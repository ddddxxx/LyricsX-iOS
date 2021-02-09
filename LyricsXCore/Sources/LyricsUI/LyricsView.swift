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
import LyricsXCore
import LyricsCore
import MusicPlayer

public struct LyricsView: View {
    
    @ObservedObject
    public var viewStore: ViewStore<LyricsViewState, LyricsViewAction>
    
    public var showTranslation: Bool
    
    public init(store: Store<LyricsViewState, LyricsViewAction>, showTranslation: Bool) {
        self.viewStore = ViewStore(store)
        self.showTranslation = showTranslation
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewStore.progressing.lyrics.lines.indices, id: \.self) { index in
                            LyricsLineView(line: viewStore.progressing.lyrics.lines[index], showTranslation: showTranslation)
                                .opacity(viewStore.progressing.currentLineIndex == index ? 1 : 0.6)
                                .scaleEffect(viewStore.progressing.currentLineIndex == index ? 1 : 0.9, anchor: .leading)
                                .animation(.default, value: viewStore.progressing.currentLineIndex == index)
                                .onTapGesture {
                                    viewStore.send(.lyricsLineTapped(index: index))
                                }
                        }
                    }
                    .padding(.vertical, geometry.size.height / 2)
                }
                .onChange(of: viewStore.progressing.currentLineIndex) { index in
                    if let index = index, viewStore.isAutoScrollEnabled {
                        withAnimation(.linear(duration: 0.1)) {
                            scrollProxy.scrollTo(index, anchor: .center)
                        }
                    }
                }
                .onChange(of: viewStore.forceScroll) { forceScroll in
                    guard forceScroll else { return }
                    if let index = viewStore.progressing.currentLineIndex {
                        scrollProxy.scrollTo(index, anchor: .center)
                    }
                    viewStore.send(.setForceScroll(false))
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
        }
    }
}

import LyricsUIPreviewSupport

struct LyricsView_Previews: PreviewProvider {
    
    static var previews: some View {
        let progressing = LyricsProgressingState(
            lyrics: PreviewResources.lyrics,
            playbackState: .playing(time: 3))
        let store = Store(
            initialState: LyricsViewState(progressing: progressing),
            reducer: Reducer(LyricsViewState.reduce),
            environment: .default
        )
        return Group {
            LyricsView(store: store, showTranslation: true)
                .padding()
                .background(Color.systemBackground)
                .environment(\.colorScheme, .light)
            
            LyricsView(store: store, showTranslation: true)
                .padding()
                .background(Color.systemBackground)
                .environment(\.colorScheme, .dark)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
