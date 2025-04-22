import SwiftUI
import CoreLocation

struct WeatherView: View {
    @StateObject private var weatherVM = WeatherViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Keresés
                TextField("Város keresése", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onSubmit {
                        weatherVM.fetchWeather(for: searchText)
                    }
                
                // Fő időjárási adatok
                if let weather = weatherVM.weather {
                    VStack {
                        Text(weather.name)
                            .font(.title)
                        
                        Text("\(weather.main.temp.roundDouble())°C")
                            .font(.system(size: 50, weight: .bold))
                        
                        Text(weather.weather.first?.description.capitalized ?? "")
                            .font(.title3)
                        
                        HStack {
                            WeatherRow(icon: "thermometer", value: "\(weather.main.feelsLike.roundDouble())°C", label: "Hőérzet")
                            WeatherRow(icon: "humidity", value: "\(weather.main.humidity)%", label: "Páratartalom")
                        }
                    }
                } else if weatherVM.isLoading {
                    ProgressView("Betöltés...")
                } else {
                    Text("Kérjük, engedélyezd a helymeghatározást vagy keress egy várost")
                }
            }
            .navigationTitle("Időjárás")
            .alert("Hiba", isPresented: $weatherVM.showError) {
                Button("OK") {}
            } message: {
                Text(weatherVM.errorMessage)
            }
        }
    }
}

struct WeatherRow: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
            Text(value)
                .font(.title2)
            Text(label)
                .font(.caption)
        }
        .padding()
    }
}