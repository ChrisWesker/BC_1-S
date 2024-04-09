pageextension 50108 SiFiveFieedAssetJournalExten1 extends "Fixed Asset Journal"
{
    layout
    {
        addafter(Amount)
        {
            field("SF Consolidation Currency"; Rec."SF Consolidation Currency")
            {
                ApplicationArea = all;
                Caption = 'SF Consolidation Currency';
            }
            field("SF ConsolidationCurrencyFactor"; Rec."SF ConsolidationCurrencyFactor")
            {
                ApplicationArea = all;
                Caption = 'SF Consolidation CurrencyFactor';
            }
        }
    }
}
