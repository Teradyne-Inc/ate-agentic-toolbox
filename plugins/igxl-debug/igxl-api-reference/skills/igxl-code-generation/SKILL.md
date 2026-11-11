---
name: igxl-code-generation
description: 'Generate, explain, review, or change C# IG-XL test code using grounded API evidence. Use automatically for IG-XL, TheHdw, TheExec, TheProgram, tester instruments, pins, patterns, measurements, limits, datalog, UltraFLEX, or Teradyne test-code requests. Guides broad and focused API searches, methods versus properties, overload confirmation, C# structure, and no-invention checks.'
argument-hint: 'Describe the IG-XL C# task'
---

<!-- Copyright (C) 2026 Teradyne, Inc. All rights reserved.
This document contains proprietary and confidential information of Teradyne,
Inc. and is tendered subject to the condition that the information (a) be
retained in confidence and (b) not be used or incorporated in any product
except with the express written consent of Teradyne, Inc. -->

# IG-XL C# Code Generation

Use this workflow for natural-language IG-XL coding requests. The user should not need to name an MCP tool.

## Evidence Roles

- `search_igxl_api`: authority for API names, kinds, rooted code references, descriptions, overloads, and the declaration facts `is_read_only`, `accessor`, `return_type`, and `parameter_enum_values`.
- [C# patterns](./references/csharp-patterns.md): common C# test structure, typing, lifecycle, validation, multisite, conversion, and datalog rules.
- [DSP and RunDsp](./references/dsp-rundsp.md): load only for DSP, DspClass, DspMethod, RunDsp, Samples, or DemodDSP requests.
- MyInfo Copilot: optional conceptual context when terminology or workflow remains unclear; never API authority.

Do not infer an API from an example. Do not infer code structure from search ranking alone. Do not infer assignability from description wording: `is_read_only=true` forbids assignment even when the description opens "Sets".

## Procedure

1. Parse the task into independent actions, required access-chain members, and unresolved concepts. For example, "connect the PPMU and force a current" requires evidence for selector, connection, and force actions.
2. Load the DSP reference only when the request involves DSP or RunDsp. Otherwise use the common C# patterns only.
3. If the task depends on IG-XL APIs, make an evidence plan before writing code or issuing tools. Map each requested action and each emitted access-chain member to the kind of evidence it needs: selector, operation, property value leaf, or exact overload.
4. Run an orientation evidence wave before the next reasoning step:
   - for a simple, direct task, use one broad query with the user's wording, `mode="hybrid"`, 10 results, all kinds, and no overloads;
   - for a multi-action, ambiguous, chain-sensitive, or overload-sensitive task, issue normally 4-6 independent `search_igxl_api` calls in parallel: the full task wording, one query per independent action, selector/access-chain queries, and exact identifier or overload queries when already named or strongly indicated;
   - use 20 results for the full multi-action query and 5-10 for targeted queries;
   - use more than six calls only when every added call establishes a distinct missing action, selector, setter/value leaf, or overload. Do not split dependent calls in parallel when a later query must be derived from earlier evidence.
5. Inspect the complete orientation evidence bundle together. If every requested action and chain member already has a clear, rooted candidate with the right kind and required signature facts, skip refinement and generate only after the final gates below.
6. Refine only a specific evidence gap. Dispatch all independent refinement queries in parallel:
   - methods for operations;
   - properties for values, state, configuration, or navigable interfaces;
   - `word` for exact names/identifiers;
   - `dense` for paraphrase or vocabulary mismatch;
   - `hybrid` as the primary mode and exact-identifier check.
7. For method/property uncertainty, compare both kinds. Grammar alone is insufficient: "set" may assign a property. A property described only as an interface or syntax surface is not proof that `property = value` is valid; confirm the scalar setter, value leaf, indexer, and value type before emitting an assignment. `is_read_only` and `accessor` carry the setter fact and `return_type` the value type; `is_read_only=true` (`accessor=get`) forbids the assignment, `accessor=set` is write-only so use it only as an assignment target, and an empty `accessor` marks a non-property rather than missing evidence.
8. Confirm final chain members in parallel. Request 3-5 results and `include_overloads=true` for every method, indexer, or argument-bearing member that will appear in code. If a fully qualified dotted query ranks poorly, retry the exact returned member `name` plus its kind; do not assume more path terms improve ranking. A capability-level `return_type` containing " | " reports that the overloads disagree, so bind to the chosen overload's own `return_type` and never to the joined string.
9. Generate C# using the applicable references and only confirmed API evidence. Use the `[TestClass]`, `TestCodeBase`, and `[TestMethod] public void` structure from C# patterns; never invent an `Execute()` override or another lifecycle shape.
10. Audit every IG-XL member, enum, parameter, rooted path, multisite conversion, and lifecycle assumption against evidence. Take enum members from `parameter_enum_values` on the same card and emit them as `EnumType.MemberName` rather than searching again; its absence does not prove a parameter takes no enum. For compound requests, audit each requested action separately: evidence for one action never covers another.
11. State unresolved hardware values, pin names, limits, version assumptions, selector syntax, setter/value-type facts, or missing conceptual context.
12. Say "not compiled or executed" unless actual compile/runtime evidence exists.

## Stop Conditions

Code is ready to draft only when each requested action has:

- a returned API whose kind and description support the action;
- a returned `code_reference`;
- `navigable_from_root=true` when code dereferences TheHdw, TheExec, or TheProgram;
- a confirmed overload when arguments are required; and
- confirmed selector, indexer, setter, and value-type facts for every emitted chain member, reading `is_read_only` and `accessor` for the setter fact and `return_type` for the value type.

For a compound request, every independently requested action must meet this gate before code is emitted. After an orientation wave and one targeted parallel refinement wave, ask one targeted clarification if evidence is still insufficient. Use another wave only when newly returned evidence creates a distinct required chain member; do not keep searching indefinitely.

Fail closed when the service is unavailable, no candidate supports the behavior, terminology remains unresolved, or overloads do not support required arguments. Never generate plausible fallback APIs.

## Context Controls

- Orientation: one broad direct query, or normally 4-6 independent parallel searches for multi-action or chain-sensitive work; 10 results, or 20 for the full multi-action query; overloads off except for already known signature-critical candidates.
- Focused: 5-10 results per distinct evidence gap; run independent focused searches in parallel.
- Confirmation: 3-5 results; overloads on for every final method, indexer, or argument-bearing chain member.
- No arbitrary call-count cap: retain only calls that establish a distinct required fact, deduplicate returned cards by `code_reference`, and stop rather than collecting unrelated context.
- Keep only identity, kind, description, navigability, selector facts, read/write facts (`is_read_only`, `accessor`), value-type facts (`return_type`), any `parameter_enum_values` needed for emitted enum members, and final overload facts between phases.
- Include internal helpers only for an explicit internal/debug request or after the user approves that fallback.

## Multi-Action Example

For "strobe and read a DCVI meter":

1. In one parallel orientation wave, search the full task, `strobe DCVI meter`, `read DCVI meter measurement`, and the DCVI meter/access-chain selector. Add exact identifier or overload searches only when the task or broad evidence makes them independently necessary.
2. Inspect the combined bundle. If it proves both actions and every emitted access-chain member, skip refinement.
3. Otherwise run only the unresolved selector, operation, property-value, or overload queries in a parallel refinement wave.
4. Confirm the final Strobe and Read method families with overloads in parallel.
5. Generate only when both requested actions and all emitted chain members pass the evidence gate.

For unfamiliar shorthand such as `CPUA`, preserve the raw wording in one search and test paraphrases separately. If no evidence resolves the term, ask the user or consult MyInfo rather than guessing.