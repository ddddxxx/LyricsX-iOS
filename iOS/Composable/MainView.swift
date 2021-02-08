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
    
    var playerState: MusicPlayerState
    var lyricsProgressing: LyricsProgressingState?
    
    var lyricsView: LyricsViewState? {
        get {
            return lyricsProgressing
                .map(LyricsViewState.init(progressing:))
        }
        set {
            lyricsProgressing = newValue?.progressing
        }
    }
    
    static func reduce(state: inout MainViewState, action: MainViewAction, env: MainViewEnvironment) -> Effect<MainViewAction, Never> {
        return .none
    }
}

enum MainViewAction: Equatable {
    case lyricsView(LyricsViewAction)
    case player(MusicPlayerAction)
}

struct MainViewEnvironment {
    let mainQueue = DispatchQueue.main
    let player: MusicPlayerProtocol
    
    var lyricsView: LyricsViewEnvironment {
        let progressingEnv =  LyricsProgressingEnvironment(mainQueue: mainQueue, playbackStateUpdate: player.playbackStateWillChange)
        return LyricsViewEnvironment(progressing: progressingEnv)
    }
}

struct MainView: View {
    
    var store: Store<MainViewState, MainViewAction>
    
    @AppStorage("ShowTranslation")
    var showTranslation: Bool = false
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                IfLetStore(self.store.scope(state: \.lyricsView, action: MainViewAction.lyricsView)) { store in
                    VStack {
                        LyricsView(store: store, showTranslation: showTranslation)
                            .mask(FeatherEdgeMask(edges: .vertical, depthPercentage: 0.05))
                        HStack {
                            Button {
                                showTranslation.toggle()
                                viewStore.send(.lyricsView(.setForceScroll(true)))
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
                    NowPlayingToolbarItem(track: viewStore.playerState.currentTrack)
                }
            }
            .environment(\.colorScheme, .dark)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let player = MusicPlayers.Virtual()
        player.currentTrack = MusicTrack(id: "0", title: "No Surprises", album: "OK Computer", artist: "Radiohead")
        player.playbackState = .playing(time: 0)
        let state = MainViewState(
            playerState: MusicPlayerState(player: player),
            lyricsProgressing: LyricsProgressingState(lyrics: .sample, playbackState: .playing(time: 0)))
        let reducer = Reducer(LyricsProgressingState.reduce)
            .pullback(
                state: \LyricsViewState.progressing,
                action: /LyricsViewAction.progressing,
                environment: \LyricsViewEnvironment.progressing)
            .combined(with: Reducer(LyricsViewState.reduce))
            .optional()
            .pullback(
                state: \.lyricsView,
                action: /MainViewAction.lyricsView,
                environment: \.lyricsView)
            .combined(with: Reducer(MainViewState.reduce))
        let store = Store(
            initialState: state,
            reducer: reducer,
            environment: MainViewEnvironment(player: player))
        return MainView(store: store)
    }
}
