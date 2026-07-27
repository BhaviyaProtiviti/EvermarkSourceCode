/// <summary>
/// Page id.
/// </summary>
page 50261 "SBC Vena Job Lines"
{
    ApplicationArea = All;
    Caption = 'SBC Vena Job Lines';
    PageType = List;
    SourceTable = "SBC Vena Job Setup Line";
    UsageCategory = Lists;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Vena Job Code"; Rec."Vena Job Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vena Job Code field.', Comment = '%';
                }
                field("Column No."; Rec."Column No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The CSV column number for the Vena CSV file.', Comment = 'Starts from 1.';
                }
                field("ERP Table ID"; Rec."ERP Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ERP Table ID field.', Comment = '%';
                }
                field("ERP Link Table Name"; Rec."ERP Link Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The table in the ERP that data will be sent from during this job.';
                }
                field("ERP Link Table ID"; Rec."ERP Link Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ERP Link Table ID field.', Comment = '%';
                }
                field("ERP Field ID"; Rec."ERP Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The field ID of the ERP table that data will be retrieved from.', Comment = 'This value is used when setting the ERP Field Name flow field value.';
                }
                field("ERP Field Name"; Rec."ERP Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The field name in the ERP table that data will be retrieved from.';
                }
                field("ERP Link Field ID"; Rec."ERP Link Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ERP Link Field ID field.', Comment = '%';
                }
                field("ERP Link Field Name"; Rec."ERP Link Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The field name in the ERP link table that data will be retrieved from.';
                }
                field("ERP Link Table Filter"; Rec."ERP Link Table Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ERP Link Table Filter field.', Comment = '%';
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
}