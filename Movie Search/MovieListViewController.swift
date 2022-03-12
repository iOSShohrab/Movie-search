//
//  ViewController.swift
//  Movie Search
//
//  Created by Walid Hossain on 14/3/21.
//

import UIKit

let dataSourceURL = "https://api.themoviedb.org/3/search/movie?api_key=2a61185ef6a27f400fd92820ad9e8537"

class MovieListViewController: UIViewController {
    
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var moviewSearchBar: UISearchBar!
    
    var movies:[Movie] = [Movie]()
    
    
    let pendingOperations = PendingOperations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    func fetchMovieSearchResult(_ searchText: String) {
        let request = URLRequest(url: URL(string: "\(dataSourceURL)&query=\(searchText)")!)
        
        let task = URLSession(configuration: .default).dataTask(with: request) { data, response, error in
            
            let alertController = UIAlertController(title: "Oops!",
                                                    message: "There was an error fetching photo details.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            
            if let data = data {
                do {
                    let datasourceDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                    if let results = datasourceDictionary!["results"] {
                        if let moviesdata = try? JSONSerialization.data(withJSONObject: results, options: []) {
                            
                            let movies: [Movie] = try! JSONDecoder().decode([Movie].self, from: moviesdata)
                            self.movies = movies
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.movieTableView.reloadData()
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        task.resume()
    }
    
    func suspendAllOperations() {
        pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        pendingOperations.downloadQueue.isSuspended = false
    }
    
    
    func loadImagesForOnscreenCells() {
        
        if let pathsArray = movieTableView.indexPathsForVisibleRows {
            
            let allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
            
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtract(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            for indexPath in toBeCancelled {
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                
                pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
            }
            
            for indexPath in toBeStarted {
                let recordToProcess = movies[indexPath.row]
                startOperations(for: recordToProcess, at: indexPath)
            }
        }
    }
    
    func startOperations(for movie: Movie, at indexPath: IndexPath) {
        switch (movie.state) {
        case .new:
            startDownload(for: movie, at: indexPath)
        default:
            NSLog("do nothing")
        }
    }
    
    func startDownload(for movie: Movie, at indexPath: IndexPath) {
        
        guard pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }
        let downloader = ImageDownloader(movie)
        
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.movieTableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
}

extension MovieListViewController: UIScrollViewDelegate {
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
}

extension MovieListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MovieListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MovieListTableViewCell") as! MovieListTableViewCell
        
        let movie = self.movies[indexPath.row]
        cell.movieTitle.text = movie.title
        cell.movieOverView.text = movie.overview
        cell.posterImage.image = movie.posterImage
        
        switch (movie.state) {
        case .failed:
            cell.activityIndicatorView.stopAnimating()
        case .new:
            cell.activityIndicatorView.startAnimating()
            if !tableView.isDragging && !tableView.isDecelerating {
                startOperations(for: movie, at: indexPath)
            }
        default:
            cell.activityIndicatorView.stopAnimating()
        }
        return cell
    }
    
}

extension MovieListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar,
                   selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("\(searchBar.text ?? "")")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            self.fetchMovieSearchResult(searchText)
        }
    }
}


