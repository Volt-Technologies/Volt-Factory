namespace {{rootnamespace}};

using System.AI;

codeunit 50101 "Copilot Install"
{
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrlTxt: Label 'https://example.com/CopilotToolkit', Locked = true;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Request Copilot") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Request Copilot", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);
    end;
}