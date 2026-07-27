/// <summary>
/// Page SBC Vena Job Setup (ID 50258).
/// </summary>
page 50258 "SBC Vena Job Setup"
{
    Caption = 'SBC Vena Job Setup';
    PageType = Card;
    SourceTable = "SBC Vena Job Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Vena Job Code"; Rec."Vena Job Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Identifier for the Vena Job.', Comment = 'Friendly name.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'A brief description of the Vena Job.';
                }
                field("Vena API Endpoint Path"; Rec."Vena API Endpoint Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'The URI path that is combined with the base API URL in Vena settings.';
                }
                field("Vena Template ID"; Rec."Vena Template ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The template value that must be sent with each Vena file upload request.', Comment = 'This value comes from Vena.';
                }
                field("CSV Template"; GlobalUploadDownloadText)
                {
                    ApplicationArea = All;
                    Caption = 'CSV Template';
                    Editable = false;
                    Lookup = true;
                    ToolTip = 'This template can be loaded and used to generate the upload to Vena.';
                    Visible = true;
                    trigger OnDrillDown()
                    begin
                        Rec.UploadFile();
                    end;
                }
            }
            group(ERP)
            {
                Caption = 'ERP';

                field("ERP Table Name"; Rec."ERP Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The table in the ERP that data will be sent from during this job.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupTable();
                    end;
                }
                field("ERP Table Filter"; GlobalVenaErpTableFilterText)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Lookup = true;
                    ToolTip = 'Filtering for the ERP table.';
                    trigger OnDrillDown()
                    begin
                        Rec.UpdateERPTableFilter(Rec."ERP Table ID");
                        CurrPage.Update(false);
                    end;
                }
                field("Last Entry No. Exported"; Rec."Last Entry No. Exported")
                {
                    ApplicationArea = All;
                    ToolTip = 'The last entry number that was exported to Vena.';
                    Visible = true;
                }
                field("Max Rows Per Export"; Rec."Max Rows Per Export")
                {
                    ApplicationArea = All;
                    ToolTip = 'The maximum number of rows to export to Vena. Rows in excess of this number will be split into additional exports.';
                    Visible = true;
                }

            }
            group(SQL)
            {
                Caption = 'SQL';
                Visible = GlobalIsExternalTable;


                field("Connection String"; GlobalConnectionStringText)
                {
                    ApplicationArea = All;
                    ToolTip = 'The connection string used to connect to the external resource.';
                    Visible = true;
                    trigger OnValidate()
                    begin
                        Rec.Validate("Connection String", GlobalConnectionStringText);

                        if Rec.ConnectionValueSet() then
                            GlobalConnectionStringText := MaskPlaceholderLabel
                        else
                            GlobalConnectionStringText := '';

                        CurrPage.Update(false);
                    end;
                }
            }
            group(Mapping)
            {


                part(VenaJobSetupLines; "SBC Vena Job Setup Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Vena Job Setup Lines';
                    Description = 'The columns that will be sent to Vena from the ERP table.';
                    Editable = Rec."ERP Table ID" <> 0;
                    Enabled = Rec."ERP Table ID" <> 0;
                    Visible = true;
                    SubPageLink = "Vena Job Code" = field("Vena Job Code"), "ERP Table ID" = field("ERP Table ID");
                    UpdatePropagation = SubPart;
                }
            }

        }


    }
    actions
    {
        area(Processing)
        {
            action(SetTableFieldsAsColumns)
            {
                ApplicationArea = All;
                Caption = 'Set Table Fields as Columns';
                ToolTip = 'Sets non-obsolete fields as columns. Does not delete existing columns.';
                Image = Column;
                trigger OnAction()
                begin
                    Rec.SetTableFieldsAsColumns();
                    CurrPage.Update(false);
                    Currpage.VenaJobSetupLines.Page.Update(false);
                end;
            }
            action(SyncVenaJob)
            {
                ApplicationArea = All;
                Caption = 'Sync Vena Job';
                Image = CreateLinesFromJob;
                trigger OnAction()
                var 
                    SBCVenaJobSetup: Record "SBC Vena Job Setup";
                begin
                    SBCVenaJobSetup := Rec;
                    SBCVenaJobSetup.SetRecFilter();
                    Report.Run(Report::"SBC Vena Sync Job", true, false, SBCVenaJobSetup);
                end;

            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(SetTableFieldsAsColumns_Promoted; SetTableFieldsAsColumns)
                {
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        GlobalVenaErpTableFilterText := GlobalVenaErpTableFilterLabel;
        GlobalUploadDownloadText := CSVtemplateDownloadUploadLabel;

        if Rec.ConnectionValueSet() then
            GlobalConnectionStringText := MaskPlaceholderLabel;
    end;

    trigger OnAfterGetRecord()
    var
        TableMetadata: Record "Table Metadata";
    begin
        if xRec."ERP Table ID" = Rec."ERP Table ID" then
            exit;
        TableMetadata.SetRange(Id, Rec."ERP Table ID");
        TableMetadata.SetRange(TableType, TableMetadata."TableType"::ExternalSQL);
        GlobalIsExternalTable := not TableMetadata.IsEmpty();
        if not GlobalIsExternalTable then
            exit;
    end;




    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.VenaJobSetupLines.Page.SetGlobalERPTableId(Rec."ERP Table ID");
    end;

    var

        CSVtemplateDownloadUploadLabel: Label 'Download/Upload';
        GlobalVenaErpTableFilterLabel: Label 'Set/Update ERP Table Filter';
        GlobalConnectionStringText: Text;
        GlobalUploadDownloadText: Text;
        GlobalVenaErpTableFilterText: Text;
        GlobalIsExternalTable: Boolean;
        MaskPlaceholderLabel: Label '********', Locked = true;



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
        Rec.Validate("ERP Table Name", AllObjWithCaption."Object Name");
        CurrPage.Update(true);
    end;
}