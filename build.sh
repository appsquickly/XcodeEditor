#!/bin/sh

#Fail immediately if a task fails
set -e
set -o pipefail

xcodebuild -project XcodeEditor.xcodeproj -scheme XcodeEditor clean test | ruby -e 'STDIN.each_line {|line| STDOUT.write line.scrub;STDOUT.flush}' | xcpretty -c --report junit
#groovy http://frankencover.it/with --source-dir Source
