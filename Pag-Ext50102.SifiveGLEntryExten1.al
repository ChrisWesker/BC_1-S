pageextension 50102 SifiveGLEntryExten1 extends "General Ledger Entries"
{

    layout
    {
        addafter("Bal. Account Type")
        {
            field("SF Consolidation Currency"; Rec."SF Consolidation Currency")
            {
                ApplicationArea = all;



            }
            field("SF ConsCurrencyFactor"; Rec."SF ConsCurrencyFactor")
            {
                ApplicationArea = all;
                DecimalPlaces = 3 : 3;
            }

        }
    }


    trigger OnOpenPage()
    var

    begin
        // CurrPage.Editable := true;
        // Editable :=
    end;
}
