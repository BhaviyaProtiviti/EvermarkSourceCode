/// <summary>
/// Table STA Bracket Price (ID 50212).
/// </summary>
table 50212 "STA Bracket Price"
{
    Caption = 'STA Bracket Price';
    DataClassification = CustomerContent;
    DrillDownPageId = "STA Bracket Prices";
    LookupPageId = "STA Bracket Prices";
    Extensible = true;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Description = 'A reference to the Item table.';
            TableRelation = "Item"."No.";
        }
        field(2; "Bracket Price Code"; Code[20])
        {
            Caption = 'Bracket Price Code';
            Description = 'A reference to the Bracket table.';
            TableRelation = "STA Bracket Price Code"."Bracket Price Code";
        }
        field(3; "Bracket Unit Price"; Decimal)
        {
            Caption = 'Bracket Unit Price';
            Description = 'The unit price of the item in the bracket.';
        }
        field(4; "Bracket Case Price"; Decimal)
        {
            Caption = 'Bracket Case Price';
            Description = 'The case price of the item in the bracket.';
        }
        field(5; "Item Unit Price"; Decimal)
        {
            Caption = 'Item Unit Price';
            Description = 'The list unit price of the item in the bracket.';
        }
        field(6; "Item UPC"; Code[20])
        {
            Caption = 'Item UPC';
            Description = 'The UPC of the item.';
        }
        field(7; "Case UPC"; Code[20])
        {
            Caption = 'Case UPC';
            Description = 'The UPC of the case.';
        }
        field(8; UCC14; Code[20])
        {
            Caption = 'UCC14';
            Description = 'The UCC14 of the item.';
        }
        field(9; "Units per Case"; Integer)
        {
            Caption = 'Units per Case';
            Description = 'The number of units per case.';
        }
        field(10; "Promo Family"; Code[20])
        {
            Caption = 'Promo Family';
            Description = 'The promo family of the item.';
        }
        field(11; Active; Boolean)
        {
            Caption = 'Active';
            Description = 'A reference to the SBC Status field. True if Active, false if Do Not Sell.';
        }
        field(12; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            Description = 'Specifies the country or region of the address';
            TableRelation = "Country/Region".Code;
        }
    }
    keys
    {
        key(PK; "Item No.", "Bracket Price Code")
        {
            Clustered = true;
        }
    }
}