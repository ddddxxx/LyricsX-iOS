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

struct MainView: View {
    
    @EnvironmentObject
    var coreStore: ViewStore<LyricsXCoreState, LyricsXCoreAction>
    
    @State
    var isSearchViewPresented = false
    
    var body: some View {
        NavigationView {
            NowPlayingLyricsView()
                .environmentObject(coreStore)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    NowPlayingToolbarItem(track: coreStore.playerState.currentTrack)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isSearchViewPresented.toggle()
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }
                .environment(\.colorScheme, .dark)
                .sheet(isPresented: Binding(get: { isSearchViewPresented && coreStore.searchingState != nil }, set: { isSearchViewPresented = $0 })) {
                    LyricsSearchView()
                        .environmentObject(coreStore)
                }
        }
    }
}

import LyricsUIPreviewSupport

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewStore = ViewStore(Store(initialState: PreviewResources.coreState, reducer: lyricsXCoreReducer, environment: .default))
        viewStore.send(.progressingAction(.recalculateCurrentLineIndex))
        return MainView()
            .environmentObject(viewStore)
    }
}
