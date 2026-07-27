/// <summary>
/// TableExtension SBC Customer (ID 50041) extends Record Customer.
/// </summary>
tableextension 50041 "SBC Customer" extends Customer
{
    fields
    {
        field(50040; "SBC Emerson Customer No."; Code[20])
        {
            Caption = 'SBC Emerson Customer No.';
            DataClassification = CustomerContent;
            Description = 'The Emerson Customer No. for the Customer.';
        }
        field(50041; "SBC Use Bill-To Pricing"; Boolean)
        {
            Caption = 'Use Bill-To Pricing';
            DataClassification = CustomerContent;
            Description = 'Use Bill-To Pricing for the Customer.';
        }
        field(50042;"SBC Use Sell-To Posting";Boolean)
        {
            Caption = 'SBC Use Sell-To Posting';
            DataClassification = CustomerContent;
            Description = 'When this is set, When this Customer is the Sell-To on a Sales Document, the Gen. Business Posting Group of this customer will be used instead of the Gen. Business Posting Group of the Bill-To Customer.';
        }
        field(50043;"SBC Channel Detail";Text[50])
        {
            Caption = 'SBC Channel Detail';
            DataClassification = CustomerContent;
            Description = 'The Channel Detail for the Customer.';
        }
        field(50044;"SBC Account Lead";Code[20])
        {
            Caption = 'SBC Account Lead';
            DataClassification = CustomerContent;
            Description = 'The Account Lead for the Customer. Works under the Salesperson.';
            TableRelation = "Salesperson/Purchaser".Code;
        }
    }
}
