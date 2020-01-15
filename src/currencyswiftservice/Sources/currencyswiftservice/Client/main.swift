//
//  File.swift
//  
//
//  Created by Mark Mccracken on 12/01/2020.
//

import Foundation
import GRPC
import NIO
import CurrencyModel
import Logging

LoggingSystem.bootstrap {
  var handler = StreamLogHandler.standardOutput(label: $0)
  handler.logLevel = .critical
  return handler
}

func makeClient(port: Int, group: EventLoopGroup) -> Hipstershop_CurrencyServiceServiceClient {
  let config = ClientConnection.Configuration(
    target: .hostAndPort("localhost", port),
    eventLoopGroup: group
  )
  let connection = ClientConnection(configuration: config)
  return Hipstershop_CurrencyServiceServiceClient(connection: connection)
}

func getSupportedCurrencies(using client: Hipstershop_CurrencyServiceServiceClient) {
  print("→ Get Supported Currencies:")
  let request = Hipstershop_Empty()
  let call = client.getSupportedCurrencies(request)
  do {
    let currencies = try call.response.wait()
    print("Returned currencies:")
    for currency in currencies.currencyCodes {
      print(currency)
    }
  } catch {
    print("RPC failed: \(error)")
    return
  }
}

func convertCurrency(using client: Hipstershop_CurrencyServiceServiceClient) {
  var request = Hipstershop_CurrencyConversionRequest()
  request.from.currencyCode = "GBP"
  request.from.units = 10
  request.from.nanos = 500_000_000
  request.toCode = "USD"
  let call = client.convert(request)
  do {
    let money = try call.response.wait()
    print("Returned Currency amount: \(money.currencyCode) \(money.units).\(money.nanos)")
  } catch {
    print("RPC failed: \(error)")
    return
  }
}

func main(args: [String]) throws {
  // arg0 (dropped) is the program name. We expect arg1 to be the port.
  guard case .some(let port) = args.dropFirst(1).first.flatMap(Int.init) else {
    print("Usage: \(args[0]) PORT")
    exit(1)
  }
  
  let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
  defer { try? group.syncShutdownGracefully() }
  // Make a client, make sure we close it when we're done.
  let currencyClient = makeClient(port: port, group: group)
  defer {
    try? currencyClient.connection.close().wait()
  }

  getSupportedCurrencies(using: currencyClient)
  
  convertCurrency(using: currencyClient)
}

try main(args: CommandLine.arguments)
