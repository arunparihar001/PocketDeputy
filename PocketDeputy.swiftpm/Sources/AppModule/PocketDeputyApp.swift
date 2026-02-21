// PocketDeputyApp.swift
// PocketDeputy: Mobile Agent Prompt-Injection Safety Lab
//
// App entry point.

import SwiftUI

@main
struct PocketDeputyApp: App {
    @StateObject private var store = EvidenceStore()
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .sheet(isPresented: Binding(
                    get: { !hasSeenWelcome },
                    set: { isPresented in if !isPresented { hasSeenWelcome = true } }
                )) {
                    WelcomeView(hasSeenWelcome: $hasSeenWelcome)
                }
        }
    }
}
