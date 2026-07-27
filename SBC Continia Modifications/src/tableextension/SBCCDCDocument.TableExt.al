tableextension 50160 "SBC CDC Document" extends "CDC Document"
{
    fields
    {
        field(50160; "SBC Order No."; Text[250])
        {
            Caption = 'SBC Order No.';
            CalcFormula = lookup("CDC Document Value"."Value (Text)" where("Document No." = field("No."), "Is Value" = filter(true), Code = const('OURDOCNO'), "Line No." = const(0)));
            FieldClass = FlowField;
        }
        field(50161; "SBC Invoice No."; text[250])
        {
            Caption = 'SBC Invoice No.';
            CalcFormula = lookup("CDC Document Value"."Value (Text)" where("Document No." = field("No."), "Is Value" = filter(true), Code = const('DOCNO'), "Line No." = const(0)));
            FieldClass = FlowField;
        }
        field(50162; "SBC Invoice Date"; Date)
        {
            Caption = 'SBC Invoice Date';
            CalcFormula = lookup("CDC Document Value"."Value (Date)" where("Document No." = field("No."), "Is Value" = filter(true), Code = const('DOCDATE'), "Line No." = const(0)));
            FieldClass = FlowField;
        }
        field(50163; "SBC Amount Excl. Tax"; Decimal)
        {
            Caption = 'SBC Amount Excl. Tax';
            CalcFormula = lookup("CDC Document Value"."Value (Decimal)" where("Document No." = field("No."), "Is Value" = filter(true), Code = const('AMOUNTEXCLVAT'), "Line No." = const(0)));
            FieldClass = FlowField;
        }
        field(50165; "SBC Matching Email Sent Flag"; Boolean)
        {
            Caption = 'SBC Matching Email Sent Flag';
            DataClassification = CustomerContent;
        }
    }
}
