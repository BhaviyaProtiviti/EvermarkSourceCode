/// <summary>
/// This table is used to store the Trade Budget Rate Codes that are used to organize budget rates on Trade Budgets.
/// </summary>
table 50203 "SBCTA Trade Budget Rate Codes"
{
    Caption = 'Trade Rate Codes';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Trade Budget Rate Code"; Code[20])
        {
            Caption = 'Trade Rate Code';
            DataClassification = CustomerContent;
            Description = 'This is an organizational and tracking code that is used to organize budget rates on Trade Budgets.';
        }
        field(2; Description; Text[200])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Description = 'This is a brief description of the Trade Budget Rate Code.';
        }
        field(3; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = SystemMetadata;
            Description = 'When this field is set, the trade budget rate code is blocked and cannot be used for new trade budgets.';
        }
        field(4; "Rate Type"; Enum "SBCTA Budget Group Type")
        {
            Caption = 'Rate Type';
            DataClassification = CustomerContent;
            Description = 'The budget group type the rate is used for.';
            trigger OnValidate()
            begin
                if Rec."Rate Type" <> "SBCTA Budget Group Type"::Item then
                    exit;
                if Rec."Calculation Method" = "SBCTA COGs Calc Type"::"Cost Only" then
                    exit;
                Rec."Calculation Method" := "SBCTA COGs Calc Type"::"Cost Only";
            end;
        }
        field(5; "Calculation Method"; Enum "SBCTA COGs Calc Type")
        {
            Caption = 'Calculation Method';
            DataClassification = CustomerContent;
            Description = 'The calculation method used to calculate the COGs for the trade budget rate code.';
        }
    }
    keys
    {
        key(PK; "Trade Budget Rate Code")
        {
            Clustered = true;
        }
        key(Key2; "Rate Type")
        {
            Description = 'Sorting Key';
        }

    }
}