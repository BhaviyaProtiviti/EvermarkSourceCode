/// <summary>
/// Page SBC Posted Contracts (ID 50354).
/// </summary>
page 50354 "SBC Posted Contracts"
{
    ApplicationArea = All;
    Caption = 'Posted Contracts';
    SourceTable = "SBC Posted Contract Mfg Hdr";
    CardPageId = "SBC Posted Contract";
    UsageCategory = Lists;
    PageType = List;
    InsertAllowed = false;

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
                }
                field("SBC Contract Type"; Rec."SBC Contract Type")
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
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(Database::"SBC Posted Contract Mfg Hdr"),
                              "No." = FIELD("SBC Import Document No."),
                  "Document Type" = field("SBC Contract Type");
            }
        }
    }
}

