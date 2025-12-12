import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        VStack(spacing: 24) {
            Text("TahoeGlow")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.top)
            
            // Section 1: Presets
            VStack(alignment: .leading, spacing: 10) {
                Text("Quick Presets")
                    .font(.caption).bold().foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    ForEach(appState.presets) { preset in
                        Button(action: {
                            appState.borderColor = Color(hex: preset.color) ?? .white
                        }) {
                            VStack {
                                Circle()
                                    .fill(Color(hex: preset.color) ?? .white)
                                    .frame(width: 30, height: 30)
                                    .shadow(color: Color(hex: preset.color)?.opacity(0.6) ?? .clear, radius: 4)
                                    .overlay(
                                        Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                Text(preset.name)
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Section 2: Customization
            VStack(spacing: 15) {
                ColorPicker("Custom Color", selection: $appState.borderColor)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Intensity & Width")
                        Spacer()
                        Text("\(Int(appState.borderWidth))")
                            .foregroundColor(.secondary)
                    }
                    // Увеличил максимум до 120
                    Slider(value: $appState.borderWidth, in: 10...300) {
                        Text("Width")
                    } minimumValueLabel: {
                        Image(systemName: "sun.min")
                    } maximumValueLabel: {
                        Image(systemName: "sun.max.fill")
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // --- ОБНОВЛЕННЫЙ ПОДВАЛ ---
                        HStack(spacing: 4) {
                            Text("Made with ❤️ by")
                            
                            // Ссылка на GitHub
                            Link("nrksu1tan", destination: URL(string: "https://github.com/nrksu1tan")!)
                                .fontWeight(.bold) // Жирный шрифт
                                .underline(false) // Без подчеркивания (или true, если хочешь)
                                .foregroundColor(.primary) // Цвет текста системы
                                .onHover { isHovered in
                                    // Меняем курсор на "руку" при наведении
                                    if isHovered { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                                }
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                    }
                    .frame(width: 400, height: 450)
                    .background(VisualEffectBlur(material: .sidebar, blendingMode: .behindWindow))
                }
            }

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
