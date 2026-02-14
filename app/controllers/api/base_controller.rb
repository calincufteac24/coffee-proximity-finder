module Api
  class BaseController < ActionController::API
    JSONAPI_CONTENT_TYPE = "application/vnd.api+json"

    before_action :set_content_type

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::ParameterMissing, with: :render_unprocessable

    private

    def set_content_type
      response.headers["Content-Type"] = JSONAPI_CONTENT_TYPE
    end

    def render_jsonapi_errors(errors, status:)
      render json: { errors: errors }, status: status
    end

    def render_not_found(exception)
      render_jsonapi_errors(
        [{ status: "404", title: "Not Found", detail: exception.message }],
        status: :not_found
      )
    end

    def render_unprocessable(exception)
      render_jsonapi_errors(
        [{ status: "422", title: "Unprocessable Entity", detail: exception.message }],
        status: :unprocessable_entity
      )
    end
  end
end