from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from jinja2 import Environment, FileSystemLoader
from ansible import errors

class FilterModule(object):
    ''' adds rgb filter '''
    def filters(self):
        return {
          # filter map
          'rgb': rgb_hex_to_dec
        }


def rgb_hex_to_dec(inStr, component):
    if component == 'r':
          return int(inStr[1:3], 16) * 255
    if component == 'g':
          return int(inStr[3:5], 16) * 255
    if component == 'b':
          return int(inStr[5:7], 16) * 255

if __name__ == "__main__":
    str = "#002f3d"
    print(str)
    print(" -> ")

    print(rgb_hex_to_dec("#002f3d", "r"))
    print(rgb_hex_to_dec("#002f3d", "g"))
    print(rgb_hex_to_dec("#002f3d", "b"))
