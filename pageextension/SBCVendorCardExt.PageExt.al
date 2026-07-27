pageextension 50001 "SBC Vendor Card Ext" extends "Vendor Card"
{
    layout
    {
        addlast(General)
        {
            field("SBC Vendor Group Code"; Rec."SBC Vendor Group Code")
            {
                ApplicationArea = All;
                Editable = not Rec."SBC Sensitive Vendor";
                ShowMandatory = true;
                ToolTip = 'Specifies the value of the SBC Vendor Group Code field.';
            }
            field("SBC Sensitive Vendor"; Rec."SBC Sensitive Vendor")
            {
                ApplicationArea = All;
                ShowMandatory = true;
                ToolTip = 'Specifies the value of the SBC Sensitive Vendor field.';
            }
        }
        addafter("Pay-to Vendor No.")
        {
            field("SBC Use Buy-From Pricing"; Rec."SBC Use Buy-From Pricing")
            {
                ApplicationArea = All;
                Enabled = AllowSetUserPricing;
                ToolTip = 'Specifies whether to use child buy-from pricing for this pay-to vendor.';
            }
        }
        modify("Pay-to Vendor No.")
        {
            trigger OnAfterValidate()
            begin
                if Rec."No." <> Rec."Pay-to Vendor No." then
                    Rec."SBC Use Buy-From Pricing" := false;

                CurrPage.Update();
            end;
        }
        modify(Name)
        {
            ShowMandatory = true;

        }
        modify("Purchaser Code")
        {
            ShowMandatory = true;
        }
        modify(Address)
        {
            ShowMandatory = true;
        }
        modify("Phone No.")
        {
            ShowMandatory = true;
        }
        modify("E-Mail")
        {
            ShowMandatory = true;
        }
        modify("Primary Contact No.")
        {
            ShowMandatory = true;
        }
        modify("Preferred Bank Account Code")
        {
            ShowMandatory = true;
        }
        modify("Federal ID No.")
        {
            ShowMandatory = true;
        }
        modify("Payment Terms Code")
        {
            ShowMandatory = true;
        }
        modify("Payment Method Code")
        {
            ShowMandatory = true;
        }
        modify("IRS 1099 Code")
        {
            ShowMandatory = true;
        }
    }

    var
        AllowSetUserPricing: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        AllowSetUserPricing := (Rec."No." = Rec."Pay-to Vendor No.");
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        HasRequiredFields(true);
    end;

    local procedure HasRequiredFields(UseConfirm: Boolean): Boolean
    var
        RequiredFields: List of [Text];
    begin
        if Rec.Name = '' then
            RequiredFields.Add('Name');
        if Rec."Purchaser Code" = '' then
            RequiredFields.Add('Purchaser Code');
        if Rec.Address = '' then
            RequiredFields.Add('Address');
        if (Rec."Phone No." = '') and (Rec."E-Mail" = '') then
            RequiredFields.Add('Phone No. or E-Mail');
        if Rec."Primary Contact No." = '' then
            RequiredFields.Add('Primary Contact No.');
        if (Rec."SBC Vendor Group Code" = '') and (not Rec."SBC Sensitive Vendor") then
            RequiredFields.Add('SBC Vendor Group Code or SBC Sensitive Vendor');
        if Rec."Preferred Bank Account Code" = '' then
            RequiredFields.Add('Preferred Bank Account Code');
        if Rec."Federal ID No." = '' then
            RequiredFields.Add('Federal ID No.');
        if Rec."Payment Terms Code" = '' then
            RequiredFields.Add('Payment Terms Code');
        if Rec."Payment Method Code" = '' then
            RequiredFields.Add('Payment Method Code');
        if Rec."IRS 1099 Code" = '' then
            RequiredFields.Add('IRS 1099 Code');

        if RequiredFields.Count >= 1 then
            CreateNotification(RequiredFields, UseConfirm);
    end;

    local procedure CreateNotification(RequiredFields: List of [Text]; UseConfirm: Boolean): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
        RequiredField: Text;
        TxtBuilder: TextBuilder;
    begin
        TxtBuilder.Append('The following fields are required: \');
        foreach RequiredField in RequiredFields do begin
            TxtBuilder.Append(RequiredField + '\');
        end;

        if UseConfirm then
            if Confirm(TxtBuilder.ToText() + ' Do you want to stay to populate?') then
                Error('');
    end;
}
