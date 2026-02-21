// Components.swift
// PocketDeputy: Mobile Agent Prompt-Injection Safety Lab
//
// Shared SwiftUI components used across multiple screens.

import SwiftUI

// MARK: - Decision Pill

/// A coloured badge showing a GatewayDecision.
struct DecisionPill: View {
    let decision: GatewayDecision

    var body: some View {
        Label(decision.rawValue, systemImage: decision.icon)
            .font(.subheadline.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(pillColor.opacity(0.15))
            .foregroundColor(pillColor)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(pillColor.opacity(0.4), lineWidth: 1))
    }

    private var pillColor: Color {
        switch decision {
        case .allow:   return .green
        case .confirm: return .orange
        case .block:   return .red
        }
    }
}

// MARK: - Channel Badge

struct ChannelBadge: View {
    let channel: Channel

    var body: some View {
        Text(channel.rawValue)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(channelColor.opacity(0.12))
            .foregroundColor(channelColor)
            .clipShape(Capsule())
    }

    private var channelColor: Color {
        switch channel {
        case .notification: return .blue
        case .deepLink:     return .purple
        case .qrText:       return .teal
        case .clipboard:    return .indigo
        }
    }
}

// MARK: - Tool Row

/// Compact display of a proposed ToolCall.
struct ToolCallRow: View {
    let call: ToolCall

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: call.tool.icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(call.tool.rawValue)
                    .font(.subheadline.bold())
                if !call.args.isEmpty {
                    Text(call.displayArgs)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Section Card

/// A card-style container used throughout the app.
struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption.uppercaseSmallCaps())
                .foregroundColor(.secondary)
            content
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }
}

// MARK: - Outcome Badge

struct OutcomeBadge: View {
    let outcome: FinalOutcome

    var body: some View {
        Text(outcome.rawValue)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    private var color: Color {
        switch outcome {
        case .executed:   return .green
        case .pending:    return .orange
        case .blocked:    return .red
        case .userDenied: return .gray
        }
    }
}

// MARK: - Simple Bar Chart (Charts-free fallback)

/// A minimal horizontal-bar chart for benchmark metrics.
struct SimpleBarChart: View {
    struct Bar: Identifiable {
        let id = UUID()
        let label: String
        let value: Double   // 0.0 – 1.0
        let color: Color
    }

    let bars: [Bar]
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.bold())
            ForEach(bars) { bar in
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(bar.label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.0f%%", bar.value * 100))
                            .font(.caption.bold())
                            .foregroundColor(bar.color)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.tertiarySystemBackground))
                                .frame(height: 12)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(bar.color)
                                .frame(width: geo.size.width * CGFloat(bar.value), height: 12)
                        }
                    }
                    .frame(height: 12)
                }
            }
        }
    }
}

// MARK: - Divider with label

struct LabelledDivider: View {
    let label: String

    var body: some View {
        HStack {
            Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize()
            Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
        }
    }
}
