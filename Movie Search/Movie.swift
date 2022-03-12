//
//  Movie.swift
//  Movie Search
//
//  Created by Walid Hossain on 14/3/21.
//

import UIKit

class Movie: Decodable {
    let id : Int?
    let title : String?
    let overview : String?
    let poster_path : String?
    var state : PosterState?
    var posterImage : UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case overview = "overview"
        case poster_path = "poster_path"
        case state = "state"
        case posterImage = "posterImage"
        
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        overview = try values.decodeIfPresent(String.self, forKey: .overview)
        poster_path = try values.decodeIfPresent(String.self, forKey: .poster_path)
        state = .new
        posterImage = UIImage(named: "Placeholder")
    }
}

enum PosterState: Decodable {
    case new, downloaded, failed
    
    init(from decoder: Decoder) throws {
        let state = try decoder.singleValueContainer().decode(String.self)
        switch state {
            case "new": self = .new
            case "downloaded": self = .downloaded
            case "failed": self = .failed
            default: self = .new
        }
    }
    
    
}


