/// <summary>
/// PageExtension SBCPC User Card (ID 50204) extends Record User Card.
/// </summary>
pageextension 50250 "SBCPC User Card" extends "User Card"
{
    actions
    {

        addlast(processing)
        {
            action(ShowSBCPCPageControl)
            {
                ApplicationArea = All;
                Caption = 'SBC Page Control Filters';
                Image = Permission;
                trigger OnAction()
                var
                    SBCPCPageControl: Page "SBCPC Page Control";
                    SBCPCPageControlRecord: Record "SBCPC Page Control";
                begin
                    SBCPCPageControlRecord.SetRange("User ID", Rec."User Name");
                    SBCPCPageControl.SetTableView(SBCPCPageControlRecord);
                    SBCPCPageControl.SetRecord(SBCPCPageControlRecord);
                    SBCPCPageControl.SetUserId(Rec."User Name");
                    SBCPCPageControl.RunModal();
                end;
            }
        }
        addlast(Category_Process)
        {
            actionref(ShowSBCPCPageControl_Promoted; ShowSBCPCPageControl)
            {
            }
        }
    }
}