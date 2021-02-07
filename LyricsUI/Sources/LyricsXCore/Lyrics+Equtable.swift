//
//  Lyrics+Equtable.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import LyricsCore

// TODO: move to LyricsKit
extension Lyrics: Equatable {
    public static func == (lhs: Lyrics, rhs: Lyrics) -> Bool {
        return lhs.idTags == rhs.idTags &&
//            lhs.metadata == rhs.metadata &&
            lhs.lines == rhs.lines
    }
}
