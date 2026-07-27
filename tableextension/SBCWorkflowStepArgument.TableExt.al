tableextension 50128 "SBC Workflow Step Argument" extends "Workflow Step Argument"
{
    fields
    {
        field(50100; "SBC ApprRequester not Approver"; Boolean)
        {
            Caption = 'SBC Approval Requester cannot be Approver';
            DataClassification = CustomerContent;
        }
        // field(50101; "SBC Use Final Approver"; Boolean)
        // {
        //     Caption = 'SBC Use Final Approver';
        //     DataClassification = CustomerContent;
        // }
        // field(50102; "SBC Final Approval User"; Code[50])
        // {
        //     Caption = 'SBC Final Approval User';
        //     DataClassification = CustomerContent;
        //     TableRelation = "Salesperson/Purchaser";
        // }
    }
}