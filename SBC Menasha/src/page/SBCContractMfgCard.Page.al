/// <summary>
/// Page SBC Contract Mfg. Card (ID 50352).
/// </summary>
page 50352 "SBC Contract Mfg. Card"
{
    ApplicationArea = All;
    Caption = 'Contract Manufacturing';
    SourceTable = "SBC Contract Mfg. Header";
    PageType = Card;
    InsertAllowed = false;
    DeleteAllowed = false;

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
                    Visible = false;
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
                field("SBC Error Message"; Rec."SBC Error Message")
                {
                    ToolTip = 'Specifies the value of the Error Message field.';
                    Editable = false;
                }
            }
            part(Lines; "SBC Contract Mfg Subform")
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
                SubPageLink = "Table ID" = const(Database::"SBC Contract Mfg. Header"),
                              "No." = field("SBC Import Document No."),
                              "Document Type" = field("SBC Contract Type");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ProcessInvAdjust)
            {
                ApplicationArea = All;
                Caption = 'Process Contract';
                Image = PostInventoryToGL;

                trigger OnAction()
                var
                    ProcessContractMfg: Codeunit "SBC Process - Contract Mfg.";
                begin
                    ProcessContractMfg.Run(Rec);
                end;
            }
            action(Delete)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                Image = Delete;
                ToolTip = 'Creates a Posted Contract Mfg. for Processed lines and then deletes document';

                trigger OnAction()
                begin
                    Rec.ArchiveProcessedLines();
                end;
            }
            // action(ClearTransSpec)
            // {
            //     ApplicationArea = All;
            //     Caption = 'clear res. entries';
            //     Image = Delete;

            //     trigger OnAction()
            //     var
            //         TrackingSpecification: Record "Reservation Entry";
            //     begin
            //         TrackingSpecification.SetFilter("Source Type", '%1|%2', 39, 5406);
            //         TrackingSpecification.SetFilter("Source ID", '%1|%2', 'RPO100368', 'PSD17945');
            //         TrackingSpecification.DeleteAll();

            //         TrackingSpecification.SetRange("Source Type", 83);
            //         TrackingSpecification.SetRange("Source ID", 'PROD. ORDE');
            //         TrackingSpecification.DeleteAll();
            //     end;
            // }
            // action(TestCreateInv)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Create Consumption Inventory';

            //     trigger OnAction()
            //     var
            //         MenashaImportProdMgmt: Codeunit "SBC Menasha Import Prod. Mgmt.";
            //     begin
            //         MenashaImportProdMgmt.TestingOnly(Rec);
            //     end;
            // }
        }
        area(Promoted)
        {
            actionref(Delete_Promoted; Delete)
            {
            }
            actionref(ProcessInvAdjust_Promoted; ProcessInvAdjust)
            {
            }
        }
    }
}
