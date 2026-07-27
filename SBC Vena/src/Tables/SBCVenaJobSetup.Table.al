/// <summary>
/// Table SBC Vena Job Setup (ID 50257).
/// </summary>
table 50257 "SBC Vena Job Setup"
{
    Caption = 'SBC Vena Job Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "SBC Vena Job Setup";
    LookupPageId = "SBC Vena Job Setup";

    fields
    {
        field(1; "Vena Job Code"; Code[20])
        {
            Caption = 'Vena Job Code';
        }
        field(2; Description; Text[200])
        {
            Caption = 'Description';
        }
        field(3; "Vena API Endpoint Path"; Text[200])
        {
            Caption = 'Vena API Endpoint Path';
        }
        field(4; "Vena Template ID"; Text[20])
        {
            Caption = 'Vena Template ID';
        }
        field(5; "ERP Table Name"; Text[30])
        {
            Caption = 'ERP Table Name';
            trigger OnValidate()
            begin
                SetERPTableID();
            end;
        }
        field(6; "ERP Table ID"; Integer)
        {
            Caption = 'ERP Table ID';
        }
        field(7; "ERP Table Filter"; Blob)
        {
            Caption = 'ERP Table Filter';
        }
        field(8; "CSV Template"; Blob)
        {
            Caption = 'CSV Template';
            Description = 'Add your header file template here.';
        }

        field(9; "Last Entry No. Exported"; Text[20])
        {
            Caption = 'Last Entry No. Exported';
            Description = 'The last entry number that was exported to Vena.';
        }
        field(10; "Connection String"; Text[2048])
        {
            Caption = 'Connection String';
            DataClassification = CustomerContent;
            Description = 'The connection string used to connect to the external resource.';
            ExtendedDatatype = Masked;
            trigger OnValidate()
            begin
                GlobalSBCVenaHelper.SetAuthenticationValue(GetConnectionStringLabel(), Rec."Connection String");
                Rec."Connection String" := MaskPlaceholderLabel;
            end;

        }

        field(20; "Max Rows Per Export"; Integer)
        {
            BlankZero = true;
            Caption = 'Max Rows Per Export';
            Description = 'The maximum number of rows to export to Vena. Rows in excess of this number will be split into additional exports.';
        }

    }
    keys
    {
        key(PK; "Vena Job Code")
        {
            Clustered = true;
        }
    }


    var
        GlobalSBCVenaHelper: Codeunit "SBC Vena Helper";
        MaskPlaceholderLabel: Label '********', Locked = true;
        VenaJobConnectionStringLabel: Label '%Connection', Locked = true;
        CSVFileExtension: Label '.csv', Locked = true;
        CSVFilterTextLabel: Label 'CSV (*.csv)|*.csv', Locked = true;
        DownloadTemplateConfirmLabel: Label 'Would you like to download the current template?';
        ErpTableNameErrorLabel: Label 'ERP Table Name must be set before setting the filter.';
        ExportDialogTitleLabel: Label 'Export Template';
        OverwriteExistingTemplateWarningLabel: Label 'The current template will be overwritten. Do you want to continue?';
        TemplateDownloadFailedErrorLabel: Label 'Template Download failed: %1';
        NoFieldFoundNotificationErrorLabel: Label 'No fields found for the selected table.';

    internal procedure UpdateERPTableFilter(ErpTableNo: Integer) NewErpTableFilter: Text
    var
        ErpTableRecordRef: RecordRef;
        VenaFilterPageBuilder: FilterPageBuilder;
        ERPFilterTextInStream: InStream;
        CurrentERPFilterText: Text;
        ExistingErpTableFilter: Text;
        CurrentERPFilterTextBuilder: TextBuilder;
    begin
        if Rec."ERP Table ID" = 0 then
            Error(ErrorInfo.Create(ErpTableNameErrorLabel, false, Rec, Rec.FieldNo("ERP Table Name")));
        Rec.CalcFields("ERP Table Filter");

        Rec."ERP Table Filter".CreateInStream(ERPFilterTextInStream);
        if Rec."ERP Table Filter".HasValue() then begin
            while not ERPFilterTextInStream.EOS do begin
                ERPFilterTextInStream.ReadText(CurrentERPFilterText);
                CurrentERPFilterTextBuilder.Append(CurrentERPFilterText);
            end;
            ExistingErpTableFilter := CurrentERPFilterTextBuilder.ToText();
        end;
        ErpTableRecordRef.Open(ErpTableNo);
        VenaFilterPageBuilder.AddRecordRef(ErpTableRecordRef.Name(), ErpTableRecordRef);

        if not VenaFilterPageBuilder.SetView(ErpTableRecordRef.Name(), ExistingErpTableFilter) then
            VenaFilterPageBuilder.SetView(ErpTableRecordRef.Name(), ErpTableRecordRef.GetView()); // Set Default view
        if not VenaFilterPageBuilder.RunModal() then
            exit;

        NewErpTableFilter := VenaFilterPageBuilder.GetView(ErpTableRecordRef.Name());

        // if Rec."ERP Table Filter".HasValue() then;
        SetOutstreamValue(VenaFilterPageBuilder.GetView(ErpTableRecordRef.Name()));
    end;

    local procedure SetERPTableID()
    var
        TableMetadata: Record "Table Metadata";
    begin
        Rec."ERP Table ID" := 0;
        TableMetadata.SetLoadFields(ID);
        TableMetadata.SetFilter(Name, '%1', Rec."ERP Table Name");
        if TableMetadata.IsEmpty() then
            exit;
        TableMetadata.FindFirst();
        Rec."ERP Table ID" := TableMetadata.ID;
    end;

    internal procedure UploadFile() SelectedPath: Text
    var
        ConfirmManagement: Codeunit "Confirm Management";
        UploadedInStream: InStream;
        UploadOutStream: OutStream;
    begin
        Rec.CalcFields(Rec."CSV Template");


        if Rec."CSV Template".HasValue() then begin
            if not ConfirmManagement.GetResponseOrDefault(OverwriteExistingTemplateWarningLabel, true) then
                exit;
            if not DownloadExistingTemplate() and GuiAllowed then
                Message(TemplateDownloadFailedErrorLabel, GetLastErrorText());
        end;

        Rec."CSV Template".CreateInStream(UploadedInStream);
        if not UploadIntoStream(ExportDialogTitleLabel, '', Format(CSVFilterTextLabel), SelectedPath, UploadedInStream) then
            exit;
        Rec."CSV Template".CreateOutStream(UploadOutStream);
        if not CopyStream(UploadOutStream, UploadedInStream) then
            exit;
        Rec.Modify(true);
    end;

    [TryFunction]
    local procedure DownloadExistingTemplate()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        CurrentTemplateInStream: InStream;
        DownloadFileName: Text;
    begin
        if not GuiAllowed then
            exit;
        if not ConfirmManagement.GetResponseOrDefault(DownloadTemplateConfirmLabel, true) then
            exit;
        Rec.CalcFields(Rec."CSV Template");
        Rec."CSV Template".CreateInStream(CurrentTemplateInStream);
        DownloadFileName := Rec."Vena Job Code" + CSVFileExtension;
        DownloadFromStream(CurrentTemplateInStream, ExportDialogTitleLabel, '', '', DownloadFileName);
    end;

    #region "Connection String"
    local procedure GetConnectionStringLabel() ConnectionStringLabel: Text
    begin
        ConnectionStringLabel := StrSubstNo(Rec."Vena Job Code", VenaJobConnectionStringLabel);
    end;

    local procedure CreateNotification(NotificationText: Text)
    var
        NotificationInstance: Notification;
    begin
        if NotificationText = '' then
            exit;
        NotificationInstance.Message(NoFieldFoundNotificationErrorLabel);
        NotificationInstance.Scope := NotificationScope::LocalScope;
        NotificationInstance.Send();
    end;

    local procedure SetOutstreamValue(ViewText: text) NewFilter: Text
    var
        SBCVenaJobSetup: Record "SBC Vena Job Setup";
        ErpTableFilterOutStream: OutStream;
        // EmptyText: Text;
        NewFilterTExtbuilder: TextBuilder;
        ERPFilterTextInStream: InStream;
    begin
        SBCVenaJobSetup := Rec;
        SBCVenaJobSetup.CalcFields(SBCVenaJobSetup."ERP Table Filter");
        SBCVenaJobSetup."ERP Table Filter".CreateInStream(ERPFilterTextInStream);
        While not ERPFilterTextInStream.EOS() do begin
            ERPFilterTextInStream.ReadText(NewFilter);
            NewFilterTExtbuilder.Append(NewFilter);
        end;
        NewFilter := NewFilterTExtbuilder.ToText().Trim();
        NewFilterTExtbuilder.Clear();
        Clear(SBCVenaJobSetup."ERP Table Filter");
        SBCVenaJobSetup.Modify();
        SBCVenaJobSetup.CalcFields("ERP Table Filter");
        SBCVenaJobSetup."ERP Table Filter".CreateOutStream(ErpTableFilterOutStream);

        if ViewText.Contains('WHERE') then
            ErpTableFilterOutStream.WriteText(ViewText);

        if SBCVenaJobSetup.Modify() then
            Commit();
        Clear(ERPFilterTextInStream);
        SBCVenaJobSetup."ERP Table Filter".CreateInStream(ERPFilterTextInStream);
        While not ERPFilterTextInStream.EOS() do begin
            ERPFilterTextInStream.ReadText(NewFilter);
            NewFilterTExtbuilder.Append(NewFilter);
        end;
        NewFilter := NewFilterTExtbuilder.ToText();
    end;


#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure GetConnectionValue() Value: Text
    begin
        IsolatedStorage.Get(GetConnectionStringLabel(), DataScope::Module, Value);
    end;


#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure ConnectionValueSet() Result: Boolean
    begin
        Result := IsolatedStorage.Contains(GetConnectionStringLabel(), DataScope::Module);
    end;

    internal procedure SetTableFieldsAsColumns()
    var
        VenaJobSetupLines: Record "SBC Vena Job Setup Line";
        Field: Record Field;
        LastColumnNo: Integer;
    begin
        Field.SetRange(TableNo, Rec."ERP Table ID");
        Field.SetFilter(ObsoleteState, '%1|%2', Field.ObsoleteState::No, Field.ObsoleteState::Pending);
        if Field.IsEmpty() then begin
            CreateNotification(NoFieldFoundNotificationErrorLabel);
            exit;
        end;
        Field.SetLoadFields("No.");
        Field.FindSet();
        VenaJobSetupLines.SetRange("Vena Job Code", Rec."Vena Job Code");
        VenaJobSetupLines.SetRange("ERP Table ID", Rec."ERP Table ID");
        VenaJobSetupLines.SetAscending("Column No.", true);
        if VenaJobSetupLines.FindLast() then
            LastColumnNo := VenaJobSetupLines."Column No.";
        repeat
            VenaJobSetupLines.SetFilter("ERP Field ID", '%1', Field."No."); // Attempts to not double add fields that already exist. The user can manually duplicate columns if that is necessary.
            if VenaJobSetupLines.IsEmpty() then begin
                VenaJobSetupLines.Init();
                VenaJobSetupLines."Vena Job Code" := Rec."Vena Job Code";
                VenaJobSetupLines."ERP Table ID" := Rec."ERP Table ID";
                VenaJobSetupLines."Column No." := LastColumnNo + 1;
                VenaJobSetupLines."ERP Field ID" := Field."No.";
                LastColumnNo += 1;
                VenaJobSetupLines.Insert();
            end;
        until Field.Next() = 0;

    end;



    #endregion
}