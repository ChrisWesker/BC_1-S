tableextension 50112 SifivePurchheaderCurrencyExt extends Currency
{

    //  <<---------  joy & chris addd  延伸 選取的幣別 做判斷 
    fields
    {
        field(50100; "SF Consolidation"; Boolean)
        {
            Caption = 'SF Consolidation';
            DataClassification = ToBeClassified;
        }
    }

    //  >>---------  joy & chris addd  延伸 選取的幣別 做判斷 
}
