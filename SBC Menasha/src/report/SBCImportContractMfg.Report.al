report 50351 "SBC Import Contract Mfg"
{
    Caption = 'SBC Import Contract Mfg';
    ProcessingOnly = true;


    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    ShowCaption = false;

                    field(ContractSource; ContractSource)
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            AllowEdit := (ContractSource <> ContractSource::"SBC Menasha");
                        end;
                    }
                    field(ContractType; ContractType)
                    {
                        ApplicationArea = All;
                        Editable = AllowEdit;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        ImportFileMgmt: Codeunit "SBC Import File Mgmt";
    begin
        ImportFileMgmt.ImportExcelSheet();
    end;

    var
        ContractSource: Enum "SBC Contract Source";
        ContractType: Enum "SBC Contract Type";
        AllowEdit: Boolean;

}