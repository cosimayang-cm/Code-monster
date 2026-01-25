#!/bin/bash

# Kill Xcode first
killall Xcode 2>/dev/null
sleep 2

# Use XcodeGen to recreate project with all files
cd /Users/yutasm4macmini/Desktop/CMoney/CodeMonster/yuta/monster3/004-undo-redo-system/UndoRedoDemoApp/UndoDemoApp

cat > project.yml << 'EOF'
name: UndoDemoApp
options:
  bundleIdPrefix: com.codemonster
  deploymentTarget:
    iOS: "15.0"

targets:
  UndoDemoApp:
    type: application
    platform: iOS
    deploymentTarget: "15.0"
    sources:
      - UndoDemoApp
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.codemonster.UndoDemoApp
        SWIFT_VERSION: "5.9"
        TARGETED_DEVICE_FAMILY: "1,2"
        DEVELOPMENT_TEAM: ""
    info:
      path: UndoDemoApp/Info.plist
      properties:
        CFBundleDevelopmentRegion: en
        CFBundleExecutable: $(EXECUTABLE_NAME)
        CFBundleIdentifier: $(PRODUCT_BUNDLE_IDENTIFIER)
        CFBundleInfoDictionaryVersion: "6.0"
        CFBundleName: $(PRODUCT_NAME)
        CFBundlePackageType: APPL
        CFBundleShortVersionString: "1.0"
        CFBundleVersion: "1"
        LSRequiresIPhoneOS: true
        UIApplicationSceneManifest:
          UIApplicationSupportsMultipleScenes: false
        UIApplicationSupportsIndirectInputEvents: true
        UILaunchScreen: {}
        UISupportedInterfaceOrientations:
          - UIInterfaceOrientationPortrait
          - UIInterfaceOrientationLandscapeLeft
          - UIInterfaceOrientationLandscapeRight
EOF

# Generate project
xcodegen generate

# Open Xcode
open UndoDemoApp.xcodeproj

echo "✅ Project regenerated with all files!"
