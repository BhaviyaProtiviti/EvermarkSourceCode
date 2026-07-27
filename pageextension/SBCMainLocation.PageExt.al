pageextension 50007 "SBC Main Location" extends "Location Card"
{
    layout
    {
        addlast(General)
        {
            field("SBC Has Max Weight Req."; Rec."SBC Has Max Weight Req.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Has Max Weight Req. field.';
            }
            field("SBC Transfer Max Weight Allow"; Rec."SBC Transfer Max Weight Allow")
            {
                ApplicationArea = All;
                Editable = Rec."SBC Has Max Weight Req.";
            }
        }
    }
    actions
    {
        addafter("LAX Posted Packages - Action")
        {
            action(SBC_BrandCapacityByLocation)
            {
                applicationArea = All;
                Caption = 'SBC Brand Capacity by Location';
                Image = SetupList;
                ToolTip = 'View the SBC Brand Capacity by Location.';
                RunObject = page "SBC Brand Capacity by Location";
                RunPageLink = "SBC Location" = field(Code);
                RunPageMode = Edit;
            }
        }
        addafter("LAX Posted Packages - Action_Promoted")
        {
            actionref(SBC_BrandCapacityByLocation_Promoted; SBC_BrandCapacityByLocation)
            {                
            }
        }
    }
}
