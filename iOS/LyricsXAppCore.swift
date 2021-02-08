//
//  LyricsXAppCore.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import ComposableArchitecture
import LyricsCore
import MusicPlayer
import LyricsXCore
import LyricsUI

struct LyricsXAppState: Equatable {
    
    var playerState: MusicPlayerState
    var lyricsProgressing: LyricsProgressingState?
    var lyricsSearching: LyricsSearchingState
}

enum LyricsXAppAction: Equatable {
    
    case player(MusicPlayerAction)
    case lyricsView(LyricsViewAction)
}
