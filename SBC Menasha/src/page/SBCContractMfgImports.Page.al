/// <summary>
/// Page SBC Contract Mfg. List (ID 50351).
/// </summary>
page 50351 "SBC Contract Mfg. List"
{
    ApplicationArea = All;
    Caption = 'Contract Manufacturing List';
    SourceTable = "SBC Contract Mfg. Header";
    CardPageId = "SBC Contract Mfg. Card";
    UsageCategory = Lists;
    PageType = List;
    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("SBC Import Document No."; Rec."SBC Import Document No.")
                {
                    ToolTip = 'Specifies the value of the Import Document No. field.';
                }
                field("SBC Contract Source"; Rec."SBC Contract Source")
                {
                    ToolTip = 'Specifies the value of the Contract Mfg. Source';
                    Visible = false;
                }
                field("SBC Contract Mgf. File Type"; Rec."SBC Contract Type")
                {
                    ToolTip = 'Specifies the value of the Contract Mfg. file Type field.';
                }
                field("SBC Import Receive Date"; Rec."SBC Import Receive Date")
                {
                    ToolTip = 'Specifies the value of the Import Received Date field.';
                }
                field("SBC Import Name"; Rec."SBC Import Name")
                {
                    ToolTip = 'Specifies the value of the Import Name field.';
                }
                field("SBC Has Line Errors"; Rec."SBC Has Line Errors")
                {
                    ToolTip = 'Specifies the value of the Has Line Errors field.';
                }
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(Database::"SBC Contract Mfg. Header"),
                              "No." = FIELD("SBC Import Document No."),
                              "Document Type" = field("SBC Contract Type");
            }
        }
    }

    actions
    {
        area(Processing)
        {
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
            action(Import)
            {
                Caption = 'Import Contract Mfg. File';
                Image = Import;
                ApplicationArea = All;

                trigger OnAction()
                var
                    ImportFileMgmt: Codeunit "SBC Import File Mgmt";
                begin
                    ImportFileMgmt.ImportExcelSheet();
                end;
            }
        }

        area(Promoted)
        {
            actionref(Delete_Promoted; Delete)
            {
            }
            actionref(Import_Promoted; Import)
            {
            }
        }
    }
}
