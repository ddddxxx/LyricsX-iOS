//
//  FeatherEdgeMask.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

struct FeatherEdgeMask: View {
    
    let edges: Edge.Set
    let depthPercentage: CGFloat
    
    init(edges: Edge.Set = .all, depthPercentage: CGFloat = 0.1) {
        self.edges = edges
        self.depthPercentage = depthPercentage
    }
    
    var body: some View {
        let edgeColor = Color.clear
        let fillColor = Color.white
        var hGradient: LinearGradient?
        var vGradient: LinearGradient?
        if !edges.isDisjoint(with: .horizontal) {
            var hStops: [Gradient.Stop] = []
            if edges.contains(.leading) {
                hStops.append(.init(color: edgeColor, location: 0))
                hStops.append(.init(color: fillColor, location: depthPercentage))
            } else {
                hStops.append(.init(color: fillColor, location: 0))
            }
            if edges.contains(.trailing) {
                hStops.append(.init(color: fillColor, location: 1 - depthPercentage))
                hStops.append(.init(color: edgeColor, location: 1))
            } else {
                hStops.append(.init(color: fillColor, location: 1))
            }
            hGradient = LinearGradient(
                gradient: Gradient(stops: hStops),
                startPoint: .leading,
                endPoint: .trailing)
        }
        if !edges.isDisjoint(with: .vertical) {
            var vStops: [Gradient.Stop] = []
            if edges.contains(.top) {
                vStops.append(.init(color: edgeColor, location: 0))
                vStops.append(.init(color: fillColor, location: depthPercentage))
            } else {
                vStops.append(.init(color: fillColor, location: 0))
            }
            if edges.contains(.bottom) {
                vStops.append(.init(color: fillColor, location: 1 - depthPercentage))
                vStops.append(.init(color: edgeColor, location: 1))
            } else {
                vStops.append(.init(color: fillColor, location: 1))
            }
            vGradient = LinearGradient(
                gradient: Gradient(stops: vStops),
                startPoint: .top,
                endPoint: .bottom)
        }
        switch (hGradient, vGradient) {
        case let (v1?, v2?):
            return AnyView(v2.mask(v1))
        case let (v1?, nil):
            return AnyView(v1)
        case let (nil, v2?):
            return AnyView(v2)
        case (nil, nil):
            return AnyView(EmptyView())
        }
    }
}

struct FeatherEdgeMask_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Color.white
                .mask(FeatherEdgeMask(depthPercentage: 0.2))
            Color.white
                .mask(FeatherEdgeMask(
                        edges: .horizontal,
                        depthPercentage: 0.2))
            Color.white
                .mask(FeatherEdgeMask(
                        edges: .top,
                        depthPercentage: 0.2))
        }
        .previewLayout(.fixed(width: 100, height: 100))
        .background(Color.black)
    }
}
