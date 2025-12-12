Whenver you are asked to develop any AL change, either a new feature, fix a bug  or make a small change, it is MANDATORY that you follow this flow of actions:

1. Use the bc-al-developer subagents, and the al-guidelines ANY TIME you code in AL Langauge for Business Central.
2. Once you consider you are done with coding,  you need to compile the application with the bc-app-compiler subagent. If you get any compiling error, not allowing you to compile the app, you will need to go back, use the bc-al-developer agent to fix it, and then try to compile again.
3. Once you are done compiling the app, you will have to publish it to Business Central. For that, you will keep using the bc-app-compiler subagent.
4. Once the main code has been coded, compiled, and published, you will need to create the automated tests for what you have developed, to make sure it works the way you expected it to work. Publishing is NOT ENOUGH to consider your job done. Therefore, you will now need to use the Test app, and in the same way, yo uwill need to code the automated tests, compile the Test app, publish it. As you can see, you need to follow the same logic where if you get an error compiling the test app, you will need to rework on it, until it compiles and publishes. 
5. Then run the automated tests, Use the bc-test-runner agent for that.
6. Only when you have passed all automated tests, then you can consider your job done. If not, based on the errors, you will have to go back to point 1, and code, compile, publish and run the tests again until the tests pass.

It is mandatory you create create the AL objects grouped by global feature, with objects organizes in subfolders uch as:
    src/
        [Feature A]/
            table/
            tableextension/
            page/
            codeunit/

Mandatory to have created or updated the permissionset before compiling
Do not ever change the format of a file to be able to compile the BC app.
Do not remove dependencies in the Test app
You will need to download symbols for the first time, if you get a missing object error
Test Runner app is installed in the BC environments.
For today, DO NOT USE DOCKER, DO NOW DOWNLOAD ANY DOCKER IMAGE.