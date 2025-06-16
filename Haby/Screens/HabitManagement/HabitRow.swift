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
        
    
    var body: some View {
        NavigationLink(destination: OverviewView()){
            VStack{
                Label(name, systemImage: icon)
                HStack{
                    Text(type)
                    Text(frequency)
                    Text(time)
                }
            }
        }
    }
}

#Preview {
    //HabitRow()
}
