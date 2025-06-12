//
//  HabitManagementState.swift
//  Haby
//
//  Created by Kateřina Plešová on 12.06.2025.
//

mport Observation
import MapKit
import SwiftUI

@Observable
final class HabitManagementViewState {
    var mapPlaces: [MapPlace] = []
    
    var selectedPlace: MapPlace?
    
    var currentLocation: CLLocationCoordinate2D?
    
    var mapCameraPosition: MapCameraPosition = .camera(
        .init(
            centerCoordinate: .init(
                latitude: 49.21044343932761,
                longitude: 16.6157301199077
            ),
            distance: 3000
        )
    )
}
