pageextension 50008 "SBC Main Location List" extends "Location List"
{
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
