/// <summary>
/// Table SBCSR Query Header (ID 50181).
/// </summary>
table 50181 "SBCSR Query Header"
{
    Caption = 'SBCSR Query Header';
    DataClassification = CustomerContent;
    DrillDownPageId = "SBCSR Query Lines";
    LookupPageId = "SBCSR Queries";

    fields
    {
        field(1; "Query Code"; Code[20])
        {
            Caption = 'Query Code';
        }
        field(2; "Query Object Name"; Text[80])
        {
            Caption = 'Query Object Name';
        }
        field(10; "Query Description"; Text[250])
        {
            Caption = 'Query Description';
        }
        field(20; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            DataClassification = CustomerContent;
            Description = 'This is the table that the returned values in the query will write to.';

            trigger OnValidate()
            var
                TypeHelper: Codeunit "Type Helper";
            begin
                SetTableNo();
                UpdateTableName();
            end;
        }
        field(21; "Config Template Code"; Code[10])
        {
            Caption = 'Config Template Code';
            Description = 'This is the code of the configuration template that will be used to generate the query.';
            TableRelation = "Config. Template Header" where("Table ID" = field("Table No."));
        }
        field(14; "Table No."; Integer)
        {
            BlankZero = true;
            Caption = 'From Table No.';
            Description = 'Helper field';
            Editable = false;
            MinValue = 0;
        }
        field(30; "Trigger on Write"; Boolean)
        {
            Caption = 'Trigger on Write';
            Description = 'If this is set, the record trigger will be set on insert or modify.';
            InitValue = true;
        }
    }
    keys
    {
        key(PK; "Query Code")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(Brick; "Query Code", "Query Object Name", "Query Description")
        {

        }
        fieldGroup(DropDown; "Query Code", "Query Object Name", "Query Description")
        {

        }
    }

    trigger OnRename()
    begin
        RenameLines();
        RenameSubQueries();
    end;

    /// <summary>
    /// This trigger will set the From Table No. field based on the value in the From Table field.
    /// </summary>
    local procedure SetTableNo()
    var
        TableMetadata: Record "Table Metadata";
    begin
        Rec."Table No." := 0;
        TableMetadata.SetLoadFields(ID);
        TableMetadata.SetFilter(Name, '%1', Rec."Table Name");
        if TableMetadata.IsEmpty() then
            exit;
        TableMetadata.FindFirst();
        Rec."Table No." := TableMetadata.ID;
    end;

    local procedure UpdateTableName()
    var
        SBCSRQueryLine: Record "SBCSR Query Line";
    begin
        SBCSRQueryLine.SetRange("Query Code", Rec."Query Code");
        SBCSRQueryLine.SetFilter("Table Name", '<>%1', Rec."Table Name");
        if SBCSRQueryLine.IsEmpty() then
            exit;
        SBCSRQueryLine.ModifyAll("Table No.", Rec."Table No.");
        SBCSRQueryLine.ModifyAll("Table Name", Rec."Table Name");
    end;

    internal procedure RenameLines()
    var
        SBCSRQueryLine: Record "SBCSR Query Line";
        RenameSBCSRQueryLine: Record "SBCSR Query Line";
    begin
        SBCSRQueryLine.SetFilter("Query Code", '%1', xRec."Query Code");
        if SBCSRQueryLine.IsEmpty() then
            exit;
        SBCSRQueryLine.FindSet(true);
        repeat
            RenameSBCSRQueryLine.Get(SBCSRQueryLine."Query Code", SBCSRQueryLine."Query Field Order");
            RenameSBCSRQueryLine.Rename(Rec."Query Code", SBCSRQueryLine."Query Field Order");
        until SBCSRQueryLine.Next = 0;
    end;

    internal procedure RenameSubQueries()
    var
        SBCSRSubQuery: Record "SBCSR Sub Query";
        RenameSBCSRSubQuery: Record "SBCSR Sub Query";
    begin
        SBCSRSubQuery.SetFilter("Query Code", '%1', xRec."Query Code");
        if SBCSRSubQuery.IsEmpty() then
            exit;
        SBCSRSubQuery.FindSet(true);
        repeat
            RenameSBCSRSubQuery.Get(SBCSRSubQuery."Query Code", SBCSRSubQuery."Sub Query Code");
            RenameSBCSRSubQuery.Rename(Rec."Query Code", SBCSRSubQuery."Sub Query Code");
        until SBCSRSubQuery.Next = 0;
    end;
}