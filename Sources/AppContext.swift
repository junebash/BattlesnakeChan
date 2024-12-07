import Foundation
import HTTPTypes
import Hummingbird
import OrderedCollections
import Synchronization
import URLRouting

public struct AppContext: RequestContext {
    private actor RNGBox {
        var rng: any RandomNumberGenerator

        init(rng: consuming any RandomNumberGenerator) {
            self.rng = rng
        }

        public func withRNG<T>(
            _ work: (inout any RandomNumberGenerator) throws -> T
        ) rethrows -> T {
            try work(&rng)
        }
    }

    public var coreContext: CoreRequestContextStorage

    private let rng: RNGBox

    public init(
        source: ApplicationRequestContextSource,
        rng: consuming sending some RandomNumberGenerator
    ) {
        self.coreContext = .init(source: source)
        self.rng = .init(rng: rng)
    }

    public init(source: ApplicationRequestContextSource) {
        self.init(source: source, rng: SystemRandomNumberGenerator())
    }

    public func withRNG<T: Sendable>(
        _ work: sending (inout any RandomNumberGenerator) throws -> T
    ) async rethrows -> T {
        try await rng.withRNG { try work(&$0) }
    }

    public var requestDecoder: JSONDecoder {
        JSONDecoder() |> {
            $0.dateDecodingStrategy = .iso8601
        }
    }

    public var responseEncoder: JSONEncoder {
        JSONEncoder() |> {
            $0.dateEncodingStrategy = .iso8601
        }
    }
}

//struct AppRouteHandler: HTTPResponder {
//    func respond(to request: Request, context: Context) async throws -> Response {
//        context.logger.info("Received \(request.method) \(request.uri)")
//        do {
//            let requestData = URLRequestData(
//                method: request.method.rawValue,
//                scheme: request.uri.scheme?.rawValue,
//                host: request.uri.host,
//                port: request.uri.port,
//                path: request.uri.path,
//                query: OrderedDictionary(
//                    request.uri.queryParameters.lazy.map { (String($0), [String($1)]) },
//                    uniquingKeysWith: { $1 }
//                ),
//                headers: OrderedDictionary(
//                    request.headers.lazy.map { ($0.name.canonicalName, [$0.value]) },
//                    uniquingKeysWith: { $1 }
//                ),
//                body: Data(try await request.body.collect(upTo: .max).readableBytesView)
//            )
//            let appRoute: AppRoute
//            do {
//                appRoute = try AppRoute.router.parse(requestData)
//            } catch {
//                context.logger.info("Route not found for request")
//                return Response(status: .notFound)
//            }
//
//            var response: Response
//            switch appRoute {
//            case .battlesnakeDetails:
//                response = Response(
//                    status: .ok,
//                    body: .init(
//                        byteBuffer: .init(data: try context.responseEncoder.encode(BattlesnakeDetails.current))
//                    )
//                )
//            case .gameStarted:
//                response = Response(status: .ok)
//            }
//            response.headers.append(HTTPField(name: .contentType, value: "application/json"))
//            context.logger.debug("Response: \(response)")
//            return response
//        } catch {
//            context.logger.error("Error: \(error)")
//            throw error
//        }
//    }
//}
