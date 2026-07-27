table 50100 "SBC Purch Order Transfer Link"
{
    Caption = 'Purchase Order Transfer Link';
    DataClassification = CustomerContent;


    fields
    {
        field(1; "Entry No."; Integer)
        { Caption = 'Entry No.'; }
        field(2; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Order));
        }
        field(3; "Purchase Receipt No."; Code[20])
        {
            Caption = 'Purchase Receipt No.';
            TableRelation = "Purch. Rcpt. Header"."No.";
        }
        field(4; "Transfer Order No."; Code[20])
        {
            Caption = 'Transfer Order No.';
            TableRelation = "Transfer Header"."No.";
        }
        field(5; "Created Date-Time"; DateTime)
        {
            Caption = 'Created Date-Time';
        }
        field(6; "Posted Transfer Shipment No."; Code[20])
        {
            Caption = 'Posted Transfer Shipment No.';
            TableRelation = "Transfer Shipment Header"."No.";
        }
        field(7; "Posted Transfer Receipt No."; Code[20])
        {
            Caption = 'Posted Transfer Receipt No.';
            TableRelation = "Transfer Receipt Header"."No.";
        }

    }

    keys
    {
        key(PK; "Entry No.")
        { Clustered = true; }
        key(UniqueReceipt; "Purchase Receipt No.") { Unique = true; }
        key(ByPO; "Purchase Order No.") { }
    }
}
