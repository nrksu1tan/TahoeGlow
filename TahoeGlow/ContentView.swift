import SwiftUI
import Combine

struct ContentView: View {
    // Состояние прозрачности (для анимации скрытия)
    @State private var currentOpacity: Double = 1.0
    // Целевая прозрачность (к чему стремимся)
    @State private var targetOpacity: Double = 1.0

    // --- НАСТРОЙКИ КРАСОТЫ ---
    // Основной цвет света (теплый белый для уюта)
    let mainColor: Color = Color(red: 1.0, green: 0.95, blue: 0.8)
    // Радиус скругления углов экрана
    let cornerRadius: CGFloat = 24.0
    
    var body: some View {
        ZStack {
            // Слой 1: Самое широкое, мягкое внешнее свечение (Glow)
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(mainColor.opacity(0.3), lineWidth: 50)
                .blur(radius: 60)
            
            // Слой 2: Среднее свечение, формирует "тело" света
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(mainColor.opacity(0.6), lineWidth: 20)
                .blur(radius: 20)

            // Слой 3: Яркий внутренний контур (Core)
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
                .shadow(color: mainColor, radius: 5) // Небольшая тень для объема
        }
        // Применяем прозрачность ко всему стеку слоев
        .opacity(currentOpacity)
        // Отступ от краев окна, чтобы размытие не обрезалось резко
        .padding(30)
        .edgesIgnoringSafeArea(.all)
        // Таймер для проверки мыши
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
            updateMouseBehavior()
        }
        // Плавная анимация изменения прозрачности
        .animation(.smooth(duration: 0.4), value: currentOpacity)
    }
    
    // Логика проверки положения мыши
    func updateMouseBehavior() {
        let mouseLoc = NSEvent.mouseLocation
        
        // Нам нужно получить frame именно того окна, в котором мы находимся,
        // так как оно теперь не на весь экран.
        guard let window = NSApp.windows.first(where: { $0.isKeyWindow ?? false }) else { return }
        let windowFrame = window.frame

        // Дистанция, на которой свет начинает "пугаться" мыши
        let reactionDistance: CGFloat = 150.0
        
        // Проверяем, попадает ли мышь в зону риска у краев нашего окна
        // Важно: NSEvent.mouseLocation дает глобальные координаты экрана.
        // Нам нужно соотнести их с координатами нашего окна.
        
        let isNearLeft = mouseLoc.x < (windowFrame.minX + reactionDistance)
        let isNearRight = mouseLoc.x > (windowFrame.maxX - reactionDistance)
        // Координата Y в macOS идет снизу вверх
        let isNearBottom = mouseLoc.y < (windowFrame.minY + reactionDistance)
        let isNearTop = mouseLoc.y > (windowFrame.maxY - reactionDistance)
        
        if isNearLeft || isNearRight || isNearBottom || isNearTop {
            // Если мышь у края - гасим свет почти полностью
            self.currentOpacity = 0.02
        } else {
            // Если мышь в безопасной зоне - включаем свет
            self.currentOpacity = 1.0
        }
    }
}
