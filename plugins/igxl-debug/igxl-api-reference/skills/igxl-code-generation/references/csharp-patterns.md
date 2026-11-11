<!-- Copyright (C) 2026 Teradyne, Inc. All rights reserved.
This document contains proprietary and confidential information of Teradyne,
Inc. and is tendered subject to the condition that the information (a) be
retained in confidence and (b) not be used or incorporated in any product
except with the express written consent of Teradyne, Inc. -->

# Common C# IG-XL Patterns

Compressed from the Teradyne-authored 2026 `csharp_generation_instructions.md`. This file encodes common rules and decision branches rather than repeating examples. It is compact composition guidance, not a comprehensive standalone authority. Use it together with `search_igxl_api` for every concrete API, enum, rooted path, parameter, and overload, and MyInfo when conceptual/product context is unresolved.

## Authority And Applicability

Use these rules for C# that references `Teradyne.Igxl.Interfaces.Public`, derives from `TestCodeBase`, uses IG-XL attributes, or mentions IG-XL, UltraFLEX, tester instruments, pins, patterns, sites, limits, or datalog. MyInfo may return VBA examples; translate their intent using these rules instead of naively copying syntax.

## File And Test Skeleton

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using Teradyne.Igxl.Interfaces.Public;
using static Teradyne.Igxl.Interfaces.Public.Constants.Global_Units;

namespace WorkbookName {
    [TestClass]
    public class SampleTests : TestCodeBase {
        [TestMethod]
        public void SampleTest(PinList pins, double voltage) {
            // Add only API-grounded task logic.
        }
    }
}
```

- Namespace should match the project/workbook. Do not duplicate existing `using` statements.
- Test classes are public, use `[TestClass]`, and inherit `TestCodeBase`.
- Test methods use `[TestMethod]`, return `void`, and use K&R braces.
- Use task-appropriate parameters. Unsigned test inputs are unsupported.
- Prefer `PinList`, `Pattern`, and `PatternSet` over strings: they integrate validation, instance editing, and pattern loading. Preserve PinList order. Do not add `.ToString()` to `Pattern`; implicit string conversion is supported.
- `InterposeName` values must be fully qualified method names.
- Express physical quantities with `Global_Units` multipliers, such as `1.8 * V`, `100 * mA`, or `0.5 * ms`, when the value represents a unit.

## Root Objects, Kinds, And Access

| Root | Responsibility |
|---|---|
| `TheHdw` | Instruments, pins, and tester hardware |
| `TheExec` | Execution, sites, limits, pass/fail, output, and datalog |
| `TheProgram` | Test-program data, sheets, paths, and security |

- Call a method with parentheses. Read or assign a property without call parentheses.
- A property may return another interface: `Meter` can provide interface access while `Meter.Read()` performs an operation.
- Instrument-first and pin-first access can reach equivalent interfaces. Choose the form that matches the task context.
- Prefer explicit leaf types. Use `var` only for short, block-scoped aliases to generated IG-XL interface chains:

```csharp
{
    var dcvi = TheHdw.DCVI.Pins(pins);
    dcvi.Mode = tlDCVIMode.Voltage;
}
```

- Avoid `object` when a concrete type exists. Prefer supported conversion methods over explicit casts.
- Translate flat VBA enums to verified dotted C# enums, but never infer the enum type mechanically: `tlDCVIModeVoltage` may become `tlDCVIMode.Voltage`, while other families use different type names.

## Measurement, Limits, And Datalog

`TheExec.Flow.TestLimit` performs limit checking and datalog. Prefer Flow Table limits when the test-program design supplies them; still pass result and datalog metadata. Use named arguments because most parameters are optional.

```csharp
PinSite<double> results = TheHdw.DCVI.Pins(pins).Meter.Read().ToPinSite<double>();

TheExec.Flow.TestLimit(
    ResultVal: results,
    Unit: UnitType.Amp,
    ForceVal: forceVoltage,
    ForceUnit: UnitType.Volt,
    ForceResults: tlLimitForceResults.Flow);
