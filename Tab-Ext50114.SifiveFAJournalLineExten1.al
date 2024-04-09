tableextension 50114 SifiveFAJournalLineExten1 extends "FA Journal Line"
{
    fields
    {
        field(50100; "SF Consolidation Currency"; Code[20])
        {
            Caption = 'SF Consolidation Currency';
            DataClassification = ToBeClassified;
            TableRelation = Currency;
        }
        field(50101; "SF ConsolidationCurrencyFactor"; Decimal)
        {
            Caption = 'SF ConsolidationCurrencyFactor';
            DataClassification = ToBeClassified;

        }
    }

    // trigger OnModify()
    // var

    // begin
    //     Message('test');
    // end;
}
