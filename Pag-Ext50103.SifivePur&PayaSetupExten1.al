pageextension 50103 "SifivePur&PayaSetupExten1" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter(Archiving)
        {
            group("KSI Finance Setup")
            {
                Visible = isvisible;
                field("SF Consolidation Currency"; Rec."SF Consolidation Currency")
                {
                    ApplicationArea = all;
                    Visible = isvisible;
                }
                field(ApplConsCurrOrdPurInvandRecJnl; Rec."SF ApplConsCurrOrdPurInvandRec")
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
