


import Observation
import MapKit
import SwiftUI

@Observable
final class HabitManagementViewState {
    var habits: [HabitDefinition] = []
    
    var selectedPlace: HabitDefinition?
    
}
