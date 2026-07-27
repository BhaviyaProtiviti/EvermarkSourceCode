codeunit 50148 "SBC SO Update ODW Ship Date"
{


    procedure ImportODWfile()
    var
        SalesHeader: Record "Sales Header";
        FileName: Text;
        GetFile: InStream;
        SheetName: Text;
        TempExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        MaxRowNo: Integer;
        SOrderNo: Code[20];
        ShipDate: Date;


    begin
        UploadIntoStream('Import Excel File', '', 'Excel (.xlsx)|*.xlsx', FileName, GetFile);
        SheetName := TempExcelBuffer.SelectSheetsNameStream(GetFile);
        TempExcelBuffer.OpenBookStream(GetFile, SheetName);
        TempExcelBuffer.ReadSheet();



        begin
            RowNo := 0;
            MaxRowNo := 0;
            if TempExcelBuffer.FindLast() then begin
                MaxRowNo := TempExcelBuffer."Row No.";
            end;

            for RowNo := 3 to MaxRowNo do begin
                SOrderNo := CopyStr(GetValueAtCell(TempExcelBuffer, RowNo, 11), 5, 15);
                Evaluate(Shipdate, GetValueAtCell(TempExcelBuffer, RowNo, 17));
                UpdateSalesHeader(SalesHeader, SOrderNo, ShipDate);

            end;
        end;

    end;


    local procedure UpdateSalesHeader(var SalesHeader: Record "Sales Header"; SOrderNo: Code[20]; ShipDate: Date)
    var
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        Released: Boolean;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", SOrderNo);
        If SalesHeader.FindFirst() then begin
            IF (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then begin
                Released := SalesHeader.Status = SalesHeader.Status::Released;
                if Released then
                    ReleaseSalesDoc.Reopen(SalesHeader);
                SalesHeader.Validate("Shipment Date", ShipDate);
                SalesHeader."SBC ODW Update Ship Date" := true;
                SalesHeader.Modify();
            end;
            if released then
                ReleaseSalesDoc.Run(SalesHeader);
        end;
    end;




    local procedure GetValueAtCell(var TempExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, ColumnNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;


























    /*
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;

    trigger OnRun()
    begin
        // ReadExcel();
    end;


    procedure ImportODWPlannedShipDate(var TempExcelBuffer: Record "Excel Buffer" temporary; SalesOrderNo: Code[20]; MaxRowNo: Integer): Boolean
    var
        SalesHeader: Record "Sales Header";
        RowNo: Integer;
        LineNo: Integer;
        GetDate: Text[2];
        SOrderNo: Code[20];
        ShipDate: Date;

    begin
        for RowNo := 3 to MaxRowNo do begin
            SOrderNo := CopyStr(GetValueAtCell(TempExcelBuffer, RowNo, 11), 5, 15);
            Evaluate(Shipdate, GetValueAtCell(TempExcelBuffer, RowNo, 17));
            UpdateSalesHeader(SalesHeader, SOrderNo, ShipDate);

        end;
    end;


    local procedure UpdateSalesHeader(var SalesHeader: Record "Sales Header"; SOrderNo: Code[20]; ShipDate: Date)
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", SOrderNo);
        If SalesHeader.FindFirst() then begin
            SalesHeader.Validate("Shipment Date", ShipDate);
            SalesHeader.Modify();
        end;
    end;



    local procedure GetValueAtCell(var TempExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, ColumnNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;



    local procedure EvaluateDate(var TempExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer): Date
    var
        DateTxt: Text;
        DateVar: Date;
    begin
        Datetxt := GetValueAtCell(TempExcelBuffer, RowNo, ColumnNo);
        Evaluate(DateVar, DateTxt);
        exit(DateVar);
    end;

    local procedure ReadODWExcelFile(Instream: InStream; SalesOrderSource: Enum "SBC Sales Order Source"; FileName: Text; FileExt: Text)
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        SalesOrderType: Enum "SBC Sales Order Source";
        SalesOrderNo: Code[20];
        SheetName: Text;
        MaxRowNo: Integer;
        HasLineErrors: Boolean;
    begin
        TempExcelBuffer.GetSheetsNameListFromStream(Instream, TempNameValueBuffer);

        TempNameValueBuffer.Reset();
        TempNameValueBuffer.Ascending(false);
        if TempNameValueBuffer.FindSet() then
            repeat
                SalesOrderNoNo := CreateImportHeader(ContractSource, ContractType, FileName);
                HasLineErrors := importMenashaData(ContractType, Instream, ImportDocNo, SheetName, MaxRowNo);
                AttachDocument(ImportDocNo, ContractSource, ContractType, Instream, FileName, FileExt, HasLineErrors);
                        end;
            until TempNameValueBuffer.Next() = 0;
    end;
    */
}


