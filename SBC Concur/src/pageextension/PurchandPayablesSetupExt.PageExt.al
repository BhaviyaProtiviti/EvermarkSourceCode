pageextension 50122 "PurchandPayablesSetup-Ext" extends "Purchases & Payables Setup"
{
    layout
    {
        addlast("Default Accounts")
        {
            field("American Express Vendor No."; rec."American Express Vendor No.")
            {
                Caption = 'American Express Vendor No.';
                ToolTip = 'American Express Vendor No.';
                ApplicationArea = All;
            }
            group(Payments)
            {
                Caption = 'Payments';
                field("SBC AmEx Pmt Batch Name"; rec."SBC AmEx Pmt Jnl Batch Name")
                {
                    Caption = 'SBC AmEx Payment Journal Batch Name';
                    ToolTip = 'Specifies which payment journal batch to use for SBC AmEx payments';
                    ApplicationArea = All;
                }
                field("SBC AmEx Offsetting Account No"; rec."SBC AmEx Offsetting Account No")
                {
                    Caption = 'SBC AmEx Offsetting Account No.';
                    ToolTip = 'Specifies which bank account to use for SBC AmEx Offsetting Account';
                    ApplicationArea = All;
                }
            }
            field("Visa/Company Paid Vendor No."; rec."Visa Vendor No.")
            {
                Caption = 'Visa/Company Paid Vendor No.';
                ToolTip = 'Visa/Company Paid Vendor No.';
                ApplicationArea = All;
                Visible = false;
            }
        }
    }
}