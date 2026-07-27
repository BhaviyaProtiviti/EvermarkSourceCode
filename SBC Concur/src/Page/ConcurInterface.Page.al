Page 50103 "Concur Interface"
{
    Caption = 'Concur Interface';
    InsertAllowed = false;
    SourceTable = "Concur Import Entry";
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;

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

                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action("Import Concur Expenses")
                {
                    PromotedOnly = true;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    Image = Import;
                    ToolTip = 'Import Concur Expenses';

                    trigger OnAction()
                    VAR
                        ImportConcurEntries: XMLport "Import Concur Entries";
                    begin
                        CLEAR(ImportConcurEntries);
                        ImportConcurEntries.RUN();
                    END;
                }

                action("Create Purchase Invoices")
                {
                    PromotedOnly = true;
                    Promoted = true;
                    PromotedIsBig = true;
                    Image = CreateDocuments;
                    PromotedCategory = Process;
                    ToolTip = 'Executes the Create Purchase Invoices action.';
                    trigger OnAction()
                    VAR
                        ConcurImportEntry: Record "Concur Import Entry";
                        ConcurInterfaceMgt: Codeunit "Concur Interface Management";
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(ConcurImportEntry);
                        ConcurInterfaceMgt.CreatePurchInvoices(ConcurImportEntry);
                        CurrPage.UPDATE();
                    END;
                }
            }
        }
    }
    trigger OnOpenPage()
    BEGIN
        rec.FILTERGROUP(2);
        rec.SETRANGE("Purchase Invoice No.", '');
        rec.FILTERGROUP(0);
    END;

    VAR
}
