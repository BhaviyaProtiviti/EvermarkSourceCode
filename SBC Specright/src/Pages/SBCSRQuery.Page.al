/// <summary>
/// Page SBCSR Query (ID 50182).
/// </summary>
page 50182 "SBCSR Query"
{
    Caption = 'Specright Query';
    PageType = Card;
    SourceTable = "SBCSR Query Header";

    layout
    {
        area(content)
        {
            group(Query)
            {
                Caption = 'Query';

                field("Query Code"; Rec."Query Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Query Code field.';
                    trigger OnValidate()
                    begin
                        Rec.RenameLines();
                        CurrPage.QueryFields.Page.Update(false);
                    end;
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
                field("Config Template Code"; Rec."Config Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the code of the configuration template that will be used to generate the query.';
                    TableRelation = "Config. Template Header" where("Table ID" = field("Table No."));
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the table that the returned values in the query will write to.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupTable();
                    end;
                }
                field("Trigger on Write"; Rec."Trigger on Write")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is set, the record trigger will be set on insert or modify.';
                }
            }
            part(QueryFields; "SBCSR Query Lines")
            {
                ApplicationArea = All;
                Caption = 'Query Fields';
                Editable = Rec."Table No." <> 0;
                Enabled = Rec."Table No." <> 0;
                SubPageLink = "Query Code" = field("Query Code");
                UpdatePropagation = SubPart;
            }
            part(SubQueries; "SBCSR Sub Queries")
            {
                ApplicationArea = All;
                Caption = 'Sub Queries';
                Editable = Rec."Table No." <> 0;
                Enabled = Rec."Table No." <> 0;
                SubPageLink = "Query Code" = field("Query Code");
                UpdatePropagation = SubPart;
            }

        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.QueryFields.Page.SetTableNameandNo(Rec."Table Name", Rec."Table No.");
        CurrPage.SubQueries.Page.SetGlobalQueryCode(Rec."Query Code");
    end;

    local procedure LookupTable()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        TableObjects: Page "Table Objects";
    begin
        TableObjects.LookupMode(true);
        if not (Action::LookupOK = TableObjects.RunModal()) then
            exit;
        TableObjects.SetSelectionFilter(AllObjWithCaption);
        TableObjects.GetRecord(AllObjWithCaption);
        Rec.Validate("Table Name", AllObjWithCaption."Object Name");
        CurrPage.Update(true);
    end;
}