/// <summary>
/// Page SBC Vena Jobs (ID 50257).
/// </summary>
page 50257 "SBC Vena Jobs List"
{
    ApplicationArea = All;
    Caption = 'SBC Vena Jobs';
    CardPageId = "SBC Vena Job Setup";
    PageType = List;
    SourceTable = "SBC Vena Job Setup";
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Vena API Endpoint Path"; Rec."Vena API Endpoint Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vena API Endpoint Path field.', Comment = '%';
                }
                field("Vena Template ID"; Rec."Vena Template ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vena Template ID field.', Comment = '%';
                }
                field("Last Entry No. Exported"; Rec."Last Entry No. Exported")
                {
                    ApplicationArea = All;
                    ToolTip = 'The last entry number that was exported to Vena.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncVenaJob)
            {
                ApplicationArea = All;
                Caption = 'Sync Vena Job';
                Image = CreateLinesFromJob;
                RunObject = Report "SBC Vena Sync Job";
                RunPageOnRec = true;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(SyncVenaJob_Promoted; SyncVenaJob)
                {
                }
            }
        }
    }
}