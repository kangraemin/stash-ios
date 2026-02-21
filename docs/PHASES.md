# Phase 계획

Stash iOS 앱의 단계별 개발 계획.

---

## 환경 제약사항

| 항목 | 현재 상태 | 필요 사항 |
|------|----------|----------|
| macOS | 13.2.1 (Ventura) | 13.5+ (Xcode 15용) |
| Xcode | 미설치 (Command Line Tools만 존재) | Xcode 15+ 필수 |
| Swift | 5.8 | 5.9+ (TCA @ObservableState, Swift Testing) |
| XcodeGen | 미설치, brew 지원 안 됨 (macOS 13) | 불필요 (Xcode 프로젝트 직접 생성) |

**결론**: Xcode 15 설치가 선행되어야 한다. macOS 13.5 이상으로 업데이트가 필요할 수 있다. Phase 0의 첫 Step에서 환경 확인 및 Xcode 프로젝트 생성을 처리한다.

---

## Phase 0: 프로젝트 셋업
상태: ⏳ 대기

> 빌드 가능한 빈 앱 + 기본 프로젝트 구조 + 의존성 설정

### Step 0.1: 개발 환경 확인 및 Xcode 프로젝트 생성
- 구현:
  - macOS 버전 확인, 필요 시 사용자에게 업데이트 안내
  - Xcode 15+ 설치 확인 (사용자가 수동 설치)
  - Xcode에서 iOS App 프로젝트 생성 (SwiftUI, iOS 17+)
  - Bundle ID: `com.kangraemin.stash`
  - Swift Package Manager로 TCA 의존성 추가
  - `.gitignore` 설정 (Xcode, SPM 캐시 등)
- 완료 기준:
  - `xcodebuild build -scheme Stash` 성공
  - TCA import 가능 (의존성 resolve 완료)
  - 시뮬레이터에서 빈 앱 실행 가능

### Step 0.2: 프로젝트 디렉토리 구조 생성
- 구현:
  - ARCHITECTURE.md에 정의된 디렉토리 구조 생성
  - `App/`, `Features/`, `Domain/`, `Data/`, `ML/`, `Shared/`, `Resources/`
  - 테스트 타겟 `StashTests/` 구조 생성
  - 각 디렉토리에 빈 placeholder 파일 배치 (Xcode 프로젝트 인식용)
- 완료 기준:
  - 모든 디렉토리가 Xcode 프로젝트에 등록됨
  - 빌드 성공 유지

### Step 0.3: 앱 진입점 및 루트 Feature 구성
- 구현:
  - `StashApp.swift` (앱 진입점)
  - `AppFeature.swift` (루트 TCA Reducer, 빈 State/Action)
  - `AppView.swift` (루트 View, Store 연결)
  - TCA `@ObservableState` + `@Bindable` 패턴 적용
- 완료 기준:
  - 앱 실행 시 빈 화면 표시
  - `AppFeature` TestStore 테스트 1개 통과
  - 빌드 성공, warning 0

---

## Phase 1: 도메인 모델 + 데이터 계층
상태: ⏳ 대기

> 핵심 데이터 모델 정의, SwiftData 저장소, TCA Client 구현

### Step 1.1: 도메인 모델 정의
- 구현:
  - `Domain/Models/SavedContent.swift` — 핵심 도메인 모델
    - `id`, `title`, `url`, `contentType`, `thumbnailURL`, `memo`, `createdAt` 등
  - `Domain/Models/ContentType.swift` — 콘텐츠 타입 enum
    - `.youtube`, `.instagram`, `.naverMap`, `.googleMap`, `.coupang`, `.web` 등
  - `Domain/Models/Collection.swift` — 컬렉션(폴더) 모델
  - 모든 모델에 `Equatable`, `Identifiable` 준수
  - 테스트용 `.mock` static factory 메서드
- 완료 기준:
  - 도메인 모델 단위 테스트 통과 (Equatable 검증, ContentType 분류 로직)
  - 빌드 성공, warning 0

### Step 1.2: SwiftData 모델 + Mapper
- 구현:
  - `Data/SwiftData/SDContent.swift` — SwiftData 모델 (`@Model`)
  - `Data/SwiftData/SDCollection.swift` — SwiftData 컬렉션 모델
  - `Data/Mappers/ContentMapper.swift` — SD 모델 <-> 도메인 모델 변환
  - `ModelContainer` 설정 (App Group 컨테이너 경로)
- 완료 기준:
  - Mapper 변환 테스트 통과 (SD -> Domain, Domain -> SD 양방향)
  - 빌드 성공, warning 0

### Step 1.3: ContentClient (TCA Dependency)
- 구현:
  - `Domain/Services/ContentClient.swift` — Client 프로토콜 정의
    - `save`, `fetch`, `fetchByType`, `delete`, `update`
  - `Data/Clients/ContentClient+Live.swift` — SwiftData 기반 실제 구현
  - `Data/Clients/ContentClient+Test.swift` — 테스트용 구현
  - DependencyKey 등록
