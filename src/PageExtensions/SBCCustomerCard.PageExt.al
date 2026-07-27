/// <summary>
/// PageExtension SBC Customer Card (ID 50042) extends Record Customer Card.
/// </summary>
pageextension 50042 "SBC Customer Card" extends "Customer Card"
{
    layout
    {
        addafter("No.")
        {
            field("SBC Emerson Customer No."; Rec."SBC Emerson Customer No.")
            {
                ApplicationArea = All;
                Caption = 'SBC Emerson Customer No.';
                ToolTip = 'The Emerson Customer No. for the customer.';
                Visible = true;
            }
        }
        addafter("Bill-to Customer No.")
        {
            field("SBC Use Bill-To Pricing"; Rec."SBC Use Bill-To Pricing")
            {
                ApplicationArea = All;
                Caption = 'SBC Use Bill-To Pricing';
                ToolTip = 'Use Bill-To Pricing for the Customer.';
                Visible = true;
            }
        }
        addafter("Gen. Bus. Posting Group")
        {
         
            field("SBC Use Sell-To Posting"; Rec."SBC Use Sell-To Posting")
            {
                ApplicationArea = All;
                ToolTip = 'When this is set, When this Customer is the Sell-To on a Sales Document, the Gen. Business Posting Group of this customer will be used instead of the Gen. Business Posting Group of the Bill-To Customer.';
                Visible = false;

            }
        }
        addafter("Customer Posting Group")
        {

            field("SBC Channel Detail"; Rec."SBC Channel Detail")
            {
                ApplicationArea = All;
                ToolTip = 'The Channel Detail for the Customer.';
            }
        }
        addafter("Salesperson Code")
        {

            field("SBC Account Lead"; Rec."SBC Account Lead")
            {
                ApplicationArea = All;
                ToolTip = 'The Account Lead for the Customer. Works under the Salesperson.';
                Importance = Additional;
            }
        }
    }
}
