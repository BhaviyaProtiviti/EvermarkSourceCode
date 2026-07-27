tableextension 50104 "SBC_User Setup" extends "User Setup"
{
    fields
    {
        field(50000; "SBC Subcontracting Batch"; Code[10])
        {
            Caption = 'SBC Subcontracting Batch';
            DataClassification = CustomerContent;
            TableRelation = "Requisition Wksh. Name".Name where("Worksheet Template Name" = CONST('FOR. LABOR'));
            Description = 'This is the batch used by the user when creating a Subcontracting Purchase Order directly from the Released Production Order.';
        }
        field(50100; "SBC JnlBatch AmtApproval Limit"; Integer)
        {
            BlankZero = true;
            Caption = 'SBC Journal Batch Amount Approval Limit';
            DataClassification = CustomerContent;
        }
        field(50101; "SBC JnlBatch Unlimited Approv"; Boolean)
        {
            Caption = 'SBC Journal Batch Unlimited Approval';
            DataClassification = CustomerContent;
        }
    }
}