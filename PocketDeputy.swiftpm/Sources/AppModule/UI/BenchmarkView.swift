// BenchmarkView.swift
// PocketDeputy: Mobile Agent Prompt-Injection Safety Lab
//
// Runs all built-in scenarios and shows ASR before/after gateway,
// accuracy, false friction, and per-scenario replay cards.

import SwiftUI

struct BenchmarkView: View {
    @State private var summary: BenchmarkSummary? = nil
    @State private var isRunning = false

    private let runner = BenchmarkRunner()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    // ── Run button ───────────────────────────────────────────
                    Button {
                        isRunning = true
                        // Brief async hop to allow UI to update
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            summary = runner.runAll()
                            isRunning = false
                        }
                    } label: {
                        HStack {
                            if isRunning {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "play.rectangle.fill")
                            }
                            Text(summary == nil ? "Run All Scenarios" : "Re-run Benchmark")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }

                    if let s = summary {
                        BenchmarkResultsView(summary: s)
                    } else {
                        Text("Tap 'Run All Scenarios' to evaluate the Action Gateway across all 12 built-in scenarios.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 24)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
            .navigationTitle("Benchmark")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - BenchmarkResultsView

private struct BenchmarkResultsView: View {
    let summary: BenchmarkSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            // ── Metric cards ─────────────────────────────────────────────────
            HStack(spacing: 12) {
                MetricCard(label: "Scenarios", value: "\(summary.total)", color: .accentColor)
                MetricCard(label: "Accuracy",
                           value: String(format: "%.0f%%", summary.accuracy * 100),
                           color: summary.accuracy >= 0.8 ? .green : .orange)
                MetricCard(label: "False Friction",
                           value: "\(summary.falseFrictionCount)",
                           color: summary.falseFrictionCount == 0 ? .green : .orange)
            }

            // ── ASR bar chart ─────────────────────────────────────────────────
            SectionCard(title: "Attack Success Rate (ASR)", icon: "chart.bar.fill") {
                SimpleBarChart(
                    bars: [
                        .init(label: "ASR Before Gateway",
                              value: summary.asrBefore,
                              color: .red),
                        .init(label: "ASR After Gateway",
                              value: summary.asrAfter,
                              color: .green)
                    ],
                    title: ""
                )
                .frame(height: 80)

                Text("ASR reduced from \(pct(summary.asrBefore)) → \(pct(summary.asrAfter)). Unsafe scenarios that slipped through: \(summary.unsafeAfterCount).")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }

            // ── Per-scenario list ─────────────────────────────────────────────
            Text("Per-Scenario Results")
                .font(.subheadline.bold())

            ForEach(summary.results) { result in
                ScenarioResultRow(result: result)
            }
        }
    }

    private func pct(_ v: Double) -> String { String(format: "%.0f%%", v * 100) }
}

// MARK: - ScenarioResultRow

private struct ScenarioResultRow: View {
    let result: BenchmarkResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(result.scenario.name)
                    .font(.caption.bold())
                    .lineLimit(2)
                Spacer()
                Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.isCorrect ? .green : .red)
            }

            HStack(spacing: 8) {
                ChannelBadge(channel: result.scenario.channel)
                DecisionPill(decision: result.gatewayResult.decision)
                if !result.isCorrect {
                    Text("Expected: \(result.scenario.expectedDecision.rawValue)")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }

            Text(result.gatewayResult.reason)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - MetricCard

private struct MetricCard: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
}
