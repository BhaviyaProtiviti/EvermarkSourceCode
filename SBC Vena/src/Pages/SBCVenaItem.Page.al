page 50264 "SBC Vena Item"
{
    ApplicationArea = All;
    Caption = 'SBC Vena Item';
    PageType = List;
    SourceTable = "SBC Vena Item";
    UsageCategory = Lists;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(No_; Rec.No_)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No_ field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field(PrevStatus; Rec.PrevStatus)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PrevStatus field.', Comment = '%';
                }
                field(StatusChanged; Rec.StatusChanged)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the StatusChanged field.', Comment = '%';
                }
                field(Brand; Rec.Brand)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Brand field.', Comment = '%';
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Category field.', Comment = '%';
                }
                field("Sub-Category"; Rec."Sub-Category")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sub-Category field.', Comment = '%';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Cost field.', Comment = '%';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field.', Comment = '%';
                }
                field("EDLP MSRP"; Rec."EDLP MSRP")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EDLP MSRP field.', Comment = '%';
                }
                field("H-L MSRP"; Rec."H-L MSRP")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the H-L MSRP field.', Comment = '%';
                }
                field("Each UPC"; Rec."Each UPC")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Each UPC field.', Comment = '%';
                }
                field("Case UPC"; Rec."Case UPC")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Case UPC field.', Comment = '%';
                }
                field("Inner Pack UPC"; Rec."Inner Pack UPC")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inner Pack UPC field.', Comment = '%';
                }
                field(GTIN; Rec.GTIN)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GTIN field.', Comment = '%';
                }
                field(User; Rec.User)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User field.', Comment = '%';
                }
                field("Sub Brand"; Rec."Sub Brand")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sub Brand field.', Comment = '%';
                }
                field(Form; Rec.Form)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Form field.', Comment = '%';
                }
                field(Size; Rec.Size)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Size field.', Comment = '%';
                }
                field("Variant"; Rec."Variant")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant field.', Comment = '%';
                }
                field("Pack Type"; Rec."Pack Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pack Type field.', Comment = '%';
                }
                field("Promo Family"; Rec."Promo Family")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promo Family field.', Comment = '%';
                }
                field("SBC Create Date"; Rec."SBC Create Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC Create Date field.', Comment = '%';
                }
                field("Country_Region of Origin Code"; Rec."Country_Region of Origin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country_Region of Origin Code field.', Comment = '%';
                }
                field("Tariff No_"; Rec."Tariff No_")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tariff No_ field.', Comment = '%';
                }
                field("Schedule B Code"; Rec."Schedule B Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Schedule B Code field.', Comment = '%';
                }
                field("OS/Display"; Rec."OS/Display")
                {
                    ApplicationArea = All;
                    ToolTip = 'This External Name is needed because the / is translated into a _ in SQL by BC if we allow the default field name to be used.';
                }
                field("WERCS ID"; Rec."WERCS ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the WERCS ID field.', Comment = '%';
                }
                field("Regulatory Classification"; Rec."Regulatory Classification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Regulatory Classification field.', Comment = '%';
                }
                field("Minimum Order Quantity"; Rec."Minimum Order Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Minimum Order Quantity field.', Comment = '%';
                }
                field("Brand Category"; Rec."Brand Category")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Brand Category field.', Comment = '%';
                }
                field(Country; Rec.Country)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country field.', Comment = '%';
                }
                field(Exportable; Rec.Exportable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Exportable field.', Comment = '%';
                }
                field("Shelf Life (Days)"; Rec."Shelf Life (Days)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shelf Life (Days) field.', Comment = '%';
                }
                field("Hazardous Material Code"; Rec."Hazardous Material Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hazardous Material Code field.', Comment = '%';
                }
                field("ABC Code"; Rec."ABC Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ABC Code field.', Comment = '%';
                }
                field("Run Strategy"; Rec."Run Strategy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Run Strategy field.', Comment = '%';
                }
                field("Safety Stock Days"; Rec."Safety Stock Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Safety Stock Days field.', Comment = '%';
                }
                field("Lead Time"; Rec."Lead Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lead Time field.', Comment = '%';
                }
                field("MSA Item"; Rec."MSA Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MSA Item field.', Comment = '%';
                }
                field("Previous Item"; Rec."Previous Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Previous Item field.', Comment = '%';
                }
                field("Production Plant 1"; Rec."Production Plant 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Plant 1 field.', Comment = '%';
                }
                field("Production Plant 2"; Rec."Production Plant 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Plant 2 field.', Comment = '%';
                }
                field("Production Plant 3"; Rec."Production Plant 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Plant 3 field.', Comment = '%';
                }
                field("Production Line 1"; Rec."Production Line 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Line 1 field.', Comment = '%';
                }
                field("Production Line 2"; Rec."Production Line 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Line 2 field.', Comment = '%';
                }
                field(Ti; Rec.Ti)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ti field.', Comment = '%';
                }
                field(Hi; Rec.Hi)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hi field.', Comment = '%';
                }
                field("UoM Qty ICI"; Rec."UoM Qty ICI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Qty ICI field.', Comment = '%';
                }
                field("UoM Qty EA"; Rec."UoM Qty EA")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Qty EA field.', Comment = '%';
                }
                field("UoM Length EA"; Rec."UoM Length EA")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Length EA field.', Comment = '%';
                }
                field("UoM Width EA"; Rec."UoM Width EA")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Width EA field.', Comment = '%';
                }
                field("UoM Height EA"; Rec."UoM Height EA")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Height EA field.', Comment = '%';
                }
                field("UoM Weight EA"; Rec."UoM Weight EA")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Weight EA field.', Comment = '%';
                }
                field("UoM Qty CS"; Rec."UoM Qty CS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Qty CS field.', Comment = '%';
                }
                field("UoM Length CS"; Rec."UoM Length CS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Length CS field.', Comment = '%';
                }
                field("UoM Width CS"; Rec."UoM Width CS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Width CS field.', Comment = '%';
                }
                field("UoM Height CS"; Rec."UoM Height CS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Height CS field.', Comment = '%';
                }
                field("UoM Weight CS"; Rec."UoM Weight CS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Weight CS field.', Comment = '%';
                }
                field("UoM Cubage CS"; Rec."UoM Cubage CS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Cubage CS field.', Comment = '%';
                }
                field("UoM Qty LAY"; Rec."UoM Qty LAY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Qty LAY field.', Comment = '%';
                }
                field("UoM Length LAY"; Rec."UoM Length LAY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Length LAY field.', Comment = '%';
                }
                field("UoM Width LAY"; Rec."UoM Width LAY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Width LAY field.', Comment = '%';
                }
                field("UoM Height LAY"; Rec."UoM Height LAY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Height LAY field.', Comment = '%';
                }
                field("UoM Weight LAY"; Rec."UoM Weight LAY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Weight LAY field.', Comment = '%';
                }
                field("UoM Qty PAL"; Rec."UoM Qty PAL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Qty PAL field.', Comment = '%';
                }
                field("UoM Length PAL"; Rec."UoM Length PAL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Length PAL field.', Comment = '%';
                }
                field("UoM Width PAL"; Rec."UoM Width PAL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Width PAL field.', Comment = '%';
                }
                field("UoM Height PAL"; Rec."UoM Height PAL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Height PAL field.', Comment = '%';
                }
                field("UoM Weight PAL"; Rec."UoM Weight PAL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Weight PAL field.', Comment = '%';
                }
                field("UoM Qty INNER"; Rec."UoM Qty INNER")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Qty INNER field.', Comment = '%';
                }
                field("UoM Length INNER"; Rec."UoM Length INNER")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Length INNER field.', Comment = '%';
                }
                field("UoM Width INNER"; Rec."UoM Width INNER")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Width INNER field.', Comment = '%';
                }
                field("UoM Height INNER"; Rec."UoM Height INNER")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Height INNER field.', Comment = '%';
                }
                field("UoM Weight INNER"; Rec."UoM Weight INNER")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the UoM Weight INNER field.', Comment = '%';
                }
            }
        }
    }
}