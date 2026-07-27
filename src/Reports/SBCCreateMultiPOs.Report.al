/// <summary>
/// Report SBC - Create Multi POs (ID 50036).
/// </summary>
report 50036 "SBC - Create Multi POs"
{
    ApplicationArea = All;
    Caption = 'SBC - Create Multiple POs';
    AdditionalSearchTerms = 'Create Subcontractor POs';
    UsageCategory = Tasks;
    ProcessingOnly = TRUE;

    dataset
    {

        dataitem(POCount; Integer)
        {
            dataitem(Vendor; Vendor)
            {
                RequestFilterFields = "No.";
                trigger OnAfterGetRecord()
                begin
                    CreatePO();
                end;

            }
            trigger OnPostDataItem()
            begin
                SetPurchaseHeaderFilter();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(OrderCount; GlobalPOCount)
                    {
                        ApplicationArea = All;
                        Caption = 'Number of POs to create';
                    }
                }
            }

        }
        actions
        {
            area(processing)
            {
            }
        }
        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction <> CloseAction::Ok then
                exit;
            POCount.SetRange(Number, 1, GlobalPOCount);
        end;
    }
    trigger OnPostReport()
    begin
        if GlobalPurchaseHeaderFilter = '' then
            Message(NoPOsCreatedMsgLabel)
        else
            Message(StrSubstNo(POsCreatedSuccessfullyMsgLabel, GlobalPurchaseHeaderFilter));
    end;

    var
        GlobalPOCount: Integer;
        GlobalTempPurchaseOrder: Record "Purchase Header" temporary;
        NoPOsCreatedMsgLabel: Label 'No POs created';
        POsCreatedSuccessfullyMsgLabel: Label 'POs %1 created successfully.';
        GlobalPurchaseHeaderFilter: Text;


    local procedure CreatePO()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        PurchaseHeader."SBC Block Order" := true;
        if PurchaseHeader.Insert(true) then begin
            Commit();
            GlobalTempPurchaseOrder := PurchaseHeader;
            GlobalTempPurchaseOrder.Insert();
        end;
    end;

    local procedure SetPurchaseHeaderFilter()
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        GlobalPurchaseHeaderFilter := SelectionFilterManagement.GetSelectionFilterForPurchaseHeader(GlobalTempPurchaseOrder);
    end;
}