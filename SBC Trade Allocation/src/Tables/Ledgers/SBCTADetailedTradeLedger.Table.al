/// <summary>
/// Detailed posting ledger for Trade Budget Ledger entries.
/// </summary>
table 50207 "SBCTA Detailed Trade Ledger"
{
    Caption = 'Detailed Trade Ledger';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Trade Budget Code"; Code[20])
        {
            Caption = 'Trade Budget Code';
            DataClassification = CustomerContent;
            Description = 'This code identifies the Trade Budget and set of rates associated with it.';
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Description = 'This is the document number that this entry is associated with.';
            TableRelation = "Sales Invoice Header";
        }
        field(4; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            Description = 'This is the line number of the Document associated with this entry.';
        }
        field(5; "Document Line Type"; Enum "Sales Line Type")
        {
            Caption = 'Document Line Type';
        }
        field(6; "No."; Code[20])
        {

            Caption = 'No.';
            TableRelation = IF ("Document Line Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Document Line Type" = CONST(Item)) Item
            ELSE
            IF ("Document Line Type" = CONST(Resource)) Resource
            ELSE
            IF ("Document Line Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("Document Line Type" = CONST("Charge (Item)")) "Item Charge";
        }
        field(7; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
        }
        field(8; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
        }
        field(9; "Trade Budget Rate Code"; Code[20])
        {
            Caption = 'Trade Budget Rate Code';
        }
        field(10; "Trade Budget Rate Type"; Enum "SBCTA Tr. Budget Rate Type")
        {
            Caption = 'Trade Budget Rate Type';
            DataClassification = CustomerContent;
            Description = 'This code identifies the type of Trade Budget Rate.';
        }
        field(11; "Trade Budget Rate"; Decimal)
        {
            Caption = 'Trade Budget Rate';
            DataClassification = CustomerContent;
            Description = 'This is the rate that will be applied to the Customer Price Group.';
        }
        field(12; "T/L Entry No."; Integer)
        {
            Caption = 'T/L Entry No.';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}