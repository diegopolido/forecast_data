require 'rails_helper'

RSpec.describe ForecastsController, type: :request do
  describe "GET /forecast" do
    context "when the zip_code parameter is provided" do
      let(:zip_code) { "10001" }

      before do
        allow(ForecastService).to receive(:call).and_return({
          current_weather: {
            temperature: 75,
            high: 80,
            low: 70,
            description: "Clear sky"
          },
          forecast: [
            { datetime: "2023-10-01 12:00:00", temperature: 75, high: 80, low: 70, description: "Clear sky" }
          ]
        })
      end

      it "returns a successful response from the API and renders the index template" do
        get '/forecast', params: { zip_code: zip_code }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Weather Forecast")
        expect(response.body).to include("Clear sky")
        expect(response.body).to include("Source: API")
      end
    end

    context "when the zip_code parameter is missing" do
      it "renders the form template with an error message" do
        get '/forecast'
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Zip code is required")
      end
    end

    context "when the ForecastService returns errors" do
      let(:zip_code) { "99999" }

      before do
        allow(ForecastService).to receive(:call).and_return({ errors: ["Error retreiving from forecast service"] })
      end

      it "renders the form template with an error message" do
        get '/forecast', params: { zip_code: zip_code }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Error retreiving from forecast service")
      end
    end

    context "when the forecast is retrieved from the cache" do
      let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
      let(:cache) { Rails.cache }

      before do
        allow(Rails).to receive(:cache).and_return(memory_store)
        Rails.cache.clear
      end

      let(:zip_code) { "10001" }
      let(:cached_forecast) do
        {
          current_weather: {
            temperature: 75,
            high: 80,
            low: 70,
            description: "Clear sky"
          },
          forecast: [
            { datetime: "2023-10-01 12:00:00", temperature: 75, high: 80, low: 70, description: "Clear sky" }
          ]
        }
      end

      before do
        cache.write("forecast_#{zip_code}", cached_forecast)
      end

      it "returns a successful response and uses the cached data" do
        get '/forecast', params: { zip_code: zip_code }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Weather Forecast")
        expect(response.body).to include("Clear sky")
        expect(response.body).to include("Source: Cache")
      end
    end
  end
end
