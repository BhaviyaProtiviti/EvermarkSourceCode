pageextension 50154 "SBC LAX EDI Trade Partner" extends "LAX EDI Trade Partner"
{
    layout
    {
        addlast(Options)
        {
            group(SBCEDIReceiveDocMap)
            {
                Caption = 'SBC Receive Document Field Mapping';

                field("SBC RecDoc PostDate Field Name"; Rec."SBC RecDoc PostDate Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies what EDI field to use as the Posting Date for 810''s when creating Business Central Documents from EDI Receive Documents. If this field is left blank, the Posting Date will be set to the Work Date.';
                }
            }
        }
    }
}