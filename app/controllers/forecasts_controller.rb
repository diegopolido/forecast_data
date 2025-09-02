
class ForecastsController < ApplicationController
  require "net/http"
  require "json"

  CACHE_EXPIRATION = 30.minutes

  def index
    zip_code = params[:zip_code]
    if zip_code.blank?
      render json: { error: "Zip code is required" }, status: :bad_request and return
    end

    cache_key = "forecast_#{zip_code}"
    cached_forecast = Rails.cache.read(cache_key)

    if cached_forecast
      @forecast = cached_forecast
    else
      @forecast = ForecastService.call(zip_code)
      if @forecast
        Rails.cache.write(cache_key, @forecast, expires_in: CACHE_EXPIRATION)
      else
        render json: { error: "Unable to fetch forecast" }, status: :unprocessable_entity and return
      end
    end
  end
end
