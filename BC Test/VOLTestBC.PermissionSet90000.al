permissionset 90000 VOLTestBC
{
    Assignable = true;
    Caption = 'VOLTESTBC', MaxLength = 30;
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
