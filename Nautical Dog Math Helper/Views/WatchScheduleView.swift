import SwiftUI

struct WatchScheduleView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var systemColorScheme
    
    @State private var selectedFeature: WatchFeature = .timeCalculator
    
    // Shared date states - moved to parent view
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    private var isDark: Bool {
        nightMode.isEnabled || systemColorScheme == .dark
    }
    
    var body: some View {
        ZStack {
            (isDark ? Color.black : Color("TileBackground"))
                .ignoresSafeArea()
            
            ScrollView {
                CardContainer {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Watch Schedule")
                            .font(.custom("Avenir-Heavy", size: 36))
                            .bold()
                            .foregroundColor(isDark ? .green : .black)
                        
                        Text("Calculate the total time underway or create a watch schedule for 2 pilots.\nFor Custom watch schedule, calculator assumes equal time split between both pilots with remainder of time on either end. For example 18 hrs underway with max 6 hour watch would be split 3/6/6/3.")
                            .font(.custom("Avenir", size: 16))
                            .padding()
                            .background(isDark ? Color.white.opacity(0.05) : Color.gray.opacity(0.1))
                            .foregroundColor(isDark ? .green : .black)
                            .cornerRadius(8)
                        
                        // Feature Selection
                        Picker("Feature", selection: $selectedFeature) {
                            Text("Time Calculator").tag(WatchFeature.timeCalculator)
                            Text("Watch Schedule").tag(WatchFeature.watchSchedule)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .onAppear {
                            updateSegmentedControlAppearance(isDark: isDark)
                        }
                        .onChange(of: isDark) { newValue in
                            updateSegmentedControlAppearance(isDark: newValue)
                        }
                        
                        // Show selected feature - pass shared dates
                        Group {
                            if selectedFeature == .timeCalculator {
                                TimeCalculatorView(startDate: $startDate, endDate: $endDate)
                            } else {
                                WatchSchedulerView(startDate: $startDate, endDate: $endDate)
                            }
                        }
                        .environmentObject(nightMode)
                        
                        Spacer()
                    }
                }
                .padding(.vertical)
            }
        }
        .dismissKeyboardOnTap()
        .navigationTitle("Watch Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isDark ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
    }
    
    private func updateSegmentedControlAppearance(isDark: Bool) {
        let appearance = UISegmentedControl.appearance()
        if isDark {
            appearance.backgroundColor = UIColor.black
            appearance.selectedSegmentTintColor = UIColor.green
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.green], for: .normal)
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        } else {
            appearance.backgroundColor = UIColor.white
            appearance.selectedSegmentTintColor = UIColor(named: "AccentColor") ?? UIColor.systemBlue
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        }
    }
}

enum WatchFeature: String, CaseIterable {
    case timeCalculator = "Time Calculator"
    case watchSchedule = "Watch Schedule"
}

// MARK: - Time Calculator View
struct TimeCalculatorView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var systemColorScheme
    
    // Use binding to shared dates
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var totalTime = ""
    
    private var isDark: Bool {
        nightMode.isEnabled || systemColorScheme == .dark
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Start Date & Time")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(isDark ? .green : .black)
                
                DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(CompactDatePickerStyle())
                    .accentColor(isDark ? .green : Color("AccentColor"))
                    .foregroundColor(isDark ? .green : .black)
                    .colorScheme(isDark ? .dark : .light)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("End Date & Time")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(isDark ? .green : .black)
                
                DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(CompactDatePickerStyle())
                    .accentColor(isDark ? .green : Color("AccentColor"))
                    .foregroundColor(isDark ? .green : .black)
                    .colorScheme(isDark ? .dark : .light)
            }
            
            Button("Calculate Total Time", action: calculateTotalTime)
                .buttonStyle(ModernButtonStyle())
                .padding(.horizontal)
            
            if !totalTime.isEmpty {
                VStack(spacing: 10) {
                    Text("Total Time Underway")
                        .font(.custom("Avenir", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(isDark ? .green : Color("AccentColor"))
                    
                    Text(totalTime)
                        .font(.custom("Avenir", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(isDark ? .green : Color("AccentColor"))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isDark ? Color.green.opacity(0.1) : Color("AccentColor").opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isDark ? Color.green.opacity(0.3) : Color("AccentColor").opacity(0.2), lineWidth: 1)
                        )
                )
                
            }
        }
    }
    
    private func calculateTotalTime() {
        let timeInterval = endDate.timeIntervalSince(startDate)
        
        if timeInterval <= 0 {
            totalTime = "End time must be after start time"
            return
        }
        
        let totalMinutes = Int(timeInterval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        // Check if start and end minutes are the same - if so, round up to next full hour
        let startCalendar = Calendar.current
        let endCalendar = Calendar.current
        let startMinuteComponent = startCalendar.component(.minute, from: startDate)
        let endMinuteComponent = endCalendar.component(.minute, from: endDate)
        
        if startMinuteComponent == endMinuteComponent {
            // Same minutes - round up to next full hour
            let roundedHours = hours + (minutes > 0 ? 1 : 0)
            totalTime = "\(roundedHours)h"
        } else if hours > 0 && minutes > 0 {
            totalTime = "\(hours)h \(minutes)m"
        } else if hours > 0 {
            totalTime = "\(hours)h"
        } else {
            totalTime = "\(minutes)m"
        }
    }
}

