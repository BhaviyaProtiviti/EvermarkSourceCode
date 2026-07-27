permissionset 50036 "SBC - UI Permissions"
{
    Assignable = true;
    Caption = 'SBC - UI Permissions', MaxLength = 30;
    Permissions =
        table "SBC Temp Item Attribute Value" = X,
        tabledata "SBC Temp Item Attribute Value" = RMID,
        table "SBC SpecRight Interface" = X,
        tabledata "SBC SpecRight Interface" = RMID,
        table "SBC Plant" = X,
        tabledata "SBC Plant" = RMID,
        codeunit "SBC Upgrade" = X,
        codeunit "SBC Sell-To Posting Handler" = X,
        codeunit "SBC Misc Events" = X,
        codeunit "SBC Export Value Helper" = X,
        codeunit "SBC Export Helper" = X,
        codeunit "SBC BillTo Customer Events" = X,
        page "SBC Plant" = X,
        page "SBC SQI Item Attribute API" = X,
        page "SBC SpecRight Interface" = X,
        page "SBC SIQ Item API" = X,
        report "SBC Export Vendor Orders" = X,
        report "SBC Export Sales Orders" = X,
        report "SBC Export Purchase Orders" = X,
        report "SBC - Create Multi POs" = X;
}
