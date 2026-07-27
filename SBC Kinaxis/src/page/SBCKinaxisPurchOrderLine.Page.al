page 50147 "SBC Kinaxis Purch Order Line"
{
    APIGroup = 'kinaxis';
    APIPublisher = 'tigunia';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'sbcKinaxisPurchOrderLine';
    DelayedInsert = true;
    editable = true;
    EntityName = 'tigPurchOrderLine';
    EntitySetName = 'tigPurchOrderLines';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Purchase Line";
    SourceTableView = where("Document Type" = const(Order));
    // PageType = List;
    // UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(vendorNo; Rec."Buy-from Vendor No.")
                {
                    Caption = 'Buy-from Vendor No.';
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type';
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(itemno; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                }
                field(quantity; TotalQuantity)
                {
                    Caption = 'Quantity';
                    trigger OnValidate()
                    begin
                        Rec."Quantity" := TotalQuantity;
                    end;
                }
                field(qtyToReceive; Rec."Qty. to Receive")
                {
                    Caption = 'Qty to Receive';
                }
                field(expectedShipDate; ExpectShipDate)
                {
                    Caption = 'Expected Ship Date';

                    trigger OnValidate()
                    begin
                        //avoid validating the date and updating the Promised Receipt Date
                        Rec."EVM Expected Ship Date" := ExpectShipDate;
                    end;
                }
                field(dueDate; Rec."Promised Receipt Date")
                {
                    Caption = 'Promised Receipt Date';
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                }
                field(quantityReceived; Rec."Quantity Received")
                {
                    Caption = 'Quantity Received';
                    Editable = false;
                }
                field(outstandingQuantity; Rec."Outstanding Quantity")
                {
                    Caption = 'Outstanding Quantity';
                    Editable = false;
                }
                field(plannedReceiptDate; Rec."Planned Receipt Date")
                {
                    Caption = 'Planned Receipt Date';
                }
                field(requestedReceiptDate; Rec."Requested Receipt Date")
                {
                    Caption = 'Requested Receipt Date';
                }
                field(evmDeliveryDate; Rec."EVM Delivery Date")
                {
                    Caption = 'Delivery Date';
                }
                field(evmOriginalRequestedReceiptDate; Rec."EVM Orignl. Req. Recpt. Date")
                {
                    Caption = 'Original Requested Receipt Date';
                }
            }
        }
    }

    var
        KinaxisInternalHdlr: Codeunit "SBC Kinaxis Internal Hdlr";
        KinaxisReleaseReopenPO: Codeunit "SBC Kinaxis Release_Reopen PO";
        TotalQuantity: Decimal;
        ExpectShipDate: Date;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        clear(TotalQuantity);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        PopulateVars();
    end;

    trigger OnAfterGetRecord()
    begin
        PopulateVars();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        KinaxisInternalHdlr.Kinaxis_OnInsert(Rec);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        KinaxisReleaseReopenPO.Kinaxis_ReopenPurchaseOrder(Rec);
        KinaxisInternalHdlr.Kinaxis_OnModify(Rec, xRec);
    end;

    local procedure PopulateVars()
    begin
        TotalQuantity := Rec."Quantity";
        ExpectShipDate := Rec."EVM Expected Ship Date";
    end;
}
