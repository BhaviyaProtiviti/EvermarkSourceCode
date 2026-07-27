tableextension 50122 "PurchaseLine-Ext" extends "Purchase Line"
{
    trigger OnDelete()
    var
        ConcurImportEntry: Record "Concur Import Entry";
    begin
        // TIG0001 >>
        IF ("Document Type" = "Document Type"::Invoice) AND ("Line No." <> 0) THEN BEGIN
            ConcurImportEntry.RESET();
            ConcurImportEntry.SETRANGE("Purchase Invoice No.", "Document No.");
            ConcurImportEntry.SETRANGE("Purchase Invoice Line No.", "Line No.");
            IF ConcurImportEntry.FIND('-') THEN
                REPEAT
                    ConcurImportEntry."Purchase Invoice No." := '';
                    ConcurImportEntry."Purchase Invoice Line No." := 0;
                    ConcurImportEntry.MODIFY();
                UNTIL ConcurImportEntry.NEXT() = 0;
        END;
        // TIG0001 <<
    END;

}