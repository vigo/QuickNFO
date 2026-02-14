import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("QuickNFO")
                .font(.largeTitle)
                .bold()

            Text("QuickLook Preview Extension for .nfo files")
                .font(.body)
                .foregroundColor(.secondary)

            Text("Select a .nfo file in Finder and press Space to preview.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
    }
}
