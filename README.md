# Forecast Data Application

This application provides weather forecasts based on a zip code entered by the user. It integrates with the OpenWeatherMap API to fetch current weather and 5-day forecast data. The application also includes caching to improve performance and reduce API calls.

## Features

1. **Weather Forecast**:
   - Displays current weather (temperature, high, low, description).
   - Shows a 5-day forecast with detailed information.

2. **Interactive Form**:
   - Users can enter an address using Google Places Autocomplete.
   - Automatically extracts the zip code from the address.

3. **Caching**:
   - Forecast data is cached for 30 minutes to reduce API calls and improve performance.

4. **Chart Integration**:
   - Users can toggle between a table view and a chart view of the 5-day forecast.

5. **Error Handling**:
   - Displays appropriate error messages when the forecast cannot be fetched.

## Implementation Details

### 1. **Controller**
- File: `app/controllers/forecasts_controller.rb`
- Handles the logic for fetching and caching weather data.
- Renders the form and forecast views.

### 2. **Views**
- **Form View** (`app/views/forecasts/form.html.erb`):
  - Includes a form for entering an address.
  - Uses Google Places Autocomplete to extract the zip code.
- **Index View** (`app/views/forecasts/index.html.erb`):
  - Displays the current weather and 5-day forecast.
  - Includes a toggle button to switch between table and chart views.

### 3. **Service**
- File: `app/services/forecast_service.rb`
- Fetches weather data from the OpenWeatherMap API.
- Parses and formats the data for use in the application.

### 4. **Testing**
- **Controller Tests** (`spec/requests/forecasts_controller_spec.rb`):
  - Tests the behavior of the `ForecastsController`.
  - Covers scenarios like valid zip codes, missing parameters, and cached data.
- **Service Tests** (`spec/services/forecast_service_spec.rb`):
  - Tests the `ForecastService` for API integration.
  - Uses `WebMock` to stub external API requests.

### 5. **Styling**
- Custom CSS is included in the views for a clean and user-friendly interface.

### 6. **Dependencies**
- **Google Maps API**:
  - Used for address autocomplete.
  - Requires a valid API key in the environment variable `GOOGLE_MAPS_API_KEY`.
- **OpenWeatherMap API**:
  - Used to fetch weather data.
  - Requires a valid API key in the environment variable `WEATHER_API_KEY`.
- **Chart.js**:
  - Used to render the temperature chart in the forecast view.

## Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd forecast_data
   ```

2. **Install Dependencies**:
   ```bash
   bundle install
   ```

3. **Set Environment Variables**:
   - Add the following keys to your `.env` file:
     ```
     GOOGLE_MAPS_API_KEY=<your_google_maps_api_key>
     WEATHER_API_KEY=<your_openweathermap_api_key>
     ```

4. **Run the Server**:
   ```bash
   rails server
   ```

5. **Access the Application**:
   - Open your browser and navigate to `http://localhost:3000`.

## Testing

1. **Run RSpec Tests**:
   ```bash
   bundle exec rspec
   ```

2. **Test Coverage**:
   - Includes tests for both the controller and the service layer.
   - Uses `WebMock` to stub external API calls.

## Future Improvements

- Add support for additional weather metrics (e.g., wind speed, precipitation).
- Implement user authentication for personalized forecasts.
- Enhance error handling for edge cases.

## Author

Developed by Diego Polido.
