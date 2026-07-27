tableextension 50352 "SBC CA Sales Import Customer" extends Customer
{
    fields
    {
        field(50350; "SBC CA Import Cust."; Boolean)
        {
            Caption = 'SBC Default CA Import Customer';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if not "SBC CA Import Cust." then
                    exit;

                Customer.SetRange("SBC CA Import Cust.", true);
                Customer.SetFilter("No.", '<>%1', Rec."No.");
                Customer.ModifyAll("SBC CA Import Cust.", false);
            end;
        }
    }
}
