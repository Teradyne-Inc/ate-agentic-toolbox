<!-- Copyright (C) 2026 Teradyne, Inc. All rights reserved.
This document contains proprietary and confidential information of Teradyne,
Inc. and is tendered subject to the condition that the information (a) be
retained in confidence and (b) not be used or incorporated in any product
except with the express written consent of Teradyne, Inc. -->

# DSP And RunDsp C# Patterns

Load this module only for DSP, `[DspClass]`, `[DspMethod]`, RunDsp, `Samples<T>`, DSP persistence, ESA, or DemodDSP requests. It compresses current Teradyne 2026 guidance. Confirm concrete APIs through `search_igxl_api`.

## Architecture Invariants

- DSP code lives in a separate C# DSP project/DLL referenced by the test-code project.
- A DSP class is public, uses `[DspClass]`, and is non-static.
- A DSP method is public, non-static, uses `[DspMethod]`, and returns `void`.
- DSP methods run for one site and one pin, so their signatures use scalar values and `Samples<T>`, not `Site<T>` or `PinSite<T>`.
- Results return through `ref` parameters.
- IG-XL generates static RunDsp wrappers that translate scalar DSP signatures into multisite/multipin host signatures and schedule parallel execution.
- DSP does not support arbitrary enums, structures, or classes. Fail closed when a type is not explicitly supported.
- Use the Visual Studio IG-XL DSP project template and required target runtime for the installed IG-XL version; do not assume a normal test-code project is sufficient.
- Avoid C++ libraries in DSP projects. Match SiteGeneric element types to instrument return types because IG-XL does not guarantee a compatibility check at the DSP boundary.

```csharp
using Teradyne.Igxl.Interfaces.Public;

namespace DspProject {
    [DspClass]
    public class MeasurementDsp {
        [DspMethod]
        public void Calculate(Samples<double> capture, ref double result) {
            // Scalar DSP logic.
        }
    }
}
```

## Wrapper Shape Decision Table

| DSP scalar argument | Default host wrapper | Pin/site wrapper |
|---|---|---|
| `T` | `Site<T>` | `PinSite<T>` |
| `Samples<T>` | `Site<Samples<T>>` | `PinSite<Samples<T>>` |
| `[RunDspParameter.Scalar] T` | scalar `T` | scalar `T` |
| `[RunDspParameter.Site] T` | `Site<T>` | `Site<T>` |
| `ref T` result | `ref Site<T>` | `ref PinSite<T>` |

- Use `[DspMethod, RunDspType.PinSite]` when the wrapper must process pins and sites.
- A parameter may have only one parameter attribute.
- `[RunDspParameter.Scalar]` inputs cannot use `ref`.
- Supported scalar families include string, bool, int/double scalars and arrays, and `Samples<int/double>`; verify current API/version support.

## Dimensional Branches

Multiple-pin `PinSite<T>` input:

- all multi-pin inputs must have matching pin counts;
- outputs must be `PinSite<T>`;
- output pin structure follows the first multi-pin input;
- `Site<T>` inputs repeat their site value across pins;
- scalar inputs repeat across every pin/site.

One-pin `PinSite<T>` input:

- behaves like `Site<T>` across sites;
- outputs may be `Site<T>` or `PinSite<T>`;
- output pin names derive from the first site/pin input;
- scalar inputs repeat across sites.

Do not generate a wrapper call when input pin counts, output dimensions, or the generated wrapper signature are unknown.

## Deferred Execution

RunDsp work is queued and may execute in the background as hardware data arrives. Preserve SiteGeneric deferral:

- avoid indexing results before limits/datalog unless immediate evaluation is required;
- perform SiteGeneric math as expressions and pass deferred results onward;
- understand that direct access can silently synchronize and reduce parallelism;
- host-debug execution behavior differs from automatic embedded execution.

## Persistent DSP State

DSP objects may retain large or measurement-specific values across calls. Avoid static variables. Use write-once/read-many state intentionally, and reset state when assemblies reload through the appropriate assembly-loaded interpose path. Host test code does not directly access embedded DSP object state.

## Specialized DemodDSP Branch

Do not translate VBA DemodDSP signatures mechanically. Current .NET patterns may replace by-reference `DSPWave` outputs with string result IDs and result-store retrieval, and may use `ExecuteProcessingResults` variants. Search and confirm every selected .NET member and overload. If result-store choreography is unresolved, ask for a known-good project example rather than inventing it.

## DSP Generation Gate

Before generating DSP code, require evidence for:

1. separate project/reference expectations;
2. scalar DSP method signature and supported types;
3. exact generated RunDsp wrapper or enough declared attributes to predict it safely;
4. input/output site and pin dimensions;
5. `ref` result ownership;
6. deferred-evaluation expectations;
7. persistence/reset requirements.

If any shape or wrapper evidence is missing, provide a partial DSP method skeleton and ask for the generated wrapper/project context. Never claim compilation or embedded execution without evidence.