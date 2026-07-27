/// <summary>
/// PageExtension SBCEDI Receive Document List (ID 50087) extends Record LAX EDI Receive Document List.
/// </summary>
/// 
/*
pageextension 50087 "SBCEDI Receive Document List" extends "LAX EDI Receive Document List"
{

    actions
    {
        addafter("&Process Receive Document")
        {

            action("SBC Process Receive Documents")
            {
                ApplicationArea = All;
                Caption = 'SBC Process Multiple Documents';
                Image = ElectronicDoc;
                ToolTip = 'Highlight EDI Receive Documents and Process them.';

                trigger OnAction()
                var
                    LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.";
                    LAXEDIReceiveDocumentHdr2: Record "LAX EDI Receive Document Hdr.";
                    EDISetGlobalVariable: Codeunit "LAX EDI Set Global Variable";
                begin
                    CurrPage.SetSelectionFilter(LAXEDIReceiveDocumentHdr);
                    if LAXEDIReceiveDocumentHdr.IsEmpty() then
                        exit;
                    LAXEDIReceiveDocumentHdr.FindSet(true);
                    repeat

                        if LAXEDIReceiveDocumentHdr."Data Error" = true then
                            // Skip if error is already logged
                            if not SBCEDIRecDocErrorLog.Get(Rec."Internal Doc. No.") then
                                "SBC Save First Error Message"(LAXEDIReceiveDocumentHdr);

                        LAXEDIReceiveDocumentHdr."Manual Process" := true;
                        LAXEDIReceiveDocumentHdr."Error Message Text" := '';
                        LAXEDIReceiveDocumentHdr.Modify();
                        Commit();
                        LAXEDIReceiveDocumentHdr2.Get(LAXEDIReceiveDocumentHdr."Internal Doc. No.");  // JIT
                        EDISetGlobalVariable.DocImportProcess(false);
                        LAXEDIReceiveDocumentHdr2.ProcessReceiveDocument(true);
                    until LAXEDIReceiveDocumentHdr.Next() = 0;
                    CurrPage.Update(false);
                end;
            }

            action("SBC Update Discrepancy Flag")
            {
                ApplicationArea = All;
                Caption = 'SBC Update Discrepancy Flag';
                ToolTip = 'This action will update the discrepancy flag on the EDI Receive Document Header based on the value set on the EDI template.';
                Image = Change;
                RunObject = Report "SBCEDI Update Discrepancy Flag";
                Visible = false;
            }
            // action(clearCustomFields)
            // {
            //     ApplicationArea = All;
            //     Caption = 'SBC Clear Custom Fields';
            //     ToolTip = 'This action will clear all the custom fields on the EDI Receive Document Header and Lines.';
            //     Image = Delete;

            //     trigger OnAction()
            //     var
            //         LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.";
            //     begin
            //         if LAXEDIReceiveDocumentHdr.FindSet() then begin
            //             LAXEDIReceiveDocumentHdr.ModifyAll("SBC Sales Order No.", '');
            //             LAXEDIReceiveDocumentHdr.ModifyAll("SBC Purchase Order No.", '');
            //             LAXEDIReceiveDocumentHdr.ModifyAll("SBC Vendor Invoice No.", '');
            //             LAXEDIReceiveDocumentHdr.ModifyAll("SBC Total Invoice Amount", '');
            //             Commit();
            //         end;
            //     end;
            // }
        }
        addlast(Category_Process)
        {
            actionref(SBCProcessReceiveDocuments_Promoted; "SBC Process Receive Documents")
            {
            }
        }
    }

    // Update log page 

    trigger OnAfterGetRecord()
    var
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
        LAXEDIReceiveDocumentField2: Record "LAX EDI Receive Document Field";
        LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.";
        StrLength: Integer;
        TempStr: Text[50];

    begin
        if Rec."Data Error" = true then
            // Skip if error is already logged
            if not SBCEDIRecDocErrorLog.Get(Rec."Internal Doc. No.") then
                "SBC Save First Error Message"(Rec);

        if (SBCEDIRecDocErrorLog.Get(Rec."Internal Doc. No.")) and (Rec."Data Error" = false) then begin
            SBCEDIRecDocErrorLog."SBC Error Resolved At" := CurrentDateTime();
            SBCEDIRecDocErrorLog.Modify(true);
            Commit();
        end;

        LAXEDIReceiveDocumentHdr.Get(Rec."Internal Doc. No.");

        if Rec."EDI Document No." = '810' then begin
            if Rec."SBC Vendor Invoice No." = '' then begin
                LAXEDIReceiveDocumentField.Reset();
                LAXEDIReceiveDocumentHdr.Reset();

                LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", Rec."Internal Doc. No.");
                LAXEDIReceiveDocumentField.SetRange("Field Name", 'Vendor_Invoice_No.');
                if LAXEDIReceiveDocumentField.FindSet() then begin

                    LAXEDIReceiveDocumentHdr."SBC Vendor Invoice No." := LAXEDIReceiveDocumentField."Field Text Value"; // Assign Vendor Invoice No.
                    LAXEDIReceiveDocumentHdr.Modify();
                    Commit();
                end;
            end;

            // Assign total invoice amount
            if Rec."SBC Total Invoice Amount" = '' then begin
                LAXEDIReceiveDocumentField.Reset();
                LAXEDIReceiveDocumentHdr.Reset();

                LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", Rec."Internal Doc. No.");
                LAXEDIReceiveDocumentField.SetRange("Field Name", 'Total Invoice Amount');
                if LAXEDIReceiveDocumentField.FindSet() then begin

                    // add decimal point
                    StrLength := Text.StrLen(LAXEDIReceiveDocumentField."Field Text Value");
                    if (StrLength - 1) > 0 then
                        TempStr := Text.InsStr(LAXEDIReceiveDocumentField."Field Text Value", '.', StrLength - 1)
                    else
                        TempStr := (LAXEDIReceiveDocumentField."Field Text Value" + '.00');

                    LAXEDIReceiveDocumentHdr."SBC Total Invoice Amount" := TempStr;
                    LAXEDIReceiveDocumentHdr.Modify();
                    Commit();
                end;
            end;
        end;

        // Assign either sales order number or purchase order number if columns are empty
        if (Rec."SBC Sales Order No." = '') and (Rec."SBC Purchase Order No." = '') then begin
            LAXEDIReceiveDocumentField.Reset();
            LAXEDIReceiveDocumentHdr.Reset();

            // if list field have vendor invoice no. consider record is purchase order
            LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", Rec."Internal Doc. No.");
            LAXEDIReceiveDocumentField.SetRange("Field Name", 'Vendor_Invoice_No.');
            if not LAXEDIReceiveDocumentField.IsEmpty() then begin
                LAXEDIReceiveDocumentField2.SetRange("Internal Doc. No.", Rec."Internal Doc. No.");
                LAXEDIReceiveDocumentField2.SetRange("Field Name", 'No.');
                if (LAXEDIReceiveDocumentField2.FindSet()) and (LAXEDIReceiveDocumentHdr."SBC Purchase Order No." = '') then
                    LAXEDIReceiveDocumentHdr."SBC Purchase Order No." := LAXEDIReceiveDocumentField2."Field Text Value"; // Assign purchase header no.
            end else begin
                // if not sales order
                LAXEDIReceiveDocumentField2.Reset();
                LAXEDIReceiveDocumentField2.SetRange("Internal Doc. No.", Rec."Internal Doc. No.");
                LAXEDIReceiveDocumentField2.SetRange("Field Name", 'No.');
                if (LAXEDIReceiveDocumentField2.FindLast()) and (LAXEDIReceiveDocumentHdr."SBC Sales Order No." = '') then
                    LAXEDIReceiveDocumentHdr."SBC Sales Order No." := LAXEDIReceiveDocumentField2."Field Text Value"; // Assign sales header no.
            end;

            LAXEDIReceiveDocumentHdr.Modify();
            Commit();
        end;
    end;


    local procedure "SBC Save First Error Message"(var LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.")
    var
        EDIRecDocErrorLog: Record "SBC EDI Receive Doc Error Logs";
    begin
        EDIRecDocErrorLog.Init();
        EDIRecDocErrorLog."SBC Internal Doc. No." := LAXEDIReceiveDocumentHdr."Internal Doc. No.";
        EDIRecDocErrorLog."SBC Trade Partner No." := LAXEDIReceiveDocumentHdr."Trade Partner No.";
        EDIRecDocErrorLog."SBC EDI Document No." := LAXEDIReceiveDocumentHdr."EDI Document No.";
        EDIRecDocErrorLog."SBC Error Message Text" := LAXEDIReceiveDocumentHdr."Error Message Text";
        EDIRecDocErrorLog."SBC Error Occured At" := CurrentDateTime();

        EDIRecDocErrorLog.Insert();
        Commit();
    end;

    var
        SBCEDIRecDocErrorLog: Record "SBC EDI Receive Doc Error Logs";
}
*/