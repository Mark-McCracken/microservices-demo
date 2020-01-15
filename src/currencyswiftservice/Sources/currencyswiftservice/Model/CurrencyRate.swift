//
//  File.swift
//  
//
//  Created by Mark Mccracken on 12/01/2020.
//

import Foundation
import SwiftProtobuf

public struct CurrencyRate: Codable {
  public let name: String
  public let rate: Double
}
