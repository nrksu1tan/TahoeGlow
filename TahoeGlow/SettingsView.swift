import SwiftUI

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralTab()
                .tabItem { Label("Studio", systemImage: "slider.horizontal.3") }
            
            AboutTab()
                .tabItem { Label("About", systemImage: "sparkles") }
        }
        .frame(width: 500, height: 600)
        .background(VisualEffectBlur(material: .sidebar, blendingMode: .behindWindow).ignoresSafeArea())
    }
}


struct GeneralTab: View {
    @ObservedObject var s = AppState.shared
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                // HERO
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("TahoeGlow")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        Text(s.isLightOn ? "Studio Light Active" : "Light is Off")
                            .font(.subheadline)
                            .foregroundColor(s.isLightOn ? .green : .secondary)
                            .animation(.snappy, value: s.isLightOn)
                    }
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            s.isLightOn.toggle()
                        }
                    }) {
                        Image(systemName: "power")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(s.isLightOn ? .white : .gray)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(s.isLightOn ? s.activeColor : Color.gray.opacity(0.2))
                                    .shadow(color: s.isLightOn ? s.activeColor.opacity(0.5) : .clear, radius: 10)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                .background(.ultraThinMaterial) 
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // SOURCE
                VStack(alignment: .leading, spacing: 15) {
                    Label("Illumination Source", systemImage: "sun.max.fill")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Picker("", selection: $s.useTemperature) {
                        Text("Color Temperature").tag(true)
                        Text("Custom Tint").tag(false)
                    }
                    .pickerStyle(.segmented)
                    
                    if s.useTemperature {
                        VStack(spacing: 10) {
                            ZStack {
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.6, blue: 0.2),
                                        Color.white,
                                        Color(red: 0.6, green: 0.8, blue: 1.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .mask(Capsule())
                                .frame(height: 12)
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                
                                Slider(value: $s.colorTemp, in: 2000...9000)
                                    .accentColor(.clear)
                                    .opacity(0.8)
                            }
                            HStack {
                                Text("Candle").font(.caption2).foregroundColor(.secondary)
                                Spacer()
                                Text("\(Int(s.colorTemp))K").font(.system(.caption, design: .monospaced)).bold().padding(4).background(Color.black.opacity(0.1)).cornerRadius(4)
                                Spacer()
                                Text("Sky").font(.caption2).foregroundColor(.secondary)
                            }
                        }
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    } else {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Select Tint")
                                Spacer()
                                ColorPicker("", selection: $s.borderColor, supportsOpacity: false).labelsHidden()
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(s.presets) { p in
                                        Button(action: { withAnimation { s.borderColor = Color(hex: p.color) ?? .white } }) {
                                            Circle().fill(Color(hex: p.color) ?? .white).frame(width: 36, height: 36)
                                                .overlay(Circle().strokeBorder(Color.white.opacity(0.2), lineWidth: 1))
                                                .shadow(color: Color(hex: p.color)!.opacity(0.4), radius: 4, y: 2)
                                        }.buttonStyle(.plain)
                                    }
                                }.padding(.horizontal, 4).padding(.vertical, 8)
                            }
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial) 
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 20) {
                    Label("Frame Geometry", systemImage: "ruler.fill")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "arrow.left.and.right.circle").foregroundColor(.gray)
                        Slider(value: $s.borderWidth, in: 20...150).tint(s.activeColor)
                        Text("\(Int(s.borderWidth))px").font(.system(.caption, design: .monospaced)).frame(width: 45)
                    }
                    HStack {
                        Image(systemName: "circle.dotted").foregroundColor(.gray)
                        Slider(value: $s.cornerRadius, in: 20...120).tint(s.activeColor)
                        Text("\(Int(s.cornerRadius))").font(.system(.caption, design: .monospaced)).frame(width: 45)
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding(20)
            .animation(.easeInOut(duration: 0.3), value: s.useTemperature)
        }
    }
}

// --- TAB 2: ABOUT ---
struct AboutTab: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 90, height: 90)
                            .blur(radius: 20)
                            .opacity(0.5)
                        Image(systemName: "macwindow.badge.plus").font(.system(size: 60)).foregroundStyle(.white).shadow(radius: 10)
                    }
                    VStack(spacing: 5) {
                        Text("TahoeGlow").font(.system(size: 32, weight: .bold, design: .rounded))
                        HStack(spacing: 8) {
                            Text("v\(Bundle.main.appVersion)").font(.caption).bold().padding(.horizontal, 8).padding(.vertical, 4).background(Color.gray.opacity(0.1)).cornerRadius(6)                        }
                    }
                }.padding(.top, 40)
                
                Text("The ultimate edge lighting utility for macOS.\nEnhance your video calls with professional, studio-quality illumination.")
                    .font(.body).multilineTextAlignment(.center).foregroundColor(.secondary).padding(.horizontal, 40).lineSpacing(4)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Link(destination: URL(string: "https://github.com/nrksu1tan/TahoeGlow")!) {
                            HStack { Image(systemName: "star.fill").foregroundColor(.yellow); Text("Star on GitHub"); Spacer(); Image(systemName: "arrow.up.right") }
                                .padding().background(.ultraThinMaterial).cornerRadius(12).shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                        }.buttonStyle(.plain)
                        Link(destination: URL(string: "https://github.com/nrksu1tan/TahoeGlow/issues")!) {
                            HStack { Image(systemName: "ladybug.fill").foregroundColor(.red); Text("Report Bug"); Spacer(); Image(systemName: "arrow.up.right") }
                                .padding().background(.ultraThinMaterial).cornerRadius(12).shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                        }.buttonStyle(.plain)
                    }
                    Link(destination: URL(string: "https://github.com/nrksu1tan")!) {
                        HStack {
                            Image(systemName: "person.crop.circle.fill").font(.title2).foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) { Text("Developed by nrksu1tan").font(.headline); Text("Follow for more macOS apps").font(.caption).foregroundColor(.secondary) }
                            Spacer(); Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                        .padding().background(.ultraThinMaterial).cornerRadius(12).shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                    }.buttonStyle(.plain)
                }.padding(.horizontal, 20)
                
                Spacer()
                Text("© 2025 TahoeGlow. Open Source (MIT License).").font(.caption2).foregroundColor(.secondary.opacity(0.5)).padding(.bottom, 20)
            }
        }
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
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}