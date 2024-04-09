tableextension 50105 SifivePurchaseLineExten1 extends "Purchase Line"
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
            Caption = 'CurrencyExchageCompare';
            DataClassification = ToBeClassified;
        }
    }
    // purchase header 選擇的consolidation currency 同步purchase line 
    trigger OnInsert()


    begin
        purchaseheader.SetRange("Document Type", rec."Document Type"::Order);
        purchaseheader.SetRange("No.", rec."Document No.");
        if purchaseheader.FindFirst() then;

        if Rec.Type <> Type::"Fixed Asset" then
            "SF Consolidation Currency" := purchaseheader."SF Consolidation Currency";

        // if Rec.Type = Type::"Fixed Asset" then begin
        //     fixedasset.SetRange("No.", Rec."No.");
        //     fixedasset.FindFirst();
        //     "SF Consolidation Currency" := fixedasset."SF Consolidation Currency";

        // purchaseheader."SF consolidation Currency" := fixedasset."SF Consolidation Currency";
        // purchaseheader.Modify()
        // end;

        // currencyrate.SetRange("Currency Code", rec."SF Consolidation Currency");
        // currencyrate.Validate("Starting Date", purchaseheader."Posting Date");
        // currencyrate.FindFirst();
        // "SF ConsolidationCurrencyFactor" := currencyrate."Relational Exch. Rate Amount"

    end;

    trigger OnModify()


    begin
        purchaseheader.SetRange("Document Type", rec."Document Type"::Order);
        purchaseheader.SetRange("No.", rec."Document No.");
        if purchaseheader.FindFirst() then;
        if Rec.Type <> Type::"Fixed Asset" then
            "SF consolidation Currency" := purchaseheader."SF Consolidation Currency";

        if Rec.Type = Type::"Fixed Asset" then begin
            fixedasset.SetRange("No.", Rec."No.");
            fixedasset.FindFirst();
            "SF Consolidation Currency" := fixedasset."SF Consolidation Currency";
            // purchaseheader."SF Consolidation Currency" := fixedasset."SF Consolidation Currency";
            // purchaseheader.Modify()
        end;
        // currencyrate.SetRange("Currency Code", rec."SF Consolidation Currency");
        // currencyrate.Validate("Starting Date", purchaseheader."Posting Date");
        // currencyrate.FindFirst();
        // "SF ConsolidationCurrencyFactor" := currencyrate."Relational Exch. Rate Amount"
    end;

    var
        purchaseheader: Record "Purchase Header";
        fixedasset: Record "Fixed Asset";

        currencyrate: Record "Currency Exchange Rate";
}
