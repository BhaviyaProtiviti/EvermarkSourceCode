report 50104 "SBC Update Blank Dimensions"
{
    Caption = 'SBC Update Blank Dimensions';
    ProcessingOnly = true;
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            trigger OnAfterGetRecord()
            begin
                Item.Validate("Item Category Code");
            end;

            trigger OnPostDataItem()
            begin
            end;

            trigger OnPreDataItem()
            begin
            end;
        }
    }

    trigger OnPreReport()
    begin
        IF GUIALLOWED THEN
            Wind.OPEN('@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
    end;

    trigger OnPostReport()
    begin
        IF GUIALLOWED THEN
            Wind.CLOSE();
    end;

    var
        Wind: Dialog;
}

