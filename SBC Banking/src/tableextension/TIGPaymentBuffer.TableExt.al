//  FXS140 - KT - ABCSI - 8-8-2019
//    - Added fields from 50007 to 50013

//   FXS100 - KT - ABCSI - 3-8-2018
//     - Added a field Bank Level

//   FXS050 - Remit-To-Vendor - KT - ABCSI - 2-5-2018
//     - Added new fields
tableextension 50607 "TIG Payment Buffer" extends "Payment Buffer"
{
    // version NAVW111.00.00.46609,FXS050,FXS100,FXS140

    fields
    {
        field(50600; "TIG Remit-to Vendor No."; Code[20])
        {
            Caption = 'Remit-to Vendor No.';
            Description = 'FXS050';
            NotBlank = true;
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }
        field(50601; "TIG Remit-to Vendor Name"; Text[50])
        {
            Caption = 'Remit-to Vendor Name';
            Description = 'FXS050';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                Vendor: Record Vendor;
            begin
            end;
        }
        field(50602; "TIG Importance Code"; Integer)
        {
            Description = 'FXS100';
            Caption = 'Importance Code';
            DataClassification = CustomerContent;
        }
        field(50603; "TIG Remit-to Address"; Text[50])
        {
            Caption = 'Remit-to Address';
            DataClassification = CustomerContent;
        }
        field(50604; "TIG Remit-to Address 2"; Text[50])
        {
            Caption = 'Remit-to Address 2';
            DataClassification = CustomerContent;
        }
        field(50605; "TIG Remit-to City"; Text[30])
        {
            Caption = 'Remit-to City';
            DataClassification = CustomerContent;
            TableRelation = IF ("TIG Remit-to Country/Region" = CONST('')) "Post Code".City
            ELSE
            IF ("TIG Remit-to Country/Region" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("TIG Remit-to Country/Region"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(50606; "TIG Remit-to Post Code"; Code[20])
        {
            Caption = 'Remit-to Post Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("TIG Remit-to Country/Region" = CONST('')) "Post Code"
            ELSE
            IF ("TIG Remit-to Country/Region" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("TIG Remit-to Country/Region"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(50607; "TIG Remit-to County"; Text[30])
        {
            Caption = 'Remit-to County';
            DataClassification = CustomerContent;
        }
        field(50608; "TIG Remit-to Country/Region"; Code[10])
        {
            Caption = 'Remit-to Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(50609; "TIG Posting Description"; Text[50])
        {
            Caption = 'Posting Description';
            DataClassification = CustomerContent;
        }
    }
}