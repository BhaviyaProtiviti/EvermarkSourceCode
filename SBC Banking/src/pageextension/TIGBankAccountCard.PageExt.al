pageextension 50602 "TIG Bank Account Card" extends "Bank Account Card"
{
    // version NAVW111.00.00.46609,NAVNA11.00.00.46609,FXS100,AMCUS11.00.00.19846,VLDM4.07,SR94552

    layout
    {
        addlast(General)
        {
            field("SBC Reconciliation File Path"; Rec."SBC Reconciliation File Path")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Reconciliation File Path field.', Comment = '%';
            }
        }
        addafter(Transfer)
        {
            group(SBCWF)
            {
                Caption = 'WF Export';
                field("WF Export File Path"; "WF Export File Path")
                {
                    ApplicationArea = All;
                }

                field("TIG Download Payment to client"; "TIG Download Payment to client")
                {
                    ApplicationArea = All;
                }
                field("TIG Payment Export Nos"; "TIG Payment Export Nos")
                {
                    ApplicationArea = All;
                }
                field("TIG Last File Name"; "TIG Last File Name")
                {
                    ApplicationArea = All;
                }
                field("SBC ACH Co ID"; "SBC ACH Co ID")
                {
                    ApplicationArea = All;
                }
                field("EVM Check Marketing Message"; "EVM Check Marketing Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Check Marketing Message to print on checks created through the Payment Manager process.';
                    MultiLine = true;
                }
            }
        }
    }
}