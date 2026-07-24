tableextension 50608 "TIG Payment Export Data" extends "Payment Export Data"
{
    fields
    {
        field(50600; "TIG Remit-to Vendor No."; Text[100])
        {
            Caption = 'Remit-to Vendor No.';
            TableRelation = Vendor."No.";
            DataClassification = CustomerContent;
        }
        field(50601; "TIG Remit-to Name"; Text[100])
        {
            Caption = 'Remit-to Name';
            DataClassification = CustomerContent;
        }
        field(50602; "TIG Remit-to Address"; Text[100])
        {
            Caption = 'Remit-to Address';
            DataClassification = CustomerContent;
        }
        field(50603; "TIG Remit-to City"; Text[50])
        {
            Caption = 'Remit-to City';
            DataClassification = CustomerContent;
        }
        field(50604; "TIG Remit-to Post Code"; Code[20])
        {
            Caption = 'Remit-to Post Code';
            DataClassification = CustomerContent;
        }
        field(50605; "TIG Remit-to Country Code"; Code[10])
        {
            Caption = 'Remit-to Country/Region Code';
            DataClassification = CustomerContent;
        }
        field(50606; "TIG Remit-to Email Address"; Text[80])
        {
            Caption = 'Remit-to Email Address';
            DataClassification = CustomerContent;
        }
        field(50607; "TIG Remit-to ID"; Code[20])
        {
            Caption = 'Remit-to ID';
            DataClassification = CustomerContent;
        }
        field(50608; "TIG Remit-to Address 2"; Text[100])
        {
            Caption = 'Remit-to Address 2';
            DataClassification = CustomerContent;
        }
        field(50609; "TIG Remit-to Bank Clearg Std."; Text[50])
        {
            Caption = 'Remit-to Bank Clearing Std.';
            TableRelation = "Bank Clearing Standard";
            DataClassification = CustomerContent;
        }
        field(50610; "TIG Remit-to Bank Clearing"; Text[50])
        {
            Caption = 'Remit-to Bank Clearing Code';
            DataClassification = CustomerContent;
        }
        field(50611; "TIG Remit-to Reg. No."; Code[20])
        {
            Caption = 'Remit-to Reg. No.';
            DataClassification = CustomerContent;
        }
        field(50612; "TIG Remit-to Acc. No."; Code[30])
        {
            Caption = 'Remit-to Acc. No.';
            DataClassification = CustomerContent;
        }
        field(50613; "TIG Remit-to Bank Acc. No."; Text[50])
        {
            Caption = 'Remit-to Bank Acc. No.';
            DataClassification = CustomerContent;
        }
        field(50614; "TIG Remit-to Bank BIC"; Code[35])
        {
            Caption = 'Remit-to Bank BIC';
            DataClassification = CustomerContent;
        }
        field(50615; "TIG Remit-to Bank Name"; Text[100])
        {
            Caption = 'Remit-to Bank Name';
            DataClassification = CustomerContent;
        }
        field(50616; "TIG Remit-to Bank Address"; Text[100])
        {
            Caption = 'Remit-to Bank Address';
            DataClassification = CustomerContent;
        }
        field(50617; "TIG Remit-to Bank City"; Text[50])
        {
            Caption = 'Remit-to Bank City';
            DataClassification = CustomerContent;
        }
        field(50618; "TIG Remit-to Bank Country"; Code[10])
        {
            Caption = 'Remit-to Bank Country/Region';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(50619; "TIG Remit-to Bank Post Code"; Code[20])
        {
            Caption = 'Remit-to Bank Post Code';
            DataClassification = CustomerContent;
        }
        field(50620; "TIG Remit-to Bank County"; Text[30])
        {
            CaptionClass = '5,11,' + "TIG Remit-to Bank Country";
            Caption = 'RRemit-to Bank County';
            DataClassification = CustomerContent;
        }
        field(50621; "TIG Remit-to County"; Text[30])
        {
            CaptionClass = '5,11,' + "TIG Remit-to Country Code";
            Caption = 'Remit-to County';
            DataClassification = CustomerContent;
        }
        field(50622; TIGNbOfTxs; Integer)
        {
            editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Payment Export Data" where("General Journal Template" = field("General Journal Template"), "General Journal Batch Name" = field("General Journal Batch Name"),
            "Sender Bank Account Code" = field("Sender Bank Account Code")));

        }
        field(50623; TIGCtrlSum; Decimal)
        {
            editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Payment Export Data".Amount where("General Journal Template" = field("General Journal Template"), "General Journal Batch Name" = field("General Journal Batch Name"),
            "Sender Bank Account Code" = field("Sender Bank Account Code")));

        }
        field(50624; "TIG Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
            DataClassification = CustomerContent;

        }
        field(50625; "TIG Description"; Code[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;

        }
        field(50626; "TIG Bank Account No."; Text[30])
        {
            Caption = 'Bank Account No.';
            DataClassification = CustomerContent;

        }
        field(50627; "TIG Bank Branch No."; Text[20])
        {
            Caption = 'Bank Branch No.';
            DataClassification = CustomerContent;

        }
        field(50628; "TIG Remit-to Bank Transit No."; Text[20])
        {
            Caption = 'Remit-to Bank Transit No.';
            DataClassification = CustomerContent;
        }
        field(50629; "TIG WF ID"; Code[20])
        {
            Caption = 'WF Bank ID';
            Dataclassification = CustomerContent;
        }
        field(50630; "TIG Sender IBAN"; Code[50])
        {
            Caption = 'Sender IBAN';
            Dataclassification = CustomerContent;
        }
        field(50631; "TIG Remit-to Bank Code"; Code[20])
        {
            Caption = 'Remit-to Bank Code';
            DataClassification = CustomerContent;
        }
        field(50632; "TIG Sender ACH Co ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Sender ACH Company ID';
        }
        field(50633; "TIG Sender ClrSysID Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Sender ClrSysID Code';
        }
        field(50634; "TIG Remit-to ClrSysID Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Remit-to ClrSysID Code';
        }
        field(50635; "TIG Payment Purpose Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Purpose Code';
        }
        field(50636; "TIG Check Marketing Message"; Text[135])
        {
            DataClassification = CustomerContent;
            Caption = 'Check Marketing Message';
        }
    }

    procedure SetRemitToVendorAsRecipient(var Vendor: Record Vendor; var VendorBankAccount: Record "Vendor Bank Account"; BankAccount: Record "Bank Account")
    begin
        "TIG Remit-to Vendor No." := Vendor."No.";
        "TIG Remit-to Name" := Vendor.Name;
        "TIG Remit-to Address" := CopyStr(Vendor.Address, 1, 70);
        "TIG Remit-to Address 2" := CopyStr(Vendor."Address 2", 1, 70);
        "TIG Remit-to City" := CopyStr(Vendor.City, 1, 35);
        "TIG Remit-to County" := Vendor.County;
        "TIG Remit-to Post Code" := Vendor."Post Code";
        "TIG Remit-to Country Code" := Vendor."Country/Region Code";
        "TIG Remit-to Email Address" := Vendor."E-Mail";
        "TIG Remit-to Bank Name" := VendorBankAccount.Name;
        "TIG Remit-to Bank Address" := CopyStr(VendorBankAccount.Address, 1, 70);
        "TIG Remit-to Bank City" := CopyStr(VendorBankAccount.City, 1, 35);
        "TIG Remit-to Bank County" := VendorBankAccount.County;
        "TIG Remit-to Bank Post Code" := VendorBankAccount."Post Code";
        "TIG Remit-to Bank Country" := VendorBankAccount."Country/Region Code";
        "TIG Remit-to Bank BIC" := VendorBankAccount."SWIFT Code";
        "TIG Remit-to Bank Acc. No." := CopyStr(VendorBankAccount.GetBankAccountNo(), 1, MaxStrLen("TIG Remit-to Bank Acc. No."));
        "TIG Remit-to Bank Clearg Std." := VendorBankAccount."Bank Clearing Standard";
        "TIG Remit-to Bank Clearing" := VendorBankAccount."Bank Clearing Code";
        "TIG Remit-to Bank Transit No." := VendorBankAccount."Transit No.";
        "TIG Sender IBAN" := BankAccount.IBAN;
        "TIG Sender ACH Co ID" := BankAccount."SBC ACH Co ID";
        "TIG Remit-to Bank Code" := VendorBankAccount.Code;
        "TIG Sender ClrSysID Code" := GetClearingStandard(BankAccount."Bank Clearing Standard");
        "TIG Remit-to ClrSysID Code" := GetClearingStandard(VendorBankAccount."Bank Clearing Standard");
        "TIG Check Marketing Message" := BankAccount."EVM Check Marketing Message";
        //OnAfterSetVendorAsRecipient(Rec, Vendor, VendorBankAccount);
    end;

    local procedure GetClearingStandard(ClearingStandard: Text[50]): Code[10]
    var
        BankClearingStandard: Record "Bank Clearing Standard";
    begin
        BankClearingStandard.Reset();
        if not BankClearingStandard.Get(ClearingStandard) then
            exit('');

        exit(BankClearingStandard."TIG Clearing System ID Code");
    end;


}