# Monster 5: TCA + UIKit Login & Posts App - Setup Instructions

## TCA Dependency Installation

**MANUAL STEP REQUIRED**: Add TCA Swift Package to Xcode project.

### Steps:
1. Open `CodeMonster.xcodeproj` in Xcode
2. Go to **File > Add Package Dependencies...**
3. Enter package URL: `https://github.com/pointfreeco/swift-composable-architecture`
4. Set version: **From 1.7.0, Up to Next Major**
5. Click **Add Package**
6. When prompted, add `ComposableArchitecture` to the **CodeMonster** target
7. Ensure iOS Deployment Target is set to **iOS 16.0** or higher

### Verification:
- Check that `import ComposableArchitecture` compiles without errors
- Verify that `@Reducer`, `@ObservableState`, `Store`, `Effect`, `@Dependency` are all recognized

### Common Issues:
- If package resolution fails, check network connection
- If "No exact matches" error appears, verify the URL is correct
- If minimum deployment target error appears, set target to iOS 16.0+

---

**Status**: Awaiting manual Xcode configuration (T003)
