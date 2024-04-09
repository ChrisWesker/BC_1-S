tableextension 50108 "SIfivePurch.Rcpt.HeaderExten1" extends "Purch. Rcpt. Header"
{
    fields
    {
        field(50100; "SF Consolidation Currency"; Code[20])
        {
            Caption = 'SF Consolidation Currency';
            DataClassification = ToBeClassified;
        }
        // field(50101; "ApplConsCurrOrdPurInvandRecJnl"; Decimal)
        // {
        //     Caption = 'Apply Cons. Currency in Pur. Ord., Pur. Inv. and Rec. Jnl from Amount';
        //     DataClassification = ToBeClassified;
        // }
    }
}
