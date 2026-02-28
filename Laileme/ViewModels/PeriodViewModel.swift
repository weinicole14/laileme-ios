import SwiftUI
import SwiftData
import Combine

// MARK: - UI State
struct PeriodUiState {
    var records: [PeriodRecord] = []
    var latestRecord: PeriodRecord? = nil
    var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    var currentMonth: Date = Date()
    var isInPeriod: Bool = false
    var hasActivePeriod: Bool = false
    var daysUntilPeriodEnd: Int = 0
    var daysUntilNextPeriod: Int = 0
    var currentPhase: String = "请记录经期"
    var cycleDay: Int = 0
    var cycleProgress: Float = 0
    var periodProgress: Float = 0
    var isFirstRecord: Bool = false
    var hasSetup: Bool = false
    var trackingMode: String = "auto"
    var savedCycleLength: Int = 28
    var savedPeriodLength: Int = 5
}

// MARK: - Helper Functions
func normalizeDate(_ date: Date) -> Date {
    Calendar.current.startOfDay(for: date)
}

func daysBetween(_ start: Date, _ end: Date) -> Int {
    Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
}

// MARK: - ViewModel
@MainActor
class PeriodViewModel: ObservableObject {
    @Published var uiState = PeriodUiState()
    @Published var currentDiary: DiaryEntry? = nil

    private var modelContext: ModelContext?

    init() {
        let defaults = UserDefaults.standard
        uiState.hasSetup = defaults.bool(forKey: "has_setup")
        uiState.trackingMode = defaults.string(forKey: "tracking_mode") ?? "auto"
        uiState.savedCycleLength = defaults.integer(forKey: "cycle_length").clamped(to: 15...60, default: 28)
        uiState.savedPeriodLength = defaults.integer(forKey: "period_length").clamped(to: 1...15, default: 5)
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadRecords()
    }

    func loadRecords() {
        guard let ctx = modelContext else { return }
        let descriptor = FetchDescriptor<PeriodRecord>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        do {
            let records = try ctx.fetch(descriptor)
            let latest = records.first
            recalculate(records: records, latest: latest)
        } catch {
            print("Failed to fetch records: \(error)")
        }
    }

    // MARK: - Core Calculation
    private func recalculate(records: [PeriodRecord], latest: PeriodRecord?) {
        guard let latest = latest else {
            uiState.records = records
            uiState.latestRecord = nil
            uiState.isInPeriod = false
            uiState.hasActivePeriod = false
            uiState.currentPhase = "请记录经期"
            uiState.cycleDay = 0
            uiState.cycleProgress = 0
            uiState.periodProgress = 0
            return
        }

        let today = normalizeDate(Date())
        let start = normalizeDate(latest.startDate)
        let daysSinceStart = daysBetween(start, today)

        let periodEnd: Date
        if let endDate = latest.endDate {
            periodEnd = normalizeDate(endDate)
        } else {
            let predicted = Calendar.current.date(byAdding: .day, value: latest.periodLength - 1, to: start)!
            periodEnd = max(predicted, today)
        }

        let hasActivePeriod = latest.endDate == nil
        let isInPeriod = hasActivePeriod && today >= start && today <= periodEnd

        let cycleLength = latest.cycleLength
        let periodLength = latest.periodLength
        let cycleDay = daysSinceStart >= 0 ? (daysSinceStart % cycleLength) + 1 : 0

        let daysUntilPeriodEnd = isInPeriod ? max(daysBetween(today, periodEnd), 0) : 0

        let nextPeriodStart: Date
        if daysSinceStart < cycleLength {
            nextPeriodStart = Calendar.current.date(byAdding: .day, value: cycleLength, to: start)!
        } else {
            let cyclesPassed = daysSinceStart / cycleLength
            nextPeriodStart = Calendar.current.date(byAdding: .day, value: (cyclesPassed + 1) * cycleLength, to: start)!
        }
        let daysUntilNextPeriod = isInPeriod ? 0 : max(daysBetween(today, nextPeriodStart), 0)

        let effectiveDay = daysSinceStart >= 0 ? daysSinceStart % cycleLength : 0
        let phase: String
        if daysSinceStart < 0 {
            phase = "等待中"
        } else if isInPeriod {
            phase = "经期第\(daysBetween(start, today) + 1)天"
        } else if effectiveDay < cycleLength / 2 - 2 {
            phase = "安全期"
        } else if effectiveDay < cycleLength / 2 + 2 {
            phase = "排卵期"
        } else if effectiveDay < cycleLength - 3 {
            phase = "黄体期"
        } else {
            phase = "经期将至"
        }

        let cycleProgress: Float = cycleLength > 0 ? Float(effectiveDay) / Float(cycleLength) : 0
        var periodProgress: Float = 0
        if isInPeriod && periodLength > 0 {
            let raw = Float(daysBetween(start, today)) / Float(periodLength)
            periodProgress = raw > 0.9 ? 0.9 : raw
        }

        let completedCount = records.filter { $0.endDate != nil }.count

        uiState.records = records
        uiState.latestRecord = latest
        uiState.isInPeriod = isInPeriod
        uiState.hasActivePeriod = hasActivePeriod
        uiState.daysUntilPeriodEnd = daysUntilPeriodEnd
        uiState.daysUntilNextPeriod = daysUntilNextPeriod
        uiState.currentPhase = phase
        uiState.cycleDay = cycleDay
        uiState.cycleProgress = cycleProgress
        uiState.periodProgress = periodProgress
        uiState.isFirstRecord = completedCount < 2
    }

