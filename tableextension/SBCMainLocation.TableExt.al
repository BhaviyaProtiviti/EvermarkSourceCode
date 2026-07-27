tableextension 50007 "SBC Main Location" extends Location
{
    fields
    {
        field(50100; "SBC Has Max Weight Req."; Boolean)
        {
            Caption = 'SBC Has Max Weight Req.';
            DataClassification = CustomerContent;
        }
        field(50101; "SBC Transfer Max Weight Allow"; Decimal)
        {
            Caption = 'SBC Transfer Max Weight Allowed';
            DataClassification = CustomerContent;
        }
    }
}
