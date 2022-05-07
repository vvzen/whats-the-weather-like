#!/usr/local/bin/fish
set USE_ARDUINO 0

set base_url "http://api.weatherstack.com"
set access_key (cat .env | grep "WEATHER_STACK_API_KEY" | sed 's/WEATHER_STACK_API_KEY=//g')
set fifo_pipe (cat .env | grep "HTWISJ_PIPE_NAME" | sed 's/HTWISJ_PIPE_NAME=//g')

set jq_install_path (which jq)
if test -z $jq_install_path
    echo "'jq' not found. Please install it."
    exit 1
end

# Use the Weatherstock api and jq to understand the current weather in a city
function check_weather --argument-names city

    set city_query (echo $city | sed 's/ /%20/g')
    set request_url "http://api.weatherstack.com/current?access_key=$access_key&query=$city_query"

    # Query the endpoint
    echo "Querying $request_url"
    set date_str (date +%Y-%m-%d_%r | sed 's/:[0-9][0-9]:[0-9][0-9] //g')
    set output_name (echo $date_str)"-"(echo $city | sed 's/ //g').json
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

    if test $USE_ARDUINO -eq 0
        return
    end
    exit 0


    set send_red 0

    switch $result
        case "sunny"
            set send_red 1
        case "clear"
            set send_red 1
    end

    echo "Sending message to $fifo_pipe"
    if test $send_red -eq 1
        echo "RED" > $fifo_pipe
    else
        echo "BLUE" > $fifo_pipe
    end

end

# Cities we're interested in
set cities "San Jose" "London"
#set cities "San Jose"

for city in $cities;
    echo "Querying weather in $city"
    check_weather $city
    echo -e "\n"
end

# Possible results, so far:
# - Partly Cloudy
# - Sunny
# - Clear