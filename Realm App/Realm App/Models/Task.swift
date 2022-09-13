//
//  Task.swift
//  Realm App
//
//  Created by Apple Macbook Pro 13 on 13.09.22.
//

import Foundation
import RealmSwift

class Task: Object {
    @Persisted var name = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplete = false
}
