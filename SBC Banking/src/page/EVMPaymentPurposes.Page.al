page 50600 "EVM Payment Purposes"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "EVM Payment Purpose";
    Caption = 'EVM Payment Purposes';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                ShowCaption = false;

                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Country Code that the Payment Purpose Code applies to.';
                }
                field("Purpose Code"; Rec."Payment Purpose Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Purpose Code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Description of the Payment Purpose Code.';
                }
            }
        }
    }
}