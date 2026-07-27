table 50355 "SBC Blind Receipt"
{
    Caption = 'SBC Blind Receipt';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "SBC Entry No."; Integer)
        {
            Caption = 'SBC Entry No.';
        }
        field(2; "SBC Purchase Order No."; Code[20])
        {
            Caption = 'SBC Purchase Order No.';

            trigger OnValidate()
            var
            begin
                clear("SBC Do Not Process");
                Clear("SBC Error Message");
                if not OrderExists() then begin
                    "SBC Do Not Process" := true;
                    "SBC Error Message" := CopyStr(GetLastErrorText(), 1, 500);
                end;
            end;
        }
        field(3; "SBC Supplier ID"; Text[250])
        {
            Caption = 'SBC Supplier ID';
        }
        field(4; "SBC Item No."; Code[30])
        {
            Caption = 'SBC Item No.';

            trigger OnValidate()
            var
                ItemUOM: Record "Item Unit of Measure";
            begin
                TestAllowPurchLineProcess();
                if ItemUOM.Get("SBC Item No.", GetCaseUOMCode()) then
                    Validate("SBC Qty Per UOM", ItemUOM."Qty. per Unit of Measure")
                else
                    Validate("SBC Qty Per UOM", 1);
            end;
        }
        field(5; "SBC BOL No."; Code[35])
        {
            Caption = 'SBC BOL No.';
        }
        field(6; "SBC Load ID"; Text[100])
        {
            Caption = 'SBC Load ID';
        }
        field(7; "SBC Lot No."; Code[20])
        {
            Caption = 'SBC Lot No.';

            trigger OnValidate()
            var
                LotTxt: Text[20];
            begin
                LotTxt := "SBC Lot No.";
                LotTxt := DelChr(LotTxt, '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-');
                if LotTxt <> '' then begin
                    "SBC Error Message" := 'Lot No. contains special characters';
                    "SBC Do Not Process" := true;
                end;
            end;
        }
        field(8; "SBC Case Qty"; Decimal)
        {
            Caption = 'SBC Case Qty';
            DecimalPlaces = 2;

            trigger OnValidate()
            begin
                PopulateQuantityBase();
            end;
        }
        field(9; "SBC Report Date"; Date)
        {
            Caption = 'SBC Report Date';
        }
        field(15; "SBC Processed"; Boolean)
        {
            Caption = 'SBC Processed';
        }
        field(16; "SBC Posted"; Boolean)
        {
            Caption = 'SBC Posted';
        }
        field(17; "SBC Do Not Process"; Boolean)
        {
            Caption = 'SBC Do Not Process';
        }
        field(20; "SBC Qty Per UOM"; Decimal)
        {
            Caption = 'SBC Qty Per UOM';
            DecimalPlaces = 2;

            trigger OnValidate()
            begin
                if "SBC Case Qty" <> 0 then
                    PopulateQuantityBase();
            end;
        }
        field(21; "SBC Quantity (Base)"; Decimal)
        {
            Caption = 'SBC Quantity (Base)';
            DecimalPlaces = 2;
        }
        field(100; "SBC Error Message"; Text[500])
        {
            Caption = 'SBC Error Message';
        }
    }
    keys
    {
        key(PK; "SBC Entry No.")
        {
            Clustered = true;
        }
        key(P2; "SBC Purchase Order No.")
        {
        }
        key(P3; "SBC Processed", "SBC Posted", "SBC Do Not Process", "SBC Item No.", "SBC BOL No.", "SBC Lot No.", "SBC Case Qty", "SBC Quantity (Base)")
        {
        }
    }

    trigger OnInsert()
    begin
        if "SBC Entry No." = 0 then
            "SBC Entry No." := GetLastEntryNo() + 1;

    end;

    local procedure GetLastEntryNo(): Integer
    var
        SBCBlindReceipt: Record "SBC Blind Receipt";
    begin
        if SBCBlindReceipt.FindLast() then
            exit(SBCBlindReceipt."SBC Entry No.");
    end;

    local procedure PopulateQuantityBase()
    begin
        TestField("SBC Case Qty");
        if "SBC Qty Per UOM" = 0 then
            "SBC Qty Per UOM" := 1;
        "SBC Quantity (Base)" := "SBC Case Qty" * "SBC Qty Per UOM";
    end;

    procedure GetCaseUOMCode(): Code[10]
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldValue: Text[10];
    begin
        RecRef.OPEN(Database::"Unit of Measure");
        if RecRef.FindSet() then
            repeat
                FieldRef := RecRef.Field(50040);
                FieldValue := FieldRef.Value;
                if UpperCase(FieldValue) = 'YES' then
                    exit(RecRef.Field(1).Value);
            until RecRef.Next() = 0;
    end;

    [TryFunction]
    local procedure OrderExists()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, "SBC Purchase Order No.");
    end;

    local procedure TestAllowPurchLineProcess()
    var
        PurchaseLine: Record "Purchase Line";
        NoLineLbl: Label 'Order %1 does not contain a line with Item No. %2.', Comment = '%1 = Order No., %2 = Item No.';
        IsRPOLineLbl: Label 'Order %1 line with Item No. %2 that is connected to a Production Order line and cannot be processed.', Comment = '%1 = Order No., %2 = Item No.';
    begin
        if "SBC Do Not Process" then
            exit;
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", "SBC Purchase Order No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetRange("No.", "SBC Item No.");
        if PurchaseLine.IsEmpty() then begin
            "SBC Do Not Process" := true;
            "SBC Error Message" := StrSubstNo(NoLineLbl, "SBC Purchase Order No.", "SBC Item No.");
        end else begin
            PurchaseLine.SetRange("Prod. Order No.", '');
            if PurchaseLine.IsEmpty() then begin
                "SBC Do Not Process" := true;
                "SBC Error Message" := StrSubstNo(IsRPOLineLbl, "SBC Purchase Order No.", "SBC Item No.");
            end;
        end;
    end;
}
