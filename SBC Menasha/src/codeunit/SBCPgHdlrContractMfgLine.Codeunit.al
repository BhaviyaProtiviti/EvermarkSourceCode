/// <summary>
/// Codeunit SBC PgHdlr Contract Mfg Line (ID 50357).
/// </summary>
codeunit 50357 "SBC PgHdlr Contract Mfg Line"
{
    /// <summary>
    /// SetVisibleByContractType.
    /// </summary>
    /// <param name="POVis">VAR Boolean.</param>
    /// <param name="DescVis">VAR Boolean.</param>
    /// <param name="PDVis">VAR Boolean.</param>
    /// <param name="SLEDVis">VAR Boolean.</param>
    /// <param name="LocVis">VAR Boolean.</param>
    /// <param name="UOMVis">VAR Boolean.</param>
    /// <param name="MatVis">VAR Boolean.</param>
    /// <param name="MatGrpVis">VAR Boolean.</param>
    /// <param name="HdlVis">VAR Boolean.</param>
    /// <param name="ContractType">Enum "SBC Contract Type".</param>
    procedure SetVisibleByContractType(var RPOVis: Boolean; var POVis: Boolean; var DescVis: Boolean; var PDVis: Boolean; var SLEDVis: Boolean; var LocVis: Boolean; var UOMVis: Boolean; var MatVis: Boolean; var MatGrpVis: Boolean; var HdlVis: Boolean; ContractType: Enum "SBC Contract Type")
    begin
        case ContractType of
            ContractType::"SBC Inventory":
                begin
                    RPOVis := false;
                    POVis := false;
                    PDVis := false;
                    SLEDVis := false;
                    LocVis := false;
                    UOMVis := false;
                    MatVis := false;
                end;
            ContractType::"SBC Consumption":
                begin
                    DescVis := false;
                    SLEDVis := false;
                    MatVis := false;
                    MatGrpVis := false;
                    HdlVis := false;
                end;
            ContractType::"SBC Finished Goods":
                begin
                    LocVis := false;
                    UOMVis := false;
                    MatGrpVis := false;
                    HdlVis := false;
                end;
        end;
    end;
}
