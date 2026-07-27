pageextension 50151 "SBC Item List Mod" extends "Item List"
{
    layout
    {
        addlast(Control1)
        {
            field("SBC Qty. per Sales UOM"; Rec."SBC Qty. per Sales UOM")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Qty. per Sales UOM field.';
            }
        }
    }

    // actions
    // {
    //     addafter(CopyItem)
    //     {
    //         action(test)
    //         {
    //             ApplicationArea = All;
    //             Caption = 'Test';

    //             trigger OnAction()
    //             var
    //                 SBCEDICreateItemJnlHelper: Codeunit "SBC EDI Create Item Jnl Helper";
    //                 TempItemJournalLine: Record "Item Journal Line" temporary;
    //                 availQty: Decimal;
    //                 // QtyOrdered: Decimal;
    //             begin
    //                 //reserved qty = 500
    //                 //ordered qty = 600
    //                 //total qty on hand = 700
    //                 //adjust inv = 300 ((total qty on hand - reserved qty) - ordered qty)
    //                 // QtyOrdered := 205;
    //                 TempItemJournalLine.init;
    //                 TempItemJournalLine."Journal Template Name" := 'ITEM';
    //                 TempItemJournalLine."Journal Batch Name" := '945_FIX';
    //                 TempItemJournalLine."Line No." := 10000;
    //                 TempItemJournalLine."Entry Type" := TempItemJournalLine."Entry Type"::"Positive Adjmt.";
    //                 TempItemJournalLine."Item No." := '68844639';
    //                 // TempItemJournalLine."Lot No." := '4330AA';
    //                 TempItemJournalLine.Quantity := 205;
    //                 TempItemJournalLine."Lot No." := '02095JU36';
    //                 TempItemJournalLine."Location Code" := 'ODW';
    //                 availQty := SBCEDICreateItemJnlHelper.FindQuantityAvailableByLot(TempItemJournalLine);
    //                 message(format(TempItemJournalLine.Quantity));
    //                 // message(format(availQty));
    //                 // if QtyOrdered < availQty then
    //                 //     message('0')
    //                 // else
    //                 //     if (availQty < 0) or (QtyOrdered - availQty = 0) then
    //                 //         Message(format(QtyOrdered))
    //                 //     else
    //                 //         Message(format(QtyOrdered - availQty));
    //             end;
    //         }
    //     }
    //     addafter(CopyItem_Promoted)
    //     {
    //         actionRef(Test_Promoted; Test)
    //         {
    //         }
    //     }
    // }
}
