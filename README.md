# MDPreviewer

A high-performance, modern Markdown Quick Look extension for macOS 14+.

## Features

- **Modern Architecture**: Built using a Rust-based rendering engine and an Objective-C `QLPreviewProvider` bridge.
- **GFM Support**: Full support for GitHub Flavored Markdown (Tables, Task lists, Strikethrough, Footnotes, etc.).
- **Syntax Highlighting**: Premium code block highlighting using `syntect` with a modern theme.
- **Responsive Dark Mode**: Clean, minimal aesthetics with automatic light and dark mode switching.
- **Native Performance**: Compiled to native hardware code (arm64), ensuring fast spacebar previews.

## Requirements

- **macOS**: 14.0 Sonoma or later.
- **Build Tools**: Xcode 15+ and Rust 1.75+.

## Getting Started

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/DoctorC0de/MDPreviewer.git
   cd MDPreviewer
   ```

2. **Build and Install**:
   ```bash
   make build
   make install
   ```
   The `make install` command builds the Rust rendering core, compiles the Objective-C bridge, and registers the app extension to `/Applications/MDPreviewer.app`.

### Usage

Once installed, simply find any `.md` file in Finder and press the **Spacebar**. The preview should appear instantly with full formatting and syntax highlighting.

## Project Architecture

- **`crates/mdpreviewer-core`**: Core rendering library written in Rust using `pulldown-cmark`.
- **`objc-bridge`**: Objective-C implementation of the `QLPreviewProvider` protocol.
- **`scripts/bundle.sh`**: Codesigning and bundling script for macOS App Extensions.
- **`Makefile`**: Automated build and deployment orchestration.

## Troubleshooting

If the preview does not appear after installation:
- Ensure you are on macOS 14+.
- Try running `qlmanage -r` in the terminal to reset the Quick Look cache.
- Restart Finder with `killall Finder`.

## License

MIT
