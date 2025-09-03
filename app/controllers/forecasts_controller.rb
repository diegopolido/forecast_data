class ForecastsController < ApplicationController
  require "net/http"
  require "json"

  CACHE_EXPIRATION = 30.minutes

  def index
    if params[:zip_code].blank?
      render :form
      return
    end

    zip_code = params[:zip_code]
    cache_key = "forecast_#{zip_code}"
    cached_forecast = Rails.cache.read(cache_key)

    if cached_forecast
      @forecast = cached_forecast
      @from_cache = true
    else
      @forecast = ForecastService.call(zip_code)
      if @forecast
        Rails.cache.write(cache_key, @forecast, expires_in: CACHE_EXPIRATION)
        @from_cache = false
      else
        flash.now[:error] = "Unable to fetch forecast"
        render :form
      end
    end
  end
end
