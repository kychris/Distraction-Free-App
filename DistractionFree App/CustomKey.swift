//
//  CustomKey.swift
//  DistractionFree App
//
//  Created by Christian Yang on 7/28/20.
//  Copyright © 2020 Christian. All rights reserved.
//

import Foundation
struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}
