page 50037 "SBC SQI Item Attribute API"
{
    APIGroup = 'SIQ';
    APIPublisher = 'StockIQ';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'siqItemAttributeAPI';
    DelayedInsert = true;
    EntityName = 'siqitemattribute';
    EntitySetName = 'siqitemattributes';
    PageType = API;
    SourceTable = "SBC Temp Item Attribute Value";
    // ApplicationArea = All;
    // Caption = 'SBC SQI Item Attribute API';
    // PageType = List;
    // SourceTable = "SBC Temp Item Attribute Value";
    // UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(itemNo; Rec."SBC Item No.")
                {
                    ToolTip = 'Specifies the value of the SBC Item No. field.';
                }
                field(itemAtributteName; Rec."SBC Item Attribute Name")
                {
                    ToolTip = 'Specifies the value of the SBC Item Attribute Name field.';
                }
                field(itemAttribueValue; Rec."SBC Item Attribute Value")
                {
                    ToolTip = 'Specifies the value of the SBC Item Attribute Value field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        PopulateRec();
    end;

    local procedure PopulateRec()
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        ItemAttributeValue: Record "Item Attribute Value";
    begin
        ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
        if ItemAttributeValueMapping.FindSet() then
            repeat
                ItemAttributeValue.Reset();
                ItemAttributeValue.SetRange("Attribute ID", ItemAttributeValueMapping."Item Attribute ID");
                ItemAttributeValue.SetRange("ID", ItemAttributeValueMapping."Item Attribute Value ID");
                if ItemAttributeValue.FindFirst() then begin
                    Rec.Init();
                    Rec."SBC Item No." := ItemAttributeValueMapping."No.";
                    Rec."SBC Item Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                    Rec."SBC Item Attribute Value ID" := ItemAttributeValueMapping."Item Attribute Value ID";
                    ItemAttributeValue.CalcFields("Attribute Name");
                    Rec."SBC Item Attribute Name" := ItemAttributeValue."Attribute Name";
                    Rec."SBC Item Attribute Value" := ItemAttributeValue."Value";
                    Rec.Insert();
                end;
            until ItemAttributeValueMapping.Next() = 0;
    end;
}
