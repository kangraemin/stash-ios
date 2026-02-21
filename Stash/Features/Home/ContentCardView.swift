import SwiftUI

struct ContentCardView: View {
    let content: SavedContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            thumbnail
            textArea
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    // MARK: - Thumbnail

    private var thumbnail: some View {
        AsyncImage(url: content.thumbnailURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                placeholder
            case .empty:
                placeholder
                    .overlay { ProgressView() }
            @unknown default:
                placeholder
            }
        }
        .frame(height: 100)
        .clipped()
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
    }

    // MARK: - Text Area

    private var textArea: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(content.title)
                .font(.footnote)
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundStyle(.primary)

            Text(content.url.host ?? "")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(10)
    }

    // MARK: - Icon

    private var iconName: String {
        switch content.contentType {
        case .youtube: "play.rectangle.fill"
        case .instagram: "camera.fill"
        case .naverMap, .googleMap: "map.fill"
        case .coupang: "cart.fill"
        case .web: "globe"
        }
    }
}

// MARK: - Preview

#Preview("Web") {
    ContentCardView(content: .mock)
        .frame(width: 180)
        .padding()
}

#Preview("YouTube") {
    ContentCardView(content: .mockYouTube)
        .frame(width: 180)
        .padding()
}

#Preview("Grid") {
    LazyVGrid(
        columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
        spacing: 12
    ) {
        ContentCardView(content: .mock)
        ContentCardView(content: .mockYouTube)
        ContentCardView(content: .mockInstagram)
        ContentCardView(content: .mockCoupang)
    }
    .padding()
}
