/// <summary>
/// PageExtension Adds export to text functionality to the SBC EDI WS Document page.
/// </summary>
pageextension 50090 "SBC EDI WS Document" extends "LAX EDI WS Document"
{
    actions
    {
        addlast(Processing)
        {
            action("Export to Text")
            {
                ApplicationArea = All;
                Caption = 'Export to Text';
                ToolTip = 'Export the EDI Document to a text file.';
                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    EDIDocumentTextBuilder: TextBuilder;
                    TempLAXEDIWSDocument: Record "LAX EDI WS Document" temporary;
                    EDIDocumentOutStream : OutStream;
                    EDiDocumentInstream : InStream;
                    EdiDocumentText : Text;
                begin
                    Rec.FindSet();
                    repeat
                        EDIDocumentTextBuilder.AppendLine(Rec."Document Line 1");
                    until Rec.Next() = 0;
                    TempBlob.CreateOutStream(EDIDocumentOutStream);
                    EDIDocumentOutStream.WriteText(EDIDocumentTextBuilder.ToText());
                    TempBlob.CreateInStream(EDiDocumentInstream);
                    EdiDocumentText := 'EdiDocument.txt';
                    DownloadFromStream(EDiDocumentInstream,'','','',EdiDocumentText);
                end;
            }
        }
    }
}