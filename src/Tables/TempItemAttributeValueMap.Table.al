table 50037 "SBC Temp Item Attribute Value"
{
    Caption = 'SBC Temporary Item Attribute Value';
    DataClassification = CustomerContent;
    TableType = Temporary;
    
    fields
    {
        field(1; "SBC Item No."; Code[20])
        {
            Caption = 'SBC Item No.';
        }
        field(2; "SBC Item Attribute ID"; Integer)
        {
            Caption = 'SBC Item Attribute ID';
        }
        field(3; "SBC Item Attribute Value ID"; Integer)
        {
            Caption = 'SBC Item Attribute Value ID';
        }
        field(4; "SBC Item Attribute Name"; Text[250])
        {
            Caption = 'SBC Item Attribute Name';
        }
        field(5; "SBC Item Attribute Value"; Text[250])
        {
            Caption = 'SBC Item Attribute Value';
        }
        
    }
    keys
    {
        key(PK; "SBC Item No.","SBC Item Attribute ID")
        {
            Clustered = true;
        }
    }
}
