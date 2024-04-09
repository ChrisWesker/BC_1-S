pageextension 50105 SifivePurchaseInvoiceExten1 extends "Purchase Invoice"
{
    layout
    {
        addafter("On Hold")
        {
            field("Consolidation Currency"; Rec."SF Consolidation Currency")
            {
                //  <<---------  joy & chris addd  延伸 選取的幣別 做判斷 
                TableRelation = Currency.Code where("SF Consolidation" = const(true));
                ApplicationArea = all;
                //  >>---------  joy & chris addd  延伸 選取的幣別 做判斷 
                Visible = isvisible;
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
