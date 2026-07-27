page 50144 "SBC Kinaxis Trans Order Lines"
{
    APIGroup = 'kinaxis';
    APIPublisher = 'tigunia';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'kinaxisTransOrderLines';
    DelayedInsert = true;
    EntityName = 'tigTransferLine';
    EntitySetName = 'tigTransferLines';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Transfer Line";
    // pagetype = List;
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
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(transferToCode; Rec."Transfer-to Code")
                {
                    Caption = 'Transfer-to Code';
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.';
                }
                field(quantity; LineQuantity)
                {
                    Caption = 'Quantity';

                    trigger OnValidate()
                    begin
                        Rec."SBC Override Exact Qty." := true;
                        Rec.Validate(Quantity, LineQuantity);
                    end;
                }
                field(dueDate; Rec."Receipt Date")
                {
                    Caption = 'Due Date';
                }
                field(qtyToReceive; Rec."Qty. to Receive")
                {
                    Caption = 'Qty. to Receive';
                }
                field(quantityReceived; Rec."Quantity Received")
                {
                    Caption = 'Quantity Received';
                    Editable = false;
                }
            }
        }
    }

    var
        KinaxisInternalHdlr: Codeunit "SBC Kinaxis Internal Hdlr";
        LineQuantity: Decimal;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        LineQuantity := 0;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        LineQuantity := Rec.Quantity;
    end;

    trigger OnAfterGetRecord()
    begin
        LineQuantity := Rec.Quantity;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        KinaxisInternalHdlr.Kinaxis_OnInsert(Rec);
    end;
}
