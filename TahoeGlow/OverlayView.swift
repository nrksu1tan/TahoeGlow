import SwiftUI
import Combine

struct OverlayView: View {
    @ObservedObject var appState = AppState.shared
    var windowFrame: CGRect
    

    @State private var localMousePos: CGPoint = .zero
    
    // Конфиг дырки
    let holeSize: CGSize = CGSize(width: 450, height: 280)
    let holeBlur: CGFloat = 80.0
    

    let moveThreshold: CGFloat = 4.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if appState.isLightOn {
                    RoundedRectangle(cornerRadius: appState.cornerRadius)
                        .strokeBorder(appState.activeColor, lineWidth: appState.borderWidth)
                        .background(Color.clear)
                        .blur(radius: 2)
                        .padding(20)
                        .mask(
                            ZStack {
                                Color.black
                                

                                RoundedRectangle(cornerRadius: 50)
                                    .frame(width: holeSize.width, height: holeSize.height)
                                    .position(localMousePos)
                                    .blur(radius: holeBlur)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()
                            .drawingGroup() // Metal rendering
                        )
                }
            }
            .animation(.linear(duration: 0.15), value: appState.isLightOn)
            .animation(.easeInOut(duration: 0.2), value: appState.activeColor)
        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            updateMouseLocal()
        }
    }
    
    private func updateMouseLocal() {
        let globalMouse = NSEvent.mouseLocation
        
        let localX = globalMouse.x - windowFrame.minX
        let localY = windowFrame.height - (globalMouse.y - windowFrame.minY)
        

        let diffX = abs(localX - localMousePos.x)
        let diffY = abs(localY - localMousePos.y)
        
        if diffX > moveThreshold || diffY > moveThreshold {
            self.localMousePos = CGPoint(x: localX, y: localY)
        }
    }
}