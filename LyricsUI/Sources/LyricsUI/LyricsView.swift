//
//  LyricsView.swift
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

public struct LyricsView: View {
    
    @ObservedObject
    var viewStore: ViewStore<LyricsViewState, LyricsViewAction>
    
    public init(store: Store<LyricsViewState, LyricsViewAction>) {
        self.viewStore = ViewStore(store)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewStore.lyrics.lines.indices, id: \.self) { index in
                            LyricsLineView(line: viewStore.lyrics.lines[index], showTranslation: viewStore.showTranslation)
                                .foregroundColor(viewStore.currentLineIndex == index ? Color(.systemBlue) : .primary)
                                .onTapGesture {
                                    viewStore.send(.lyricsLineTapped(index: index))
                                }
                        }
                    }
                    .padding(.vertical, geometry.size.height / 2)
                }
                .onChange(of: viewStore.currentLineIndex) { index in
                    if let index = index, viewStore.isAutoScrollEnabled {
                        withAnimation(.linear(duration: 0.1)) {
                            scrollProxy.scrollTo(index, anchor: .center)
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { _ in
                            viewStore.send(.onDrag)
                        }
                        .onEnded { _ in
                            viewStore.send(.onDragEnded)
                        }
                )
            }
        }.onAppear {
            viewStore.send(.recalculateCurrentLineIndex)
        }
    }
}

struct LyricsView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            LyricsView(
                store: Store(
                    initialState: LyricsViewState(lyrics: .sample, showTranslation: true),
                    reducer: lyricsViewReducer,
                    environment: LyricsViewEnvironment(playbackStateUpdate: Just(PlaybackState.playing(time: 0)).eraseToAnyPublisher())
                )
            )
            .padding()
            .background(Color.systemBackground)
            .environment(\.colorScheme, .light)
            .edgesIgnoringSafeArea(.all)
            
            LyricsView(
                store: Store(
                    initialState: LyricsViewState(lyrics: .sample, showTranslation: true),
                    reducer: lyricsViewReducer,
                    environment: LyricsViewEnvironment(playbackStateUpdate: Just(PlaybackState.playing(time: 0)).eraseToAnyPublisher())
                )
            )
            .padding()
            .background(Color.systemBackground)
            .environment(\.colorScheme, .dark)
            .edgesIgnoringSafeArea(.all)
        }
    }
}
