#!/usr/local/bin/fish
set access_key (cat .env | grep "WEATHER_STACK_API_KEY" | sed 's/WEATHER_STACK_API_KEY=//g')
set base_url "http://api.weatherstack.com"

set jq_install_dir (which jq)
if test -z $jq_install_dir
    echo "jq not found. Please install it."
    exit 1
end

# Use the Weatherstock api and jq to understand the current weather in a city
function check_weather --argument-names city

    set city_query (echo $city | sed 's/ /%20/g')
    set request_url "http://api.weatherstack.com/current?access_key=$access_key&query=$city_query"

    # Query the endpoint
    echo "Querying $request_url"
    set output_name (date +%Y-%m-%d)"-"(echo $city | sed 's/ //g').json
    mkdir -p ./data
    curl --GET "$request_url" 2> /dev/null 1> "$output_name"
    mv "$output_name" ./data
    echo "Saved result to ./data/$output_name"

    # Filter what we need
    set result (cat "./data/$output_name" | jq .current.weather_descriptions[0])
    # All lowercase, no quote characters
    set result (echo $result | tr [:upper:] [:lower:] | tr -d "\"")
    set degrees (cat "./data/$output_name" | jq .current.feelslike)

    set message "It's $result in $city, with $degrees degrees"
    echo $message
    osascript  -e "display notification \"$message\" with title \"Weather Update\""

end

# Cities we're interested in
set cities "San Jose" "London"

for city in $cities;
    echo "Querying weather in $city"
    check_weather $city
    echo -e "\n"
end

# Possible results, so far:
# - Partly Cloudy
# - Sunny
# - Clear