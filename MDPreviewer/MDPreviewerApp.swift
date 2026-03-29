import SwiftUI

@main
struct MDPreviewerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @AppStorage("selectedTheme", store: UserDefaults(suiteName: "group.com.mdpreviewer"))
    private var selectedTheme = "System"
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("MDPreviewer")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Markdown QuickLook Extension for macOS")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Appearance Theme")
                    .font(.headline)
                
                Picker("Theme", selection: $selectedTheme) {
                    Text("System").tag("System")
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                }
                .pickerStyle(.segmented)
                .frame(width: 250)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
            
            Text("To enable the preview, simply launch this app once. Finder will automatically pick up the extension.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Quit App") {
                NSApplication.shared.terminate(nil)
            }
            .padding(.top)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 450)
    }
}
