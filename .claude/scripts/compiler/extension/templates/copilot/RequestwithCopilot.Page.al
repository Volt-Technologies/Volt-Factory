namespace {{rootnamespace}};

page 50100 "Request with Copilot"
{
    PageType = PromptDialog;
    Extensible = false;
    IsPreview = true;
    Caption = 'Request with Copilot';

    layout
    {
        area(Prompt)
        {
            field(ChatRequest; ChatRequest)
            {
                ShowCaption = false;
                MultiLine = true;
                ApplicationArea = All;
                InstructionalText = 'Provide the text for request.';
            }
        }

        area(Content)
        {
            field(ChatResponse; ChatResponse)
            {
                ShowCaption = false;
                MultiLine = true;
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                ToolTip = 'Generate request with Dynamics 365 Copilot.';

                trigger OnAction()
                begin
                    RunGeneration();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Confirm';
                ToolTip = 'Save response.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
                ToolTip = 'Discard response.';
            }
            systemaction(Regenerate)
            {
                Caption = 'Regenerate';
                ToolTip = 'Regenerate request.';
                trigger OnAction()
                begin
                    RunGeneration();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Caption := 'Request with Copilot';
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = CloseAction::OK then begin
            // Save output
        end;
    end;

    local procedure RunGeneration()
    var
        InStr: InStream;
        Attempts: Integer;
    begin
        CurrPage.Caption := ChatRequest;

        ChatResponse := Copilot.Generate(ChatRequest);
    end;

    var
        Copilot: Codeunit "Copilot";
        ChatRequest: Text;
        ChatResponse: Text;
}