require './app/models/station'
require './app/models/city'
require './app/models/trip'
require './app/models/subscription_type'
require './app/models/condition'
# require './app/models/bike'
require 'csv'
require 'pry'

City.destroy_all
Station.destroy_all
SubscriptionType.destroy_all
Condition.destroy_all
Trip.destroy_all
# Bike.destroy_all

stations = CSV.open 'db/csv/fixtures/stations_sample_data.csv',
headers: true, header_converters: :symbol

trips = CSV.open 'db/csv/fixtures/trip_sample_data.csv',
headers: true, header_converters: :symbol

conditions = CSV.open 'db/csv/weather.csv',
headers: true, header_converters: :symbol

def format_date(date)
  fd = date.split(/[\/: ]/)
  Time.local(fd[2], fd[0], fd[1], fd[3], fd[4])
end

stations.each do |row|
  city = City.find_or_create_by!(name: row[:city])
  city.stations.create(id: row[:id],
                 name: row[:name],
                 city_id: city.id,
                 dock_count: row[:dock_count],
                 lat: row[:lat],
                 long: row[:long],
                 installation_date: Date.strptime(row[:installation_date], '%m/%e/%Y')
                 )
end


conditions.each do |row|
  Condition.create(id: row[:id],
                    date: format_date(row[:date]),
                    max_temperature_f: row[:max_temperature_f],
                    mean_temperature_f: row[:mean_temperature_f],
                    min_temperature_f: row[:min_temperature_f],
                    mean_humidity: row[:mean_humidity],
                    mean_visibility_miles: row[:mean_visibility_miles],
                    mean_wind_speed_mph: row[:mean_wind_speed_mph],
                    precipitation_inches: row[:precipitation_inches],
                    zip_code: row[:zip_code]
                    )
end

trips.each do |row|
  subscriber_type = SubscriptionType.find_or_create_by!(flavor: row[:subscription_type])
  start_date = Chronic.parse(row[:start_date]).to_date
  end_date = Chronic.parse(row[:end_date]).to_date
  Trip.create(id: row[:id],
              duration: row[:duration],
              start_date: start_date,
              start_station_id: row[:start_station_id],
              end_date: end_date,
              bike_id: row[:bike_id],
              end_station_id: row[:end_station_id],
              subscription_type_id: subscriber_type.id,
              condition_id: Condition.find_by(date: start_date.strftime("%Y/%m/%e")).id
              )
end