    // MARK: - User Actions
    func addPeriodRecord(startDate: Date) {
        guard let ctx = modelContext else { return }
        let normalized = normalizeDate(startDate)
        let record = PeriodRecord(
            startDate: normalized,
            cycleLength: uiState.savedCycleLength,
            periodLength: uiState.savedPeriodLength
        )
        ctx.insert(record)
        try? ctx.save()
        loadRecords()
        SyncManager.shared.triggerImmediateSync()
    }

    func endPeriod(endDate: Date) {
        guard let ctx = modelContext else { return }
        guard let latest = uiState.latestRecord, latest.endDate == nil else { return }
        let normalizedEnd = normalizeDate(endDate)
        let normalizedStart = normalizeDate(latest.startDate)
        let finalEnd = normalizedEnd < normalizedStart ? normalizedStart : normalizedEnd
        let actualPeriodLength = max(1, min(daysBetween(normalizedStart, finalEnd) + 1, 15))

        latest.endDate = finalEnd
        latest.periodLength = actualPeriodLength
        try? ctx.save()
        loadRecords()
        SyncManager.shared.triggerImmediateSync()
    }

    func updateSelectedDate(_ date: Date) {
        uiState.selectedDate = normalizeDate(date)
        loadDiaryForSelectedDate()
    }

    func changeMonth(_ delta: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: delta, to: uiState.currentMonth) {
            uiState.currentMonth = newMonth
        }
    }

    func deleteRecord(_ record: PeriodRecord) {
        guard let ctx = modelContext else { return }
        ctx.delete(record)
        try? ctx.save()
        loadRecords()
        SyncManager.shared.triggerImmediateSync()
    }

    func resetLatestRecord() {
        guard let ctx = modelContext else { return }
        if let latest = uiState.latestRecord {
            ctx.delete(latest)
            try? ctx.save()
            loadRecords()
            SyncManager.shared.triggerImmediateSync()
        }
    }

    func saveCycleSettings(cycleLength: Int, periodLength: Int) {
        let cycle = max(15, min(cycleLength, 60))
        let period = max(1, min(periodLength, 15))
        UserDefaults.standard.set(true, forKey: "has_setup")
        UserDefaults.standard.set(cycle, forKey: "cycle_length")
        UserDefaults.standard.set(period, forKey: "period_length")
        uiState.hasSetup = true
        uiState.savedCycleLength = cycle
        uiState.savedPeriodLength = period
        SyncManager.shared.triggerImmediateSync()
    }

    func saveTrackingMode(_ mode: String) {
        UserDefaults.standard.set(mode, forKey: "tracking_mode")
        UserDefaults.standard.set(true, forKey: "has_setup")
        uiState.trackingMode = mode
        uiState.hasSetup = true
        SyncManager.shared.triggerImmediateSync()
    }

    // MARK: - Diary
    func saveDiary(_ entry: DiaryEntry) {
        guard let ctx = modelContext else { return }
        entry.date = normalizeDate(entry.date)
        ctx.insert(entry)
        try? ctx.save()
        SyncManager.shared.triggerImmediateSync()
    }

    private func loadDiaryForSelectedDate() {
        guard let ctx = modelContext else { return }
        let date = uiState.selectedDate
        let descriptor = FetchDescriptor<DiaryEntry>()
        if let entries = try? ctx.fetch(descriptor) {
            currentDiary = entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
        }
    }
}

// MARK: - Int Extension
extension Int {
    func clamped(to range: ClosedRange<Int>, default defaultValue: Int) -> Int {
        if self == 0 { return defaultValue }
        return max(range.lowerBound, min(self, range.upperBound))
    }
}
