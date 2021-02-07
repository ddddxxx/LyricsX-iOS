//
//  ContentView.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2020  Xander Deng. Licensed under GPLv3.
//

import Combine
import SwiftUI
import ComposableArchitecture
import LyricsCore
import MusicPlayer
import LyricsUI

struct MainViewState: Equatable {
    var lyricsView: LyricsViewState?
}

enum MainViewAction: Equatable {
    case lyricsView(LyricsViewAction)
}

struct MainViewEnvironment {
    let mainQueue = DispatchQueue.main
    let player: MusicPlayerProtocol
    
    var lyricsView: LyricsViewEnvironment {
        return LyricsViewEnvironment(mainQueue: mainQueue, playbackStateUpdate: player.playbackStateWillChange)
    }
}

let mainViewReducer = Reducer<MainViewState, MainViewAction, MainViewEnvironment>.combine(
    lyricsViewReducer
        .optional()
        .pullback(
            state: \.lyricsView,
            action: /MainViewAction.lyricsView,
            environment: \.lyricsView
        ),
    Reducer { state, action, env in
        
        return .none
    }
)

struct MainView: View {
    
    var store: Store<MainViewState, MainViewAction>
    
    var body: some View {
        IfLetStore(self.store.scope(state: \.lyricsView, action: MainViewAction.lyricsView)) { store in
            LyricsView(store: store)
                .padding()
        }
        .background(DefaultArtworkImage().dimmed())
        .ignoresSafeArea()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let player = MusicPlayers.Virtual()
        player.currentTrack = MusicTrack(id: "0", title: "0", album: "0", artist: "0")
        player.playbackState = .playing(time: 0)
        let store = Store(initialState: MainViewState(lyricsView: LyricsViewState(lyrics: .sample, showTranslation: true)), reducer: mainViewReducer, environment: MainViewEnvironment(player: player))
        return MainView(store: store)
    }
}
