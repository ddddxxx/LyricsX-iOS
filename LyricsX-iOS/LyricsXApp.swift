//
//  LyricsXApp.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import ComposableArchitecture
import LyricsXCore
import MusicPlayer

@main
struct LyricsXApp: App {
    
    let mainStore: Store<MainViewState, MainViewAction> = {
        let playerState = MusicPlayerState(player: MusicPlayers.AppleMusic())
        let mainState = MainViewState(coreState: LyricsXCoreState(playerState: playerState))
        let reducer = lyricsXCoreReducer.pullback(
            state: \MainViewState.coreState,
            action: /MainViewAction.coreAction,
            environment: { $0 })
        return Store(initialState: mainState, reducer: reducer, environment: .default)
    }()
    
    @Environment(\.scenePhase)
    var scenePhase
    
    var body: some Scene {
        WithViewStore(mainStore) { viewStore in
            WindowGroup {
                MainView(store: mainStore)
            }
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    // TODO: Authorization
                    MusicPlayers.AppleMusic().requestAuthorizationIfNeeded()
                    viewStore.send(.coreAction(.onAppActivate))
                case .inactive, .background, _:
                    break
                }
            }
        }
    }
}
