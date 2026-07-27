/// <summary>
/// Page SBCSR Queries (ID 50183).
/// </summary>
page 50183 "SBCSR Queries"
{
    ApplicationArea = All;
    Caption = 'Specright Queries';
    CardPageId = "SBCSR Query";
    PageType = List;
    SourceTable = "SBCSR Query Header";
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Query Code"; Rec."Query Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Query Code field.';

                }
                field("Query Object Name"; Rec."Query Object Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Query Name Name field.';
                }
                field("Query Description"; Rec."Query Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Query Description field.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the table that the returned values in the query will write to.';
                }
                field("Trigger on Write"; Rec."Trigger on Write")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is set, the record trigger will be set on insert or modify.';
                }
            }
        }
    }
}