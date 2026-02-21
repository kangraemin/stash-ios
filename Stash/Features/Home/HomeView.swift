import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterChips
                    .padding(.vertical, 12)

                Divider()

                // 카드 그리드는 Step 2.7에서 추가
                Spacer()
            }
            .navigationTitle("Stash")
            .onAppear { store.send(.onAppear) }
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HomeFeature.ContentFilter.allCases, id: \.self) { filter in
                    FilterChipView(
                        title: filter.rawValue,
                        isSelected: store.selectedFilter == filter
                    ) {
                        store.send(.filterTapped(filter))
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - FilterChipView

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color(.systemGray6))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.contentClient.fetch = {
                [.mock, .mockYouTube, .mockInstagram, .mockNaverMap, .mockCoupang]
            }
        }
    )
}
