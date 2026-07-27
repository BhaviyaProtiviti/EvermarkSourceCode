/// <summary>
/// Page SBC Vena Job Status (ID 50260).
/// </summary>
page 50260 "SBC Vena Job Status"
{
    ApplicationArea = All;
    Caption = 'SBC Vena Job Status';
    PageType = List;
    SourceTable = "SBC Vena Job Status";
    SourceTableView = order(descending);
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Vena Send Date"; Rec."Vena Send Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'The date the request was sent to Vena.';
                    Visible = true;
                    Editable = false;
                }
                field("Vena Job ID"; Rec."Vena Job ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Job ID sent back in the response to the Vena request.';
                    Visible = true;
                    Editable = false;
                }
                field("Vena Status"; Rec."Vena Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Status value sent back in the response to the Vena request.';
                    Visible = true;
                }
                field("Vena CSV"; GlobalVenaDownloadText)
                {
                    ApplicationArea = All;
                    ToolTip = 'The blob file that represents the CSV file sent to Vena.', Comment = 'To use the drilldown link associated with this field, you must be assigned the Vena CSV Save permission set';
                    Visible = true;
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        Rec.DownloadVenaCSV();

                    end;
                }
                field("Vena API Endpoint Path"; Rec."Vena API Endpoint Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Vena API path that was used during the request.', Comment = 'The base Vena API url in Vena API Setup is combined with this value.';
                    Visible = true;
                }
                field("Vena Template ID"; Rec."Vena Template ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The template value sent to Vena in the request.', Comment = 'This is logged here for reference so that if the Template ID on a job changes, users are able to determine what template IDs were used with the job in the past.';
                    Visible = true;
                }
                field("Vena Model ID"; Rec."Vena Model ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Model ID sent back in the response to the Vena request.';
                    Visible = true;
                    Editable = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Key field.';
                    Visible = true;
                    Editable = false;
                }
                field("Vena Job Code"; Rec."Vena Job Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Value of the Vena Job Code that the request was created from.';
                    Visible = true;
                    Editable = false;
                }
                field("Resent from Entry No."; Rec."Resent from Entry No.")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Visible = true;
                    ToolTip = 'The Entry No. of the original job that was resent.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(UpdateJobStatus)
            {
                Caption = 'Update Job Status';
                ApplicationArea = All;
                ToolTip = 'Update the status of the Vena Job.';
                Image = UpdateXML;
                RunObject = report "SBC Vena Job Status Update";
            }
            action(ResendVenaJob)
            {
                Caption = 'Resend Vena Job';
                ApplicationArea = All;
                ToolTip = 'Resend the Vena Job to Vena.';
                Image = Redo;
                trigger OnAction()
                begin
                    Rec.ResendVenaJob();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(UpdateJobStatus_Promoted; UpdateJobStatus)
                {
                }
                actionref(ResendVenaJob_Promoted; ResendVenaJob)
                {
                }
            }
        }
    }

    var
        GlobalVenaDownloadText: Text;

    trigger OnOpenPage()
    begin
        GlobalVenaDownloadText := 'Download';
    end;
}