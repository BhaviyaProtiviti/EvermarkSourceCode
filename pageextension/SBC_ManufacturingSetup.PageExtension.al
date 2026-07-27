pageextension 50109 "SBC Manufacturing Setup" extends "Manufacturing Setup"
{
    layout
    {
        addlast(Planning)
        {
            field("SBC Default Location"; Rec."SBC Default Location")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("SBC Default Routing Link"; Rec."SBC Default Routing Link")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}