# app/middlewares/error_handler.rb
require "json"
require "securerandom"

class ErrorHandler
  def initialize(app, logger:)
    @app    = app
    @logger = logger
  end

  def call(env)
    request_id = SecureRandom.uuid
    env["request_id"] = request_id

    @app.call(env)
  rescue Errors::BaseError => e
    log_error(e, env, request_id, known: true)
    [e.status, default_headers, problem_json(e, env, request_id)]
  rescue StandardError => e
    log_error(e, env, request_id, known: false)
    body = {
      type:   "about:blank",
      title:  "Internal Server Error",
      status: 500,
      detail: "Something went wrong",
      instance: env["PATH_INFO"],
      "request-id": request_id
    }
    [500, default_headers, [JSON.generate(body)]]
  end

  private

  def default_headers
    { "Content-Type" => "application/json; charset=utf-8" }
  end

  def problem_json(error, env, request_id)
    body = {
      type:     "about:blank",
      title:    error.message,
      status:   error.status,
      detail:   error.details,
      code:     error.code,
      instance: env["PATH_INFO"],
      "request-id": request_id
    }
    [JSON.generate(body)]
  end

  def log_error(e, env, request_id, known:)
    @logger.public_send(known ? :info : :error, {
      msg: e.message,
      class: e.class.name,
      backtrace: (known ? nil : e.backtrace&.first(10)),
      path: env["PATH_INFO"],
      method: env["REQUEST_METHOD"],
      request_id: request_id
    }.compact.to_json)
  end
end
