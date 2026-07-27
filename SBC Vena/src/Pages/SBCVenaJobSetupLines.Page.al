/// <summary>
/// Page SBC Vena Job Setup Lines (ID 50259).
/// </summary>
page 50259 "SBC Vena Job Setup Lines"
{
    Caption = 'SBC Vena Job Setup Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "SBC Vena Job Setup Line";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Column No."; Rec."Column No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The CSV column number for the Vena CSV file.', Comment = 'Starts from 1.';
                }
                field("ERP Field ID"; Rec."ERP Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The field ID of the ERP table that data will be retrieved from.', Comment = 'This value is used when setting the ERP Field Name flow field value.';
                    Visible = false;
                    // trigger OnLookup(var Text: Text): Boolean
                    // begin
                    //     LookupField();
                    // end;
                }
                field("ERP Field Name"; Rec."ERP Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    DrillDown = true;
                    Visible = true;
                    ToolTip = 'The field name in the ERP table that data will be retrieved from.';
    
                    trigger OnDrillDown()
                    begin
                        LookupField();
                    end;
                }
                field("ERP Link Table Name"; Rec."ERP Link Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The table in the ERP that data will be sent from during this job.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupTable();
                    end;
                }
                field("ERP Link Table Filter"; GlobalVenaErpTableFilterText)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Lookup = true;
                    ToolTip = 'Filtering for the ERP Link table.';
                    trigger OnDrillDown()
                    begin
                        Rec.UpdateERPTableFilter(Rec."ERP Link Table ID");
                    end;
                }
                field("ERP Link Field Name"; Rec."ERP Link Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = true;
                      DrillDown = true;
                    ToolTip = 'The field name in the ERP link table that data will be retrieved from.';
                      trigger OnDrillDown()
                    begin
                        LookupLinkField();
                    end;
                }
                field("ERP Link Field ID"; Rec."ERP Link Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ERP Link Field ID field.', Comment = '%';
                    Visible = false;
                }



                field("Default Value"; Rec."Default Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'If the ERP field is not set or the value from the field is empty, this value will be used.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'A brief description of the field and/or its usage.';
                }

            }


        }
    }

    var
        GlobalERPTableId: Integer;
        GlobalVenaErpTableFilterText: Text;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."ERP Table ID" := GlobalERPTableId;

    end;

    internal procedure SetGlobalERPTableId(ERPTableId: Integer) // This may not be needed because table Id is in the key of the table.
    begin
        GlobalERPTableId := ERPTableId;
    end;

    local procedure LookupField()
    var
        "Field": Record "Field";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        FieldSelection: Codeunit "Field Selection";
    begin
        ConfigPackageMgt.SetFieldFilter(Field, Rec."ERP Table ID", 0);
        if not FieldSelection.Open(Field) then
            exit;
        Rec.Validate("ERP Field ID", Field."No.");
        CurrPage.Update(true);
    end;
    local procedure LookupLinkField()
    var
        "Field": Record "Field";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        FieldSelection: Codeunit "Field Selection";
    begin
        ConfigPackageMgt.SetFieldFilter(Field, Rec."ERP Link Table ID", 0);
        if not FieldSelection.Open(Field) then
            exit;
        Rec.Validate("ERP Link Field ID", Field."No.");
        CurrPage.Update(true);
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
        Rec.Validate("ERP Link Table Name", AllObjWithCaption."Object Name");
        CurrPage.Update(true);
    end;
}