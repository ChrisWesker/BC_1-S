pageextension 50101 SifiveFixAssetCardExten1 extends "Fixed Asset Card"
{
    layout
    {
        addafter(Control38)
        {
            field("SF Consolidation Currency"; Rec."SF Consolidation Currency")
            {
                ApplicationArea = all;
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

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        message: Label 'SF Consolidation Currency must have a value in Fixed Asset Card: No.="%1" ';
    begin
        if isvisible and (rec."SF Consolidation Currency" = '') then
            message(message, Rec."No.");
    end;

    var
        isvisible: Boolean;
}
