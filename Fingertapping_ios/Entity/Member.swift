//
//  Member.swift
//  Fingertapping_ios
//
//  Created by KJW on 2023/05/15.
//

import Foundation

class Member : Codable {
    
    var member_id: Int = 0
    var number: String = ""
    var patient_number: String = ""
    var gender: String?
    var birth_date: String?
    var data_count: Int = 0
    
    
    init () {
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        member_id = try values.decode(Int.self, forKey: .member_id)
        number = try values.decode(String.self, forKey: .number)
        patient_number = try values.decode(String.self, forKey: .patient_number)
        gender = (try? values.decode(String.self, forKey: .gender)) ?? nil
        birth_date = (try? values.decode(String.self, forKey: .birth_date)) ?? nil
        data_count = try values.decode(Int.self, forKey: .data_count)
    }
    
    private enum CodingKeys: String, CodingKey {
        case member_id
        case number
        case patient_number
        case gender
        case birth_date
        case data_count
    }
    
}
