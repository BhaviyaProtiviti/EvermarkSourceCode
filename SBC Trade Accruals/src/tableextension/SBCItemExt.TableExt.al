tableextension 50701 "SBC Item Ext" extends Item
{
    fields
    {
        field(50700; "Inbound Freight Rate"; Decimal)
        {
            Caption = 'Inbound Freight Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(50701; "WB Inbound Variable"; Decimal)
        {
            Caption = 'WH Inbound Variable';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(50702; "WH Overhead - Fixed"; Decimal)
        {
            Caption = 'WH Overhead - Fixed';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(50703; "SBC Custom/Duty"; Decimal)
        {
            Caption = 'Custom/Duty';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
    }
}