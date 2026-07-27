/// <summary>
/// Report SBCEDI Refresh ECRs (ID 50080).
/// </summary>
report 50080 "SBCEDI Refresh ECRs"
{
    ApplicationArea = All;
    Caption = 'Refresh Emerson Cross References';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    UseRequestPage = true;
    dataset
    {
        dataitem(ShiptoAddressDataItem; "Ship-to Address")
        {
            trigger OnPreDataItem()
            var
                EmptyDateTime: DateTime;
            begin
                ShiptoAddressDataItem.SetFilter("SBC Emerson Ship-to Code", '<>%1', '');
                if Format(EmptyDateTime) <> Format(GlobalLastModifiedDateTime) then
                    ShiptoAddressDataItem.SetFilter(SystemModifiedAt, '>=%1', GlobalLastModifiedDateTime);
            end;

            trigger OnAfterGetRecord()
            var
                SBCEDIECRUpdateHelper: Codeunit "SBCEDI Event Helper";
            begin
                SBCEDIECRUpdateHelper.CheckECR(ShiptoAddressDataItem);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Settings)
                {
                    Caption = 'Settings';
                    field(GlobalLastModifiedDateTimeOption; GlobalLastModifiedDateTime)
                    {
                        ApplicationArea = All;
                        Caption = 'Check Records Modified After';
                        Editable = true;
                        ToolTip = 'Records modified after this date will be checked for ECR updates.  Leave blank to check all records.';
                    }
                    field(GlobalDeleteOrphanedECRsOption; GlobalDeleteOrphanedECRs)
                    {
                        ApplicationArea = All;
                        Caption = 'Delete Orphaned ECRs';
                        Editable = true;
                        ToolTip = 'Delete ECRs from Customer Cross References that are no longer valid.';
                    }
                    field(GlobalUpdateCustomerECRsOption; GlobalUpdateCustomerECRs)
                    {
                        ApplicationArea = All;
                        Caption = 'Update Customer ECRs';
                        Editable = true;
                        ToolTip = 'Update Customer Base ECRs.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            // SetLastModifiedDateTimeVar();
        end;
    }
    var
        GlobalDeleteOrphanedECRs: Boolean;
        GlobalUpdateCustomerECRs: Boolean;
        GlobalLastModifiedDateTime: DateTime;
        CompleteLabel: Label 'Complete.';

    trigger OnInitReport()
    begin
        SetLastModifiedDateTimeVar();
    end;

    trigger OnPostReport()
    begin
        UpdateCustomerBaseECRs();
        DeleteOrphanedECRs();
        Message(CompleteLabel);
    end;

    internal procedure SetGlobalLastModifiedDateTime(LastModifiedDateTime: DateTime)
    begin
        GlobalLastModifiedDateTime := LastModifiedDateTime;
    end;

    local procedure DeleteOrphanedECRs()
    var
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
        ShiptoAddress: Record "Ship-to Address";
        SBCEDIECRUpdateHelper: Codeunit "SBCEDI Event Helper";
    begin
        if not GlobalDeleteOrphanedECRs then
            exit;
        LAXEDICustCrossReference.SetRange("Trade Partner No.", SBCEDIECRUpdateHelper.GetSBCEDISettings()."Emerson Trade Partner");
        LAXEDICustCrossReference.SetFilter(SystemModifiedAt, '<=%1', GlobalLastModifiedDateTime);
        LAXEDICustCrossReference.SetFilter("Sell To Code", '<>%1', '');
        LAXEDICustCrossReference.SetFilter("Ship To Code", '<>%1', '');
        LAXEDICustCrossReference.SetFilter("EDI Ship To Code", '<>%1', '');
        if LAXEDICustCrossReference.IsEmpty() then
            exit;
        SBCEDIECRUpdateHelper.SetGloblConfirm(false);
        LAXEDICustCrossReference.FindSet();
        repeat
            ShiptoAddress.SetRange("Customer No.", LAXEDICustCrossReference."Sell To Code");
            ShiptoAddress.SetRange(Code, LAXEDICustCrossReference."Ship To Code");
            ShiptoAddress.SetRange("SBC Emerson Ship-to Code", LAXEDICustCrossReference."EDI Ship To Code");
            if ShiptoAddress.IsEmpty() then
                SBCEDIECRUpdateHelper.DeleteShipToECRs(LAXEDICustCrossReference."Ship To Code", LAXEDICustCrossReference."Sell To Code");
        until LAXEDICustCrossReference.Next() = 0;
    end;

    local procedure SetLastModifiedDateTimeVar()
    var
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
        SBCEDIECRUpdateHelper: Codeunit "SBCEDI Event Helper";
    begin
        LAXEDICustCrossReference.SetRange("Trade Partner No.", SBCEDIECRUpdateHelper.GetSBCEDISettings()."Emerson Trade Partner");
        LAXEDICustCrossReference.SetCurrentKey(SystemModifiedAt);
        LAXEDICustCrossReference.SetAscending(SystemModifiedAt, true);
        if not LAXEDICustCrossReference.FindLast() then
            exit;
        GlobalLastModifiedDateTime := LAXEDICustCrossReference.SystemModifiedAt;
    end;

    local procedure UpdateCustomerBaseECRs()
    var
        Customer: Record Customer;
        SBCEDIECRUpdateHelper: Codeunit "SBCEDI Event Helper";
        EmptyDateTime: DateTime;
    begin
        if Format(EmptyDateTime) <> Format(GlobalLastModifiedDateTime) then
            Customer.SetFilter(SystemModifiedAt, '>=%1', GlobalLastModifiedDateTime);
        Customer.SetFilter("SBC Emerson Customer No.", '<>%1', '');
        if Customer.IsEmpty() then
            exit;
        Customer.FindSet();
        repeat
            SBCEDIECRUpdateHelper.CheckCustomerECR(Customer);
        until Customer.Next() = 0;
    end;
}