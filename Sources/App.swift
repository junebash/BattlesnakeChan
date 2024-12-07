import Hummingbird

@main
enum App {
    static func main() async throws {
        let app = Application(
            responder: RoutingResponder(
                router: { AppRoute.router(context: $0) },
                respond: { try await $0.respond(request: $1, context: $2) }
            )
        )
        try await app.run()
    }
}
