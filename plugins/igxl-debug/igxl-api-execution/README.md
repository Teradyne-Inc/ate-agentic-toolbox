# igxl-api-execution

The igxl-api-execution MCP server is one of the MCPs in the IG-XL Debug Plugin. It works with the 
igxl-api-reference and igxl-flow-manager-mcp. The igxl-api-reference MCP helps an agent find public
APIs to perform a debug action. The igxl-flow-manager-mcp confirms IG-XL is in a suitable state.
The igxl-api-execution MCP executes agent-generated code against a live IG-XL test program that's 
paused at a breakpoint, to perform the desired debug action.

## Usage

- Install `igxl-api-execution-mcp.exe`, and make it available on `PATH`.
- Start IG-XL with an active test program.
- Pause the program at a flow breakpoint, VBA breakpoint or C# breakpoint before executing
  generated code. Debug (blue button) runs are recommended. Running while the test program is active 
  would race with the program for shared tester state.

The plugin starts the local MCP server through `.mcp.json`. 

## Included content

- `skills/igxl-code-execution/SKILL.md` covers execution, console output,
  multisite values, units, and common failures.
