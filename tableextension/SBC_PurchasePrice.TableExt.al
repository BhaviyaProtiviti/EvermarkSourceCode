tableextension 50000 "SBC Purchase Price" extends "Purchase Price"
{
    fields
    {
        modify("Item No.")
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
            begin
                Item.Get(Rec."Item No.");

                Rec."SBC Item Description" := Item.Description;
                if not Rec.Modify() then
                    exit;
            end;
        }
        field(50500; "SBC Item Description"; Text[100])
        {
            Caption = 'Item Description';
            Editable = false;
        }
    }
}