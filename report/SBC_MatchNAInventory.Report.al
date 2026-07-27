// Author: Jong Yoon
// Task: ODW EDI 846 enhancement
// Creation Date: 1/15/2025
// Description: Processing only report to generate negative adjustment for ODW NA location item journal line based on ODW 846
// Last Modified:
// 01/20/2025 Add comments Jong Yoon

report 50105 "SBC Match NA Inventory"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = True;
    UseRequestPage = true;

    dataset
    {
    }
    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        "Check Item Ledger Entries"(); // Start
    end;

    local procedure "Check Item Ledger Entries"()
    begin
        // Get Document number and journal template from Inventory Setup
        InventorySetup.Get();
        InventorySetup.TestField("SBC Match Inventory Doc No."); // Test for empty field
        InventorySetup.TestField("SBC Match Invt Journal Templ"); // Test for empty field
        InventorySetup.TestField("SBC Match Invt Journal Batch "); // Test for empty field

        DocNo := NumberSeriesCodeUnit.GetNextNo(InventorySetup."SBC Match Inventory Doc No.", WorkDate(), true); // Get next Document number

        // Create Item journal lines for each ODW positive adjustment
        ItemLedgerEntry.SetFilter("Location Code", '%1', 'ODW-NA');
        ItemLedgerEntry.SetFilter("Entry Type", '%1', ItemLedgerEntry."Entry Type"::"Positive Adjmt.");
        ItemLedgerEntry.SetFilter("Remaining Quantity", '>%1', 0);
        if (StartDate <> 0D) AND (EndDate <> 0D) then begin
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);
        End
        else begin
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate('<-2D>', WorkDate()), WorkDate());
        end;
        if ItemLedgerEntry.FindFirst() then begin
            repeat
                "Create Negative Adjustment"();
            until ItemLedgerEntry.Next() = 0;
        end
    end;

    local procedure "Create Negative Adjustment"()
    var
        ItemJournalLine: Record "Item Journal Line";
        LastLineNo: Integer;
    begin
        // Get last line number
        ItemJournalLine.Reset();
        ItemJournalLine.SetFilter("Journal Template Name", '%1', "InventorySetup"."SBC Match Invt Journal Templ");
        ItemJournalLine.SetFilter("Journal Batch Name", '%1', "InventorySetup"."SBC Match Invt Journal Batch ");
        if ItemJournalLine.FindLast() then begin
            LastLineNo := ItemJournalLine."Line No."; // Assign last line number
        end
        else begin
            LastLineNo := 0; // IF journal bath is empty, start from 10000
        end;

        // Create item journal line
        Clear(ItemJournalLine);

        ItemJournalLine."Journal Template Name" := "InventorySetup"."SBC Match Invt Journal Templ";
        ItemJournalLine."Journal Batch Name" := "InventorySetup"."SBC Match Invt Journal Batch ";

        ItemJournalLine."Posting Date" := Today();
        ItemJournalLine."Entry Type" := ItemJournalLine."Entry Type"::"Negative Adjmt.";
        ItemJournalLine."Document No." := DocNo;
        ItemJournalLine."Line No." := LastLineNo + 10000;
        ItemJournalLine.Validate("Item No.", ItemLedgerEntry."Item No.");
        ItemJournalLine."Location Code" := 'ODW-NA';
        ItemJournalLine.Validate(Quantity, ItemLedgerEntry."Remaining Quantity");

        if not ItemJournalLine.Modify() then begin
            ItemJournalLine.Insert();
            "Insert Item Tracking Lines"(ItemJournalLine);
        end
    end;

    local procedure "Insert Item Tracking Lines"(ItemJournalLine: Record "Item Journal Line")
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        // Insert new item tracking line for each journal line
        Clear(ReservationEntry);

        ReservationEntry."Entry No." := ReservationEntry.GetLastEntryNo() + 1;
        ReservationEntry."Source ID" := "InventorySetup"."SBC Match Invt Journal Templ";
        ReservationEntry."Source Batch Name" := "InventorySetup"."SBC Match Invt Journal Batch ";
        ReservationEntry."Creation Date" := WorkDate();
        ReservationEntry."Source Ref. No." := ItemJournalLine."Line No.";
        ReservationEntry."Item No." := ItemJournalLine."Item No.";
        ReservationEntry."Lot No." := ItemLedgerEntry."Lot No.";
        ReservationEntry."Location Code" := ItemJournalLine."Location Code";
        ReservationEntry.Description := ItemJournalLine.Description;
        ReservationEntry.Positive := true;
        ReservationEntry.Validate("Quantity (Base)", -1 * (ItemJournalLine."Quantity (Base)"));
        ReservationEntry."Qty. per Unit of Measure" := ItemJournalLine."Qty. per Unit of Measure";
        ReservationEntry."Source Type" := Database::"Item Journal Line";
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"3";
        ReservationEntry."Created By" := UserId;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;

        ReservationEntry.Insert();
    end;

    // Global variables
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        DocNo: Code[20];
        NumberSeriesCodeUnit: Codeunit NoSeriesManagement;
        InventorySetup: Record "Inventory Setup";
        StartDate: Date;
        EndDate: Date;
}