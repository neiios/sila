#!/usr/bin/env python3

# use the link to find the key code (you need first column)
# https://gitlab.com/cunidev/gestures/-/wikis/xdotool-list-of-key-codes

import asyncio
import asyncudp
import os

task = None

PORT = 16523
PTT_KEY = 'Control_R + Num_Lock' # change to your hotkey
DELAY_BEFORE_KEY_UP = .35

def do_key_down():
    os.system("xdotool keydown %s" % PTT_KEY)

def do_key_up():
    os.system("xdotool keyup %s" % PTT_KEY)

async def delayed_key_up(delay):
    global task
    await asyncio.sleep(delay)
    do_key_up()
    task = None

async def main():
    sock = await asyncudp.create_socket(local_addr=('127.0.0.1', PORT))
    global task

    while True:
        await sock.recvfrom()

        if task is not None:
            task.cancel()
        else:
            do_key_down()

        task = asyncio.create_task(delayed_key_up(DELAY_BEFORE_KEY_UP))

asyncio.run(main())
