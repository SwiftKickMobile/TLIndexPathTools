#!/bin/bash

xcodebuild -showsdks | xcpretty

#Step 1
xcodebuild -project "TLIndexPathTools.xcodeproj" -scheme "TLIndexPathTools" -sdk "iphonesimulator11.0" -configuration "Release" | xcpretty

# if [ $? != 0 ]; then
# echo "xcodebuild job failed. Please check your build configuration (-sdk arg. ) and make sure tests passed locally."
# exit 1
# fi

#Step 2
echo "Verifying that TLIndexPathTools functions as a dynamic framework (for Carthage users)."
carthage build --no-skip-current

# Check for error
if [ $? != 0 ]; then
echo "Can't build with Carthage..."
exit 1
fi

echo "Good job."
