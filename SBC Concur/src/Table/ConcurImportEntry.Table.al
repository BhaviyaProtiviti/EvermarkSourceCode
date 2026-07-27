Table 50104 "Concur Import Entry"
{
    Caption = 'Concur Import Entry';
    DataClassification = CustomerContent;

    FIELDS
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }

        field(2; "Entry Date"; Date)
        {
            Caption = 'Entry Date';
        }
        field(3; "Employee ID"; Text[30])
        {
            Caption = 'Employee ID';
        }
        field(4; "Employee Last Name"; Text[50])
        {
            Caption = 'Employee Last Name';
        }
        field(5; "Employee First Name"; Text[50])
        {
            Caption = 'Employee First Name';
        }
        field(6; "Report ID"; Text[100])
        {
            Caption = 'Report ID';
        }
        field(7; "Employee Default Currency"; Code[10])
        {
            Caption = 'Employee Default Currency';
        }
        field(8; "Report Submit Date"; Date)
        {
            Caption = 'Report Submit Date';
        }
        field(9; "Report Processing Payment Date"; Date)
        {
            Caption = 'Report Processing Payment Date';
        }
        field(10; "Report Name"; Text[30])
        {
            Caption = 'Report Name';
        }
        field(11; "Expense Type Name"; Code[50])
        {
            Caption = 'Expense Type Name';
        }
        field(12; "Transaction Date"; Date)
        {
            Caption = 'Transaction Date';
        }
        field(13; "Is Personal Flag"; Code[1])
        {
            Caption = 'Is Personal Flag';
        }
        field(14; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(15; "Vendor Name"; Text[50])
        {
            Caption = 'Vendor Name';
        }
        field(16; "Vendor Description"; Text[100])
        {
            Caption = 'Vendor Description';
        }
        field(17; "Payment Code"; Code[10])
        {
            Caption = 'Payment Code';
        }
        field(18; "Payment Name"; Text[100])
        {
            Caption = 'Payment Name';
        }
        field(19; "Payment Reimbursement Type"; Code[10])
        {
            Caption = 'Payment Reimbursement Type';
        }
        field(20; "Billed Credit Card Account No."; Code[30])
        {
            Caption = 'Billed Credit Card Account No.';
        }
        field(21; "Billed Credit Card Acc. Descr."; Text[100])
        {
            Caption = 'Billed Credit Card Acc. Descr.';
        }

        field(22; "Journal Payer Payment Name"; Text[100])
        {
            Caption = 'Journal Payer Payment Name';
        }
        field(23; "Journal Payee Payment Type"; Text[50])
        {
            Caption = 'Journal Payee Payment Type';
        }
        field(24; "Journal Amount"; Decimal)
        {
            Caption = 'Journal Amount';
        }
        field(25; "Journal Account Code"; Code[10])
        {
            Caption = 'Journal Account Code';
        }
        field(26; "Journal Debit Or Credit"; Option)
        {
            Caption = 'Journal Debit Or Credit';
            OptionCaption = 'DR, CR';
            OptionMembers = DR,CR;
        }
        field(27; "Demand Comp. Cash Acc."; Text[30])
        {
            Caption = 'Demand Comp. Cash Acc.';
        }
        field(28; "Demand Comp. Liability Acc."; Text[30])
        {
            Caption = 'Demand Comp. Liability Acc.';
        }
        field(29; "Estimated Payment Date"; Date)
        {
            Caption = 'Estimated Payment Date';
        }
        field(31; Department; Code[20])
        {
            Caption = 'Department';
        }
        field(100; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = ' , American Express, Cash Reimbursements, Visa/Company Paid';
            OptionMembers = " ","American Express","Cash Reimbursements","Visa/Company Paid";
        }
        field(101; "Purchase Invoice No."; Code[20])
        {
            Caption = 'Purchase Invoice No.';
        }
        field(102; "Purchase Invoice Line No."; Integer)
        {
            Caption = 'Purchase Invoice Line No.';
        }
        field(103; "Is Billable"; Boolean)
        {
            Caption = 'Is Billable';
        }
        field(105; "SBC Document Type"; Enum "Purchase Document Type")
        {
            Caption = 'Document Type';
        }
    }
    KEYS
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Report ID")
        {

        }
    }
}

