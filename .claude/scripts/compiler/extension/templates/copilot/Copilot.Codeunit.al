namespace {{rootnamespace}};

using System.AI;

codeunit 50100 "Copilot"
{
    procedure Generate(Request: Text): Text
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        Result: Text;
    begin
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Request Copilot");
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", GetEndpoint(), GetDeployment(), GetApiKey());

        AOAIChatMessages.AddUserMessage(Request);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIOperationResponse);

        if AOAIOperationResponse.IsSuccess() then
            Result := AOAIChatMessages.GetLastMessage()
        else
            Error(AOAIOperationResponse.GetError());
        exit(Result);
    end;

    local procedure GetEndpoint() Endpoint: Text
    begin
        if not IsolatedStorage.Get('endpoint', Endpoint) then
            Error('Endpoint not set, please update the Copilot Config page.');
    end;

    local procedure GetDeployment() Deployment: Text
    begin
        if not IsolatedStorage.Get('deployment', Deployment) then
            Error('Deployment not set, please update the Copilot Config page.');
    end;

    local procedure GetApiKey() Secret: SecretText
    begin
        if not IsolatedStorage.Get('apikey', Secret) then
            Error('Api key not set, please update the Copilot Config page.');
    end;

    internal procedure SetEndpoint(Value: Text)
    begin
        if Value = '' then begin
            if IsolatedStorage.Delete('endpoint') then;
        end
        else
            IsolatedStorage.Set('endpoint', Value);
    end;

    internal procedure SetDeployment(Value: Text)
    begin
        if Value = '' then begin
            if IsolatedStorage.Delete('deployment') then;
        end
        else
            IsolatedStorage.Set('deployment', Value);
    end;

    internal procedure SetApiKey(Value: SecretText)
    begin
        if Value.IsEmpty() then begin
            if IsolatedStorage.Delete('apikey') then;
        end
        else
            IsolatedStorage.Set('apikey', Value);
    end;
}