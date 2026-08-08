import Foundation

struct AlgoliaPage: Decodable {
    let hits: [AlgoliaHit]
}

struct AlgoliaHit: Decodable {
    let objectID: String
    let title: String?
    let url: String?
    let author: String?
    let created_at_i: Int
}
