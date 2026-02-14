# QuickNFO

macOS QuickLook extension for previewing `.nfo` files. Select any `.nfo` file
in Finder and press **Space** to see a rendered preview with classic CP437
block characters.

Supports both **preview** (full content) and **thumbnail** generation.

## Screenshots

### Preview

<img src="examples/preview.png" alt="QuickLook Preview" width="606" height="817"/>

### Thumbnails

<img src="examples/thumbnails.png" alt="QuickLook Thumbnails" width="722" height="171"/>

## Requirements

- **macOS 15.0** (Sequoia) or later
- **Xcode 16+** and **XcodeGen** (only for building from source)

## Installation

### Homebrew (Recommended)

```bash
brew tap vigo/quicknfo
brew install --cask quicknfo --no-quarantine
```

### Manual Download

1. Download `QuickNFO-v{version}.zip` from
   [GitHub Releases](https://github.com/vigo/QuickNFO/releases/latest)
2. Extract and move `QuickNFO.app` to `/Applications`
3. Remove the quarantine attribute:
   ```bash
   xattr -cr /Applications/QuickNFO.app
   ```
4. Launch `QuickNFO.app` once to register the QuickLook extensions

### Build from Source

```bash
brew install xcodegen  # if not already installed
make build
make install
```

## Usage

1. Open Finder and navigate to a folder with `.nfo` files
2. Select a `.nfo` file
3. Press **Space** to see the QuickLook preview

## Unsigned App Notice

QuickNFO is **not signed** with an Apple Developer ID. macOS Gatekeeper will
block the app on first launch. To resolve this:

```bash
xattr -cr /Applications/QuickNFO.app
```

If you install via Homebrew with `--no-quarantine`, this step is handled
automatically.

## Upgrading from Previous Versions

The old `.qlgenerator` plugin (v1.x) is no longer supported on modern macOS.
QuickNFO v2.0 uses the App Extension architecture introduced in macOS 15.

If you have the old plugin installed, remove it:

```bash
rm -rf ~/Library/QuickLook/QuickNFO.qlgenerator
```

Then install the new version using one of the methods above.

## Contributing

```bash
# Clone and build
git clone https://github.com/vigo/QuickNFO.git
cd QuickNFO
brew install xcodegen
make build

# Run the app locally
open build/QuickNFO.xcarchive/Products/Applications/QuickNFO.app
```

## License

This project is available under the MIT License. See the original repository
for details.
