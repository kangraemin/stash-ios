import SwiftUI

struct ContentCardView: View {
    let content: SavedContent

    var body: some View {
        Group {
            switch content.contentType {
            case .youtube:
                YouTubeCardView(content: content)
            case .instagram:
                InstagramCardView(content: content)
            case .naverMap, .googleMap:
                PlaceCardView(content: content)
            case .coupang:
                ShoppingCardView(content: content)
            case .web:
                WebCardView(content: content)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Shared Thumbnail

private struct CardThumbnail: View {
    let url: URL?
    let aspectRatio: CGFloat
    let iconName: String

    var body: some View {
        AsyncImage(url: url) { phase in
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
        .aspectRatio(aspectRatio, contentMode: .fit)
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
}

// MARK: - YouTube Card

private struct YouTubeCardView: View {
    let content: SavedContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardThumbnail(url: content.thumbnailURL, aspectRatio: 16 / 9, iconName: "play.rectangle.fill")

            VStack(alignment: .leading, spacing: 4) {
                Text(content.title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    if let channel = content.metadata["channelName"] {
                        Text(channel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if let duration = content.metadata["duration"] {
                        Text("·")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(duration)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
        }
    }
}

// MARK: - Instagram Card

private struct InstagramCardView: View {
    let content: SavedContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardThumbnail(url: content.thumbnailURL, aspectRatio: 1, iconName: "camera.fill")

            VStack(alignment: .leading, spacing: 4) {
                if let username = content.metadata["username"] {
                    Text("@\(username)")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }

                if let summary = content.summary {
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(10)
        }
    }
}

// MARK: - Place Card

private struct PlaceCardView: View {
    let content: SavedContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardThumbnail(url: content.thumbnailURL, aspectRatio: 4 / 3, iconName: "map.fill")

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(content.title)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Image(systemName: content.contentType == .naverMap ? "n.square.fill" : "g.square.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let address = content.metadata["address"] {
                    Text(address)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(10)
        }
    }
}

// MARK: - Shopping Card

private struct ShoppingCardView: View {
    let content: SavedContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardThumbnail(url: content.thumbnailURL, aspectRatio: 1, iconName: "cart.fill")

            VStack(alignment: .leading, spacing: 4) {
                Text(content.title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .lineLimit(2)

                if let price = content.metadata["price"] {
                    Text(price)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                }
            }
            .padding(10)
        }
    }
}

// MARK: - Web Card (기본)

private struct WebCardView: View {
    let content: SavedContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardThumbnail(url: content.thumbnailURL, aspectRatio: 16 / 9, iconName: "globe")

            VStack(alignment: .leading, spacing: 4) {
                Text(content.title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .lineLimit(2)

                Text(content.url.host ?? "")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(10)
        }
    }
}

// MARK: - Previews

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

#Preview("Instagram") {
    ContentCardView(content: .mockInstagram)
        .frame(width: 180)
        .padding()
}

#Preview("Place - Naver") {
    ContentCardView(content: .mockNaverMap)
        .frame(width: 180)
        .padding()
}

#Preview("Place - Google") {
    ContentCardView(content: .mockGoogleMap)
        .frame(width: 180)
        .padding()
}

#Preview("Shopping") {
    ContentCardView(content: .mockCoupang)
        .frame(width: 180)
        .padding()
}

#Preview("Grid") {
    ScrollView {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ContentCardView(content: .mock)
            ContentCardView(content: .mockYouTube)
            ContentCardView(content: .mockInstagram)
            ContentCardView(content: .mockNaverMap)
            ContentCardView(content: .mockGoogleMap)
            ContentCardView(content: .mockCoupang)
        }
        .padding()
    }
}
