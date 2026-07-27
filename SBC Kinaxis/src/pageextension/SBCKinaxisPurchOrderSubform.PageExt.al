pageextension 50363 "SBCKinaxis Purch Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        addafter("EVM Expected Ship Date")
        {
            field("EVM Delivery Date"; Rec."EVM Delivery Date")
            {
                ApplicationArea = All;
            }
            field("EVM Orignl. Req. Recpt. Date"; Rec."EVM Orignl. Req. Recpt. Date")
            {
                ApplicationArea = All;
            }
        }
    }
}