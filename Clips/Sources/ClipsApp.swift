import SwiftUI
import AppKit
import Carbon

@main
enum ClipsAppMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}

// MARK: - Global Hotkey Manager
class HotkeyManager {
    static let shared = HotkeyManager()
    
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private var callback: (() -> Void)?
    
    // 默认快捷键: Command + Shift + V
    private let defaultKeyCode: UInt32 = 9  // V 键
    private let defaultModifiers: UInt32 = UInt32(cmdKey | shiftKey)
    
    private init() {}
    
    func register(callback: @escaping () -> Void) {
        self.callback = callback
        
        // 注册事件处理器
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, userData) -> OSStatus in
                guard let userData = userData else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.callback?()
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
        
        if status != noErr {
            print("❌ 无法安装事件处理器: \(status)")
            return
        }
        
        // 注册热键 (Command + Shift + V)
        let hotKeyID = EventHotKeyID(signature: OSType(0x434C4950), id: 1)  // "CLIP"
        
        let registerStatus = RegisterEventHotKey(
            defaultKeyCode,
            defaultModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if registerStatus != noErr {
            print("❌ 无法注册热键: \(registerStatus)")
        } else {
            print("✅ 全局快捷键已注册: ⌘⇧V")
        }
    }
    
    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }
    
    deinit {
        unregister()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover!
    var floatingWindow: NSWindow?
    var mainWindow: NSWindow?
    
    let clipboardService = ClipboardService()
    var historyStore: HistoryStore!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize Core Services
        historyStore = HistoryStore(clipboardService: clipboardService)
        
        // 先启动监控，确保能捕获剪贴板变化
        clipboardService.startMonitoring()
        
        // 创建主窗口
        createMainWindow()
        
        // 尝试创建状态栏图标
        setupStatusItem()
        
        // 注册全局快捷键 (Command + Shift + V)
        HotkeyManager.shared.register { [weak self] in
            DispatchQueue.main.async {
                self?.showFloatingWindow()
            }
        }
        
        // 请求辅助功能权限（用于全局快捷键）
        requestAccessibilityPermission()
        
        // 激活应用
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func createMainWindow() {
        let menuView = MenuBarView(
            historyStore: historyStore,
            onCopy: { [weak self] content in
                self?.clipboardService.copyToClipboard(content)
            },
            onQuit: {
                NSApplication.shared.terminate(nil)
            }
        )
        
        let hostingController = NSHostingController(rootView: menuView)
        
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 450),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        mainWindow?.contentViewController = hostingController
        mainWindow?.title = "Clips"
        mainWindow?.center()
        mainWindow?.makeKeyAndOrderFront(nil)
    }
    
    private func setupStatusItem() {
        // 创建状态栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let statusItem = statusItem, let button = statusItem.button else {
            print("❌ 无法创建菜单栏按钮")
            return
        }
        
        // 使用系统图标
        if let image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clips") {
            image.isTemplate = true
            button.image = image
        } else {
            button.title = "C"
        }
        
        button.action = #selector(statusItemClicked(_:))
        button.target = self
        
        // 创建 Popover
        let menuView = MenuBarView(
            historyStore: historyStore,
            onCopy: { [weak self] content in
                self?.clipboardService.copyToClipboard(content)
                self?.closePopover(sender: nil)
            },
            onQuit: {
                NSApplication.shared.terminate(nil)
            }
        )
        
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: menuView)
        
        print("✅ 菜单栏图标已设置")
    }
    
    @objc func statusItemClicked(_ sender: AnyObject?) {
        togglePopover(sender)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        HotkeyManager.shared.unregister()
    }
    
    private func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        if !trusted {
            print("⚠️ 需要辅助功能权限才能使用全局快捷键")
        }
    }
    
    // MARK: - Floating Window (用于快捷键唤出)
    func showFloatingWindow() {
        if let window = floatingWindow, window.isVisible {
            closeFloatingWindow()
            return
        }
        
        let menuView = MenuBarView(
            historyStore: historyStore,
            onCopy: { [weak self] content in
                self?.clipboardService.copyToClipboard(content)
                self?.closeFloatingWindow()
            },
            onQuit: {
                NSApplication.shared.terminate(nil)
            }
        )
        
        let hostingController = NSHostingController(rootView: menuView)
        
        // 获取鼠标位置或屏幕中心
        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        
        let windowWidth: CGFloat = 320
        let windowHeight: CGFloat = 420
        
        // 计算窗口位置（在鼠标附近或屏幕中心）
        var windowX = mouseLocation.x - windowWidth / 2
        var windowY = mouseLocation.y - windowHeight / 2
        
        // 确保窗口在屏幕内
        windowX = max(screenFrame.minX + 10, min(windowX, screenFrame.maxX - windowWidth - 10))
        windowY = max(screenFrame.minY + 10, min(windowY, screenFrame.maxY - windowHeight - 10))
        
        let window = NSWindow(
            contentRect: NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.contentViewController = hostingController
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.backgroundColor = NSColor.windowBackgroundColor
        window.isReleasedWhenClosed = false
        
        // 添加圆角
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 12
        window.contentView?.layer?.masksToBounds = true
        
        floatingWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        // 监听窗口失去焦点时关闭
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResignKey(_:)),
            name: NSWindow.didResignKeyNotification,
            object: window
        )
    }
    
    @objc func windowDidResignKey(_ notification: Notification) {
        closeFloatingWindow()
    }
    
    func closeFloatingWindow() {
        if let window = floatingWindow {
            NotificationCenter.default.removeObserver(self, name: NSWindow.didResignKeyNotification, object: window)
            window.close()
            floatingWindow = nil
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let statusItem = statusItem, let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
}
