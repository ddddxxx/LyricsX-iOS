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
    
    public enum AutoScrollState {
        case focusing
        case awaiting
        case none
    }
    
    @EnvironmentObject
    public var coreStore: ViewStore<LyricsXCoreState, LyricsXCoreAction>
    
    @State
    public var autoScrollState: AutoScrollState = .focusing
    
    public var showTranslation: Bool
    
    public init(showTranslation: Bool) {
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
                                autoScrollState = .none
                            }
                            .onEnded { _ in
                                autoScrollState = .awaiting
                            }
                    )
                    .onChange(of: progressing.currentLineIndex) { _ in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.autoScrollIfNeeded(scrollProxy: scrollProxy)
                        }
                    }
                    .onChange(of: autoScrollState) { _ in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.autoScrollIfNeeded(scrollProxy: scrollProxy)
                        }
                    }
                }
            }
            .onAppear {
                coreStore.send(.progressingAction(.recalculateCurrentLineIndex))
            }
        }
        
    }
    
    private func autoScrollIfNeeded(scrollProxy: ScrollViewProxy) {
        switch autoScrollState {
        case .focusing:
            if let index = coreStore.progressingState?.currentLineIndex {
                scrollProxy.scrollTo(index, anchor: .center)
            }
        case .awaiting:
            autoScrollState = .focusing
        case .none:
            break
        }
    }
}

import LyricsUIPreviewSupport

struct LyricsView_Previews: PreviewProvider {
    
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
            LyricsView(showTranslation: true)
                .environmentObject(viewStore)
                .padding()
                .background(Color.systemBackground)
                .environment(\.colorScheme, .light)
            
            LyricsView(showTranslation: true)
                .environmentObject(viewStore)
                .padding()
                .background(Color.systemBackground)
                .environment(\.colorScheme, .dark)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
