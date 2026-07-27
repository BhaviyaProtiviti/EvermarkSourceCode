pageextension 50107 "SBC Transfer Order" extends "Transfer Order"
{
    layout
    {
        addafter("In-Transit Code")
        {
            field("SBC Production Order No."; Rec."SBC Production Order No.")
            {
                ApplicationArea = All;
                Visible = true;
                Editable = false;
            }
        }
        addlast(General)
        {
            field("SBC Max Weight Req."; Rec."SBC Max Weight Req.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Max Weight Req. field.', Comment = 'lb';

                trigger OnValidate()
                var
                    Location: Record Location;
                    SBCSubcontracting: Codeunit "SBC Subcontracting";
                begin
                    if not Rec."SBC Max Weight Req." then
                        clear(Rec."SBC Max Weight Allowed")
                    else
                        if Location.Get(Rec."Transfer-from Code") and (Location."SBC Has Max Weight Req.") then begin
                            Rec."SBC Max Weight Req." := Location."SBC Has Max Weight Req.";
                            Rec."SBC Max Weight Allowed" := Location."SBC Transfer Max Weight Allow";
                            SBCSubcontracting.UpdateLineWeight(Rec."No.");
                        end;
                end;
            }
            field("SBC Max Weight Allowed"; Rec."SBC Max Weight Allowed")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the SBC Max Weight Allowed field.', Comment = 'lb';
            }
            field("SBC Total Order Weight"; Rec."SBC Total Order Weight")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the SBC Total Order Weight field.', Comment = '%';
            }
        }
    }
    actions
    {
        addafter("Get Bin Content")
        {
            action(SBC_RecalculateLineWeight)
            {
                ApplicationArea = All;
                Caption = 'Recalculate Line Weight';
                Image = Recalculate;
                
                trigger OnAction()
                var
                    SBCSubcontracting: Codeunit "SBC Subcontracting";
                begin
                    SBCSubcontracting.UpdateLineWeight(Rec."No.");
                end;
            }
        }
        addafter("Get Bin Content_Promoted")
        {
            actionref(RecalculateLineWeight_Promoted; sbc_RecalculateLineWeight)
            {
            }
        }
    }
}