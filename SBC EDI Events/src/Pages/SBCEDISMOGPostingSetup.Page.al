/// <summary>
/// Page SBC EDI SMOG Posting Setup (ID 50143).
/// Card page for the single-record SBC EDI SMOG Posting Setup table.
/// </summary>
page 50148 "SBC EDI SMOG Posting Setup"
{
    ApplicationArea = All;
    Caption = 'SBC EDI SMOG Posting Setup';
    PageType = Card;
    SourceTable = "SBC EDI SMOG Posting Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("SMOG Gen. Bus. Posting Group"; Rec."SMOGGenBusPostingGroup")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Gen. Bus. Posting Group applied to the Sales Order when the EDI 850 document MSG segment contains the SMOG keyword (e.g. "SMOG ORDER"). Typically set to LIQUIDATION.';
                }
                field("Non-SMOG Gen. Bus. Posting Group"; Rec."Non-SMOGGenBusPostingGroup")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Gen. Bus. Posting Group applied to the Sales Order when the EDI 850 document MSG segment does NOT contain the SMOG keyword. Typically set to GENERAL.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
