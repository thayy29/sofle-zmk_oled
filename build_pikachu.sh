#!/bin/bash
# Build script para compilar o firmware Sofle com Pikachu animado

set -e

echo "🐤 Building Sofle Pikachu firmware..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$REPO_ROOT/build"
FIRMWARE_DIR="$BUILD_DIR/zephyr"

# Clean previous build
if [ "$1" == "--clean" ]; then
    echo -e "${YELLOW}Cleaning previous build...${NC}"
    rm -rf "$BUILD_DIR"
    echo -e "${GREEN}✓ Build cleaned${NC}"
    echo ""
fi

# Build left side
echo -e "${BLUE}Building LEFT side...${NC}"
west build -d "$BUILD_DIR/left" \
    -b nice_nano//zmk \
    -s zmk/app \
    -- -DSHIELD=sofle_left \
    -DCONFIG_ZMK_DISPLAY=y \
    -DCONFIG_CFB=y

echo -e "${GREEN}✓ Left firmware built${NC}"
echo ""

# Build right side
echo -e "${BLUE}Building RIGHT side...${NC}"
west build -d "$BUILD_DIR/right" \
    -b nice_nano//zmk \
    -s zmk/app \
    -- -DSHIELD=sofle_right \
    -DCONFIG_ZMK_DISPLAY=y \
    -DCONFIG_CFB=y

echo -e "${GREEN}✓ Right firmware built${NC}"
echo ""

# Find and copy UF2 files
echo -e "${BLUE}Organizing firmware files...${NC}"

# Sofle firmware files
LEFT_UF2=$(find "$BUILD_DIR/left" -name "*.uf2" -type f | head -1)
RIGHT_UF2=$(find "$BUILD_DIR/right" -name "*.uf2" -type f | head -1)

if [ -n "$LEFT_UF2" ] && [ -n "$RIGHT_UF2" ]; then
    cp "$LEFT_UF2" "$BUILD_DIR/sofle_left.uf2"
    cp "$RIGHT_UF2" "$BUILD_DIR/sofle_right.uf2"

    echo -e "${GREEN}✓ Firmware files ready:${NC}"
    echo "  Left:  $BUILD_DIR/sofle_left.uf2  ($(du -h "$BUILD_DIR/sofle_left.uf2" | cut -f1))"
    echo "  Right: $BUILD_DIR/sofle_right.uf2 ($(du -h "$BUILD_DIR/sofle_right.uf2" | cut -f1))"
else
    echo -e "${YELLOW}Warning: Could not find UF2 files${NC}"
fi

echo ""
echo -e "${GREEN}✅ Build complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Connect your Sofle LEFT side via USB"
echo "2. Copy sofle_left.uf2 to the USB drive that appears"
echo "3. Repeat with sofle_right.uf2 for the RIGHT side"
echo ""
echo "Files are in: $BUILD_DIR"
echo ""