// MARK: - Watch Scheduler View
struct WatchSchedulerView: View {
    @EnvironmentObject var nightMode: NightMode
    @Environment(\.colorScheme) var systemColorScheme
    
    private let pilot1Name = "Pilot 1"
    private let pilot2Name = "Pilot 2"
    
    // Use binding to shared dates
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var scheduleType: ScheduleType = .sixSix
    @State private var maxWatchHours = "6"
    @State private var watchSchedule: [WatchPeriod] = []
    @State private var totalTimeText = ""
    @State private var errorMessage = ""
    
    private var isDark: Bool {
        nightMode.isEnabled || systemColorScheme == .dark
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Date Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Start Date & Time")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(isDark ? .green : .black)
                
                DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(CompactDatePickerStyle())
                    .accentColor(isDark ? .green : Color("AccentColor"))
                    .foregroundColor(isDark ? .green : .black)
                    .colorScheme(isDark ? .dark : .light)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("End Date & Time")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(isDark ? .green : .black)
                
                DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(CompactDatePickerStyle())
                    .accentColor(isDark ? .green : Color("AccentColor"))
                    .foregroundColor(isDark ? .green : .black)
                    .colorScheme(isDark ? .dark : .light)
            }
            
            // Schedule Type Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Schedule Type")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(isDark ? .green : .black)
                
                Picker("Schedule Type", selection: $scheduleType) {
                    Text("Halfway Split").tag(ScheduleType.halfway)
                    Text("Custom").tag(ScheduleType.custom)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onAppear {
                    updateSegmentedControlAppearance(isDark: isDark)
                }
                .onChange(of: isDark) { newValue in
                    updateSegmentedControlAppearance(isDark: newValue)
                }
            }
            
