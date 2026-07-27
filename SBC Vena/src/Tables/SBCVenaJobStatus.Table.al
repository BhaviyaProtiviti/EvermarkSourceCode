/// <summary>
/// Table SBC Vena Job Status (ID 50259).
/// </summary>
table 50259 "SBC Vena Job Status"
{
    Caption = 'SBC Vena Job Status';
    DataClassification = CustomerContent;
    DrillDownPageId = "SBC Vena Job Status";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Vena Job Code"; Code[20])
        {
            Caption = 'Vena Job Code';
        }
        field(3; "Vena API Endpoint Path"; Text[200])
        {
            Caption = 'Vena API Endpoint Path';
        }
        field(4; "Vena Template ID"; Text[20])
        {
            Caption = 'Vena Template ID';
        }
        field(5; "Vena Send Date"; DateTime)
        {
            Caption = 'Vena Send Date';
        }
        field(6; "Vena Job ID"; Text[20])
        {
            Caption = 'Vena Job ID';
        }
        field(7; "Vena Model ID"; Text[20])
        {
            Caption = 'Vena Model ID';
        }
        field(8; "Vena Status"; Enum "SBC Vena Status")
        {
            Caption = 'Vena Status';
        }
        field(9; "Vena CSV"; Blob)
        {
            Caption = 'Vena CSV';
        }
        field(10; "Resent from Entry No."; Integer)
        {
            Caption = 'Resent from Entry No.';
            Description = 'The Entry No. of the original job that was resent.';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    var
        CsvFileExtension: Label '.csv', Locked = true;
        DownloadCsvDialogTitleLabel: Label 'Download CSV';
    /// <summary>
    /// Call an external modify after using this procedure.
    /// </summary>
    /// <param name="VenaCSV">Text.</param>
    /// <returns>Return variable Length of type Integer.</returns>

    /// <summary>
    /// This might be used to change the Vena CSV text. Primary means of setting the Vena CSV blob value is via the CSV Buffer table.
    /// </summary>
    /// <param name="VenaCSV">Text.</param>
    /// <returns>Return variable Length of type Integer.</returns>
    internal procedure SetVenaCSVText(VenaCSV: Text) Length: Integer
    var
        VenaCsvOutStream: OutStream;
    begin
        Rec."Vena CSV".CreateOutStream(VenaCsvOutStream);
        Length := VenaCsvOutStream.WriteText(VenaCSV);
    end;



    /// <summary>
    /// Allows the download of the Vena CSV file.
    /// </summary>
    internal procedure DownloadVenaCSV()
    var
        VenaCsvInStream: InStream;
        DownloadFileName: Text;
    begin
        if not GuiAllowed then
            exit;

        Rec.CalcFields(Rec."Vena CSV");
        Rec."Vena CSV".CreateInStream(VenaCsvInStream);
        DownloadFileName := Rec."Vena Job ID" + CsvFileExtension;
        DownloadFromStream(VenaCsvInStream, DownloadCsvDialogTitleLabel, '', '', DownloadFileName);
    end;

    internal procedure ResendVenaJob()
    var
        SBCResendVenaJob: Codeunit "SBC Resend Vena Job";
    begin
        SBCResendVenaJob.Run(Rec);
    end;
}