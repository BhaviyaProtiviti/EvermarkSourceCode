/// <summary>
/// PageExtension SBCEDI Customer Card (ID 50084) extends Record Customer Card.
/// </summary>
pageextension 50084 "SBCEDI Customer Card" extends "Customer Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group(SBCEDI)
            {
                Caption = 'SBC EDI';
                field("SBC Ignore Price Discrepancy"; Rec."SBC Ignore Price Discrepancy")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is set, the EDI price discrepancy check will be ignored for this Customer.';
                    Visible = true;
                }
                field("SBC Auto-Created Customer"; Rec."SBC Auto-Created Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field is set when a Customer is auto created during the EDI850 insert process.';
                    Visible = true;
                }
                field("SBC Always Accept EDI Price"; Rec."SBC Always Accept EDI Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field is used primarily so that zero dollar prices will be accepted rather than ignored.';
                }
            }
        }
    }
}