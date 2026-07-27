/// <summary>
/// Resends a Vena job to the API based on the Vena Job Status record.
/// </summary>
codeunit 50258 "SBC Resend Vena Job"
{
    TableNo = "SBC Vena Job Status";

    trigger OnRun()
    begin
        Code(Rec);
    end;

    var
        VenaCSVErrorLabel: Label 'Vena CSV is empty.';

    local procedure Code(var SBCVenaJobStatus: Record "SBC Vena Job Status")
    var
        SBCSyncVenaJob: Codeunit "SBC Sync Vena Job";
        SBCVenaHelper : Codeunit "SBC Vena Helper";
        TempBlob: Codeunit "Temp Blob";
    begin
        SBCSyncVenaJob.SetResentFromEntryNo(SBCVenaJobStatus."Entry No.");
        SBCVenaJobStatus.CalcFields(SBCVenaJobStatus."Vena CSV");
        if not SBCVenaJobStatus."Vena CSV".HasValue() then
            SBCVenaHelper.SetErrorMessage(SBCVenaJobStatus.RecordId(), SBCVenaJobStatus.FieldNo("Vena CSV"), VenaCSVErrorLabel, true);

        TempBlob.FromFieldRef(SBCVenaJobStatus.RecordId().GetRecord().Field(SBCVenaJobStatus.FieldNo("Vena CSV")));
        if not TempBlob.HasValue() then
            exit;
        SBCSyncVenaJob.SendVenaRequest(SBCVenaJobStatus."Vena Job Code", SBCVenaJobStatus."Vena Template ID", SBCVenaJobStatus."Vena API Endpoint Path", TempBlob);
    end;

}