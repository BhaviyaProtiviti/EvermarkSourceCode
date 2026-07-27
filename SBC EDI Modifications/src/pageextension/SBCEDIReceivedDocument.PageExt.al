pageextension 50153 "SBC EDI Received Document" extends "LAX EDI Receive Document"
{
    // actions
    // {
    //     addafter("&Document")
    //     {
    //         action(updateCreated)
    //         {
    //             ApplicationArea = All;
    //             Visible = true;

    //             trigger OnAction()
    //             begin
    //                 Rec."Sales Order Updated" := false;
    //                 Rec."Sales Invoice Created" := false;
    //                 Rec."Sales Order Posted" := false;
    //                 Rec.Modify(false);
    //             end;
    //         }
    //         action(CopyDoc)
    //         {
    //             ApplicationArea = All;

    //             trigger OnAction()
    //             var
    //                 testingcopyrecdoc: Report "testing copy rec. doc";
    //             begin
    //                 testingcopyrecdoc.RunModal();
    //             end;
    //         }
    //         action(deleteItemJnl)
    //         {
    //             Caption = 'delete journal EDI-INV20';
    //             ApplicationArea = All;

    //             trigger OnAction()
    //             var
    //                 ItemJournalLine: Record "Item Journal Line";
    //                 ReservMgt: Codeunit "Reservation Management";
    //             begin
    //                 ItemJournalLine.SetRange("Journal Template Name", 'ITEM');
    //                 ItemJournalLine.SetRange("Journal Batch Name", 'EDI-INV20');
    //                 if ItemJournalLine.FindSet(true) then
    //                     repeat

    //                         ReservMgt.SetReservSource(ItemJournalLine);
    //                         ReservMgt.SetItemTrackingHandling(1); // Allow Deletion
    //                         ReservMgt.DeleteReservEntries(true, 0);
    //                         ItemJournalLine.CalcFields("Reserved Qty. (Base)");
    //                         ItemJournalLine.Delete();
                            
    //                     until ItemJournalLine.Next() = 0;
    //             end;
    //         }
    //     }
    // }
}