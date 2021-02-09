//
//  LyricsSearchingModel.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import ComposableArchitecture
import MusicPlayer

public struct MusicPlayerState: Equatable {
    
    public let availablePlayers: [MusicPlayerProtocol]
    public var selectedPlayer: MusicPlayerProtocol? = nil
    
    public var currentTrack: MusicTrack? = nil
    public var playbackState: PlaybackState = .stopped
    
    public init(availablePlayers: [MusicPlayerProtocol], selectedPlayer: MusicPlayerProtocol? = nil) {
        self.availablePlayers = availablePlayers
        self.selectedPlayer = selectedPlayer
    }
    
    public init(player: MusicPlayerProtocol) {
        self.init(availablePlayers: [player], selectedPlayer: player)
    }
    
    private mutating func syncPlayerState() -> Effect<MusicPlayerAction, Never> {
        var effects: [Effect<MusicPlayerAction, Never>] = []
        if playbackState != selectedPlayer?.playbackState ?? .stopped {
            playbackState = selectedPlayer?.playbackState ?? .stopped
            effects.append(Effect(value: MusicPlayerAction.playbackStateDidChange))
        }
        if currentTrack != selectedPlayer?.currentTrack {
            currentTrack = selectedPlayer?.currentTrack
            effects.append(Effect(value: MusicPlayerAction.currentTrackDidChange))
        }
        if effects.isEmpty {
            return .none
        }
        return Effect.merge(effects)
    }
    
    public static func reduce(state: inout MusicPlayerState, action: MusicPlayerAction, env: MusicPlayerEnvironment) -> Effect<MusicPlayerAction, Never> {
        struct SyncPlayerStateID: Hashable {}
        
        switch action {
        case let .setSelectedPlayer(player):
            state.selectedPlayer = player
            return Effect(value: MusicPlayerAction.startSyncPlayerState)
            
        case .startSyncPlayerState:
            return state.selectedPlayer?.objectWillChange
                .map { MusicPlayerAction.syncPlayerState }
                .receive(on: env.uiSchedular)
                .eraseToEffect()
                .cancellable(id: SyncPlayerStateID(), cancelInFlight: true) ?? .none
        
        case let .playbackAction(action):
            state.selectedPlayer?.perform(action)
            return .none
            
        case .currentTrackDidChange, .playbackStateDidChange:
            return .none
            
        case .syncPlayerState:
            return state.syncPlayerState()
            
        case .forceUpdatePlayerState:
            state.selectedPlayer?.updatePlayerState()
            return Effect(value: MusicPlayerAction.syncPlayerState)
        }
    }
}

public enum MusicPlayerAction: Equatable {
    case setSelectedPlayer(MusicPlayerProtocol)
    case startSyncPlayerState
    case currentTrackDidChange
    case playbackStateDidChange
    case playbackAction(PlaybackAction)
    case syncPlayerState
    case forceUpdatePlayerState
}

public typealias MusicPlayerEnvironment = UISchedularEnvironment

// MARK: - Equatable

extension MusicPlayerState {
    public static func == (lhs: MusicPlayerState, rhs: MusicPlayerState) -> Bool {
        return lhs.selectedPlayer === rhs.selectedPlayer &&
            lhs.currentTrack == rhs.currentTrack &&
            lhs.playbackState == rhs.playbackState
    }
}

extension MusicPlayerAction {
    public static func == (lhs: MusicPlayerAction, rhs: MusicPlayerAction) -> Bool {
        switch (lhs, rhs) {
        case let (.setSelectedPlayer(l), .setSelectedPlayer(r)):
            return l === r
        case let (.playbackAction(l), .playbackAction(r)):
            return l == r
        case (.syncPlayerState, .syncPlayerState):
            return true
        default:
            return false
        }
    }
}
