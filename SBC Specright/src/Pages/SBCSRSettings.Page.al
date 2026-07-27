/// <summary>
/// Page SBCSR Settings (ID 50184).
/// </summary>
page 50184 "SBCSR Settings"
{
    ApplicationArea = All;
    Caption = 'Specright Settings';
    PageType = Card;
    SourceTable = "SBCSR Settings";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Default Query Code"; Rec."Default Query Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    TableRelation = "SBCSR Query Header";
                    ToolTip = 'Specifies the value of the Default Query Code field.';
                }
                field("Item Template Code"; Rec."Item Template Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    TableRelation = "Item Templ.";
                    ToolTip = 'Specifies the value of the Item Template Code field.';
                }
                field("Disable Auto Sync"; Rec."Disable Auto Sync")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'If this is set, the auto sync on insert to the Specright Interface will be disabled.';
                }
            }
            group(API)
            {
                field("API User ID"; Rec."API User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API User ID field.';
                }
                field("API URI"; Rec."API URI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API URI field.';
                }
                field("API Password"; GlobalPasswordMaskText)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API Password field.';
                    trigger OnValidate()
                    begin
                        Rec.Validate("API Password", GlobalPasswordMaskText);
                    end;
                }
                field("API Key"; GlobalAPIKeyMaskText)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API Key field.';
                    trigger OnValidate()
                    begin
                        Rec.Validate("API Key", GlobalAPIKeyMaskText);
                    end;
                }
            }
        }
    }
    var
        GlobalAPIKeyMaskText: Text;
        GlobalPasswordMaskText: Text;
        MaskPlaceholderLabel: Label '********', Locked = true;

    trigger OnAfterGetRecord()
    begin
        if Rec.APIPasswordSet() then
            GlobalPasswordMaskText := MaskPlaceholderLabel;
        if Rec.APIKeySet() then
            GlobalAPIKeyMaskText := MaskPlaceholderLabel;
    end;
}