/// <summary>
/// This table stores the export data for SBCOE.
/// </summary>
table 50065 "SBCOE Export"
{
    Caption = 'SBCOE Export';
    DataClassification = CustomerContent;
    Description = 'This table stores the export data for SBCOE.';
    DrillDownPageId = "SBCOE Export";
    LookupPageId = "SBCOE Export Archive";

    fields
    {
        field(1; "Export Entry No."; Integer)
        {
            AutoIncrement = true;
            BlankZero = true;
            Caption = 'Export Entry No.';
            DataClassification = SystemMetadata;
            Description = 'The entry number of the export data.';
        }
        field(2; "Export Definition Code"; Code[20])
        {
            Caption = 'Export Definition Code';
            DataClassification = SystemMetadata;
            Description = 'The code of the export definition.';
        }
        field(3; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = SystemMetadata;
            Description = 'The date when the export data was created.';
        }
        field(4; "Export Data"; Blob)
        {
            Caption = 'Export Data';
            DataClassification = OrganizationIdentifiableInformation;
            Description = 'The export data.';
        }
        field(10; "Email Group Code"; Code[20])
        {
            Caption = 'Email Group Code';
            DataClassification = EndUserIdentifiableInformation;
            Description = 'The list of emails associated with this export.';
            TableRelation = "SBCOE Export Email Group"."Email Group Code";
        }
    }
    keys
    {
        key(PK; "Export Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        DeleteEntries();
    end;

    trigger OnRename()
    begin
        RenameEntries();
    end;

    var
        CouldNotBeEmailedErrorLabel: Label 'The Export could not be emailed.';
        ExportDownloadCompleteLabel: Label 'The export has been downloaded.';
        /// <summary>
        /// GetExports.
        /// </summary>
        /// <param name="ExportRecordKey">Code[20].</param>
        /// <param name="tableId">Integer.</param>
        ExportDownloadFailedErrorLabel: Label 'Export Download Failed.';
        ExportFailedErrorTitleLabel: Label 'Export Email Failed';
        ThereIsNoDataErrorLabel: Label 'There is no data to download.';
    /// <param name="SBCOEExport">VAR Record "SBCOE Export".</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure GetExports(ExportRecordKey: Code[20]; tableId: Integer; var SBCOEExport: Record "SBCOE Export"): Boolean
    var
        SBCOEExportEntry: Record "SBCOE Export Entry";
    begin
        SBCOEExportEntry.SetRange("Export Document Key", ExportRecordKey);
        SBCOEExportEntry.SetRange("Export Table No.", tableId);
        exit(SetExportFilters(SBCOEExport, SBCOEExportEntry));
    end;

    /// <summary>
    /// GetExports.
    /// </summary>
    /// <param name="ExportRecordGUID">Guid.</param>
    /// <param name="tableId">Integer.</param>
    /// <param name="SBCOEExport">VAR Record "SBCOE Export".</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure GetExports(ExportRecordGUID: Guid; tableId: Integer; var SBCOEExport: Record "SBCOE Export"): Boolean
    var
        SBCOEExportEntry: Record "SBCOE Export Entry";
    begin
        SBCOEExportEntry.SetFilter("Export System ID", ExportRecordGUID);
        SBCOEExportEntry.SetRange("Export Table No.", tableId);
        exit(SetExportFilters(SBCOEExport, SBCOEExportEntry));
    end;
    /// <summary>
    /// GetExports.
    /// </summary>
    /// <param name="ExportRecordKey">Code[20].</param>
    /// <param name="tableId">Integer.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure HasExports(ExportRecordKey: Code[20]; tableId: Integer): Boolean
    var
        SBCOEExport: Record "SBCOE Export";
        SBCOEExportEntry: Record "SBCOE Export Entry";
    begin
        exit(GetExports(ExportRecordKey, tableId, SBCOEExport));
    end;

    /// <summary>
    /// GetExports.
    /// </summary>
    /// <param name="ExportRecordGUID">Guid.</param>
    /// <param name="tableId">Integer.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure HasExports(ExportRecordGUID: Guid; tableId: Integer): Boolean
    var
        SBCOEExport: Record "SBCOE Export";
        SBCOEExportEntry: Record "SBCOE Export Entry";
    begin
        exit(GetExports(ExportRecordGUID, tableId, SBCOEExport));
    end;

    /// <summary>
    /// ViewExports.
    /// </summary>
    /// <param name="ExportRecordKey">Code[20].</param>
    /// <param name="tableId">Integer.</param>
    procedure ViewExports(ExportRecordKey: Code[20]; tableId: Integer)
    var
        SBCOEExport: Record "SBCOE Export";

    begin
        if not GuiAllowed then
            exit;
        if not GetExports(ExportRecordKey, tableId, SBCOEExport) then
            exit;
        OpenPage(SBCOEExport);
    end;

    /// <summary>
    /// ViewExports.
    /// </summary>
    /// <param name="ExportRecordGUID">Guid.</param>
    /// <param name="tableId">Integer.</param>
    procedure ViewExports(ExportRecordGUID: Guid; tableId: Integer)
    var
        SBCOEExport: Record "SBCOE Export";
    begin
        if not GuiAllowed then
            exit;
        if not GetExports(ExportRecordGUID, tableId, SBCOEExport) then
            exit;
        OpenPage(SBCOEExport);
    end;

    /// <summary>
    /// This procedure is the entry point that allows adding an ERP record to an export.
    /// </summary>
    /// <param name="ExportDocumentKey">Code[20].</param>
    /// <param name="ExportDocumentSystemId">Guid.</param>
    /// <param name="ExportTableNo">Integer.</param>
    /// <param name="ExportRowType">Enum "SBCOE Row Type".</param>
    procedure AddExportEntry(ExportDocumentKey: Code[20]; ExportDocumentSystemId: Guid; ExportTableNo: Integer; ExportRowType: Enum "SBCOE Row Type")
    var
        SBCOEExportEntry: Record "SBCOE Export Entry";
    begin
        if Rec."Export Entry No." = 0 then
            exit;
        SBCOEExportEntry.Init();
        SBCOEExportEntry."Export Entry No." := Rec."Export Entry No.";
        SBCOEExportEntry."Export Document Key" := ExportDocumentKey;
        SBCOEExportEntry."Export System ID" := ExportDocumentSystemId;
        SBCOEExportEntry.Validate("Export Table No.", ExportTableNo);
        SBCOEExportEntry."Row Type" := ExportRowType;
        SBCOEExportEntry.Insert(true);
    end;

    internal procedure EmailExportAsAttachment(EmailGroupCode: Code[20]; AttachmentName: Text[250]; AttachmentMimeType: Text[250]; ContactEmailList: List of [Text])
    var
        SBCOEExportEmailGroup: Record "SBCOE Export Email Group";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailHtmlFormatted: Boolean;
        ContactRecipient: Text;
        EmailBody: Text;
        EmailSubject: Text;
    begin
        if not Rec."Export Data".HasValue() and not Rec.GetExportDefinition()."Notification Only"  then
            exit;

        SBCOEExportEmailGroup.Get(EmailGroupCode);
        SetEmailBodyAndSubject(EmailBody, EmailSubject, EmailHtmlFormatted);
        EmailMessage := SBCOEExportEmailGroup.CreateEmailMessage(EmailSubject, EmailBody, EmailHtmlFormatted);
        Rec.CalcFields("Export Data");
        if not Rec.GetExportDefinition()."Notification Only" then
            AddAttachment(AttachmentName, AttachmentMimeType, EmailMessage);

        foreach ContactRecipient in ContactEmailList do
            EmailMessage.AddRecipient("Email Recipient Type"::"To", ContactRecipient);

        Email.AddRelation(EmailMessage, Rec.RecordId().TableNo(), Rec.SystemId, "Email Relation Type"::"Primary Source", "Email Relation Origin"::"Compose Context");
        CreateEmailMessageLog(EmailMessage, EmailSubject);
        Email.OpenInEditor(EmailMessage);
    end;

    // internal procedure ExportVendorOrders(var PurchaseHeader: Record "Purchase Header")
    // var
    //     SelectionFilterManagement: Codeunit SelectionFilterManagement;
    //     SBCPlant: Record "SBC Plant";
    // begin
    //     if not PurchaseHeader.HasFilter() then
    //         PurchaseHeader.SetRecFilter();
    //     PurchaseHeader.SetFilter("No.", SelectionFilterManagement.GetSelectionFilterForPurchaseHeader(PurchaseHeader));
    //     SBCPlant.SetRange(Enabled, true);
    //     if SBCPlant.IsEmpty() then
    //         exit;
    //     SBCPlant.FindSet();
    //     repeat
    //         Export(PurchaseHeader);
    //     until SBCPlant.Next() = 0;
    // end;

    internal procedure GetDocumentKeyFilterString() KeyString: Text
    var
        SBCOEExportEntry: Record "SBCOE Export Entry";
        TempSBCOEExportEntry: Record "SBCOE Export Entry" temporary;
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        TempRecRef: RecordRef;
    begin
        if not Rec.HasHeader(SBCOEExportEntry) then
            exit;

        SBCOEExportEntry.FindSet();
        repeat
            TempSBCOEExportEntry := SBCOEExportEntry;
            TempSBCOEExportEntry.Insert();
        until SBCOEExportEntry.Next() = 0;
        TempRecRef.GetTable(TempSBCOEExportEntry);

        KeyString := SelectionFilterManagement.GetSelectionFilter(TempRecRef, SBCOEExportEntry.FieldNo(SBCOEExportEntry."Export Document Key"));
    end;

    /// <summary>
    /// Returns the export definition for the export.
    /// </summary>
    /// <returns>Return variable SBCOEExportDefinition of type Record "SBCOE Export Definition".</returns>
    procedure GetExportDefinition() SBCOEExportDefinition: Record "SBCOE Export Definition"
    begin
        if not SBCOEExportDefinition.Get(Rec."Export Definition Code") then
            exit;
    end;

    internal procedure HasDetail(var SBCOEExportEntry: Record "SBCOE Export Entry"): Boolean
    begin
        SetDetailEntryFilters(SBCOEExportEntry);
        exit(not SBCOEExportEntry.IsEmpty());
    end;
    /// <summary>
    /// This procedure returns true if the Export has related entries.
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure HasEntries(): Boolean
    var
        SBCOEExportEntry: Record "SBCOE Export Entry";
    begin
        SetExportEntryFilters(SBCOEExportEntry);
        exit(not SBCOEExportEntry.IsEmpty());
    end;

    internal procedure HasFooter(var SBCOEExportEntry: Record "SBCOE Export Entry"): Boolean
    begin
        SetFooterEntryFilters(SBCOEExportEntry);
        exit(not SBCOEExportEntry.IsEmpty());
    end;

    internal procedure HasHeader(var SBCOEExportEntry: Record "SBCOE Export Entry"): Boolean
    begin
        SetHeaderEntryFilters(SBCOEExportEntry);
        exit(not SBCOEExportEntry.IsEmpty());
    end;

    internal procedure SetDetailEntryFilters(var SBCOEExportEntry: Record "SBCOE Export Entry")
    begin
        SetExportEntryFilters(SBCOEExportEntry);
        SBCOEExportEntry.SetRange("Row Type", "SBCOE Row Type"::Detail);
    end;

    internal procedure SetExportDefinitionFilters(var SBCOEExportDefinition: Record "SBCOE Export Definition")
    begin
        SBCOEExportDefinition.SetRange("Export Definition Code", Rec."Export Definition Code");
    end;

    internal procedure SetExportEntryFilters(var SBCOEExportEntry: Record "SBCOE Export Entry")
    begin
        SBCOEExportEntry.SetRange("Export Entry No.", "Export Entry No.");
    end;

    internal procedure SetFooterEntryFilters(var SBCOEExportEntry: Record "SBCOE Export Entry")
    begin
        SetExportEntryFilters(SBCOEExportEntry);
        SBCOEExportEntry.SetRange("Row Type", "SBCOE Row Type"::Footer);
    end;

    internal procedure SetHeaderEntryFilters(var SBCOEExportEntry: Record "SBCOE Export Entry")
    begin
        SetExportEntryFilters(SBCOEExportEntry);
        SBCOEExportEntry.SetRange("Row Type", "SBCOE Row Type"::Header);
    end;

    [TryFunction]
    internal procedure TryDownloadExportData()
    var
        SBCOEExportDefinition: Record "SBCOE Export Definition";
        ConfirmManagement: Codeunit "Confirm Management";
        ExportFile: InStream;
        DownloadFileName: Text;
    begin
        if not GuiAllowed then
            exit;

        if not "Export Data".HasValue() then
            Error(ThereIsNoDataErrorLabel);

        Rec.CalcFields(Rec."Export Data");
        Rec."Export Data".CreateInStream(ExportFile);
        SBCOEExportDefinition.SetRange("Export Definition Code", Rec."Export Definition Code");
        SBCOEExportDefinition.SetFilter("Export File Name", '<>%1', '');

        if SBCOEExportDefinition.FindFirst() then
            DownloadFileName := SBCOEExportDefinition.GetExportFileName()
        else
            DownloadFileName := Rec."Export Definition Code" + '.xlsx';

        if not DownloadFromStream(ExportFile, '', '', '', DownloadFileName) then
            Error(ExportDownloadFailedErrorLabel);

        Message(ExportDownloadCompleteLabel);
    end;

    internal procedure TryEmailExportAsAttachment() Complete: Boolean
    var
        ContactEmailList: List of [Text];
    begin
        Complete := TryEmailExportAsAttachment(ContactEmailList);
    end;

    internal procedure TryEmailExportAsAttachment(ContactEmailList: List of [Text]) Complete: Boolean
    var
        SBCOEExportDefinition: Record "SBCOE Export Definition";
        SBCOEExportOptions: Record "SBCOE Export Options";
        FileManagement: Codeunit "File Management";
        SBCOEErrorHelper: Codeunit "SBCOE Error Helper";
        ExportFileName: Text;
    begin
        SBCOEExportDefinition := Rec.GetExportDefinition();
        ExportFileName := SBCOEExportDefinition.GetExportFileName(SBCOEExportDefinition.GetTimestampFormatString(), Rec.GetDocumentKeyFilterString());

        Rec.EmailExportAsAttachment(Rec."Email Group Code", ExportFileName, FileManagement.GetFileNameMimeType(SBCOEExportDefinition.GetExportFileName()), ContactEmailList);

        Complete := true;
    end;

    internal procedure TryOpenEmailOutbox(): Boolean
    var
        TempEmailOutbox: Record "Email Outbox" temporary;
        Email: Codeunit Email;
        PageManagement: Codeunit "Page Management";
        EmailOutbox: Page "Email Outbox";
    begin
        if not GuiAllowed then
            exit;

        Email.GetEmailOutboxForRecord(Rec, TempEmailOutbox);
        if TempEmailOutbox.IsEmpty() then
            exit;

        EmailOutbox.SetTableView(TempEmailOutbox);
        EmailOutbox.SetRecord(TempEmailOutbox);
        exit(EmailOutbox.RunModal() = Action::RunObject);
    end;

    [TryFunction]
    internal procedure TryOpenSentEmails()
    var
        Email: Codeunit Email;
    begin
        if not GuiAllowed then
            exit;
        Email.OpenSentEmails(Rec.RecordId().TableNo(), Rec.SystemId);
    end;

    internal procedure ViewRecord(SBCOEExportEntry: Record "SBCOE Export Entry")
    begin
        SBCOEExportEntry.ViewRecord();
    end;

    local procedure CreateEmailMessageLog(var EmailMessage: Codeunit "Email Message"; var EmailSubject: Text)
    var
        SBCOEExportSendLog: Record "SBCOE Export Send Log";
    begin
        SBCOEExportSendLog.Init();
        SBCOEExportSendLog."Export Entry No." := Rec."Export Entry No.";
        SBCOEExportSendLog."Email Message Id" := EmailMessage.GetId();
        SBCOEExportSendLog."EMail Subject" := EmailSubject;
        SBCOEExportSendLog."Sender User ID" := UserId;
        SBCOEExportSendLog.Insert();
    end;

    local procedure DeleteEntries()
    var
        SBCOEExportEntry: Record "SBCOE Export Entry";
    begin
        SetExportEntryFilters(SBCOEExportEntry);
        if SBCOEExportEntry.IsEmpty() then
            exit;
        SBCOEExportEntry.DeleteAll(true);
    end;

    local procedure OpenPage(var SBCOEExport: Record "SBCOE Export")
    var
        PageManagement: Codeunit "Page Management";
    begin
        PageManagement.PageRunModal(SBCOEExport);
    end;

    local procedure RenameEntries()
    var
        SBCOEExportEntry: Record "SBCOE Export Entry";
    begin
        SetExportEntryFilters(SBCOEExportEntry);
        if SBCOEExportEntry.IsEmpty() then
            exit;
        SBCOEExportEntry.FindSet(true);
        repeat
            SBCOEExportEntry.Rename(Rec."Export Entry No.", SBCOEExportEntry."Export Table No.", SBCOEExportEntry.SystemId);
        until SBCOEExportEntry.Next() = 0;
    end;

    local procedure SetEmailBodyAndSubject(var EmailBody: Text; var EmailSubject: Text; var EmailHtmlFormatted: Boolean)
    var
        SBCOEExportDefinition: Record "SBCOE Export Definition";
        SBCOEExportOptions: Record "SBCOE Export Options";
    begin
        SBCOEExportOptions.Get();
        SBCOEExportDefinition := Rec.GetExportDefinition();
        EmailSubject := SBCOEExportDefinition.GetExportEmailSubject(SBCOEExportDefinition.GetTimestampFormatString(), Rec.GetDocumentKeyFilterString());
        EmailBody := SBCOEExportDefinition.GetBodyText(SBCOEExportDefinition.GetTimestampFormatString(), Rec.GetDocumentKeyFilterString());
        EmailHtmlFormatted := SBCOEExportDefinition."Email Body Is HTML";

        if EmailBody <> '' then
            exit;

        EmailBody := SBCOEExportOptions.GetBodyText();
        EmailHtmlFormatted := SBCOEExportOptions."Email Body Is HTML";
    end;

    local procedure SetExportFilters(var SBCOEExport: Record "SBCOE Export"; var SBCOEExportEntry: Record "SBCOE Export Entry"): Boolean
    var
        TempSBCOEExportEntry: Record "SBCOE Export Entry" temporary;
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        TempRecRef: RecordRef;
    begin
        if SBCOEExportEntry.IsEmpty() then
            exit;
        SBCOEExportEntry.FindSet();
        repeat
            TempSBCOEExportEntry := SBCOEExportEntry;
            TempSBCOEExportEntry.Insert();
        until SBCOEExportEntry.Next() = 0;
        TempRecRef.GetTable(TempSBCOEExportEntry);
        SBCOEExport.SetFilter("Export Entry No.", SelectionFilterManagement.GetSelectionFilter(TempRecRef, TempSBCOEExportEntry.FieldNo(TempSBCOEExportEntry."Export Entry No.")));
        exit(not SBCOEExport.IsEmpty());
    end;

    local procedure AddAttachment(var AttachmentName: Text[250]; var AttachmentMimeType: Text[250]; var EmailMessage: Codeunit "Email Message")
    var
        AttachmentInStream: InStream;
    begin
        Rec."Export Data".CreateInStream(AttachmentInStream);
        EmailMessage.AddAttachment(AttachmentName, AttachmentMimeType, AttachmentInStream);
    end;

    // local procedure Export(var PurchaseHeader: Record "Purchase Header")
    // var
    //     SBCOEExportVendorOrders: Report "SBCOE Export Vendor Orders";
    // begin
    //     SBCOEExportVendorOrders.SetTableView(PurchaseHeader);
    //     SBCOEExportVendorOrders.UseRequestPage(PurchaseHeader.Count() > 1);
    //     SBCOEExportVendorOrders.Run();
    // end;
}
