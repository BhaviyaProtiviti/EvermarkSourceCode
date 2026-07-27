tableextension 50361 "SBC Kinaxis User Setup" extends "User Setup"
{
    fields
    {
        field(50359; "SBC Kinaxis Planner Name"; Code[20])
        {
            Caption = 'SBC Kinaxis Planner Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."SBC Kinaxis Planner Name" <> '' then
                    TestUniquePlannerName();
            end;
        }
    }

    procedure TestUniquePlannerName()
    var
        UserSetup: Record "User Setup";
        PlannerLbl: label 'Kinaxis Planner Name has already been added to another user. Planner name must be unique';
    begin
        UserSetup.SetFilter("User ID", '<>%1', Rec."User ID");
        UserSetup.SetRange("SBC Kinaxis Planner Name", Rec."SBC Kinaxis Planner Name");
        if not UserSetup.IsEmpty() then
            Error(PlannerLbl);
    end;
}
