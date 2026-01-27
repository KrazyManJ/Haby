
import SwiftUI

fileprivate enum TabLeadingAction {
    case Streak
    case AddHabit
}


fileprivate struct TabInfo : Identifiable {
    var id: Int { tag }
    
    let tag: Int
    @Localizable var tabItemLabel: String
    let tabItemImage: String
    @Localizable var navigationTitle: String
    let leadingIcon: TabLeadingAction
    let accessibilityIdentifier: AccessibilityTag
    let content: () -> AnyView
}

fileprivate let TAB_INFO: [TabInfo] = [
    TabInfo(
        tag: 0,
        tabItemLabel: "Daily",
        tabItemImage: "sun.min",
        navigationTitle: "Daily Habits",
        leadingIcon: .Streak,
        accessibilityIdentifier: .MainTabView_DailyTabButton,
        content: { AnyView(DailyView()) }
    ),
    TabInfo(
        tag: 1,
        tabItemLabel: "Weekly",
        tabItemImage: "calendar",
        navigationTitle: "Weekly Habits",
        leadingIcon: .Streak,
        accessibilityIdentifier: .MainTabView_WeeklyTabButton,
        content: { AnyView(WeeklyView()) }
    ),
    TabInfo(
        tag: 2,
        tabItemLabel: "Habits",
        tabItemImage: "book",
        navigationTitle: "Habits",
        leadingIcon: .AddHabit,
        accessibilityIdentifier: .MainTabView_HabitsTabButton,
        content: { AnyView(HabitManagementView()) }
    )
]

private struct MainTabViewRefreshKey: EnvironmentKey {
    static let defaultValue: () -> Void = { }
}

extension EnvironmentValues {
    var mainTabViewRefresh: () -> Void {
        get { self[MainTabViewRefreshKey.self] }
        set { self[MainTabViewRefreshKey.self] = newValue }
    }
}


struct MainTabView : View {
    
    @State private var viewModel: MainTabViewModel = MainTabViewModel()
    
    @State var isAddEditHabitViewPresented = false
    
    @State private var selectedTab: Int = 0
    @State private var habitsRefreshID = UUID()
    
    private var selectedTabInfo: TabInfo { TAB_INFO[selectedTab] }
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = Colors.TextSecondary.ui
    }
    
    var body : some View {
        NavigationStack {
            TabView(selection: $selectedTab){
                ForEach(TAB_INFO) { tabInfo in
                    tabInfo.content()
                        .id(tabInfo.tag == 2 ? habitsRefreshID : AnyHashable(tabInfo.tag))
                        .tabItem {
                            Label(tabInfo.tabItemLabel, systemImage: tabInfo.tabItemImage)
                                .environment(\.symbolVariants, .none)
                                .accessibilityIdentifier(tabInfo.accessibilityIdentifier)
                        }
                        .tag(tabInfo.tag)
                }
            }
            .toolbar {
                switch selectedTabInfo.leadingIcon {
                case .Streak:
                    StreakToolbarItem(streak: viewModel.state.streak)
                case .AddHabit:
                    AddHabitToolbarItem(isAddEditHabitViewPresented: $isAddEditHabitViewPresented)
                }
            }
            .navigationTitle(selectedTabInfo.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isAddEditHabitViewPresented, onDismiss: { habitsRefreshID = UUID() }) {
                NavigationStack {
                    AddEditHabitView(
                        viewModel: AddEditHabitViewModel()
                    )
                }
            }
            .navigationDestination(item: $viewModel.state.habitToShowOnNavigation) { habit in
                DetailView(viewModel: DetailViewModel(habit: habit))
            }
        }
        .onAppear {
            performRefresh()
        }
        .onChange(of: selectedTab) {
            performRefresh()
        }
        .environment(\.mainTabViewRefresh, performRefresh)
    }
    
    private func performRefresh() {
        viewModel.fetchStreak()
    }
}
