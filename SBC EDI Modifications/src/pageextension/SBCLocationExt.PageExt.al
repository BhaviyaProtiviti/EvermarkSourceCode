pageextension 50169 "SBC Location Ext" extends "Location Card"
{
    layout
    {
        addafter(Name)
        {
            field("SBC Physical Warehouse"; Rec."SBC Physical Warehouse")
            {
                ApplicationArea = All;
                Caption = 'Physical Warehouse';
                ToolTip = 'Physical Warehouse associated with the location.';
                Editable = true;
                TableRelation = "Location"."Code";

            }
        }

    }

}
