import SwiftUI
import SwiftData

struct SecretUiState {
    var records: [SecretRecord] = []
    var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    var currentMonth: Date = Date()
    var currentRecord: SecretRecord? = nil
    var defaultHadSex: Bool = false
}

@MainActor
class SecretViewModel: ObservableObject {
    @Published var uiState = SecretUiState()

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadRecords()
    }

    func loadRecords() {
        guard let ctx = modelContext else { return }
        let descriptor = FetchDescriptor<SecretRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            let records = try ctx.fetch(descriptor)
            uiState.records = records
            loadRecordForSelectedDate()
        } catch {
            print("Failed to fetch secret records: \(error)")
        }
    }

    func updateSelectedDate(_ date: Date) {
        uiState.selectedDate = Calendar.current.startOfDay(for: date)
        loadRecordForSelectedDate()
    }

    func changeMonth(_ offset: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: offset, to: uiState.currentMonth) {
            uiState.currentMonth = newMonth
        }
    }

    private func loadRecordForSelectedDate() {
        let date = uiState.selectedDate
        uiState.currentRecord = uiState.records.first {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
        uiState.defaultHadSex = uiState.records.contains { $0.hadSex }
    }

    func saveRecord(_ record: SecretRecord) {
        guard let ctx = modelContext else { return }
        ctx.insert(record)
        try? ctx.save()
        loadRecords()
    }

    func deleteRecordForDate(_ date: Date) {
        guard let ctx = modelContext else { return }
        let normalized = Calendar.current.startOfDay(for: date)
        if let record = uiState.records.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: normalized)
        }) {
            ctx.delete(record)
            try? ctx.save()
            loadRecords()
        }
    }
}
