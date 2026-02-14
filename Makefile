# QuickNFO Build & Package Automation
# ------------------------------------
# Usage:
#   make build      - Generate Xcode project and build Release
#   make package    - Create distributable .zip from built app
#   make install    - Install to /Applications
#   make uninstall  - Remove from /Applications
#   make clean      - Remove build artifacts

APP_NAME     := QuickNFO
BUILD_DIR    := build
ARCHIVE_PATH := $(BUILD_DIR)/$(APP_NAME).xcarchive
APP_PATH     := $(ARCHIVE_PATH)/Products/Applications/$(APP_NAME).app
VERSION      := $(shell /usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" QuickNFOApp/Info.plist)
ZIP_NAME     := $(APP_NAME)-v$(VERSION).zip
ZIP_PATH     := $(BUILD_DIR)/$(ZIP_NAME)
SCHEME       := $(APP_NAME)

.PHONY: build package install uninstall clean help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Generate Xcode project and build Release configuration
	@echo "==> Generating Xcode project..."
	xcodegen generate
	@echo "==> Building $(APP_NAME) (Release)..."
	xcodebuild archive \
		-project $(APP_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration Release \
		-archivePath $(ARCHIVE_PATH) \
		CODE_SIGN_IDENTITY="-" \
		CODE_SIGN_STYLE=Manual \
		SKIP_INSTALL=NO \
		| xcpretty || xcodebuild archive \
		-project $(APP_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration Release \
		-archivePath $(ARCHIVE_PATH) \
		CODE_SIGN_IDENTITY="-" \
		CODE_SIGN_STYLE=Manual \
		SKIP_INSTALL=NO
	@echo "==> Build complete: $(APP_PATH)"

package: ## Create distributable .zip (requires build first)
	@test -d "$(APP_PATH)" || (echo "Error: Run 'make build' first" && exit 1)
	@echo "==> Creating $(ZIP_NAME)..."
	@mkdir -p $(BUILD_DIR)
	cd "$(ARCHIVE_PATH)/Products/Applications" && ditto -c -k --keepParent "$(APP_NAME).app" "$(CURDIR)/$(ZIP_PATH)"
	@echo "==> Package created: $(ZIP_PATH)"
	@echo ""
	@echo "SHA256:"
	@shasum -a 256 "$(ZIP_PATH)"

install: ## Install QuickNFO.app to /Applications
	@test -d "$(APP_PATH)" || (echo "Error: Run 'make build' first" && exit 1)
	@echo "==> Installing $(APP_NAME).app to /Applications..."
	cp -R "$(APP_PATH)" /Applications/
	xattr -cr /Applications/$(APP_NAME).app
	@echo "==> Installed. Launch $(APP_NAME).app once to register the QuickLook extensions."

uninstall: ## Remove QuickNFO.app from /Applications
	@echo "==> Removing $(APP_NAME).app from /Applications..."
	rm -rf /Applications/$(APP_NAME).app
	@echo "==> Uninstalled."

clean: ## Remove build artifacts
	@echo "==> Cleaning..."
	rm -rf $(BUILD_DIR)
	rm -rf $(APP_NAME).xcodeproj
	@echo "==> Clean complete."
