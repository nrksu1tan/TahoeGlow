import SwiftUI
import AppKit

@main
struct EdgeLightApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Стандартная сцена настроек macOS.
        // Она автоматически привязывается к меню "Settings..." и Cmd+,
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupOverlayWindow()
    }
    
    func setupOverlayWindow() {
        guard let screen = NSScreen.main else { return }
        
        let contentRect = screen.visibleFrame
        
        overlayWindow = NSWindow(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        overlayWindow.isOpaque = false
        overlayWindow.backgroundColor = .clear
        overlayWindow.level = .floating
        overlayWindow.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        overlayWindow.ignoresMouseEvents = true
        
        overlayWindow.contentView = NSHostingView(rootView: OverlayView())
        
        overlayWindow.orderFront(nil)
    }
}
