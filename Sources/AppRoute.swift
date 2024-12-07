import CasePaths
import Hummingbird
import URLRouting

@CasePathable
public enum AppRoute: Equatable {
    /// GET /
    case battlesnakeDetails

    /// POST /start
    case gameStarted(GameMoveRequest)

    /// POST /move
    case move(GameMoveRequest)

    /// POST /end
    case gameOver(GameMoveRequest)

    public static func router(context: AppContext) -> some URLRouting.Router<AppRoute> {
        func json<T: Codable>(_ type: T.Type = T.self) -> Conversions.JSON<T> {
            .json(T.self, decoder: context.requestDecoder, encoder: context.responseEncoder)
        }

        return OneOf {
            Route(.battlesnakeDetails) {
                Method.get
            }

            Route(.case(AppRoute.gameStarted)) {
                Method.post
                Path { "start" }
                Body(json(GameMoveRequest.self))
            }

            Route(.case(AppRoute.move)) {
                Method.post
                Path { "move" }
                Body(json(GameMoveRequest.self))
            }

            Route(.case(AppRoute.gameOver)) {
                Method.post
                Path { "end" }
                Body(json(GameMoveRequest.self))
            }
        }
    }

    func respond(request: Request, context: AppContext) async throws -> Response {
        switch self {
        case .battlesnakeDetails:
            let data = try context.responseEncoder.encode(BattlesnakeDetails.current)
            return Response(status: .ok, body: .init(byteBuffer: .init(data: data)))
        case .gameStarted/*(let game)*/:
            return Response(status: .ok)
        case .move/*(let moveRequest)*/:
            let data = try await context.withRNG { rng in
                try context.responseEncoder.encode(MoveResponse(move: .random(using: &rng)))
            }
            return Response(status: .ok, body: .init(byteBuffer: .init(data: data)))
        case .gameOver/*(let moveRequest)*/:
            return Response(status: .ok)
        }
    }
}
