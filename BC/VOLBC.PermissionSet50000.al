/// <summary>
/// PermissionSet VOLBC (ID 50000).
/// Grants permissions to this app's objects. The Cortex Configurations codeunit
/// must be listed here: the project's service principal executes it over the
/// CortexConfigurations web service, and without execute permission the call
/// fails for the caller rather than the author.
/// </summary>
permissionset 50000 "VOLBC"
{
    Assignable = true;
    Caption = 'VOLBC', MaxLength = 30;

    Permissions = codeunit "VOL Cortex Configurations" = X;
}
