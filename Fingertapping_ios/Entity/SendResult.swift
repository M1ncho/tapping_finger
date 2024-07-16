//
//  SendResult.swift
//  Fingertapping_ios
//
//  Created by KJW on 2023/05/22.
//

import Foundation

class SendResult: Codable {
    var result: Bool
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        result = try values.decode(Bool.self, forKey: .result)
    }
    
    private enum CodingKeys: String, CodingKey {
        case result
    }
    
}
