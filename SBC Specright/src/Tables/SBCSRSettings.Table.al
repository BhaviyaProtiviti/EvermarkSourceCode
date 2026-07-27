/// <summary>
/// Table Specright Settings (ID 50180).
/// </summary>
table 50180 "SBCSR Settings"
{
    Caption = 'SBC Specright Settings';
    DataClassification = EndUserPseudonymousIdentifiers;

    fields
    {
        field(1; "Key"; Code[1])
        {
            Caption = 'Key';
            DataClassification = SystemMetadata;
        }
        field(10; "Item Template Code"; Code[20])
        {
            Caption = 'Item Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Templ.";
        }
        field(20; "API URI"; Text[200])
        {
            Caption = 'API URI';
        }
        field(21; "API User ID"; Text[200])
        {
            Caption = 'API User ID';
        }
        field(22; "API Password"; Text[40])
        {
            Caption = 'API Password';
            ExtendedDatatype = Masked;
            trigger OnValidate()
            begin
                GlobalSBCSRAuthentication.SetPasswordValue(Rec."API Password");
                Rec."API Password" := '';
            end;
        }
        field(23; "API Key"; Text[40])
        {
            Caption = 'API Key';
            ExtendedDatatype = Masked;
            trigger OnValidate()
            begin
                GlobalSBCSRAuthentication.SetAPIKeyValue(Rec."API Key");
                Rec."API Key" := '';
            end;
        }

        field(30; "Last Authenticated"; DateTime)
        {
            Caption = 'Last Authenticated';
            DataClassification = SystemMetadata;
        }
        field(31; "Expires In"; Integer)
        {
            Caption = 'Expires In';
            DataClassification = SystemMetadata;
            Description = 'Time in milliseconds when the token expires';
        }

        field(40;"Default Query Code"; Code[20])
        {
            Caption = 'Default Query Code';
            DataClassification = CustomerContent;
            TableRelation = "SBCSR Query Header";
        }
        field(41;"Disable Auto Sync"; Boolean)
        {
            Caption = 'Disable Auto Sync';
            DataClassification = CustomerContent;
            Description = 'If this is set, the auto sync on insert to the Specright Interface will be disabled.';
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
        GlobalSBCSRAuthentication: Codeunit "SBCSR Authentication";

    internal procedure APIKeySet() Result: Boolean
    begin
        Result := GlobalSBCSRAuthentication.APIKeySet();
    end;

    internal procedure APIPasswordSet() Result: Boolean
    begin
        Result := GlobalSBCSRAuthentication.APIPasswordSet();
    end;

    internal procedure SetLastAuthenticated(ExpiresIn: Integer)
    begin
        Rec."Last Authenticated" := CurrentDateTime;
        Rec."Expires In" := ExpiresIn;
        Rec.Modify();
    end;

    internal procedure ClearLastAuthenticated()
    begin
        Rec."Last Authenticated" := 0DT;
        Rec."Expires In" := 0;
        Rec.Modify();
    end;



}