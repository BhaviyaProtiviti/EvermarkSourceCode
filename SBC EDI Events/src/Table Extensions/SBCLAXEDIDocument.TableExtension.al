/// <summary>
/// TableExtension SBC LAX EDI Document (ID 50080) extends Record LAX EDI Document.
/// </summary>
tableextension 50080 "SBC LAX EDI Document" extends "LAX EDI Document"
{
    fields
    {
        field(50080; "SBC Accept Lower Unit Price"; Boolean)
        {
            Caption = 'SBC Accept Lower EDI Unit Price';
            DataClassification = CustomerContent;
            Description = 'When this is set, a lower unit price on the EDI document will be accepted and set as the unit price on the sales line.';
        }
        field(50081; "SBC Variance Threshold"; Decimal)
        {
            Caption = 'SBC Variance Threshold';
            DataClassification = CustomerContent;
            Description = 'Total variance amount for the line will be ignored if it is below this amount.';
        }
        field(50082; "SBC Threshold Type"; Enum "SBC Threshold Type")
        {
            Caption = 'SBC Threshold Type';
            DataClassification = CustomerContent;
            Description = 'Type of threshold to use when comparing EDI and ERP unit prices.';
        }
        field(50083; "SBC Create Missing Ship-To"; Boolean)
        {
            Caption = 'SBC Create Missing Ship-To';
            DataClassification = CustomerContent;
            Description = 'When this is set, a missing ship-to address on the EDI document will be created as a new customer Ship-To.';
        }
        field(50084; "SBC Create Missing Customer"; Boolean)
        {
            Caption = 'SBC Create Missing Customer';
            DataClassification = CustomerContent;
            Description = 'When this is set, a missing Customer on the EDI document will be created as a new customer Customer.';
        }
        field(50085; "SBC Customer Template"; Code[20])
        {
            Caption = 'SBC Customer Template';
            DataClassification = CustomerContent;
            Description = 'The Customer Template that is used during Customer Creation.';
            TableRelation = "Customer Templ.".Code;
        }
        field(50086; "SBC Allow SO Update from 850"; Boolean)
        {
            Caption = 'SBC Allow SO Update from 850';
            DataClassification = CustomerContent;
            Description = 'When this is set, an existing Sales Order that has not been shipped can be updated from a new version of an existing 850 EDI document.';
            trigger OnValidate()
            begin
                GlobalSBCEDI850Helper.CreateEDI851(Rec);
            end;
        }
        field(50087; "SBC SMOG Enabled"; Boolean)
        {
            Caption = 'SBC SMOG Enabled';
            DataClassification = CustomerContent;
            Description = 'When this is set, the EDI document will be checked for SMOG order information in the MSG Segment.';
        }
    }
    var
        GlobalSBCEDI850Helper: Codeunit "SBCEDI 850 Helper";
}