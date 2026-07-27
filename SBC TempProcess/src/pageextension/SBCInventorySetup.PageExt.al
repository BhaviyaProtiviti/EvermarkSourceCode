pageextension 60000 "SBC Inventory Setup" extends "Inventory Setup"
{
    actions
    {
        addlast(Processing)
        {
            action(Delete_ItemAttribute)
            {
                ApplicationArea = All;
                Caption = 'Delete Item Attribute';                
                Image = Delete;
                Tooltip = 'Delete Item Attribute Value Mapping';

                trigger OnAction()
                var
                    ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
                    DeleteAttributeMapLbl: Label 'This process will delete the Item Attribute Value Mapping for the Item Attribute ID 61 and Item Attribute Value ID 0. Do you want to continue?';
                begin
                    if confirm(deleteAttributeMapLbl) then begin
                        ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
                        ItemAttributeValueMapping.SetRange("Item Attribute ID", 61);
                        ItemAttributeValueMapping.SetRange("Item Attribute Value ID", 0);
                        if ItemAttributeValueMapping.FindSet() then begin
                            ItemAttributeValueMapping.DeleteAll(true);
                            Message('Item Attribute Value Mapping deleted successfully.');
                        end else
                            Message('No mapping found for the specified criteria.');
                    end;
                end;
            }
        }
        addafter("Item Discount Groups_Promoted")
        {
            actionref(Delete_ItemAttribute_Promoted; Delete_ItemAttribute)
            {                
            }
        }
    }
}