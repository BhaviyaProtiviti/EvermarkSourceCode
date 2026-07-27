/// <summary>
/// This is where posting setups, and other settings will be defined.
/// </summary>
table 50200 "SBCTA Trade Budget Setup"
{
    Caption = 'Trade Posting Setup';
    DataClassification = CustomerContent;


    fields
    {
        field(1; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
            DataClassification = CustomerContent;
            Description = 'This code identifies the Customer Posting Group that the Trade Budget Rate applies to.';
            TableRelation = "Customer Posting Group"."Code";
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            Description = 'This field allows for granular posting settings for a particular customer within a Customer Posting Group.';
            TableRelation = Customer."No.";
            trigger OnValidate()
            begin
                CheckCustomerPostingGroupMembership();
            end;
        }
        field(3; "Trade Budget Rate Code"; Code[20])
        {
            Caption = 'Trade Rate Code';
            DataClassification = CustomerContent;
            Description = 'This code identifies the particular Trade Budget Rate associated with the Trade Budget and further instructions on how it should be applied.';
            TableRelation = "SBCTA Trade Budget Rate Codes"."Trade Budget Rate Code" where("Rate Type" = const(Customer));
        }

        field(4; "Posting Account"; Code[20])
        {
            Caption = 'Posting Account';
            TableRelation = "G/L Account";
            Description = 'This is the account that values related to the Trade Budget Rate Code in the setup will be posted to.';
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
        field(6; "Grouping Customer No."; Code[20])
        {
            Caption = 'Grouping Customer No.';
            DataClassification = CustomerContent;
            Description = 'Credits will be created using this grouping customer.';
            TableRelation = Customer."No.";

        }
        field(10; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
            Description = 'This dimension value can be used to match along with the group code.';

        }
    }
    keys
    {
        key(PK; "Customer Posting Group", "Customer No.", "Shortcut Dimension 1 Code", "Trade Budget Rate Code")
        {
            Clustered = true;
        }
    }
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CustomerPostingGroupErrorLabel: Label 'If a Customer Posting Group is set, the Customer set in this field must belong to it.';
    #region Customer
    internal procedure CustomerBelongsToCPG(): Boolean
    var
        Customer: Record Customer;
    begin
        if Rec."Customer Posting Group" = '' then
            exit(true);
        Customer.SetRange("No.", Rec."Customer No.");
        Customer.SetRange("Customer Posting Group", Rec."Customer Posting Group");
        exit(not Customer.IsEmpty());
    end;

    local procedure CheckCustomerPostingGroupMembership()
    begin
        if Rec."Customer No." = '' then
            exit;
        if Rec.CustomerBelongsToCPG() then
            exit;
        Error(ErrorInfo.Create(CustomerPostingGroupErrorLabel, true, Rec, Rec.FieldNo(Rec."Customer No."), 0, '', Verbosity::Warning, DataClassification::CustomerContent));
    end;

    /// <summary>
    /// Most specific to least specific setup returned
    /// </summary>
    /// <param name="CustomerPostingGroup"></param>
    /// <param name="CustomerNo"></param>
    /// <returns></returns>
    internal procedure GetCustomerSetup(CustomerPostingGroup: Code[20]; CustomerNo: Code[20]; ShortcutDimension1Code: Code[20]; TradeBudgetRateCode: Code[20]; var SBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup") Found: Boolean
    var
        CPGCustSBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
        CustOnlySBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
        CPGOnlySBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
        CPGandDim1SBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
        CPGDim1CustSBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
    begin
        // Add a Dimension lookup here for Customer Separation.
        CPGDim1CustSBCTATradeBudgetSetup.SetRange("Customer Posting Group", CustomerPostingGroup);
        CPGDim1CustSBCTATradeBudgetSetup.SetRange("Shortcut Dimension 1 Code", ShortcutDimension1Code);
        CPGCustSBCTATradeBudgetSetup.SetRange("Customer No.", CustomerNo);

        CPGandDim1SBCTATradeBudgetSetup.SetRange("Customer Posting Group", CustomerPostingGroup);
        CPGandDim1SBCTATradeBudgetSetup.SetRange("Shortcut Dimension 1 Code", ShortcutDimension1Code);
        CPGandDim1SBCTATradeBudgetSetup.SetFilter("Customer No.", '%1', '');

        CPGCustSBCTATradeBudgetSetup.SetRange("Customer Posting Group", CustomerPostingGroup);
        CPGCustSBCTATradeBudgetSetup.SetRange("Customer No.", CustomerNo);

        CustOnlySBCTATradeBudgetSetup.SetFilter("Customer Posting Group", '%1', '');
        CustOnlySBCTATradeBudgetSetup.SetRange("Customer No.", CustomerNo);

        CPGOnlySBCTATradeBudgetSetup.SetRange("Customer Posting Group", CustomerPostingGroup);
        CPGOnlySBCTATradeBudgetSetup.SetFilter("Customer No.", '%1', '');


        if TradeBudgetRateCode <> '' then begin
            CPGDim1CustSBCTATradeBudgetSetup.SetRange("Trade Budget Rate Code", TradeBudgetRateCode);
            CPGandDim1SBCTATradeBudgetSetup.SetRange("Trade Budget Rate Code", TradeBudgetRateCode);
            CPGCustSBCTATradeBudgetSetup.SetRange("Trade Budget Rate Code", TradeBudgetRateCode);
            CustOnlySBCTATradeBudgetSetup.SetRange("Trade Budget Rate Code", TradeBudgetRateCode);
            CPGOnlySBCTATradeBudgetSetup.SetRange("Trade Budget Rate Code", TradeBudgetRateCode);
        end;
        // Most restrictive to least restrictive
        SBCTATradeBudgetSetup.Reset();
        case true of // This is an exclusionary check. If there is a trade budget with no specific global dimension 1 code, then one without a global dimension 1 code set will be used. So if you want to set up a budget for a specific global dim 1, then you only need to create one for it. Otherwise, the generic budget will be used, if one exists.
            not CPGDim1CustSBCTATradeBudgetSetup.IsEmpty():
                SBCTATradeBudgetSetup.CopyFilters(CPGDim1CustSBCTATradeBudgetSetup);
            not CPGandDim1SBCTATradeBudgetSetup.IsEmpty():
                SBCTATradeBudgetSetup.CopyFilters(CPGandDim1SBCTATradeBudgetSetup);
            not CPGCustSBCTATradeBudgetSetup.IsEmpty():
                SBCTATradeBudgetSetup.CopyFilters(CPGCustSBCTATradeBudgetSetup);
            not CustOnlySBCTATradeBudgetSetup.IsEmpty():
                SBCTATradeBudgetSetup.CopyFilters(CustOnlySBCTATradeBudgetSetup);
            not CPGOnlySBCTATradeBudgetSetup.IsEmpty():
                SBCTATradeBudgetSetup.CopyFilters(CPGOnlySBCTATradeBudgetSetup);
        end;

        Found := not SBCTATradeBudgetSetup.IsEmpty();
    end;

    internal procedure GetCustomerSetup(CustomerPostingGroup: Code[20]; CustomerNo: Code[20]; ShortcutDimension1Code: Code[20]; var SBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup") Found: Boolean
    var
        BlankTradeBudgetRateCode: Code[20];
    begin
        Found := GetCustomerSetup(CustomerPostingGroup, CustomerNo, ShortcutDimension1Code, BlankTradeBudgetRateCode, SBCTATradeBudgetSetup);
    end;

    // internal procedure CustomerSetupExists(CustomerPostingGroup: Code[20]; CustomerNo: Code[20]; ItemCategoryCode: Code[20]; TradeBudgetRateCode: Code[20]) Found: Boolean
    // var
    //     SBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
    // begin
    //     Found := GetCustomerSetup(CustomerPostingGroup, CustomerNo, TradeBudgetRateCode, SBCTATradeBudgetSetup);
    // end;

    // internal procedure CustomerSetupExists(CustomerPostingGroup: Code[20]; CustomerNo: Code[20]; ItemCategoryCode: Code[20]) Found: Boolean
    // begin
    //     Found := CustomerSetupExists(CustomerPostingGroup, CustomerNo, '');
    // end;
    #endregion Customer
    #region Item
    #endregion Item
}