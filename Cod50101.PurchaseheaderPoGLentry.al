codeunit 50101 PurchaseheaderPoGLentry
{
    //  <<----------------------------purchase invoice and reciept  紀錄有consolidatetion  currency -------------------------------------------------------------------------------------

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterInsertInvoiceHeader, '', false, false)]
    local procedure OnAfterInsertInvoiceHeader(var PurchaseHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header");
    begin
        PurchInvHeader."SF Consolidation Currency" := PurchaseHeader."SF Consolidation Currency";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPurchInvLineInsert, '', false, false)]
    local procedure OnAfterPurchInvLineInsert(var PurchInvLine: Record "Purch. Inv. Line"; PurchInvHeader: Record "Purch. Inv. Header"; PurchLine: Record "Purchase Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean; PurchHeader: Record "Purchase Header"; PurchRcptHeader: Record "Purch. Rcpt. Header"; TempWhseRcptHeader: Record "Warehouse Receipt Header");
    begin
        PurchInvLine."SF Consolidation Currency" := PurchLine."SF Consolidation Currency"
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterInsertReceiptHeader, '', false, false)]
    local procedure OnAfterInsertReceiptHeader(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary; WhseReceive: Boolean; CommitIsSuppressed: Boolean);
    begin
        PurchRcptHeader."SF Consolidation Currency" := PurchHeader."SF Consolidation Currency"
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPurchRcptLineInsert, '', false, false)]
    local procedure OnAfterPurchRcptLineInsert(PurchaseLine: Record "Purchase Line"; var PurchRcptLine: Record "Purch. Rcpt. Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean; PurchInvHeader: Record "Purch. Inv. Header"; var TempTrackingSpecification: Record "Tracking Specification" temporary; PurchRcptHeader: Record "Purch. Rcpt. Header"; TempWhseRcptHeader: Record "Warehouse Receipt Header"; xPurchLine: Record "Purchase Line"; var TempPurchLineGlobal: Record "Purchase Line" temporary);
    begin
        PurchRcptLine."SF Consolidation Currency" := PurchaseLine."SF Consolidation Currency"
    end;

    //  >>----------------------------purchase invoice and reciept  紀錄有consolidatetion currency ---------------------------------------------------------------------------------------------

    //  ----------------------------FA general journal line 開帳 過帳到GL--------------------------------------------------------------------------
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Make FA Ledger Entry", OnAfterCopyFromFAJnlLine, '', false, false)]
    local procedure "Make FA Ledger Entry_OnAfterCopyFromFAJnlLine"(var FALedgerEntry: Record "FA Ledger Entry"; FAJournalLine: Record "FA Journal Line")
    begin

        FALedgerEntry."SF Consolidation Currency" := FAJournalLine."SF Consolidation Currency";
        FALedgerEntry."SF ConsolidationCurrencyFactor" := FAJournalLine."SF ConsolidationCurrencyFactor"
    end;

    //  ----------------------------FA general journal line 開帳 過帳到GL--------------------------------------------------------------------------

    //   -------------------------- 折舊進入 FA GL journal ---------------------------------------------------------
    [EventSubscriber(ObjectType::Report, Report::"Calculate Depreciation", OnAfterCalculateDepreciation, '', false, false)]
    local procedure "Calculate Depreciation_OnAfterCalculateDepreciation"(FANo: Code[20]; var TempGenJournalLine: Record "Gen. Journal Line" temporary; var TempFAJournalLine: Record "FA Journal Line" temporary; var DeprAmount: Decimal; var NumberOfDays: Integer; DeprBookCode: Code[10]; DeprUntilDate: Date; EntryAmounts: array[4] of Decimal; DaysInPeriod: Integer)

    var
        FAledgerentry: Record "FA Ledger Entry";
        glentry: Record "G/L Entry";
    begin

        FAledgerentry.SetRange("FA No.", FANo);
        // FAledgerentry.SetRange("FA Posting Type", GenJnlLine."FA Posting Type"::"Acquisition Cost");
        if FAledgerentry.FindFirst() then begin
            if FAledgerentry."FA Posting Type" = FAledgerentry."FA Posting Type"::"Acquisition Cost" then begin    //判斷是否開帳的FA
                if FAledgerentry."SF Consolidation Currency" <> '' then begin
                    TempGenJournalLine."SF Consolidation Currency" := FAledgerentry."SF Consolidation Currency";
                    TempGenJournalLine."SF ConsolidationCurrencyFactor" := FAledgerentry."SF ConsolidationCurrencyFactor";
                    TempFAJournalLine."SF Consolidation Currency" := FAledgerentry."SF Consolidation Currency";
                    TempFAJournalLine."SF ConsolidationCurrencyFactor" := FAledgerentry."SF ConsolidationCurrencyFactor";
                end
                else begin                                                                                          //判斷是否為PO購買固資
                    glentry.SetRange("Document No.", FAledgerentry."Document No.");
                    glentry.SetRange("Posting Date", FAledgerentry."Posting Date");
                    glentry.SetRange("Source No.", FAledgerentry."FA No.");
                    if glentry.FindFirst() then begin
                        TempGenJournalLine."SF Consolidation Currency" := glentry."SF Consolidation Currency";
                        TempGenJournalLine."SF ConsolidationCurrencyFactor" := glentry."SF ConsCurrencyFactor";
                        TempFAJournalLine."SF Consolidation Currency" := glentry."SF Consolidation Currency";
                        TempFAJournalLine."SF ConsolidationCurrencyFactor" := glentry."SF ConsCurrencyFactor";
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Calculate Depreciation", OnBeforeGenJnlLineInsert, '', false, false)]
    local procedure "Calculate Depreciation_OnBeforeGenJnlLineInsert"(var TempGenJournalLine: Record "Gen. Journal Line" temporary; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."SF Consolidation Currency" := TempGenJournalLine."SF Consolidation Currency";
        GenJournalLine."SF ConsolidationCurrencyFactor" := TempGenJournalLine."SF ConsolidationCurrencyFactor"
    end;

    //   -------------------------- 折舊進入 FA GL jpurnal ---------------------------------------------------------

    // ----------------------------------FA journal line 使用 "inser FA bal account" 抓對應固資的購買成本之幣別、匯率 -------------------------------------------------------
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Insert G/L Account", OnGetBalAccAfterSaveGenJnlLineFields, '', false, false)]
    local procedure "FA Insert G/L Account_OnGetBalAccAfterSaveGenJnlLineFields"(var Sender: Codeunit "FA Insert G/L Account"; var ToGenJnlLine: Record "Gen. Journal Line"; FromGenJnlLine: Record "Gen. Journal Line"; var SkipInsert: Boolean)
    var
        faledgerentry: Record "FA Ledger Entry";
        Glentry: Record "G/L Entry";
    begin
        faledgerentry.SetRange("FA No.", FromGenJnlLine."Account No.");
        if faledgerentry.FindFirst() then begin
            if FAledgerentry."FA Posting Type" = FAledgerentry."FA Posting Type"::"Acquisition Cost" then begin    //判斷是否開帳的FA
                if FAledgerentry."SF Consolidation Currency" <> '' then begin
                    ToGenJnlLine."SF Consolidation Currency" := FAledgerentry."SF Consolidation Currency";
                    ToGenJnlLine."SF ConsolidationCurrencyFactor" := FAledgerentry."SF ConsolidationCurrencyFactor";
                end
                else begin
                    glentry.SetRange("Document No.", FAledgerentry."Document No.");
                    glentry.SetRange("Posting Date", FAledgerentry."Posting Date");
                    glentry.SetRange("Source No.", FAledgerentry."FA No.");
                    if Glentry.FindFirst() then begin
                        ToGenJnlLine."SF Consolidation Currency" := Glentry."SF Consolidation Currency";
                        ToGenJnlLine."SF ConsolidationCurrencyFactor" := Glentry."SF ConsCurrencyFactor";
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Insert G/L Account", OnGetBalAccAfterRestoreGenJnlLineFields, '', false, false)]
    local procedure "FA Insert G/L Account_OnGetBalAccAfterRestoreGenJnlLineFields"(var ToGenJnlLine: Record "Gen. Journal Line"; FromGenJnlLine: Record "Gen. Journal Line"; var TempFAGLPostBuf: Record "FA G/L Posting Buffer")
    var
        faledgerentry: Record "FA Ledger Entry";
        Glentry: Record "G/L Entry";
    begin
        // Message('test');
        // faledgerentry.SetRange("FA No.", FromGenJnlLine."Account No.");
        // if faledgerentry.FindFirst() then begin
        //     glentry.SetRange("Document No.", FAledgerentry."Document No.");
        //     glentry.SetRange("Posting Date", FAledgerentry."Posting Date");
        //     glentry.SetRange("Source No.", FAledgerentry."FA No.");
        //     if Glentry.FindFirst() then begin
        //         ToGenJnlLine."SF Consolidation Currency" := Glentry."SF Consolidation Currency";
        //         ToGenJnlLine."SF ConsolidationCurrencyFactor" := Glentry."SF ConsCurrencyFactor"
        //     end;
        // end;

        ToGenJnlLine."SF Consolidation Currency" := FromGenJnlLine."SF Consolidation Currency";
        ToGenJnlLine."SF ConsolidationCurrencyFactor" := FromGenJnlLine."SF ConsolidationCurrencyFactor"
    end;


    // ----------------------------------FA journal line 使用 "inser FA bal account" 抓對應固資的購買成本之幣別、匯率 -------------------------------------------------------

    // --------------------------   1   過帳 -----------------------------------------------------------------
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeInsertGlEntry, '', false, false)]
    local procedure OnBeforeInsertGlEntry(var GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; var IsHandled: Boolean);
    var
        purchaseinv: record "Purch. Inv. Header";
        purchaseinvLine: Record "Purch. Inv. Line";
        PurchasesPayablesSetup: record "Purchases & Payables Setup";
        currencyExchangeRate: record "Currency Exchange Rate";
        currenctUnitcost: Decimal;
        currenctUnitcost2: Decimal;
        purchhead: Record "Purchase Header";
        purchline: record "Purchase Line";
        FAledgerentry: Record "FA Ledger Entry";
        GLAccountcard: Record "G/L Account";
        unpostgenjournalline: Record "Gen. Journal Line";
        FixedAsset: Record "Fixed Asset";
        salesinvoice: Record "Sales Invoice Header";
        salesinvoiceline: Record "Sales Invoice Line";
        message: Label 'Document No. "%1" must have the same Consolidation Currency, Consolidation Currency Factor.';
        GLsetup: Record "General Ledger Setup";

        accountcard_line_forFilter: Record "G/L Account";
        purchaseinvline_forFilter: Record "Purch. Inv. Line";
        currenctunitcost_forFilter: Decimal;

        currenctunitcost_foreachglaccount: Decimal;
        accountcard_line__foreachglaccount: Record "G/L Account";
        currencyExchangeRate__foreachglaccount: record "Currency Exchange Rate";

        glentry2: Record "G/L Entry";

    begin
        PurchasesPayablesSetup.Get();
        GLsetup.Get();
        if GLsetup.SFConsolidationCurrencyFactor = true then begin   //匯率總開關

            if GenJnlLine."Journal Template Name" = 'ASSETS' then begin    // 判斷固定資產 journal 過帳
                unpostgenjournalline.SetRange("Posting Date", GenJnlLine."Posting Date");
                unpostgenjournalline.SetRange("Document No.", GenJnlLine."Document No.");
                unpostgenjournalline.SetRange("Line No.", GenJnlLine."Line No.");
                unpostgenjournalline.FindFirst(); //抓過帳前單據
                GLAccountcard.SetRange("No.", GLEntry."G/L Account No.");
                GLAccountcard.Findfirst();

                //>>>>>>>---------- 先判斷 Fa ledger entries 是否有取得成本的FA分錄------------------------------ 
                if GenJnlLine."SF Consolidation Currency" = '' then begin
                    FAledgerentry.SetRange("FA No.", GenJnlLine."Account No.");
                    // FAledgerentry.SetRange("FA Posting Type", GenJnlLine."FA Posting Type"::"Acquisition Cost");
                    if FAledgerentry.FindFirst() then begin
                        if FAledgerentry."FA Posting Type" = FAledgerentry."FA Posting Type"::"Acquisition Cost" then begin
                            GenJnlLine."SF Consolidation Currency" := FAledgerentry."SF Consolidation Currency";
                            GenJnlLine."SF ConsolidationCurrencyFactor" := FAledgerentry."SF ConsolidationCurrencyFactor";
                        end;
                    end;
                end;

                //<<<<<<<<---------- 先判斷 Fa ledger entries 是否有取得成本的FA分錄------------------------------ 

                // >>>>>>>------------------------判斷FAposting type 過帳-----------------------------------------------------------------
                if GenJnlLine."SF Consolidation Currency" = '' then begin
                    if (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::Disposal) or
                     (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::"Acquisition Cost") or
                      (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::Appreciation) or
                       (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::"Custom 1") or (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::"Custom 2") or (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::Maintenance) or (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::"Write-Down") then begin
                        FAledgerentry.SetRange("FA No.", GenJnlLine."Account No.");
                        if FAledgerentry."FA Posting Type" = FAledgerentry."FA Posting Type"::"Acquisition Cost" then begin    //判斷是否開帳的FA
                            if FAledgerentry."SF Consolidation Currency" <> '' then begin
                                GenJnlLine."SF Consolidation Currency" := FAledgerentry."SF Consolidation Currency";
                                GenJnlLine."SF ConsolidationCurrencyFactor" := FAledgerentry."SF ConsolidationCurrencyFactor";
                            end
                            else begin                                                                                          //判斷是否為PO購買固資
                                glentry2.SetRange("Document No.", FAledgerentry."Document No.");
                                glentry2.SetRange("Posting Date", FAledgerentry."Posting Date");
                                glentry2.SetRange("Source No.", FAledgerentry."FA No.");
                                if glentry2.FindFirst() then begin
                                    GenJnlLine."SF Consolidation Currency" := glentry2."SF Consolidation Currency";
                                    GenJnlLine."SF ConsolidationCurrencyFactor" := glentry2."SF ConsCurrencyFactor";

                                end;
                            end;
                        end;
                    end;
                end;
                // >>>>>>>--------------------------判斷FA作廢---------------------------------------------------------------------

                // >>>>>>>----------- 判斷FA是否有事先帶入幣別和匯率(有可能操作折舊帶入，不是自己手key,若自己手key 會先抓固資源有的合併幣別)---------------------------------------------
                if GenJnlLine."SF Consolidation Currency" = '' then begin
                    FAledgerentry.SetRange("FA No.", GenJnlLine."Account No.");
                    if FAledgerentry."FA Posting Type" = FAledgerentry."FA Posting Type"::"Acquisition Cost" then begin    //判斷是否開帳的FA
                        if FAledgerentry."SF Consolidation Currency" <> '' then begin
                            GenJnlLine."SF Consolidation Currency" := FAledgerentry."SF Consolidation Currency";
                            GenJnlLine."SF ConsolidationCurrencyFactor" := FAledgerentry."SF ConsolidationCurrencyFactor";
                        end
                        else begin                                                                                          //判斷是否為PO購買固資
                            glentry2.SetRange("Document No.", FAledgerentry."Document No.");
                            glentry2.SetRange("Posting Date", FAledgerentry."Posting Date");
                            glentry2.SetRange("Source No.", FAledgerentry."FA No.");
                            if glentry2.FindFirst() then begin
                                GenJnlLine."SF Consolidation Currency" := glentry2."SF Consolidation Currency";
                                GenJnlLine."SF ConsolidationCurrencyFactor" := glentry2."SF ConsCurrencyFactor";

                            end;
                        end;
                    end;
                end;

                // if GenJnlLine."SF Consolidation Currency" = '' then begin
                //     FixedAsset.SetRange("No.", GenJnlLine."Account No.");
                //     if FixedAsset.FindFirst() then
                //         GenJnlLine."SF Consolidation Currency" := FixedAsset."SF Consolidation Currency";

                //     currencyExchangeRate.SetRange("Currency Code", FixedAsset."SF Consolidation Currency");
                //     currencyExchangeRate.SetAscending("Starting Date", false);
                //     currencyExchangeRate.SetFilter("Starting Date", '<=%1', GenJnlLine."Posting Date");
                //     IF currencyExchangeRate.FindSet() then
                //         GenJnlLine."SF ConsolidationCurrencyFactor" := currencyExchangeRate."Relational Exch. Rate Amount";
                // end;
                // <<<<<<<<----------- 判斷FA是否有事先帶入幣別和匯率(有可能操作折舊帶入，不是自己手key,若自己手key 會先抓固資源有的合併幣別)---------------------------------------------

                if (GLEntry."G/L Account No." = GLAccountcard."No.") and (GLAccountcard."SF Apply Consol.CurrencyFactor" = true) then begin  //判斷 G/L Account Card 是否有勾起 consolidate

                    //>>>>>>>-----------判斷是會科是否有帶入幣值和匯率------------------------------------------------------
                    if GenJnlLine."SF Consolidation Currency" = '' then begin
                        GenJnlLine."SF Consolidation Currency" := PurchasesPayablesSetup."SF Consolidation Currency";
                        currencyExchangeRate.SetRange("Currency Code", PurchasesPayablesSetup."SF Consolidation Currency");
                        currencyExchangeRate.SetAscending("Starting Date", false);
                        currencyExchangeRate.SetFilter("Starting Date", '<=%1', GenJnlLine."Posting Date");
                        IF currencyExchangeRate.FindSet() then
                            GenJnlLine."SF ConsolidationCurrencyFactor" := currencyExchangeRate."Relational Exch. Rate Amount";
                    end;
                    //<<<<<<<<-----------判斷是會科是否有帶入幣值和匯率------------------------------------------------------
                    GLEntry."SF consolidation Currency" := GenJnlLine."SF Consolidation Currency";
                    GLEntry."SF ConsCurrencyFactor" := GenJnlLine."SF ConsolidationCurrencyFactor";
                end;

                FAledgerentry.SetRange("G/L Entry No.", GLEntry."Entry No.");
                if FAledgerentry.FindFirst() then
                    GLEntry."SF FA NO." := FAledgerentry."FA No.";
            end;

            if GenJnlLine."Source Code" = 'PURCHASES' then begin     // 判斷採購訂,採購發票單過帳

                GLAccountcard.SetRange("No.", GLEntry."G/L Account No.");
                GLAccountcard.FindFirst();

                purchaseinv.SetRange("Posting Date", GenJnlLine."Posting Date");
                purchaseinv.SetRange("Source Code", GenJnlLine."Source Code");
                purchaseinv.SetRange("No.", GenJnlLine."Document No.");
                purchaseinv.FindLast();

                // --------------------單據總金額 加總-----------------------------------------------------
                purchaseinvLine.SetRange("Posting Date", purchaseinv."Posting Date");
                purchaseinvLine.SetRange("Document No.", purchaseinv."No.");
                if purchaseinvLine.FindSet() then
                    repeat
                        currenctUnitcost += purchaseinvLine."Line Amount";
                    until purchaseinvLine.Next() = 0;
                // --------------------單據總金額 加總-----------------------------------------------------

                // --------------------單據總金額 加總,但過濾會科沒開起功能 的加總-----------------------------------------------------
                // purchaseinvline_forFilter.SetRange("Posting Date", purchaseinv."Posting Date");
                // purchaseinvline_forFilter.SetRange("Document No.", purchaseinv."No.");
                // if purchaseinvline_forFilter.FindSet() then begin
                //     repeat
                //         accountcard_line_forFilter.SetRange("No.", purchaseinvline_forFilter."No.");
                //         accountcard_line_forFilter.FindFirst();
                //         if accountcard_line_forFilter."SF Apply Consol.CurrencyFactor" = true then
                //             currenctunitcost_forFilter += purchaseinvline_forFilter."Line Amount";
                //     until purchaseinvline_forFilter.Next() = 0;
                // end;
                // --------------------單據總金額 加總,但過濾會科沒開起客製功能 的加總-----------------------------------------------------

                // ----------------------針對單一會科過濾開起客製功能，並換算匯率--------------------------------------------------------
                accountcard_line__foreachglaccount.SetRange("No.", GenJnlLine."Account No.");
                if accountcard_line__foreachglaccount.FindFirst() then;
                currencyExchangeRate__foreachglaccount.SetRange("Currency Code", PurchasesPayablesSetup."SF Consolidation Currency");
                currencyExchangeRate__foreachglaccount.SetAscending("Starting Date", false);
                currencyExchangeRate__foreachglaccount.SetFilter("Starting Date", '<=%1', purchaseinv."Posting Date");
                IF currencyExchangeRate__foreachglaccount.FindSet() then;
                if accountcard_line__foreachglaccount."SF Apply Consol.CurrencyFactor" = true then
                    currenctunitcost_foreachglaccount := GenJnlLine.Amount / currencyExchangeRate__foreachglaccount."Relational Exch. Rate Amount";
                // ----------------------針對單一會科過濾開起客製功能，並換算匯率--------------------------------------------------------

                // if purchaseinvLine.Type <> purchaseinvLine.Type::"Fixed Asset" then begin   //非採購固定資產
                if GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Fixed Asset" then
                    if GLAccountcard."SF Apply Consol.CurrencyFactor" = true then
                        if purchaseinv."SF Consolidation Currency" <> '' then begin       // 判斷是否有勾起 consilidation currency， 若沒有直接跳過
                            currencyExchangeRate.SetRange("Currency Code", purchaseinv."SF Consolidation Currency");
                            currencyExchangeRate.SetAscending("Starting Date", false);
                            currencyExchangeRate.SetFilter("Starting Date", '<=%1', purchaseinv."Posting Date");
                            IF currencyExchangeRate.FindSet() then;
                            // currenctUnitcost2 := Round(currenctUnitcost, currencyExchangeRate."Relational Exch. Rate Amount");
                            currenctUnitcost2 := currenctUnitcost / currencyExchangeRate."Relational Exch. Rate Amount";

                            // 判斷Setup金額是否有大餘
                            if (purchaseinv."SF Consolidation Currency" = PurchasesPayablesSetup."SF Consolidation Currency") and (currenctUnitcost2 >= purchasesPayablesSetup."SF ApplConsCurrOrdPurInvandRec") then begin
                                GenJnlLine."SF Consolidation Currency" := purchaseinv."SF Consolidation Currency";
                                GLEntry."SF Consolidation Currency" := GenJnlLine."SF Consolidation Currency";
                                GLEntry."SF CurrencyExchageCompare" := currenctUnitcost2;
                                GLEntry."SF ConsCurrencyFactor" := currencyExchangeRate."Relational Exch. Rate Amount";
                            end;
                        end;



                // if purchaseinvLine.Type = purchaseinvLine.Type::"Fixed Asset" then begin   //使用購固定資產
                if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Fixed Asset" then begin
                    if GLEntry."FA Entry No." <> 0 then begin   // 判斷是否是 固定資產 還是 稅率 要進入VAT G/L Account car
                        FixedAsset.SetRange("No.", purchaseinvLine."No.");
                        FixedAsset.FindFirst();
                        currencyExchangeRate.SetRange("Currency Code", FixedAsset."SF Consolidation Currency");
                        currencyExchangeRate.SetAscending("Starting Date", false);
                        currencyExchangeRate.SetFilter("Starting Date", '<=%1', purchaseinv."Posting Date");
                        IF currencyExchangeRate.FindSet() then;
                        GenJnlLine."SF Consolidation Currency" := FixedAsset."SF Consolidation Currency";
                        GLEntry."SF Consolidation Currency" := GenJnlLine."SF Consolidation Currency";
                        GLEntry."SF ConsCurrencyFactor" := currencyExchangeRate."Relational Exch. Rate Amount";
                        GLEntry."SF FA NO." := purchaseinvLine."No.";

                        FAledgerentry.SetRange("G/L Entry No.", GLEntry."Entry No.");
                        if FAledgerentry.FindFirst() then
                            GLEntry."SF FA NO." := FAledgerentry."FA No.";

                    end;

                    if GLEntry."FA Entry No." = 0 then begin // 判斷是否是 固定資產 還是 稅率 要進入VAT G/L Account car
                        if GLAccountcard."SF Apply Consol.CurrencyFactor" = true then begin
                            FixedAsset.SetRange("No.", purchaseinvLine."No.");
                            FixedAsset.FindFirst();

                            currencyExchangeRate.SetRange("Currency Code", FixedAsset."SF Consolidation Currency");
                            currencyExchangeRate.SetAscending("Starting Date", false);
                            currencyExchangeRate.SetFilter("Starting Date", '<=%1', purchaseinv."Posting Date");
                            IF currencyExchangeRate.FindSet() then;
                            GenJnlLine."SF Consolidation Currency" := FixedAsset."SF Consolidation Currency";
                            GLEntry."SF Consolidation Currency" := GenJnlLine."SF Consolidation Currency";
                            GLEntry."SF ConsCurrencyFactor" := currencyExchangeRate."Relational Exch. Rate Amount";
                            GLEntry."SF FA NO." := purchaseinvLine."No.";

                            FAledgerentry.SetRange("G/L Entry No.", GLEntry."Entry No.");
                            if FAledgerentry.FindFirst() then
                                GLEntry."SF FA NO." := FAledgerentry."FA No.";
                        end;
                    end;
                end;
            end;

            if GenJnlLine."Source Code" = 'SALES' then begin                      // 判斷銷售訂單,銷售發票單過帳
                salesinvoice.SetRange("Posting Date", GenJnlLine."Posting Date");
                salesinvoice.SetRange("Source Code", GenJnlLine."Source Code");
                salesinvoice.SetRange("No.", GenJnlLine."Document No.");
                salesinvoice.FindFirst();

                salesinvoiceline.SetRange("Posting Date", salesinvoice."Posting Date");
                salesinvoiceline.SetRange("Document No.", salesinvoice."No.");
                salesinvoiceline.FindFirst();

                GLAccountcard.SetRange("No.", GLEntry."G/L Account No.");
                GLAccountcard.FindFirst();

                if salesinvoiceline.Type = salesinvoiceline.Type::"Fixed Asset" then begin   //使用購固定資產
                    FixedAsset.SetRange("No.", salesinvoiceline."No.");
                    FixedAsset.FindFirst();
                    FAledgerentry.SetRange("FA No.", salesinvoiceline."No.");
                    if FAledgerentry.FindFirst() then;                                       //抓固資第一次買的幣別匯率
                    if GLAccountcard."SF Apply Consol.CurrencyFactor" = true then begin
                        if FAledgerentry."FA Posting Type" = FAledgerentry."FA Posting Type"::"Acquisition Cost" then begin    //判斷是否開帳的FA
                            if FAledgerentry."SF Consolidation Currency" <> '' then begin
                                GLEntry."SF Consolidation Currency" := FAledgerentry."SF Consolidation Currency";
                                GLEntry."SF ConsCurrencyFactor" := FAledgerentry."SF ConsolidationCurrencyFactor"

                            end
                            else begin                                                                                        //抓夠購買的FA
                                glentry2.SetRange("Document No.", FAledgerentry."Document No.");
                                glentry2.SetRange("Posting Date", FAledgerentry."Posting Date");
                                glentry2.SetRange("Source No.", FAledgerentry."FA No.");
                                if glentry2.FindFirst() then begin
                                    GenJnlLine."SF Consolidation Currency" := glentry2."SF Consolidation Currency";
                                    GenJnlLine."SF ConsolidationCurrencyFactor" := glentry2."SF ConsCurrencyFactor";
                                    GLEntry."SF Consolidation Currency" := glentry2."SF Consolidation Currency";
                                    GLEntry."SF ConsCurrencyFactor" := glentry2."SF ConsCurrencyFactor"
                                end;
                            end;
                        end;
                    end;
                end;
            end;

            // if GenJnlLine."Source Code" = 'SALES' then begin                      // 判斷銷售訂單,銷售發票單過帳
            //     salesinvoice.SetRange("Posting Date", GenJnlLine."Posting Date");
            //     salesinvoice.SetRange("Source Code", GenJnlLine."Source Code");
            //     salesinvoice.SetRange("No.", GenJnlLine."Document No.");
            //     salesinvoice.FindFirst();

            //     salesinvoiceline.SetRange("Posting Date", salesinvoice."Posting Date");
            //     salesinvoiceline.SetRange("Document No.", salesinvoice."No.");
            //     salesinvoiceline.FindFirst();

            //     if salesinvoiceline.Type = salesinvoiceline.Type::"Fixed Asset" then begin   //使用購固定資產
            //         FixedAsset.SetRange("No.", salesinvoiceline."No.");
            //         FixedAsset.FindFirst();

            //         currencyExchangeRate.SetRange("Currency Code", FixedAsset."SF Consolidation Currency");
            //         currencyExchangeRate.SetAscending("Starting Date", false);
            //         currencyExchangeRate.SetFilter("Starting Date", '<=%1', salesinvoice."Posting Date");
            //         IF currencyExchangeRate.FindSet() then;
            //         GenJnlLine."SF Consolidation Currency" := FixedAsset."SF Consolidation Currency";
            //         GLEntry."SF Consolidation Currency" := FixedAsset."SF Consolidation Currency";
            //         GLEntry."SF ConsCurrencyFactor" := currencyExchangeRate."Relational Exch. Rate Amount";
            //         GLEntry."SF FA NO." := salesinvoiceline."No."
            //     end;
            // end;

            if GenJnlLine."Journal Template Name" = 'RECURRING' then begin           //判斷循環傳票過帳
                currencyExchangeRate.SetRange("Currency Code", PurchasesPayablesSetup."SF Consolidation Currency");
                currencyExchangeRate.SetAscending("Starting Date", false);
                currencyExchangeRate.SetFilter("Starting Date", '<=%1', GenJnlLine."Posting Date");
                IF currencyExchangeRate.FindSet() then;

                GLAccountcard.SetRange("No.", GLEntry."G/L Account No.");
                GLAccountcard.FindFirst();

                unpostgenjournalline.SetRange("Posting Date", GenJnlLine."Posting Date");
                unpostgenjournalline.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
                unpostgenjournalline.SetRange("Line No.", GenJnlLine."Line No.");
                // unpostgenjournalline.SetRange("Document Type", GenJnlLine."Document Type");
                // unpostgenjournalline.SetRange("Document No.", GenJnlLine."Document No.");
                unpostgenjournalline.FindFirst();


                if GLAccountcard."SF Apply Consol.CurrencyFactor" = true then begin
                    if GenJnlLine."SF Consolidation Currency" = '' then begin
                        currenctUnitcost2 := GenJnlLine.Amount / currencyExchangeRate."Relational Exch. Rate Amount";
                        GenJnlLine."SF Consolidation Currency" := currencyExchangeRate."Currency Code";
                        GenJnlLine."SF ConsolidationCurrencyFactor" := currencyExchangeRate."Relational Exch. Rate Amount";
                    end else begin
                        currenctUnitcost2 := GenJnlLine.Amount / GenJnlLine."SF ConsolidationCurrencyFactor";
                    end;

                    if currenctUnitcost2 > PurchasesPayablesSetup."SF ApplConsCurrOrdPurInvandRec" then begin
                        GLEntry."SF Consolidation Currency" := GenJnlLine."SF Consolidation Currency";
                        GLEntry."SF ConsCurrencyFactor" := GenJnlLine."SF ConsolidationCurrencyFactor";
                        GLEntry."SF CurrencyExchageCompare" := currenctUnitcost2
                    end;

                    if currenctUnitcost2 < '0' then
                        if currenctUnitcost2 < PurchasesPayablesSetup."SF ApplConsCurrOrdPurInvandRec" then begin
                            GLEntry."SF Consolidation Currency" := GenJnlLine."SF Consolidation Currency";
                            GLEntry."SF ConsCurrencyFactor" := GenJnlLine."SF ConsolidationCurrencyFactor";
                            GLEntry."SF CurrencyExchageCompare" := currenctUnitcost2
                        end;
                end;



                //判斷循環傳票過帳 的 curreny 和 currency factor 與 purchase&payabke setup 不同，將會失敗    
                // if (unpostgenjournalline."SF ConsolidationCurrencyFactor" = currencyExchangeRate."Relational Exch. Rate Amount") and (unpostgenjournalline."SF Consolidation Currency" = currencyExchangeRate."Currency Code") then begin
                //     GLEntry."SF Consolidation Currency" := unpostgenjournalline."SF Consolidation Currency";
                //     GLEntry."SF ConsCurrencyFactor" := unpostgenjournalline."SF ConsolidationCurrencyFactor"
                // end else begin
                //     Error(message, GenJnlLine."Document No.");
                // end;
            end

        end;
    end;

    // --------------------------   1   過帳 -----------------------------------------------------------------

    // 2
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterInsertGLEntry, '', false, false)]
    local procedure OnAfterInsertGLEntry(var Sender: Codeunit "Gen. Jnl.-Post Line"; GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; TempGLEntryBuf: Record "G/L Entry" temporary; CalcAddCurrResiduals: Boolean);
    var
        purchaseinv: record "Purch. Inv. Header";
        currencyexchangerate: Record "Currency Exchange Rate";
        GLAccountcard: Record "G/L Account";
        PostedGenjournalline: Record "Posted Gen. Journal Line";
        FAledgerentry: Record "FA Ledger Entry";
    begin
        TempGLEntryBuf."SF Consolidation Currency" := GLEntry."SF Consolidation Currency";
        TempGLEntryBuf."SF ConsCurrencyFactor" := GLEntry."SF ConsCurrencyFactor";
    end;
}
