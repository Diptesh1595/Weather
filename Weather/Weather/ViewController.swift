//
//  ViewController.swift
//  Weather
//
//  Created by user252703 on 7/22/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var weatherDescription: UILabel!
    
    @IBOutlet weak var weatherImageView: UIImageView!
    let locationManager = CLLocationManager()
    let apiKey = "a7292271c7fc5e2cca19935e48f7de13"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            fetchWeatherData(for: location.coordinate)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=43.4516371&lon=-80.492531&units=metric&appid=a7292271c7fc5e2cca19935e48f7de13"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let main = json["main"] as? [String: Any],
                       let wind = json["wind"] as? [String: Any],
                       let weather = json["weather"] as? [[String: Any]] {
                        let temperature = main["temp"] as? Double ?? 0.0
                        let humidity = main["humidity"] as? Double ?? 0.0
                        let windSpeed = wind["speed"] as? Double ?? 0.0
                        let weatherId = weather.first?["id"] as? Int ?? 0
                        let weatherDescription = weather.first?["description"] as? String ?? "Unknown"

                        DispatchQueue.main.async {
                            self.temperatureLabel.text = "Temperature: \(temperature)°C"
                            self.windSpeedLabel.text = "Wind Speed: \(windSpeed)km/h"
                            self.humidityLabel.text = "Humidity: \(humidity)%"
                            self.weatherDescription.text = "Description: \(weatherDescription)"
                            self.weatherImageView.image = UIImage(systemName: self.getImage(id: weatherId))
                        }
                    }
                }
            } catch {
                print("Failed to parse JSON: \(error)")
            }
        }.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error)")
    }
    func getImage(id: Int) -> String {
        switch id {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
}
