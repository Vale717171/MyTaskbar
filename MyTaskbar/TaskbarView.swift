import SwiftUI

struct TaskbarView: View {
    @StateObject private var viewModel = TaskbarViewModel()
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: viewModel.toggleStartMenu) {
                Text("Start")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            
            Divider().frame(height: 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.runningApplications, id: \.bundleIdentifier) { app in
                        AppIconButton(app: app, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 4)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
    }
}

struct AppIconButton: View {
    let app: NSRunningApplication
    let viewModel: TaskbarViewModel
    
    var body: some View {
        Button(action: { viewModel.bringAppToFront(app) }) {
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
        }
        .buttonStyle(.plain)
    }
}