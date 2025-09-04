class ForecastsController < ApplicationController
  require "net/http"
  require "json"

  def index
    if params[:zip_code].blank?
      flash.now[:error] = "Zip code is required"
      render :form

      return
    end

    @forecast = ForecastService.call(params[:zip_code])

    if @forecast[:errors]
      flash.now[:error] = @forecast[:errors].join(", ")
      render :form
    end
  end
end
