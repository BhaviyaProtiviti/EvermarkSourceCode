table 50150 "SBC Sales Order Cut Lines"
{
    Caption = 'SBC Sales Order Cut Lines';
    DataClassification = CustomerContent;

    fields
    {

        field(1; "SBC Entry No."; Integer)
        {
            Caption = 'SBC Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "SBC Order No."; Code[20])
        {
            Caption = 'SBC Order No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "SBC Sell-to Customer No."; Code[20])
        {
            Caption = 'SBC Sell-to Customer No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "SBC Line No."; Integer)
        {
            Caption = 'SBC Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "SBC No."; Code[20])
        {
            Caption = 'SBC No.';
            DataClassification = CustomerContent;
        }
        field(6; "SBC Shipment Date"; Date)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'SBC Shipment Date';
            DataClassification = CustomerContent;
        }
        field(7; "SBC Description"; Text[100])
        {
            Caption = 'SBC Description';
            DataClassification = CustomerContent;
        }
        field(8; "SBC Unit of Measure"; Text[50])
        {
            Caption = 'SBC Unit of Measure';
            DataClassification = CustomerContent;
        }
        field(9; "SBC Order Quantity"; Decimal)
        {
            Caption = 'SBC Order Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(10; "SBC Qty Invoiced"; Decimal)
        {
            Caption = 'SBC Qty Invoice';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(11; "SBC Invoice No."; Code[20])
        {
            Caption = 'SBC Invoice No.';
            DataClassification = CustomerContent;
        }
        field(18; "SBC Qty Shipped"; Decimal)
        {
            Caption = 'SBC Qty Shipped';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(12; "SBC Cut Quantity"; Decimal)
        {
            Caption = 'SBC Cut Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
    }
    keys
    {
        key(PK; "SBC Entry No.")
        {
            Clustered = true;
        }
    }
}
