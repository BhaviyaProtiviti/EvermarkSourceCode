codeunit 50155 "SBC Cut Short Lines"
{
    #region createSalesCutLines

    Permissions = tabledata "SBC Sales Order Cut Lines" = rimd;
    TableNo = "SBC Sales Order Cut Lines";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure CreateCutSalesLines(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; var HideProgressWindow: Boolean; PreviewMode: Boolean; CommitIsSuppressed: Boolean)
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        SalesOrderCutLines: Record "SBC Sales Order Cut Lines";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        Released: Boolean;
        EntryNoCheck: Integer;
    begin
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit;

        if not Customer."SBC Auto Cancel Back Order" then
            exit;

        IF (not SalesHeader.Ship) or (SalesHeader."Document Type" <> SalesHeader."Document Type"::Order) then
            exit;

        IF SalesOrderCutLines.FindLast() then
            EntryNoCheck := SalesOrderCutLines."SBC Entry No."
        else
            EntryNoCheck := 0;

        IF (SalesHeader.Ship) or (SalesHeader."Document Type" <> SalesHeader."Document Type"::Order) then begin
            Released := SalesHeader.Status = SalesHeader.Status::Released;
            if Released then
                ReleaseSalesDoc.Reopen(SalesHeader);
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            if SalesLine.FindSet() then begin
                repeat
                    if SalesLine."Qty. to Ship" <> SalesLine.Quantity then begin
                        SalesLine.Validate("SBC Original Order Qty.", SalesLine.Quantity);
                        SalesLine.Validate(Quantity, SalesLine."Qty. to Ship");
                        SalesLine.Modify();
                        SalesOrderCutLines.Init();
                        EntryNoCheck += 1;
                        SalesOrderCutLines."SBC Entry No." := EntryNoCheck;
                        SalesOrderCutLines.Validate("SBC Order No.", SalesLine."Document No.");
                        SalesOrderCutLines."SBC Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
                        SalesOrderCutLines."SBC Line No." := SalesLine."Line No.";
                        SalesOrderCutLines."SBC No." := SalesLine."No.";
                        SalesOrderCutLines."SBC Description" := SalesLine.Description;
                        SalesOrderCutLines."SBC Order Quantity" := SalesLine."SBC Original Order Qty.";
                        SalesOrderCutLines."SBC Unit of Measure" := SalesLine."Unit of Measure";
                        SalesOrderCutLines."SBC Qty Shipped" := SalesLine."Qty. to Ship";
                        SalesOrderCutLines."SBC Qty Invoiced" := SalesLine."Qty. to Invoice";
                        SalesOrderCutLines."SBC Cut Quantity" := (SalesLine."SBC Original Order Qty." - SalesLine."Qty. to Ship");
                        SalesOrderCutLines.Insert();
                    end;
                until SalesLine.Next() = 0;
            end;
            if released then
                ReleaseSalesDoc.Run(SalesHeader);
        end;
    end;

    #endregion createSalesCutLines

    #region updateSalesCutLines
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterInsertInvoiceHeader', '', false, false)]
    local procedure UpdateCutSalesLines(var SalesHeader: Record "Sales Header"; var SalesInvHeader: Record "Sales Invoice Header")
    var
        SalesLine: Record "Sales Line";
        SalesOrderCutLines: Record "SBC Sales Order Cut Lines";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        SalesOrderCutLines.SetRange("SBC Order No.", SalesInvHeader."Order No.");
        if SalesOrderCutLines.FindSet() then begin
            repeat
                SalesOrderCutLines.Validate("SBC Invoice No.", SalesInvHeader."No.");
                SalesOrderCutLines.Validate("SBC Shipment Date", SalesInvHeader."Shipment Date");
                SalesOrderCutLines.Modify();
            until SalesOrderCutLines.Next() = 0;
        end;

    end;
    #endregion updateSalesCutLines

}
