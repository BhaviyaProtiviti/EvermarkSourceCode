pageextension 50167 "SBC Posted Purchase Receipts" extends "Posted Purchase Receipts"
{
    layout
    {
        addafter("No.")
        {
            field(VendorShipmentNo; Rec."Vendor Shipment No.")
            {
                ApplicationArea = All;
                ToolTip = 'Displays the Vendor Shipment No. (EDI Bill of Lading Number) from the related Purchase Order.';
            }

            field("LAX EDI Update Int. Doc. No."; Rec."LAX EDI Update Int. Doc. No.")
            {
                ApplicationArea = All;
                Caption = 'EDI Internal Doc No.';
                ToolTip = 'Displays the EDI Internal Document No. from the LAX EDI Receive Document Header related to this Purchase Receipt.';
                trigger OnDrillDown()
                var
                    LAXEDIReceiveDocHdr: Record "LAX EDI Receive Document Hdr.";
                begin
                    if Rec."LAX EDI Update Int. Doc. No." = '' then
                        exit;

                    LAXEDIReceiveDocHdr.Reset();

                    LAXEDIReceiveDocHdr.SetRange("Internal Doc. No.", Rec."LAX EDI Update Int. Doc. No.");
                    if LAXEDIReceiveDocHdr.FindFirst() then
                        Page.Run(Page::"LAX EDI Receive Document List", LAXEDIReceiveDocHdr)
                    else
                        Message('Unable to locate the related Lanham EDI Receive Document for Internal Document No. %1.\' +
                                '\The posted purchase receipt still references this EDI transaction, but no matching record exists in the EDI receive document table.' +
                                '\This may indicate the original EDI document was deleted, archived, or removed during data cleanup.',
                                Rec."LAX EDI Update Int. Doc. No.");
                end;
            }
            field(UserId; Rec."User ID")
            {
                ApplicationArea = All;
                ToolTip = 'Displays the User ID of the person who created the Purchase Receipt.';
            }
        }
    }

}
