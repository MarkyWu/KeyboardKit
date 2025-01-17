//
//  InputSetRows.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-03.
//  Copyright © 2021 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This typealias represents a list of input set rows.
 */
public typealias InputSetRows = [InputSetRow]

public extension InputSetRows {

    /**
     Get all input characters for a certain keyboard casing.
     */
    func characters(for casing: KeyboardCasing = .lowercased) -> [[String]] {
        map { $0.characters(for: casing) }
    }
}
