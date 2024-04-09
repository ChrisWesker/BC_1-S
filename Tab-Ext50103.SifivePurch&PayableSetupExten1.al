tableextension 50103 "SifivePurch&PayableSetupExten1" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50100; "SF Consolidation Currency"; Code[20])
        {
            Caption = 'SF Consolidation Currency';
            // DataClassification = ToBeClassified;
            TableRelation = Currency;
            //  <<---------  joy & chris addd  延伸 purchaseorder選取的幣別 做判斷 
            trigger OnValidate()
            var
                Currency: Record Currency;
            begin
                Currency.SetFilter("SF Consolidation", '=%1', true);
                Currency.ModifyAll("SF Consolidation", false);
                Currency.Reset();
                Currency.SetFilter(Code, '=%1', "SF Consolidation Currency");
                if (Currency.FindSet(true)) then begin
                    Currency."SF Consolidation" := true;
                    Currency.Modify();
                end;
            end;

            //  <<---------  joy & chris addd  延伸 purchaseorder選取的幣別 做判斷 
        }
        field(50101; "SF ApplConsCurrOrdPurInvandRec"; Decimal)
        {
            Caption = 'SF Apply Cons. Currency in Pur. Ord., Pur. Inv. and Rec. Jnl from Amount';
            DataClassification = ToBeClassified;
        }
    }
}
