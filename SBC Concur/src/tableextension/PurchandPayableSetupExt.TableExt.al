tableextension 50121 "PurchandPayableSetup-Ext" extends "Purchases & Payables Setup"
{
    fields
    {

        field(50100; "American Express Vendor No."; Code[20])
        {
            Caption = 'American Express Vendor No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }

        field(50110; "Visa Vendor No."; Code[20])
        {
            Caption = 'Visa/Company Paid Vendor No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }
        field(50111; "SBC AmEx Pmt Jnl Batch Name"; Code[10])
        {
            Caption = 'SBC AmEx Payment Journal Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch".Name where("Template Type" = const(Payments));
        }
        field(50112; "SBC AmEx Offsetting Account No"; Code[10])
        {
            Caption = 'SBC AmEx Offsetting Account No.';
            DataClassification = CustomerContent;
            TableRelation = "Bank Account";
        }
    }

    var
        // CFBSText001Err: Label 'ENU=%1 does not appear to end with a file name.', comment = 'just an error %1';
        // CFBSText002Err: Label 'ENU=Is %1 missing the file extension?', comment = 'just an error %1';
        CFBSText003Err: Label 'ENU=You should not enter a period in this field.', comment = 'just an error %1';

    procedure CheckPath(var CheckString: Text)
    var
        DirLength: Integer;
    begin
        //001 Start
        DirLength := STRLEN(CheckString);
        if (DirLength <> 0) then
            if (COPYSTR(CheckString, DirLength, 1) <> '\') then
                CheckString := CheckString + '\';

        if STRPOS(CheckString, '.') <> 0 then
            ERROR(CFBSText003Err);
        //001 End
    end;

    // local procedure CheckFileName(CheckString: Text[100])
    // var
    //     DirLength: Integer;
    //     CheckName: Text[100];
    // begin
    //     //001 Start
    //     DirLength := STRLEN(CheckString);
    //     if (DirLength <> 0) then
    //         if (COPYSTR(CheckString, DirLength, 1) = '\') then
    //             ERROR(STRSUBSTNO(CFBSText001Err, CheckString));

    //     CheckName := CheckString;
    //     if STRPOS(CheckName, '\') <> 0 then
    //         repeat
    //             CheckName := COPYSTR(CheckName, STRPOS(CheckName, '\') + 1);
    //         until STRPOS(CheckName, '\') = 0;

    //     if STRPOS(CheckString, '.') = 0 then
    //         ERROR(STRSUBSTNO(CFBSText002Err, CheckName));
    //     //001 end
    // end;
}