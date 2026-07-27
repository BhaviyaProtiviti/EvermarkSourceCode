pageextension 50350 "SBC Contract User Setup" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {            
            field("SBC Allow delete Post Contract"; Rec."SBC Allow delete Post Contract")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Allow delete Posted Contract field.';
            }
        }
    }
}
