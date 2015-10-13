#!/bin/bash
LONG_BUILD_VERSION=$(git describe --long --tags --dirty --always)
SHORT_BUILD_VERSION=$(git describe --tags --abbrev=0 2>/dev/null)
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${LONG_BUILD_VERSION}" "./Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${SHORT_BUILD_VERSION}" "./Info.plist"

