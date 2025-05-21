//
//  DataManaging.swift
//  CityGuide
//
//  Created by David Procházka on 19.03.2025.
//
import CoreData
import UIKit

protocol DataManaging {
    var context: NSManagedObjectContext { get }
}