- 완료 기준:
  - ContentClient TestStore 테스트 통과 (save -> fetch 흐름)
  - 빌드 성공, warning 0

---

## Phase 2: 홈 화면 (핵심 UI)
상태: ⏳ 대기

> 메인 화면 UI — 콘텐츠 목록, 필터 칩, 카드 그리드

### Step 2.1: HomeFeature (Reducer)
- 구현:
  - `Features/Home/HomeFeature.swift`
    - State: `contents`, `selectedFilter`, `isLoading`
    - Action: `onAppear`, `filterChanged`, `contentTapped`, `contentsLoaded`
  - `ContentClient` 의존성 주입으로 데이터 로드
  - 필터 로직 (ContentType별 필터링)
- 완료 기준:
  - TestStore 테스트 통과:
    - onAppear 시 콘텐츠 로드
    - 필터 변경 시 목록 필터링
    - 콘텐츠 탭 시 상태 변경
  - 빌드 성공, warning 0

### Step 2.2: HomeView + 카드 UI
- 구현:
  - `Features/Home/HomeView.swift` — 메인 화면
  - 검색바 (아직 동작 안 함, UI만)
  - 필터 칩 (가로 스크롤, ContentType별)
  - 2열 카드 그리드 (`LazyVGrid`)
  - `Shared/Common/ContentCardView.swift` — ContentType별 카드 UI
    - YouTube 카드 (썸네일 16:9 + 제목 + 채널명)
    - 일반 웹 카드 (OG 이미지 + 제목 + 도메인)
    - 장소 카드, 쇼핑 카드, 인스타 카드 (기본 레이아웃)
- 완료 기준:
  - Preview에서 다양한 카드 타입 확인 가능
  - 빌드 성공, warning 0

### Step 2.3: 상세 화면 (DetailFeature)
- 구현:
  - `Features/Detail/DetailFeature.swift` — 상세 Reducer
    - State: 콘텐츠 정보, 편집 모드
    - Action: 열기(딥링크), 메모 편집, 삭제
  - `Features/Detail/DetailView.swift` — 상세 화면 UI
  - Home -> Detail 네비게이션 연결 (StackState)
- 완료 기준:
  - TestStore 테스트 통과 (열기, 삭제 액션)
  - 네비게이션 동작 확인
  - 빌드 성공, warning 0

---

## Phase 3: Share Extension (콘텐츠 저장)
상태: ⏳ 대기

> 다른 앱에서 공유하기로 Stash에 콘텐츠 저장

### Step 3.1: Share Extension 타겟 설정
- 구현:
  - Xcode에서 Share Extension 타겟 추가
  - App Group 설정 (`group.com.kangraemin.stash`)
  - 공유 ModelContainer (App Group 컨테이너 경로)
  - `Shared/AppGroup/` — 메인 앱 + Extension 공유 설정
- 완료 기준:
  - Share Extension 타겟 빌드 성공
  - App Group 컨테이너 접근 가능 확인

### Step 3.2: URL 파싱 + ContentType 판별
- 구현:
  - `Domain/ContentParsing/ContentParser.swift` — URL 파서
  - `Domain/ContentParsing/ContentTypeDetector.swift` — 도메인 기반 타입 판별
    - youtube.com -> `.youtube`
    - instagram.com -> `.instagram`
    - naver.me, map.naver.com -> `.naverMap`
    - goo.gl/maps, maps.google.com -> `.googleMap`
    - coupang.com -> `.coupang`
    - 기타 -> `.web`
  - 단축 URL 도메인도 매핑 (youtu.be 등)
- 완료 기준:
  - ContentTypeDetector 테스트: 각 소스별 URL 10개 이상 검증
  - 빌드 성공, warning 0

### Step 3.3: Share Extension UI + 저장 플로우
- 구현:
  - `ShareExtension/ShareFeature.swift` — TCA Reducer
  - `ShareExtension/ShareView.swift` — 최소 UI (토스트 스타일)
  - `NSExtensionContext`에서 URL 추출
  - ContentParser로 파싱 -> SwiftData 저장 -> 토스트 표시 -> 자동 닫힘
  - 1탭 저장 UX 구현 (UX Guide 기본 플로우)
- 완료 기준:
  - Share Extension에서 URL 저장 -> 메인 앱에서 확인 가능
  - TestStore 테스트 통과 (저장 플로우)
  - 빌드 성공, warning 0

---

## Phase 4: 메타데이터 추출 + 딥링크
상태: ⏳ 대기

> 저장된 URL에서 메타데이터 자동 추출, 원본 앱으로 딥링크 이동

### Step 4.1: 메타데이터 추출 서비스
- 구현:
  - `Domain/Services/MetadataClient.swift` — 메타데이터 추출 Client 프로토콜
  - `Data/Clients/MetadataClient+Live.swift` — 구현
    - OG 태그 파싱 (title, description, image)
    - 단축 URL 리다이렉트 해소
  - 메인 앱 진입 시 미처리 콘텐츠의 메타데이터 배치 추출
