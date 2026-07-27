/// <summary>
/// TableExtension SBC Purchase Line (ID 50049) extends Record Purchase Line.
/// </summary>
tableextension 50049 "SBC Purchase Line" extends "Purchase Line"
{
    fields
    {
        field(50042; "SBC Plant Code"; Code[20])
        {
            Caption = 'SBC Plant Code';
            DataClassification = OrganizationIdentifiableInformation;
            Description = 'The code that identifies the supplier plant for the item.';
            TableRelation = "SBC Plant"."Plant Code" where(Enabled = const(true));
            trigger OnValidate()
            begin
                SetPlantItemNo();
            end;
        }
        field(50043; "SBC Plant Item No."; Code[20])
        {
            Caption = 'SBC Plant Item No.';
            DataClassification = CustomerContent;
            Description = 'The Plant-specific item number.';

        }        
    }

    local procedure GetSBCPurchaseLineItem(ItemNo: Code[20]; var Item: Record Item) Found: Boolean
    begin
        Item.SetRange("No.", ItemNo);
        Item.SetFilter("SBC Plant Item No.", '<>%1', '');
        Item.SetFilter("SBC Plant Code", '<>%1', '');
        if Item.IsEmpty() then
            exit;
        Item.SetLoadFields("SBC Plant Item No.", "SBC Plant Code");
        Found := Item.FindFirst();
    end;

    local procedure SetPlantItemNo()
    var
        Item: Record Item;
    begin
        if Rec."SBC Plant Item No." <> '' then
            exit;
        If Rec."SBC Plant Code" = '' then begin
            Rec."SBC Plant Item No." := '';
            exit;
        end;
        if GetSBCPurchaseLineItem(Rec."No.", Item) then
            Rec."SBC Plant Item No." := Item."SBC Plant Item No.";
    end;
}