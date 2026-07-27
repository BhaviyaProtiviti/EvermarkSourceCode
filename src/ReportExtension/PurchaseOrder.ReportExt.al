/// <summary>
/// Unknown EMG Sales Quote (ID 50803) extends Record Sales Quote NA.
/// </summary>
reportextension 50040 "SUAVE Purchase Order" extends "Purchase Order"
{
    dataset
    {
        add(PageLoop)
        {
            column(ExptRecptDtCaption_PurchaseHeader; "Purchase Header".FieldCaption("Expected Receipt Date"))
            {
            }
            column(PaymentTermsCode_PurchaseHeader; "Purchase Header"."Payment Terms Code")
            {
            }
            column(Picture_CompanyInfo; CompanyInfo.Picture)
            {
            }
        }
        add("Purchase Line")
        {
            column(ExpectedReceiptDate_PurchaseLine; "Expected Receipt Date")
            {
            }
            column(ExptRecptDtCaption_PurchaseLine; "Purchase Line".FieldCaption("Expected Receipt Date"))
            {
            }
            column(ExpectedShipDate; "EVM Expected Ship Date")
            {
            }
            column(ExptShipDtCaption_PurchaseLine; "Purchase Line".FieldCaption("EVM Expected Ship Date"))
            {
            }
        }
    }

    rendering
    {
        layout(SuavePO)
        {
            Caption = 'SUAVE Purchase Order';
            LayoutFile = './src/ReportExtension/layout/PurchaseOrder.rdl';
            Type = RDLC;
        }
    }

    var
        CompanyInfo: Record "Company Information";

    trigger OnPreReport()
    begin
        CompanyInfo.get;
        CompanyInfo.CalcFields(Picture);
    end;
}
