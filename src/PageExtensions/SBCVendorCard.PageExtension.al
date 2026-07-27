/// <summary>
/// PageExtension SBC Vendor Card (ID 50036) extends Record Vendor Card.
/// </summary>
pageextension 50036 "SBC Vendor Card" extends "Vendor Card"
{
    actions
    {
        addlast(processing)
        {
            action(SBCCreateSubcontractPO)
            {
                ApplicationArea = All;
                Caption = 'SBC Create Sub-Contract PO';
                ToolTip = 'This action allows the creation of a block of sub-contracting Purchase Orders for this vendor.';
                Promoted = true;
                PromotedCategory = Process;
                Image = SubcontractingWorksheet;
                trigger OnAction()
                var
                    SBCCreateMultiPOs: Report "SBC - Create Multi POs";
                    Vendor: Record Vendor;
                begin
                    Vendor := Rec;
                    Vendor.SetRecFilter();
                    SBCCreateMultiPOs.SetTableView(Vendor);
                    SBCCreateMultiPOs.RunModal();
                end;
            }
        }
    }
}