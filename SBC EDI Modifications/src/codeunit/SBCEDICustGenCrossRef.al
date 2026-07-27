codeunit 50156 "SBC EDI Cust Gen Cross Ref"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Page, Page::"LAX EDI GeneralCrossRef Types", 'OnAfterSetCustomRange', '', false, false)]
    procedure SetAdditionalCustomRange(var EDIGenCrossRefType: record "LAX EDI Gen. Cross Ref. Type")
    var
        EDIInventoryAdviceHdr: Record "LAX EDI Inventory Advice Hdr.";
        EDIGenCrossRefTypes: page "LAX EDI GeneralCrossRef Types";
        TableName: Text[250];
        CrossReferenceType: Text[250];
        i: Integer;
    begin

        EDIGenCrossRefType."Entry No." := 50001;
        EDIGenCrossRefType."Cross Reference" := 50001;
        EDIGenCrossRefType."Cross Reference Type" := 'Gen. Product Posting Group';
        EDIGenCrossRefType."Table Name" := EDIInventoryAdviceHdr.TableCaption;
        EDIGenCrossRefType.Insert();
    end;


    [EventSubscriber(ObjectType::Table, Database::"LAX EDI General Cross Ref.", 'OnAfterValidateCrossReference', '', false, false)]
    local procedure OnAfterValidateCrossReference(LAXEDIGeneralCrossRef: Record "LAX EDI General Cross Ref.")
    begin
        case LAXEDIGeneralCrossRef."Cross Reference" of
            50001:
                LAXEDIGeneralCrossRef."Table No. (Cross Ref.)" := Database::"Gen. Business Posting Group";

        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"LAX EDI General Cross Ref.", 'OnAfterGetLookupValuePage', '', false, false)]
    local procedure GetLookupValuePage(LAXEDIGeneralCrossRef: Record "LAX EDI General Cross Ref."; var ReturnValue: Code[40]; var ValueFound: Boolean)
    var
        GenBusPostingGroup: Record "Gen. Business Posting Group";
    begin
        case LAXEDIGeneralCrossRef."Table No. (Cross Ref.)" of
            Database::"Gen. Business Posting Group":
                if Page.RunModal(0, GenBusPostingGroup) in [Action::LookupOK, Action::OK]
               then begin
                    ReturnValue := GenBusPostingGroup.Code;
                    ValueFound := true;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"LAX EDI General Cross Ref.", 'OnAfterSetCrossReferenceTypeDescription', '', false, false)]
    local procedure SetCrossReferenceTypeDescription(LAXEDIGeneralCrossRef: Record "LAX EDI General Cross Ref."; var ReturnValue: Text[250]; var ValueFound: Boolean)
    var
        lblGenBusPostingGroup: Label 'Gen. Business Posting Group';
    begin
        case LAXEDIGeneralCrossRef."Cross Reference" of
            50001:
                begin
                    ReturnValue := lblGenBusPostingGroup;
                    ValueFound := true;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"LAX EDI General Cross Ref.", 'OnAfterSetCrossReferenceTableName', '', false, false)]
    local procedure SetCrossReferenceTableName(LAXEDIGeneralCrossRef: Record "LAX EDI General Cross Ref."; var ReturnValue: Text[250]; var ValueFound: Boolean)
    var
        lblInventoryAdviceLine: Label 'EDI Inventory Advice Hdr.';
    begin
        case LAXEDIGeneralCrossRef."Cross Reference" of
            50001:
                begin
                    ReturnValue := lblInventoryAdviceLine;
                    ValueFound := true;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"LAX EDI General Cross Ref.", 'OnAfterAssignAssocTablebyFunctionalArea', '', false, false)]
    local procedure AssignAssocTablebyFunctionalArea(var LAXEDIGeneralCrossRef: Record "LAX EDI General Cross Ref.")
    var
        EDIInventoryAdviceHdr: Record "LAX EDI Inventory Advice Hdr.";
        AllObj: Record AllObj;
        Field: Record Field;
    begin
        case LAXEDIGeneralCrossRef."Cross Reference" of
            50001:
                begin
                    AllObj.Reset;
                    AllObj.SetRange("Object ID", Database::"LAX EDI Inventory Advice Hdr.");
                    if AllObj.Find('-') then begin
                        LAXEDIGeneralCrossRef."Table No." := Database::"LAX EDI Inventory Advice Hdr.";
                        LAXEDIGeneralCrossRef."Table Name" := EDIInventoryAdviceHdr.TableCaption;
                        LAXEDIGeneralCrossRef."Table No. (Cross Ref.)" := Database::"Gen. Business Posting Group";
                        LAXEDIGeneralCrossRef."Functional Area" := LAXEDIGeneralCrossRef."Functional Area"::"General Ledger";
                        Field.Reset;
                        Field.SetRange(TableNo, DATABASE::"LAX EDI Inventory Advice Hdr.");
                    end;
                    case LAXEDIGeneralCrossRef."Cross Reference" of
                        50001:
                            begin
                                Field.SetRange("No.", EDIInventoryAdviceHdr.FieldNo("Adj Code"));
                                if Field.Find('-') then begin
                                    LAXEDIGeneralCrossRef."Field No." := EDIInventoryAdviceHdr.FieldNo("Adj Code");
                                    LAXEDIGeneralCrossRef."Field Name" := ConvertStr(Field.FieldName, '_', ' ');
                                    LAXEDIGeneralCrossRef."Data Type" := Format(Field.Type);
                                end;
                            end;
                    end;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Evaluate Cross Ref.", 'OnAfterSetCrossReferenceNo', '', false, false)]
    local procedure SetCrossReferenceNo(EDIRecDocField: Record "LAX EDI Receive Document Field"; var CrossReference: Integer)
    var
        EDIInventoryAdviceHdr: Record "LAX EDI Inventory Advice Hdr.";
    begin
        case EDIRecDocField."Table No." of
            Database::"LAX EDI Inventory Advice Hdr.":
                begin
                    case EDIRecDocField."Field No." of
                        EDIInventoryAdviceHdr.FieldNo("Adj Code"):
                            CrossReference := 50001;
                    end;
                end;
        end;
    end;


}

