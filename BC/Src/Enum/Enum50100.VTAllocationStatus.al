/// <summary>
/// Enum VT Allocation Status (ID 50100)
/// Represents the status of an allocation in sales and purchase documents
/// </summary>
enum 50100 "VT Allocation Status"
{
    Extensible = true;
    Caption = 'VT Allocation Status';

    value(0; Active)
    {
        Caption = 'Active';
    }
    value(1; Cancelled)
    {
        Caption = 'Cancelled';
    }
}