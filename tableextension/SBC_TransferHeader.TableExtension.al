tableextension 50108 "SBC_Transfer Header" extends "Transfer Header"
{
    fields
    {
        field(50000; "SBC Production Order No."; Code[20])
        {
            Caption = 'SBC Production Order No.';
            DataClassification = CustomerContent;
            Description = 'This is the related Production Order No..';
        }
        field(50100; "SBC Max Weight Req."; Boolean)
        {
            Caption = 'SBC Max Weight Req.';
            DataClassification = CustomerContent;
            Description = 'Transfer Order has maximum weight required.';
        }
        field(50101; "SBC Max Weight Allowed"; Decimal)
        {
            Caption = 'SBC Max Weight Allowed';
            DataClassification = CustomerContent;
            Description = 'This is the maximum weight allowed, by location, that can be transferred.';
        }
        field(50102; "SBC Total Order Weight"; Decimal)
        {
            CalcFormula = sum("Transfer Line"."SBC Line Weight" where("Document No." = field("No.")));
            Caption = 'SBC Total Order Weight';
            Description = 'This is the total weight of the order.';
            FieldClass = FlowField;
        }
    }
}