import SwiftUI

@main
struct TakeARestApp: App {
    @State private var statusText = "工作中"

    var body: some Scene {
        MenuBarExtra("TakeARest", systemImage: "cup.and.saucer.fill") {
            MenuBarView(statusText: $statusText)
        }
    }
}
