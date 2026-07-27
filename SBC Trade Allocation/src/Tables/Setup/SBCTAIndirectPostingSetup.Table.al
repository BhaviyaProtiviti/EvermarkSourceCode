/// <summary>
/// This is where posting setups, and other settings will be defined.
/// </summary>
table 50209 "SBCTA Indirect Posting Setup"
{
    Caption = 'Indirect Cost Posting Setup';
    DataClassification = CustomerContent;


    fields
    {
        field(1; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            Description = 'This code identifies the Item Category Code that the Trade Budget Rate applies to.';
            TableRelation = "Item Category".Code;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            Description = 'This field allows for granular posting settings for a particular customer within a Customer Posting Group.';
            TableRelation = Item."No.";
            // trigger OnValidate()
            // begin
            //     CheckCustomerPostingGroupMembership();
            // end;
        }
        field(3; "Trade Budget Rate Code"; Code[20])
        {
            Caption = 'Trade Rate Code';
            DataClassification = CustomerContent;
            Description = 'This code identifies the particular Trade Budget Rate associated with the Trade Budget and further instructions on how it should be applied.';
            TableRelation = "SBCTA Trade Budget Rate Codes"."Trade Budget Rate Code" where("Rate Type" = const(Item));
        }

        field(4; "Posting Account"; Code[20])
        {
            Caption = 'Purchase Posting Account';
            TableRelation = "G/L Account";
            Description = 'This is the account that values related to the Trade Budget Rate Code in the setup will be posted to for Purchase Transactions.';
            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccountWithoutCategory(Rec."Posting Account");
            end;

        }
        field(6; "Sales Posting Account"; Code[20])
        {
            Caption = 'Sales Posting Account';
            TableRelation = "G/L Account";
            Description = 'This is the account that values related to the Trade Budget Rate Code in the setup will be posted to for Sales Transactions.';
            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccountWithoutCategory(Rec."Posting Account");
            end;

        }
        field(5; "Balance Account"; Code[20])
        {
            Caption = 'Balance Account';
            TableRelation = "G/L Account";
            Description = 'This is the account that values related to the Trade Budget Rate Code in the setup will be balanced against.';
            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccountWithoutCategory(Rec."Balance Account");
            end;
        }

        field(7; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
            DataClassification = CustomerContent;
            Description = 'This code identifies the Customer Posting Group that the Trade Budget Rate applies to.';
            TableRelation = "Customer Posting Group"."Code";
        }
    }
    keys
    {
        key(PK; "Item Category Code", "Item No.", "Trade Budget Rate Code", "Customer Posting Group")
        {
            Clustered = true;
        }
    }
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CustomerPostingGroupErrorLabel: Label 'If a Customer Posting Group is set, the Customer set in this field must belong to it.';
    #region Customer
    // internal procedure CustomerBelongsToCPG(): Boolean
    // var
    //     Customer: Record Customer;
    // begin
    //     if Rec."Item Category Code" = '' then
    //         exit(true);
    //     Customer.SetRange("No.", Rec."Item No.");
    //     Customer.SetRange("Customer Posting Group", Rec."Item Category Code");
    //     exit(not Customer.IsEmpty());
    // end;

    // local procedure CheckCustomerPostingGroupMembership()
    // begin
    //     if Rec."Item No." = '' then
    //         exit;
    //     if Rec.CustomerBelongsToCPG() then
    //         exit;
    //     Error(ErrorInfo.Create(CustomerPostingGroupErrorLabel, true, Rec, Rec.FieldNo(Rec."Item No."), 0, '', Verbosity::Warning, DataClassification::CustomerContent));
    // end;

    /// <summary>
    /// Most specific to least specific setup returned
    /// </summary>
    /// <param name="ItemCategoryCode"></param>
    /// <param name="ItemNo"></param>
    /// <returns></returns>
    internal procedure GetItemSetup(ItemCategoryCode: Code[20]; ItemNo: Code[20]; TradeBudgetRateCode: Code[20]; var SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup"; CustomerPostingGroupCode: Code[20]) Found: Boolean
    var
        ICItemSBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
        ItemOnlySBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
        ICOnlySBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
        CPGPostingGroupSetup: Record "SBCTA Indirect Posting Setup";
        CustomerPostingGroupFound: Boolean;
    begin
        //TODO(Streamline this code.)
        SBCTAIndirectPostingSetup.Reset();

        if CustomerPostingGroupCode <> '' then begin
            CPGPostingGroupSetup.SetRange("Customer Posting Group", CustomerPostingGroupCode);
            if ItemCategoryCode <> '' then
                CPGPostingGroupSetup.SetRange("Item Category Code", ItemCategoryCode);
            if ItemNo <> '' then
                CPGPostingGroupSetup.SetRange("Item No.", ItemNo);
            if TradeBudgetRateCode <> '' then
                CPGPostingGroupSetup.SetRange("Trade Budget Rate Code", TradeBudgetRateCode);
            if CPGPostingGroupSetup.IsEmpty() then
                CPGPostingGroupSetup.SetRange("Item No.");
            CustomerPostingGroupFound := not CPGPostingGroupSetup.IsEmpty();
        end;
        if not CustomerPostingGroupFound then begin
            ICItemSBCTAIndirectPostingSetup.SetRange("Item Category Code", ItemCategoryCode);
            ICItemSBCTAIndirectPostingSetup.SetRange("Item No.", ItemNo);

            ItemOnlySBCTAIndirectPostingSetup.SetRange("Item Category Code", '');
            ItemOnlySBCTAIndirectPostingSetup.SetRange("Item No.", ItemNo);

            ICOnlySBCTAIndirectPostingSetup.SetRange("Item Category Code", ItemCategoryCode);
            ICOnlySBCTAIndirectPostingSetup.SetRange("Item No.", '');

            if TradeBudgetRateCode <> '' then begin
                ICItemSBCTAIndirectPostingSetup.SetRange("Trade Budget Rate Code", TradeBudgetRateCode);
                ItemOnlySBCTAIndirectPostingSetup.SetRange("Trade Budget Rate Code", TradeBudgetRateCode);
                ICOnlySBCTAIndirectPostingSetup.SetRange("Trade Budget Rate Code", TradeBudgetRateCode);
            end;

            // SBCTAIndirectPostingSetup.Reset();
            case true of
                not ICItemSBCTAIndirectPostingSetup.IsEmpty():
                    SBCTAIndirectPostingSetup.CopyFilters(ICItemSBCTAIndirectPostingSetup);
                not ItemOnlySBCTAIndirectPostingSetup.IsEmpty():
                    SBCTAIndirectPostingSetup.CopyFilters(ItemOnlySBCTAIndirectPostingSetup);
                not ICOnlySBCTAIndirectPostingSetup.IsEmpty():
                    SBCTAIndirectPostingSetup.CopyFilters(ICOnlySBCTAIndirectPostingSetup);
            end;

        end else
            SBCTAIndirectPostingSetup.CopyFilters(CPGPostingGroupSetup);

        Found := not SBCTAIndirectPostingSetup.IsEmpty();
        // Found := not SBCTAIndirectPostingSetup.IsEmpty();
    end;

    internal procedure GetItemSetup(ItemCategoryCode: Code[20]; ItemNo: Code[20]; var SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup"; CustomerPostingGroupCode: Code[20]) Found: Boolean
    begin
        Found := GetItemSetup(ItemCategoryCode, ItemNo, '', SBCTAIndirectPostingSetup, CustomerPostingGroupCode);
    end;

    internal procedure ItemSetupExists(ItemCategoryCode: Code[20]; ItemNo: Code[20]; TradeBudgetRateCode: Code[20]; CustomerPostingGroupCode: Code[20]) Found: Boolean
    var
        SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
    begin
        Found := GetItemSetup(ItemCategoryCode, ItemNo, TradeBudgetRateCode, SBCTAIndirectPostingSetup, CustomerPostingGroupCode);
    end;

    internal procedure ItemSetupExists(ItemCategoryCode: Code[20]; ItemNo: Code[20]) Found: Boolean
    begin
        Found := ItemSetupExists(ItemCategoryCode, ItemNo, '', '');
    end;
    #endregion Customer
    #region Item
    #endregion Item
}