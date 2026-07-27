/// <summary>
/// TableExtension SBC (ID 50040).
/// </summary>
tableextension 50040 "SBC Item" extends Item
{
    fields
    {
        field(50040; "SBC Created Date"; Date)
        {
            Caption = 'SBC Created Date';
            DataClassification = CustomerContent;
            Description = 'The historical first created date of the item.';
        }
        field(50041; "SBC Obsolete Date"; Date)
        {
            Caption = 'SBC Obsolete Date';
            DataClassification = CustomerContent;
            Description = 'The date the item was made obsolete.';
        }
        field(50042; "SBC Plant Code"; Code[20])
        {
            Caption = 'SBC Plant Code';
            DataClassification = OrganizationIdentifiableInformation;
            Description = 'The code that identifies the supplier plant for the item.';
            TableRelation = "SBC Plant"."Plant Code" where(Enabled = const(true));
        }
        field(50043; "SBC Plant Item No."; Code[20])
        {
            Caption = 'SBC Plant Item No.';
            DataClassification = CustomerContent;
            Description = 'The Plant-specific item number.';

        }
        field(50044; "SBC EDLP MSRP"; Decimal)
        {
            Caption = 'SBC EDLP MSRP';
            DataClassification = CustomerContent;
            Description = 'EDLP MSRP';
        }
        field(50045; "SBC H-L MSRP"; Decimal)
        {
            Caption = 'SBC H-L MSRP';
            DataClassification = CustomerContent;
            Description = 'H-L MSRP';
        }
        field(50046; "SBC Allow Override"; Boolean)
        {
            Caption = 'SBC Allow Override';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not Rec."SBC Allow Override" then
                    SetItemTieHigh();

            end;
        }
        field(50047; "SBC Tie Qty"; Decimal)
        {
            Caption = 'SBC Tie Qty';
            DataClassification = CustomerContent;
            DecimalPlaces = 0;
        }
        field(50048; "SBC High Qty"; Decimal)
        {
            Caption = 'SBC High Qty';
            DataClassification = CustomerContent;
            DecimalPlaces = 0;
        }
        field(50049; "SBC Project Name"; Text[255])
        {
            Caption = 'SBC Project Name';
            DataClassification = CustomerContent;
            Description = 'The name of the project associated with the item.';
        }
    }

    local procedure GetIUOM(UnitOfMeasureCode: Code[10]) ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitofMeasure.SetRange("Item No.", Rec."No.");
        ItemUnitofMeasure.SetRange(Code, UnitOfMeasureCode);
        if ItemUnitofMeasure.IsEmpty() then
            exit;

        ItemUnitofMeasure.FindFirst();
    end;

    local procedure GetCaseSBCCaseUnit() UomCode: Code[10];
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        UnitofMeasure.SetRange("SBC Case Unit", true);
        UomCode := GetUomCode(UnitofMeasure);
    end;

    local procedure GetCaseSBCPalletLayerUnit() UomCode: Code[10];
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        UnitofMeasure.SetRange("SBC Pallet Layer Unit", true);
        UomCode := GetUomCode(UnitofMeasure);
    end;

    local procedure GetCaseSBCPalletUnit() UomCode: Code[10];
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        UnitofMeasure.SetRange("SBC Pallet Unit", true);
        UomCode := GetUomCode(UnitofMeasure);
    end;

    local procedure GetUomCode(var UnitofMeasure: Record "Unit of Measure") UomCode: Code[10];
    begin
        if UnitofMeasure.IsEmpty() then
            exit;
        UnitofMeasure.SetLoadFields("Code");
        UnitofMeasure.FindFirst();
        UomCode := UnitofMeasure.Code;
    end;

    internal procedure GetItemUnitsByCase(var CaseQuantityPerBaseUnit: Decimal; var CaseQuantityRoundingPrecision: Decimal)
    var
        DefaultRoundPrecision: Decimal;
    begin
        GetItemUnitsByCase(CaseQuantityPerBaseUnit, CaseQuantityRoundingPrecision, DefaultRoundPrecision);
    end;

    procedure SetItemUnits()
    begin
        if Rec."SBC Allow Override" then
            exit;

        SetItemTieHigh();
        Rec.Modify();
    end;

    local procedure SetItemTieHigh()
    var
        CaseQuantityPerBaseUnit, LayerQuantityPerBaseUnit, PalletQuantityPerBaseUnit : Decimal;
    begin
        GetItemUnitsByCase(CaseQuantityPerBaseUnit);
        LayerQuantityPerBaseUnit := GetIUOM(GetCaseSBCPalletLayerUnit())."Qty. per Unit of Measure";
        PalletQuantityPerBaseUnit := GetIUOM(GetCaseSBCPalletUnit())."Qty. per Unit of Measure";

        Rec."SBC Tie Qty" := (LayerQuantityPerBaseUnit / CaseQuantityPerBaseUnit);
        Rec."SBC High Qty" := (PalletQuantityPerBaseUnit / LayerQuantityPerBaseUnit);

        TestTieHighWholeNumber();
    end;

    local procedure TestTieHighWholeNumber()
    var
        TieError, HighError : Boolean;
        TieHigh_Round: Decimal;
        TieHighErrLbl: label '%1 qty did not calculate into a whole number, please update Item Unit of Measure', comment = '%1 = field caption';
        TieHighTxt: TextBuilder;
    begin
        TieHigh_Round := Round(Rec."SBC Tie Qty", 1, '=');
        TieError := (TieHigh_Round <> Rec."SBC Tie Qty");

        TieHigh_Round := Round(Rec."SBC High Qty", 1, '=');
        HighError := (TieHigh_Round <> Rec."SBC High Qty");

        if (not TieError) and (not HighError) then
            exit;
        if TieError then
            tieHighTxt.Append('SBC Tie Qty');
        if HighError then begin
            if TieHighTxt.Length > 0 then
                TieHighTxt.Append(' and ');
            TieHighTxt.Append('SBC High Qty');
        end;
        Error(StrSubstNo(TieHighErrLbl, TieHighTxt.ToText()));
    end;

    internal procedure GetItemUnitsByCase(var CaseQuantityPerBaseUnit: Decimal)
    var
        // UnitofMeasureManagement: Codeunit "Unit of Measure Management";
    begin
        CaseQuantityPerBaseUnit := GetIUOM(GetCaseSBCCaseUnit())."Qty. per Unit of Measure";
        if CaseQuantityPerBaseUnit = 0 then
            CaseQuantityPerBaseUnit := 1;
    end;

    internal procedure GetItemUnitsByCase(var CaseQuantityPerBaseUnit: Decimal; var CaseQuantityRoundingPrecision: Decimal; var DefaultRoundPrecision: Decimal)
    var
        UnitofMeasureManagement: Codeunit "Unit of Measure Management";
    begin
        DefaultRoundPrecision := UnitofMeasureManagement.QtyRndPrecision();
        CaseQuantityPerBaseUnit := GetIUOM(GetCaseSBCCaseUnit())."Qty. per Unit of Measure";
        if CaseQuantityPerBaseUnit = 0 then
            CaseQuantityPerBaseUnit := 1;
        CaseQuantityRoundingPrecision := GetIUOM(GetCaseSBCCaseUnit())."Qty. Rounding Precision";
        if CaseQuantityRoundingPrecision = 0 then
            CaseQuantityRoundingPrecision := DefaultRoundPrecision;
    end;

    // local procedure SetItemTieHigh()
    // var
    //     CaseQuantityPerBaseUnit, DefaultRoundPrecision, LayerQuantityPerBaseUnit, PalletQuantityPerBaseUnit, CaseQuantityRoundingPrecision, LayerQuantityRoundingPrecision : Decimal;
    // begin
    //     GetItemUnitsByCase(CaseQuantityPerBaseUnit, CaseQuantityRoundingPrecision, DefaultRoundPrecision);
    //     LayerQuantityPerBaseUnit := GetIUOM(GetCaseSBCPalletLayerUnit())."Qty. per Unit of Measure";
    //     LayerQuantityRoundingPrecision := GetIUOM(GetCaseSBCPalletLayerUnit())."Qty. Rounding Precision";
    //     if LayerQuantityRoundingPrecision = 0 then
    //         LayerQuantityRoundingPrecision := DefaultRoundPrecision;
    //     PalletQuantityPerBaseUnit := GetIUOM(GetCaseSBCPalletUnit())."Qty. per Unit of Measure";

    //     Rec."SBC Tie Qty" := Round(LayerQuantityPerBaseUnit / CaseQuantityPerBaseUnit, CaseQuantityRoundingPrecision, '<');
    //     Rec."SBC High Qty" := Round(PalletQuantityPerBaseUnit / LayerQuantityPerBaseUnit, LayerQuantityRoundingPrecision, '>');
    // end;    

    trigger OnAfterInsert()
    begin
        SetSBCCreatedDate();
    end;

    local procedure SetSBCCreatedDate()
    begin
        if Rec."SBC Created Date" <> 0D then
            exit;
        Rec."SBC Created Date" := Today();
        Rec.Modify();
    end;
}
