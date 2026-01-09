# Proposal: Init macOS Clipboard Manager (Clips)

## Summary
Initialize a new macOS Menu Bar application named "Clips" built with Swift. This tool will monitor the system clipboard, maintain a history of copied text, and allow users to access previous clippings via a status bar menu.

## Problem Statement
Users frequently need to access previously copied text. macOS does not provide a native, persistent clipboard history accessible via the menu bar.

## Goals
- Create a lightweight, native macOS application using Swift and SwiftUI.
- Monitor the system clipboard (`NSPasteboard`) for text changes.
- Store a limited history of copied items (e.g., last 50 items).
- Provide a Menu Bar interface to view and select history items to copy them back to the clipboard.

## Non-Goals
- Image or file clipboard history (v1 is text-only).
- iCloud sync.
- Complex search or categorization features.
