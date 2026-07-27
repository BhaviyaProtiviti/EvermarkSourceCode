/// <summary>
/// PageExtension STA Sales Order Subform (ID 50203) extends Record Sales Order Subform.
/// </summary>
pageextension 50203 "SBCTA Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                "Apply Country Specific Unit Price"();
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                "Apply Country Specific Unit Price"();
            end;
        }
        modify("Unit of Measure Code")
        {
            trigger OnAfterValidate()
            begin
                "Apply Country Specific Unit Price"();
            end;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        "Apply Country Specific Unit Price"();
        "Assign Country Code to Sales Line"();
    end;

    local procedure "Assign Country Code to Sales Line"()
    begin
        if SalesHeaer.Get(Rec."Document Type", Rec."Document No.") then begin
            if SalesHeaer."Ship-to Country/Region Code" = 'US' then
                Rec."Shortcut Dimension 2 Code" := 'USA';
            if SalesHeaer."Ship-to Country/Region Code" = 'CA' then
                Rec."Shortcut Dimension 2 Code" := 'CANADA';
            if SalesHeaer."Ship-to Country/Region Code" = 'MX' then
                Rec."Shortcut Dimension 2 Code" := 'MEXICO';
            if SalesHeaer."Ship-to Country/Region Code" = 'PH' then
                Rec."Shortcut Dimension 2 Code" := 'PHILIPPINES';
            if SalesHeaer."Ship-to Country/Region Code" = 'PA' then
                Rec."Shortcut Dimension 2 Code" := 'PANAMA';
        end;
    end;

    local procedure "Apply Country Specific Unit Price"()
    begin
        if SalesHeaer.Get(Rec."Document Type", Rec."Document No.") then begin
            BracketPrices.SetFilter("Item No.", '%1', Rec."No.");
            BracketPrices.SetFilter("Country Code", '%1', SalesHeaer."Ship-to Country/Region Code");
            BracketPrices.SetFilter(Active, '%1', true);
            if BracketPrices.FindFirst() then begin
                if Rec."Unit of Measure Code" = 'CS' then
                    Rec."Unit Price" := BracketPrices."Bracket Case Price";
                if Rec."Unit of Measure Code" = 'EA' then
                    Rec."Unit Price" := BracketPrices."Bracket Unit Price";
            end;
        end;
    end;

    var
        SalesHeaer: Record "Sales Header";
        BracketPrices: Record "STA Bracket Price";
}