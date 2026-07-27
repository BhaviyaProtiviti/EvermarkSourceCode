/// <summary>
/// PageExtension SBCEDI Sales Lines (ID 50083) extends Record Sales Lines.
/// </summary>
pageextension 50083 "SBCEDI Sales Lines" extends "Sales Lines"
{

    Editable = true;
    layout
    {
        addafter("Line Amount")
        {


            field("Unit Price"; Rec."Unit Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the price for one unit on the sales line.';
                Editable = true;
                Visible = true;
            }
            field("LAX EDI Unit Price"; Rec."LAX EDI Unit Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the mapped EDI unit price referenced in the EDI file.';
                Editable = true;
                Visible = true;
            }
            field("LAX EDI Price Discrepancy"; Rec."LAX EDI Price Discrepancy")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if there a difference between the Unit Price and the mapped EDI Unit Price.';
                Editable = true;
                Visible = true;
            }
            field("Line Discount %"; Rec."Line Discount %")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the discount percentage that is granted to the amount on the line.';
                Editable = true;
                Visible = false;
            }
            field("Line Discount Amount"; Rec."Line Discount Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the amount of the discount that will be given on the invoice line.';
                Editable = true;
                Visible = false;
            }

        }
    }
}