# Copilot Instructions for PocketDeputy

## Project Overview

**PocketDeputy** is an iOS Swift Playgrounds / Xcode app built for the Apple Swift Student Challenge. It is a **Mobile Agent Prompt-Injection Safety Lab** — an interactive simulator that teaches users how a mobile AI agent can be manipulated through prompt-injection attacks and how an **Action Gateway** policy engine defends against them.

The entire app lives in `PocketDeputy.swiftpm`, a Swift Package Manager playground bundle.

## Repository Structure

```
PocketDeputy.swiftpm/
  Package.swift                  # SPM manifest (iOS 16+, single executableTarget)
  Sources/AppModule/
    PocketDeputyApp.swift        # @main App entry point
    Models.swift                 # All shared data types (Channel, ToolCall, Evidence, Scenario, …)
    ActionGateway.swift          # Policy engine: evaluates ToolCalls and returns GatewayResult
    MockAgent.swift              # Simulated LLM agent that proposes ToolCalls from raw text
    EvidenceStore.swift          # ObservableObject persisting Evidence records to UserDefaults
    Scenarios.swift              # 12 built-in test scenarios (benign / malicious / ambiguous)
    Benchmark.swift              # Accuracy scoring across all scenarios
    UI/
      RootView.swift             # Tab container (Simulator, Evidence Log, Benchmark, About)
      SimulatorView.swift        # Main interactive input + gateway decision UI
      BenchmarkView.swift        # Batch-run all scenarios and display accuracy
      ReplayView.swift           # Detail view for a past Evidence record
      WelcomeView.swift          # First-launch onboarding sheet
      AboutView.swift            # AI tool usage disclosure + personalisation checklist
      Components.swift           # Reusable SwiftUI components (badges, cards, labels)
```

## How to Build and Run

1. Open `PocketDeputy.swiftpm` in **Xcode 15+** (drag the folder or double-click it).
2. Select an **iOS 16+ simulator** (e.g., iPhone 15).
3. Press **▶** to build and run — no additional setup, dependencies, or API keys are required.
4. Alternatively, open the `.swiftpm` bundle in **Swift Playgrounds 4** on iPad or Mac.

There is no separate test target. All logic validation is done via the in-app **Benchmark** tab, which runs all 12 built-in scenarios and reports gateway accuracy.

## Key Concepts

- **Channel** (`Models.swift`): The provenance of agent input (`notification`, `deepLink`, `qrText`, `clipboard`). Each channel has a `TrustLevel` (low / medium).
- **ToolCall** (`Models.swift`): A proposed action the agent wants to take (e.g., `openURL`, `composeMessage`, `copyToClipboard`, `saveLocalNote`, `createCalendarReminder`).
- **ActionGateway** (`ActionGateway.swift`): The policy engine. Given a `Channel`, raw input text, and a `ToolCall`, it returns a `GatewayResult` with a `GatewayDecision` (`allow` / `confirm` / `block`) and a human-readable `reason`. All logic is **local** — no network calls.
- **Evidence** (`Models.swift`): A complete record of one agent run (channel, input, proposal, gateway result, final outcome).
- **Scenario** (`Models.swift`, `Scenarios.swift`): A pre-built test case with a known `expectedDecision` used to benchmark gateway accuracy.

## Coding Conventions

- **Language**: Swift 5.9+, SwiftUI, Combine / `@Observable` patterns.
- **Formatting**: 4-space indentation, no tabs. Follow the style already present in each file.
- **Naming**: Use Swift API Design Guidelines. Types are `UpperCamelCase`; properties and functions are `lowerCamelCase`.
- **Comments**: Every file starts with a `// FileName.swift` header comment. Use `// MARK: -` sections to organise large files (see `ActionGateway.swift` as the reference).
- **No external dependencies**: The project intentionally has zero third-party packages. Do not add any.
- **No network calls**: All logic must remain purely local.
- **Privacy**: Do not log or transmit any user input or evidence data outside the device.

## Extending the Gateway

When adding new injection heuristics or per-tool rules to `ActionGateway.swift`:
1. Add new keyword arrays in the `// MARK: - Injection heuristics` section.
2. Increment scores in `evaluate(channel:rawInput:proposal:)` following the existing pattern (high-signal: +3, override: +2, urgency: +1).
3. Add or update the corresponding `case` in the `switch proposal.tool` block.
4. Add matching scenarios in `Scenarios.swift` covering benign, malicious, and ambiguous cases.
5. Run the in-app **Benchmark** tab to verify accuracy stays at or above the previous level.

## Adding Scenarios

All scenarios live in `Scenarios.swift` as elements of `Scenarios.all`. Each `Scenario` requires:
- `name`: Short descriptive string (format: `"Benign|Malicious|Ambiguous: <description>"`).
- `channel`: One of `.notification`, `.deepLink`, `.qrText`, `.clipboard`.
- `inputText`: The raw text the agent would receive.
- `expectedDecision`: `.allow`, `.confirm`, or `.block` — must match what `ActionGateway` actually returns.
- `notes`: One-sentence explanation of why this scenario is interesting.

## Personalisation Checklist (before Swift Student Challenge submission)

- [ ] Rewrite `inputText` and `notes` in `Scenarios.swift` with realistic, personal examples.
- [ ] Update the AI tool usage disclosure paragraph in `AboutView.swift`.
- [ ] Optionally adjust allowlists or keyword lists in `ActionGateway.swift` and explain your tradeoffs in the written submission.
