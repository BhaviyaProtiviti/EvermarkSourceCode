page 50263 "SBCAPI Vena Item"
{
    APIGroup = 'vena';
    APIPublisher = 'tigunia';
    APIVersion = 'v2.0';
    InsertAllowed = true;
    ApplicationArea = All;
    ModifyAllowed = true;
    DeleteAllowed = true;
    Editable = true;
    Caption = 'sbcapiVenaItem';
    DelayedInsert = true;
    EntityName = 'sbcApiVenaItem';
    EntitySetName = 'sbcApiVenaItems';
    ODataKeyFields = No_;
    PageType = API;
    SourceTable = "SBC Vena Item";


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(no; Rec.No_)
                {
                    Caption = 'No_';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(prevStatus; Rec.PrevStatus)
                {
                    Caption = 'PrevStatus';
                }
                field(statusChanged; Rec.StatusChanged)
                {
                    Caption = 'StatusChanged';
                }
                field(brand; Rec.Brand)
                {
                    Caption = 'Brand';
                }
                field(category; Rec.Category)
                {
                    Caption = 'Category';
                }
                field(subCategory; Rec."Sub-Category")
                {
                    Caption = 'Sub-Category';
                }
                field(unitCost; Rec."Unit Cost")
                {
                    Caption = 'Unit Cost';
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                }
                field(edlpMSRP; Rec."EDLP MSRP")
                {
                    Caption = 'EDLP MSRP';
                }
                field(hLMSRP; Rec."H-L MSRP")
                {
                    Caption = 'H-L MSRP';
                }
                field(eachUPC; Rec."Each UPC")
                {
                    Caption = 'Each UPC';
                }
                field(caseUPC; Rec."Case UPC")
                {
                    Caption = 'Case UPC';
                }
                field(innerPackUPC; Rec."Inner Pack UPC")
                {
                    Caption = 'Inner Pack UPC';
                }
                field(gtin; Rec.GTIN)
                {
                    Caption = 'GTIN';
                }
                field(user; Rec.User)
                {
                    Caption = 'User';
                }
                field(subBrand; Rec."Sub Brand")
                {
                    Caption = 'Sub Brand';
                }
                field(form; Rec.Form)
                {
                    Caption = 'Form';
                }
                field(size; Rec.Size)
                {
                    Caption = 'Size';
                }
                field("variant"; Rec."Variant")
                {
                    Caption = 'Variant';
                }
                field(packType; Rec."Pack Type")
                {
                    Caption = 'Pack Type';
                }
                field(promoFamily; Rec."Promo Family")
                {
                    Caption = 'Promo Family';
                }
                field(sbcCreateDate; Rec."SBC Create Date")
                {
                    Caption = 'SBC Create Date';
                }
                field(countryRegionOfOriginCode; Rec."Country_Region of Origin Code")
                {
                    Caption = 'Country_Region of Origin Code';
                }
                field(tariffNo; Rec."Tariff No_")
                {
                    Caption = 'Tariff No_';
                }
                field(scheduleBCode; Rec."Schedule B Code")
                {
                    Caption = 'Schedule B Code';
                }
                field(osDisplay; Rec."OS/Display")
                {
                    Caption = 'OS/Display';
                }
                field(wercsID; Rec."WERCS ID")
                {
                    Caption = 'WERCS ID';
                }
                field(regulatoryClassification; Rec."Regulatory Classification")
                {
                    Caption = 'Regulatory Classification';
                }
                field(minimumOrderQuantity; Rec."Minimum Order Quantity")
                {
                    Caption = 'Minimum Order Quantity';
                }
                field(brandCategory; Rec."Brand Category")
                {
                    Caption = 'Brand Category';
                }
                field(country; Rec.Country)
                {
                    Caption = 'Country';
                }
                field(exportable; Rec.Exportable)
                {
                    Caption = 'Exportable';
                }
                field(shelfLifeDays; Rec."Shelf Life (Days)")
                {
                    Caption = 'Shelf Life (Days)';
                }
                field(hazardousMaterialCode; Rec."Hazardous Material Code")
                {
                    Caption = 'Hazardous Material Code';
                }
                field(abcCode; Rec."ABC Code")
                {
                    Caption = 'ABC Code';
                }
                field(runStrategy; Rec."Run Strategy")
                {
                    Caption = 'Run Strategy';
                }
                field(safetyStockDays; Rec."Safety Stock Days")
                {
                    Caption = 'Safety Stock Days';
                }
                field(leadTime; Rec."Lead Time")
                {
                    Caption = 'Lead Time';
                }
                field(msaItem; Rec."MSA Item")
                {
                    Caption = 'MSA Item';
                }
                field(previousItem; Rec."Previous Item")
                {
                    Caption = 'Previous Item';
                }
                field(productionPlant1; Rec."Production Plant 1")
                {
                    Caption = 'Production Plant 1';
                }
                field(productionPlant2; Rec."Production Plant 2")
                {
                    Caption = 'Production Plant 2';
                }
                field(productionPlant3; Rec."Production Plant 3")
                {
                    Caption = 'Production Plant 3';
                }
                field(productionLine1; Rec."Production Line 1")
                {
                    Caption = 'Production Line 1';
                }
                field(productionLine2; Rec."Production Line 2")
                {
                    Caption = 'Production Line 2';
                }
                field(ti; Rec.Ti)
                {
                    Caption = 'Ti';
                }
                field(hi; Rec.Hi)
                {
                    Caption = 'Hi';
                }
                field(uoMQtyICI; Rec."UoM Qty ICI")
                {
                    Caption = 'UoM Qty ICI';
                }
                field(uoMQtyEA; Rec."UoM Qty EA")
                {
                    Caption = 'UoM Qty EA';
                }
                field(uoMLengthEA; Rec."UoM Length EA")
                {
                    Caption = 'UoM Length EA';
                }
                field(uoMWidthEA; Rec."UoM Width EA")
                {
                    Caption = 'UoM Width EA';
                }
                field(uoMHeightEA; Rec."UoM Height EA")
                {
                    Caption = 'UoM Height EA';
                }
                field(uoMWeightEA; Rec."UoM Weight EA")
                {
                    Caption = 'UoM Weight EA';
                }
                field(uoMQtyCS; Rec."UoM Qty CS")
                {
                    Caption = 'UoM Qty CS';
                }
                field(uoMLengthCS; Rec."UoM Length CS")
                {
                    Caption = 'UoM Length CS';
                }
                field(uoMWidthCS; Rec."UoM Width CS")
                {
                    Caption = 'UoM Width CS';
                }
                field(uoMHeightCS; Rec."UoM Height CS")
                {
                    Caption = 'UoM Height CS';
                }
                field(uoMWeightCS; Rec."UoM Weight CS")
                {
                    Caption = 'UoM Weight CS';
                }
                field(uoMCubageCS; Rec."UoM Cubage CS")
                {
                    Caption = 'UoM Cubage CS';
                }
                field(uoMQtyLAY; Rec."UoM Qty LAY")
                {
                    Caption = 'UoM Qty LAY';
                }
                field(uoMLengthLAY; Rec."UoM Length LAY")
                {
                    Caption = 'UoM Length LAY';
                }
                field(uoMWidthLAY; Rec."UoM Width LAY")
                {
                    Caption = 'UoM Width LAY';
                }
                field(uoMHeightLAY; Rec."UoM Height LAY")
                {
                    Caption = 'UoM Height LAY';
                }
                field(uoMWeightLAY; Rec."UoM Weight LAY")
                {
                    Caption = 'UoM Weight LAY';
                }
                field(uoMQtyPAL; Rec."UoM Qty PAL")
                {
                    Caption = 'UoM Qty PAL';
                }
                field(uoMLengthPAL; Rec."UoM Length PAL")
                {
                    Caption = 'UoM Length PAL';
                }
                field(uoMWidthPAL; Rec."UoM Width PAL")
                {
                    Caption = 'UoM Width PAL';
                }
                field(uoMHeightPAL; Rec."UoM Height PAL")
                {
                    Caption = 'UoM Height PAL';
                }
                field(uoMWeightPAL; Rec."UoM Weight PAL")
                {
                    Caption = 'UoM Weight PAL';
                }
                field(uoMQtyINNER; Rec."UoM Qty INNER")
                {
                    Caption = 'UoM Qty INNER';
                }
                field(uoMLengthINNER; Rec."UoM Length INNER")
                {
                    Caption = 'UoM Length INNER';
                }
                field(uoMWidthINNER; Rec."UoM Width INNER")
                {
                    Caption = 'UoM Width INNER';
                }
                field(uoMHeightINNER; Rec."UoM Height INNER")
                {
                    Caption = 'UoM Height INNER';
                }
                field(uoMWeightINNER; Rec."UoM Weight INNER")
                {
                    Caption = 'UoM Weight INNER';
                }
            }
        }
    }
}