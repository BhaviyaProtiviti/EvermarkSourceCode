/// <summary>
/// PageExtension SBCOE Vendor (ID 50070) extends Record Vendor Card.
/// </summary>
pageextension 50070 "SBCOE Vendor Card" extends "Vendor Card"
{
    layout
    {
        addlast(Contact)
        {
            group(SBCOEExport)
            {
                Caption = 'SBC Excel Order Export';
                field("SBCOE Export Definition"; Rec."SBCOE Export Definition")
                {
                    ApplicationArea = All;
                    Caption = 'Export Template';
                    ToolTip = 'This is export template that will be used for Excel Purchase Order exports for this Vendor in place of the default export template.';
                }
                field("SBCOE Email Group"; Rec."SBCOE Email Group")
                {
                    ApplicationArea = All;
                    Caption = 'Email Group';
                    ToolTip = 'These emails will be added to the email list when sending Excel Purchase Order exports in place of the default email group for the export.';
                }
            }
        }
    }

}