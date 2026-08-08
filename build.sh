#!/bin/bash
set -e
cd "$(dirname "$0")"

DEST="simulator"

while [[ $# -gt 0 ]]; do
    case "$1" in
        device)    DEST="device"; shift ;;
        simulator) DEST="simulator"; shift ;;
        *)         shift ;;
    esac
done

VERSION="1.0.0"
BUILD="$(git rev-parse --short=8 HEAD 2>/dev/null || echo deadbeef)"
DATE="$(date '+%b %-d, %Y')"

cat > Sources/Firehose/Version.swift <<EOF
// Overwritten by build.sh with the real git hash and build date.
enum Version {
    static let version = "${VERSION}"
    static let build = "${BUILD}"
    static let date = "${DATE}"
}
EOF

echo "firehose-ios ${VERSION}/${BUILD}"

# Device signing needs an Apple Developer team. The team ID is not checked in;
# export DEVELOPMENT_TEAM (see harrison.sh in the private repo) or set your own.
TEAM_ARGS=()
if [ -n "$DEVELOPMENT_TEAM" ]; then
    TEAM_ARGS+=("DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM")
fi

if [ "$DEST" = "device" ]; then
    BUILD_LOG=$(mktemp)
    trap 'rm -f "$BUILD_LOG"' EXIT
    set +e
    xcodebuild -project Firehose.xcodeproj -scheme Firehose \
        -destination 'generic/platform=iOS' \
        -allowProvisioningUpdates "${TEAM_ARGS[@]}" build 2>&1 | tee "$BUILD_LOG"
    BUILD_STATUS=${PIPESTATUS[0]}
    set -e
    if [ "$BUILD_STATUS" -ne 0 ] && grep -q 'is not installed. Please download and install the platform' "$BUILD_LOG"; then
        echo
        echo "hint: your device is running a newer iOS than Xcode has platform support for."
        echo "fix:  xcodebuild -downloadPlatform iOS"
    fi
    exit $BUILD_STATUS
else
    xcodebuild -project Firehose.xcodeproj -scheme Firehose \
        -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
fi
