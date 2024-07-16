//
//  MemberData.swift
//  Fingertapping_ios
//
//  Created by KJW on 2023/05/25.
//

import Foundation

class MemberData: Codable {
    var number: String = ""
    var patient_number: String = ""
    
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        number = try container.decode(String.self, forKey: .number)
        patient_number = try container.decode(String.self, forKey: .patient_number)
    }
    
    private enum CodingKeys: String, CodingKey {
        case number
        case patient_number
    }
    
}
