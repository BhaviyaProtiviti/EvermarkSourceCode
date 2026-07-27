pageextension 50117 "SBC Gen. Journal Import" extends "General Journal"
{
    actions
    {
        addafter("&Line")
        {
            action(ImportLines)
            {
                ApplicationArea = All;
                Caption = 'Import Lines';
                Image = Import;

                trigger OnAction()
                var
                    SBCGenJournalImportMgmt: Codeunit "SBC Gen Journal Import Mgmt";
                begin
                    SBCGenJournalImportMgmt.ImportLines(Rec."Journal Template Name", Rec."Journal Batch Name");
                end;
            }
            action(AdjustCost)
            {
                ApplicationArea = All;
                Caption = 'Run Adjust Cost';
                Image = AdjustItemCost;
                //RunObject = Report "SBC Adjust Cost";
                trigger OnAction()
                var
                    SBCAdjustCost: Report "SBC Adjust Cost";
                begin
                    SBCAdjustCost.Run();
                end;
            }
        }
        addlast(Category_Category10)
        {
            actionref(ImportLines_Promoted; ImportLines)
            {
            }
            actionref(AdjustCost_Promoted; AdjustCost)
            {
            }
        }
    }
}