/// <summary>
/// TableExtension STA Bracket Price LAX (ID 50203) extends Record STA Bracket Price.
/// </summary>
tableextension 50203 "STA Bracket Price LAX" extends "STA Bracket Price"
{
    fields{
        modify("Item No.")
        {
            trigger OnAfterValidate()
          var
                Item: Record Item;
                ItemUnitofMeasure: Record "Item Unit of Measure";
            begin
                Item.SetFilter("No.", '%1', Rec."Item No.");
                if Item.IsEmpty() then
                    exit;
                Item.SetLoadFields("Unit Price", GTIN,"Sales Unit of Measure","Base Unit of Measure");
                Item.FindFirst();
                Rec."Item Unit Price" := Item."Unit Price";
                Rec.UCC14  := Item.GTIN;
                SetCaseValuesFromUOM(Item);
                SetItemValuesFromUOM(Item);
            end;
        }
    }

    local procedure SetCaseValuesFromUOM(Item: Record Item)
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitofMeasure.SetFilter("Item No.", Rec."Item No.");
        ItemUnitofMeasure.SetFilter(Code, Item."Sales Unit of Measure");
        if ItemUnitofMeasure.IsEmpty() then
            exit;
        ItemUnitofMeasure.SetLoadFields("Qty. per Unit of Measure", "LAX Std. Pack UPC/EAN Number");
        ItemUnitofMeasure.FindFirst();
        Rec."Units per Case" := ItemUnitofMeasure."Qty. per Unit of Measure";
        Rec."Case UPC" := ItemUnitofMeasure."LAX Std. Pack UPC/EAN Number";
    end;
    local procedure SetItemValuesFromUOM(Item: Record Item)
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitofMeasure.SetFilter("Item No.", Rec."Item No.");
        ItemUnitofMeasure.SetFilter(Code, Item."Base Unit of Measure");
        if ItemUnitofMeasure.IsEmpty() then
            exit;
        ItemUnitofMeasure.SetLoadFields("LAX Std. Pack UPC/EAN Number");
        ItemUnitofMeasure.FindFirst();
        Rec."Item UPC" := ItemUnitofMeasure."LAX Std. Pack UPC/EAN Number";
    end;
}