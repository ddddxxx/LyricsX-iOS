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

struct NowPlayingLyricsView: View {
    
    @EnvironmentObject
    var coreStore: ViewStore<LyricsXCoreState, LyricsXCoreAction>
    
    @AppStorage("ShowLyricsTranslation")
    var showTranslation = false
    
    @State
    var isAutoScrollEnabled = true
    
    var body: some View {
            VStack {
                LyricsView(isAutoScrollEnabled: $isAutoScrollEnabled, showTranslation: showTranslation)
                    .environmentObject(coreStore)
                    .mask(FeatherEdgeMask(edges: .vertical, depthPercentage: 0.05))
                
                HStack {
                    Button {
                        showTranslation.toggle()
                    } label: {
                        Image(systemName: "textformat")
                    }
                    
                    if !isAutoScrollEnabled {
                        Button {
                            isAutoScrollEnabled = true
                        } label: {
                            Image(systemName: "rectangle.arrowtriangle.2.inward")
                        }
                    }
                    
                    Spacer()
                }
                .font(Font.system(.title2))
                .foregroundColor(.white)
                .padding()
            }
            .padding()
            .background(DefaultArtworkImage().dimmed().ignoresSafeArea())
            .environment(\.colorScheme, .dark)
    }
}

import LyricsUIPreviewSupport

struct NowPlayingLyricsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewStore = ViewStore(Store(initialState: PreviewResources.coreState, reducer: lyricsXCoreReducer, environment: .default))
        viewStore.send(.progressingAction(.recalculateCurrentLineIndex))
        return NowPlayingLyricsView()
            .environmentObject(viewStore)
    }
}
