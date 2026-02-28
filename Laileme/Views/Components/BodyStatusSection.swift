import SwiftUI

// MARK: - Data Options
struct LevelOption: Identifiable { let id = UUID(); let value: Int; let label: String }
struct StringOption: Identifiable { let id = UUID(); let value: String; let label: String; var color: Color? = nil }

let flowLevelOptions = [LevelOption(value: 0, label: "未记录"), LevelOption(value: 1, label: "少"), LevelOption(value: 2, label: "中"), LevelOption(value: 3, label: "多")]
let flowColorOptions = [StringOption(value: "", label: "未记录", color: Color(hex: "E0E0E0")), StringOption(value: "light_red", label: "浅红", color: Color(hex: "FF8A80")), StringOption(value: "red", label: "正红", color: Color(hex: "FF1744")), StringOption(value: "dark_red", label: "深红", color: Color(hex: "B71C1C")), StringOption(value: "brown", label: "棕色", color: Color(hex: "795548")), StringOption(value: "black", label: "黑色", color: Color(hex: "424242"))]
let painLevelOptions = [LevelOption(value: 0, label: "无"), LevelOption(value: 1, label: "轻微"), LevelOption(value: 2, label: "中等"), LevelOption(value: 3, label: "较重"), LevelOption(value: 4, label: "严重")]
let threeLevelOptions = [LevelOption(value: 0, label: "无"), LevelOption(value: 1, label: "轻微"), LevelOption(value: 2, label: "明显"), LevelOption(value: 3, label: "严重")]
let digestiveOptions = [LevelOption(value: 0, label: "正常"), LevelOption(value: 1, label: "不适"), LevelOption(value: 2, label: "腹泻"), LevelOption(value: 3, label: "便秘")]
let fatigueOptions = [LevelOption(value: 0, label: "充沛"), LevelOption(value: 1, label: "正常"), LevelOption(value: 2, label: "有点累"), LevelOption(value: 3, label: "很疲惫")]
let skinOptions = [StringOption(value: "", label: "未记录"), StringOption(value: "good", label: "很好"), StringOption(value: "normal", label: "正常"), StringOption(value: "oily", label: "出油"), StringOption(value: "acne", label: "长痘"), StringOption(value: "dry", label: "干燥")]
let appetiteOptions = [LevelOption(value: 0, label: "正常"), LevelOption(value: 1, label: "增加"), LevelOption(value: 2, label: "减少")]
let dischargeOptions = [StringOption(value: "", label: "未记录"), StringOption(value: "none", label: "无"), StringOption(value: "clear", label: "透明"), StringOption(value: "white", label: "白色"), StringOption(value: "yellow", label: "黄色"), StringOption(value: "sticky", label: "粘稠")]

// MARK: - Body Status Section
struct BodyStatusSection: View {
    @Binding var flowLevel: Int
    @Binding var flowColor: String
    @Binding var painLevel: Int
    @Binding var breastPain: Int
    @Binding var digestive: Int
    @Binding var backPain: Int
    @Binding var headache: Int
    @Binding var fatigue: Int
    @Binding var skinCondition: String
    @Binding var temperature: String
    @Binding var appetite: Int
    @Binding var discharge: String
    var initialExpanded: Bool = false

    @State private var expanded: Bool = false

    var body: some View {
        let recordedCount = [flowLevel > 0, !flowColor.isEmpty, painLevel > 0, breastPain > 0, digestive > 0, backPain > 0, headache > 0, fatigue > 0, !skinCondition.isEmpty, !temperature.isEmpty, appetite > 0, !discharge.isEmpty].filter { $0 }.count

        VStack(alignment: .leading) {
            // 标题栏
            Button(action: { withAnimation { expanded.toggle() } }) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.accentTeal)
                        Text("身体状态")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                        if recordedCount > 0 {
                            Text("已记录 \(recordedCount) 项")
                                .font(.system(size: 9))
                                .foregroundColor(AppColors.accentTeal)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.accentTeal.opacity(0.15))
                                .cornerRadius(8)
                        }
                    }
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textHint)
                }
            }

            if expanded {
                VStack(spacing: 10) {
                    StatusCategory(icon: "drop.fill", title: "月经量", color: AppColors.periodRed) {
                        LevelSelector(options: flowLevelOptions, selectedValue: $flowLevel, activeColor: AppColors.periodRed)
                    }
                    StatusCategory(icon: "paintpalette.fill", title: "经血颜色", color: AppColors.periodRed) {
                        ColorSelector(options: flowColorOptions, selectedValue: $flowColor)
                    }
                    StatusCategory(icon: "bolt.fill", title: "痛经程度", color: AppColors.accentOrange) {
                        LevelSelector(options: painLevelOptions, selectedValue: $painLevel, activeColor: AppColors.accentOrange)
                    }
                    StatusCategory(icon: "heart.fill", title: "胸部胀痛", color: AppColors.primaryPink) {
                        LevelSelector(options: threeLevelOptions, selectedValue: $breastPain, activeColor: AppColors.primaryPink)
                    }
                    StatusCategory(icon: "fork.knife", title: "肠胃状态", color: AppColors.accentTeal) {
                        LevelSelector(options: digestiveOptions, selectedValue: $digestive, activeColor: AppColors.accentTeal)
                    }
                    StatusCategory(icon: "figure.walk", title: "腰腹痛", color: AppColors.accentOrange) {
                        LevelSelector(options: threeLevelOptions, selectedValue: $backPain, activeColor: AppColors.accentOrange)
                    }
                    StatusCategory(icon: "brain.head.profile", title: "头痛", color: Color(hex: "9575CD")) {
                        LevelSelector(options: threeLevelOptions, selectedValue: $headache, activeColor: Color(hex: "9575CD"))
                    }
                    StatusCategory(icon: "battery.75percent", title: "精力/疲劳", color: AppColors.accentBlue) {
                        LevelSelector(options: fatigueOptions, selectedValue: $fatigue, activeColor: AppColors.accentBlue)
                    }
                    StatusCategory(icon: "face.smiling", title: "皮肤状态", color: Color(hex: "FF8A65")) {
                        StringSelector(options: skinOptions, selectedValue: $skinCondition, activeColor: Color(hex: "FF8A65"))
                    }
                    StatusCategory(icon: "thermometer.medium", title: "基础体温", color: AppColors.periodRed) {
                        TemperatureInput(value: $temperature)
                    }
                    StatusCategory(icon: "fork.knife.circle", title: "食欲", color: AppColors.accentTeal) {
                        LevelSelector(options: appetiteOptions, selectedValue: $appetite, activeColor: AppColors.accentTeal)
                    }
                    StatusCategory(icon: "drop.triangle.fill", title: "分泌物", color: AppColors.accentBlue) {
                        StringSelector(options: dischargeOptions, selectedValue: $discharge, activeColor: AppColors.accentBlue)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onAppear { expanded = initialExpanded }
    }
}

// MARK: - Sub Components
struct StatusCategory<Content: View>: View {
    let icon: String; let title: String; let color: Color
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 12)).foregroundColor(color)
                Text(title).font(.system(size: 11, weight: .medium)).foregroundColor(AppColors.textPrimary)
            }
            content()
        }
    }
}

