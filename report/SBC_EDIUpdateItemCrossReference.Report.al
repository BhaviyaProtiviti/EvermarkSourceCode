report 50102 "SBC Update EDI Item References"
{
    Caption = 'SBC Update EDI Item References';
    ProcessingOnly = true;
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.") where("SBC Needs EDI 832 Update" = filter(true));

            trigger OnAfterGetRecord()
            begin
                EDITradePartner.Reset();
                EDITradePartner.SetRange("SBC Item Master Sync.", true);
                if EDITradePartner.FindSet() then
                    repeat
                        EDIItemReference.Reset();
                        EDIItemReference.SetRange("Trade Partner No.", EDITradePartner."No.");
                        EDIItemReference.SetRange("Item No.", Item."No.");
                        if EDIItemReference.FindFirst() then begin
                            EDIItemReference."Update Price Catalog" := EDIItemReference."Update Price Catalog"::Add;
                            EDIItemReference.modify(false);
                        end else begin
                            EDIItemReference.Reset();
                            EDIItemReference.Init();
                            EDIItemReference."Trade Partner No." := EDITradePartner."No.";
                            EDIItemReference."Partner Item No." := Item."No.";
                            EDIItemReference."Item No." := Item."No.";
                            EDIItemReference."Update Price Catalog" := EDIItemReference."Update Price Catalog"::Add;
                            EDIItemReference.Insert();
                        end;
                    until EDITradePartner.next() = 0;
                Item2.get(Item."No.");
                Item2."SBC Needs EDI 832 Update" := false;
                Item2.modify(false);
            end;

            trigger OnPostDataItem()
            begin
            end;

            trigger OnPreDataItem()
            begin
            end;
        }
    }


    trigger OnPreReport()
    begin
        IF GUIALLOWED THEN
            Wind.OPEN('@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
    end;

    trigger OnPostReport()
    begin
        IF GUIALLOWED THEN
            Wind.CLOSE();
    end;

    var
        Item2: Record Item;
        EDITradePartner: Record "LAX EDI Trade Partner";
        EDIItemReference: Record "LAX EDI Trade Partner Item";
        Wind: Dialog;
}

