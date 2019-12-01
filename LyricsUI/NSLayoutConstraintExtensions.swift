//
//  NSLayoutConstraintExtensions.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2020  Xander Deng. Licensed under GPLv3.
//

import UIKit

extension NSLayoutConstraint {
    
    func activate() {
        self.isActive = true
    }
    
    func withPriority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}
