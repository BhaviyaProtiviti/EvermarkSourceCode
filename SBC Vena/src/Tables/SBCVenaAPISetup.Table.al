/// <summary>
/// Table SBC Vena API Setup (ID 50256).
/// </summary>
table 50256 "SBC Vena API Setup"
{
    Caption = 'SBC Vena API Setup';
    DataClassification = OrganizationIdentifiableInformation;
    DrillDownPageId = "SBC Vena API Setup";
    LookupPageId = "SBC Vena API Setup";

    fields
    {
        field(1; "Key"; Code[1])
        {
            Caption = 'Key';
        }
        field(2; "Vena API User"; Text[40])
        {
            Caption = 'Vena API User';
            ExtendedDatatype = Masked;
            trigger OnValidate()
            begin
                GlobalSBCVenaHelper.SetAuthenticationValue(VenaAPIUserLabel, Rec."Vena API User");
                Rec."Vena API User" := MaskPlaceholderLabel;
            end;
        }
        field(3; "Vena API Key"; Text[40])
        {
            Caption = 'Vena API Key';
            ExtendedDatatype = Masked;
            trigger OnValidate()
            begin
                GlobalSBCVenaHelper.SetAuthenticationValue(VenaAPIKeyLabel, Rec."Vena API Key");
                Rec."Vena API Key" := MaskPlaceholderLabel;
            end;
        }
        field(4; "Vena Base API URI"; Text[200])
        {
            Caption = 'Vena Base API URI';
        }
    }
    keys
    {
        key(PK; "Key")
        {
            Clustered = true;
        }
    }
    var
        GlobalSBCVenaHelper: Codeunit "SBC Vena Helper";
        MaskPlaceholderLabel: Label '********', Locked = true;
        VenaAPIKeyLabel: Label 'VenaAPIKey';
        VenaAPIUserLabel: Label 'VenaAPIUser';


#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure GetAPIKeyValue() Value: Text
    begin
        IsolatedStorage.Get(VenaAPIKeyLabel, DataScope::Module, Value);
    end;

#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure GetAPIUserValue() Value: Text
    begin
        IsolatedStorage.Get(VenaAPIUserLabel, DataScope::Module, Value);
    end;
#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure APIKeySet() Result: Boolean
    begin
        Result := IsolatedStorage.Contains(VenaAPIKeyLabel, DataScope::Module);
    end;

#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure APIUserSet() Result: Boolean
    begin
        Result := IsolatedStorage.Contains(VenaAPIUserLabel, DataScope::Module);
    end;

}