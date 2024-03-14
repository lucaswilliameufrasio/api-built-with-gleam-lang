import gleam/bytes_builder
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import gleam/json.{object, string}

pub fn main() {
  let not_found_response =
    object([#("message", string("route not found"))])
    |> json.to_string

  let not_found =
    response.new(404)
    |> response.set_body(
      mist.Bytes(bytes_builder.from_string(not_found_response)),
    )

  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        ["health-check"] -> health_check(req)

        _ -> not_found
      }
    }
    |> mist.new
    |> mist.port(9988)
    |> mist.start_http

  process.sleep_forever()
}

fn health_check(_request: Request(Connection)) -> Response(ResponseData) {
  let response =
    object([#("message", string("ok"))])
    |> json.to_string

  response.new(200)
  |> response.set_body(mist.Bytes(bytes_builder.from_string(response)))
  |> response.set_header("content-type", "application/json")
}
