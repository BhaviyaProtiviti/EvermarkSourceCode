table 50703 SBCInboundCostSetup
{
    DataClassification = CustomerContent;
    Caption = 'Inbound Cost Setup';
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(2; "Inbound Cost Journal Template"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Inbound Cost Journal Template';
            TableRelation = "Gen. Journal Template".Name;
        }
        field(3; "Inbound Cost Journal Batch"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Inbound Cost Journal Batch';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Inbound Cost Journal Template"));
        }
        field(4; "Inbound Freight Acc. Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Inbound Freight Acc. Account';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(5; "Accd Freight Inb. Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Accd Freight Inb. Acc.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(6; "COGS Inb. Freight Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'COGS Inb. Freight Acc.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(7; "WH Inbound Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'WH Inbound Acc.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(8; "Accd WH Inbound Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Accd WH Inbound Acc.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(9; "COGS WH Inbound Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'COGS WH Inbound Acc.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
        }

        field(10; "Enable Indirect Costs"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Indirect Costs';
        }
        field(11; "Auto Post Indirect Costs"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Auto Post Indirect Costs';
        }
        field(12; CostCalcType; Enum SBCInboundCostCalcType)
        {
            DataClassification = CustomerContent;
            Caption = 'Cost Calc. Type';
        }
        field(13; "WH Overhead Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'WH Overhead Acc.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(14; "Accd WH Overhead Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Accd WH Overhead Acc.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(15; "COGS WH Overhead Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'COGS WH Overhead Acc.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(16; "SBC Custom/Duty Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Custom/Duty Acc.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(17; "SBC COGS Custom/Duty Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'COGS Custom/Duty Acc.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(18; "SBC Accd Custom/Duty Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Accd Custom/Duty Acc.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}