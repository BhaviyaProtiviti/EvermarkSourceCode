page 50146 "SBC Kinaxis Purchase Order"
{
    APIGroup = 'kinaxis';
    APIPublisher = 'tigunia';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'sbcKinaxisPurchaseOrder';
    DelayedInsert = true;
    EntityName = 'tigPurchaseOrder';
    EntitySetName = 'tigPurchaseOrders';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Purchase Header";
    SourceTableView = where("Document Type" = filter(Order));

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
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(buyFromVendorNo; Rec."Buy-from Vendor No.")
                {
                    Caption = 'Buy-from Vendor No.';
                }
                field(toSite; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(yourReference; Rec."Your Reference")
                {
                    Caption = 'Your Reference';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
                field(sbcKinaxisPlannerName; Rec."SBC Kinaxis Planner Name")
                {
                    Caption = 'SBC Kinaxis Planner Name';
                }
                part(purchOrderLines; "SBC Kinaxis Purch Order Line")
                {
                    Caption = 'lines';
                    EntityName = 'tigPurchOrderLine';
                    EntitySetName = 'tigPurchOrderLines';
                    SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                }
            }
        }
    }

    var
        KinaxisInternalHdlr: Codeunit "SBC Kinaxis Internal Hdlr";
        LocationCodeToUse: Code[10];

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        KinaxisInternalHdlr.Kinaxis_OnInsert(Rec);

        LocationCodeToUse := Rec."Location Code";
        exit(SetLocationCode());
    end;

    local procedure SetLocationCode(): Boolean
    begin
        if LocationCodeToUse <> '' then begin
            Rec.Insert(true);
            Rec.Validate("Location Code", LocationCodeToUse);
            Rec.Modify(true);
            exit(false);
        end;
        exit(true);
    end;
}