struct LevelSelector: View {
    let options: [LevelOption]
    @Binding var selectedValue: Int
    let activeColor: Color
    var body: some View {
        HStack(spacing: 6) {
            ForEach(options) { opt in
                let selected = selectedValue == opt.value
                Button(action: { selectedValue = selected ? 0 : opt.value }) {
                    Text(opt.label)
                        .font(.system(size: 10, weight: selected ? .bold : .regular))
                        .foregroundColor(selected ? activeColor : AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(selected ? activeColor.opacity(0.18) : Color(hex: "F5F5F5"))
                        .cornerRadius(8)
                        .overlay(selected ? RoundedRectangle(cornerRadius: 8).stroke(activeColor.opacity(0.5), lineWidth: 1) : nil)
                }
            }
        }
    }
}

struct StringSelector: View {
    let options: [StringOption]
    @Binding var selectedValue: String
    let activeColor: Color
    var body: some View {
        HStack(spacing: 6) {
            ForEach(options) { opt in
                let selected = selectedValue == opt.value
                Button(action: { selectedValue = selected ? "" : opt.value }) {
                    Text(opt.label)
                        .font(.system(size: 10, weight: selected ? .bold : .regular))
                        .foregroundColor(selected ? activeColor : AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(selected ? activeColor.opacity(0.18) : Color(hex: "F5F5F5"))
                        .cornerRadius(8)
                        .overlay(selected ? RoundedRectangle(cornerRadius: 8).stroke(activeColor.opacity(0.5), lineWidth: 1) : nil)
                }
            }
        }
    }
}

struct ColorSelector: View {
    let options: [StringOption]
    @Binding var selectedValue: String
    var body: some View {
        HStack(spacing: 6) {
            ForEach(options) { opt in
                let selected = selectedValue == opt.value
                Button(action: { selectedValue = selected ? "" : opt.value }) {
                    VStack(spacing: 2) {
                        if let c = opt.color, !opt.value.isEmpty {
                            Circle().fill(c).frame(width: 14, height: 14)
                        }
                        Text(opt.label)
                            .font(.system(size: 9, weight: selected ? .bold : .regular))
                            .foregroundColor(selected ? AppColors.periodRed : AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(selected ? AppColors.periodRed.opacity(0.1) : Color(hex: "F5F5F5"))
                    .cornerRadius(8)
                    .overlay(selected ? RoundedRectangle(cornerRadius: 8).stroke(AppColors.periodRed.opacity(0.5), lineWidth: 1) : nil)
                }
            }
        }
    }
}

struct TemperatureInput: View {
    @Binding var value: String
    let quickTemps = ["36.2", "36.5", "36.8", "37.0"]
    var body: some View {
        HStack {
            TextField("例如 36.5", text: $value)
                .font(.system(size: 12))
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 80)
            Text("°C").font(.system(size: 12)).foregroundColor(AppColors.textSecondary)
            ForEach(quickTemps, id: \.self) { temp in
                Button(action: { value = temp }) {
                    Text(temp)
                        .font(.system(size: 9))
                        .foregroundColor(value == temp ? AppColors.periodRed : AppColors.textHint)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(value == temp ? AppColors.periodRed.opacity(0.18) : Color(hex: "F0F0F0"))
                        .cornerRadius(6)
                }
            }
        }
    }
}
