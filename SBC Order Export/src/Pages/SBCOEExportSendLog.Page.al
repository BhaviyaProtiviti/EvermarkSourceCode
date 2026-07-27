/// <summary>
/// Log of all the emails sent from the SBCOE Export process.
/// </summary>
page 50061 "SBCOE Export Send Log"
{
    AdditionalSearchTerms = 'SBCOE Export Send Log';
    ApplicationArea = All;
    Caption = 'Export Send Log';
    Description = 'Log of all the emails sent from the SBCOE Export process.';
    PageType = List;
    SourceTable = "SBCOE Export Send Log";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            part(Sends; "SBCOE Export Sends Part")
            {
                ApplicationArea = All;
                Caption = 'Exports Sends';
                Editable = false;
            }
        }
    }
}
