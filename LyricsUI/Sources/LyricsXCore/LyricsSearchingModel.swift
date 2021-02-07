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
import LyricsService
import MusicPlayer

public struct LyricsSearchingState: Equatable {
    public let track: MusicTrack
    public var searchResultSorted: [Lyrics] = []
    public var currentLyrics: Lyrics? = nil
    public var searchTerm: LyricsSearchRequest.SearchTerm? = nil
    
    public init(track: MusicTrack) {
        self.track = track
    }
    
    private mutating func setSearchTerm(_ term: LyricsSearchRequest.SearchTerm) -> LyricsSearchRequest {
        searchTerm = term
        return LyricsSearchRequest(
            searchTerm: term,
            title: track.title ?? "",
            artist: track.artist ?? "",
            duration: track.duration ?? 0)
    }
    
    private mutating func clearPreviousSearching() {
        searchResultSorted = []
        currentLyrics = nil
        searchTerm = nil
    }
    
    public static func reduce(state: inout LyricsSearchingState, action: LyricsSearchingAction, env: LyricsSearchingEnvironment) -> Effect<LyricsSearchingAction, Never> {
        switch action {
        case .autoSearch:
            state.clearPreviousSearching()
            guard let title = state.track.title, let artist = state.track.artist else {
                state.searchTerm = nil
                return .none
            }
            let req = state.setSearchTerm(.info(title: title, artist: artist))
            return env.searchLyrics(req)
                .map { LyricsSearchingAction.lyricsReceived($0, isAuto: true) }
                .receive(on: env.mainQueue)
                .eraseToEffect()
                .cancellable(id: state.track, cancelInFlight: true)
            
        case let .search(term: term):
            state.clearPreviousSearching()
            let req = state.setSearchTerm(term)
            return env.searchLyrics(req)
                .map { LyricsSearchingAction.lyricsReceived($0, isAuto: false) }
                .receive(on: env.mainQueue)
                .eraseToEffect()
                .cancellable(id: state.track, cancelInFlight: true)
            
        case let .lyricsReceived(lyrics, isAuto):
            let idx = state.searchResultSorted.lastIndex { $0.quality < lyrics.quality } ?? state.searchResultSorted.endIndex
            defer {
                state.searchResultSorted.insert(lyrics, at: idx)
            }
            if isAuto, idx == state.searchResultSorted.startIndex {
                return Just(LyricsSearchingAction.chooseLyrics(lyrics))
                    .eraseToEffect()
            }
            return .none
            
        case let .chooseLyrics(lyrics):
            state.currentLyrics = lyrics
            return .none
        }
    }
}

public enum LyricsSearchingAction: Equatable {
    case autoSearch
    case search(term: LyricsSearchRequest.SearchTerm)
    case lyricsReceived(Lyrics, isAuto: Bool)
    case chooseLyrics(Lyrics)
}

public struct LyricsSearchingEnvironment {
    public let mainQueue: DispatchQueue
    public let searchLyrics: (LyricsSearchRequest) -> AnyPublisher<Lyrics, Never>
    
    init(mainQueue: DispatchQueue = .main, searchLyrics: @escaping (LyricsSearchRequest) -> AnyPublisher<Lyrics, Never>) {
        self.mainQueue = mainQueue
        self.searchLyrics = searchLyrics
    }
}
