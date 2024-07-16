//
//  FingerData.swift
//  Fingertapping_ios
//
//  Created by KJW on 2023/05/22.
//

import Foundation

class FingerData: Codable {
    var member_id: Int = 0
    var tapping_number: Int = 0
    var hand_type: Int = 0
    var finger_max_height: Int?
    var finger_data_details: [TappingDetail]?
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        member_id = try values.decode(Int.self, forKey: .member_id)
        tapping_number = try values.decode(Int.self, forKey: .tapping_number)
        hand_type = try values.decode(Int.self, forKey: .hand_type)
        finger_max_height = (try? values.decode(Int.self, forKey: .finger_max_height)) ?? nil
        finger_data_details = (try? values.decode([TappingDetail].self, forKey: .finger_data_details)) ?? nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case member_id
        case tapping_number
        case hand_type
        case finger_max_height
        case finger_data_details
    }
    
}
