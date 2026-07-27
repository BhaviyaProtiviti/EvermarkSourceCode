/// <summary>
/// Report SBCEDI Set Discrepancy Flag (ID 50082).
/// </summary>
report 50082 "SBCEDI Update Discrepancy Flag"
{
    Caption = 'SBCEDI Set Discrepancy Flag';
    ProcessingOnly = true;
    dataset
    {
        dataitem(LAXEDITemplate; "LAX EDI Template")
        {


            dataitem(PriceLAXEDIReceiveDocumentHdr; "LAX EDI Receive Document Hdr.")
            {
                DataItemLinkReference = LAXEDITemplate;
                DataItemLink = "EDI Template Code" = field(Code);

                trigger OnPreDataItem()
                begin
                    PriceLAXEDIReceiveDocumentHdr.SetRange("Price Discrepancy Check Req.", not LAXEDITemplate."Price Discrepancy Rel. Block");
                end;

                trigger OnAfterGetRecord()
                begin
                    PriceLAXEDIReceiveDocumentHdr."Price Discrepancy Check Req." := LAXEDITemplate."Price Discrepancy Rel. Block";
                    PriceLAXEDIReceiveDocumentHdr.Modify();
                end;
            }
            dataitem(CostLAXEDIReceiveDocumentHdr; "LAX EDI Receive Document Hdr.")
            {
                DataItemLinkReference = LAXEDITemplate;
                DataItemLink = "EDI Template Code" = field(Code);

                trigger OnPreDataItem()
                begin
                    CostLAXEDIReceiveDocumentHdr.SetRange("Cost Discrepancy Check Req.", not LAXEDITemplate."Cost Discrepancy Rel. Block");
                end;

                trigger OnAfterGetRecord()
                begin
                    CostLAXEDIReceiveDocumentHdr."Cost Discrepancy Check Req." := LAXEDITemplate."Cost Discrepancy Rel. Block";
                    CostLAXEDIReceiveDocumentHdr.Modify();
                end;
            }

            trigger OnPreDataItem()
            begin
                GlobalDialog.Open(GlobalDialogMsg, LAXEDITemplate.Code);

            end;

            trigger OnAfterGetRecord()
            begin
                GlobalDialog.Update(1, LAXEDITemplate.Code);
            end;

            trigger OnPostDataItem()
            begin
                GlobalDialog.Close();
            end;
        }
    }
    requestpage
    {
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

    var
        GlobalDialog: Dialog;

        GlobalDialogMsg: Label 'Updating Template #1######';
}