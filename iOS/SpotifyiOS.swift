//
//  SpotifyiOS
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if false

import Foundation
import CXShim
import MusicPlayer

extension MusicPlayers {
    
    public class SpotifyiOS: NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
        
        public static let accessTokenDefaultsKey = "ddddxxx.LyricsKit.SpotifyAccessToken"
        
        @Published public private(set) var currentTrack: MusicTrack?
        @Published public private(set) var playbackState: PlaybackState = .stopped
        
        private let appRemote: SPTAppRemote
        
        public init(clientID: String, redirectURL: URL) {
            let configuration = SPTConfiguration(clientID: clientID, redirectURL: redirectURL)
            appRemote = SPTAppRemote(configuration: configuration, logLevel: .info)
            super.init()
            appRemote.delegate = self
            
            let accessToken = UserDefaults.standard.string(forKey: SpotifyiOS.accessTokenDefaultsKey)
            appRemote.connectionParameters.accessToken = accessToken
            appRemote.connect()
        }
        
        private func addObserver() {
            NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        }
        
        private func attemptConnect() {
            SPTAppRemote.checkIfSpotifyAppIsActive { active in
                if active {
                    self.appRemote.connect()
                }
            }
        }
        
        public func requestAuthorization() {
            appRemote.authorizeAndPlayURI("")
        }
        
        public func getAccessTokenAndConnect(from url: URL) -> Bool {
            if let token = appRemote.authorizationParameters(from: url)?[SPTAppRemoteAccessTokenKey] {
                UserDefaults.standard.set(token, forKey: SpotifyiOS.accessTokenDefaultsKey)
                appRemote.connectionParameters.accessToken = token
                appRemote.connect()
                return true
            }
            return false
        }
        
        public func updatePlayerState() {
            appRemote.playerAPI?.getPlayerState({ state, _ in
                if let state = state as! SPTAppRemotePlayerState? {
                    self.playerStateDidChange(state)
                }
            })
        }
        
        // MARK: -
        
        @objc private func applicationDidBecomeActiveNotification(_ n: Notification) {
            if UserDefaults.standard.object(forKey: SpotifyiOS.accessTokenDefaultsKey) != nil {
                appRemote.connect()
            }
        }
        
        @objc private func applicationWillResignActiveNotification(_ n: Notification) {
            if appRemote.isConnected {
                appRemote.disconnect()
            }
        }
        
        // MARK: - SPTAppRemoteDelegate
        
        public func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
            appRemote.playerAPI?.delegate = self
            appRemote.playerAPI?.subscribe(toPlayerState: nil)
            updatePlayerState()
        }
        
        public func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
            // TODO: clean up invalid or expired access token
        }
        
        public func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
            
        }
        
        // MARK: SPTAppRemotePlayerStateDelegate
        
        public func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
            let newState = playerState.playbackState
            let newTrack = playerState.track.track
            if currentTrack?.id != newTrack.id {
                currentTrack = newTrack
                playbackState = newState
            } else if !playbackState.approximateEqual(to: newState, tolerate: 1) {
                playbackState = newState
            }
        }
    }
}

extension MusicPlayers.SpotifyiOS: MusicPlayerProtocol, CXShim.ObservableObject {
    
    public var name: MusicPlayerName? {
        return .spotify
    }
    
    public var playbackTime: TimeInterval {
        get {
            return playbackState.time
        }
        set(newValue) {
            guard appRemote.isConnected else { return }
            playbackState = playbackState.withTime(newValue)
            let positionInMs = Int(newValue * 1000)
            appRemote.playerAPI?.seek(toPosition: positionInMs, callback: nil)
        }
    }
    
    public var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> {
        return $currentTrack.eraseToAnyPublisher()
    }
    
    public var playbackStateWillChange: AnyPublisher<PlaybackState, Never> {
        return $playbackState.eraseToAnyPublisher()
    }
    
    public func resume() {
        appRemote.playerAPI?.resume(nil)
    }
    
    public func pause() {
        appRemote.playerAPI?.pause(nil)
    }
    
    public func playPause() {
        if playbackState.isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    public func skipToNextItem() {
        appRemote.playerAPI?.skip(toNext: nil)
    }
    
    public func skipToPreviousItem() {
        appRemote.playerAPI?.skip(toPrevious: nil)
    }
}

// MARK: - Extensions

extension SPTAppRemoteTrack {
    
    var track: MusicTrack {
        let durationInSec = TimeInterval(duration) / 1000
        // TODO: Artwork
        return MusicTrack(id: uri, title: name, album: album.name, artist: artist.name, duration: durationInSec)
    }
}

extension SPTAppRemotePlayerState {
    
    var playbackState: PlaybackState {
        let time = TimeInterval(playbackPosition) / 1000
        return isPaused ? .paused(time: time) : .playing(time: time)
    }
}

extension PlaybackState {
    func withTime(_ time: TimeInterval) -> PlaybackState {
        switch self {
        case .stopped:  return .stopped
        case .playing:  return .playing(time: time)
        case .paused:   return .paused(time: time)
        case .fastForwarding:   return .fastForwarding(time: time)
        case .rewinding:        return .rewinding(time: time)
        }
    }
}

#if false

extension MusicPlayers.SpotifyiOS: PlaybackModeSettable {
    
    public var repeatMode: MusicRepeatMode {
        get {
            // TODO: get repeat mode
            return .off
        }
        set {
            appRemote.playerAPI?.setRepeatMode(.init(newValue), callback: nil)
        }
    }
    
    public var shuffleMode: MusicShuffleMode {
        get {
            // TODO: get repeat mode
            return .off
        }
        set {
            let shuffle = newValue != .off
            appRemote.playerAPI?.setShuffle(shuffle, callback: nil)
        }
    }
}

extension SPTAppRemotePlaybackOptionsRepeatMode {

    var mode: MusicRepeatMode {
        switch self {
        case .off: return .off
        case .track: return .one
        case .context: return .all
        @unknown default: return .off
        }
    }

    init(_ mode: MusicRepeatMode) {
        switch mode {
        case .off: self = .off
        case .one: self = .track
        case .all: self = .context
        }
    }
}

#endif

#endif
