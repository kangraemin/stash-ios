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

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .openButtonTapped, .deleteButtonTapped, .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
