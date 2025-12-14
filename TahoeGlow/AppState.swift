import SwiftUI
import Combine

struct LightPreset: Identifiable {
    let id = UUID()
    let name: String
    let color: String 
}

class AppState: ObservableObject {
    static let shared = AppState()
    
    @AppStorage("borderColor") var savedColorStr: String = "#FFD28E" 
    @AppStorage("borderWidth") var borderWidth: Double = 25.0
    
    @Published var isLightOn: Bool = true
    @Published var mousePosition: CGPoint = .zero
    
    let presets: [LightPreset] = [
        LightPreset(name: "Warm", color: "#FFD28E"),
        LightPreset(name: "Cool", color: "#E0F7FA"),
        LightPreset(name: "Neon", color: "#FF00FF"),
        LightPreset(name: "Gold", color: "#FFD700"),
        LightPreset(name: "Matrix", color: "#00FF7F")
    ]
    
    var borderColor: Color {
        get { Color(hex: savedColorStr) ?? .yellow }
        set { savedColorStr = newValue.toHex() ?? "#FFD700" }
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
