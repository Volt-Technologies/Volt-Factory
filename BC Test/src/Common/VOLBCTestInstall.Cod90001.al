codeunit 90001 "VOLBC Test Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        SetPermissionSet();
    end;

    procedure SetPermissionSet()
    var
        AppReg: Record "AAD Application";
        AppPermisionLbl: Label 'VOLBC', Locked = true;
        TestpermissionsLbl: Label 'VOLTESTBC', Locked = true;

    begin
        if AppReg.FindSet(false) then
            repeat
                AddPermissionSetToUser(AppReg."User ID", AppPermisionLbl, CompanyName());
                AddPermissionSetToUser(UserSecurityID, TestpermissionsLbl, CompanyName());
            until AppReg.Next() = 0;
    end;

    local procedure AddPermissionSetToUser(UserSecurityID: Guid; RoleID: Code[20]; Company: Text[30])
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityID);
        AccessControl.SetRange("Role ID", RoleID);
        AccessControl.SetRange("Company Name", Company);

        if not AccessControl.IsEmpty() then
            exit;

        AccessControl.Init();
        AccessControl."Company Name" := Company;
        AccessControl."User Security ID" := UserSecurityID;
        AccessControl."Role ID" := RoleID;
        AccessControl.Insert(true);
    end;
}
