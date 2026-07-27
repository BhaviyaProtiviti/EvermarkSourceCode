/// <summary>
/// Page SBC Posted Contract (ID 50355).
/// </summary>
page 50355 "SBC Posted Contract"
{
    ApplicationArea = All;
    Caption = 'Posted Contract';
    PageType = Card;
    SourceTable = "SBC Posted Contract Mfg Hdr";
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("SBC Import Document No."; Rec."SBC Import Document No.")
                {
                    ToolTip = 'Specifies the value of the Import Document No. field.';
                    Editable = false;
                }
                field("SBC Contract Source"; Rec."SBC Contract Source")
                {
                    ToolTip = 'Specifies the value of the Contract Mfg. Source field.';
                    Editable = false;
                }
                field("SBC Contract Type"; Rec."SBC Contract Type")
                {
                    ToolTip = 'Specifies the value of the Contract Mfg. File Type field.';
                    Editable = false;
                }
                field("SBC Import Name"; Rec."SBC Import Name")
                {
                    ToolTip = 'Specifies the value of the Import Name field.';
                    Editable = false;
                }
                field("SBC Import Receive Date"; Rec."SBC Import Receive Date")
                {
                    ToolTip = 'Specifies the value of the Import Received Date field.';
                    Editable = false;
                }
            }
            part(Lines; "SBC Posted Contract Subform")
            {
                ApplicationArea = all;
                Caption = 'Lines';
                SubPageLink = "SBC Import Document No." = field("SBC Import Document No."), "SBC Contract Source" = field("SBC Contract Source"), "SBC Contract Type" = field("SBC Contract Type");
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"SBC Posted Contract Mfg Hdr"),
                              "No." = field("SBC Import Document No."),
                              "Document Type" = field("SBC Contract Type");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Reopen)
            {
                ApplicationArea = All;
                Caption = 'Reopen';
                ToolTip = 'Send Posted Contract back to Contract Mfg page to attempt reprocessing.';
                Image = ReOpen;

                trigger OnAction()
                var
                   SBCContractMfgHeader: Record "SBC Contract Mfg. Header";
                   SBCContractMfgLine: Record "SBC Contract Mfg. Line";
                   SBCPostedContractMfgLine: Record "SBC Posted Contract Mfg Line";
                begin
                    if not confirm('Reopening this Posted Contract will create a copy in Contract Mfg. Do you want to continue?') then
                        exit;

                        SBCContractMfgHeader.init();
                        SBCContractMfgHeader.TransferFields(Rec, true);
                        SBCContractMfgHeader."SBC Import Document No." := Rec."SBC Import Document No." + ' - Reopen';
                        if SBCContractMfgHeader.Insert(true) then begin
                            SBCPostedContractMfgLine.SetRange("SBC Import Document No.", Rec."SBC Import Document No.");
                            SBCPostedContractMfgLine.SetRange("SBC Contract Source", Rec."SBC Contract Source");
                            SBCPostedContractMfgLine.SetRange("SBC Contract Type", Rec."SBC Contract Type");
                            if SBCPostedContractMfgLine.FindSet() then begin
                                repeat
                                    SBCContractMfgLine.init();
                                    SBCContractMfgLine.TransferFields(SBCPostedContractMfgLine, true);
                                    SBCContractMfgLine."SBC Import Document No." := SBCContractMfgHeader."SBC Import Document No.";
                                    SBCContractMfgLine.Insert(true);
                                until SBCPostedContractMfgLine.Next() = 0;
                            end;
                        end;

                        if confirm('Posted Contract has been reopened and copied to Contract Mfg. Do you want to open the Contract Mfg. page?') then begin                            
                            PAGE.Run(PAGE::"SBC Contract Mfg. Card", SBCContractMfgHeader);
                        end;
                end;
            }
        }
    }
}

