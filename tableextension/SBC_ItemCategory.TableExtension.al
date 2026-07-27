tableextension 50112 "SBC_Item Category" extends "Item Category"
{
    fields
    {
        field(50000; "SBC Default Brand Dimension"; Code[10])
        {
            Caption = 'SBC Default Brand Dimension';
            DataClassification = CustomerContent;
            Description = 'This is the default Brand dimension that will be assigned to the Item when assigning the Item Category.';
            TableRelation = "Dimension Value".Code where("Dimension Code" = CONST('BRANDCAT'));
        }
    }
}