class ForecastService
  attr_reader :zip_code, :api_key

  def initialize(zip_code)
    @zip_code = zip_code
    @api_key = ENV["WEATHER_API_KEY"]
  end

  def self.call(zip_code)
    new(zip_code).call
  end

  def call
    current_weather = weather
    forecast_data = forecast

    return nil unless current_weather && forecast_data

    {
      current_weather: current_weather,
      forecast: forecast_data
    }
  end

  private

  def parsed_data(url)
    response = Net::HTTP.get(URI(url))
    JSON.parse(response)
  end
  def weather
    url = "http://api.openweathermap.org/data/2.5/weather?zip=#{zip_code},us&units=metric&appid=#{api_key}"
    data = parsed_data(url)

    return nil unless data["main"]

    {
      temperature: data["main"]["temp"],
      high: data["main"]["temp_max"],
      low: data["main"]["temp_min"],
      description: data["weather"].first["description"]
    }
  rescue StandardError
    nil
  end

  def forecast
    url = "http://api.openweathermap.org/data/2.5/forecast?zip=#{zip_code},us&units=metric&appid=#{api_key}"
    data = parsed_data(url)

    return nil unless data["list"]

    data["list"].map do |forecast|
      {
        datetime: forecast["dt_txt"],
        temperature: forecast["main"]["temp"],
        high: forecast["main"]["temp_max"],
        low: forecast["main"]["temp_min"],
        description: forecast["weather"].first["description"]
      }
    end
  rescue StandardError
    nil
  end
end
