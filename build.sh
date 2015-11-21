#!/bin/sh
xcodebuild -project XcodeEditor.xcodeproj -scheme XcodeEditor clean test | xcpretty -c --report junit
groovy http://frankencover.it/with --source-dir Source
