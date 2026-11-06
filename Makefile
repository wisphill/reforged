APP_NAME    := Reforged
BUNDLE_ID   := com.yuu.reforged
MIN_MACOS   := 13.0
ARCH        := $(shell uname -m)

BUILD_DIR   := build
XCODE_APP   := $(BUILD_DIR)/Build/Products/Debug/$(APP_NAME).app
SWIFTC_APP  := $(BUILD_DIR)/swiftc/$(APP_NAME).app
SOURCES     := $(shell find Sources -name '*.swift')

# Full Xcode available? (Command Line Tools alone cannot run xcodebuild.)
HAS_XCODE   := $(shell xcodebuild -version >/dev/null 2>&1 && echo yes)

ifeq ($(HAS_XCODE),yes)
APP_PATH := $(XCODE_APP)
BUILD_TARGET := xcode-build
else
APP_PATH := $(SWIFTC_APP)
BUILD_TARGET := swiftc-build
endif

.DEFAULT_GOAL := help
.PHONY: help run build project xcode xcode-build swiftc-build stop clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-8s %s\n", $$1, $$2}'

run: build stop ## Build and launch the app (uses Xcode if installed, else swiftc)
	open "$(APP_PATH)"

build: $(BUILD_TARGET) ## Build the .app without launching

project: ## Generate Reforged.xcodeproj from project.yml (needs xcodegen)
	@command -v xcodegen >/dev/null || { echo "xcodegen not found: brew install xcodegen"; exit 1; }
	xcodegen generate

xcode: project ## Generate and open the project in Xcode
	open $(APP_NAME).xcodeproj

xcode-build: project
	xcodebuild -project $(APP_NAME).xcodeproj -scheme $(APP_NAME) \
		-configuration Debug -derivedDataPath $(BUILD_DIR) build

# Fallback that only needs the Command Line Tools: compile with swiftc and
# wrap the binary in a minimal .app bundle (Dock click behavior still works).
define INFO_PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>$(APP_NAME)</string>
<key>CFBundleIdentifier</key><string>$(BUNDLE_ID)</string>
<key>CFBundleName</key><string>$(APP_NAME)</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>$(MIN_MACOS)</string>
<key>NSPrincipalClass</key><string>NSApplication</string>
</dict></plist>
endef
export INFO_PLIST

swiftc-build: $(SOURCES)
	mkdir -p "$(SWIFTC_APP)/Contents/MacOS"
	swiftc -swift-version 5 -target $(ARCH)-apple-macosx$(MIN_MACOS) \
		$(SOURCES) -o "$(SWIFTC_APP)/Contents/MacOS/$(APP_NAME)"
	printf '%s\n' "$$INFO_PLIST" > "$(SWIFTC_APP)/Contents/Info.plist"
	codesign --force --sign - "$(SWIFTC_APP)"

stop: ## Quit a running instance
	-@pkill -x $(APP_NAME) 2>/dev/null || true

clean: stop ## Remove build output
	rm -rf $(BUILD_DIR)
