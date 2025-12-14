import SwiftUI
import Combine

struct OverlayView: View {
    @ObservedObject var appState = AppState.shared
    

    let holeRadius: CGFloat = 180.0
    let coreRadius: CGFloat = 40.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if appState.isLightOn {
                    LightBodyView(borderColor: appState.borderColor, borderWidth: appState.borderWidth)
                        .mask(
                            MouseMaskView(
                                mousePos: appState.mousePosition,
                                screenSize: geometry.size,
                                holeRadius: holeRadius,
                                coreRadius: coreRadius
                            )
                        )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.isLightOn)
        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            updateMouseLocation()
        }
    }
    
    private func updateMouseLocation() {
        let globalMouse = NSEvent.mouseLocation
        guard let window = NSApp.windows.first(where: { $0.level == .floating }) else { return }
        let windowFrame = window.frame
        
        let localX = globalMouse.x - windowFrame.minX
        let localY = windowFrame.height - (globalMouse.y - windowFrame.minY)
        
        appState.mousePosition = CGPoint(x: localX, y: localY)
    }
}

struct LightBodyView: View {
    var borderColor: Color
    var borderWidth: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .stroke(borderColor.opacity(0.25), lineWidth: borderWidth + 60)
                .blur(radius: 50)
            
            RoundedRectangle(cornerRadius: 32)
                .stroke(borderColor.opacity(0.7), lineWidth: borderWidth + 10)
                .blur(radius: 20)
            
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.white.opacity(0.95), lineWidth: borderWidth * 0.3)
                .blur(radius: 6)
                .shadow(color: borderColor, radius: 10)
        }
        .padding(25)
    }
}


struct MouseMaskView: View {
    var mousePos: CGPoint
    var screenSize: CGSize
    var holeRadius: CGFloat
    var coreRadius: CGFloat
    
    var body: some View {
        Canvas { context, size in

            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))
            

            context.blendMode = .destinationOut
            
            let rect = CGRect(
                x: mousePos.x - holeRadius,
                y: mousePos.y - holeRadius,
                width: holeRadius * 2,
                height: holeRadius * 2
            )
            
            context.fill(
                Path(ellipseIn: rect),
                with: .radialGradient(
                    Gradient(stops: [
                        .init(color: .black, location: 0.0),
                        .init(color: .black, location: coreRadius / holeRadius),
                        .init(color: .black.opacity(0.5), location: 0.6),
                        .init(color: .clear, location: 1.0)
                    ]),
                    center: mousePos, // <--- ИСПРАВЛЕНО: Было .center, стало mousePos
                    startRadius: 0,
                    endRadius: holeRadius
                )
            )
        }
    }
}
