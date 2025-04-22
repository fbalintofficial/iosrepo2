import CoreLocation

class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weather: WeatherResponse?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let apiKey = "IDE_IRD_BE_AZ_API_KULCSOD" // ← Fontos!
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        requestLocation()
    }
    
    func fetchWeather(for city: String) {
        isLoading = true
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&units=metric&appid=\(apiKey)&lang=hu"
        fetchData(from: urlString)
    }
    
    private func fetchData(from urlString: String) {
        guard let url = URL(string: urlString) else {
            showError(message: "Érvénytelen URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.showError(message: error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    self.showError(message: "Nincs adat")
                    return
                }
                
                do {
                    self.weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
                } catch {
                    self.showError(message: "Érvénytelen adatformátum")
                }
            }
        }.resume()
    }
    
    private func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=metric&appid=\(apiKey)&lang=hu"
            fetchData(from: urlString)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(message: "Helymeghatározási hiba")
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}