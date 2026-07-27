/// <summary>
/// TableExtension SBCOE Vendor (ID 50061) extends Record Vendor.
/// </summary>
tableextension 50061 "SBCOE Vendor" extends Vendor
{
    fields
    {
        field(50060; "SBCOE Export Definition"; Code[20])
        {
            Caption = 'Export Template';
            DataClassification = CustomerContent;
            Description = 'This is export template that will be used for Excel Purchase Order exports for this Vendor.';
            TableRelation = "SBCOE Export Definition"."Export Definition Code";
        }
        field(50061; "SBCOE Email Group"; Code[20])
        {
            Caption = 'Email Group';
            DataClassification = CustomerContent;
            Description = 'These emails will be added to the email list when sending Excel Purchase Order exports.';
            TableRelation = "SBCOE Export Email Group"."Email Group Code";
        }
    }

    internal procedure GetExportContactEmailList() ContactEmailList: List of [Text]
    var
        SBCOEExportEmailGroup: Record "SBCOE Export Email Group";
    begin
        if Rec."No." = '' then
            exit;
        ContactEmailList := SBCOEExportEmailGroup.GetExportContactEmailList(Rec."No.", "Contact Business Relation Link To Table"::Vendor);
    end;
}
