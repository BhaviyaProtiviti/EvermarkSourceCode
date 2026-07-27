pageextension 50120 "SBC Approval User Setup" extends "Approval User Setup"
{
    layout
    {
        addafter("Unlimited Purchase Approval")
        {
            field("SBC JnlBatch AmtApproval Limit"; Rec."SBC JnlBatch AmtApproval Limit")
            {
                ApplicationArea = All;
                ToolTip = 'Enter the amount limit for journal batch approval';
            }            
            field("SBC JnlBatch Unlimited Approv"; Rec."SBC JnlBatch Unlimited Approv")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Journal Batch Unlimited Approval field.', Comment = '%';
            }
        }
    }
}