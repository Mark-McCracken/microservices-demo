//
//  File.swift
//  
//
//  Created by Mark Mccracken on 12/01/2020.
//

import Foundation
import GRPC
import NIO
import NIOConcurrencyHelpers
import CurrencyModel

public enum CurrencyError: Error {
  case notFound(message: String)
}

class CurrencyProvider: Hipstershop_CurrencyServiceProvider {
  private let currencyRates: [String: Double]
  
  public init(currencies: [CurrencyRate]) {
    var rates = [String: Double]()
    for currency in currencies {
      rates[currency.name] = currency.rate
    }
    currencyRates = rates
  }
  
  func getSupportedCurrencies(request: Hipstershop_Empty, context: StatusOnlyCallContext) -> EventLoopFuture<Hipstershop_GetSupportedCurrenciesResponse> {
    var response = Hipstershop_GetSupportedCurrenciesResponse()
    response.currencyCodes = Array(currencyRates.keys)
    return context.eventLoop.makeSucceededFuture(response)
  }
  
  func convert(request: Hipstershop_CurrencyConversionRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Hipstershop_Money> {
    guard let fromRate = currencyRates[request.from.currencyCode] else {
      return context.eventLoop.makeFailedFuture(CurrencyError.notFound(message: "No currency code called \(request.from.currencyCode) found"))
    }
    guard let toRate = currencyRates[request.toCode] else {
      return context.eventLoop.makeFailedFuture(CurrencyError.notFound(message: "No currency code called \(request.toCode) found"))
    }
    print("Request: \(request.from.currencyCode) \(request.from.units).\(request.from.nanos) to \(request.toCode)")
    var originalAmount = Double(request.from.units)
    originalAmount += Double(request.from.nanos) * pow(10, -9)
    let convertedAmount = originalAmount / fromRate * toRate
    var response = Hipstershop_Money()
    response.currencyCode = request.toCode
    response.units = Int64(floor(convertedAmount))
    response.nanos = Int32((convertedAmount - Double(response.units)) * pow(10, 9))
    return context.eventLoop.makeSucceededFuture(response)
  }
  
}
