page 50601 EVMAzureFileShareSetup
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = EVMAzureFileShareSetup;
    Caption = 'EVM Azure File Share Setup';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Storage Account"; Rec."Storage Account")
                {
                    ApplicationArea = All;
                }
                field("File Share"; Rec."File Share")
                {
                    ApplicationArea = All;
                }
                field("SAS Token"; SASToken)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    Editable = PageEditable;

                    trigger OnValidate()
                    begin
                        SetSASToken();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        PageEditable := CurrPage.Editable();
        GetSASToken();
    end;

    var
        PageEditable: Boolean;
        [NonDebuggable]
        SASToken: Text;

    [NonDebuggable]
    local procedure GetSASToken()
    begin
        if not IsolatedStorage.Get('EVMBankAFSSASToken', SASToken) then
            exit;
    end;

    [NonDebuggable]
    local procedure SetSASToken()
    begin
        if not IsolatedStorage.Set('EVMBankAFSSASToken', SASToken) then
            exit;
    end;
}