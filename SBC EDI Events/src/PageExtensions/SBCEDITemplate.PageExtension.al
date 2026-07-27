/// <summary>
/// PageExtension SBC EDI Template (ID 50089) extends Record LAX EDI Template.
/// </summary>
pageextension 50089 "SBC EDI Template List" extends "LAX EDI Template List"
{
    actions
    {

        addlast(Processing)
        {
            action("SBC Update Discrepancy Flag")
            {
                ApplicationArea = All;
                Caption = 'SBC Update Discrepancy Flag';
                ToolTip = 'This action will update the discrepancy flag on the EDI Receive Document Header based on the value set on the EDI template.';
                Image = Change;
                RunObject = Report "SBCEDI Update Discrepancy Flag";
            }
        }

        addlast(Category_Process)
        {
            actionref(SBCUpdateDiscrepancyFlag_Promoted; "SBC Update Discrepancy Flag")
            {
            }
        }
    }
}