pageextension 50106 "SiFiveRecurringGenJourExten1" extends "Recurring General Journal"
{
    layout
    {
        addafter("Gen. Prod. Posting Group")
        {
            field("SF Consolidation Currency"; Rec."SF Consolidation Currency")
            {
                ApplicationArea = all;
                // Editable = false;
            }
            field("SF Consolidation Currency Factor"; Rec."SF ConsolidationCurrencyFactor")
            {
                ApplicationArea = all;
                DecimalPlaces = 3 : 3;
                // Editable = false;
            }
        }
    }

    actions
    {
        addafter("Ledger E&ntries")
        {
            action("GL Entry")
            {
                ApplicationArea = all;
                Caption = 'GL Entry';
                Image = GLRegisters;
                Visible = isvisible;
                trigger OnAction()
                var
                    message: Label 'Document No. "%1" must have the same Consolidation Currency, Consolidation Currency Factor.';
                begin
                    GLEntry.Reset();
                    PurchasesPayablesSetup.Get();

                    if Rec."Account Type" = Rec."Account Type" then begin
                        GLEntry.SetCurrentKey("G/L Account No.", "Posting Date");
                        GLEntry.SetRange("G/L Account No.", Rec."Account No.");
                        GLEntry.SetRange("Document Type", Rec."Document Type"::Invoice);
                        GLEntry.SetRange("Source Code", Rec."Source Code", 'PURCHASES');
                        GLEntry.SetRange("SF connetmark", false);
                        GLEntry.SetFilter("Posting Date", '<%1', Rec."Posting Date");
                        GLEntry.SetFilter(Amount, '>%1', Rec.Amount);

                        if GLEntry.FindLast() then;
                        if Page.RunModal(Page::"General Ledger Entries", GLEntry) = Action::LookupOK then begin
                            Currency_exchange_rate.SetRange("Currency Code", PurchasesPayablesSetup."SF Consolidation Currency");
                            Currency_exchange_rate.SetAscending("Starting Date", false);
                            Currency_exchange_rate.SetFilter("Starting Date", '<%1', GLEntry."Posting Date");
                            if Currency_exchange_rate.FindSet() then;

                            if (GLEntry."SF Consolidation Currency" = PurchasesPayablesSetup."SF Consolidation Currency") and (GLEntry."SF ConsCurrencyFactor" = Currency_exchange_rate."Relational Exch. Rate Amount") then begin
                                Rec."SF Consolidation Currency" := GLEntry."SF Consolidation Currency";
                                rec."SF ConsolidationCurrencyFactor" := GLEntry."SF ConsCurrencyFactor";
                                rec."SF G/L Entry No." := GLEntry."Entry No.";
                                rec.Modify();
                            end else begin
                                message(message, rec."Document No.");
                            end;
                        end;

                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()

    begin
        GLsetup.Get();
        isvisible := GLsetup.SFConsolidationCurrencyFactor;
    end;

    var
        GLEntry: Record "G/L Entry";
        Genjournal: record "Gen. Journal Line";
        PurchInHeader: Record "Purch. Inv. Header";

        SalesInvoice: Record "Sales Invoice Header";
        GLAccountcard: Record "G/L Account";
        PurchasesPayablesSetup: record "Purchases & Payables Setup";
        Currency_exchange_rate: Record "Currency Exchange Rate";
        GLsetup: Record "General Ledger Setup";

        isvisible: Boolean;

}
