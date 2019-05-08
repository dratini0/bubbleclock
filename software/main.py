# -*- coding: utf-8 -*-

import machine
from alphabet import *
import utime
import micropython

CS = machine.Pin(15, machine.Pin.OUT)
spi = machine.SPI(1, baudrate=8000000, polarity=0, phase=0)
CS.on()
index = 0
data = bytearray([
    0xff, 0xfe, 0xff,
    0xff, 0xfd, 0xff,
    0xff, 0xfb, 0xff,
    0xff, 0xf7, 0xff,
    0xff, 0xef, 0xff,
    0xff, 0xdf, 0xff,
    0xff, 0xbf, 0xff,
    0xff, 0x7f, 0xff,
    0xfe, 0xff, 0xff,
    0xfd, 0xff, 0xff,
    0xfb, 0xff, 0xff,
    0xf7, 0xff, 0xff,
    0xef, 0xff, 0xff,
    0xdf, 0xff, 0xff,
])
LEN_DATA = len(data)
def cb(_):
    global index
    CS.off()
    spi.write(data[index:index+3])
    CS.on()
    index += 3
    if index >= LEN_DATA:
        index = 0

tim = machine.Timer(-1)
tim.init(period=1, mode=machine.Timer.PERIODIC, callback=cb)

def set_letter_raw(place, letter):
    data[place * 3 + 2] = letter

def update_raw(text):
    for i in range(14):
        if i < len(text):
            set_letter_raw(i, text[i])
        else:
            set_letter_raw(i, 0)

def prepare_text(text):
    result = bytearray(len(text))
    position = 0
    for letter in text:
        letter = letter.upper()
        if letter not in alphabet:
            letter = ' '
        if position > 0 and letter == '.':
            result[position - 1] |= alphabet[letter]
        else:
            result[position] = alphabet[letter]
            position += 1
    return bytes(result[0:position])

def update(text):
    update_raw(prepare_text(text))

def update_clock(_):
    update('{:014}'.format(utime.time()))

def schedule_update_clock(t):
    micropython.schedule(update_clock, t)

clocktimer = machine.Timer(-1)
clocktimer.init(period=1000, mode=machine.Timer.PERIODIC, callback=schedule_update_clock)
update_clock(0)

def stop():
    tim.deinit()
    CS.off()
    spi.write(b'\0\0\0')
    CS.on()
    clocktimer.deinit()
