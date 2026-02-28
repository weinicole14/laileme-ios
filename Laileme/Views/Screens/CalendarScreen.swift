import SwiftUI
import SwiftData

struct CalendarScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PeriodRecord.startDate, order: .reverse) private var records: [PeriodRecord]
    @Query(sort: \DiaryEntry.date, order: .reverse) private var diaryEntries: [DiaryEntry]

    @State private var currentMonth = Date()
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 标题
                Text("日历")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top, 50)

                // 日历组件
                CalendarGridView(
                    currentMonth: $currentMonth,
                    selectedDate: $selectedDate,
                    records: records
                )
                .padding(.horizontal, 12)
                .padding(16)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
                .padding(.horizontal, 16)

                // 图例
                LegendView()
                    .padding(.horizontal, 16)

                // 选中日期详情
                DayDetailCard(date: selectedDate, records: records, diaryEntries: diaryEntries)
                    .padding(.horizontal, 16)

                Spacer(minLength: 80)
            }
        }
        .background(AppColors.background)
    }
}

// MARK: - 日历网格
struct CalendarGridView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    let records: [PeriodRecord]

    private let weekDays = ["一", "二", "三", "四", "五", "六", "日"]
    private let cal = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            // 月份导航
            HStack {
                Button(action: { changeMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primaryPink)
                        .frame(width: 32, height: 32)
                        .background(AppColors.primaryPink.opacity(0.1))
                        .cornerRadius(8)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("\(cal.component(.year, from: currentMonth))年")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                    Text("\(cal.component(.month, from: currentMonth))月")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }
                Spacer()
                Button(action: { changeMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primaryPink)
                        .frame(width: 32, height: 32)
                        .background(AppColors.primaryPink.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            // 星期标题
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    Text(weekDays[i])
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(i >= 5 ? AppColors.weekendText : AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)

            // 日期网格（固定6行）
            let days = buildDays()
            let padded = days + Array(repeating: DayData.empty, count: max(42 - days.count, 0))
            ForEach(0..<6, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { col in
                        let idx = row * 7 + col
                        if idx < padded.count {
                            DayCellView(
                                day: padded[idx],
                                isSelected: padded[idx].date.map { cal.isDate($0, inSameDayAs: selectedDate) } ?? false,
                                onTap: { if let d = padded[idx].date { selectedDate = d } }
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private func changeMonth(_ delta: Int) {
        if let newMonth = cal.date(byAdding: .month, value: delta, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func buildDays() -> [DayData] {
        var result: [DayData] = []
        var comp = cal.dateComponents([.year, .month], from: currentMonth)
        comp.day = 1
        guard let firstOfMonth = cal.date(from: comp) else { return result }

        let year = comp.year!
        let month = comp.month!
        var firstWeekday = cal.component(.weekday, from: firstOfMonth) - 2 // 周一=0
        if firstWeekday < 0 { firstWeekday += 7 }
        let daysInMonth = cal.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30
        let today = cal.startOfDay(for: Date())

        // 月初空白
        for _ in 0..<firstWeekday {
            result.append(.empty)
        }

        for day in 1...daysInMonth {
            comp.day = day
            guard let date = cal.date(from: comp) else { continue }
            let normalizedDate = cal.startOfDay(for: date)
            let weekday = cal.component(.weekday, from: date)
            let isWeekend = weekday == 1 || weekday == 7
            let isToday = cal.isDate(normalizedDate, inSameDayAs: today)
            let status = calcPeriodStatus(date: normalizedDate)
            let lunar = LunarCalendar.shared.getLunarInfo(year: year, month: month, day: day)

            result.append(DayData(
                day: day,
                date: normalizedDate,
                isPeriod: status.isPeriod,
                isPredictPeriod: status.isPredictPeriod,
                isOvulation: status.isOvulation,
                isFertile: status.isFertile,
                isToday: isToday,
                isWeekend: isWeekend,
                lunarText: lunar.lunarText,
                isHoliday: lunar.isHoliday
            ))
        }
        return result
    }

    private func calcPeriodStatus(date: Date) -> PeriodStatus {
        if records.isEmpty { return PeriodStatus() }
        let normalizedDate = cal.startOfDay(for: date)

        for record in records {
            let start = cal.startOfDay(for: record.startDate)
            let end: Date
            if let endDate = record.endDate {
                end = cal.startOfDay(for: endDate)
            } else {
                let predicted = cal.date(byAdding: .day, value: record.periodLength - 1, to: start)!
                let today = cal.startOfDay(for: Date())
                end = max(predicted, today)
            }
            if normalizedDate >= start && normalizedDate <= end {
                return PeriodStatus(isPeriod: true)
            }
        }

        let hasCompleted = records.contains { $0.endDate != nil }
        if !hasCompleted { return PeriodStatus() }

        guard let latest = records.first(where: { $0.endDate != nil }) else { return PeriodStatus() }
        let start = cal.startOfDay(for: latest.startDate)
        let diff = cal.dateComponents([.day], from: start, to: normalizedDate).day ?? 0
        if diff < 0 { return PeriodStatus() }

        let cycleLen = latest.cycleLength
        let periodLen = latest.periodLength
        if cycleLen <= 0 || periodLen <= 0 { return PeriodStatus() }

        let dayInCycle = diff % cycleLen
        let ovulationDay = max(cycleLen - 14, periodLen + 1)
        let fertileStart = max(ovulationDay - 5, periodLen)
        let fertileEnd = min(ovulationDay + 1, cycleLen - 1)

        if diff < cycleLen {
            if dayInCycle == ovulationDay { return PeriodStatus(isOvulation: true) }
            if dayInCycle >= fertileStart && dayInCycle <= fertileEnd { return PeriodStatus(isFertile: true) }
            return PeriodStatus()
        }

        if dayInCycle < periodLen { return PeriodStatus(isPredictPeriod: true) }
        if dayInCycle == ovulationDay { return PeriodStatus(isOvulation: true) }
        if dayInCycle >= fertileStart && dayInCycle <= fertileEnd { return PeriodStatus(isFertile: true) }
        return PeriodStatus()
    }
}

// MARK: - 数据结构
struct DayData {
    var day: Int?
    var date: Date?
    var isPeriod = false
    var isPredictPeriod = false
    var isOvulation = false
    var isFertile = false
    var isToday = false
    var isWeekend = false
    var lunarText = ""
    var isHoliday = false

    static let empty = DayData()
}

struct PeriodStatus {
    var isPeriod = false
    var isPredictPeriod = false
    var isOvulation = false
    var isFertile = false
}

// MARK: - 日期格子
struct DayCellView: View {
    let day: DayData
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let dayNum = day.day {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                        .frame(width: 32, height: 32)
                    if isSelected && !day.isToday {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.primaryPink, lineWidth: 1)
                            .frame(width: 32, height: 32)
                    }
                    VStack(spacing: 0) {
                        // 顶部小圆点
                        if day.isPeriod && !day.isToday {
                            Circle().fill(AppColors.periodRed).frame(width: 4, height: 4)
                        } else if day.isFertile && !day.isToday {
                            Circle().fill(AppColors.fertileGreen).frame(width: 4, height: 4)
                        } else if day.isOvulation && !day.isToday {
                            Circle().fill(AppColors.ovulationOrange).frame(width: 4, height: 4)
                        } else {
                            Spacer().frame(height: 4)
                        }
                        // 日期数字
                        Text(day.isToday ? "今" : "\(dayNum)")
                            .font(.system(size: day.lunarText.isEmpty ? 12 : 10, weight: day.isToday || isSelected ? .bold : .regular))
                            .foregroundColor(day.isToday ? .white : (day.isWeekend ? AppColors.weekendText : AppColors.textPrimary))
                            .lineSpacing(0)
                        // 农历
                        if !day.lunarText.isEmpty {
                            Text(day.lunarText)
                                .font(.system(size: 6, weight: day.isHoliday ? .bold : .regular))
                                .foregroundColor(day.isToday ? .white.opacity(0.85) : (day.isHoliday ? AppColors.periodRed : AppColors.textSecondary))
                                .lineLimit(1)
                        }
                    }
                }
                .onTapGesture(perform: onTap)
            } else {
                Spacer().frame(width: 32, height: 32)
            }
        }
        .padding(1)
    }

    private var backgroundColor: Color {
        if day.isToday { return AppColors.todayGreen }
        if day.isPeriod { return AppColors.periodRed.opacity(0.2) }
        if day.isPredictPeriod { return AppColors.predictPeriod.opacity(0.3) }
        if day.isOvulation { return AppColors.ovulationOrange.opacity(0.3) }
        if day.isFertile { return AppColors.fertileGreen.opacity(0.25) }
        if isSelected { return AppColors.primaryPink.opacity(0.1) }
        return .clear
    }
}

// MARK: - 图例
struct LegendView: View {
    var body: some View {
        HStack(spacing: 16) {
            legendItem(color: AppColors.periodRed.opacity(0.2), text: "经期")
            legendItem(color: AppColors.predictPeriod.opacity(0.3), text: "预测经期")
            legendItem(color: AppColors.fertileGreen.opacity(0.25), text: "易孕期")
            legendItem(color: AppColors.ovulationOrange.opacity(0.3), text: "排卵日")
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(text)
                .font(.system(size: 9))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - 日期详情
struct DayDetailCard: View {
    let date: Date
    let records: [PeriodRecord]
    let diaryEntries: [DiaryEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let formatter = DateFormatter()
            let _ = formatter.dateFormat = "M月d日 EEEE"
            let _ = formatter.locale = Locale(identifier: "zh_CN")

            Text(formatter.string(from: date))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            let entry = diaryEntries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
            if let entry = entry, !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
            } else {
                Text("暂无记录")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textHint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
}
