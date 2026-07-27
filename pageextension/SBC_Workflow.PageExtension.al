pageextension 50128 "SBC Workflow" extends Workflow
{
    layout
    {
        addbefore(Enabled)
        {

            field("SBC Purchase Final Approver"; Rec."SBC Purchase Final Approver")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Purchase Final Approver field.', Comment = '%';
            }
        }
        addafter(Enabled)
        {

            field("SBC Custom Purch Workflow"; Rec."SBC Custom Purch Workflow")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Custom Purch Doc. Workflow field.', Comment = '%';
                Caption = 'SBC Insert Finance Approval';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // Check if Final approver is assigned when Custom Purhcase workflow is enabled
        if Rec."SBC Custom Purch Workflow" = true then
            Rec.TestField(Rec."SBC Purchase Final Approver");
    end;

    var
        myInt: Integer;
}