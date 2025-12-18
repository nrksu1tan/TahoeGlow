import SwiftUI
import AppKit
import Combine

@main
struct EdgeLightApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class WindowManager: ObservableObject {
    var overlayWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                self?.setupWindow()
            }
            .store(in: &cancellables)
            
        setupWindow()
    }
    
    func setupWindow() {
        overlayWindow?.close()
        overlayWindow = nil
        
        guard let mainScreen = NSScreen.main else { return }
        let frame = mainScreen.visibleFrame
        
        let window = NSWindow(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.ignoresMouseEvents = true
        
        window.contentView = NSHostingView(rootView: OverlayView(windowFrame: frame))
        
        window.setFrame(frame, display: true)
        window.orderFront(nil)
        
        self.overlayWindow = window
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowManager: WindowManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        windowManager = WindowManager()
    }
}