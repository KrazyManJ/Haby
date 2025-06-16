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
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: icon)
                    Text(name)
                }
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
