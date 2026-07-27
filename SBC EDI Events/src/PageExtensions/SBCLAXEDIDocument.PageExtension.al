/// <summary>
/// PageExtension SBC LAX EDI Document (ID 50081) extends Record LAX EDI Document.
/// </summary>
pageextension 50081 "SBC LAX EDI Document" extends "LAX EDI Document"
{
    layout
    {
        addafter("Allow $0 Price Discrepancy")
        {

            field("SBC Accept Lower Unit Price"; Rec."SBC Accept Lower Unit Price")
            {
                ApplicationArea = All;
                ToolTip = 'When this is set, a lower unit price on the EDI document will be accepted and set as the unit price on the sales line.';
                Visible = true;
            }
            field("SBC Variance Threshold"; Rec."SBC Variance Threshold")
            {
                ApplicationArea = All;
                ToolTip = 'Total variance amount for the line will be ignored if it is below this amount.';
                Visible = true;
                BlankZero = true;
                MinValue = 0;
            }
            field("SBC Threshold Type"; Rec."SBC Threshold Type")
            {
                ApplicationArea = All;
                Visible = true;
                Enabled = Rec."SBC Variance Threshold" > 0;
                ToolTip = 'Type of threshold to use when comparing EDI and ERP unit prices.';
            }
        }
        addafter(SalesPriceDiscrepancy)
        {
            group("SBC Additional")
            {
                field("SBC SMOG Enabled"; Rec."SBC SMOG Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'When this is set, the EDI document will be checked for Smog order information.';
                    Visible = true;
                }
                field("SBC Create Missing Customer"; Rec."SBC Create Missing Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'When this is set, a missing Customer on the EDI document will be created as a new customer Customer.';
                }
                field("SBC Customer Template"; Rec."SBC Customer Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Customer Template that is used during Customer Creation.';
                    Visible = true;
                    Enabled = Rec."SBC Create Missing Customer";
                }
                field("SBC Create Missing Ship-To"; Rec."SBC Create Missing Ship-To")
                {
                    ApplicationArea = All;
                    ToolTip = 'When this is set, a missing ship-to address on the EDI document will be created as a new customer Ship-To.';
                    Visible = true;
                }
                field("SBC Allow SO Update from 850"; Rec."SBC Allow SO Update from 850")
                {
                    ApplicationArea = All;
                    ToolTip = 'When this is set, an existing Sales Order that has not been shipped can be updated from a new version of an existing 850 EDI document.';
                    Enabled = GLobal850ActionsEnabled;
                }
            }
        }
    }
    var
        ImportSalesOrderLabel: Label 'I_SLSORD', Locked = true;
        ImportSalesOrderEDIDocLabel: Label '850', Locked = true;
        GLobal850ActionsEnabled: Boolean;

    trigger OnAfterGetRecord()
    begin
        GLobal850ActionsEnabled := (Rec."Document" = ImportSalesOrderLabel) and (Rec."EDI Document No." = ImportSalesOrderEDIDocLabel);
        if GLobal850ActionsEnabled then
            exit;
    end;
}