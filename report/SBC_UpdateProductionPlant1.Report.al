/// <summary>
/// Report SBC Update Production Plant 1 (ID 50107)
/// Updates "SBC Production Plant 1" field on Purchase Order lines to match current Item Attribute Values (ID 25).
/// Processes only Purchase Order lines with Type = Item.
/// </summary>
/// <changelog>
/// 2025-10-28 v1.0.0 - Initial creation
/// </changelog>

report 50003 "SBC Update Production Plant 1"
{
    Caption = 'SBC Update Production Plant 1';
    ProcessingOnly = true;
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;
    UseRequestPage = false;

    dataset
    {
        dataitem("Purchase Line"; "Purchase Line")
        {
            DataItemTableView = where(Type = const(Item), "Document Type" = const(Order));
            RequestFilterFields = "Document No.", "No.", "Buy-from Vendor No.";
            trigger OnAfterGetRecord()
            var
                ItemAttributeValue: Record "Item Attribute Value";
                ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
                CurrentProductionPlant: Text[250];
                NewProductionPlant: Text[250];
            begin
                // Get current Production Plant 1 value
                CurrentProductionPlant := "SBC Production Plant 1";
                NewProductionPlant := '';

                // Look up the current Item Attribute Value for Production Plant 1 (Attribute ID 25)
                ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
                ItemAttributeValueMapping.SetRange("No.", "No.");
                ItemAttributeValueMapping.SetRange("Item Attribute ID", 25);
                if ItemAttributeValueMapping.FindFirst() then begin
                    ItemAttributeValue.SetRange("Attribute ID", 25);
                    ItemAttributeValue.SetRange("ID", ItemAttributeValueMapping."Item Attribute Value ID");
                    if ItemAttributeValue.FindFirst() then begin
                        NewProductionPlant := ItemAttributeValue.Value;
                    end;
                end;

                // Compare and update if different
                if (CurrentProductionPlant <> NewProductionPlant) and (NewProductionPlant <> '') then begin
                    "SBC Production Plant 1" := NewProductionPlant;
                    Modify();
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Information)
                {
                    Caption = 'Information';

                    label(InfoLabel)
                    {
                        ApplicationArea = All;
                        Caption = 'This report will check all purchase order lines with items and update the "SBC Production Plant 1" field if the current Item Attribute Value (Attribute ID 25) is different from what is stored on the purchase line.';
                        MultiLine = true;
                    }
                }
            }
        }
    }
}
