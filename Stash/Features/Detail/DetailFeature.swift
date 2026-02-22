import ComposableArchitecture
import Foundation

@Reducer
struct DetailFeature {
    @ObservableState
    struct State: Equatable {
        var content: SavedContent
        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action {
        case openButtonTapped
        case deleteButtonTapped
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        @CasePathable
        enum Alert: Equatable {
            case confirmDelete
        }

        @CasePathable
        enum Delegate: Equatable {
            case contentDeleted(UUID)
        }
    }

    @Dependency(\.contentClient) var contentClient
    @Dependency(\.openURLClient) var openURLClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .openButtonTapped:
                let url = DeepLinkBuilder.deepLinkURL(for: state.content)
                return .run { [openURLClient] _ in
                    _ = await openURLClient.open(url)
                }

            case .deleteButtonTapped:
                state.alert = AlertState {
                    TextState("삭제하시겠습니까?")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDelete) {
                        TextState("삭제")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                } message: {
                    TextState("삭제된 콘텐츠는 복구할 수 없습니다.")
                }
                return .none

            case .alert(.presented(.confirmDelete)):
                let id = state.content.id
                return .run { [contentClient] send in
                    try await contentClient.delete(id)
                    await send(.delegate(.contentDeleted(id)))
                }

            case .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
