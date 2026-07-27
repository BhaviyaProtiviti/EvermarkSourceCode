pageextension 50150 "SBC LAX EDI Setup" extends "LAX EDI Setup"
{
    layout
    {
        addafter(Alerts)
        {
            group(SBC945ItemInv)
            {
                Caption = '945 Update Item Inventory';

                field("SBC 945 Adjust Inventory"; Rec."SBC 945 Adjust Inventory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if 945 Adjust Inventory allowed.';
                    ShowMandatory = true;
                }
                field("SBC 945 Journal Template Name"; Rec."SBC 945 Journal Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC 945 Journal Template Name field.';
                    ShowMandatory = true;
                    Editable = Rec."SBC 945 Adjust Inventory";
                }
                field("SBC 945 Journal Batch Name"; Rec."SBC 945 Journal Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC 945 Journal Batch Name field.';
                    ShowMandatory = true;
                    Editable = Rec."SBC 945 Adjust Inventory";
                }
                field("SBC 945 Document No."; Rec."SBC 945 Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC 945 Document No. field.';
                    ShowMandatory = true;
                    Editable = Rec."SBC 945 Adjust Inventory";
                }
                field("SBC Journal Location Code"; Rec."SBC Journal Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC Journal Location Code field.';
                    ShowMandatory = true;
                    Editable = Rec."SBC 945 Adjust Inventory";
                }
                field("SBC Skip Trans Order 945"; Rec."SBC Skip Trans Order 945")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Skip Transfer Order 945 Inv. Adj. field.';
                }
            }
            group(SBC846InventoryAdj)
            {
                Caption = '846 Inventory Adjustment';

                field("SBC 846 Inventory Floor"; Rec."SBC 846 Positive Adj. Only")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if 846 Inventory Floor equal to zero will be inforced.';
                }
            }
            group(SBC810CreateShipment)
            {
                Caption = '810 Create missing shipments';
                Visible = false;

                field("SBC 810 Allow Create Shipment"; Rec."SBC 810 Allow Create Shipment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 810 Allows Create Shimpents field.';
                    Visible = false;
                }
                field("SBC 810 Journal Template Name"; Rec."SBC 810 Journal Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 810 Journal Template Name field.';
                    Editable = Rec."SBC 810 Allow Create Shipment";
                    Visible = false;
                }
                field("SBC 810 Journal Batch Name"; Rec."SBC 810 Journal Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 810 Journal Batch Name field.';
                    Editable = Rec."SBC 810 Allow Create Shipment";
                    Visible = false;
                }
                field("SBC 810 Document No."; Rec."SBC 810 Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 810 Document No. field.';
                    Editable = Rec."SBC 810 Allow Create Shipment";
                    Visible = false;
                }
            }
        }
    }
}
