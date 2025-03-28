# BikedMiles Development Guide

## Build & Test Commands
- Build app: `xcodebuild build -scheme BikedMiles`
- Run all tests: `xcodebuild test -scheme BikedMiles -destination 'platform=iOS Simulator,name=iPhone 15'`
- Run single test: `xcodebuild test -scheme BikedMiles -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BikedMilesTests/DateHelpersTests/test_specificMethodName`

## Code Style Guidelines
- **Imports**: Group Swift/Foundation imports separately from third-party frameworks
- **Formatting**: Use 4-space indentation, add space after colons
- **Types**: Use strong typing, custom error enums, and extensions for functionality
- **Naming**:
  - Functions/variables: camelCase with descriptive names
  - Types/classes: PascalCase
  - Methods: start with verb (fetch, get, compute)
- **Error Handling**: Use try/catch blocks with explicit error types, propagate with throws

## Project Structure
- Core business logic in separate managers (HealthKitManager)
- Helper extensions in dedicated files (DateHelpers)
- Tests should mirror main code structure

Follow Swift best practices for API design and documentation.