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
    
    @EnvironmentObject
    public var coreStore: ViewStore<LyricsXCoreState, LyricsXCoreAction>
    
    @Binding
    public var isAutoScrollEnabled: Bool
    
    public var showTranslation: Bool
    
    public init(isAutoScrollEnabled: Binding<Bool>, showTranslation: Bool) {
        self._isAutoScrollEnabled = isAutoScrollEnabled
        self.showTranslation = showTranslation
    }
    
    public var body: some View {
        if let progressing = coreStore.progressingState {
            GeometryReader { geometry in
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(progressing.lyrics.lines.indices, id: \.self) { index in
                                LyricsLineView(line: progressing.lyrics.lines[index], showTranslation: showTranslation)
                                    .opacity(progressing.currentLineIndex == index ? 1 : 0.6)
                                    .scaleEffect(progressing.currentLineIndex == index ? 1 : 0.9, anchor: .topLeading)
                                    .animation(.default, value: progressing.currentLineIndex == index)
                                // TODO:
                                if progressing.currentLineIndex == index {
                                    Spacer(minLength: 4)
                                }
                            }
                        }
                        .padding(.vertical, geometry.size.height / 2)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { _ in
                                isAutoScrollEnabled = false
                            }
                    )
                    .onChange(of: progressing.currentLineIndex) { index in
                        if isAutoScrollEnabled, let index = index {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                scrollProxy.scrollTo(index, anchor: .center)
                            }
                        }
                    }
                    .onChange(of: isAutoScrollEnabled) { enabled in
                        if enabled, let index = coreStore.progressingState?.currentLineIndex {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                scrollProxy.scrollTo(index, anchor: .center)
                            }
                        }
                    }
                    .onChange(of: showTranslation) { _ in
                        if let index = coreStore.progressingState?.currentLineIndex {
                            scrollProxy.scrollTo(index, anchor: .center)
                            isAutoScrollEnabled = true
                        }
                    }
                }
            }
            .onAppear {
                coreStore.send(.progressingAction(.recalculateCurrentLineIndex))
            }
        }
        
    }
}

import LyricsUIPreviewSupport

struct LyricsView_Previews: PreviewProvider {
    
    @State
    static var isAutoScrollEnabled = true
    
    static var previews: some View {
        let store = Store(
            initialState: PreviewResources.coreState,
            reducer: Reducer(LyricsProgressingState.reduce)
                .optional()
                .pullback(
                    state: \LyricsXCoreState.progressingState,
                    action: /LyricsXCoreAction.progressingAction,
                    environment: { $0 }),
            environment: .default)
        let viewStore = ViewStore(store)
        return Group {
            LyricsView(isAutoScrollEnabled: $isAutoScrollEnabled, showTranslation: true)
                .environmentObject(viewStore)
                .padding()
                .background(Color.systemBackground)
                .environment(\.colorScheme, .light)
            
            LyricsView(isAutoScrollEnabled: $isAutoScrollEnabled, showTranslation: true)
                .environmentObject(viewStore)
                .padding()
                .background(Color.systemBackground)
                .environment(\.colorScheme, .dark)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
