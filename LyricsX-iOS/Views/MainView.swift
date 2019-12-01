//
//  ContentView.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2020  Xander Deng. Licensed under GPLv3.
//

import SwiftUI
import LyricsUI
import LyricsCore

struct MainView: View {
    
    @ObservedObject var controller: AppController
    
    @State var isAutoScrollEnabled: Bool = true
    
    var body: some View {
        ZStack {
            DefaultArtworkImage()
            LyricsView(lyrics: controller.currentLyrics, isAutoScrollEnabled: $isAutoScrollEnabled)
                .moveFocus(to: controller.currentLineIndex)
                .overlay(
                    HStack {
                        if !isAutoScrollEnabled {
                            Button(action: {
                                self.isAutoScrollEnabled = true
                            }, label: {
                                Image("Action.Track")
                            })
                        }
                    }
                    .accentColor(.white)
                    .padding(20),
                    alignment: .bottomLeading)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(controller: AppController.shared)
    }
}
