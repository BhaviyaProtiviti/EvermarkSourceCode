pageextension 50603 "EVM Payment Journal" extends "Payment Journal"
{
    layout
    {
        addafter("Payment Method Code")
        {
            field("EVM Payment Purpose Code"; Rec."EVM Payment Purpose Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Payment Purpose Code for the payment. Only applies to payments to certain countries.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    PaymentPurpose: Record "EVM Payment Purpose";
                    PaymentPurposes: Page "EVM Payment Purposes";
                begin
                    PaymentPurposes.LookupMode(true);
                    if PaymentPurposes.RunModal() = Action::LookupOK then begin
                        PaymentPurposes.GetRecord(PaymentPurpose);
                        Text := PaymentPurpose."Payment Purpose Code";
                        exit(true);
                    end;

                    exit(false);
                end;
            }
        }
    }
}