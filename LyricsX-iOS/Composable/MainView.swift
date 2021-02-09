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
    
    var lyricsView: LyricsViewState? {
        get { return coreState.progressingState.map(LyricsViewState.init(progressing:)) }
        set { coreState.progressingState = newValue?.progressing }
    }
    
    var searchView: LyricsSearchViewState? {
        get { coreState.searchingState.map(LyricsSearchViewState.init) }
        set { coreState.searchingState = newValue?.searching }
    }
    
    static func reduce(state: inout MainViewState, action: MainViewAction, env: MainViewEnvironment) -> Effect<MainViewAction, Never> {
        return .none
    }
}

enum MainViewAction: Equatable {
    
    case coreAction(LyricsXCoreAction)
    case lyricsViewAction(LyricsViewAction)
    case searchViewIsolatedAction(LyricsSearchViewIsolatedAction)
    
    static func searchViewAction(_ action: LyricsSearchViewAction) -> MainViewAction {
        switch action {
        case let .left(isolated):
            return .searchViewIsolatedAction(isolated)
        case let .right(searching):
            return .coreAction(.searchingAction(searching))
        }
    }
}

typealias MainViewEnvironment = LyricsXCoreEnvironment

struct MainView: View {
    
    var store: Store<MainViewState, MainViewAction>
    
    @AppStorage("ShowLyricsTranslation")
    var showTranslation = false
    
    @State
    var isSearchViewPresented = false
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                IfLetStore(self.store.scope(state: \.lyricsView, action: MainViewAction.lyricsViewAction)) { store in
                    VStack {
                        LyricsView(store: store, showTranslation: showTranslation)
                            .mask(FeatherEdgeMask(edges: .vertical, depthPercentage: 0.05))
                        HStack {
                            Button {
                                showTranslation.toggle()
                                viewStore.send(.lyricsViewAction(.setForceScroll(true)))
                            } label: {
                                // TODO: icon
                                Image(systemName: "textformat")
                                    .font(Font.system(.title2))
                            }
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    .padding()
                }
                .background(DefaultArtworkImage().dimmed().ignoresSafeArea())
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
