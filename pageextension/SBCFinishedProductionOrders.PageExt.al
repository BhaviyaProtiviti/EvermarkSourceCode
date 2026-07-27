pageextension 50115 "SBC_Finished Production Orders" extends "Finished Production Orders"
{
    actions
    {
        addafter("Co&mments")
        {
            group(AssocPostedDoc)
            {
                Caption = 'Associated Posted Documents';
                Image = Documents;
                
                action(SBCPostedInv)
                {
                    Caption = 'Posted Purchase Invoice';
                    ApplicationArea = All;
                    Image = Document;

                    trigger OnAction()
                    var
                        SBCSubcontracting: Codeunit "SBC Subcontracting";
                    begin
                        SBCSubcontracting.GetPostPurchInv(Rec."SBC Original Purch Order No.");
                    end;
                }
                action(SBCPostedTransRec)
                {
                    Caption = 'Posted Transfer Receipt';
                    ApplicationArea = All;
                    Image = Document;

                    trigger OnAction()
                    var
                        SBCSubcontracting: Codeunit "SBC Subcontracting";
                    begin
                        SBCSubcontracting.GetTransRcpt(Rec."SBC Original Trans. Order No.");
                    end;
                }
                action(SBCPostedTransShip)
                {
                    Caption = 'Posted Transfer Shipment';
                    ApplicationArea = All;
                    Image = Document;

                    trigger OnAction()
                    var
                        SBCSubcontracting: Codeunit "SBC Subcontracting";
                    begin
                        SBCSubcontracting.GetTransShip(Rec."SBC Original Trans. Order No.");
                    end;
                }
            }
        }  
    }    
}
