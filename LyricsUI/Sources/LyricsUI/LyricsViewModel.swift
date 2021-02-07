//
//  LyricsViewStore.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import ComposableArchitecture
import LyricsXCore
import LyricsCore
import MusicPlayer

public struct LyricsViewState: Equatable {
    
    public var progressing: LyricsProgressingState
    
    public var showTranslation: Bool
    public var isAutoScrollEnabled: Bool = true
    
    public init(progressing: LyricsProgressingState, showTranslation: Bool) {
        self.progressing = progressing
        self.showTranslation = showTranslation
    }
}

public enum LyricsViewAction: Equatable {
    case progressing(LyricsProgressingAction)
    case lyricsLineTapped(index: Int)
    case setAutoScrollEnabled(Bool)
    case onDrag
    case onDragEnded
}

public struct LyricsViewEnvironment {
    public let progressing: LyricsProgressingEnvironment
    
    public init(progressing: LyricsProgressingEnvironment) {
        self.progressing = progressing
    }
}

public let lyricsViewReducer = Reducer<LyricsViewState, LyricsViewAction, LyricsViewEnvironment> { state, action, env in
    struct DelayedSetAutoScrollID: Hashable {}
    
    switch action {
    case let .progressing(action):
        switch action {
        case .playbackStateUpdated(_):
            return Just(LyricsViewAction.setAutoScrollEnabled(true))
                .eraseToEffect()
        default:
            return .none
        }
    
    case let .lyricsLineTapped(index):
        // TODO: lyricsLineTapped
        state.progressing.playbackState = .playing(time: state.progressing.lyrics.lines[index].position)
        return state.progressing.recalculateCurrentLineIndex(environment: env.progressing)
            .map(LyricsViewAction.progressing)
            .cancellable(id: state.progressing.currentLineCalculationCancelID, cancelInFlight: true)
        
    case let .setAutoScrollEnabled(enabled):
        state.isAutoScrollEnabled = enabled
        if enabled {
            return .cancel(id: DelayedSetAutoScrollID())
        } else {
            return Just(LyricsViewAction.setAutoScrollEnabled(true))
                .delay(for: .seconds(5), scheduler: env.progressing.mainQueue)
                .eraseToEffect()
                .cancellable(id: state.progressing.currentLineCalculationCancelID, cancelInFlight: true)
        }
        
    case .onDrag:
        state.isAutoScrollEnabled = false
        return .cancel(id: DelayedSetAutoScrollID())
        
    case .onDragEnded:
        return Just(LyricsViewAction.setAutoScrollEnabled(true))
            .delay(for: .seconds(5), scheduler: env.progressing.mainQueue)
            .eraseToEffect()
            .cancellable(id: state.progressing.currentLineCalculationCancelID, cancelInFlight: true)
    }
}