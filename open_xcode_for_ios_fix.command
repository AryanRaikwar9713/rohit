#!/bin/bash
# Double-click this file to open Xcode so you can fix iOS signing (Steps in docs/IOS_RUN_FIX.md)
cd "$(dirname "$0")"
open ios/Runner.xcworkspace
echo "Xcode opened. Now follow the steps in docs/IOS_RUN_FIX.md"
