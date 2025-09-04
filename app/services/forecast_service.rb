class ForecastService
  OPEN_WEATHER_URL = "http://api.openweathermap.org/data/2.5"
  CACHE_EXPIRATION = 30.minutes

  attr_reader :zip_code, :errors

  def initialize(zip_code)
    @zip_code = zip_code
    @errors = []
  end

  def self.call(zip_code)
    new(zip_code).call
  end

  def call
    cache_key = "forecast_#{zip_code}"
    cached_forecast = Rails.cache.read(cache_key)

    return cached_forecast.merge(from_cache: true) if cached_forecast

    current_weather = weather
    forecast_data = forecast

    return { errors: @errors } unless current_weather && forecast_data

    forecast_result = {
      current_weather: current_weather,
      forecast: forecast_data
    }

    Rails.cache.write(cache_key, forecast_result, expires_in: CACHE_EXPIRATION)

    forecast_result.merge(from_cache: false)
  end

  private

  def api_key
    ENV["WEATHER_API_KEY"]
  end

  def parsed_data(url)
    response = Net::HTTP.get(URI(url))

    parsed_response = JSON.parse(response)

    raise StandardError if parsed_response.empty?

    parsed_response
  end

  def build_data_hash(data)
    {
      temperature: data["main"]["temp"],
      high: data["main"]["temp_max"],
      low: data["main"]["temp_min"],
      description: data["weather"].first["description"]
    }
  end

  def weather
    url = "#{OPEN_WEATHER_URL}/weather?zip=#{zip_code},us&units=imperial&appid=#{api_key}"
    data = parsed_data(url)

    unless data["main"]
      @errors << "Invalid response from weather service"

      return nil
    end

    build_data_hash(data)
  rescue StandardError
    @errors << "Error retreiving from weather service"

    nil
  end

  def forecast
    url = "#{OPEN_WEATHER_URL}/forecast?zip=#{zip_code},us&units=imperial&appid=#{api_key}"
    data = parsed_data(url)

    unless data["list"]
      @errors << "Invalid response from forecast service"

      return nil
    end

    data["list"].map do |forecast|
      build_data_hash(forecast).merge(datetime: forecast["dt_txt"])
    end
  rescue StandardError
    @errors << "Error retreiving from forecast service"

    nil
  end
end
