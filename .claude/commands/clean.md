Clean build folder, then build and launch the Xcode project in the iPhone 16 simulator (equivalent to Cmd-K + Run in Xcode).

Steps:
1. Auto-detect the .xcworkspace or .xcodeproj file in the current directory
2. Use the first available scheme if multiple exist
3. Clean the build folder (xcodebuild clean)
4. Build for Debug configuration
5. Launch in iPhone 16 simulator with latest iOS version
6. Use xcodebuild with --quiet flag to minimize output
7. Report clean/build status and any errors
