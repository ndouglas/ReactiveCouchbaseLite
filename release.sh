#!/bin/bash
export GIT_MERGE_AUTOEDIT=no
NEW_VERSION="$1"
rm Podfile.lock && pod install
git add .
git commit -am "Updates pods for $1"
git flow release start "$1"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_VERSION" "./Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW_VERSION" "./Info.plist"
sed -i "" "1s/.*/MY_RCL_VERSION\=\"$NEW_VERSION\"/" ./ReactiveCouchbaseLite.podspec
git add .
git commit -am "$1"
git flow release finish -p -m "$1" "$1"
git merge master
git push --all
git checkout master
git merge develop
git checkout develop
git merge master
git push --all

