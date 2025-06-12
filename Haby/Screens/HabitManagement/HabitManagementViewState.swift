//
//  HabitManagementState.swift
//  Haby
//
//  Created by Kateřina Plešová on 12.06.2025.
//

import Observation
import MapKit
import SwiftUI

@Observable
final class HabitManagementViewState {
    // todo habitdefinition
    var habits: [HabitDef] = []
    
    var selectedPlace: HabitDef?
    
}
