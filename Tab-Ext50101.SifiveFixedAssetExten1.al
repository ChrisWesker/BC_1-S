tableextension 50101 SifiveFixedAssetExten1 extends "Fixed Asset"
{
    fields
    {
        field(50100; "SF Consolidation Currency"; Code[20])
        {
            Caption = 'SF Consolidation Currency';
            DataClassification = ToBeClassified;
            TableRelation = Currency;

            trigger OnValidate()
            var
                message: Label 'SF Consolidation Currency must have a value in Fixed Asset Card: No.="%1" ';
            begin
                if GLsetup.SFConsolidationCurrencyFactor = true then begin
                    if "SF Consolidation Currency" = '' then begin
                        message(message, RecordId);
                    end;
                end;
            end;
        }
    }

    var
        GLsetup: Record "General Ledger Setup";

}
