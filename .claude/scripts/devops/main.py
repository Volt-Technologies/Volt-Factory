import asyncio
from claude_agent_sdk import ClaudeSDKClient, AssistantMessage, TextBlock, ResultMessage, ClaudeAgentOptions

ClaudeOptions = ClaudeAgentOptions(
        #allowed_tools=["Bash"],
        permission_mode="bypassPermissions"
    )


#Create functional requirement
#Create Technical requirement
#Code the solution
#Test the solution

async def main():
    async with ClaudeSDKClient(ClaudeOptions) as client:
        # First question

        #Load the file user_request.md and pass it to the client.query
        with open('user_request.md', 'r') as file:
            user_request = file.read()
        await client.query(user_request)

        # Process response
        
        async for message in client.receive_response():
            if isinstance(message, AssistantMessage):
                for block in message.content:
                    if isinstance(block, TextBlock):
                        print(f"Claude: {block.text}")
       
asyncio.run(main())