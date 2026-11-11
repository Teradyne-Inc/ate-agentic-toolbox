---
name: igxl-code-execution
description: 'Execute generated C# code against a live IG-XL instance'
argument-hint: 'a public function that uses IG-XL public language'
---

<!-- Copyright (C) 2026 Teradyne, Inc. All rights reserved.
This document contains proprietary and confidential information of Teradyne,
Inc. and is tendered subject to the condition that the information (a) be
retained in confidence and (b) not be used or incorporated in any product
except with the express written consent of Teradyne, Inc. -->

# IG-XL C# Code Execution

The `igxl-api-execution` MCP server contains an `execute` tool that runs code that you generate against a live IG-XL instance. The intended use case is to perform debug actions for the user, not to generate test program code or do production testing. Here's how to use this tool:

1. Use another MCP server to learn about IG-XL public APIs that can perform what the user is asking for. The search_igxl_api tool on the igxl-api-reference-mcp server is the preferred tool, since it runs quickly and locally. If this is not available, you can use MyInfo Copilot's query tool, if available. MyInfo Copilot runs remotely and is slower, but returns more complete information that can go beyond API syntax. 
2. Note that the user might ask for things that IG-XL public language can't do. For example, invoking some of IG-XL's GUI tools or analyzing waveforms. Work with the user to use code generation and execution along with manual actions they must perform. If you have access to MyInfo Copilot query, you can learn about IG-XL tools and assist them.
3. Once you have learned about IG-XL language that can help fulfill the user's request, generate this language inside a single parameterless public C# function.
4. All output that you require to do your job or pass information on to the user must be output from the code you generate using Console.WriteLine. The `igxl-api-execution` `execute` tool will return all console output to you.
5. The execute tool will wrap your function in an assembly that references IG-XL, compile it, and execute it.
6. IG-XL must be running a test program that is paused at a breakpoint for execute to work properly. If the test program isn't running, IG-XL language will return an error that no sites are active. If IG-XL is running but not in a break state, your code and the test program code will be in a race to modify the shared tester state (bad). You may have access to the igxl-flow-manager-mcp server that can tell you if the program is running or at a flow breakpoint. The user can also set and run to flow breakpoints. The execute tool can also be used if the user has set and run to a C# breakpoint in Visual Studio in one of their test code assemblies or a VBA breakpoint in one of their test functions. Coordinate with the user to ensure the test program is paused at an appropriate breakpoint before executing your code.
7. If your code has a compile or runtime error, the tool will return error information. In these cases, try again or ask the user for guidance.

# Example

Below is an example of a valid argument for the execute tool. This code is appropriate for a user request like "Set the PPMU force voltage to 1.9 V and then read back the force voltage for each site".

    public void AgentPPMUMethod()
    {
        TheHdw.PPMU.Pins("a1").ForceV(1.9);
        var result = TheHdw.PPMU.Pins("a1").Voltage.Value;
        ForEachSite((site) =>
        {
            Console.WriteLine($"Site {site}: Voltage = {result}");
        });
    }


# Gotchas

* Unless otherwise specified, all public language expects voltages to be specified in volts and times in seconds. So, if the user requests setting a force voltage to 350 mV, use 0.350 in the generated language. If they ask to set a period to 65 ns, use 65e-9 in the generated language.

* IG-XL is a multi-site test system, and values are read back into multi-site variables. The above example shows how such results must be printed inside a site loop. If the code had tried to simply print result, IG-XL would have returned an error about how the variable contains multiple values.

* If the user has paused the test program at a C# breakpoint, the program must have been run with a debug (blue button) run for the execute tool to work. If they used the performance (red button) run, the execute will time out.