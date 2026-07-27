tableextension 50002 "SBC Purchase Line 2" extends "Purchase Line"
{
    fields
    {
        field(50002; "SBC Vendor Group Code"; Code[20])
        {
            Caption = 'SBC Vendor Group Code';
            DataClassification = CustomerContent;
        }
        field(50003; "SBC Buy-From Vendor Name"; Text[100])
        {
            Caption = 'Buy-from Vendor Name';
            CalcFormula = lookup(Vendor.Name where("No." = field("Buy-from Vendor No.")));
            FieldClass = FlowField;
        }
        // #162 Adjust Needed on the purchase lines report Start Jyoon
        field(50004; "SBC Production Plant 1"; Text[250])
        {
            Caption = 'Production Plant 1';
            DataClassification = CustomerContent;
        }
        // #162 Adjust Needed on the purchase lines report End Jyoon
        field(50005; "SBC LAX EDI PO Generated"; Boolean)
        {
            Caption = 'LAX EDI PO Generated';
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."LAX EDI PO Generated" where("No." = field("Document No.")));
        }
        field(50006; "SBC EDI PO Gen. Date"; Date)
        {
            Caption = 'LAX EDI PO Gen. Date';
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."LAX EDI PO Gen. Date" where("No." = field("Document No.")));
        }
        field(50007; "SBC LAX EDI PO Change Gen"; Boolean)
        {
            Caption = 'LAX EDI PO Change Generated';
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."LAX EDI PO Change Generated" where("No." = field("Document No.")));
        }
        field(50008; "SBC EDI PO Change Gen. Date"; DateTime)
        {
            Caption = 'LAX EDI PO Change Gen. Date';
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."LAX EDI PO Change Gen. Date" where("No." = field("Document No.")));
        }
        field(50009; "EVM Expected Ship Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Ship Date';
        }
    }


    trigger OnInsert()
    var
        ItemAttributeValueSelection: Record "Item Attribute Value Selection";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMappping: Record "Item Attribute Value Mapping";
    begin
        // #162 Adjust Needed on the purchase lines report Start Jyoon
        if Rec.Type = Rec.Type::Item then begin
            ItemAttributeValueMappping.SetFilter("Table ID", '%1', 27);
            ItemAttributeValueMappping.Setfilter("No.", '%1', Rec."No.");
            ItemAttributeValueMappping.SetFilter("Item Attribute ID", '%1', 25);
            if ItemAttributeValueMappping.FindFirst() then begin
                ItemAttributeValue.SetFilter("Attribute ID", '%1', 25);
                ItemAttributeValue.SetFilter("ID", '%1', ItemAttributeValueMappping."Item Attribute Value ID");
                if ItemAttributeValue.FindFirst() then begin
                    Rec."SBC Production Plant 1" := ItemAttributeValue.Value;
                end;
            end
        end;
        // #162 Adjust Needed on the purchase lines report End Jyoon
    end;
}
