tableextension 50102 SifiveGLEntryExten1 extends "G/L Entry"
{
    fields
    {
        field(50100; "SF Consolidation Currency"; Code[20])
        {
            Caption = 'SF Consolidation Currency';
            DataClassification = ToBeClassified;

        }
        field(50101; "SF ConsCurrencyFactor"; Decimal)
        {
            Caption = 'SF Consolidation Currency Factor';
            DecimalPlaces = 3 : 3;
            DataClassification = ToBeClassified;
        }
        field(50102; "SF CurrencyExchageCompare"; Decimal)
        {
            Caption = 'SF CurrencyExchageCompare';
            DataClassification = ToBeClassified;
        }
        field(50103; "SF FA NO."; code[20])
        {
            Caption = 'SF FA No.';
            DataClassification = ToBeClassified;
        }
        field(50104; "SF connetmark"; Boolean)
        {
            Caption = 'SF connetmark';
            CalcFormula = exist("Gen. Journal Line" where("SF G/L Entry No." = field("Entry No.")));
            FieldClass = FlowField;
        }
    }

    trigger OnInsert()

    begin
        GLentry.SetRange("Source Code", purchaseinvoiceheader."Source Code");
        GLentry.SetRange("Document No.", purchaseinvoiceheader."No.");
    end;

    var
        GLentry: Record "G/L Entry";
        purchaseinvoiceheader: Record "Purch. Inv. Header";
        GenJoural: record "Gen. Journal Line";
}
