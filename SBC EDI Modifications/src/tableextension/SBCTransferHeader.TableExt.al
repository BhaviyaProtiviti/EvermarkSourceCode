tableextension 50166 "SBC Transfer Header Ext" extends "Transfer Header"
{
    fields
    {
        field(50105; "SBC Linked Purchase Order No."; Code[20])
        {
            Caption = 'Linked Purchase Order No.';
        }

        field(50106; "SBC Source Receipt No."; Code[20])
        {
            Caption = 'Source Receipt No.';
        }

        field(50107; "SBC EDI 944 Processed"; Boolean)
        {
            Caption = 'EDI 944 Processed';
        }
    }
}
