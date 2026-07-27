/// <summary>
/// PageExtension SBCEDI Receive Document List (ID 50087) extends Record LAX EDI Receive Document List.
/// </summary>
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
                // Promoted = true;
                // PromotedCategory = Process;
                // PromotedIsBig = true;
                ToolTip = 'Highlight EDI Receive Documents and Process them.';

                trigger OnAction()
                var
                    EDISetGlobalVariable: Codeunit "LAX EDI Set Global Variable";
                    LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.";
                    LAXEDIReceiveDocumentHdr2: Record "LAX EDI Receive Document Hdr.";
                begin
                    CurrPage.SetSelectionFilter(LAXEDIReceiveDocumentHdr);
                    if LAXEDIReceiveDocumentHdr.IsEmpty() then
                        exit;
                    LAXEDIReceiveDocumentHdr.FindSet(true);
                    repeat

                        if LAXEDIReceiveDocumentHdr."Data Error" = true then begin
                            // Skip if error is already logged
                            if not SBCEDIRecDocErrorLog.Get(LAXEDIReceiveDocumentHdr."Internal Doc. No.") then
                                "SBC Save First Error Message"(LAXEDIReceiveDocumentHdr); // Save first Error message
                        end;

                        LAXEDIReceiveDocumentHdr."Manual Process" := true;
                        LAXEDIReceiveDocumentHdr."Error Message Text" := '';
                        LAXEDIReceiveDocumentHdr.Modify;
                        Commit;
                        LAXEDIReceiveDocumentHdr2.Get(LAXEDIReceiveDocumentHdr."Internal Doc. No.");  // JIT
                        EDISetGlobalVariable.DocImportProcess(false);
                        LAXEDIReceiveDocumentHdr2.ProcessReceiveDocument(true);
                    until LAXEDIReceiveDocumentHdr.Next = 0;
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
        }

        addlast(Category_Process)
        {
            actionref(SBCProcessReceiveDocuments_Promoted; "SBC Process Receive Documents")
            {
            }
        }
    }

    local procedure "SBC Save First Error Message"(var LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.")
    var
        SBCEDIRecDocErrorLog: Record "SBC EDI Receive Doc Error Logs";
    begin
        SBCEDIRecDocErrorLog.Init();
        SBCEDIRecDocErrorLog."SBC Internal Doc. No." := LAXEDIReceiveDocumentHdr."Internal Doc. No.";
        SBCEDIRecDocErrorLog."SBC Trade Partner No." := LAXEDIReceiveDocumentHdr."Trade Partner No.";
        SBCEDIRecDocErrorLog."SBC EDI Document No." := LAXEDIReceiveDocumentHdr."EDI Document No.";
        SBCEDIRecDocErrorLog."SBC Error Message Text" := LAXEDIReceiveDocumentHdr."Error Message Text";
        SBCEDIRecDocErrorLog."SBC Error Occured At" := CurrentDateTime();

        SBCEDIRecDocErrorLog.Insert();
        Commit();
    end;

    // Update log page 
    trigger OnAfterGetRecord()
    var
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
        LAXEDIReceiveDocumentField2: Record "LAX EDI Receive Document Field";
        LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        StrLength: Integer;
        TempStr: Text[50];

    begin
        if Rec."Data Error" = true then begin
            // Skip if error is already logged
            if SBCEDIRecDocErrorLog.Get(Rec."Internal Doc. No.") then
                exit;
            "SBC Save First Error Message"(Rec);
        end;

        if (SBCEDIRecDocErrorLog.Get(Rec."Internal Doc. No.")) AND (Rec."Data Error" = false) then begin
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
                    TempStr := Text.InsStr(LAXEDIReceiveDocumentField."Field Text Value", '.', StrLength - 1);

                    LAXEDIReceiveDocumentHdr."SBC Total Invoice Amount" := TempStr;
                    LAXEDIReceiveDocumentHdr.Modify();
                    Commit();
                end;
            end;
        end;

        // Assign either sales order number or purchase order number if columns are empty
        if (Rec."SBC Sales Order No." = '') AND (Rec."SBC Purchase Order No." = '') then begin
            LAXEDIReceiveDocumentField.Reset();
            LAXEDIReceiveDocumentHdr.Reset();

            // if list field have vendor invoice no. consider record is purchase order
            LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", Rec."Internal Doc. No.");
            LAXEDIReceiveDocumentField.SetRange("Field Name", 'Vendor_Invoice_No.');
            if LAXEDIReceiveDocumentField.FindSet() then begin

                LAXEDIReceiveDocumentField2.SetRange("Internal Doc. No.", Rec."Internal Doc. No.");
                LAXEDIReceiveDocumentField2.SetRange("Field Name", 'No.');
                if (LAXEDIReceiveDocumentField2.FindSet()) AND (LAXEDIReceiveDocumentHdr."SBC Purchase Order No." = '') then begin
                    LAXEDIReceiveDocumentHdr."SBC Purchase Order No." := LAXEDIReceiveDocumentField2."Field Text Value"; // Assign purchase header no.
                end;
            end
            // if not sales order
            else begin
                LAXEDIReceiveDocumentField2.Reset();
                LAXEDIReceiveDocumentField2.SetRange("Internal Doc. No.", Rec."Internal Doc. No.");
                LAXEDIReceiveDocumentField2.SetRange("Field Name", 'No.');
                if (LAXEDIReceiveDocumentField2.FindSet()) AND (LAXEDIReceiveDocumentHdr."SBC Sales Order No." = '') then begin
                    LAXEDIReceiveDocumentHdr."SBC Sales Order No." := LAXEDIReceiveDocumentField2."Field Text Value"; // Assign sales header no.
                end;
            end;

            LAXEDIReceiveDocumentHdr.Modify();
            Commit();
        end;
    end;

    var
        SBCEDIRecDocErrorLog: Record "SBC EDI Receive Doc Error Logs";
}