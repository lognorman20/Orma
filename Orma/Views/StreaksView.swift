//
//  StreakDay.swift
//  Orma
//
//  Created by Logan Norman on 8/17/25.
//

import SwiftUI
import FirebaseAuth

// MARK: - Data Models
struct StreakDay: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let hasPosted: Bool? // nil = no data
}

enum StreakDataState {
    case loading
    case loaded([StreakDay])
    case noData
    case error
}

// MARK: - Individual Day Component
struct StreakDayView: View {
    let day: StreakDay
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(fillColor)
            .frame(width: 28, height: 28)
            .shadow(color: shadowColor, radius: 3, x: 0, y: 1)
    }
    
    private var fillColor: LinearGradient {
        guard let hasPosted = day.hasPosted else {
            return LinearGradient(
                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        return hasPosted
            ? LinearGradient(colors: [Color(hex: "4ADE80"), Color(hex: "22C55E")],
                             startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(hex: "F87171"), Color(hex: "EF4444")],
                             startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var shadowColor: Color {
        guard let hasPosted = day.hasPosted else { return Color.clear }
        return hasPosted
            ? Color(hex: "22C55E").opacity(0.2)
            : Color(hex: "EF4444").opacity(0.2)
    }
}

// MARK: - Week Row Component
struct StreakWeekRow: View {
    let days: [StreakDay]
    
    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 10
            let totalSpacing = spacing * CGFloat(days.count - 1)
            let itemWidth = (geo.size.width - totalSpacing) / CGFloat(days.count)
            
            HStack(spacing: spacing) {
                ForEach(days) { day in
                    StreakDayView(day: day)
                        .frame(width: itemWidth, height: itemWidth)
                }
            }
        }
        .frame(height: 28) // Optional: keeps consistent row height if needed
    }
}


// MARK: - Main Streaks View
struct StreaksView: View {
    @StateObject private var viewModel = StreaksViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Activity")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if viewModel.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("\(viewModel.currentStreak)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.weekRows, id: \.self) { week in
                    StreakWeekRow(days: week)
                }
            }
            .padding(.bottom, 8)
            .onAppear {
                viewModel.loadStreakDataFromFirebase()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// TODO: move this to another file
// MARK: - View Model
@MainActor
class StreaksViewModel: ObservableObject {
    @Published var streakDays: [StreakDay] = []
    @Published var currentStreak: Int = 0
    
    var weekRows: [[StreakDay]] {
        streakDays.chunked(into: 7)
    }
    
    private func generateSampleData() -> [StreakDay] {
        let calendar = Calendar.current
        let today = Date()
        var days: [StreakDay] = []
        
        for i in 0..<14 {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            let hasPosted: Bool?
            
            if i < 5 { // simulate missing data
                hasPosted = nil
            } else {
                hasPosted = (i < 7 || i == 13)
            }
            
            days.append(StreakDay(date: date, hasPosted: hasPosted))
        }
        
        return days
    }
    
    func loadStreakDataFromFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        PostService().fetchUserStreak(userId: userId) { streakDays, currentStreak in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.streakDays = streakDays
                    self.currentStreak = currentStreak
                }
            }
        }
    }
}

// MARK: - Array Extension
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

#Preview {
    VStack(spacing: 20) {
        StreaksView()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
