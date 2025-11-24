# Repository Guidelines

## Project Structure & Module Organization
- `SwiftSDUI/`: App target (entry `SwiftSDUIApp.swift`, root `ContentView.swift`, `Assets.xcassets`).
- `Source/`: Library-style source for Server‑Driven UI (`SDUIView.swift`, enums, parsing/types).
- `SwiftSDUI.xcodeproj/`: Xcode project and schemes. Do not edit plist files by hand unless necessary.

## Build, Test, and Development Commands
- Build (Xcode): Open with `open SwiftSDUI.xcodeproj` and build the `SwiftSDUI` scheme.
- Build (CLI): `xcodebuild -scheme SwiftSDUI -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build`
- Run tests (if tests target exists): `xcodebuild test -scheme SwiftSDUI -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'`
- SwiftUI Previews: Use Xcode canvas; keep previews lightweight and deterministic.

## Coding Style & Naming Conventions
- Indentation: 4 spaces; one type per file; keep files focused.
- Naming: Types `UpperCamelCase` (e.g., `SDUIViewType`), methods/properties `lowerCamelCase`.
- SwiftUI Views: Use value types (`struct`), minimal state, and clear modifiers ordering (layout → style → effects → accessibility).
- Access control: Default to `internal`; use `public` only for API surface in `Source/`.

## Testing Guidelines
- Framework: XCTest. Add a `SwiftSDUITests/` target for unit tests (parsing, rendering decisions).
- Naming: `test<Subject>_<Condition>_<Expectation>()`.
- Coverage: Prioritize JSON parsing and view mapping. Add snapshot tests if UI regressions become common.
- Run: see “Run tests” command above.

## Commit & Pull Request Guidelines
- Commits: Imperative, concise messages (e.g., `Add SDUIView`, `Fix HStack spacing`). Group related changes.
- Branches: `feature/<short-name>` or `fix/<short-name>`.
- PRs: Include summary, motivation, before/after screenshots for UI, and steps to validate. Link issues when applicable.

## SDUI Notes & Examples
- JSON schema maps to enums in `Source/SDUIView.swift` (`SDUIViewType`, `SDUIProperty`). Keep keys stable and documented.
- Example snippet:
  ```json
  { "type": "text", "text": "Hello, world!", "fontSize": 16, "fontWeight": "regular" }
  ```
- Prefer additive changes; avoid breaking existing keys. Validate inputs and provide sensible defaults.

## Security & Configuration
- Do not commit secrets or signing files. Use your local iOS signing identities.
- Schemes: Use the shared `SwiftSDUI` scheme; avoid creating per‑dev schemes in VCS.
