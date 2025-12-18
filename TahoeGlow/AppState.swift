import SwiftUI
import Combine

struct LightPreset: Identifiable {
    let id = UUID()
    let name: String
    let color: String
}

class AppState: ObservableObject {
    static let shared = AppState()
    
    // --- STORAGE ---
    @AppStorage("borderColor") var savedColorStr: String = "#FFD28E"
    @AppStorage("borderWidth") var borderWidth: Double = 40.0
    @AppStorage("cornerRadius") var cornerRadius: Double = 65.0
    
    // Temp Controls
    @AppStorage("useTemperature") var useTemperature: Bool = false
    @AppStorage("colorTemp") var colorTemp: Double = 4500.0
    
    // --- RUNTIME ---
    @Published var isLightOn: Bool = true
    @Published var mousePosition: CGPoint = .zero
    
    // Presets
    let presets: [LightPreset] = [
        LightPreset(name: "Warm", color: "#FFD28E"),
        LightPreset(name: "Cold", color: "#E0F7FA"),
        LightPreset(name: "Toxic", color: "#00FF00"),
        LightPreset(name: "White", color: "#FFFFFF")
    ]
    
    // --- LOGIC ---
    var activeColor: Color {
        if useTemperature {
            return kelvinToColor(k: colorTemp)
        } else {
            return Color(hex: savedColorStr) ?? .white
        }
    }
    
    var borderColor: Color {
        get { Color(hex: savedColorStr) ?? .white }
        set { savedColorStr = newValue.toHex() ?? "#FFFFFF" }
    }
    
    func updateMousePos(newPos: CGPoint) {
        if abs(newPos.x - mousePosition.x) > 1.0 || abs(newPos.y - mousePosition.y) > 1.0 {
            self.mousePosition = newPos
        }
    }
    
    // Kelvin Math
    func kelvinToColor(k: Double) -> Color {
        let temp = k / 100.0
        var red: Double, green: Double, blue: Double
        
        if temp <= 66 { red = 255 } else {
            red = temp - 60
            red = 329.698727446 * pow(red, -0.1332047592)
            if red < 0 { red = 0 }
            if red > 255 { red = 255 }
        }
        
        if temp <= 66 {
            green = temp
            green = 99.4708025861 * log(green) - 161.1195681661
        } else {
            green = temp - 60
            green = 288.1221695283 * pow(green, -0.0755148492)
        }
        if green < 0 { green = 0 }
        if green > 255 { green = 255 }
        
        if temp >= 66 { blue = 255 } else {
            if temp <= 19 { blue = 0 } else {
                blue = temp - 10
                blue = 138.5177312231 * log(blue) - 305.0447927307
            }
        }
        if blue < 0 { blue = 0 }
        if blue > 255 { blue = 255 }
        
        return Color(red: red/255.0, green: green/255.0, blue: blue/255.0)
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
    func toHex() -> String? {
        guard let components = cgColor?.components, components.count >= 3 else { return nil }
        let r = Float(components[0]), g = Float(components[1]), b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}