- 완료 기준:
  - 메타데이터 추출 테스트 통과 (OG 태그 파싱)
  - 빌드 성공, warning 0

### Step 4.2: 딥링크 서비스
- 구현:
  - `Domain/Services/DeepLinkClient.swift` — 딥링크 생성 Client
  - `Data/Clients/DeepLinkClient+Live.swift` — 구현
    - ContentType별 URL scheme 생성
    - 앱 설치 여부 확인 (`canOpenURL`)
    - fallback: Safari로 웹 URL 열기
  - DetailView의 "열기" 버튼에 딥링크 연결
- 완료 기준:
  - 딥링크 URL 생성 테스트 통과 (각 ContentType별)
  - fallback 로직 테스트 통과
  - 빌드 성공, warning 0

---

## Phase 5: 검색 (키워드 + 시맨틱)
상태: ⏳ 대기

> 키워드 검색 먼저, 이후 Core ML 기반 시맨틱 검색

### Step 5.1: 키워드 검색
- 구현:
  - `Features/Search/SearchFeature.swift` — 검색 Reducer
    - 디바운스 검색 (300ms)
    - 필터 칩과 조합 가능
  - `Features/Search/SearchView.swift` — 검색 UI
  - `Domain/Services/SearchClient.swift` — 검색 Client 프로토콜
  - `Data/Clients/SearchClient+Live.swift` — `localizedStandardContains` 기반 구현
  - HomeView의 검색바와 연결
- 완료 기준:
  - TestStore 테스트 통과:
    - 디바운스 동작 검증
    - 필터 + 검색어 조합 검증
    - 빈 쿼리 시 전체 결과 반환
  - 빌드 성공, warning 0

### Step 5.2: Core ML 임베딩 서비스
- 구현:
  - `ML/EmbeddingService/EmbeddingClient.swift` — 임베딩 Client 프로토콜
  - `ML/EmbeddingService/EmbeddingClient+Live.swift` — NLEmbedding 기반 구현
  - 콘텐츠 저장 시 임베딩 벡터 자동 생성
  - SwiftData 모델에 `embedding: [Float]` 필드 추가
- 완료 기준:
  - 텍스트 -> 임베딩 벡터 생성 테스트 통과
  - 빌드 성공, warning 0

### Step 5.3: 벡터 유사도 검색
- 구현:
  - `ML/VectorSearch/VectorSearchClient.swift` — 벡터 검색 Client
  - 코사인 유사도 계산 로직
  - 키워드 검색 + 시맨틱 검색 결과 병합 랭킹
  - SearchFeature에 시맨틱 검색 통합
- 완료 기준:
  - 코사인 유사도 계산 테스트 통과
  - 키워드 + 시맨틱 결합 검색 테스트 통과
  - 빌드 성공, warning 0

---

## Phase 6: 컬렉션 + 설정
상태: ⏳ 대기

> 수동 정리 기능(컬렉션)과 설정 화면

### Step 6.1: 컬렉션 관리
- 구현:
  - `Features/CategoryList/CategoryListFeature.swift` — 컬렉션 목록 Reducer
  - `Features/CategoryList/CategoryListView.swift` — 컬렉션 목록 UI
  - 컬렉션 생성, 이름 변경, 삭제
  - 콘텐츠를 컬렉션에 추가/제거
  - 탭 또는 사이드바에서 접근
- 완료 기준:
  - TestStore 테스트 통과 (CRUD, 콘텐츠 연결)
  - 빌드 성공, warning 0

### Step 6.2: 설정 화면
- 구현:
  - `Features/Settings/SettingsFeature.swift` — 설정 Reducer
  - `Features/Settings/SettingsView.swift` — 설정 UI
  - 앱 정보, 데이터 관리 (전체 삭제 등)
  - 탭 네비게이션 구성 (홈, 컬렉션, 설정)
- 완료 기준:
  - TestStore 테스트 통과
  - 탭 네비게이션 동작 확인
  - 빌드 성공, warning 0

---

## Phase 7: 마무리 + 품질
상태: ⏳ 대기

> 에러 처리 통합, 접근성, 최종 점검

### Step 7.1: 에러 처리 통합
- 구현:
  - `Domain/Models/StashError.swift` — 통합 에러 타입
  - 모든 Feature에 에러 상태 + AlertState 처리 추가
  - 네트워크 실패, 파싱 실패, 저장 실패 등 시나리오별 처리
- 완료 기준:
  - 에러 시나리오별 테스트 통과
  - 빌드 성공, warning 0

### Step 7.2: 접근성 + 최종 점검
- 구현:
  - VoiceOver 레이블 추가
  - Dynamic Type 대응
  - 다크 모드 확인
  - 메모리 누수 점검
  - 전체 테스트 스위트 실행 및 통과 확인
- 완료 기준:
  - 전체 테스트 통과
  - 빌드 성공, warning 0
  - VoiceOver로 주요 플로우 탐색 가능
