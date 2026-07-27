/// <summary>
/// PageExtension SBC Inventory Setup (ID 50102) extends Record Inventory Setup.
/// </summary>
pageextension 50102 "SBC Inventory Setup" extends "Inventory Setup"
{
    layout
    {
        addafter("Copy Item Descr. to Entries")
        {
            field("SBC Layer Unit of Measure"; Rec."SBC Layer Unit of Measure")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("SBC Pallet Unit of Measure"; Rec."SBC Pallet Unit of Measure")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
        addlast(General)
        {
            field("SBC Parse Lot Code"; Rec."SBC Parse Lot Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Parse Lot Code field.', Comment = '%';
            }
            field("SBC Lot Code Date Format"; Rec."SBC Lot Code Date Format")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Lot Code Date Format field.', Comment = '%';
            }
            field("SBC Adjustment Batch"; Rec."SBC Adjustment Batch")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Adjustment Batch field.', Comment = '%';
            }
            field("SBC AdjmtItemJournalTemplate"; Rec."SBC AdjmtItemJournalTemplate")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Adjustment Item Journal Template field.', Comment = '%';
            }
        }
        addlast(Numbering)
        {
            field("SBC Matching Inventory Doc No."; Rec."SBC Match Inventory Doc No.")
            {
                // ODW EDI 846 enhancement
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Matching Invt Doc No. field.', Comment = '%';
            }
            field("SBC Match Invt Journal Templ"; Rec."SBC Match Invt Journal Templ")
            {
                // ODW EDI 846 enhancement
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Matching Invt Journal Template field.', Comment = '%';
            }
            field("SBC Match Invt Journal Batch "; Rec."SBC Match Invt Journal Batch ")
            {
                // ODW EDI 846 enhancement
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Matching Invt Journal Batch field.', Comment = '%';
            }
        }
    }
}