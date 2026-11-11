# igxl-api-reference

Use `igxl-api-reference` to find public API definitions and generate C# from
retrieved evidence instead of guessed members or signatures.

## MCP server

The plugin starts `igxl-api-reference-mcp.exe` as a local MCP server through its
bundled `.mcp.json`.

## Included content

- [skills/igxl-code-generation/SKILL.md](skills/igxl-code-generation/SKILL.md)
  defines the evidence-first code generation workflow and links to the bundled
  [C# patterns](skills/igxl-code-generation/references/csharp-patterns.md) and
  [DSP and RunDsp](skills/igxl-code-generation/references/dsp-rundsp.md)
  references.

Search results are the source of truth for API names and signatures. When the
server cannot find enough evidence, report the gap instead of filling it with
an assumption.
