import Foundation
import UIKit

class User {
    var id: UInt
    var name: String?
    var imageUrl: String?
    
    init(id: UInt, name: String?, imageUrl: String?) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
    }
}