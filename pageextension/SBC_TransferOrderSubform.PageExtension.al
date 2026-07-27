pageextension 50111 "SBC Transfer Order Subform" extends "Transfer Order Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("SBC Override Exact Qty."; Rec."SBC Override Exact Qty.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Override Pallet Rounding field.';
            }
            field("SBC Line Weight"; Rec."SBC Line Weight")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Line Weight field.';
                Editable = false;
            }
        }

        modify(Quantity)
        {
            ToolTip = 'Quantity will automatically be rounded up to the number of Cases that will make a full pallet quantity count for the item.';

            trigger OnAfterValidate()
            var
                TransferHeader: Record "Transfer Header";
                TransferLine: Record "Transfer Line";
                TransError: Text;
                TotalWeight: Decimal;
                MaxWeightErrLbl: label 'Total Line Weight %1 exceeds Max Weight Req. %2. Please add additional transfer line to a new Transfer Order.';
            begin
                TransferHeader.Reset();
                if (TransferHeader.Get(Rec."Document No.")) and (TransferHeader."SBC Max Weight Req.") then begin
                    TransferLine.SetRange("Document No.", Rec."Document No.");
                    TransferLine.CalcSums("SBC Line Weight");
                    TotalWeight := (TransferLine."SBC Line Weight" + Rec."SBC Line Weight") ;
                    if TotalWeight > TransferHeader."SBC Max Weight Allowed" then begin
                        TransError := StrSubstNo(MaxWeightErrLbl, TotalWeight, TransferHeader."SBC Max Weight Allowed");
                        Error(TransError);
                    end;
                end;
            end;
        }
    }
}