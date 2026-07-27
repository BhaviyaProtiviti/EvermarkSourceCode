pageextension 50112 "SBC Consumption Journal" extends "Consumption Journal"
{
    layout
    {
        addafter("Shortcut Dimension 1 Code")
        {
            field("Lot No."; Rec."Lot No.")
            {
                ApplicationArea = All;
                Visible = true;

                trigger OnValidate()

                begin
                    CreateItemTrackingLines(Rec, true);
                    CurrPage.Update(false);
                end;

                trigger OnAssistEdit()
                begin
                    Rec.LookUpTrackingSummary("Item Tracking Type"::"Lot No.");
                end;
            }
        }
    }

    actions
    {
        addafter("&Print")
        {
            action("Update Item Tracking Lines")
            {
                ApplicationArea = ItemTracking;
                Caption = 'Update Item Tracking Lines';
                Image = RefreshLines;
                ToolTip = 'Update Item Tracking Lines based on the tracking information defined on the line.';

                trigger OnAction()
                var
                    ItemJournalLine: Record "Item Journal Line";
                begin
                    CurrPage.SaveRecord();
                    ItemJournalLine.Copy(Rec);
                    if ItemJournalLine.FindSet() then
                        repeat
                            CreateItemTrackingLines(ItemJournalLine, true);
                        until ItemJournalLine.Next() = 0;
                end;
            }
        }
    }

    internal procedure CreateItemTrackingLines(var Rec: Record "Item Journal Line"; UpdateTracking: Boolean)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.Copy(Rec);
        ItemJnlLineReserve.CreateItemTracking(ItemJournalLine);
        if UpdateTracking then
            UpdateItemTracking(ItemJournalLine);
    end;

    internal procedure UpdateItemTracking(var ItemJournalLine: Record "Item Journal Line")
    var
        TempItemJournalLine: Record "Item Journal Line" temporary;
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        SingleItemTrackingExists: Boolean;
    begin
        ItemJournalLine.Find();
        TempItemJournalLine := ItemJournalLine;

        if GetItemTracking(TempTrackingSpecification, ItemJournalLine) then
            if TempTrackingSpecification.Count() = 1 then begin
                SingleItemTrackingExists := true;
                ItemJournalLine.CopyTrackingFromSpec(TempTrackingSpecification);
                ItemJournalLine."Expiration Date" := TempTrackingSpecification."Expiration Date";
                ItemJournalLine."Warranty Date" := TempTrackingSpecification."Warranty Date";
            end;

        if not SingleItemTrackingExists then begin
            ItemJournalLine.ClearTracking();
            ItemJournalLine.ClearDates();
        end;

        if not ItemJournalLine.HasSameTracking(TempItemJournalLine) then
            ItemJournalLine.Modify();
    end;

    internal procedure GetItemTracking(var TempTrackingSpecification: Record "Tracking Specification" temporary; var Rec: Record "Item Journal Line"): Boolean
    var
        ReservationEntry: Record "Reservation Entry";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
    begin
        Rec.SetReservationFilters(ReservationEntry);
        ReservationEntry.ClearTrackingFilter();
        exit(ItemTrackingManagement.SumUpItemTracking(ReservationEntry, TempTrackingSpecification, false, true));
    end;

    var
        ItemJnlLineReserve: Codeunit "Item Jnl. Line-Reserve";

}