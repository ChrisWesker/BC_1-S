pageextension 50100 SifiveGLAccountCardExten1 extends "G/L Account Card"
{
    layout
    {
        addafter(Reporting)
        {
            group("KSI Finance Setup")
            {
                Visible = isvisible;
                field("SF Apply Consol.CurrencyFactor"; Rec."SF Apply Consol.CurrencyFactor")
                {
                    ApplicationArea = all;
                    Visible = isvisible;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        GLsetup: Record "General Ledger Setup";
    begin
        GLsetup.Get();
        isvisible := GLsetup.SFConsolidationCurrencyFactor;
        // if not GLsetup.SFConsolidationCurrencyFactor then
        //     isvisible := true
    end;


    var
        isvisible: Boolean;
}
