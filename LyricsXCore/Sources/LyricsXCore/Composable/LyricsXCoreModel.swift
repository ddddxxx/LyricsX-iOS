//
//  LyricsXCoreModel.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import ComposableArchitecture
import LyricsService

public struct LyricsXCoreState: Equatable {
    
    public var playerState: MusicPlayerState
    public var searchingState: LyricsSearchingState?
    public var progressingState: LyricsProgressingState?
    
    public init(playerState: MusicPlayerState, searchingState: LyricsSearchingState? = nil, progressingState: LyricsProgressingState? = nil) {
        self.playerState = playerState
        self.searchingState = searchingState
        self.progressingState = progressingState
    }
    
    public static func reduce(state: inout LyricsXCoreState, action: LyricsXCoreAction, env: LyricsXCoreEnvironment) -> Effect<LyricsXCoreAction, Never> {
        struct UpdatePlaybackStateID: Hashable{}
        
        switch action {
        case .onAppActivate:
            var actions = [LyricsXCoreAction.playerAction(.startSyncPlayerState), .playerAction(.forceUpdatePlayerState)]
            if state.progressingState != nil {
                actions.append(.progressingAction(.recalculateCurrentLineIndex))
            }
            return actions.publisher.eraseToEffect()
        
        case .playerAction(.currentTrackDidChange):
            state.searchingState = state.playerState.currentTrack.map(LyricsSearchingState.init(track:))
            state.progressingState = nil
            return Effect.merge([
                .cancel(id: UpdatePlaybackStateID()),
                Effect(value: LyricsXCoreAction.searchingAction(.autoSearch)),
            ])
            
        case .playerAction(.playbackStateDidChange):
            guard state.progressingState != nil else { return .none }
            return Effect(value: LyricsXCoreAction.progressingAction(.playbackStateUpdated(state.playerState.playbackState)))
                .cancellable(id: UpdatePlaybackStateID())
            
        case let .searchingAction(.setCurrentLyrics(lyrics)):
            state.progressingState = LyricsProgressingState(lyrics: lyrics, playbackState: state.playerState.playbackState)
            return Effect(value: LyricsXCoreAction.progressingAction(.recalculateCurrentLineIndex))
            
        default:
            return .none
        }
    }
}

public enum LyricsXCoreAction: Equatable {
    case playerAction(MusicPlayerAction)
    case searchingAction(LyricsSearchingAction)
    case progressingAction(LyricsProgressingAction)
    case onAppActivate
}

public typealias LyricsXCoreEnvironment = UISchedularEnvironment

public let lyricsXCoreReducer = Reducer<LyricsXCoreState, LyricsXCoreAction, LyricsXCoreEnvironment>.combine(
    Reducer(MusicPlayerState.reduce)
        .pullback(
            state: \LyricsXCoreState.playerState,
            action: /LyricsXCoreAction.playerAction,
            environment: { $0 }),
    Reducer(LyricsSearchingState.reduce)
        .optional()
        .pullback(
            state: \LyricsXCoreState.searchingState,
            action: /LyricsXCoreAction.searchingAction,
            environment: { LyricsSearchingEnvironment(uiSchedular: $0.uiSchedular, lyricsProvider: LyricsProviders.Group()) }),
    Reducer(LyricsProgressingState.reduce)
        .optional()
        .pullback(
            state: \LyricsXCoreState.progressingState,
            action: /LyricsXCoreAction.progressingAction,
            environment: { $0 }),
    Reducer(LyricsXCoreState.reduce)
)
