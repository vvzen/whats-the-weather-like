#!/Users/vvzen/miniconda3/envs/htwisj-env/bin/python
import os
import sys
import time
import argparse

import serial

ARDUINO_ADDRESS = "/dev/cu.usbmodem301"

def main():
    parser = argparse.ArgumentParser(
        description=("Reads from a FIFO pipe on disk and send the data"
                     "to Arduino. The name of the pipe can be customized by "
                     "using the HTWISJ_PIPE_NAME env variable."),
    )
    parser.parse_args()

    # Arduino resets on a new connection, wait a bit before writing
    # The alternative is to disable the reset:
    # https://playground.arduino.cc/Main/DisablingAutoResetOnSerialConnection
    device = serial.Serial(ARDUINO_ADDRESS, 9600)
    time.sleep(2)

    # We read from a pipe on disk (created via mkfifo)
    pipe_name = os.getenv("HTWISJ_PIPE_NAME", "htwisj_pipe")
    if not os.path.exists(pipe_name):
        try:
            print("Creating pipe on disk named '%s'" % pipe_name)
            os.mkfifo(pipe_name)
        except OSError as e:
            print("Failed to create FIFO pipe named '%s'" % pipe_name)
            sys.exit(1)

    print("Opened pipe. Reading for messages..")
    pipe = open(pipe_name, 'r')

    try:
        while True:
            line = pipe.read()
            if not line:
                time.sleep(0.5)
                continue

            value_bytes = line.encode("ascii")
            print("Sending %s" % value_bytes)
            device.write(value_bytes)
    except KeyboardInterrupt:
        print("Received SIGINT. Shutting down..")
    finally:
        pipe.close()
        device.close()


if __name__ == "__main__":
    main()