import SwiftUI
import Combine

struct ContentView: View {
    @State private var currentOpacity: Double = 1.0
    @State private var targetOpacity: Double = 1.0

    let mainColor: Color = Color(red: 1.0, green: 0.95, blue: 0.8)
    let cornerRadius: CGFloat = 24.0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(mainColor.opacity(0.3), lineWidth: 50)
                .blur(radius: 60)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(mainColor.opacity(0.6), lineWidth: 20)
                .blur(radius: 20)

            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [.white, mainColor, .white]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 6
                )
                .blur(radius: 4)
                .shadow(color: mainColor, radius: 5)
        }

        .opacity(currentOpacity)

        .padding(30)
        .edgesIgnoringSafeArea(.all)
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
            updateMouseBehavior()
        }
        .animation(.smooth(duration: 0.4), value: currentOpacity)
    }
    
    func updateMouseBehavior() {
        let mouseLoc = NSEvent.mouseLocation
        

        guard let window = NSApp.windows.first(where: { $0.isKeyWindow ?? false }) else { return }
        let windowFrame = window.frame

        let reactionDistance: CGFloat = 150.0
        

        let isNearLeft = mouseLoc.x < (windowFrame.minX + reactionDistance)
        let isNearRight = mouseLoc.x > (windowFrame.maxX - reactionDistance)
        let isNearBottom = mouseLoc.y < (windowFrame.minY + reactionDistance)
        let isNearTop = mouseLoc.y > (windowFrame.maxY - reactionDistance)
        
        if isNearLeft || isNearRight || isNearBottom || isNearTop {
            self.currentOpacity = 0.02
        } else {
            self.currentOpacity = 1.0
        }
    }
}
