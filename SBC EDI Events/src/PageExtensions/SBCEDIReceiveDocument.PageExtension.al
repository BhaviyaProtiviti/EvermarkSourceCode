/// <summary>
/// PageExtension SBCEDI Receive Document (ID 50088) extends Record LAX EDI Receive Document.
/// </summary>
pageextension 50088 "SBCEDI Receive Document" extends "LAX EDI Receive Document"
{
    actions
    {
        addlast(processing)
        {
            action(SBCAllowSOUpdate)
            {
                Caption = 'SBC Allow SO Update';
                Visible = false;
                Enabled = GLobal850ActionsEnabled;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    // SBCAllowPOChange();
                    if not GlobalSBCEDI850Helper.SBCSetSOUpdateDocType(Rec) then
                        exit;
                    CurrPage.Update();
                end;
            }
            action(SBCDisableSOUpdate)
            {
                Caption = 'SBC Disable PO Change';
                Visible = false;
                Enabled = GLobal850ActionsEnabled;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    if Rec."EDI Document No." <> '851' then
                        exit;
                    Rec."EDI Document No." := '850';
                    Rec."Enable PO Change" := false;
                    Rec."PO Change Purpose Code" := '';
                    Rec."PO Change Updated" := false;
                end;
            }
            action(SBCResetPOUpdate)
            {
                ApplicationArea = All;
                Visible = true;
                Enabled = GLobal856ActionsEnabled;
                Caption = 'SBC Reset PO Update Status';
                // Promoted = true;
                // PromotedIsBig = true;
                trigger OnAction()
                begin
                    if not Rec."Purchase Order Updated" then
                        exit;
                    Rec."Purchase Order Updated" := false;
                    Rec.Modify();
                end;
            }
            action(SBCResetSOUpdate)
            {
                ApplicationArea = All;
                Visible = true;
                Enabled = Global810SOUpdateActionsEnabled or Global945SOUpdateActionsEnabled;
                Caption = 'SBC Reset SO Update Status';
                // Promoted = true;
                // PromotedIsBig = true;
                trigger OnAction()
                begin
                    if not Rec."Sales Order Updated" then
                        exit;
                    Rec."Sales Order Updated" := false;
                    Rec.Modify();
                end;
            }
        }
        addlast(Category_Process)
        {
            group(SBCActions)
            {
                Caption = 'SBC Actions';
                Visible = true;
                actionref(SBCAllowPOChang_Promoted; SBCAllowSOUpdate)
                {
                }
                actionref(SBCDisablePOChange_Promoted; SBCDisableSOUpdate)
                {
                }
                actionref(SBCResetPOUpdate_Promoted; SBCResetPOUpdate)
                {
                }
                actionref(SBCResetSOUpdate_Promoted; SBCResetSOUpdate)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // GLobal850ActionsEnabled := Rec."Document" = ImportSalesOrderLabel;
        // GlobalSOUpdateActionsEnabled := Rec."Document" = UpdateSalesOrderLabel;
        // GLobal856ActionsEnabled := Rec."Document" = UpdatePurchaseOrderLabel;
        case true of
            Rec."Document" = ImportSalesOrder850Label:
                GLobal850ActionsEnabled := true;
            Rec."Document" = UpdateSalesOrder810Label:
                Global810SOUpdateActionsEnabled := true;
            Rec."Document" = UpdatePurchaseOrder856Label:
                GLobal856ActionsEnabled := true;
            Rec."Document" = UpdateSalesOrder945Label:
                Global945SOUpdateActionsEnabled := true;
        end;

    end;

    var
        ImportSalesOrder850Label: Label 'I_SLSORD', Locked = true;
        UpdateSalesOrder810Label: Label 'U_SLSORD', Locked = true;
        UpdatePurchaseOrder856Label: Label 'U_PURWSA', Locked = true;
        UpdateSalesOrder945Label: Label 'U_SLSWSA', Locked = true;
        GLobal850ActionsEnabled: Boolean;
        GLobal856ActionsEnabled: Boolean;
        Global810SOUpdateActionsEnabled: Boolean;
        Global945SOUpdateActionsEnabled: Boolean;
        GlobalSBCEDI850Helper: Codeunit "SBCEDI 850 Helper";


}