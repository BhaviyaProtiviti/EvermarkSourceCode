/// <summary>
/// Table STA Bracket Price Code (ID 50211).
/// </summary>
table 50211 "STA Bracket Price Code"
{
    Caption = 'STA Bracket Price Code';
    DataClassification = CustomerContent;
    DrillDownPageId = "STA Bracket Price Codes";
    LookupPageId = "STA Bracket Price Codes";

    fields
    {
        field(1; "Bracket Price Code"; Code[20])
        {
            Caption = 'Bracket Code';
        }
        field(2; "Bracket Description"; Text[200])
        {
            Caption = 'Bracket Description';
        }
        field(3; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = SystemMetadata;
        }
        field(4; "Posting Account"; Code[20])
        {
            Caption = 'Posting Account';
            TableRelation = "G/L Account";
            Description = 'This is the account that values related to the Bracket Price Code will be posted to.';
            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccountWithoutCategory(Rec."Posting Account");
            end;

        }
        field(5; "Balance Account"; Code[20])
        {
            Caption = 'Balance Account';
            TableRelation = "G/L Account";
            Description = 'This is the account that values related to the Bracket Price Code will be balanced against.';
            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccountWithoutCategory(Rec."Balance Account");
            end;
        }
        field(6; "Bracket Dimension Code"; Code[20])
        {
            Caption = 'Bracket Dimension Code';
            Description = 'This is the dimension code that will be used to post Bracket Entries to the G/L.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("SBCTA Trade Budget Options"."Bracket Dimension Code");
        }
        field(7; "Bracket Dimension Value"; Code[20])
        {
            Caption = 'Bracket Dimension Value';
            TableRelation = "Dimension Value".Code where("Dimension Code" = field("Bracket Dimension Code"));
        }
        field(8; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            Description = 'Specifies the country or region of the address';
            TableRelation = "Country/Region".Code;
        }
    }
    keys
    {
        key(PK; "Bracket Price Code")
        {
            Clustered = true;
        }
    }
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";

    /// <summary>
    /// Sets the value of the two var parameters passed to the procedure as they are set on record matching the Bracket Price Code parameter.  
    /// </summary>
    /// <param name="BracketPriceCode">Code[20].</param>
    /// <param name="PostingAccount">VAR Code[20].</param>
    /// <param name="BalanceAccount">VAR Code[20].</param>
    internal procedure GetPostingAccountsForBracketCode(BracketPriceCode: Code[20]; var PostingAccount: Code[20]; var BalanceAccount: Code[20]) Set: Boolean;
    var
        STABracketPriceCode: Record "STA Bracket Price Code";
    begin
        if BracketPriceCode = '' then
            exit;
        STABracketPriceCode.SetRange("Bracket Price Code", BracketPriceCode);
        STABracketPriceCode.SetFilter("Posting Account", '<>%1', '');
        STABracketPriceCode.SetFilter("Balance Account", '<>%1', '');
        if STABracketPriceCode.IsEmpty() then
            exit;
        STABracketPriceCode.SetLoadFields("Posting Account", "Balance Account");
        Set := STABracketPriceCode.FindFirst();
        PostingAccount := STABracketPriceCode."Posting Account";
        BalanceAccount := STABracketPriceCode."Balance Account";
    end;
}