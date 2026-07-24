codeunit 50606 SBCSandboxCleanup
{
    trigger OnRun()
    begin
        CycleThroughCompanies();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    begin
        CycleThroughCompanies();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearDatabaseConfig', '', false, false)]
    local procedure OnClearDatabaseConfig(SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    begin
        CycleThroughCompanies();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", 'OnAfterCopyEnvironmentPerDatabase', '', false, false)]
    local procedure OnAfterCopyEnvironmentPerDatabase(SourceEnvironmentType: Option Production,Sandbox; SourceEnvironmentName: Text; DestinationEnvironmentType: Option Production,Sandbox; DestinationEnvironmentName: Text)
    begin
        CycleThroughCompanies();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", 'OnAfterCopyEnvironmentPerCompany', '', false, false)]
    local procedure OnAfterCopyEnvironmentPerCompany(SourceEnvironmentType: Option Production,Sandbox; SourceEnvironmentName: Text; DestinationEnvironmentType: Option Production,Sandbox; DestinationEnvironmentName: Text)
    begin
        CycleThroughCompanies();
    end;


    local procedure CycleThroughCompanies()
    var
        Company: Record Company;
    begin
        if Company.FindSet() then
            repeat
                Company.ChangeCompany(CompanyName);
                CleanCompany(Company);
            until Company.Next() = 0;
    end;

    local procedure CleanCompany(Company: Record Company)
    begin
        ClearBankingInformation(Company);
    end;

    local procedure ClearBankingInformation(Company: Record Company)
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.ChangeCompany(Company.Name);
        BankAccount.ModifyAll("TIG Last File Name", '');
    end;
}