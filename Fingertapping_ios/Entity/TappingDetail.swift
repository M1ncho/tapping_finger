//
//  TappingDetail.swift
//  Fingertapping_ios
//
//  Created by KJW on 2023/05/22.
//

import Foundation

class TappingDetail: Codable {
    var time: String = ""
    var thumb_x: Double = 0.0
    var thumb_y: Double = 0.0
    var thumb_z: Double = 0.0
    var index_x: Double = 0.0
    var index_y: Double = 0.0
    var index_z: Double = 0.0
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        time = try values.decode(String.self, forKey: .time)
        thumb_x = try values.decode(Double.self, forKey: .thumb_x)
        thumb_y = try values.decode(Double.self, forKey: .thumb_y)
        thumb_z = try values.decode(Double.self, forKey: .thumb_z)
        index_x = try values.decode(Double.self, forKey: .index_x)
        index_y = try values.decode(Double.self, forKey: .index_y)
        index_z = try values.decode(Double.self, forKey: .index_z)
    }
    
    private enum CodingKeys: String, CodingKey {
        case time
        case thumb_x
        case thumb_y
        case thumb_z
        case index_x
        case index_y
        case index_z
    }
    
}
