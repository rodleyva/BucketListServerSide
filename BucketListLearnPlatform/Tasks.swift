//
//  Tasks.swift
//  BucketListLearnPlatform
//
//  Created by Rodrigo Leyva on 10/19/21.
//

import Foundation

class Tasks: Codable{
    var id: UUID?
    let createdAt: Date?
    var objective: String?
    
    init(id: UUID?, createdAt: Date?, objective: String?){
        self.id = id
        self.createdAt = createdAt
        self.objective = objective
    }
}
