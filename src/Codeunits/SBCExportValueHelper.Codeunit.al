/// <summary>
/// Codeunit SBC Export Value Helper (ID 50043).
/// </summary>
codeunit 50043 "SBC Export Value Helper"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    internal procedure IsBound(): Boolean
    begin
        exit(GlobalBound);
    end;

    internal procedure Unbind()
    begin
        Unbind(false);
    end;

    internal procedure Unbind(Force: Boolean)
    begin
        if not Force then
            if not IsBound() then
                exit;

        if not UnbindSubscription(GlobalSBCExportValueHelper) then
            if not Force then
                exit;

        ClearGlobals();
    end;

    internal procedure SetGlobalPlantCode(PlantCode: Code[20])
    begin
        GlobalPlantCode := PlantCode;
    end;

    local procedure ClearGlobals()
    begin
        Clear(GlobalBound);
        Clear(GlobalPlantCode);


    end;

    local procedure SetPlantValue(var TextValue: Text)
    var
        PlantRegex: Codeunit Regex;
    begin
        PlantRegex.Regex(PlantNoRegexLabel);
        TextValue := PlantRegex.Replace(TextValue, GlobalPlantCode);
    end;

    internal procedure Bind()
    begin
        if IsBound() then
            exit;
        GlobalBound := BindSubscription(GlobalSBCExportValueHelper);
    end;


    internal procedure GetPlantItemNo(PlantNo: Code[20]; ItemNo: Code[20]) ReferenceNo: Code[20]
    var
        Item: Record Item;
    begin
        Item.SetRange("No.", ItemNo);
        Item.SetRange("SBC Plant Code", PlantNo);
        if Item.IsEmpty() then
            exit;
        Item.SetLoadFields("SBC Plant Item No.");
        Item.FindFirst();
        ReferenceNo := Item."SBC Plant Item No.";
    end;

    internal procedure GetPlantFromItem(ItemNo: Code[20]) ReferenceNo: Code[20]
    var
        Item: Record Item;
    begin
        Item.SetRange("No.", ItemNo);
        Item.SetFilter("SBC Plant Code", '<>%1', '');
        if Item.IsEmpty() then
            exit;
        Item.SetLoadFields("SBC Plant Code");
        Item.FindFirst();
        ReferenceNo := Item."SBC Plant Code";
    end;

    internal procedure GetGTIN14(ItemNo: Code[20]) ReferenceNo: Code[14]
    var
        Item: Record Item;
    begin
        Item.SetRange("No.", ItemNo);
        Item.SetFilter(GTIN, '<>%1', '');
        if Item.IsEmpty() then
            exit;
        Item.SetLoadFields(GTIN);
        Item.FindFirst();
        ReferenceNo := Item.GTIN;
    end;


    // local procedure GetPlantReference(PlantNo: Code[20]; ItemNo: Code[20]; ReferenceType: enum "Item Reference Type"; ReferenceNoFilter: Text) ReferenceNo: Code[50]
    // var
    //     ItemReference: Record "Item Refereence";
    // begin
    //     ItemReference.SetRange("No.", ItemNo);
    //     ItemReference.SetRange("SBC Plant Code", PlantNo);


    //     if ReferenceNoFilter <> '' then
    //         ItemReference.SetFilter("Reference No.", '%1', ReferenceNoFilter);
    //     if ItemReference.IsEmpty() then
    //         exit;
    //     ItemReference.SetLoadFields("Reference No.");
    //     ItemReference.FindFirst();
    //     ReferenceNo := ItemReference."Reference No.";
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SBCOE Export Management", OnAfterSetFieldValue, '', false, false)]
    local procedure OnAfterSetFieldValue(SBCOEExportColumn: Record "SBCOE Export Column"; var FieldValueVariant: Variant; var CurrentRow: Integer; var CurrentColumn: Integer)
    begin
        if GlobalPlantCode = '' then
            exit;

        case SBCOEExportColumn."Default Text" of
            'PartNo':
                FieldValueVariant := GetPlantItemNo(GlobalPlantCode, format(FieldValueVariant));
            'GTIN14':
                FieldValueVariant := GetGTIN14(format(FieldValueVariant));
            'PlantNo':
                FieldValueVariant := GlobalPlantCode;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"SBCOE Export Definition", OnAfterSetExportEmailSubject, '', false, false)]
    local procedure OnAfterSetExportEmailSubject(var ExportEmailSubject: Text)
    begin
        SetPlantValue(ExportEmailSubject);
    end;

    [EventSubscriber(ObjectType::Table, Database::"SBCOE Export Definition", OnAfterSetExportFileName, '', false, false)]
    local procedure OnAfterSetExportFileName(var ExportFileName: Text)
    begin
         SetPlantValue(ExportFileName);
    end;

    var
        GlobalBound: Boolean;
        GlobalPlantCode: Code[20];
        GlobalSBCExportValueHelper: Codeunit "SBC Export Value Helper";
        PlantNoRegexLabel: Label '(?i)%PlantNo', Comment = 'Add more tokens here to extend replacement values.', Locked = true;
}