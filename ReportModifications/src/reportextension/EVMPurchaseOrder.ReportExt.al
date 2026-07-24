reportextension 50142 "EVM Purchase Order" extends "Standard Purchase - Order"
{
    dataset
    {
        add("Purchase Line")
        {
            column(EVM_Expected_Ship_Date; Format("EVM Expected Ship Date", 0, '<Month>/<Day>/<Year4>'))
            {
            }
            column(EVMExpectedShipDateCaption; ExpectedShipDateLbl)
            {
            }
            column(EVMExpectedReceiptDate; Format("Expected Receipt Date", 0, '<Month>/<Day>/<Year4>'))
            {
            }
        }
    }

    rendering
    {
        layout("EVM Layout with T&C")
        {
            Type = Word;
            Caption = 'EVM Layout with T&C';
            LayoutFile = './src/reportextension/layout/EVM Layout with T&C.docx';
        }
    }

    var
        ExpectedShipDateLbl: Label 'Expected Ship Date';
}