# Second Brain iOS - Development Guide

프로젝트 전체 규칙. 모든 에이전트(`~/.claude/agents/`)가 이 문서를 참조한다.

---

## 1. 프로젝트 개요

| 항목 | 선택 |
|------|------|
| 언어 | Swift 6 |
| UI | SwiftUI |
| 아키텍처 | TCA (The Composable Architecture) |
| DI | Factory + TCA Dependencies |
| 로컬 DB | SwiftData |
| AI 처리 | Apple Foundation Models (iOS 26+) |
| 시맨틱 검색 | NLContextualEmbedding (iOS 17+) |
| 테스트 | Swift Testing + TCA TestStore |
| 최소 타겟 | iOS 26 |
| 코딩 스타일 | Kodeco Swift Style Guide |
| 패키지 관리 | Swift Package Manager |

---

## 2. 단계별 개발 원칙

### 2.1 단계 구조
- 모든 개발은 **큰 단계(Phase) → 작은 단계(Step)** 로 쪼갠다.
- 각 단계는 **의미 단위**로 구성한다. 하나의 단계 = 하나의 기능 또는 하나의 관심사.
- 한 단계에서 여러 관심사를 섞지 않는다.

### 2.2 단계 완료 조건
- 모든 단계는 **해당 단계가 완료되었음을 증명하는 테스트**가 있어야 한다.
- 테스트가 **모두 통과**해야만 다음 단계로 넘어간다.
- **빌드가 성공**해야 한다. (warning 0 유지)
- 빌드가 깨진 상태로 다음 단계에 진입하지 않는다.

### 2.3 단계 진행 체크리스트

- [ ] 해당 단계의 기능이 의미 단위로 완성되었는가?
- [ ] 단계 완료를 증명하는 테스트가 작성되었는가?
- [ ] 모든 테스트가 통과하는가?
- [ ] 빌드가 성공하는가? (warning 0)
- [ ] DI 규칙을 지켰는가? (직접 생성 없음, Protocol 추상화)
- [ ] 코딩 컨벤션을 따랐는가?
- [ ] 필요한 주석이 달려있는가? (why 위주)
- [ ] 불필요한 코드/주석이 없는가?

---

## 3. 아키텍처 — TCA

### 3.1 프로젝트 구조
```
App
├── Features/           # 기능 단위
│   ├── Home/
│   │   ├── HomeFeature.swift       # Reducer + State + Action
│   │   └── HomeView.swift          # SwiftUI View
│   ├── Search/
│   ├── Save/
│   └── Detail/
├── Core/               # 공통 로직
│   ├── Models/         # 데이터 모델
│   ├── Services/       # 외부 의존성 (AI, DB, Search)
│   └── Extensions/     # Swift 확장
├── ShareExtension/     # Share Extension 타겟
├── SafariExtension/    # Safari Extension 타겟
└── Resources/          # 에셋, 로컬라이제이션
```

### 3.2 Reducer 구조
```swift
@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        // 화면에 필요한 상태만 선언
    }

    enum Action {
        case onAppear
        case searchQueryChanged(String)
        case delegate(Delegate)
        enum Delegate {
            case itemSelected(SavedItem)
        }
    }

    @Dependency(\.aiService) var aiService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    // 비동기 작업
                }
            }
        }
    }
}
```

### 3.3 View 구조
```swift
struct HomeView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        // store.state로 접근, store.send(.action)으로 이벤트
    }
}
```

### 3.4 TCA 규칙
- View에 비즈니스 로직 금지. 모든 로직은 Reducer에서.
- Side Effect는 반드시 `Effect`로 표현. Reducer body 밖에서 async 호출 금지.
- State는 반드시 `Equatable`.
- 자식 Feature 간 통신은 `Delegate` Action 패턴.

---

## 4. DI (Dependency Injection)

### 4.1 TCA Dependency (Reducer 내부)
```swift
extension DependencyValues {
    var aiService: AIServiceProtocol {
        get { self[AIServiceKey.self] }
        set { self[AIServiceKey.self] = newValue }
    }
}

private enum AIServiceKey: DependencyKey {
    static let liveValue: AIServiceProtocol = AIService()
    static let testValue: AIServiceProtocol = MockAIService()
}
```

### 4.2 Factory Container (비-TCA 영역)
```swift
extension Container {
    var storageService: Factory<StorageServiceProtocol> {
        Factory(self) { StorageService() }
    }
}
```

### 4.3 DI 규칙
- 모든 서비스는 **Protocol로 추상화**.
- 구현체 직접 생성 금지. 반드시 DI로 주입.
- Reducer: `@Dependency`, 그 외: `@Injected`.
- 테스트용 `testValue` / Mock 반드시 정의.

