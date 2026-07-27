pageextension 50119 "SBC Workflow Response Options" extends "Workflow Response Options"
{
    layout
    {
        addafter("Approver Limit Type")
        {        
            field("SBC ApprRequester not Approver"; Rec."SBC ApprRequester not Approver")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Approval Requester cannot be the document approver.', Comment = '%';
                // Visible = Rec."Response Option Group" = 'GROUP 5';
            }
        }
    }
}
