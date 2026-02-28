import SwiftUI
import SwiftData

struct SecretDiaryScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SecretViewModel()
    @Environment(\.modelContext) private var modelContext

    @State private var hadSex: Bool = false
    @State private var protection: String = ""
    @State private var feeling: Int = 0
    @State private var mood: String = ""
    @State private var notes: String = ""

    private let protectionOptions = [
        ("none", "无"), ("condom", "避孕套"), ("pill", "避孕药"),
        ("iud", "节育环"), ("safe_period", "安全期"), ("other", "其他")
    ]

    private let moodOptions = [
        ("🥰", "甜蜜"), ("😊", "开心"), ("😌", "满足"),
        ("😳", "害羞"), ("😐", "一般"), ("😔", "失望")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 日期显示
                    let formatter = DateFormatter()
                    let _ = formatter.dateFormat = "M月d日 EEEE"
                    let _ = formatter.locale = Locale(identifier: "zh_CN")
                    Text(formatter.string(from: viewModel.uiState.selectedDate))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    // 是否有亲密
                    VStack(alignment: .leading, spacing: 8) {
                        Text("今天有亲密接触吗？")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                        Toggle("", isOn: $hadSex)
                            .labelsHidden()
                            .tint(AppColors.primaryPink)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)

                    if hadSex {
                        // 避孕方式
                        VStack(alignment: .leading, spacing: 8) {
                            Text("避孕方式")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(protectionOptions, id: \.0) { value, label in
                                    Button(action: { protection = value }) {
                                        Text(label)
                                            .font(.system(size: 12))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(protection == value ? AppColors.primaryPink.opacity(0.12) : Color(hex: "F5F5F5"))
                                            .foregroundColor(protection == value ? AppColors.primaryPink : AppColors.textSecondary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)

                        // 体验评分
                        VStack(alignment: .leading, spacing: 8) {
                            Text("体验评分")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                            HStack(spacing: 8) {
                                ForEach(1...5, id: \.self) { star in
                                    Button(action: { feeling = star }) {
                                        Image(systemName: star <= feeling ? "star.fill" : "star")
                                            .font(.system(size: 24))
                                            .foregroundColor(star <= feeling ? AppColors.accentOrange : AppColors.textHint)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)

                        // 心情
                        VStack(alignment: .leading, spacing: 8) {
                            Text("伴随心情")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(moodOptions, id: \.1) { emoji, label in
                                    Button(action: { mood = label }) {
                                        HStack(spacing: 4) {
                                            Text(emoji)
                                            Text(label).font(.system(size: 12))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(mood == label ? AppColors.primaryPink.opacity(0.12) : Color(hex: "F5F5F5"))
                                        .foregroundColor(mood == label ? AppColors.primaryPink : AppColors.textSecondary)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                    }

                    // 私密日记
                    VStack(alignment: .leading, spacing: 8) {
                        Text("私密日记")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                            .font(.system(size: 13))
                            .padding(8)
                            .background(Color(hex: "F9F9F9"))
                            .cornerRadius(10)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                }
                .padding(16)
            }
            .background(AppColors.background)
            .navigationTitle("私密日记")
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
            .onAppear {
                viewModel.setModelContext(modelContext)
                loadExisting()
            }
        }
    }

    private func loadExisting() {
        guard let record = viewModel.uiState.currentRecord else {
            hadSex = viewModel.uiState.defaultHadSex
            return
        }
        hadSex = record.hadSex
        protection = record.protection
        feeling = record.feeling
        mood = record.mood
        notes = record.notes
    }

    private func save() {
        let record = SecretRecord(
            date: viewModel.uiState.selectedDate,
            hadSex: hadSex,
            protection: protection,
            feeling: feeling,
            mood: mood,
            notes: notes
        )
        viewModel.saveRecord(record)
        dismiss()
    }
}
