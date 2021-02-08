//
//  PlaybackAction.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import MusicPlayer

public enum PlaybackAction: Equatable {
    case resume
    case pause
    case playPause
    case seekTo(TimeInterval)
    case nextTrack
    case previousTrack
}

extension MusicPlayerProtocol {
    
    public func perform(_ action: PlaybackAction) {
        switch action {
        case .resume:
            resume()
        case .pause:
            pause()
        case .playPause:
            playPause()
        case let .seekTo(position):
            playbackTime = position
        case .nextTrack:
            skipToNextItem()
        case .previousTrack:
            skipToPreviousItem()
        }
    }
}
