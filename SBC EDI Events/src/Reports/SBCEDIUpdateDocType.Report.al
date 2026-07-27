#if TEST
/// <summary>
/// Report SBCEDI Update Doc Type (ID 50081).
/// </summary>
report 50081 "SBCEDI Update Doc Type"
{
    ApplicationArea = All;
    Caption = 'SBCEDI Update Doc Type';
    Description = 'Utility Report';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {

        dataitem(LAXEDIAvailableDocument; "LAX EDI Available Document")
        {
            MaxIteration = 1;
            dataitem(LAXEDIReceiveDocumentHdr; "LAX EDI Receive Document Hdr.")
            {
                trigger OnAfterGetRecord()
                begin
                    LAXEDIReceiveDocumentHdr.Document := LAXEDIAvailableDocument.Document;
                    if LAXEDIReceiveDocumentHdr.Modify() then
                        GlobalCreateCount += 1;
                end;
            }

        }

    }

    requestpage
    {
        layout
        {
            area(content)
            {

            }

        }


    }
    trigger OnPostReport()
    begin
        Message(TotalRecordsMessageLabel, GlobalCreateCount);
    end;

    var
        TotalRecordsMessageLabel: Label 'Total Records Updated: %1';
        GlobalCreateCount: Integer;

}
#endif