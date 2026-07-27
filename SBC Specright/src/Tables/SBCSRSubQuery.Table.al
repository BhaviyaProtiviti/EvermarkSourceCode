/// <summary>
/// Table SBCSR Sub Query (ID 50183).
/// </summary>
table 50183 "SBCSR Sub Query"
{
    Caption = 'SBCSR Sub Query';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Query Code"; Code[20])
        {
            Caption = 'Query Code';
        }
        field(2; "Sub Query Code"; Code[20])
        {
            Caption = 'Sub Query Code';
        }
    }
    keys
    {
        key(PK; "Query Code", "Sub Query Code")
        {
            Clustered = true;
        }
    }

    var
        SameQueryCodeErrorLabel: Label 'Query Code and Sub Query Code cannot be the same.';

    trigger OnInsert()
    begin
        CheckQueryCodes();
    end;

    trigger OnModify()
    begin
        CheckQueryCodes();
    end;

    local procedure CheckQueryCodes()
    begin
        if Rec."Query Code" = Rec."Sub Query Code" then
            Error(SameQueryCodeErrorLabel);
    end;


}