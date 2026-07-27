/// <summary>
/// Page SBC Posted Contract Subform (ID 50356).
/// </summary>
page 50356 "SBC Posted Contract Subform"
{
    ApplicationArea = All;
    Caption = 'Posted Contract Subform';
    PageType = ListPart;
    SourceTable = "SBC Posted Contract Mfg Line";
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("SBC Production Order No."; Rec."SBC Production Order No.")
                {
                    ToolTip = 'Specifies the value of the Released Prod. Order No. field.';
                }
                field("SBC Purchase Order No."; Rec."SBC Purchase Order No.")
                {
                    ToolTip = 'Specifies the value of the Purchase Order No. field.';
                    Visible = POVis;
                }
                field("SBC Item No."; Rec."SBC Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("SBC Description"; Rec."SBC Description")
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    Visible = DescVis;
                }
                field("SBC Posting Date"; Rec."SBC Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.';
                    Visible = PDVis;
                }
                field("SBC SLED/BBD"; Rec."SBC SLED/BBD")
                {
                    ToolTip = 'Specifies the value of the SLED/BBD field.';
                    Visible = SLEDVis;
                }
                field("SBC Location Code"; Rec."SBC Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field.';
                    Visible = LocVis;
                }
                field("SBC Quantity"; Rec."SBC Quantity")
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("SBC UOM Code"; Rec."SBC UOM Code")
                {
                    ToolTip = 'Specifies the value of the UOM Code field.';
                    Visible = UOMVis;
                }
                field("SBC Lot No."; Rec."SBC Lot No.")
                {
                    ToolTip = 'Specifies the value of the Lot No. field.';
                }
                field("SBC Material Type"; Rec."SBC Material Type")
                {
                    ToolTip = 'Specifies the value of the Material Type field.';
                    Visible = MatVis;
                }
                field("SBC Matl. Group Desc."; Rec."SBC Matl. Group Desc.")
                {
                    ToolTip = 'Specifies the value of the Matl. Group Desc. field.';
                    Visible = MatGrpVis;
                }
                field("SBC Count of Handling Unit"; Rec."SBC Count of Handling Unit")
                {
                    ToolTip = 'Specifies the value of the Count of Handling Unit field.';
                    Visible = HdlVis;
                }
            }
        }
    }

    var
        Handler: Codeunit "SBC PgHdlr Contract Mfg Line";
        RPOVis: Boolean;
        POVis: Boolean;
        DescVis: Boolean;
        PDVis: Boolean;
        SLEDVis: Boolean;
        LocVis: Boolean;
        UOMVis: Boolean;
        MatVis: Boolean;
        MatGrpVis: Boolean;
        HdlVis: Boolean;

    trigger OnOpenPage()
    begin
        SetAllFieldsVisible();
    end;

    trigger OnAfterGetRecord()
    begin
        SetAllFieldsVisible();
        Handler.SetVisibleByContractType(RPOVis, POVis, DescVis, PDVis, SLEDVis, LocVis, UOMVis, MatVis, MatGrpVis, HdlVis, Rec."SBC Contract Type");
    end;


    local procedure SetAllFieldsVisible()
    begin
        RPOVis := true;
        POVis := true;
        DescVis := true;
        PDVis := true;
        SLEDVis := true;
        LocVis := true;
        UOMVis := true;
        MatVis := true;
        MatGrpVis := true;
        HdlVis := true;
    end;
}
