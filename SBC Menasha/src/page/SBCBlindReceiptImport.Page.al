page 50358 "SBC Blind Receipt Import"
{
    ApplicationArea = All;
    Caption = 'SBC Blind Receipt Import';
    PageType = List;
    SourceTable = "SBC Blind Receipt";
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("SBC Do Not Process"; Rec."SBC Do Not Process")
                {
                    ToolTip = 'Specifies the value of the SBC Do Not Process field.', Comment = '%';
                }
                field("SBC Report Date"; Rec."SBC Report Date")
                {
                    ToolTip = 'Specifies the value of the SBC Report Date field.', Comment = '%';
                }                
                field("SBC Purchase Order No."; Rec."SBC Purchase Order No.")
                {
                    ToolTip = 'Specifies the value of the SBC Purchase Order No. field.', Comment = '%';
                }
                field("SBC Item No."; Rec."SBC Item No.")
                {
                    ToolTip = 'Specifies the value of the SBC Item No. field.', Comment = '%';
                }
                field("SBC BOL No."; Rec."SBC BOL No.")
                {
                    ToolTip = 'Specifies the value of the SBC BOL No. field.', Comment = '%';
                }
                field("SBC Lot No."; Rec."SBC Lot No.")
                {
                    ToolTip = 'Specifies the value of the SBC Lot No. field.', Comment = '%';
                }
                field("SBC Case Qty"; Rec."SBC Case Qty")
                {
                    ToolTip = 'Specifies the value of the SBC Case Qty field.', Comment = '%';
                }
                field("SBC Load ID"; Rec."SBC Load ID")
                {
                    ToolTip = 'Specifies the value of the SBC Load ID field.', Comment = '%';
                }
                field("SBC Supplier ID"; Rec."SBC Supplier ID")
                {
                    ToolTip = 'Specifies the value of the SBC Supplier ID field.', Comment = '%';
                }
                field("SBC Error Message"; Rec."SBC Error Message")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the SBC Error Message field.', Comment = '%';                
                }
                field("SBC Processed"; Rec."SBC Processed")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the SBC Processed field.', Comment = '%';
                }
                field("SBC Posted"; Rec."SBC Posted")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the SBC Posted field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Import)
            {
                ApplicationArea = All;
                Caption = 'Import';
                image = Import;

                trigger OnAction()
                begin
                    BlindReceiptImport.Import();
                end;
            }
            action(SBCProcess)
            {
                ApplicationArea = All;
                Caption = 'Create Item Tracking Post by BOL';
                Image = ItemTracking;
                ToolTip = 'Creates Item Tracking on Purchase Order Lines and Post Receipt by BOL';

                trigger OnAction()
                begin
                    BlindReceiptImport.ProcessBlindReceipts();
                    CurrPage.Update();
                end;
            }
            action(SBCOpenOrderLine)
            {
                ApplicationArea = All;
                Caption = 'Open Order Line';
                Image = ViewDocumentLine;

                trigger OnAction()
                var
                    PurchaseLine: Record "Purchase Line";
                begin
                    PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                    PurchaseLine.SetRange("Document No.", Rec."SBC Purchase Order No.");
                    PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
                    PurchaseLine.SetRange("No.", Rec."SBC Item No.");
                    Page.Run(Page::"Purchase Lines", PurchaseLine);
                end;
            }
            // action(SBCClearErr)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Clear All Errors';
            //     Image = ClearLog;

            //     trigger OnAction()
            //     var
            //         SBCBlindReceipt: Record "SBC Blind Receipt";
            //     begin
            //         SBCBlindReceipt.ModifyAll("SBC Error Message", '');
            //     end;
            // }
        }
        area(Promoted)
        {
            actionref(Import_Promoted; Import)
            {
            }
            actionref(SBCProcess_Promoted; SBCProcess)
            {
            }
            actionref(SBCOpenOrderLine_Promoted; SBCOpenOrderLine)
            {
            }
            // actionref(SBCClearErr_Promoted; SBCClearErr)
            // {
            // }
        }
    }

    var
        BlindReceiptImport: Codeunit "SBC Blind Receipt Import";
}
