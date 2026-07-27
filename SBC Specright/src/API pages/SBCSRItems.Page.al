page 50186 "SBC SR Item Tables"
{
    APIGroup = 'SpecRight';
    APIPublisher = 'SBC';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'sbcSpecRightItems';
    DelayedInsert = true;
    EntityName = 'SpecRightItems';
    EntitySetName = 'SpecRightItems';
    PageType = API;
    SourceTable = Item;
    ODataKeyFields = SystemId;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Id"; Rec.SystemId)
                {

                }
                field("Name"; Rec."No.")
                {

                }
                field("CreatedDate"; Rec."SBC Created Date")
                {

                }
                field("specright__Description2__c"; Rec.Description)
                {

                }
                field("SR_Auto_Number__c"; Rec."No. 2")
                {

                }
                field("SR_GTIN__c"; Rec.GTIN)
                {

                }
                field("SR_Product_Description__c"; Rec.Description)
                {

                }
                field("SR_Shelf_Life_Days__c"; Rec."SBC Shelf Life (Days)")
                {

                }
                field("SR_Item_Category_Code__c"; Rec."Item Category Code")
                {

                }
                field("Minimum_Order_Quantity__c"; Rec."Minimum Order Quantity")
                {

                }
                field("SR_Unit_Price__c"; Rec."Unit Price")
                {

                }
                field("SR_Tariff_No__c"; Rec."Tariff No.")
                {

                }


            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}