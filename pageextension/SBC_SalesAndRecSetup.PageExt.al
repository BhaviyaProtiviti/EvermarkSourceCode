pageextension 50132 "SBC Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(content)
        {
            group("SBC Additional Settings")
            {
                Caption = 'Additional Settings';
                field("SBC Commercial Invoice Note"; Rec."SBC Commercial Invoice Note")
                {
                    ApplicationArea = All;
                    Caption = 'Commercial Invoice Note';
                    ToolTip = 'Enter multi-line note text for commercial invoices.';
                    MultiLine = true;
                }
                field("SBC Customer Dimension Code"; Rec."SBC Customer Dimension Code")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Dimension Code';
                    ToolTip = 'Specifies which dimension is the Customer dimension.';
                }
                field("SBC Use Location Pricing"; Rec."SBC Use Location Pricing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if Vendor Purchase Prices will use the Location and Shipment Method pricing.';
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
}