/// <summary>
/// TableExtension SBC Sales Shipment Header (ID 50043) extends Record Sales Shipment Header.
/// </summary>
tableextension 50043 "SBC Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(50040; "Sell-To Emerson Customer No."; Code[20])
        {
            CalcFormula = lookup(Customer."SBC Emerson Customer No." where("No." = field("Sell-to Customer No.")));
            Caption = 'Sell-To Emerson Customer No.';
            Description = 'SBC Emerson Customer No. for the Sell-To Customer';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50041; "Bill-to Emerson Customer No."; Code[20])
        {
            CalcFormula = lookup(Customer."SBC Emerson Customer No." where("No." = field("Bill-to Customer No.")));
            Caption = 'Bill-to Emerson Customer No.';
            Description = 'SBC Emerson Customer No. for the Bill-To Customer';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50042; "SBC Emerson Ship-to Code"; Code[20])
        {
            CalcFormula = lookup("Ship-to Address"."SBC Emerson Ship-to Code" where("Customer No." = field("Sell-to Customer No."), Code = field("Ship-to Code")));
            Caption = 'SBC Emerson Ship-to Code';
            Description = 'SBC Emerson Ship-to Code for the Sell-To Customer';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}
