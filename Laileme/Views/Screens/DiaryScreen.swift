import SwiftUI
import SwiftData

struct DiaryScreen: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    let date: Date
    var existingEntry: DiaryEntry?

    @State private var mood: String = ""
    @State private var notes: String = ""
    @State private var flowLevel: Int = 0
    @State private var flowColor: String = ""
    @State private var painLevel: Int = 0
    @State private var breastPain: Int = 0
    @State private var digestive: Int = 0
    @State private var backPain: Int = 0
    @State private var headache: Int = 0
    @State private var fatigue: Int = 0
    @State private var skinCondition: String = ""
    @State private var temperature: String = ""
    @State private var appetite: Int = 0
    @State private var discharge: String = ""

    private let moods = [
        ("😊", "开心"), ("😌", "平静"), ("😢", "难过"),
        ("😡", "烦躁"), ("😰", "焦虑"), ("😴", "困倦"),
        ("🥰", "甜蜜"), ("😣", "不适")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 日期
                    let formatter = DateFormatter()
                    let _ = formatter.dateFormat = "M月d日 EEEE"
                    let _ = formatter.locale = Locale(identifier: "zh_CN")
                    Text(formatter.string(from: date))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    // 心情选择
                    VStack(alignment: .leading, spacing: 8) {
                        Text("今日心情")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                            ForEach(moods, id: \.1) { emoji, label in
                                Button(action: { mood = label }) {
                                    VStack(spacing: 2) {
                                        Text(emoji).font(.system(size: 24))
                                        Text(label).font(.system(size: 10))
                                            .foregroundColor(mood == label ? AppColors.primaryPink : AppColors.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(mood == label ? AppColors.primaryPink.opacity(0.1) : Color(hex: "F5F5F5"))
                                    .cornerRadius(10)
                                    .overlay(mood == label ? RoundedRectangle(cornerRadius: 10).stroke(AppColors.primaryPink, lineWidth: 1) : nil)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)

                    // 身体状态
                    VStack(alignment: .leading) {
                        BodyStatusSection(
                            flowLevel: $flowLevel,
                            flowColor: $flowColor,
                            painLevel: $painLevel,
                            breastPain: $breastPain,
                            digestive: $digestive,
                            backPain: $backPain,
                            headache: $headache,
                            fatigue: $fatigue,
                            skinCondition: $skinCondition,
                            temperature: $temperature,
                            appetite: $appetite,
                            discharge: $discharge,
                            initialExpanded: true
                        )
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)

                    // 日记
                    VStack(alignment: .leading, spacing: 8) {
                        Text("日记")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                        TextEditor(text: $notes)
                            .frame(minHeight: 120)
                            .font(.system(size: 13))
                            .padding(8)
                            .background(Color(hex: "F9F9F9"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "E8E8E8"), lineWidth: 1)
                            )
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                }
                .padding(16)
            }
            .background(AppColors.background)
            .navigationTitle("记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") { save() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear { loadExisting() }
        }
    }

    private func loadExisting() {
        guard let entry = existingEntry else { return }
        mood = entry.mood
        notes = entry.notes
        flowLevel = entry.flowLevel
        flowColor = entry.flowColor
        painLevel = entry.painLevel
        breastPain = entry.breastPain
        digestive = entry.digestive
        backPain = entry.backPain
        headache = entry.headache
        fatigue = entry.fatigue
        skinCondition = entry.skinCondition
        temperature = entry.temperature
        appetite = entry.appetite
        discharge = entry.discharge
    }

    private func save() {
        if let existing = existingEntry {
            existing.mood = mood
            existing.notes = notes
            existing.flowLevel = flowLevel
            existing.flowColor = flowColor
            existing.painLevel = painLevel
            existing.breastPain = breastPain
            existing.digestive = digestive
            existing.backPain = backPain
            existing.headache = headache
            existing.fatigue = fatigue
            existing.skinCondition = skinCondition
            existing.temperature = temperature
            existing.appetite = appetite
            existing.discharge = discharge
        } else {
            let entry = DiaryEntry(
                date: date, mood: mood, notes: notes,
                flowLevel: flowLevel, flowColor: flowColor,
                painLevel: painLevel, breastPain: breastPain,
                digestive: digestive, backPain: backPain,
                headache: headache, fatigue: fatigue,
                skinCondition: skinCondition, temperature: temperature,
                appetite: appetite, discharge: discharge
            )
            modelContext.insert(entry)
        }
        try? modelContext.save()
        SyncManager.shared.triggerImmediateSync()
        dismiss()
    }
}
