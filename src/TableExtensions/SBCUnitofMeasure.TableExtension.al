/// <summary>
/// TableExtension SBC Unit of Measure (ID 50050) extends Record Unit of Measure.
/// </summary>
tableextension 50050 "SBC Unit of Measure" extends "Unit of Measure"
{
    fields
    {
        field(50040; "SBC Case Unit"; Boolean)
        {
            Caption = 'SBC Case Unit';
            DataClassification = CustomerContent;
            Description = 'This is a case unit of measure.';
            trigger OnValidate()
            begin
                ToggleCaseUnit();
                ExistingCaseUnitCheck();
            end;
        }
        field(50041; "SBC Pallet Layer Unit"; Boolean)
        {
            Caption = 'SBC Pallet Layer Unit';
            DataClassification = CustomerContent;
            Description = 'This is a pallet layer unit of measure.';
            trigger OnValidate()
            begin
                TogglePalletLayerUnit();
                ExistingPalletLayerUnitCheck();
            end;
        }
        field(50042; "SBC Pallet Unit"; Boolean)
        {
            Caption = 'SBC Pallet Unit';
            DataClassification = CustomerContent;
            Description = 'This is a pallet layer unit of measure.';
            trigger OnValidate()
            begin
                TogglePalletUnit();
                ExistingPalletUnitCheck();
            end;
        }
    }


    var

    local procedure ToggleCaseUnit()
    begin
        if not Rec."SBC Case Unit" then
            exit;
        Rec."SBC Pallet Layer Unit" := false;
        Rec."SBC Pallet Unit" := false;
    end;

    local procedure TogglePalletLayerUnit()
    begin
        if not Rec."SBC Pallet Layer Unit" then
            exit;
        Rec."SBC Case Unit" := false;
        Rec."SBC Pallet Unit" := false;
    end;

    local procedure TogglePalletUnit()
    begin
        if not Rec."SBC Pallet Unit" then
            exit;
        Rec."SBC Case Unit" := false;
        Rec."SBC Pallet Layer Unit" := false;
    end;

    local procedure ExistingCaseUnitCheck()
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        UnitofMeasure.SetRange("SBC Case Unit", true);
        UnitofMeasure.SetFilter(Code, '<>%1&<>%2', Rec.Code, xRec.Code);
        if UnitOfMeasure.IsEmpty() then
            exit;
        UnitofMeasure.FindFirst();
        UnitofMeasure."SBC Case Unit" := false;
        UnitofMeasure.Modify();
    end;

    local procedure ExistingPalletLayerUnitCheck()
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        UnitofMeasure.SetRange("SBC Pallet Layer Unit", true);
        UnitofMeasure.SetFilter(Code, '<>%1&<>%2', Rec.Code, xRec.Code);
        if UnitOfMeasure.IsEmpty() then
            exit;
        UnitofMeasure.FindFirst();
        UnitofMeasure."SBC Pallet Layer Unit" := false;
        UnitofMeasure.Modify();
    end;

    local procedure ExistingPalletUnitCheck()
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        UnitofMeasure.SetRange("SBC Pallet Unit", true);
        UnitofMeasure.SetFilter(Code, '<>%1&<>%2', Rec.Code, xRec.Code);
        if UnitOfMeasure.IsEmpty() then
            exit;
        UnitofMeasure.FindFirst();
        UnitofMeasure."SBC Pallet Unit" := false;
        UnitofMeasure.Modify();
    end;
}