//
//  MainView.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import ComposableArchitecture
import LyricsCore
import MusicPlayer
import LyricsXCore
import LyricsUI

struct MainViewState: Equatable {
    
    var coreState: LyricsXCoreState
    
    var nowPlayingLyricsView: NowPlayingLyricsViewState {
        get {
            return NowPlayingLyricsViewState(playerState: coreState.playerState, progressingState: coreState.progressingState)
        }
        set {
            coreState.playerState = newValue.playerState
            coreState.progressingState = newValue.progressingState
        }
    }
    
    var searchView: LyricsSearchViewState? {
        get { coreState.searchingState.map(LyricsSearchViewState.init) }
        set { coreState.searchingState = newValue?.searching }
    }
}

enum MainViewAction: Equatable {
    
    case coreAction(LyricsXCoreAction)
    case lyricsViewAction(LyricsViewAction)
    case searchViewIsolatedAction(LyricsSearchViewIsolatedAction)
    
    static func searchViewAction(_ action: LyricsSearchViewAction) -> MainViewAction {
        switch action {
        case let .left(a):
            return .searchViewIsolatedAction(a)
        case let .right(a):
            return .coreAction(.searchingAction(a))
        }
    }
    
    static func nowPlayingLyricsViewAction(_ action: NowPlayingLyricsViewAction) -> MainViewAction {
        switch action {
        case let .lyricsViewAction(a):
            return .lyricsViewAction(a)
        case let .playerAction(a):
            return .coreAction(.playerAction(a))
        case let .progressingAction(a):
            return .coreAction(.progressingAction(a))
        }
    }
}

typealias MainViewEnvironment = LyricsXCoreEnvironment

struct MainView: View {
    
    var store: Store<MainViewState, MainViewAction>
    
    @State
    var isSearchViewPresented = false
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                NowPlayingLyricsView(store: store.scope(state: \.nowPlayingLyricsView, action: MainViewAction.nowPlayingLyricsViewAction))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        NowPlayingToolbarItem(track: viewStore.coreState.playerState.currentTrack)
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                isSearchViewPresented.toggle()
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }
                        }
                    }
                    .environment(\.colorScheme, .dark)
                    .sheet(isPresented: $isSearchViewPresented) {
                        IfLetStore(store.scope(state: \.searchView, action: MainViewAction.searchViewAction)) { store in
                            LyricsSearchView(store: store)
                        }
                    }
            }
        }
    }
}

import LyricsUIPreviewSupport

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let player = MusicPlayers.Virtual()
        player.currentTrack = PreviewResources.track
        player.playbackState = .playing(time: 0)
        let playerState = MusicPlayerState(player: player)
        let mainState = MainViewState(coreState: LyricsXCoreState(playerState: playerState))
        let reducer = lyricsXCoreReducer.pullback(
            state: \MainViewState.coreState,
            action: /MainViewAction.coreAction,
            environment: { $0 })
        let store = Store(initialState: mainState, reducer: reducer, environment: .default)
        return MainView(store: store)
    }
}
