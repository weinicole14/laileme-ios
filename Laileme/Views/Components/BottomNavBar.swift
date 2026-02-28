import SwiftUI

struct BottomNavBar: View {
    @Binding var selectedTab: ContentView.Tab
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack {
            ForEach(ContentView.Tab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20))
                        Text(tab.rawValue)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(selectedTab == tab ? AppColors.navSelected : AppColors.navUnselected)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 5, y: -2)
        )
    }
}