            // Custom Options (only show if Custom is selected)
            if scheduleType == .custom {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Max Watch Hours")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(isDark ? .green : .black)
                    
                    TextField("6", text: $maxWatchHours)
                        .keyboardType(.decimalPad)
                        .padding(10)
                        .background(isDark ? Color.white.opacity(0.1) : Color.white)
                        .foregroundColor(isDark ? .green : .black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isDark ? Color.green.opacity(0.3) : Color.gray.opacity(0.4), lineWidth: 1)
                        )
                }
            }
            
            Button("Generate Schedule", action: generateSchedule)
                .buttonStyle(ModernButtonStyle())
                .padding(.horizontal)
            
            // Error Message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.horizontal)
            }
            
            // Results
            if !totalTimeText.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Total Time Underway: \(totalTimeText)")
                        .font(.custom("Avenir", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(isDark ? .green : Color("AccentColor"))
                    
                    if !watchSchedule.isEmpty {
                        Text("Watch Schedule:")
                            .font(.custom("Avenir", size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(isDark ? .green : Color("AccentColor"))
                            .padding(.top, 10)
                        
                        ForEach(watchSchedule) { period in
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(formatDate(period.startTime)) - \(formatTime(period.endTime)) \(period.pilotName) (\(period.durationText))")
                                    .font(.custom("Avenir", size: 16))
                                    .foregroundColor(isDark ? .green : Color("AccentColor"))
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isDark ? Color.green.opacity(0.1) : Color("AccentColor").opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isDark ? Color.green.opacity(0.3) : Color("AccentColor").opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    private func generateSchedule() {
        errorMessage = ""
        watchSchedule = []
        
        let timeInterval = endDate.timeIntervalSince(startDate)
        guard timeInterval > 0 else {
            errorMessage = "End time must be after start time"
            return
        }
        
        let totalHours = timeInterval / 3600
        let totalMinutes = Int(timeInterval) % 3600 / 60
        
        if totalHours >= 1 && totalMinutes > 0 {
            totalTimeText = "\(Int(totalHours))h \(totalMinutes)m"
        } else if totalHours >= 1 {
            totalTimeText = "\(Int(totalHours))h"
        } else {
            totalTimeText = "\(totalMinutes)m"
        }
        
        switch scheduleType {
        case .halfway:
            generateHalfwaySchedule(totalHours: totalHours)
        case .custom:
            generateCustomSchedule(totalHours: totalHours)
        case .sixSix:
            // This case is no longer used but kept for compatibility
            generateCustomSchedule(totalHours: totalHours)
        }
    }
    
    private func generateHalfwaySchedule(totalHours: Double) {
        let halfTime = totalHours / 2
        let midTime = startDate.addingTimeInterval(halfTime * 3600)
        
        let duration1 = calculateDuration(from: startDate, to: midTime)
        let duration2 = calculateDuration(from: midTime, to: endDate)
        
        watchSchedule.append(WatchPeriod(startTime: startDate, endTime: midTime, pilotName: pilot1Name, durationText: duration1))
        watchSchedule.append(WatchPeriod(startTime: midTime, endTime: endDate, pilotName: pilot2Name, durationText: duration2))
    }
    
    private func generateCustomSchedule(totalHours: Double) {
        guard let maxWatch = Double(maxWatchHours), maxWatch > 0 else {
            errorMessage = "Please enter a valid number for max watch hours"
            return
        }
        
        // Calculate initial number of full max-watch periods
        let initialMaxWatchPeriods = Int(totalHours / maxWatch)
        
        // Ensure we have an even number of total periods
        // If initial calculation would result in odd total periods, reduce by 1
        let maxWatchPeriods: Int
        if initialMaxWatchPeriods % 2 == 1 {
            // Odd number of full watches would create odd total periods
            maxWatchPeriods = initialMaxWatchPeriods - 1
        } else {
            // Even number of full watches creates even total periods
            maxWatchPeriods = initialMaxWatchPeriods
        }
        
        // Calculate remainder after using the adjusted number of full watches
        let usedTime = Double(maxWatchPeriods) * maxWatch
        let remainder = totalHours - usedTime
        let extraTimePerEnd = remainder / 2
        
        var currentTime = startDate
        var periodNumber = 1
        
        // Always start with Pilot 1 for the first period (remainder)
        if extraTimePerEnd > 0 {
            let endTime = currentTime.addingTimeInterval(extraTimePerEnd * 3600)
            let duration = calculateDuration(from: currentTime, to: endTime)
            watchSchedule.append(WatchPeriod(startTime: currentTime, endTime: endTime, pilotName: pilot1Name, durationText: duration))
            currentTime = endTime
            periodNumber += 1
        }
        
        // Add max watch periods, alternating between pilots
        for _ in 0..<maxWatchPeriods {
            let endTime = currentTime.addingTimeInterval(maxWatch * 3600)
            let duration = calculateDuration(from: currentTime, to: endTime)
            
            // Determine pilot based on period number (odd = Pilot 1, even = Pilot 2)
            let currentPilot = (periodNumber % 2 == 1) ? pilot1Name : pilot2Name
            
            watchSchedule.append(WatchPeriod(startTime: currentTime, endTime: endTime, pilotName: currentPilot, durationText: duration))
            currentTime = endTime
            periodNumber += 1
        }
        
        // Add final period with remaining time (should always be Pilot 1 since we ensure even total periods)
        if extraTimePerEnd > 0 && currentTime < endDate {
            let duration = calculateDuration(from: currentTime, to: endDate)
            let finalPilot = (periodNumber % 2 == 1) ? pilot1Name : pilot2Name
            watchSchedule.append(WatchPeriod(startTime: currentTime, endTime: endDate, pilotName: finalPilot, durationText: duration))
        }
    }
    
    private func calculateDuration(from startTime: Date, to endTime: Date) -> String {
        let timeInterval = endTime.timeIntervalSince(startTime)
        let totalMinutes = Int(timeInterval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d HHmm"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        return formatter.string(from: date)
    }
    
    private func updateSegmentedControlAppearance(isDark: Bool) {
        let appearance = UISegmentedControl.appearance()
        if isDark {
            appearance.backgroundColor = UIColor.black
            appearance.selectedSegmentTintColor = UIColor.green
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.green], for: .normal)
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        } else {
            appearance.backgroundColor = UIColor.white
            appearance.selectedSegmentTintColor = UIColor(named: "AccentColor") ?? UIColor.systemBlue
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
            appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        }
    }
}

enum ScheduleType: String, CaseIterable {
    case halfway = "Halfway Split"
    case custom = "Custom"
    case sixSix = "6/6 Split" // Kept for compatibility but not used in picker
}

struct WatchPeriod: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let pilotName: String
    let durationText: String
}

struct WatchScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WatchScheduleView().environmentObject(NightMode())
        }
    }
}
