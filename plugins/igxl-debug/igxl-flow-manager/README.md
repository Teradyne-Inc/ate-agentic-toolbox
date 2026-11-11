# igxl-flow-manager

Use `igxl-flow-manager` to inspect live IG-XL program state, flow position, and test
context from an AI coding assistant.

## Runtime setup

Complete these steps before using the flow-manager MCP.

1. In administrator PowerShell, open the folder containing the downloaded
   `igxl-flow-manager-install.exe` and run:

   ```powershell
   (Start-Process .\igxl-flow-manager-install.exe '/S /CONSUMER=RuntimeTest /CONSUMERPATH="C:\Temp\RuntimeTest"' -Wait -PassThru).ExitCode
   ```

   Exit code `0` means success; resolve any other result before continuing.
   `C:\Temp\RuntimeTest` is the runtime consumer path, not the MCP executable folder.
2. Run the local [verification script](verify-plugin-installation.ps1) from its
   directory. If the plugin is not installed yet, download the linked script first:

   ```powershell
   .\verify-plugin-installation.ps1
   ```

   Confirm the output reports a runtime, plugin entries with `Enabled=1`, and
   `Plugins dir: True  uninstaller: True`.

## MCP server

The plugin starts `igxl-flow-manager-mcp.exe` as a local MCP server through its
bundled `.mcp.json`.