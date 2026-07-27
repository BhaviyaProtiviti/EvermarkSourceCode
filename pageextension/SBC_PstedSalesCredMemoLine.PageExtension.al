pageextension 50129 "SBC Psted Sales Cred Memo Line" extends "Posted Sales Credit Memo Lines"
{
    layout
    {
        addafter("Document No.")
        {
            field("Posting Date"; Rec."Posting Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date when the document was posted.';
                Visible = true;
            }
        }
    }
}