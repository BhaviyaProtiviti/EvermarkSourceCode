/// <summary>
/// This page part is used to display the export entries in the export entry list.
/// </summary>
page 50068 "SBCOE Export Entries Part"
{
    ApplicationArea = All;
    Caption = 'Export Entries Part';
    Description = 'This page part is used to display the export entries in the export entry list.';
    PageType = ListPart;
    SourceTable = "SBCOE Export Entry";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'General';
                Editable = false;
                field("Export Entry No."; Rec."Export Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Export Entry No.';
                    ToolTip = 'Specifies the value of the Export Entry No. field.';
                    Visible = false;
                }
                field("Row Type"; Rec."Row Type")
                {
                    ApplicationArea = All;
                    Caption = 'Export Row Type';
                    ToolTip = 'The row type the data in the export record is used for.';
                    Visible = false;
                }
                field("Export Document Key"; Rec."Export Document Key")
                {
                    ApplicationArea = All;
                    Caption = 'Export Document No.';
                    DrillDown = true;
                    ToolTip = 'The document number of the record that is included in the export.';
                    Visible = true;
                    trigger OnDrillDown()
                    begin
                        Rec.ViewRecord();
                    end;
                }
                field("Export Table Name"; Rec."Export Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'Export Table Name';
                    DrillDown = true;
                    ToolTip = 'Specifies the value of the Export Table Name field.';
                    Visible = true;
                    trigger OnDrillDown()
                    begin
                        Rec.ViewRecord();
                    end;
                }
                field(ExportRecordDescription; GlobalExportRecordDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Export Record Description';
                    DrillDown = true;
                    ToolTip = 'The description of the export record.';
                    Visible = true;
                    trigger OnDrillDown()
                    begin
                        Rec.ViewRecord();
                    end;
                }
                field("Export System ID"; Rec."Export System ID")
                {
                    ApplicationArea = All;
                    Caption = 'Export System ID';
                    DrillDown = true;
                    ToolTip = 'Specifies the value of the Export System ID field.';
                    Visible = false;
                    trigger OnDrillDown()
                    begin
                        Rec.ViewRecord();
                    end;
                }
                field("Export Table No."; Rec."Export Table No.")
                {
                    ApplicationArea = All;
                    Caption = 'Export Table No.';
                    DrillDown = true;
                    ToolTip = 'Specifies the value of the Export Table No. field.';
                    Visible = false;
                    trigger OnDrillDown()
                    begin
                        Rec.ViewRecord();
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        GlobalExportRecordDescription := Format(Rec.GetRecordIDFromSystemID());
    end;

    var
        GlobalExportRecordDescription: Text;
}
