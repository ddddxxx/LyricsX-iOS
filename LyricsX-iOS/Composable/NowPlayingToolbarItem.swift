//
//  NowPlayingToolbarItem.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import MusicPlayer

struct NowPlayingToolbarItem: ToolbarContent {
    
    let track: MusicTrack?
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            ContentView(track: track)
        }
    }
    
    struct ContentView: View {
        
        let track: MusicTrack?
        
        var body: some View {
            if let track = track {
                VStack {
                    Text(track.title ?? "-")
                        .font(.headline)
                    Text(track.artist ?? "-")
                        .font(.subheadline)
                }
            }
        }
    }
}

struct NowPlayingToolbarItem_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingToolbarItem.ContentView(track: MusicTrack(id: "0", title: "No Surprises", album: "OK Computer", artist: "Radiohead"))
            .previewLayout(.fixed(width: 300, height: 44))
    }
}
