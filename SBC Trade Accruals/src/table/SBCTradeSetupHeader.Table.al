table 50700 SBCTradeSetupHeader
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Customer Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Posting Group".Code;
            Caption = 'Customer Group';

        }
        field(2; "Global Dimension 1"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
        }
    }

    keys
    {
        key(Key1; "Customer Group", "Global Dimension 1")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        TradeSetupLines: Record SBCTradeSetupLines;
    begin
        TradeSetupLines.SetRange("Customer Group", "Customer Group");
        TradeSetupLines.SetRange("Global Dimension 1", "Global Dimension 1");
        TradeSetupLines.DeleteAll();
    end;
}