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
        self.currentTrack = selectedPlayer?.currentTrack
        self.playbackState = selectedPlayer?.playbackState ?? .stopped
    }
    
    public init(player: MusicPlayerProtocol) {
        self.init(availablePlayers: [player], selectedPlayer: player)
    }
    
    private mutating func syncPlayerState() {
        currentTrack = selectedPlayer?.currentTrack
        playbackState = selectedPlayer?.playbackState ?? .stopped
    }
    
    public static func reduce(state: inout MusicPlayerState, action: MusicPlayerAction, env: MusicPlayerEnvironment) -> Effect<MusicPlayerAction, Never> {
        switch action {
        case let .setSelectedPlayer(player):
            state.selectedPlayer = player
            state.currentTrack = player.currentTrack
            state.playbackState = player.playbackState
            return player.objectWillChange
                .map { MusicPlayerAction.syncPlayerState }
                .receive(on: env.mainQueue)
                .eraseToEffect()
        
        case .syncPlayerState:
            state.syncPlayerState()
            return .none
        
        case let .playback(action):
            state.selectedPlayer?.perform(action)
            return .none
        }
    }
}

public enum MusicPlayerAction: Equatable {
    case setSelectedPlayer(MusicPlayerProtocol)
    case syncPlayerState
    case playback(PlaybackAction)
}

public struct MusicPlayerEnvironment {
    public let mainQueue: DispatchQueue
    
    init(mainQueue: DispatchQueue = .main) {
        self.mainQueue = mainQueue
    }
}

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
        case let (.playback(l), .playback(r)):
            return l == r
        case (.syncPlayerState, .syncPlayerState):
            return true
        default:
            return false
        }
    }
}
