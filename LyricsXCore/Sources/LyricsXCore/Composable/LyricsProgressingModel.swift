//
//  LyricsProgressingModel.swift
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

public struct LyricsProgressingState: Equatable {
    
    public let lyrics: Lyrics
    public var playbackState: PlaybackState = .stopped
    
    public var currentLineIndex: Int? = nil
    public private(set) var lyricsOffset: Int {
        didSet {
            lyrics.offset = lyricsOffset
        }
    }
    
    public init(lyrics: Lyrics, playbackState: PlaybackState) {
        self.lyrics = lyrics
        self.playbackState = playbackState
        self.lyricsOffset = lyrics.offset
        _ = recalculateCurrentLineIndex(environment: .default)
    }
    
    public mutating func recalculateCurrentLineIndex(environment: LyricsProgressingEnvironment) -> Effect<LyricsProgressingAction, Never> {
        let offset = playbackState.time + lyrics.timeDelay
        let (index, next) = lyrics[offset]
        currentLineIndex = index
        if let next = next, playbackState.isPlaying {
            let dt = lyrics.lines[next].position - offset
            return Just(LyricsProgressingAction.recalculateCurrentLineIndex)
                .delay(for: .seconds(dt), tolerance: .milliseconds(20), scheduler: environment.uiSchedular)
                .eraseToEffect()
        } else {
            return .none
        }
    }
    
    private var currentLineCalculationCancelID: Int {
        return ObjectIdentifier(lyrics).hashValue
    }
    
    public static func reduce(state: inout LyricsProgressingState, action: LyricsProgressingAction, env: LyricsProgressingEnvironment) -> Effect<LyricsProgressingAction, Never> {
        struct PlaybackStateUpdateID: Hashable {}
        switch action {
        case let .playbackStateUpdated(playbackState):
            state.playbackState = playbackState
            return state.recalculateCurrentLineIndex(environment: env)
                .cancellable(id: state.currentLineCalculationCancelID, cancelInFlight: true)
            
        case .recalculateCurrentLineIndex:
            return state.recalculateCurrentLineIndex(environment: env)
                .cancellable(id: state.currentLineCalculationCancelID, cancelInFlight: true)
            
        case let .setLyricsOffset(offset):
            state.lyricsOffset = offset
            return state.recalculateCurrentLineIndex(environment: env)
                .cancellable(id: state.currentLineCalculationCancelID, cancelInFlight: true)
        }
    }
}

public enum LyricsProgressingAction: Equatable {
    case playbackStateUpdated(PlaybackState)
    case setLyricsOffset(Int)
    case recalculateCurrentLineIndex
}

public typealias LyricsProgressingEnvironment = UISchedularEnvironment
