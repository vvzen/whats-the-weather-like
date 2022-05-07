#!/Users/vvzen/miniconda3/envs/htwisj-env/bin/python
import time
import argparse

import serial

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--value", type=str)
    args = parser.parse_args()

    value_bytes = args.value.encode("ascii")
    value_bytes += b"\n"

    device = serial.Serial("/dev/cu.usbmodem301", 9600)

    # Arduino resets on a new connection, wait a bit before writing
    time.sleep(3)
    device.write(value_bytes)
    device.close()

if __name__ == "__main__":
    main()