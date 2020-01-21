import Foundation
import GRPC
import NIO
import Logging
import SwiftProtobuf
import CurrencyModel

LoggingSystem.bootstrap {
  var handler = StreamLogHandler.standardOutput(label: $0)
  handler.logLevel = .debug
  return handler
}

func loadFeatures() throws -> [CurrencyRate] {
  let url = URL(fileURLWithPath: #file)
    .deletingLastPathComponent() // main.swift
    .appendingPathComponent("currency_conversion.json")
  let data = try Data(contentsOf: url)
  let decoder = JSONDecoder()
  return try decoder.decode([CurrencyRate].self, from: data)  
}

func main(args: [String]) throws {
  let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
  defer { try! group.syncShutdownGracefully() }
  
  let currencies = try loadFeatures()
  let provider = CurrencyProvider(currencies: currencies)
  
  let port: Int
  if let portString = ProcessInfo.processInfo.environment["PORT"],
     let portInt = Int(portString) {
    port = portInt
  } else {
    port = 7000
  }
  let configuration = Server.Configuration(
    target: .hostAndPort("0.0.0.0", port),
    eventLoopGroup: group,
    serviceProviders: [provider]
  )
  
  let server = Server.start(configuration: configuration)
  server
    .map { $0.channel.localAddress }
    .whenSuccess { address in
      print("Server started on port \(address!.port!)")
    }
  
  _ = try server.flatMap {
    $0.onClose
  }.wait()
}

try main(args: CommandLine.arguments)
