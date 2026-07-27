tableextension 50169 "SBC Location Ext" extends Location
{
    fields
    {
        field(50000; "SBC Physical Warehouse"; Code[20])
        {
            Caption = 'Physical Warehouse';
            TableRelation = "Location"."Code";
            Editable = true;
            DataClassification = CustomerContent;
        }
    }
}
