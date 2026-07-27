/// <summary>
/// Table SBC Vena Item (ID 50260). External table to the view Suave_Item_Master_Summary.
/// </summary>
table 50260 "SBC Vena Item"
{
    Caption = 'SBC Vena Item';
    DataClassification = CustomerContent;
    // TableType = ExternalSQL;
    // ExternalName = 'Suave_Item_Master_Summary'; 
    // ExternalSchema = 'dbo';


    fields
    {

        field(1; No_; Code[20])
        {
            Caption = 'No_';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; Status; Text[250])
        {
            Caption = 'Status';
        }
        field(4; PrevStatus; Text[1])
        {
            Caption = 'PrevStatus';
        }
        field(5; StatusChanged; Text[1])
        {
            Caption = 'StatusChanged';
        }
        field(6; Brand; Text[250])
        {
            Caption = 'Brand';
        }
        field(7; Category; Code[20])
        {
            Caption = 'Category';
        }
        field(8; "Sub-Category"; Code[250])
        {
            Caption = 'Sub-Category';
        }
        field(9; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(10; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }
        field(11; "EDLP MSRP"; Decimal)
        {
            Caption = 'EDLP MSRP';
        }
        field(12; "H-L MSRP"; Decimal)
        {
            Caption = 'H-L MSRP';
        }
        field(13; "Each UPC"; Text[20])
        {
            Caption = 'Each UPC';
        }
        field(14; "Case UPC"; Text[20])
        {
            Caption = 'Case UPC';
        }
        field(15; "Inner Pack UPC"; Text[20])
        {
            Caption = 'Inner Pack UPC';
        }
        field(16; GTIN; Text[14])
        {
            Caption = 'GTIN';
        }
        field(17; User; Text[250])
        {
            Caption = 'User';
        }
        field(18; "Sub Brand"; Text[250])
        {
            Caption = 'Sub Brand';
        }
        field(19; Form; Text[250])
        {
            Caption = 'Form';
        }
        field(20; Size; Text[250])
        {
            Caption = 'Size';
        }
        field(21; "Variant"; Text[250])
        {
            Caption = 'Variant';
        }
        field(22; "Pack Type"; Text[250])
        {
            Caption = 'Pack Type';
        }
        field(23; "Promo Family"; Text[250])
        {
            Caption = 'Promo Family';
        }
        field(24; "SBC Create Date"; Date)
        {
            Caption = 'SBC Create Date';
        }
        field(25; "Country_Region of Origin Code"; Code[10])
        {
            Caption = 'Country_Region of Origin Code';
        }
        field(26; "Tariff No_"; Code[20])
        {
            Caption = 'Tariff No_';
        }
        field(27; "Schedule B Code"; Text[250])
        {
            Caption = 'Schedule B Code';
        }
        field(28; "OS/Display"; Text[250])
        {
            Caption = 'OS/Display';
            // ExternalName = 'OS/Display';
            Description = 'This External Name is needed because the / is translated into a _ in SQL by BC if we allow the default field name to be used.';
        }
        field(29; "WERCS ID"; Text[250])
        {
            Caption = 'WERCS ID';
        }
        field(30; "Regulatory Classification"; Text[250])
        {
            Caption = 'Regulatory Classification';
        }
        field(31; "Minimum Order Quantity"; Decimal)
        {
            Caption = 'Minimum Order Quantity';
        }
        field(32; "Brand Category"; Code[20])
        {
            Caption = 'Brand Category';
        }
        field(33; Country; Code[10])
        {
            Caption = 'Country';
        }
        field(34; Exportable; Text[3])
        {
            Caption = 'Exportable';
        }
        field(35; "Shelf Life (Days)"; Integer)
        {
            Caption = 'Shelf Life (Days)';
        }
        field(36; "Hazardous Material Code"; Code[20])
        {
            Caption = 'Hazardous Material Code';
        }
        field(37; "ABC Code"; Text[250])
        {
            Caption = 'ABC Code';
        }
        field(38; "Run Strategy"; Integer)
        {
            Caption = 'Run Strategy';
        }
        field(39; "Safety Stock Days"; Integer)
        {
            Caption = 'Safety Stock Days';
        }
        field(40; "Lead Time"; Text[33])
        {
            Caption = 'Lead Time';
        }
        field(41; "MSA Item"; Text[250])
        {
            Caption = 'MSA Item';
        }
        field(42; "Previous Item"; Code[20])
        {
            Caption = 'Previous Item';
        }
        field(43; "Production Plant 1"; Text[250])
        {
            Caption = 'Production Plant 1';
        }
        field(44; "Production Plant 2"; Text[250])
        {
            Caption = 'Production Plant 2';
        }
        field(45; "Production Plant 3"; Text[250])
        {
            Caption = 'Production Plant 3';
        }
        field(46; "Production Line 1"; Text[250])
        {
            Caption = 'Production Line 1';
        }
        field(47; "Production Line 2"; Text[250])
        {
            Caption = 'Production Line 2';
        }
        field(48; Ti; Integer)
        {
            Caption = 'Ti';
        }
        field(49; Hi; Integer)
        {
            Caption = 'Hi';
        }
        field(50; "UoM Qty ICI"; Text[50])
        {
            Caption = 'UoM Qty ICI';
        }
        field(51; "UoM Qty EA"; Decimal)
        {
            Caption = 'UoM Qty EA';
        }
        field(52; "UoM Length EA"; Decimal)
        {
            Caption = 'UoM Length EA';
        }
        field(53; "UoM Width EA"; Decimal)
        {
            Caption = 'UoM Width EA';
        }
        field(54; "UoM Height EA"; Decimal)
        {
            Caption = 'UoM Height EA';
        }
        field(55; "UoM Weight EA"; Decimal)
        {
            Caption = 'UoM Weight EA';
        }
        field(56; "UoM Qty CS"; Decimal)
        {
            Caption = 'UoM Qty CS';
        }
        field(57; "UoM Length CS"; Decimal)
        {
            Caption = 'UoM Length CS';
        }
        field(58; "UoM Width CS"; Decimal)
        {
            Caption = 'UoM Width CS';
        }
        field(59; "UoM Height CS"; Decimal)
        {
            Caption = 'UoM Height CS';
        }
        field(60; "UoM Weight CS"; Decimal)
        {
            Caption = 'UoM Weight CS';
        }
        field(61; "UoM Cubage CS"; Text[2048])
        {
            Caption = 'UoM Cubage CS';
        }
        field(62; "UoM Qty LAY"; Decimal)
        {
            Caption = 'UoM Qty LAY';
        }
        field(63; "UoM Length LAY"; Decimal)
        {
            Caption = 'UoM Length LAY';
        }
        field(64; "UoM Width LAY"; Decimal)
        {
            Caption = 'UoM Width LAY';
        }
        field(65; "UoM Height LAY"; Decimal)
        {
            Caption = 'UoM Height LAY';
        }
        field(66; "UoM Weight LAY"; Decimal)
        {
            Caption = 'UoM Weight LAY';
        }
        field(67; "UoM Qty PAL"; Decimal)
        {
            Caption = 'UoM Qty PAL';
        }
        field(68; "UoM Length PAL"; Decimal)
        {
            Caption = 'UoM Length PAL';
        }
        field(69; "UoM Width PAL"; Decimal)
        {
            Caption = 'UoM Width PAL';
        }
        field(70; "UoM Height PAL"; Decimal)
        {
            Caption = 'UoM Height PAL';
        }
        field(71; "UoM Weight PAL"; Decimal)
        {
            Caption = 'UoM Weight PAL';
        }
        field(72; "UoM Qty INNER"; Decimal)
        {
            Caption = 'UoM Qty INNER';
        }
        field(73; "UoM Length INNER"; Decimal)
        {
            Caption = 'UoM Length INNER';
        }
        field(74; "UoM Width INNER"; Decimal)
        {
            Caption = 'UoM Width INNER';
        }
        field(75; "UoM Height INNER"; Decimal)
        {
            Caption = 'UoM Height INNER';
        }
        field(76; "UoM Weight INNER"; Decimal)
        {
            Caption = 'UoM Weight INNER';
        }

    }
    keys
    {
        key(PK; No_)
        {
            Clustered = true;
        }
    }
}