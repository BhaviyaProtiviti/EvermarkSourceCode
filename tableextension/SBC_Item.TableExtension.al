tableextension 50102 "SBC_Item" extends Item
{
    fields
    {
        field(50000; "SBC Shelf Life (Days)"; Integer)
        {
            Caption = 'SBC Shelf Life (Days)';
            DataClassification = CustomerContent;
            Description = 'This is the shelf life in days.';
        }
        field(50001; "SBC Hazardous Material Code"; Code[20])
        {
            Caption = 'SBC Hazardous Material Code';
            DataClassification = CustomerContent;
            Description = 'This is the Hazardous Material Code.';
        }
        field(50002; "SBC Needs EDI 832 Update"; Boolean)
        {
            Caption = 'SBC Needs EDI 832 Update';
            DataClassification = CustomerContent;
            Description = 'This is a flag updated whenever any information required on the ODW 832 Item Master Catalog is entered or changed in Business Central';
        }
        field(50010; "SBC Run Strategy"; Integer)
        {
            Caption = 'SBC Run Strategy';
            DataClassification = CustomerContent;
        }
        field(50011; "SBC Safety Stock Days"; Integer)
        {
            Caption = 'SBC Safety Stock Days';
            DataClassification = CustomerContent;
        }
        field(50012; "SBC Production Line"; Text[25])
        {
            Caption = 'SBC Production Line';
            DataClassification = CustomerContent;
        }
        field(50013; "SBC Expiration on Label"; Boolean)
        {
            Caption = 'SBC Expiration on Label';
            DataClassification = CustomerContent;
        }
        field(50014; "SBC Landed Cost"; Decimal)
        {
            Caption = 'SBC Landed Cost';
            DataClassification = CustomerContent;
        }
        field(50015; "SBC Exportable"; Boolean)
        {
            Caption = 'SBC Exportable';
            DataClassification = CustomerContent;
        }
        field(50016; "SBC MOQ UOM"; Code[10])
        {
            Caption = 'SBC MOQ UOM';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            ValidateTableRelation = false;
        }
        field(50017; "SBC Description Short"; Text[25])
        {
            Caption = 'SBC Description Short';
            DataClassification = CustomerContent;
        }
        field(50018; "SBC Gross Weight Percentage"; Decimal)
        {
            Caption = 'SBC Gross Weight Percentage';
            DataClassification = CustomerContent;
        }
        field(50019; "SBC Measurement System"; Enum "SBC Measurement System")
        {
            Caption = 'SBC Measurement System';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Item Unit of Measure"."SBC Measurement System" where("Item No." = field("No."),
                                                                                       Code = field("Base Unit of Measure")));
        }
    }
}