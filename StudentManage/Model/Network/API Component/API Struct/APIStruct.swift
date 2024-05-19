//
//  APIStruct.swift
//  StudentManage
//
//  Created by imac-3373 on 2024/3/2.
//

import Foundation

struct authRegister: Encodable {
    
    var firstname: String
    
    var lastname: String
    
    var email: String
    
    var password: String
}

struct authLogin: Encodable {
    
    var email: String
    
    var password: String
}

struct studentRegister: Encodable {
    
    var firstName: String
    
    var lastName: String
    
    var email: String
}

struct studentDelete: Encodable {
    
    var id: Int
    
}

struct studentUpdate: Encodable {
    
    var id: Int
    
    var firstName: String?
    
    var lastName: String?
    
    var email: String?
    
}

struct Empty: Encodable {}

struct Jwttoken: Decodable {
    
    var token: String
}

struct Student: Decodable {
    
    var id: Int
    
    var firstName: String
    
    var lastName: String
    
    var email: String
}


/// 定義User的結構
struct User: Decodable {
    
    var id: Int
    
    var firstname: String
    
    var lastname: String
    
    var email: String
    
    var password: String
    
    var role: String
    
    var enabled: Bool
    
    var credentialsNonExpired: Bool
    
    var authorities: [Authority]
    
    var username: String
    
    var accountNonExpired: Bool
    
    var accountNonLocked: Bool
}

struct Authority: Decodable {
    
    var authority: String
}

struct NoData: Decodable {}
