pageextension 50162 "SBC CDC Purchase Order" extends "Purchase Order"
{
    actions
    {
        addfirst("F&unctions")
        {
            action(SBC_CDCGetAmtDistrib)
            {
                Caption = 'Get Std. Amount Di&stribution Codes';
                ToolTip = 'Insert purchase lines by applying a standard amount distribution code to the purchase invoice.';
                Ellipsis = true;
                Image = ApplyTemplate;
                ApplicationArea = Basic, Suite;
                AccessByPermission = tabledata "CDC Document Capture Setup" = R;
                Visible = CDCHasAccess;

                trigger OnAction();
                var
                    PurchLine: Record "Purchase Line";
                begin
                    CurrPage.PurchLines.Page.GetRecord(PurchLine);
                    CDCPurchDocMgt.GetAmountDistribution2(Rec, PurchLine);
                end;
            }
        }
    }

    var
        CDCPurchDocMgt: Codeunit "CDC Purch. Doc. - Management";
        CDCHasAccess: Boolean;

    trigger OnOpenPage();
    begin
        CDCCheckIfHasAccess();
    end;

    local procedure CDCCheckIfHasAccess()
    var
        CDCLicenseMgt: Codeunit "CDC Continia License Mgt.";
    begin
        CDCHasAccess := CDCLicenseMgt.HasAccessToDC();
    end;
}
