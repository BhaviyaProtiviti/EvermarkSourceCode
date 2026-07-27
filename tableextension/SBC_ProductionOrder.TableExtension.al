tableextension 50105 "SBC_Production Order" extends "Production Order"
{
    fields
    {
        field(50000; "SBC Subcontracting Purch.Order"; Code[20])
        {
            Caption = 'Subcontracting Purchase Order';
            DataClassification = CustomerContent;
            Description = 'This is the related Subcontracting Purchase Order.';
        }
        field(50001; "SBC Subcontracting Trans.Order"; Code[20])
        {
            Caption = 'Subcontracting Transfer Order';
            DataClassification = CustomerContent;
            Description = 'This is the related Subcontracting Transfer Order.';
        }
        field(50002; "SBC Original Purch Order No."; Code[20])
        {
            Caption = 'Original Subcontracting Purch. Order No.';
            DataClassification = CustomerContent;
            Description = 'This is the Original Subcontracting Purch. Order No.';
        }
        field(50003; "SBC Original Trans. Order No."; Code[20])
        {
            Caption = 'Original Subcontracting Transfer Order No.';
            DataClassification = CustomerContent;
            Description = 'This is the related Original Subcontracting Transfer Order No.';
        }
        field(50100; "SBC Override Exact Qty."; Boolean)
        {
            Caption = 'Override Pallet Rounding';
            DataClassification = CustomerContent;
        }
        field(50101; "SBC Total Transfer Orders"; Integer)
        {
            Caption = 'Total Transfer Orders';
            CalcFormula = count("Transfer Header" where("SBC Production Order No." = field("No.")));
            fieldclass = FlowField;
        }
    }
}