```swift
// Good
@Dependency(\.aiService) var aiService

// Bad
let aiService = AIService()
```

---

## 5. 코딩 컨벤션 (Kodeco 기반)

### 5.1 네이밍
- 타입: `UpperCamelCase` (`SavedItem`, `HomeFeature`)
- 변수/함수: `lowerCamelCase` (`savedItems`, `fetchRecentItems()`)
- 약어: 2글자 전부 대문자 (`ID`, `URL`), 3글자+ CamelCase (`Http`)
- Bool: `is`/`has`/`should` 접두어 (`isLoading`, `hasResults`)
- Protocol: 명사 또는 `~able`/`~ing` (`Searchable`, `StorageServiceProtocol`)

### 5.2 파일 구조
- 한 파일 = 하나의 주요 타입. 관련 extension은 같은 파일 허용.
- MARK 주석으로 섹션 구분:
```swift
// MARK: - Properties
// MARK: - Lifecycle
// MARK: - Public Methods
// MARK: - Private Methods
```

### 5.3 스타일
- 들여쓰기: 스페이스 4칸
- 줄 길이: 120자 이하
- 후행 쉼표 사용
- `self`: 컴파일러가 요구할 때만
- 타입 추론: 타입이 명확하면 생략

### 5.4 SwiftUI
- View body는 짧게. 복잡하면 서브뷰로 분리.
- modifier 체이닝은 한 줄에 하나씩:
```swift
Text("Hello")
    .font(.title)
    .foregroundStyle(.primary)
    .padding()
```

---

## 6. 주석 가이드

### 6.1 원칙
- "무엇을"은 코드로, **"왜"**는 주석으로.

### 6.2 필수
- 파일 헤더: `///` 역할 한 줄 설명
- public API: `///` 문서 주석 (`- Parameter`, `- Returns`)
- 비자명한 로직: 복잡한 알고리즘, workaround, 의도적 선택

### 6.3 금지
- 주석 처리된 코드 → 삭제
- 변경 이력 주석 → Git이 관리
- 자명한 주석

---

## 7. 테스트 가이드

### 7.1 프레임워크
- **Swift Testing** (`@Test`, `#expect`) 기본 사용
- TCA **TestStore**를 활용한 Reducer 테스트

### 7.2 Reducer 테스트
```swift
@Test("검색 쿼리 입력 시 결과가 업데이트된다")
func searchQueryUpdatesResults() async {
    let store = TestStore(initialState: SearchFeature.State()) {
        SearchFeature()
    } withDependencies: {
        $0.storageService = MockStorageService()
    }

    await store.send(.searchQueryChanged("파스타")) {
        $0.query = "파스타"
    }
}
```

### 7.3 테스트 범위
| 대상 | 필수 여부 | 방법 |
|------|----------|------|
| Reducer 로직 | **필수** | `TestStore`로 State/Action 검증 |
| Service 로직 | **필수** | Mock 주입 후 단위 테스트 |
| View | 선택 | Snapshot 테스트 |
| 통합 | 단계 완료 시 | 핵심 시나리오 E2E |

### 7.4 네이밍
- `@Test` 매크로에 한글로 행동+기대결과 명시
- 함수명은 영어 camelCase

### 7.5 Mock
- 모든 외부 서비스: Protocol + Mock 쌍
- Mock은 `Tests/Mocks/`에 모아둔다
- 최소한의 동작만 구현

### 7.6 빌드 검증
```bash
xcodebuild build -scheme SecondBrain -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
xcodebuild test -scheme SecondBrain -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

---

## 8. Git 컨벤션

`~/.claude/rules/git-rules.md` 참조. 추가로 이 프로젝트에서는:

- `develop` 브랜치를 개발 통합 브랜치로 사용
- `feature/<단계명>` 브랜치로 각 Step 작업
- 단계 완료 시 `develop`에 머지 후 태그: `phase-X.step-Y`

---

## 9. 팀 워크플로우

에이전트 정의는 글로벌(`~/.claude/agents/`)에 있다.

| 역할 | 에이전트 | 담당 |
|------|---------|------|
| Lead | `lead.md` | 단계 설계, 태스크 생성/배정, 리뷰, 조율 |
| Dev | `dev.md` | 기능 구현, 컨벤션 준수 |
| QA | `qa.md` | 테스트 작성, 빌드 검증, 단계 완료 판정 |

```
Lead: 단계 설계 → 태스크 생성
  ↓
Dev: 태스크 수행 → 구현 완료 보고
  ↓
QA: 테스트 작성/실행 → 빌드 검증 → 통과/반려
  ↓
Lead: 단계 완료 확인 → 다음 단계 진행
```
