permissionset 90000 TestVolt
{
    Assignable = true;
    Caption = 'BCTEST'
    Permissions =
        codeunit "VOL Test Runner WS" = X,
        tabledata "AL Test Suite" = RIMD,
        tabledata "Test Method Line" = RIMD,
        tabledata "CAL Test Line" = RIMD,
        tabledata "CAL Test Coverage Map" = RIMD,
        tabledata "CAL Test Enabled Codeunit" = RIMD,
        tabledata "CAL Test Result" = RIMD,
        tabledata "CAL Test Codeunit" = RIMD,
        // Test execution codeunits
        codeunit "Test Runner - Mgt" = X,
        codeunit "Test Runner - Isol. Codeunit" = X,
        codeunit "Test Runner - Isol. Disabled" = X;
}
