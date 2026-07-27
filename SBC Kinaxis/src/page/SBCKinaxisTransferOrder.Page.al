page 50143 "SBC Kinaxis Transfer Order"
{
    APIGroup = 'kinaxis';
    APIPublisher = 'tigunia';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'kinaxisTransferOrder';
    DelayedInsert = true;
    EntityName = 'tigTransferOrder';
    EntitySetName = 'tigTransferOrders';
    ODataKeyFields = SystemId;
    PageType = API;
    // pagetype = List;
    SourceTable = "Transfer Header";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    caption = 'id';
                }
                field(no; Rec."No.")
                {
                    Caption = 'no';
                }
                field(inTransitCode; InTransitCode)
                {
                    Caption = 'inTransitCode';

                    trigger OnValidate()
                    begin
                        Rec."In-Transit Code" := InTransitCode;
                    end;
                }
                field(transferFromCode; TransferFromCode)
                {
                    Caption = 'transferFromCode';

                    trigger OnValidate()
                    var
                        Location: Record Location;
                    begin
                        Rec."Transfer-From Code" := TransferFromCode;
                        if Location.Get(Rec."Transfer-From Code") then begin
                            Rec."Transfer-From Name" := Location.Name;
                            Rec."Transfer-From Address" := Location.Address;
                            Rec."Transfer-From Address 2" := Location."Address 2";
                            Rec."Transfer-From City" := Location.City;
                            Rec."Transfer-From Post Code" := Location."Post Code";
                            Rec."Transfer-From County" := Location.County;
                            Rec."Trsf.-from Country/Region Code" := Location."Country/Region Code";
                            Rec."Transfer-From Contact" := Location.Contact;
                        end
                    end;
                }
                field(transferToCode; TransferToCode)
                {
                    Caption = 'transferToCode';

                    trigger OnValidate()
                    var
                        Location: Record Location;
                    begin
                        Rec."Transfer-To Code" := TransferToCode;
                        if Location.Get(Rec."Transfer-To Code") then begin
                            Rec."Transfer-To Name" := Location.Name;
                            Rec."Transfer-To Address" := Location.Address;
                            Rec."Transfer-To Address 2" := Location."Address 2";
                            Rec."Transfer-To City" := Location.City;
                            Rec."Transfer-To Post Code" := Location."Post Code";
                            Rec."Transfer-To County" := Location.County;
                            Rec."Trsf.-to Country/Region Code" := Location."Country/Region Code";
                            Rec."Transfer-To Contact" := Location.Contact;
                        end
                    end;
                }
                part(transferOrderLines; "SBC Kinaxis Trans Order Lines")
                {
                    Caption = 'lines';
                    EntityName = 'tigTransferLine';
                    EntitySetName = 'tigTransferLines';
                    SubPageLink = "Document No." = field("No.");
                }
            }
        }
    }

    var
        KinaxisInternalHdlr: Codeunit "SBC Kinaxis Internal Hdlr";
        TransferToCode: Code[10];
        TransferFromCode: Code[10];
        InTransitCode: Code[10];

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        clear(TransferToCode);
        clear(TransferFromCode);
        clear(InTransitCode);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        PopulateVars();
    end;

    trigger OnAfterGetRecord()
    begin
        PopulateVars();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        KinaxisInternalHdlr.Kinaxis_OnInsert(Rec);
    end;

    local procedure PopulateVars()
    begin
        TransferToCode := Rec."Transfer-To Code";
        TransferFromCode := Rec."Transfer-from Code";
        InTransitCode := Rec."In-Transit Code";
    end;
}
