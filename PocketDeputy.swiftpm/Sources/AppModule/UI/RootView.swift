// RootView.swift
// PocketDeputy: Mobile Agent Prompt-Injection Safety Lab
//
// Top-level TabView that hosts all major screens.

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            SimulatorView()
                .tabItem { Label("Lab", systemImage: "flask.fill") }

            BenchmarkView()
                .tabItem { Label("Benchmark", systemImage: "chart.bar.fill") }

            AboutView()
                .tabItem { Label("About", systemImage: "info.circle.fill") }
        }
    }
}
