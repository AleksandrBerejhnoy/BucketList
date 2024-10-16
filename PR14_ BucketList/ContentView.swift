//
//  ContentView.swift
//  PR14_ BucketList
//
//  Created by user09 on 05.08.2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 49.06802, longitude: 33.42041),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)))
    
    @State private var viewModel = ViewModel()
    @State private var currentMapStyle = 0
    
    var body: some View {
        if viewModel.isUnlocked {
            ZStack(alignment: .top) {
               
                MapReader { proxy in
                    Map(initialPosition: startPosition) {
                        ForEach(viewModel.locations) { location in
                            Annotation(location.name, coordinate: location.coordinate) {
                                Image(systemName: "star.circle")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 44, height: 44)
                                    .clipShape(.circle)
                                    .onLongPressGesture {
                                        viewModel.selectedPlace = location
                                    }
                            }
                        }
                    }
                    .mapStyle(currentMapStyle == 0 ? .standard : .hybrid)
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            viewModel.addLocation(at: coordinate)
                        }
                    }
                    .sheet(item: $viewModel.selectedPlace) { place in
                        EditView(location: place) {
                            viewModel.update(location: $0)
                        }
                    }
                }
                Picker("Choose my style", selection: $currentMapStyle) {
                    Text("Standart").tag(0)
                    Text("Hybrid").tag(1)
                }
                .padding()
                .pickerStyle(.segmented)
            }
        } else {
            Button("Unlock plcases", action: viewModel.authenticate)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
                .alert(viewModel.errorMessage, isPresented: $viewModel.showErrorAlert) {
                    Button("OK", role: .cancel) {}
                }
        }
    }
}

#Preview {
    ContentView()
}
