.PHONY: all build clean install test

all: build

build:
	cargo build --release
	mkdir -p build
	# Build Modern App Extension executable
	clang -fobjc-arc -arch arm64 -isysroot $$(xcrun --show-sdk-path) \
		-mmacosx-version-min=14.0 \
		objc-bridge/main.m objc-bridge/QLBridge.m \
		-o build/MDPreviewerQL \
		-Ltarget/release -lmdpreviewer_core \
		-framework Foundation -framework QuickLookUI -framework UniformTypeIdentifiers -framework CoreGraphics
	./scripts/bundle.sh

clean:
	cargo clean
	rm -rf build

install: build
	# 1. Purge ghosts
	rm -rf /Applications/MDPreviewer.app
	cp -R build/MDPreviewer.app /Applications/
	# 2. Clear quarantine
	xattr -rc /Applications/MDPreviewer.app
	# 3. Register Extension (Modern)
	pluginkit -a /Applications/MDPreviewer.app/Contents/PlugIns/MDPreviewerQL.appex
	# 4. Final System Reset
	qlmanage -r
	qlmanage -r cache
	killall quicklookd || true
	@echo "MDPreviewer (Modern App Extension) installed and registered."

test:
	cargo test --workspace
