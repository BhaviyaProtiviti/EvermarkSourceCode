page 50145 "SBC Kinaxis Release Prod Order"
{
    APIGroup = 'kinaxis';
    APIPublisher = 'tigunia';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'kinaxisReleaseProdOrder';
    DelayedInsert = true;
    EntityName = 'tigReleasedProdOrder';
    EntitySetName = 'tigReleasedProdOrders';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Production Order";
    SourceTableView = where(Status = const(Released));
    // Pagetype = List;
    // UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    caption = 'id';
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(sourceType; Rec."Source Type")
                {
                    Caption = 'Source Type';
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Source No.';
                }
                field(quantity; OrderQty)
                {
                    Caption = 'Quantity';

                    trigger OnValidate()
                    begin
                        if Rec.Quantity <> 0 then
                            KinaxisRelease_ReopenPO.Kinaxis_ReopenPurchaseOrder(Rec."SBC Kinaxis Purchase Order No.");
                        Rec."Quantity" := OrderQty;
                    end;
                }
                field(sbcPlanner; Rec."SBC Kinaxis Planner Name")
                {
                    Caption = 'SBC Kinaxis Planner Name';
                }
                field(sbcKinaxisPurchaseOrderNo; Rec."SBC Kinaxis Purchase Order No.")
                {
                    Caption = 'SBC Kinaxis Purchase Order No.';
                }
                field(dueDate; DueDate)
                {
                    Caption = 'Due Date';

                    trigger OnValidate()
                    begin
                        Rec."Due Date" := DueDate;
                    end;
                }
                field(expectedShipDate; Rec."SBC Kinaxis Expected Ship Date")
                {
                    Caption = 'Expected Ship Date';
                }
                field(locationCode; LocationCode)
                {
                    Caption = 'Location Code';

                    trigger OnValidate()
                    begin
                        Rec."Location Code" := LocationCode;
                    end;
                }
            }
        }
    }

    var
        KinaxisInternalHdlr: Codeunit "SBC Kinaxis Internal Hdlr";
        KinaxisRelease_ReopenPO: Codeunit "SBC Kinaxis Release_Reopen PO";
        LocationCode: Code[10];
        OrderQty: Decimal;
        DueDate: Date;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        clear(OrderQty);
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
        KinaxisInternalHdlr.Kinaxis_OnModify(Rec, xRec);
    end;

    local procedure PopulateVars()
    begin
        OrderQty := Rec."Quantity";
        DueDate := Rec."Due Date";
        locationCode := Rec."Location Code";
    end;
}