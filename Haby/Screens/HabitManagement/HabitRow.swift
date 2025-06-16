//
//  HabitRow.swift
//  Haby
//
//  Created by Kateřina Plešová on 16.06.2025.
//

import SwiftUI

struct HabitRow: View {
    var icon: String
    var name: String
    var type: String
    var frequency: String
    var time: String
    
    var circle: String = "circle.fill"
    
    var body: some View {
        NavigationLink(destination: OverviewView()){
            VStack(alignment: .leading){
                Label(name, systemImage: icon).imageScale(.small)
                Text("\(type) • \(frequency) • \(time)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    //HabitRow()
}
