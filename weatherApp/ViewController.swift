//
//  ViewController.swift
//  weatherApp
//
//  Created by user224311 on 3/19/23.
//

import UIKit
import Foundation
import CoreLocation

import Foundation

// MARK: - Welcome
struct WeatherData: Codable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone, id: Int
    let name: String
    let cod: Int
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

// MARK: - Main
struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Sys
struct Sys: Codable {
    let type, id: Int
    let country: String
    let sunrise, sunset: Int
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main, description, icon: String
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
}


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var weatherStatusLabel: UILabel!
    
    @IBOutlet var weatherIcon: UIImageView!
    
    @IBOutlet var temperatureLabel: UILabel!
    
    @IBOutlet var humidityLabel: UILabel!
    
    @IBOutlet var windLabel: UILabel!
    
    var latCordinate :CLLocationDegrees = 0.0
    var lonCordinate :CLLocationDegrees = 0.0
    let APIKey = "0dbb04121a34e3fffa582b7ea9f8a9dd";
    let locationManager = CLLocationManager()
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        latCordinate = location.coordinate.latitude
        lonCordinate = location.coordinate.longitude
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("location error", error)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        currentLoc = locationManager.location
        if (locationManager.authorizationStatus == .authorizedWhenInUse ||
            locationManager.authorizationStatus == .authorizedAlways) && currentLoc != nil {
            
            print("currentloc", currentLoc! )
//            print(currentLoc.coordinate.longitude )
            
            latCordinate = currentLoc.coordinate.latitude
            lonCordinate = currentLoc.coordinate.longitude
            
            getCurrentWeather(latitude: latCordinate, longitude: lonCordinate, APIKey: APIKey){ [self] weather in
                
                if let weather = weather {
                    print(weather);
                    print(weather.name)
                    print(weather.main.temp)
                    print(weather.weather[0].main)
                    let iconCode = weather.weather[0].icon
                    let iconUrl = "https://openweathermap.org/img/wn/\(iconCode).png"
                    
                    let url = URL(string: iconUrl)
                    
                    // Download the weather icon data from the URL
                    let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                        if error != nil {
                            print(error!)
                        } else {
                            // Convert the weather icon data to UIImage
                            if let iconData = data {
                                let weatherIconImage = UIImage(data: iconData)
                                
                                // Update the image view with the weather icon
                                DispatchQueue.main.async {
                                    weatherIcon.image = weatherIconImage
                                    locationLabel.text = weather.name
                                    weatherStatusLabel.text = weather.weather[0].description
                                    humidityLabel.text = String(weather.main.humidity)
                                    windLabel.text = String(weather.wind.speed)
                                    temperatureLabel.text = String(weather.main.temp)
                                    
                                }
                              
                            }
                        }
                    }
                    task.resume()
                }
                
            }
        }
        
        
    }
    
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, APIKey: String, completion: @escaping (WeatherData?) -> Void){
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(APIKey)&unit=metrics";
        
        print(urlString);
        
        guard let urlRequest = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest){data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            do {
                let decodedData = try decoder.decode(WeatherData.self, from: data);
                print(decodedData);
                completion(decodedData);
            } catch {
                completion(nil)
            }
        }
        
        task.resume()
        
    }
}

