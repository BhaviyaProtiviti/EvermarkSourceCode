pageextension 50600 SBCCompanyInfoCardExt extends "Company Information"
{

    actions
    {
        addlast(Setup)
        {
            action(SBCSandboxCleanup)
            {
                ApplicationArea = All;
                Caption = 'Sandbox Cleanup';
                Image = Company;
                ToolTip = 'Clears sensitive data related to the SBC Banking Extension.';
                trigger OnAction()
                var
                    SBCSandboxCleanup: Codeunit SBCSandboxCleanup;
                begin
                    SBCSandboxCleanup.Run()
                end;
            }
        }
    }
}