```

Confirm measurement, conversion, units/enums, and the chosen `TestLimit` overload. SiteGeneric datalog supports only payload types compatible with STDF fields.

## Multisite Decision Table

Every test must remain site-scalable, even when currently run on one site.

| Data shape | Use |
|---|---|
| Identical for all sites | Scalar `T` |
| One value per site | `Site<T>` |
| Values per pin and site | `PinSite<T>` |
| Sample collection | `Samples<T>`, usually wrapped by Site/PinSite outside DSP |

Invariants:

- Never hard-code a SiteGeneric index in production code. A constant index is allowed only for explicit debug output.
- Use `ForEachSite(site => ...)` for scalar per-site access and its integrated site/error behavior.
- Use `.Fill()` or a constructor to assign all sites; a SiteGeneric does not accept scalar assignment directly.
- Perform SiteGeneric math outside site loops when possible; math naturally operates across selected sites.
- Math and DSP results are deferred. Accessing a specific site forces evaluation and can silently block background processing. Pass deferred expressions to `TestLimit` when possible.
- For site-serial acquisition, collect/merge values inside the site loop, then resume parallel processing outside it.

## Legacy Result Conversion

Instrument drivers often return VBA-oriented site-aware objects. Do not retain `PinListData`, `SiteLong`, `SiteDouble`, `SiteBoolean`, `SiteVariant`, or `DspWave` as C# working storage.

| Source shape | Conversion |
|---|---|
| Multi-pin `PinListData` | `.ToPinSite<T>()` |
| Single-pin `PinListData` | `.SinglePinToSite<T>()` |
| `SiteVariant` | `.ToSite<T>()` |
| `PinSite<T>` needed by legacy API | `.ToPinListData()` |
| `Site<T>` needed by legacy API | `.ToSiteDouble()` or the verified matching converter |

Use `SinglePinToSite<T>` for one pin and `ToPinSite<T>` for multiple pins. Confirm the source return shape and converter; do not choose from naming alone.

## Site Groups And Selection

Represent a site group with `Site<bool>` and assign it to `TheExec.Sites.Selected.Value`. Math/methods leave masked-site values unchanged, but indexers can still read or mutate masked sites. Always restore all sites after grouped work, normally by assigning `true`, including on failure paths.

## Validation, Lifetime, And Data

For custom validation:

```csharp
[TestMethod, CustomValidation]
public void SampleTest(PinList pins) {
    if (TheExec.Flow.IsValidating) {
        // Validate arguments and references; do not perform runtime hardware work.
        return;
    }

    // Runtime test logic.
}
```

- Only active Flow Table test instances execute custom validation.
- Default `Creation.Always` creates/discards a class object per call.
- `Creation.TestInstance` persists one object per test instance across runs.
- `Creation.Once` shares one persistent object across all test instances of the class.
- Choose lifetime intentionally; do not assume instance fields persist.
- VBA/.NET shared variables must be defined as public .NET class/module variables and use simple types. Cross-domain persistence uses IG-XL's persistent data mechanism.
- Cross-run VBA/C# state requires project- and version-specific persistent-data setup. If the actual mechanism, ownership, or initialization/reset lifecycle is not available from project evidence, do not generate storage code; ask for the existing persistence pattern or IG-XL project context.
- Read IG-XL sheet data through `TheProgram.TestData`; do not automate Excel or use third-party sheet readers from test code.
- Use `IGXLROOT` and `TEMP` environment variables instead of hard-coded installation/temp paths.

## Exceptions And Cleanup

IG-XL supplies fallback handling for unhandled test-method exceptions. Add local structured `try`/`catch`/`finally` only for expected recovery or mandatory cleanup; catch specific exceptions. Do not translate VBA `On Error GoTo`. For connect/force/measure workflows, treat disconnect, site-selection restoration, and other hardware cleanup as separate choreography requirements, not facts proven merely by API existence.

## Generation Gate

Before emitting code, verify every API and enum, conversion direction, member kind, rooted navigability, overload, site shape, lifecycle choice, and hardware-sequencing assumption. If a rule depends on missing context, expose a parameter or ask one clarification. Label output "not compiled or executed" unless actual evidence proves otherwise.