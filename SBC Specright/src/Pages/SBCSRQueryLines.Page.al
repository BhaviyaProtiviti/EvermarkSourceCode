/// <summary>
/// Page SBCSR Query Lines (ID 50181).
/// </summary>
page 50181 "SBCSR Query Lines"
{
    Caption = 'Specright Query Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "SBCSR Query Line";


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'This is the table that the returned values in the query will write to.';
                    Visible = false;
                }
                field("Query Code"; Rec."Query Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Query Code field.';
                    Visible = false;
                }
                field("Query Field Order"; Rec."Query Field Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Query Field Order field.';
                }
                field("Query Field API Name"; Rec."Query Field API Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Query Field API Name field.';
                }
                field("Field ID"; Rec."Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the ID of the field that will be used for this column.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField();
                    end;
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Caption field.';
                    Visible = true;
                }
                field("Default Text"; Rec."Default Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'This text will be used in place of a blank value.';
                    Visible = true;
                }
                field("Replace Blank with Default"; Rec."Replace Blank with Default")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is checked, the value in the Default Text field will be used in place of a blank or zero value.';
                    Visible = true;
                }
                field("Overwrite Existing"; Rec."Overwrite Existing")
                {
                    ApplicationArea = All;
                    ToolTip = 'When this is set, a field that already has a value will be overwritten if a new value is received from Specright..';
                }
                field(Validate; Rec.Validate)
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is checked, the value imported for this definition will call validation logic set on the field being written to, if any.';
                    Visible = true;
                }
                field("Transformation Rule"; Rec."Transformation Rule")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the transformation rule that will be used for this column. It is applied before padding.';
                    Visible = true;
                }
                field("Query Field Description"; Rec."Query Field Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Query Field Description field.';
                    Visible = true;
                }
            }
        }
    }
    var
        GlobalTableName: Text[30];
        GlobalTableNo: Integer;

    internal procedure SetTableNameandNo(Name: Text; No: Integer)
    begin
        GlobalTableName := Name;
        GlobalTableNo := No;
        CurrPage.Update(false);
    end;

    local procedure LookupField()
    var
        "Field": Record "Field";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        FieldSelection: Codeunit "Field Selection";
    begin
        ConfigPackageMgt.SetFieldFilter(Field, Rec."Table No.", 0);
        if not FieldSelection.Open(Field) then
            exit;
        Rec.Validate("Field ID", Field."No.");
        CurrPage.Update(true);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Table Name" := GlobalTableName;
        Rec."Table No." := GlobalTableNo;
    end;

}