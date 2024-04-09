tableextension 50115 SiFiveFALedgerEntryExten1 extends "FA Ledger Entry"
{
    fields
    {
        field(50100; "SF Consolidation Currency"; Code[20])
        {
            Caption = 'SF Consolidation Currency';
            DataClassification = ToBeClassified;
        }
        field(50101; "SF ConsolidationCurrencyFactor"; Decimal)
        {
            Caption = 'SF ConsolidationCurrencyFactor';
            DataClassification = ToBeClassified;
        }
    }
}
