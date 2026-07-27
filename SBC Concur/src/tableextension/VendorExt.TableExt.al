tableextension 50123 "Vendor-Ext" extends Vendor
{
    fields
    {
        field(50100; "Employee ID"; text[30])
        {
            Caption = 'Empmloyee ID';
            DataClassification = CustomerContent;
        }
    }
}