/// <summary>
/// PageExtension SBC Item Card (ID 50040) extends Record Item Card.
/// </summary>
pageextension 50040 "SBC YWP Item Card" extends "Item Card"
{
    layout
    {
        addlast(content)
        {
            group(SBCAudit)
            {
                Caption = 'Audit';
                Description = 'Fields related to the creation and modification of this record.';
                Editable = true;

                field("SBC Created Date"; Rec."SBC Created Date")
                {
                    ApplicationArea = All;
                    Caption = 'SBC Created Date';
                    Editable = true;
                    ToolTip = 'The historical first created date of the item.';
                    Visible = true;
                }
                field("SBC Obsolete Date"; Rec."SBC Obsolete Date")
                {
                    ApplicationArea = All;
                    Caption = 'SBC Obsolete Date';
                    Editable = true;
                    ToolTip = 'The date the item was made obsolete.';
                    Visible = true;
                }
                group(BCAuditFields)
                {
                    Caption = 'BC Audit Fields';
                    Description = 'Built-In ERP Fields related to the creation and modification of this record.';
                    Editable = false;
                    Visible = true;

                    field(SystemId; Rec.SystemId)
                    {
                        ApplicationArea = All;
                        Caption = 'System Id';
                        ToolTip = 'Specifies the value of the SystemId field.';
                        Visible = true;
                    }
                    field(SystemCreatedAt; Rec.SystemCreatedAt)
                    {
                        ApplicationArea = All;
                        Caption = 'Created At';
                        ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                        Visible = true;
                    }
                    field(SystemCreatedBy; Rec.SystemCreatedBy)
                    {
                        ApplicationArea = All;
                        Caption = 'Created By';
                        ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                        Visible = true;
                    }
                    field(SystemModifiedAt; Rec.SystemModifiedAt)
                    {
                        ApplicationArea = All;
                        Caption = 'Modified At';
                        ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                        Visible = true;
                    }
                    field(SystemModifiedBy; Rec.SystemModifiedBy)
                    {
                        ApplicationArea = All;
                        Caption = 'Modified By';
                        ToolTip = 'Specifies the value of the SystemModifiedBy field.';
                        Visible = true;
                    }
                }
            }
        }

        addlast(InventoryGrp)
        {
            group(SBCUnits)
            {
                Caption = 'SBC Units';
                Description = 'Fields related to the SBC Units of Measure.';

                field("SBC Allow Override";Rec."SBC Allow Override")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates if the Tie Qty and High Qty values can be overridden.';
                }
                field("SBC Tie Qty";Rec."SBC Tie Qty")
                {
                    ApplicationArea = All;
                    Editable = Rec."SBC Allow Override";
                    ToolTip = 'The number of cases per layer.';
                }
                field("SBC High Qty";Rec."SBC High Qty")
                {
                    ApplicationArea = All;
                    Editable = Rec."SBC Allow Override";
                    ToolTip = 'The number of layers per pallet.';
                }
            }
        }
        addafter(InventoryNonFoundation)
        {
            field(CaseQtyOnHand; GlobalCaseQtyOnhand)
            {
                ApplicationArea = All;
                Caption = 'SBC Case Qty. on Hand';
                Editable = false;
                ToolTip = 'The number of cases on hand.';
                Visible = true;
                DecimalPlaces = 0;
            }
        }

        addafter(GTIN)
        {

            field("SBC Plant Code"; Rec."SBC Plant Code")
            {
                ApplicationArea = All;
                ToolTip = 'The code that identifies the supplier plant for the item.';
                Visible = true;
                Importance = Additional;
            }
            field("SBC Plant Item No."; Rec."SBC Plant Item No.")
            {
                ApplicationArea = All;
                ToolTip = 'The Plant-specific item number.';
                Visible = true;
                Importance = Additional;
            }
        }

        addlast("Prices & Sales")
        {

            field("SBC EDLP MSRP"; Rec."SBC EDLP MSRP")
            {
                ApplicationArea = All;
                ToolTip = 'EDLP MSRP';
                MinValue = 0;
                Importance = Promoted;
                AutoFormatType = 10;
                AutoFormatExpression = '1,USD';
            }
            field("SBC H-L MSRP"; Rec."SBC H-L MSRP")
            {
                ApplicationArea = All;
                ToolTip = 'H-L MSRP';
                Importance = Promoted;
                MinValue = 0;
                AutoFormatType = 10;
                AutoFormatExpression = '1,USD';
            }
        }
        addafter("Base Unit of Measure")
        {
            field("SBC Project Name"; Rec."SBC Project Name")
            {
                ApplicationArea = All;
                Caption = 'SBC Project Name';
                ToolTip = 'The name of the project associated with the item.';
                Importance = Additional;
            }
        }
    }
    var
        GlobalCaseQtyOnhand: Decimal;

    trigger OnAfterGetRecord()
    begin
        SetUnitGlobals();
    end;

    local procedure SetUnitGlobals()
    var
        CaseQuantityPerBaseUnit: Decimal;
        CaseQuantityRoundingPrecision: Decimal;
        DefaultRoundPrecision: Decimal;
    begin
        Rec.GetItemUnitsByCase(CaseQuantityPerBaseUnit, CaseQuantityRoundingPrecision, DefaultRoundPrecision);
        SetCaseInventoryQty(CaseQuantityPerBaseUnit, CaseQuantityRoundingPrecision);
    end;

    local procedure SetCaseInventoryQty(var CaseQuantityPerBaseUnit: Decimal; var CaseQuantityRoundingPrecision: Decimal)
    begin
        if CaseQuantityPerBaseUnit <= 1 then
            exit;
        Rec.CalcFields(Inventory);
        GlobalCaseQtyOnhand := Round(Rec.Inventory / CaseQuantityPerBaseUnit, CaseQuantityRoundingPrecision, '<');
    end;
}
