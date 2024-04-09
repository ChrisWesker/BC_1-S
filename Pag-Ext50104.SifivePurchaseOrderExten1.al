pageextension 50104 SifivePurchaseOrderExten1 extends "Purchase Order"
{
    layout
    {
        addafter("IRS 1099 Code")
        {
            field("Consolidation Currency"; Rec."SF Consolidation Currency")
            {
                //  <<---------  joy & chris addd  延伸 選取的幣別 做判斷 
                TableRelation = Currency.Code where("SF Consolidation" = const(true));
                ApplicationArea = all;
                //  >>---------  joy & chris addd  延伸 選取的幣別 做判斷 
                Visible = isvisible;


                //  <<---------  joy & chris test 
                //  TableRelation = PurchaseOrderTmp."Code";
                // trigger OnLookup(var Text: Text): Boolean
                // var
                //     myTable: record "Purchases & Payables Setup";
                // begin
                //     myTable.Reset();
                //     IF Page.RunModal(Page::"SIFivePurchasesSetup", myTable) = Action::LookupOK then
                //         Rec."Consolidation Currency" := myTable."Consolidation Currency";
                // end;
                //  >>---------  joy & chris test 
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
