tableextension 50129 "SBC Approval Entry" extends "Approval Entry"
{
    fields
    {
        field(50100; "SBC ApprRequester not Approver"; Boolean)
        {
            Caption = 'SBC Approval Requester cannot be Approver';
            DataClassification = CustomerContent;
        }
        field(50101; "SBC Use Final Approver"; Boolean)
        {
            Caption = 'SBC Use Final Approver';
            DataClassification = CustomerContent;
        }
        field(50103; "SBC Final Approval Entry"; Boolean)
        {
            Caption = 'SBC Final Approval Entry';
            DataClassification = CustomerContent;
            //Used only during workflow process
        }
    }
}
