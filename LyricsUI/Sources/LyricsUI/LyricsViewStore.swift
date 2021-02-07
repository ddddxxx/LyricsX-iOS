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
import LyricsCore
import MusicPlayer

extension Lyrics: Equatable {
    public static func == (lhs: Lyrics, rhs: Lyrics) -> Bool {
        return lhs === rhs
    }
}

public struct LyricsViewState: Equatable {
    
    public let lyrics: Lyrics
    public var playbackState: PlaybackState = .stopped
    
    public var showTranslation: Bool
    public var isAutoScrollEnabled: Bool = true
    
    public var currentLineIndex: Int? = nil
    
    public init(lyrics: Lyrics, showTranslation: Bool) {
        self.lyrics = lyrics
        self.showTranslation = showTranslation
    }
    
    public mutating func recalculateCurrentLineIndex(environment: LyricsViewEnvironment) -> Effect<LyricsViewAction, Never> {
        let offset = playbackState.time + lyrics.timeDelay
        let (index, next) = lyrics[offset]
        currentLineIndex = index
        if let next = next, playbackState.isPlaying {
            let dt = lyrics.lines[next].position - offset
            return Just(LyricsViewAction.recalculateCurrentLineIndex)
                .delay(for: .seconds(dt), tolerance: .milliseconds(20), scheduler: environment.mainQueue)
                .eraseToEffect()
        } else {
            return .none
        }
    }
}

public enum LyricsViewAction: Equatable {
    case onAppear
    case onDisappear
    case playbackStateUpdated(PlaybackState)
    case recalculateCurrentLineIndex
    case lyricsLineTapped(index: Int)
    case setAutoScrollEnabled(Bool)
    case onDrag
    case onDragEnded
}

public struct LyricsViewEnvironment {
    public let mainQueue: DispatchQueue
    public let playbackStateUpdate: AnyPublisher<PlaybackState, Never>
    
    public init(mainQueue: DispatchQueue = .main, playbackStateUpdate: AnyPublisher<PlaybackState, Never>) {
        self.mainQueue = mainQueue
        self.playbackStateUpdate = playbackStateUpdate
    }
}

public let lyricsViewReducer = Reducer<LyricsViewState, LyricsViewAction, LyricsViewEnvironment> { state, action, env in
    struct CurrentLineCalculationID: Hashable {}
    struct PlayerStateUpdateID: Hashable {}
    struct DelayedSetAutoScrollID: Hashable {}
    
    switch action {
    case .onAppear:
        return env.playbackStateUpdate
            .map(LyricsViewAction.playbackStateUpdated)
            .receive(on: env.mainQueue)
            .eraseToEffect()
            .cancellable(id: PlayerStateUpdateID())
        
    case .onDisappear:
        return .cancel(id: PlayerStateUpdateID())
        
    case let .playbackStateUpdated(playbackState):
        state.playbackState = playbackState
        return state
            .recalculateCurrentLineIndex(environment: env)
            .cancellable(id: CurrentLineCalculationID(), cancelInFlight: true)
        
    case .recalculateCurrentLineIndex:
        return state
            .recalculateCurrentLineIndex(environment: env)
            .cancellable(id: CurrentLineCalculationID(), cancelInFlight: true)
        
    case let .lyricsLineTapped(index):
        // TODO: lyricsLineTapped
        state.playbackState = .playing(time: state.lyrics.lines[index].position)
        return state
            .recalculateCurrentLineIndex(environment: env)
            .cancellable(id: CurrentLineCalculationID(), cancelInFlight: true)
        
    case let .setAutoScrollEnabled(enabled):
        state.isAutoScrollEnabled = enabled
        if enabled {
            return .cancel(id: DelayedSetAutoScrollID())
        } else {
            return Just(LyricsViewAction.setAutoScrollEnabled(true))
                .delay(for: .seconds(5), scheduler: env.mainQueue)
                .eraseToEffect()
                .cancellable(id: DelayedSetAutoScrollID(), cancelInFlight: true)
        }
        
    case .onDrag:
        state.isAutoScrollEnabled = false
        return .cancel(id: DelayedSetAutoScrollID())
        
    case .onDragEnded:
        return Just(LyricsViewAction.setAutoScrollEnabled(true))
            .delay(for: .seconds(5), scheduler: env.mainQueue)
            .eraseToEffect()
            .cancellable(id: DelayedSetAutoScrollID(), cancelInFlight: true)
    }
}
