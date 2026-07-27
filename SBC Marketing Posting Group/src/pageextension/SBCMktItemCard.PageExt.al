pageextension 50141 "SBC Mkt Item Card" extends "Item Card"
{
    layout
    {
        modify("Gen. Prod. Posting Group")
        {
            trigger OnAfterValidate()
            begin
                if Rec."SBC Marketing Posting Group" = Rec."Gen. Prod. Posting Group" then
                    Error('The Gen. Prod. Posting Group and the SBC Marketing Posting Group must not be the same. Please update the field accordingly.');
            end;
        }
        addafter(ForeignTrade)
        {
            group("SBC Marketing")
            {
                field("SBC Has Marketing Display"; Rec."SBC Has Marketing Display")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Has Marketing Display field.';
                }
                field("SBC Marketing Posting Group"; Rec."SBC Marketing Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Marketing Posting Group field.';
                    Editable = Rec."SBC Has Marketing Display";

                    trigger OnValidate()
                    begin
                        if Rec."SBC Marketing Posting Group" = Rec."Gen. Prod. Posting Group" then
                            Error('The Gen. Prod. Posting Group and the SBC Marketing Posting Group must not be the same. Please update the field accordingly.');
                    end;
                }
            }
        }
    }
}
