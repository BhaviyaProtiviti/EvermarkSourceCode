/// <summary>
/// Page SBC Page Control (ID 50204).
/// </summary>
page 50250 "SBCPC Page Control"
{
    Caption = 'SBC Page Control';
    PageType = List;
    SourceTable = "SBCPC Page Control";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field.', Comment = '%';
                    Visible = false;
                    Editable = false;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field.', Comment = '%';
                }
                field("Table Number"; Rec."Table Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Number field.', Comment = '%';
                    Visible = false;
                }
                field("Field Number"; Rec."Field Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Number field.', Comment = '%';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Caption field.', Comment = '%';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field.', Comment = '%';
                    Visible = false;
                }
                field("Field Filter"; Rec."Field Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Filter field.', Comment = '%';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."User ID" := GlobalUserId;
        if xRec."User ID" = '' then
            exit;

        Rec."User ID" := xRec."User ID";
        Rec."Table Name" := xRec."Table Name";
        Rec."Table Number" := xRec."Table Number";
    end;

    var
        GlobalTableName: Text[30];
        GlobalTableNo: Integer;
        GlobalUserId: Code[50];

    internal procedure SetUserId(UserId: Code[50])
    begin
        GlobalUserId := UserId;
        CurrPage.Update(false);
    end;
}