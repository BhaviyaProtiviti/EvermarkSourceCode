tableextension 50100 "ItemJournalLIneExtension" extends "Item Journal Line"
{
    fields
    {
        field(50000; "SBC Processing Error Message"; text[250])
        {
            Caption = 'EDI Processing Error Message';
            DataClassification = CustomerContent;
            Description = 'This will display the error message only if the journal was posted from the Post EDI Batches routine.';
        }
        field(50001; "SBC Purchase Order No."; Code[20])
        {
            Caption = 'SBC Purchase Order No.';
            DataClassification = CustomerContent;
            Description = 'This is the subcontracting Purchase Order No. and will be used to find the related Production order number if not already present on the Iten Journal Line.';
            TableRelation = "Purchase Header"."No.";
        }
    }
}


