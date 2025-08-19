import Foundation

// Define a struct to hold API response data
struct APIResponse: Codable {
    let data: [String: String]
}

// Create a class to interact with the API service
class InteractiveAPIService {
    let baseURL = "https://example.com/api"
    let session = URLSession.shared
    
    func parseAPIResponse(from url: URL, completion: @escaping (APIResponse?, Error?) -> Void) {
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "Invalid data", code: 0, userInfo: nil))
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                completion(apiResponse, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func interactWithAPI(endpoint: String, params: [String: String], completion: @escaping (APIResponse?, Error?) -> Void) {
        var components = URLComponents(string: baseURL)!
        components.path += endpoint
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        
        guard let url = components.url else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        parseAPIResponse(from: url, completion: completion)
    }
}

// Example usage
let service = InteractiveAPIService()
service.interactWithAPI(endpoint: "/users", params: ["name": "John", "age": "30"]) { response, error in
    if let error = error {
        print("Error: \(error)")
        return
    }
    
    if let response = response {
        print("API Response: \(response.data)")
    }
}