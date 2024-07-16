//
//  MemberList.swift
//  Fingertapping_ios
//
//  Created by KJW on 2023/05/15.
//

import Foundation

class MemberList: Codable {
    var member_list: [Member]?
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        member_list = (try? container.decode([Member].self, forKey: .member_list)) ?? nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case member_list
    }
    
}
