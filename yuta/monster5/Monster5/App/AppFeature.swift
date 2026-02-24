import Foundation
import ComposableArchitecture

@Reducer
struct AppFeature {

    @ObservableState
    struct State: Equatable {
        var login = LoginFeature.State()
        var home: HomeFeature.State?

        var isAuthenticated: Bool { home != nil }
    }

    enum Action {
        case login(LoginFeature.Action)
        case home(HomeFeature.Action)
    }

    // MARK: - Reducer Pipeline
    //
    // body 只被讀取一次，用來「組裝」reducer pipeline（類似 Combine 建立 publisher pipeline）。
    // 組裝完成後，每次 action 進來都流過同一條 pipeline，body 不會重新讀取。
    //
    //   組裝一次：讀取 body → 建立 Scope + Reduce + ifLet 的組合
    //   執行 N 次：每個 action 流過這條 pipeline → state 被更新
    //
    // 三種 Reducer 組合器（對應 Swift 原生概念）：
    //   Scope   = map + filter — 把 state 視角縮小到子區塊，只處理對應的 action
    //   ifLet   = if let       — Optional state 有值時才執行子 Reducer
    //   forEach = for-in       — 對集合中每個元素各自執行子 Reducer
    //
    var body: some ReducerOf<Self> {

        // Scope: login state 永遠存在，將 .login(...) action 路由給 LoginFeature
        // LoginFeature 只能看到/操作 state.login，不知道 home 的存在
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }

        // Reduce: App 層攔截邏輯 — 處理跨 Feature 的事件（delegate action）
        // LoginFeature 登入成功後發出 .delegate(.loginSucceeded)，
        // 冒泡到這裡，App 層把 home 從 nil 設成有值，觸發 AppCoordinator 轉場
        Reduce { state, action in
            switch action {
            case .login(.delegate(.loginSucceeded)):
                state.home = HomeFeature.State()
                return .none

            case .login:
                return .none

            case .home:
                return .none
            }
        }
        // ifLet: home 是 Optional，登入前 nil（HomeFeature 不運作），
        // 登入成功後有值（HomeFeature 開始處理 .home(...) action）
        .ifLet(\.home, action: \.home) {
            HomeFeature()
        }
    }
}
