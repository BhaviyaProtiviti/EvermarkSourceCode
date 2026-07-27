Page 50104 "Concur Interface Processed"
{
    Editable = false;
    Caption = 'Concur Interface Processed';
    InsertAllowed = false;
    SourceTable = "Concur Import Entry";
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            Group(General)
            {
                repeater(Lines)
                {
                    field("Entry No."; rec."Entry No.")
                    {
                        Editable = FALSE;
                        ToolTip = 'Specifies the value of the Entry No. field.';
                        ApplicationArea = all;
                    }

                    field("Entry Type"; rec."Entry Type")
                    {
                        Caption = 'Entry Type';
                        ToolTip = 'Entry Type';
                        ApplicationArea = All;
                    }

                    field("Entry Date"; rec."Entry Date")
                    {
                        ToolTip = 'Specifies the value of the Entry Date field.';
                        ApplicationArea = All;
                    }

                    field("Employee ID"; rec."Employee ID")
                    {
                        ToolTip = 'Specifies the value of the Employee ID field.';
                        ApplicationArea = All;
                    }

                    field("Employee Last Name"; rec."Employee Last Name")
                    {
                        ToolTip = 'Specifies the value of the Employee Last Name field.';
                        ApplicationArea = All;
                    }

                    field("Employee First Name"; rec."Employee First Name")
                    {
                        ToolTip = 'Specifies the value of the Employee First Name field.';
                        ApplicationArea = All;
                    }

                    field("Report ID"; rec."Report ID")
                    {
                        ToolTip = 'Specifies the value of the Report ID field.';
                        ApplicationArea = All;
                    }

                    field("Employee Default Currency"; rec."Employee Default Currency")
                    {
                        ToolTip = 'Specifies the value of the Employee Default Currency field.';
                        ApplicationArea = All;
                    }

                    field("Report Submit Date"; rec."Report Submit Date")
                    {
                        ToolTip = 'Specifies the value of the Report Submit Date field.';
                        ApplicationArea = All;
                    }

                    field("Report Processing Payment Date"; rec."Report Processing Payment Date")
                    {
                        ToolTip = 'Specifies the value of the Report Processing Payment Date field.';
                        ApplicationArea = All;
                    }

                    field("Report Name"; rec."Report Name")
                    {
                        ToolTip = 'Specifies the value of the Report Name field.';
                        ApplicationArea = All;
                    }

                    field("Expense Type Name"; rec."Expense Type Name")
                    {
                        ToolTip = 'Specifies the value of the Expense Type Name field.';
                        ApplicationArea = All;
                    }

                    field("Transaction Date"; rec."Transaction Date")
                    {
                        ToolTip = 'Specifies the value of the Transaction Date field.';
                        ApplicationArea = All;
                    }

                    field("Is Personal Flag"; rec."Is Personal Flag")
                    {
                        ToolTip = 'Specifies the value of the Is Personal Flag field.';
                        ApplicationArea = All;
                    }

                    field(Description; rec.Description)
                    {
                        ToolTip = 'Specifies the value of the Description field.';
                        ApplicationArea = All;
                    }

                    field("Vendor Name"; rec."Vendor Name")
                    {
                        ToolTip = 'Specifies the value of the Vendor Name field.';
                        ApplicationArea = All;
                    }

                    field("Vendor Description"; rec."Vendor Description")
                    {
                        ToolTip = 'Specifies the value of the Vendor Description field.';
                        ApplicationArea = All;
                    }


                    field("Payment Code"; rec."Payment Code")
                    {
                        ToolTip = 'Specifies the value of the Payment Code field.';
                        ApplicationArea = All;
                    }

                    field("Payment Name"; rec."Payment Name")
                    {
                        ToolTip = 'Specifies the value of the Payment Name field.';
                        ApplicationArea = All;
                    }

                    field("Payment Reimbursement Type"; rec."Payment Reimbursement Type")
                    {
                        ToolTip = 'Specifies the value of the Payment Reimbursement Type field.';
                        ApplicationArea = All;
                    }

                    field("Billed Credit Card Account No."; rec."Billed Credit Card Account No.")
                    {
                        ToolTip = 'Specifies the value of the Billed Credit Card Account No. field.';
                        ApplicationArea = All;
                    }

                    field("Billed Credit Card Acc. Descr."; rec."Billed Credit Card Acc. Descr.")
                    {
                        ToolTip = 'Specifies the value of the Billed Credit Card Acc. Descr. field.';
                        ApplicationArea = All;
                    }

                    field("Journal Payer Payment Name"; rec."Journal Payer Payment Name")
                    {
                        ToolTip = 'Specifies the value of the Journal Payer Payment Name field.';
                        ApplicationArea = All;
                    }

                    field("Journal Payee Payment Type"; rec."Journal Payee Payment Type")
                    {
                        ToolTip = 'Specifies the value of the Journal Payee Payment Type field.';
                        ApplicationArea = All;
                    }

                    field("Journal Amount"; rec."Journal Amount")
                    {
                        ToolTip = 'Specifies the value of the Journal Amount field.';
                        ApplicationArea = All;
                    }

                    field("Journal Account Code"; rec."Journal Account Code")
                    {
                        ToolTip = 'Specifies the value of the Journal Account Code field.';
                        ApplicationArea = All;
                    }

                    field("Journal Debit Or Credit"; rec."Journal Debit Or Credit")
                    {
                        ToolTip = 'Specifies the value of the Journal Debit Or Credit field.';
                        ApplicationArea = All;
                    }

                    field("Demand Comp. Cash Acc."; rec."Demand Comp. Cash Acc.")
                    {
                        ToolTip = 'Specifies the value of the Demand Comp. Cash Acc. field.';
                        ApplicationArea = All;
                    }

                    field("Demand Comp. Liability Acc."; rec."Demand Comp. Liability Acc.")
                    {
                        ToolTip = 'Specifies the value of the Demand Comp. Liability Acc. field.';
                        ApplicationArea = All;
                    }

                    field("Estimated Payment Date"; rec."Estimated Payment Date")
                    {
                        ToolTip = 'Specifies the value of the Estimated Payment Date field.';
                        ApplicationArea = All;
                    }

                    field(Department; rec.Department)
                    {
                        ToolTip = 'Specifies the value of the Department field.';
                        ApplicationArea = All;
                    }
                    field("Purchase Invoice No."; rec."Purchase Invoice No.")
                    {
                        TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Invoice));
                        ToolTip = 'Specifies the value of the Purchase Invoice No. field.';
                    }

                    field("Purchase Invoice Line No."; rec."Purchase Invoice Line No.")
                    {
                        TableRelation = "Purchase Line"."Line No." WHERE("Document Type" = CONST(Invoice),
                                                                "Document No." = FIELD("Purchase Invoice No."));
                        ToolTip = 'Specifies the value of the Purchase Invoice No. field.';
                    }

                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdatePostedDocs)
            {
                ApplicationArea = All;
                Caption = 'Update AmEx Employee ID';
                Image = Employee;
                ToolTip = 'Runs processing report to update Employee ID on Posted Purchase Invoices and Vendor Ledger Entries for Concur AmEx transactions.';

                trigger OnAction()
                begin
                    if Confirm('This report will populate the Employee ID field on Posted Purchase Invoices, and related Vendor Ledger Entries for Concur AmEx transactions. Do you want to continue?') then
                        Report.Run(Report::"SBC Populate Employee ID");
                end;
            }
            action(DeletePurchaseInvoices)
            {
                ApplicationArea = All;
                Caption = 'Delete Purchase Invoices';
                Image = Delete;
                ToolTip = 'Deletes Purchase Invoices and related Purchase Invoice Lines that have not been posted for Concur transactions.';

                trigger OnAction()
                var
                    ConcurImportEntry: Record "Concur Import Entry";
                begin
                    CurrPage.SetSelectionFilter(ConcurImportEntry);
                    Report.Run(Report::"SBC Delete Concur Invoices", true, false, ConcurImportEntry);
                end;
            }
        }
        area(Promoted)
        {
            actionref(UpdatePostedDocs_Ref; UpdatePostedDocs)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        rec.FILTERGROUP(2);
        rec.SETFILTER("Purchase Invoice No.", '<>''''');
        rec.FILTERGROUP(0);
    end;

}
