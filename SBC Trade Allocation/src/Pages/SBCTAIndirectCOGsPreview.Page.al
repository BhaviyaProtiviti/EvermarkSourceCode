/// <summary>
/// Page SBCTA Tr. Budget Ledger Entry (ID 50209).
/// </summary>
page 50215 "SBCTA Indirect COGs Preview"
{
    Caption = 'Indirect COGs Ledger Preview';
    PageType = List;
    SourceTable = "SBCTA Indirect COGS Ledger";
    AdditionalSearchTerms = 'SBCTA Indirect COGs Ledger,SBCTA Indirect COGs Ledger Entry';
    SourceTableTemporary = true;
    Editable = false;
    LinksAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the Posting Date of the G/L Entry that this entry is associated with.';
                }
                field("Trade Budget Code"; Rec."Trade Budget Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the Trade Budget and set of rates associated with it.';
                }
                field("Trade Budget Rate Code"; Rec."Trade Budget Rate Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the particular Trade Budget Rate associated with the Trade Budget and further instructions on how it should be applied.';
                }
                field("Trade Budget Amount"; Rec."Trade Budget Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the total amount of the Trade Budget that was used for this entry.';
                }
                field("Source Entry Amount"; Rec."Source Entry Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the Amount of the basis entry that was used when the rate has a type of percent. Amounts use the quantity.';
                }
                field("Value Entry Quantity"; Rec."Value Entry Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the quantity of the Value Entry that this entry is associated with.';
                }
                field("Calculation Basis"; Rec."Calculation Basis")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the basis that was used to calculate the amount of the Trade Budget that was used for this entry.';
                    Visible = false;
                }
                field("Calculation Method"; Rec."Calculation Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'The calculation method used to calculate the COGs for the trade budget rate code.';
                }
                field("Sales Amount (Actual)"; Rec."Sales Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Amount (Actual) field.';
                }
                field("Cost Amount (Actual)"; Rec."Cost Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cost Amount (Actual) field.';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Amount field.';
                }
                field("Group Type"; Rec."Group Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the type of Group that this Trade Ledger Entry was produced for.';
                }
                field("Group Code"; Rec."Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the Customer Posting Group that the Trade Budget Rate applies to.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the type of document that this entry is associated with.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the document number that this entry is associated with.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Line No. field.';
                }
                field("Value Entry No."; Rec."Value Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the Value Entry that this entry is associated with. This will only be set for COGS entries.';
                }
                field("G/L Entry No."; Rec."G/L Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the G/L Entry No. that this entry is associated with. This will only be set for A/R entries.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the Item number that this entry is associated with.';
                }

                field("Trade Accrual No."; Rec."Trade Accrual No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the Trade Accrual that this Trade Accrual Line was produced for.';
                }
                field("Trade Accrual Line No."; Rec."Trade Accrual Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the line number of this Trade Accrual Line.';
                }
                field("Accrued Amount"; Rec."Accrued Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the amount that was transferred to the accrual entry.';
                }

                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Account No. used for the entry.';
                }

                field("Over Budget"; Rec."Over Budget")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is a flag that indicates if the entry was over budget and either partially accrued or not accrued.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.';
                }
                field("Shortcut Dimension 1 Name"; Rec."Shortcut Dimension 1 Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Name field.';
                }

                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field.';
                }
                field("Shortcut Dimension 2 Name"; Rec."Shortcut Dimension 2 Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Name field.';
                }
            }
        }
    }
}