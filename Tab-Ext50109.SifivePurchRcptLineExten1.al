tableextension 50109 SifivePurchRcptLineExten1 extends "Purch. Rcpt. Line"
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
            Caption = 'SF Consolidation Currency Factor';
            DataClassification = ToBeClassified;
        }

        field(50102; "SF CurrencyExchageCompare"; Decimal)
        {
            Caption = 'SF CurrencyExchageCompare';
            DataClassification = ToBeClassified;
        }
    }
}
