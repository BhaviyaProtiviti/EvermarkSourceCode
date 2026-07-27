/// <summary>
/// Page STA Bracket Price Ledger (ID 50221).
/// </summary>
page 50221 "STA Bracket Price Preview"
{
    Caption = 'SBC STA Bracket Price Ledger Preview"';
    PageType = List;
    SourceTable = "STA Bracket Price Ledger";
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
                    Editable = false;
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the Posting Date of the G/L Entry that this entry is associated with.';
                    Editable = false;
                    Visible = true;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Customer Account No. used for the entry.';
                    Editable = false;
                    Visible = true;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the document number that this entry is associated with.';
                    Editable = false;
                    Visible = true;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the type of document that this entry is associated with.';
                    Editable = false;
                    Visible = true;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Line No. field.';
                    Editable = false;
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the Item number that this entry is associated with.';
                    Editable = false;
                    Visible = true;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field.';
                    Editable = false;
                    Visible = true;
                }
                field("Bracket Price Code"; Rec."Bracket Price Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the Bracket Price associated with this entry.';
                    Editable = false;
                    Visible = true;
                }
                field("Bracket List Price"; Rec."Bracket List Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the particular Bracket List Price associated with Customer and Item.';
                    Editable = false;
                    Visible = true;
                }
                field("Bracket Price"; Rec."Bracket Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the particular Bracket Price associated with Customer and Item.';
                    Editable = false;
                    Visible = true;
                }
                field("Bracket Amount"; Rec."Bracket Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the Bracket List Price less the Bracket Price';
                    Editable = false;
                    Visible = true;
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ERP Sales Amount (Actual) field.';
                    Editable = false;
                    Visible = false;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ERP Discount Amount field.';
                    Editable = false;
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.';
                    Editable = false;
                    Visible = true;
                }
                field("Shortcut Dimension 1 Name"; Rec."Shortcut Dimension 1 Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Name field.';
                    Editable = false;
                    Visible = true;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field.';
                    Editable = false;
                    Visible = true;
                }
                field("Shortcut Dimension 2 Name"; Rec."Shortcut Dimension 2 Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Name field.';
                    Editable = false;
                    Visible = true;
                }
                field("Value Entry No."; Rec."G/L Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the Value Entry that this entry is associated with. This will only be set for COGS entries.';
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }
}