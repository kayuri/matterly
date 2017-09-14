import Foundation

let restApiService = RestApiService()

class RestApiService {
    
    fileprivate init() {
    }
    
    
    func fetch(_ endpoint: String, _ completion: @escaping ([FeedItem]?, NSError?) -> Void ) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        guard let url = URL(string: endpoint) else {
            completion(.none, NSError.message("Error: cannot create URL", code: 0))
            return
        }
        let urlRequest = URLRequest(url: url)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            if let error = error {
                completion(.none, error as NSError)
                return
            }
            
            guard let responseData = data else {
                completion(.none, NSError.message("Error: did not receive data", code: 0))
                return
            }
            
            do {
                guard let movies = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    completion(.none, NSError.message("Error trying to convert data to JSON", code: 0))
                    return
                }
                
                guard let results = movies["results"] as? [[String: Any]] else {
                    completion(.none, NSError.message("Could not get results from JSON", code: 0))
                    return
                }
                let items = results.flatMap{ FeedItem.fromJson( $0 ) }
                completion(items, .none)
            } catch  {
                completion(.none, NSError.message("Error trying to convert data to JSON", code: 0))
            }
        }
        task.resume()
    }
    
    func fetchHighestRatedThisYear(completion: @escaping ([FeedItem]?, NSError?) -> Void ) {
        let highestRatedThisYearEndpoint = "https://api.themoviedb.org/3/discover/movie?certification_country=US&vote_count.gte=500&page=1&include_video=false&include_adult=false&sort_by=vote_average.desc&year=2017&language=en-US&api_key=84d0e365fa21f123b2aca3c2f16bbc54"
        fetch(highestRatedThisYearEndpoint, completion)
    }
    
    func fetchPopular(completion: @escaping ([FeedItem]?, NSError?) -> Void ) {
        let popularEndpoint = "https://api.themoviedb.org/3/discover/movie?certification_country=US&page=1&include_video=false&include_adult=false&sort_by=popularity.desc&language=en-US&api_key=84d0e365fa21f123b2aca3c2f16bbc54"
        fetch(popularEndpoint, completion)
    }
    
    func fetchNewInTheatres(completion: @escaping ([FeedItem]?, NSError?) -> Void ) {
        let newInTheatresEndpoint: String = "https://api.themoviedb.org/3/discover/movie?certification_country=US&page=1&primary_release_date.gte=2017-09-11&primary_release_date.lte=2017-09-16&include_video=false&include_adult=false&sort_by=popularity.desc&language=en-US&api_key=84d0e365fa21f123b2aca3c2f16bbc54"
        fetch(newInTheatresEndpoint, completion)
    }
}
