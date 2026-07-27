/// <summary>
/// Table SBCEDI ECR Options (ID 50080).
/// </summary>
table 50080 "SBCEDI ECR Settings"
{
    Caption = 'SBCEDI ECR Options';
    DataClassification = CustomerContent;
    DrillDownPageId = "SBCEDI ECR Settings";
    LookupPageId = "SBCEDI ECR Settings";

    fields
    {
        field(1; "Key"; Code[1])
        {
            Caption = 'Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Emerson Trade Partner"; Code[20])
        {
            Caption = 'Emerson Trade Partner';
            Description = 'Emerson Trade Partner No.';
            TableRelation = "LAX EDI Trade Partner"."No.";
        }
        field(10; "Payment Advice Segment"; Code[15])
        {
            Caption = 'Payment Advice Segment';
            Description = 'This is the segment that defines the begining of a new Payment Advice Entry.';
            InitValue = 'RMR';
            TableRelation = "LAX EDI Segment".Segment where("Trade Partner No." = field("Emerson Trade Partner"), Document = const('I_PMTADV'));
        }
        field(11; "Ignore Adjustment Flag"; Boolean)
        {
            Caption = 'Ignore Adjustment Flag';
            Description = 'If this flag is set to true, then the system will create adjument remit advices, but not set the adjustment flag on the remit advice line.';
            InitValue = true;
        }
        field(12; "Allow Different Bill-to/Pay-to"; Boolean)
        {
            Caption = 'Allow Different Bill-to/Pay-to';
            Description = 'If this flag is set to true, then the system will allow the bill-to and pay-to to be different when create a journal without prompting the user.';
            InitValue = true;
        }

        field(13; "Use Payer Account"; Boolean)
        {
            Caption = 'Use Payer Account';
            Description = 'Applys invoices to the Payer Account rather than the account set on the EDI 820.';
            InitValue = true;
        }

        field(14; "Bank Account No."; Code[20])
        {
            Caption = 'Bank Account No.';
            Description = 'This is the bank account no. that will be used when creating the payment journal.';
            TableRelation = "Bank Account"."No.";
        }
        field(15; "Payment Journal Batch Name"; Code[10])
        {
            Caption = 'Payment Journal Batch name';
            Description = 'This is the journal batch that will be used for refunds.';
            TableRelation = "Gen. Journal Batch".Name where("Template Type" = const("Gen. Journal Template Type"::Payments));
            trigger OnValidate()
            var
                NullGuid: Guid;
            begin
                if Rec."Payment Journal Batch Name" = '' then
                    Rec."Payment Journal Batch ID" := NullGuid
                else
                    Rec."Payment Journal Batch ID" := GetPaymentBatchIDFromBatchName(Rec."Payment Journal Batch Name");
            end;
        }
        field(16; "Payment Journal Batch ID"; Guid)
        {
            Caption = 'Payment Journal Template name';
            Description = 'This is the journal template that will be used for refunds.';
            TableRelation = "Gen. Journal Batch".SystemId where(Name = field("Payment Journal Batch Name"), "Template Type" = const("Gen. Journal Template Type"::Payments));
        }
        field(17; "Create Adjustment Entries"; Boolean)
        {
            Caption = 'Create Adjustment Entries';
            Description = 'If this flag is set to true, then the system will create adjument remit advices.';
        }

        field(18; "Default Trade Customer"; Code[20])
        {
            Caption = 'Default Trade Customer';
            Description = 'This Customer will be used for Trade Refunds when a Customer cannot be found.';
            TableRelation = Customer."No.";
        }

        field(19; "Summarize Default Trade"; Boolean)
        {
            Caption = 'Summarize Default Trade';
            Description = 'If this flag is set to true, then the system will summarize trade refunds based on the Default Trade Customer''s Customer Posting Group.';
        }
        field(20; "Set. Bal Account on Payments"; Boolean)
        {
            Caption = 'Set Bal. Account on Lines';
            Description = 'If this flag is set to true, then the system will set the Bal. Account on journal lines. This does not include the bank deposit line.';
        }
           field(21; "Payment GL Account"; Code[20])
        {
            Caption = 'Posting Account';
            TableRelation = "G/L Account";
            Description = 'This account will be used instead of the payer account when the sell-to customer account cannot be found.';
            trigger OnLookup()
            var 
             GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
            begin
                GLAccountCategoryMgt.LookupGLAccountWithoutCategory(Rec."Payment GL Account");
            end;

        }
    }
    keys
    {
        key(PK; "Key")
        {
            Clustered = true;
        }
    }

    local procedure GetPaymentBatchIDFromBatchName(PaymentJournalBatchName: Code[10]): Guid
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.SetRange("Name", PaymentJournalBatchName);
        GenJournalBatch.SetRange("Template Type", "Gen. Journal Template Type"::Payments);
        if GenJournalBatch.IsEmpty() then
            exit;
        GenJournalBatch.SetLoadFields(SystemId);
        GenJournalBatch.FindFirst();
        exit(GenJournalBatch.SystemId);
    end;
}