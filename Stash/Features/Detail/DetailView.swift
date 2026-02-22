import ComposableArchitecture
import SwiftUI

struct DetailView: View {
    @Bindable var store: StoreOf<DetailFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - 썸네일

                AsyncImage(url: store.content.thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        thumbnailPlaceholder
                    case .empty:
                        thumbnailPlaceholder
                            .overlay { ProgressView() }
                    @unknown default:
                        thumbnailPlaceholder
                    }
                }
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // MARK: - 콘텐츠 정보

                VStack(alignment: .leading, spacing: 8) {
                    Text(store.content.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack(spacing: 8) {
                        Text(store.content.url.host ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        contentTypeBadge
                    }

                    Text(store.content.createdAt, format: .dateTime.year().month().day())
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                // MARK: - 요약

                if let summary = store.content.summary {
                    Text(summary)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 24)

                // MARK: - 버튼

                Button {
                    store.send(.openButtonTapped)
                } label: {
                    Label("원본 열기", systemImage: "arrow.up.right.square")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(role: .destructive) {
                    store.send(.deleteButtonTapped)
                } label: {
                    Label("삭제", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding()
        }
        .navigationTitle(store.content.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert($store.scope(state: \.alert, action: \.alert))
    }

    // MARK: - Components

    private var thumbnailPlaceholder: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
    }

    private var contentTypeBadge: some View {
        Text(store.content.contentType.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.accentColor.opacity(0.1))
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DetailView(store: Store(initialState: DetailFeature.State(content: .mockYouTube)) {
            DetailFeature()
        })
    }
}
