/// <summary>
/// Codeunit SBC Upgrade (ID 50036).
/// </summary>
codeunit 50036 "SBC Upgrade"
{
    Subtype = Upgrade;
    SingleInstance = true;
    Permissions = 
        tabledata Item = R,
        tabledata "Purch. Inv. Line" = RM,
        tabledata "Purch. Rcpt. Line" = RM,
        tabledata "Purchase Line" = RM;

    trigger OnUpgradePerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeSBCPurchaseLine20230925) then
            UpgradeTag.SetUpgradeTag(UpgradeSBCPurchaseLine(UpgradeSBCPurchaseLine20230925));
        if not UpgradeTag.HasUpgradeTag(UpgradeSBCPurchaseInvLine20230925) then
            UpgradeTag.SetUpgradeTag(UpgradeSBCPurchaseInvLine(UpgradeSBCPurchaseInvLine20230925));
        if not UpgradeTag.HasUpgradeTag(UpgradeSBCPurchaseRcptLine20230925) then
            UpgradeTag.SetUpgradeTag(UpgradeSBCPurchaseRcptLine(UpgradeSBCPurchaseRcptLine20230925));
    end;

    /// <summary>
    /// Sets the plant code and item code on existing purchase lines.
    /// </summary>
    /// <param name="UpgradeTag">Code[250].</param>
    /// <returns>Return value of type Code[250].</returns>
    local procedure UpgradeSBCPurchaseLine(UpgradeTag: Code[250]): Code[250]
    var
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
    begin
        PurchaseLine.SetRange(Type, "Purchase Line Type"::Item);
        PurchaseLine.SetFilter("SBC Plant Item No.", '%1', '');
        PurchaseLine.SetFilter("SBC Plant Code", '%1', '');
        if PurchaseLine.IsEmpty() then
            exit(UpgradeTag);
        PurchaseLine.FindSet(true);
        repeat
            if GetSBCPurchaseLineItem(PurchaseLine."No.", Item) then begin
                PurchaseLine."SBC Plant Item No." := Item."SBC Plant Item No.";
                PurchaseLine."SBC Plant Code" := Item."SBC Plant Code";
                PurchaseLine.Modify();
            end;
        until PurchaseLine.Next() = 0;
        exit(UpgradeTag)
    end;
    /// <summary>
    /// Sets the plant code and item code on existing purchase lines.
    /// </summary>
    /// <param name="UpgradeTag">Code[250].</param>
    /// <returns>Return value of type Code[250].</returns>
    local procedure UpgradeSBCPurchaseRcptLine(UpgradeTag: Code[250]): Code[250]
    var
        PurchaseLine: Record "Purch. Rcpt. Line";
        Item: Record Item;
    begin
        PurchaseLine.SetRange(Type, "Purchase Line Type"::Item);
        PurchaseLine.SetFilter("SBC Plant Item No.", '%1', '');
        PurchaseLine.SetFilter("SBC Plant Code", '%1', '');
        if PurchaseLine.IsEmpty() then
            exit(UpgradeTag);
        PurchaseLine.FindSet(true);
        repeat
            if GetSBCPurchaseLineItem(PurchaseLine."No.", Item) then begin
                PurchaseLine."SBC Plant Item No." := Item."SBC Plant Item No.";
                PurchaseLine."SBC Plant Code" := Item."SBC Plant Code";
                PurchaseLine.Modify();
            end;
        until PurchaseLine.Next() = 0;
        exit(UpgradeTag)
    end;
    /// <summary>
    /// Sets the plant code and item code on existing purchase lines.
    /// </summary>
    /// <param name="UpgradeTag">Code[250].</param>
    /// <returns>Return value of type Code[250].</returns>
    local procedure UpgradeSBCPurchaseInvLine(UpgradeTag: Code[250]): Code[250]
    var
        PurchaseLine: Record "Purch. Inv. Line";
        Item: Record Item;
    begin
        PurchaseLine.SetRange(Type, "Purchase Line Type"::Item);
        PurchaseLine.SetFilter("SBC Plant Item No.", '%1', '');
        PurchaseLine.SetFilter("SBC Plant Code", '%1', '');
        if PurchaseLine.IsEmpty() then
            exit(UpgradeTag);
        PurchaseLine.FindSet(true);
        repeat
            if GetSBCPurchaseLineItem(PurchaseLine."No.", Item) then begin
                PurchaseLine."SBC Plant Item No." := Item."SBC Plant Item No.";
                PurchaseLine."SBC Plant Code" := Item."SBC Plant Code";
                PurchaseLine.Modify();
            end;
        until PurchaseLine.Next() = 0;
        exit(UpgradeTag)
    end;

    local procedure GetSBCPurchaseLineItem(ItemNo: Code[20]; var Item: Record Item) Found: Boolean
    begin
        Item.SetRange("No.", ItemNo);
        Item.SetFilter("SBC Plant Item No.", '<>%1', '');
        Item.SetFilter("SBC Plant Code", '<>%1', '');
        if Item.IsEmpty() then
            exit;
        Item.SetLoadFields("SBC Plant Item No.", "SBC Plant Code");
        Found := Item.FindFirst();
    end;

    /// <summary>
    /// Adds upgrade tags to the database for new companies so they don't run again.
    /// </summary>
    /// <param name="PerCompanyUpgradeTags">VAR List of [Code[250]].</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure OnGetPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]]);
    begin
        PerCompanyUpgradeTags.Add(UpgradeSBCPurchaseLine20230925);
        PerCompanyUpgradeTags.Add(UpgradeSBCPurchaseInvLine20230925);
        PerCompanyUpgradeTags.Add(UpgradeSBCPurchaseRcptLine20230925);
    end;

    var
        UpgradeSBCPurchaseLine20230925: Label 'UpgradeSBCPurchaseLine20230925', Comment = '2023-09-25';
        UpgradeSBCPurchaseInvLine20230925: Label 'UpgradeSBCPurchaseInvLine20230925', Comment = '2023-09-25';
        UpgradeSBCPurchaseRcptLine20230925: Label 'UpgradeSBCPurchaseRcptLine20230925', Comment = '2023-09-25';
}