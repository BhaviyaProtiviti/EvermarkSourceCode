/// <summary>
/// Page SBCSR Sub Queries (ID 50185).
/// </summary>
page 50185 "SBCSR Sub Queries"
{
    Caption = 'SBCSR Sub Queries';
    PageType = ListPart;
    SourceTable = "SBCSR Sub Query";

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
                    Visible = false;
                }
                field("Sub Query Code"; Rec."Sub Query Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sub Query Code field.';
                    TableRelation = "SBCSR Query Header";
                }
            }
        }
    }

    var
        GlobalQueryCode: Code[20];

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Query Code" := GlobalQueryCode;
    end;

    internal procedure SetGlobalQueryCode(QueryCode: Code[20])
    begin
        GlobalQueryCode := QueryCode;
        CurrPage.Update(false);
    end;
}