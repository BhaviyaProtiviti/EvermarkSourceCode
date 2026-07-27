table 50142 "SBC Brand Capacity by Location"
{
    Caption = 'SBC Brand Capacity by Location';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "SBC Location"; Code[20])
        {
            Caption = 'SBC Location';
            TableRelation = "Location";
        }
        field(2; "SBC Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Brand';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
        }
        field(3; "SBC Max Pallet Count"; Decimal)
        {
            Caption = 'SBC Max Pallet Count';
        }
        field(4; "SBC Max Cubage Allowed"; Decimal)
        {
            Caption = 'SBC Max Cubage Allowed';
        }
        field(5; "SBC Allow Double Stack"; Boolean)
        {
            Caption = 'SBC Allow Double Stack';
        }
    }
    keys
    {
        key(PK; "SBC Location", "SBC Shortcut Dimension 1 Code")
        {
            Clustered = true;
        }
    }
}
