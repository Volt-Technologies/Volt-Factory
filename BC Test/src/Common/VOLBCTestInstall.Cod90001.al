codeunit 90001 "VOLBC Test Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        // Permission sets should be assigned manually by administrators
        // Automatic assignment requires SUPER/SECURITY permissions which may not be available
        // during automated publishing via API
    end;
}
