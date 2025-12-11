namespace {{rootnamespace}};

page 50101 "Copilot Config"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Endpoint; Endpoint)
                {
                    trigger OnValidate()
                    begin
                        Copilot.SetEndpoint(Endpoint);
                    end;
                }
                field(Deployment; Deployment)
                {
                    trigger OnValidate()
                    begin
                        Copilot.SetDeployment(Deployment);
                    end;
                }
                field(ApiKey; ApiKey)
                {
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        Copilot.SetApiKey(ApiKey);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SecretApikey: SecretText;
    begin
        if IsolatedStorage.Get('endpoint', Endpoint) then;
        if IsolatedStorage.Get('deployment', Deployment) then;
        if IsolatedStorage.Get('apikey', SecretApikey) then
            ApiKey := '********';
    end;

    var
        Copilot: Codeunit "Copilot";
        Endpoint: Text;
        Deployment: Text;
        [NonDebuggable]
        ApiKey: Text;
}