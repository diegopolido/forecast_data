require 'rails_helper'

RSpec.describe ForecastService, type: :service do
  let(:zip_code) { "10001" }
  let(:api_key) { ENV["WEATHER_API_KEY"] }

  describe ".call" do
    context "when the API returns valid data" do
      before do
        stub_request(:get, "http://api.openweathermap.org/data/2.5/weather?zip=#{zip_code},us&units=imperial&appid=#{api_key}")
          .to_return(status: 200, body: {
            main: { temp: 75, temp_max: 80, temp_min: 70 },
            weather: [ { description: "Clear sky" } ]
          }.to_json)

        stub_request(:get, "http://api.openweathermap.org/data/2.5/forecast?zip=#{zip_code},us&units=imperial&appid=#{api_key}")
          .to_return(status: 200, body: {
            list: [
              {
                dt_txt: "2023-10-01 12:00:00",
                main: { temp: 75, temp_max: 80, temp_min: 70 },
                weather: [ { description: "Clear sky" } ]
              }
            ]
          }.to_json)
      end

      it "returns the forecast data" do
        result = ForecastService.call(zip_code)
        expect(result).to include(:current_weather, :forecast)
        expect(result[:current_weather]).to include(:temperature, :high, :low, :description)
        expect(result[:forecast].first).to include(:datetime, :temperature, :high, :low, :description)
      end
    end

    context "when the weather API returns an error" do
      before do
        stub_request(:get, "http://api.openweathermap.org/data/2.5/weather?zip=#{zip_code},us&units=imperial&appid=#{api_key}")
          .to_return(status: 500, body: {}.to_json)

        # Add a stub for the forecast API to prevent real HTTP requests
        stub_request(:get, "http://api.openweathermap.org/data/2.5/forecast?zip=#{zip_code},us&units=imperial&appid=#{api_key}")
          .to_return(status: 200, body: {
            list: []
          }.to_json)
      end

      it "returns errors" do
        result = ForecastService.call(zip_code)
        expect(result).to eq({ errors: [ "Error retreiving from weather service" ] })
      end
    end

    context "when the forecast API returns an error" do
      before do
        stub_request(:get, "http://api.openweathermap.org/data/2.5/weather?zip=#{zip_code},us&units=imperial&appid=#{api_key}")
          .to_return(status: 200, body: {
            main: { temp: 75, temp_max: 80, temp_min: 70 },
            weather: [ { description: "Clear sky" } ]
          }.to_json)

        stub_request(:get, "http://api.openweathermap.org/data/2.5/forecast?zip=#{zip_code},us&units=imperial&appid=#{api_key}")
          .to_return(status: 500, body: {}.to_json)
      end

      it "returns errors" do
        result = ForecastService.call(zip_code)
        expect(result).to eq({ errors: [ "Error retreiving from forecast service" ] })
      end
    end
  end
end
