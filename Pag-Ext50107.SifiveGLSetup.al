pageextension 50107 SifiveGLSetup extends "General Ledger Setup"
{
    layout
    {
        addlast("KSI Finance Setup")
        {
            field(SFConsolidationCurrencyFactor; Rec.SFConsolidationCurrencyFactor)
            {
                ApplicationArea = all;
                Caption = 'SF Consolidation Currency Factor';
            }
        }
    }
}
