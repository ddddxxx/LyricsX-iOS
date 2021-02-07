//
//  ContentView.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import SwiftUI
import ComposableArchitecture
import LyricsCore
import MusicPlayer
import LyricsXCore
import LyricsUI

struct MainViewState: Equatable {
    var lyricsView: LyricsViewState?
    
    static func reduce(state: inout MainViewState, action: MainViewAction, env: MainViewEnvironment) -> Effect<MainViewAction, Never> {
        return .none
    }
}

enum MainViewAction: Equatable {
    case lyricsView(LyricsViewAction)
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
    
    var body: some View {
        NavigationView {
            IfLetStore(self.store.scope(state: \.lyricsView, action: MainViewAction.lyricsView)) { store in
                LyricsView(store: store)
                    .padding()
            }
            .background(DefaultArtworkImage().dimmed().ignoresSafeArea())
            .ignoresSafeArea(.all, edges: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Title").font(.headline)
                        Text("Subtitle").font(.subheadline)
                    }
                }
            }
        }
        .environment(\.colorScheme, .dark)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let player = MusicPlayers.Virtual()
        player.currentTrack = MusicTrack(id: "0", title: "No Surprises", album: "OK Computer", artist: "Radiohead")
        player.playbackState = .playing(time: 0)
        let state = MainViewState(
            lyricsView: LyricsViewState(
                progressing: .init(lyrics: .sample, playbackState: .playing(time: 0)),
                showTranslation: true))
        let reducer: Reducer<MainViewState, MainViewAction, MainViewEnvironment> = Reducer(LyricsViewState.reduce)
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
