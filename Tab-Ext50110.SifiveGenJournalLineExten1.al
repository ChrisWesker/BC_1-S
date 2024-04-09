tableextension 50110 SifiveGenJournalLineExten1 extends "Gen. Journal Line"
{
    fields
    {
        field(50100; "SF Consolidation Currency"; Code[20])
        {
            Caption = 'SF Consolidation Currency';
            DataClassification = ToBeClassified;
            TableRelation = Currency;
            trigger OnValidate()
            begin
                IF ("SF G/L Entry No." <> 0) then
                    Error(KSI_Err001);
            end;
        }
        field(50101; "SF ConsolidationCurrencyFactor"; Decimal)
        {
            Caption = 'SF Consolidation Currency Factor';
            DataClassification = ToBeClassified;
            DecimalPlaces = 3 : 3;
            trigger OnValidate()
            begin
                IF ("SF G/L Entry No." <> 0) then
                    Error(KSI_Err002);
            end;
        }

        field(50102; "SF CurrencyExchageCompare"; Decimal)
        {
            Caption = 'SF CurrencyExchageCompare';
            DataClassification = ToBeClassified;
        }

        field(50103; "SF G/L Entry No."; Integer)
        {
            Caption = 'SF G/L Entry SF No.';
        }

    }

    trigger OnModify()
    var
        fixedassetcard: record "Fixed Asset";
        currency: Record Currency;
        Currency_exchange_rate: Record "Currency Exchange Rate";

        FAledgerentry: Record "FA Ledger Entry";
    begin
        if PurchasesPayablesSetup.Get() then;
        // if rec."Journal Template Name" <> 'RECURRING' then begin   //排除 Recurring General Journal 資料抓到

        //     // FAledgerentry.SetRange(FAledgerentry."FA No.", rec."Account No.");
        //     // FAledgerentry.SetRange(FAledgerentry."FA Posting Type", rec."FA Posting Type"::"Acquisition Cost");

        //     // if FAledgerentry.FindFirst() then begin
        //     //     "SF Consolidation Currency" := FAledgerentry."SF Consolidation Currency";
        //     //     "SF ConsolidationCurrencyFactor" := FAledgerentry."SF ConsolidationCurrencyFactor";
        //     // end;
        //     if rec."SF Consolidation Currency" = '' then begin
        //         fixedassetcard.SetRange("No.", "Account No.");
        //         if fixedassetcard.FindFirst() then
        //             "SF Consolidation Currency" := fixedassetcard."SF Consolidation Currency";

        //         Currency_exchange_rate.SetRange("Currency Code", fixedassetcard."SF Consolidation Currency");
        //         Currency_exchange_rate.SetAscending("Starting Date", false);
        //         Currency_exchange_rate.SetFilter("Starting Date", '<%1', "Posting Date");
        //         if Currency_exchange_rate.FindSet() then begin
        //             "SF ConsolidationCurrencyFactor" := Currency_exchange_rate."Relational Exch. Rate Amount"
        //         end;
        //     end;
        // end /*else begin*/
        //     if rec."SF Consolidation Currency" = '' then begin
        //         GLAccountcard.SetRange("No.", rec."Account No.");
        //         GLAccountcard.FindFirst();

        //         if GLAccountcard."SF Apply Consol.CurrencyFactor" = true then begin
        //             Currency_exchange_rate.SetRange("Currency Code", PurchasesPayablesSetup."SF Consolidation Currency");
        //             Currency_exchange_rate.SetAscending("Starting Date", false);
        //             Currency_exchange_rate.SetFilter("Starting Date", '<=%1', rec."Posting Date");
        //             IF Currency_exchange_rate.FindSet() then;
        //             "SF Consolidation Currency" := Currency_exchange_rate."Currency Code";
        //             "SF ConsolidationCurrencyFactor" := Currency_exchange_rate."Relational Exch. Rate Amount"
        //         end;

        //     end;
        // end;
    end;

    var
        GlEntry: Record "G/L Entry";
        GLAccountcard: Record "G/L Account";
        PurchasesPayablesSetup: record "Purchases & Payables Setup";
        KSI_Err001: Label 'SF Consolidation Currency and SF Consolidation Currency Factor have been related and cannot be modified. Please delete this line and re-enter.';
        KSI_Err002: Label 'SF Consolidation Currency and SF Consolidation Currency Factor have been related and cannot be modified. Please delete this line and re-enter.';
}
