import Foundation
import HTTPTypes
import Hummingbird
import OrderedCollections
import URLRouting

public struct RoutingResponder<Route, Context: RequestContext>: HTTPResponder {
    private let router: @Sendable (Context) -> sending any URLRouting.Router<Route>
    private let _respond: @Sendable (
        _ route: Route,
        _ request: Request,
        _ context: Context
    ) async throws -> Response

    init(
        context: Context.Type = Context.self,
        router: @escaping @Sendable (Context) -> sending any URLRouting.Router<Route>,
        respond: @escaping @Sendable (
            _ route: Route,
            _ request: Request,
            _ context: Context
        ) async throws -> Response
    ) {
        self.router = router
        self._respond = respond
    }

    public func respond(to request: Request, context: Context) async throws -> Response {
        context.logger.trace("Request: \(request.method) \(request.uri)")
        do {
            let requestData = URLRequestData(
                method: request.method.rawValue,
                scheme: request.uri.scheme?.rawValue,
                host: request.uri.host,
                port: request.uri.port,
                path: request.uri.path,
                query: OrderedDictionary(
                    request.uri.queryParameters.lazy.map { (String($0), [String($1)]) },
                    uniquingKeysWith: { $1 }
                ),
                headers: OrderedDictionary(
                    request.headers.lazy.map { ($0.name.canonicalName, [$0.value]) },
                    uniquingKeysWith: { $1 }
                ),
                body: Data(try await request.body.collect(upTo: .max).readableBytesView)
            )
            let route: Route
            do {
                route = try router(context).parse(requestData)
                context.logger.trace("Route: \(route)")
            } catch {
                context.logger.info("Route not found for request")
                return Response(status: .notFound)
            }

            var response = try await _respond(route, request, context)
            response.headers.append(HTTPField(name: .contentType, value: "application/json"))
            context.logger.trace("Response: \(response)")
            return response
        } catch {
            context.logger.error("Error: \(error)")
            throw error
        }
    }
}
