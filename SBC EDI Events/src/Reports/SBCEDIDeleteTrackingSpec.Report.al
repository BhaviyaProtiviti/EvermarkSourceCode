/// <summary>
/// Report SBCEDI Delete Tracking Spec (ID 50084).
/// </summary>
report 50084 "SBCEDI Delete Tracking Spec"
{
    ApplicationArea = All;
    Caption = 'SBCEDI Delete Tracking Spec';
    UsageCategory = Administration;
    UseRequestPage = true;
    ProcessingOnly = true;
    dataset
    {
        dataitem(TrackingSpecification; "Tracking Specification")
        {
            DataItemTableView = where("Item Ledger Entry No." = Const(0),"Quantity Handled (Base)" = const(0),"Quantity Invoiced (Base)" = const(0));
            RequestFilterFields = "Source ID";

            trigger OnAfterGetRecord()
            begin
                TrackingSpecification.Delete();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
}