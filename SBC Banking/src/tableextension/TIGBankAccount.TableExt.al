//   FXS100 - ABCS -DM 04/30/17 add bank level
//   TIG001 SR94552 20201109 B_P: Check Printing
tableextension 50600 "TIG Bank Account" extends "Bank Account"
{
    // version NAVW111.00.00.46609,NAVNA11.00.00.46609,FXS100,SR94552

    fields
    {
        field(50000; "WF Export File Path"; Text[250])
        {
            Caption = 'WF Export File Path';
            DataClassification = CustomerContent;
        }
        field(50608; "TIG Payment Export Nos"; code[20])
        {
            Caption = 'Payment Export No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(50609; "TIG Download Payment to client"; Boolean)
        {
            Caption = 'Download Payment to client';
            DataClassification = CustomerContent;
        }
        field(50610; "TIG Last File Name"; Text[250])
        {
            Caption = 'Last File Name';
            DataClassification = CustomerContent;
        }
        field(50611; "SBC Reconciliation File Path"; Text[2048])
        {
            Caption = 'Reconciliation File Path';
            DataClassification = CustomerContent;
        }
        field(50612; "SBC ACH Co ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'ACH Company ID';
        }
        field(50613; "EVM Check Marketing Message"; Text[135])
        {
            DataClassification = CustomerContent;
            Caption = 'Check Marketing Message';
        }
    }

}