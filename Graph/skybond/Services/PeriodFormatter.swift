//
//  PeriodFormatter.swift
//  skybond
//
//  Created by Daniyar Salakhutdinov on 03.06.2018.
//  Copyright © 2018 Daniyar Salakhutdinov. All rights reserved.
//

import UIKit
import SwiftDate

class PeriodFormatter: PeriodFormatterProtocol {
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter
    }()
    
    func titleForDateBeforeCurrent(subtracting component: Calendar.Component, value: Int) -> String {
        let date = Date().add(components: [component : -value])
        return formatter.string(from: date)
    }
}
