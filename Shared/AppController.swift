//
//  AppController.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2020  Xander Deng. Licensed under GPLv3.
//

import Foundation
import CXShim
import CXExtensions
import MusicPlayer
import LyricsService

class AppController: ObservableObject {
    
    static let shared = AppController()
    
    let lyricsManager = LyricsProviders.Group(service: LyricsProviders.Service.allCases)
    let musicPlayer = MusicPlayers.AppleMusic()
    
    @Published var currentLyrics: Lyrics? {
        willSet {
            self.currentLineIndex = nil
        }
        didSet {
            scheduleCurrentLineCheck()
        }
    }
    
    @Published var currentLineIndex: Int?
    
    var searchRequest: LyricsSearchRequest?
    var searchCanceller: Cancellable?
    
    private var cancelBag = Set<AnyCancellable>()
    
    private init() {
        musicPlayer.currentTrackWillChange
            .signal()
            .receive(on: DispatchQueue.global().cx)
            .invoke(AppController.currentTrackChanged, weaklyOn: self)
            .store(in: &cancelBag)
        musicPlayer.playbackStateWillChange
            .signal()
            .receive(on: DispatchQueue.global().cx)
            .invoke(AppController.scheduleCurrentLineCheck, weaklyOn: self)
            .store(in: &cancelBag)
        currentTrackChanged()
    }
    
    var currentLineCheckSchedule: Cancellable?
    func scheduleCurrentLineCheck() {
        currentLineCheckSchedule?.cancel()
        guard let lyrics = currentLyrics else {
            return
        }
        let playbackTime = musicPlayer.playbackTime
        let (index, next) = lyrics[playbackTime + lyrics.timeDelay]
        if currentLineIndex != index {
            DispatchQueue.main.async {
                self.currentLineIndex = index
            }
        }
        if let next = next {
            let dt = lyrics.lines[next].position - playbackTime - lyrics.timeDelay
            let q = DispatchQueue.global().cx
            currentLineCheckSchedule = q.schedule(after: q.now.advanced(by: .seconds(dt)), interval: .seconds(42), tolerance: .milliseconds(20)) { [unowned self] in
                self.scheduleCurrentLineCheck()
            }
        }
    }
    
    func currentTrackChanged() {
//        if currentLyrics?.metadata.needsPersist == true {
//            currentLyrics?.persist()
//        }
        DispatchQueue.main.async {
            self.currentLyrics = nil
            self.currentLineIndex = nil
        }
        searchCanceller?.cancel()
        guard let track = musicPlayer.currentTrack else {
            return
        }
        // FIXME: deal with optional value
        let title = track.title ?? ""
        let artist = track.artist ?? ""
        
        // TODO: read local lyrics
        
        let duration = track.duration ?? 0
        let req = LyricsSearchRequest(searchTerm: .info(title: title, artist: artist),
                                      title: title,
                                      artist: artist,
                                      duration: duration,
                                      limit: 5,
                                      timeout: 10)
        searchRequest = req
        searchCanceller = lyricsManager.lyricsPublisher(request: req)
            .invoke(AppController.lyricsReceived, weaklyOn: self)
            .cancel(after: .seconds(10), scheduler: DispatchQueue.global().cx)
    }
    
    // MARK: LyricsSourceDelegate
    
    func lyricsReceived(lyrics: Lyrics) {
        guard let req = searchRequest,
            lyrics.metadata.request == req else {
            return
        }
        if let current = currentLyrics, current.quality >= lyrics.quality {
            return
        }
//        lyrics.filtrate()
//        lyrics.recognizeLanguage()
//        lyrics.metadata.needsPersist = true
        DispatchQueue.main.async {
            self.currentLyrics = lyrics
        }
    }
}
