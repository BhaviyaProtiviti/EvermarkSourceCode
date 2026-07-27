/// <summary>
/// This page serves as the API endpoint that allows access to the SpecRight item update queue.
/// </summary>
page 50036 "SBC SpecRight Interface"
{
    APIGroup = 'SpecRight';
    APIPublisher = 'SBC';
    APIVersion = 'v1.0';
    Caption = 'sbcSpecRightInterface';
    DelayedInsert = true;
    EntityName = 'SpecRightItems';
    EntitySetName = 'SpecRightItems';
    PageType = API;
    SourceTable = "SBC SpecRight Interface";
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.';
                }
            }
        }
    }
}