/// <summary>
/// Page SBC Contract Mfg. Setup (ID 50250).
/// </summary>
page 50350 "SBC Contract Mfg. Setup"
{
    ApplicationArea = All;
    Caption = 'Contract Manufacturing Setup';
    SourceTable = "SBC Contract Mfg. Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("SBC No. Series"; Rec."SBC No. Series")
                {
                    ToolTip = 'Specifies the value of the Contract Mfg. Import No. Series field.';
                }
            }
            group(Menasha)
            {
                Caption = 'Menasha Inventory Adjustment';

                field("SBC Menasha Item Jnl. Template"; Rec."SBC Menasha Item Jnl. Template")
                {
                    ToolTip = 'Specifies the value of the Menasha Item Jnl. Template Name';
                    ShowMandatory = true;
                }
                field("SBC Menasha Item Jnl. Batch"; Rec."SBC Menasha Item Jnl. Batch")
                {
                    ToolTip = 'Specifies the value of the Menasha Item Jnl. Batch field.';
                    ShowMandatory = true;
                }
                field("SBC Menasha Item Jnl. Location"; Rec."SBC Menasha Item Jnl. Location")
                {
                    ToolTip = 'Specifies the value of the Menasha Item Jnl. Location field.';
                    ShowMandatory = true;
                }
            }
            group(WestRock)
            {
                Caption = 'WestRock Import';

                group(Inventory)
                {
                    Caption = 'Inventory';

                    field("SBC WestRock Item Jnl. Template"; Rec."SBC WestRock Item Jnl Template")
                    {
                        ToolTip = 'Specifies the value of the WestRock Item Jnl. Template Name';
                        ShowMandatory = true;
                    }
                    field("SBC WestRock Item Jnl. Batch"; Rec."SBC WestRock Item Jnl. Batch")
                    {
                        ToolTip = 'Specifies the value of the WestRock Item Jnl. Batch field.';
                        ShowMandatory = true;
                    }
                    field("SBC WestRock Item Jnl. Location"; Rec."SBC WestRock Item Jnl Location")
                    {
                        ToolTip = 'Specifies the value of the WestRock Item Jnl. Location field.';
                        ShowMandatory = true;
                    }
                }
                group(Consumption)
                {
                    Caption = 'Consumption';

                    field("SBC WR Consumption Location"; Rec."SBC WR Consumption Location")
                    {
                        ToolTip = 'Specifies the value of the WestRock Consumption Location field.';
                        ShowMandatory = true;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Import)
            {
                Caption = 'Manually Import Contract Mfg. File';
                Image = Import;
                ApplicationArea = All;

                trigger OnAction()
                var
                    ImportFileMgmt: Codeunit "SBC Import File Mgmt";
                begin
                    ImportFileMgmt.ImportExcelSheet();
                end;
            }
            action(deleteItemJnl)
            {
                Caption = 'delete journal MEN-INV';
                ApplicationArea = All;

                trigger OnAction()
                var
                    ItemJournalLine: Record "Item Journal Line";
                    ReservMgt: Codeunit "Reservation Management";
                begin
                    ItemJournalLine.SetRange("Journal Template Name", 'ITEM');
                    ItemJournalLine.SetRange("Journal Batch Name", 'MEN-INV');
                    if ItemJournalLine.FindSet(true) then
                        repeat

                            ReservMgt.SetReservSource(ItemJournalLine);
                            ReservMgt.SetItemTrackingHandling(1); // Allow Deletion
                            ReservMgt.DeleteReservEntries(true, 0);
                            ItemJournalLine.CalcFields("Reserved Qty. (Base)");
                            ItemJournalLine.Delete();

                        until ItemJournalLine.Next() = 0;
                end;
            }
        }

        area(Promoted)
        {
            group(Category_Category4)
            {
                Caption = 'Import Contract Mfg. File';

                actionref(Import_Promoted; Import)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}