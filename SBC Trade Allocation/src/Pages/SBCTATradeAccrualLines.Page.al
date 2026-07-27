/// <summary>
/// Page SBCTA Trade Accrual Lines (ID 50207).
/// </summary>
page 50207 "SBCTA Trade Accrual Lines"
{
    Caption = 'Trade Accrual Lines';
    PageType = ListPart;
    SourceTable = "SBCTA Trade Accrual Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Editable = false;
                field("Trade Accrual No."; Rec."Trade Accrual No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the Trade Accrual that this Trade Accrual Line was produced for.';
                    Visible = false;
                    Editable = false;
                }
                field("Trade Accrual Type"; Rec."Calculation Basis")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the type of Trade Accrual that this Trade Accrual Line was produced for.';

                    Editable = false;
                }
                field("Trade Budget Code"; Rec."Trade Budget Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the Trade Budget and set of rates associated with it.';

                    Editable = false;
                }
                field("Trade Budget Rate Code"; Rec."Trade Budget Rate Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the particular Trade Budget Rate associated with the Trade Budget and further instructions on how it should be applied.';

                    Editable = false;
                }
                field("T/L Ledger Entry No."; Rec."T/L Ledger Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the Trade Budget Ledger Entry that this Trade Accrual Line was produced for.';

                    Editable = false;
                }
                field("Trade Accrual Line No."; Rec."Trade Accrual Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the line number of this Trade Accrual Line.';
                    Visible = false;
                }
                field("Over Budget"; Rec."Over Budget")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is a flag that indicates if the entry was over budget and either partially accrued or not accrued.';
                }
                field("T/L Amount"; Rec."T/L Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the trade ledger amount associated with the accrual.';
                }
                field("Accrued Amount"; Rec."Accrued Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the amount that was transferred to the accrual entry.';
                }
                field("Accrual Journal Template"; Rec."Accrual Journal Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the journal template that was used to create the accrual.';
                }
                field("Accrual Document No."; Rec."Accrual Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the date that the accrual was created.';
                }
                field("Accrual Journal Batch"; Rec."Accrual Journal Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the journal batch that was used to create the accrual.';
                }
                field("Accrual Journal Line"; Rec."Accrual Journal Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the journal line that was used to create the accrual.';
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = All;
                    ToolTip = 'This is a flag that indicates if the accrual was posted.';
                }
            }
        }
    }
}