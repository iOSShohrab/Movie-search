//
//  ImageDownloader.swift
//  Movie Search
//
//  Created by Walid Hossain on 15/3/21.
//

import UIKit

class ImageDownloader: Operation {
    
    var movie: Movie
    
    init(_ movie: Movie) {
        self.movie = movie
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        
        
        guard let imageData = try? Data(contentsOf: URL(string: "https://image.tmdb.org/t/p/w500\(movie.poster_path ?? "")")!) else { return }
        
        
        if isCancelled {
            return
        }
        
        
        if !imageData.isEmpty {
            movie.posterImage = UIImage(data:imageData)
            movie.state = .downloaded
        } else {
            movie.state = .failed
            movie.posterImage = UIImage(named: "NotFound")
        }
    }
}

class PendingOperations {
  lazy var downloadsInProgress: [IndexPath: Operation] = [:]
  lazy var downloadQueue: OperationQueue = {
    var queue = OperationQueue()
    queue.name = "Download queue"
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
}
