//
//  NowPlayingLyricsView.swift
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

struct NowPlayingLyricsViewState: Equatable {
    
    public var playerState: MusicPlayerState
    public var progressingState: LyricsProgressingState?
    
    var lyricsView: LyricsViewState? {
        get { return progressingState.map(LyricsViewState.init(progressing:)) }
        set { progressingState = newValue?.progressing }
    }
    
    static func reduce(state: inout MainViewState, action: MainViewAction, env: MainViewEnvironment) -> Effect<MainViewAction, Never> {
        return .none
    }
}

enum NowPlayingLyricsViewAction: Equatable {
    
    case playerAction(MusicPlayerAction)
    case progressingAction(LyricsProgressingAction)
    case lyricsViewAction(LyricsViewAction)
}

typealias NowPlayingLyricsViewEnvironment = LyricsXCoreEnvironment

struct NowPlayingLyricsView: View {
    
    var store: Store<NowPlayingLyricsViewState, NowPlayingLyricsViewAction>
    
    @AppStorage("ShowLyricsTranslation")
    var showTranslation = false
    
    var body: some View {
        WithViewStore(store) { viewStore in
            IfLetStore(self.store.scope(state: \.lyricsView, action: NowPlayingLyricsViewAction.lyricsViewAction)) { store in
                VStack {
                    
                    LyricsView(store: store, showTranslation: showTranslation)
                        .mask(FeatherEdgeMask(edges: .vertical, depthPercentage: 0.05))
                    
                    HStack {
                        Button {
                            showTranslation.toggle()
                            viewStore.send(.lyricsViewAction(.forceScroll))
                        } label: {
                            // TODO: icon
                            Image(systemName: "textformat").font(Font.system(.title2))
                        }
                        
                        Button {
                            viewStore.send(.lyricsViewAction(.forceScroll))
                        } label: {
                            // TODO: icon
                            Image(systemName: "rectangle.arrowtriangle.2.inward").font(Font.system(.title2))
                        }
                        
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                .padding()
            }
            .background(DefaultArtworkImage().dimmed().ignoresSafeArea())
            .environment(\.colorScheme, .dark)
        }
    }
}

import LyricsUIPreviewSupport

struct NowPlayingLyricsView_Previews: PreviewProvider {
    static var previews: some View {
        let playerState = MusicPlayerState(player: MusicPlayers.Virtual(track: PreviewResources.track, state: .playing(time: 0)))
        let progressingState = LyricsProgressingState(lyrics: PreviewResources.lyrics, playbackState: .playing(time: 0))
        let state = NowPlayingLyricsViewState(playerState: playerState, progressingState: progressingState)
        let reducer = Reducer.combine([
            Reducer(MusicPlayerState.reduce)
                .pullback(
                    state: \NowPlayingLyricsViewState.playerState,
                    action: /NowPlayingLyricsViewAction.playerAction,
                    environment: { $0 }),
            Reducer(LyricsProgressingState.reduce)
                .optional()
                .pullback(
                    state: \NowPlayingLyricsViewState.progressingState,
                    action: /NowPlayingLyricsViewAction.progressingAction,
                    environment: { $0 }),
        ])
        let store = Store(initialState: state, reducer: reducer, environment: .default)
        
        return NowPlayingLyricsView(store: store)
    }
}
