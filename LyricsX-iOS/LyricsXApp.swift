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
    
    let coreStore: ViewStore<LyricsXCoreState, LyricsXCoreAction> = {
        let playerState = MusicPlayerState(player: MusicPlayers.AppleMusic())
        let coreState = LyricsXCoreState(playerState: playerState)
        let store = Store(initialState: coreState, reducer: lyricsXCoreReducer, environment: .default)
        return ViewStore(store)
    }()
    
    @Environment(\.scenePhase)
    var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(coreStore)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                // TODO: Authorization
                MusicPlayers.AppleMusic().requestAuthorizationIfNeeded()
                coreStore.send(.onAppActivate)
            case .inactive, .background, _:
                break
            }
        }
    }
}
