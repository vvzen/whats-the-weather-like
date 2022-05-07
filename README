# Readme

This simple script queries the weather of a series of cities using api.weatherstack.com.

You'll need to provide your own API key by saving it in a `.env` file, like this:
```bash
# this is your .env file
WEATHER_STACK_API_KEY=yourapikeyvaluehere
```

It parses the data via 'jq' and displays it via a nice macOS notification.
You'll need to have 'jq' installed (see https://github.com/stedolan/jq).

The script saves all the weather data in a local `./data` directory.
I'm running this as a cronjob to check how much Sun I'd get in San Jose compared to London :)

## Disable quarantine

If you're Big Sur, Monterey, etc.. you'll need to disable the gatekeeper/quarantine in order to be able to run 'jq'. Have a look here: https://apple.stackexchange.com/a/202172

TL;DR :
```bash
xattr -dr com.apple.quarantine 'jq-osx-amd64'
```


## Additional info

Disable Arduino auto reset on serial connection: https://playground.arduino.cc/Main/DisablingAutoResetOnSerialConnection
