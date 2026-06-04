import SwiftUI

struct StartMenuView: View {
    @State private var searchText = ""
    @State private var applications: [AppInfo] = []
    
    let onAppSelected: (URL) -> Void
    
    var filteredApps: [AppInfo] {
        if searchText.isEmpty {
            return applications
        }
        return applications.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("Cerca applicazioni...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Divider()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(filteredApps) { app in
                        Button(action: {
                            onAppSelected(app.url)
                        }) {
                            HStack {
                                if let icon = app.icon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                }
                                Text(app.name)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(width: 420, height: 520)
        .onAppear {
            loadApplications()
        }
    }
    
    private func loadApplications() {
        let fileManager = FileManager.default
        var apps: [AppInfo] = []
        
        // /Applications
        if let urls = try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "/Applications"), includingPropertiesForKeys: nil) {
            for url in urls where url.pathExtension == "app" {
                apps.append(AppInfo(url: url))
            }
        }
        
        // ~/Applications
        let homeAppsURL = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Applications")
        if let urls = try? fileManager.contentsOfDirectory(at: homeAppsURL, includingPropertiesForKeys: nil) {
            for url in urls where url.pathExtension == "app" {
                apps.append(AppInfo(url: url))
            }
        }
        
        self.applications = apps.sorted { $0.name < $1.name }
    }
}

struct AppInfo: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    let icon: NSImage?
    
    init(url: URL) {
        self.url = url
        self.name = url.deletingPathExtension().lastPathComponent
        self.icon = NSWorkspace.shared.icon(forFile: url.path)
    }
}