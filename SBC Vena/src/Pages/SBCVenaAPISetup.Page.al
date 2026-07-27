/// <summary>
/// Page SBC Vena API Setup (ID 50256).
/// </summary>
page 50256 "SBC Vena API Setup"
{
    ApplicationArea = All;
    Caption = 'SBC Vena API Setup';
    PageType = Card;
    SourceTable = "SBC Vena API Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Vena Base API URI"; Rec."Vena Base API URI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vena Base API URI field.', Comment = '%';
                }
            }
            group(Authentication)
            {
                Caption = ' Authentication';

                field("Vena API User"; GlobalVenaAPIUserMaskText)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vena API User field.', Comment = '%';
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        Rec.Validate("Vena API User", GlobalVenaAPIUserMaskText);
                        GlobalVenaAPIUserMaskText := MaskPlaceholderLabel;
                        CurrPage.Update(false);
                    end;
                }
                field("Vena API Key"; GlobalVenaAPIKeyMaskText)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vena API Key field.', Comment = '%';
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        Rec.Validate("Vena API Key", GlobalVenaAPIKeyMaskText);
                        GlobalVenaAPIKeyMaskText := MaskPlaceholderLabel;
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }
    var
        MaskPlaceholderLabel: Label '********', Locked = true;
        GlobalVenaAPIKeyMaskText: Text;
        GlobalVenaAPIUserMaskText: Text;

    trigger OnAfterGetRecord()
    begin
        if Rec.APIUserSet() then
            GlobalVenaAPIUserMaskText := MaskPlaceholderLabel;
        if Rec.APIKeySet() then
            GlobalVenaAPIKeyMaskText := MaskPlaceholderLabel;
    end;
}