/// <summary>
///  This table is used to store a list of email addresses to include email exports.
/// </summary>
table 50060 "SBCOE Export Email List"
{
    Caption = 'Export Mail List';
    DataClassification = EndUserIdentifiableInformation;
    Description = 'This table is used to store a list of email addresses to include on exported data.';
    DrillDownPageId = "SBCOE Email List Part";
    LookupPageId = "SBCOE Email List Part";
    fields
    {
        field(1; "Email Group Code"; Code[20])
        {
            Caption = 'Email Group Code';
            DataClassification = EndUserIdentifiableInformation;
            Description = 'Code for the Email group.';
            TableRelation = "SBCOE Export Email Group"."Email Group Code";
        }
        field(2; "Email Address"; Text[255])
        {
            Caption = 'Email Address';
            DataClassification = EndUserIdentifiableInformation;
            Description = 'Email Address to CC on order exports.';

            trigger OnValidate()
            var
            begin
                Rec.Enabled := IsValidEmailAddress(Rec."Email Address");
            end;
        }
        field(3; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            Description = 'Determines if the email address is enabled.';

            trigger OnValidate()
            begin
                CheckEmailValidity();
            end;
        }
        field(4; "Email Type"; Enum "Email Recipient Type")
        {
            Caption = 'Email Type';
            DataClassification = EndUserIdentifiableInformation;
            Description = 'The address type of the email address.';
            InitValue = To;
        }
        field(5; "Email Placement Order"; Integer)
        {
            BlankZero = true;
            Caption = 'Email Placement Order';
            DataClassification = CustomerContent;
            Description = 'The order in which the email address will be placed in the email.';
        }
    }

    keys
    {
        key(Key1; "Email Group Code", "Email Address")
        {
            Clustered = true;
        }
        key(Key2; Enabled, "Email Type", "Email Placement Order")
        {
            Description = 'Sorting and filtering key for Enabled by Email Type by Placement Order.';
        }
    }

    var
        InvalidEmailAddressErrorLabel: Label 'Invalid Email Address. Please update it and try again.';
        InvalidEmailBlankGuidLabel: Label '00000000-0000-0000-0000-000000000000';
        InvalidEmailErrorTitleLabel: Label 'Invalid Email Address';
        InvalidEmailSearchPatternLabel: Label '^[a-zA-Z0-9._%+-]{1,64}@[a-zA-Z0-9.-]{1,250}\.[a-zA-Z]{2,}$';

    /// <summary>
    /// Checks the validity of an email address.
    /// </summary>
    internal procedure CheckEmailValidity()
    begin
        if not Rec.Enabled then
            exit;
        Rec.Enabled := Rec.IsValidEmailAddress(Rec."Email Address");
        if Rec.Enabled then
            exit;
        GenerateInvalidEmailError();
    end;
    /// <summary>
    /// Checks an input email against a regular expression to ensure it is valid.
    /// </summary>
    /// <param name="InputEmail">Text.</param>
    /// <returns>Return variable Valid of type Boolean.</returns>
    internal procedure IsValidEmailAddress(InputEmail: Text) Valid: Boolean
    var
        Regex: Codeunit Regex;
    begin
        Regex.Regex(InvalidEmailSearchPatternLabel);
        Valid := Regex.IsMatch(InputEmail);
    end;

    /// <summary>
    /// Generates an error for an invalid email address.
    /// </summary>
    local procedure GenerateInvalidEmailError()
    var
        SBCOEErrorHelper: Codeunit "SBCOE Error Helper";
        InvalidEmailErrorInfo: ErrorInfo;
    begin
        InvalidEmailErrorInfo := SBCOEErrorHelper.CreateCollectableErrorInfo(Rec.RecordId().GetRecord(), Rec.FieldName(Rec."Email Address"), Rec.FieldNo(Rec."Email Address"), Page::"SBCOE Email List Part", Database::"SBCOE Export Email List", InvalidEmailAddressErrorLabel, InvalidEmailErrorTitleLabel, DataClassification::EndUserIdentifiableInformation, Verbosity::Warning);
        Error(InvalidEmailErrorInfo);
    end;
}
