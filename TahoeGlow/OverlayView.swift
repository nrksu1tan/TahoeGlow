//
//  OverlayView.swift
//  EdgeLight
//
//  Created by Nursultan Nurekesh on 13.12.2025.
//

import SwiftUI
import Combine

struct OverlayView: View {
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if appState.isLightOn {
                    // --- ВИЗУАЛ (САМЫЙ СОК) ---
                    ZStack {
                        // 1. Широкое рассеивание (Ambient)
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(appState.borderColor.opacity(0.3), lineWidth: appState.borderWidth + 50)
                            .blur(radius: 60)
                        
                        // 2. Основное тело света (Body)
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(appState.borderColor.opacity(0.8), lineWidth: appState.borderWidth + 10)
                            .blur(radius: 20)
                        
                        // 3. Яркое ядро (Core) - создает эффект неоновой трубки
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.white.opacity(0.9), lineWidth: appState.borderWidth * 0.3)
                            .blur(radius: 4)
                            .shadow(color: appState.borderColor, radius: 10)
                    }
                    // Отступ от краев экрана (чтобы не лип к рамкам)
                    .padding(20)
                    
                    // --- МАСКА (ДЫРКА ПОД МЫШКОЙ) ---
                    .mask(
                        Rectangle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(stops: [
                                        // Прозрачность в центре (под мышкой)
                                        .init(color: .clear, location: 0.0),
                                        .init(color: .clear, location: 0.05), // Размер дырки
                                        // Переход к черному (видимому)
                                        .init(color: .black, location: 0.25)
                                    ]),
                                    center: UnitPoint(
                                        // Конвертируем координаты:
                                        // X стандартно
                                        x: appState.mousePosition.x / geometry.size.width,
                                        // Y инвертируем, так как (0,0) в маске сверху-слева!
                                        y: 1.0 - (appState.mousePosition.y / geometry.size.height)
                                    ),
                                    startRadius: 0,
                                    endRadius: 500 // Плавность перехода
                                )
                            )
                    )
                }
            }
            .animation(.easeInOut(duration: 0.6), value: appState.isLightOn)
            .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.7), value: appState.mousePosition)
        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            updateMouseLocation()
        }
    }
    
    func updateMouseLocation() {
        let globalMouse = NSEvent.mouseLocation
        guard let window = NSApp.windows.first(where: { $0.level == .floating }) else { return }
        
        let windowFrame = window.frame
        
        // В macOS mouseLocation.y идет от НИЗА экрана.
        // windowFrame.minY тоже от НИЗА экрана.
        // Получаем Y относительно нижнего края окна:
        let localYFromBottom = globalMouse.y - windowFrame.minY
        let localX = globalMouse.x - windowFrame.minX
        
        // Сохраняем как есть, инверсию для маски делаем в UnitPoint
        appState.mousePosition = CGPoint(x: localX, y: localYFromBottom)
    }
}
