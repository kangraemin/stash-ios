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
            case deleteConfirmed
        }

        @CasePathable
        enum Delegate: Equatable {
            case contentDeleted(UUID)
        }
    }

    @Dependency(\.contentClient) var contentClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .openButtonTapped:
                return .none

            case .deleteButtonTapped:
                state.alert = AlertState {
                    TextState("삭제 확인")
                } actions: {
                    ButtonState(role: .destructive, action: .deleteConfirmed) {
                        TextState("삭제")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                } message: {
                    TextState("이 콘텐츠를 삭제하시겠습니까?")
                }
                return .none

            case .alert:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
