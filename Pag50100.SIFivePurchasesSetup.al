page 50100 SIFivePurchasesSetup
{
    ApplicationArea = All;
    Caption = 'SIFivePurchasesSetup';
    PageType = List;
    SourceTable = "Purchases & Payables Setup";
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("SF Consolidation Currency"; Rec."SF Consolidation Currency")
                {
                    ToolTip = 'Specifies the value of the Consolidation Currency field.';
                }
            }
        }
    }
}
