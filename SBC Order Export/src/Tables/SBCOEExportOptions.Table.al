/// <summary>
/// Table SBCOE Export Options (ID 50067).
/// </summary>
table 50067 "SBCOE Export Options"
{
    Caption = 'SBCOE Export Options';
    DataClassification = CustomerContent;
    DrillDownPageId = "SBCOE Export Options";
    LookupPageId = "SBCOE Export Options";

    fields
    {
        field(1; "Key"; Code[20])
        {
            Caption = 'Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Export Definition Code"; Code[20])
        {
            Caption = 'Export Definition Code';
            DataClassification = CustomerContent;
            Description = 'The code of the Export Definition to use for this Export.';
            TableRelation = "SBCOE Export Definition"."Export Definition Code";
        }
        field(3; "Notification Definition Code"; Code[20])
        {
            Caption = 'Notification Definition Code';
            DataClassification = CustomerContent;
            Description = 'The code of the default Notification Export Definition to use.';
            TableRelation = "SBCOE Export Definition"."Export Definition Code" where("Notification Only" = const(true));
        }
        field(20; "Export Email Subject"; Text[2048])
        {
            Caption = 'Default Email Subject';
            DataClassification = CustomerContent;
            Description = 'The default subject to use for the email.';
        }
        field(21; "Export Email Body"; Blob)
        {
            Caption = 'Default Email Body';
            DataClassification = CustomerContent;
            Description = 'The default body to use for the email.';
        }
        field(22; "Email Body Is HTML"; Boolean)
        {
            Caption = 'Email Body Is HTML';
            DataClassification = CustomerContent;
            Description = 'Indicates whether the email body is HTML when set or plaintext when not set.';
        }
        field(23; "Timestamp Format String"; Text[50])
        {
            Caption = 'Timestamp Format String';
            DataClassification = CustomerContent;
            Description = 'The format string to use for the timestamp in the email subject.';
            InitValue = 'u';
        }
    }
    keys
    {
        key(PK; "Key")
        {
            Clustered = true;
        }
    }

    var
        HTMLPatternLabel: Label '</*[a-zA-Z][a-zA-Z0-9\-_]+>';

    internal procedure GetBodyText(): Text
    var
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        TempBlob.FromRecord(Rec, FieldNo(Rec."Export Email Body"));
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    internal procedure SetBodyText(StreamText: Text)
    var
        OutStream: OutStream;
    begin
        SetFormattedHtmlFlag(StreamText);
        Clear(Rec."Export Email Body");
        Rec."Export Email Body".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.Write(StreamText);
        if Rec.Modify(true) then;
    end;

    local procedure SetFormattedHtmlFlag(StreamText: Text)
    var
        Regex: Codeunit Regex;
        IsHtmlFormattedText: Boolean;
    begin
        Regex.Regex(HTMLPatternLabel);
        IsHtmlFormattedText := Regex.IsMatch(StreamText.Trim());
        xRec.CalcFields("Export Email Body");
        case true of
            (xRec."Export Email Body".Length() <= 1) and IsHtmlFormattedText and not Rec."Email Body Is HTML":
                Rec."Email Body Is HTML" := true;
            xRec."Export Email Body".HasValue() and not IsHtmlFormattedText and Rec."Email Body Is HTML":
                Rec."Email Body Is HTML" := false;
        end;
    end;
}
