from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from jinja2 import Environment, FileSystemLoader
from ansible import errors

class FilterModule(object):
    ''' adds rgb filter '''
    def filters(self):
        return {
            # filter map
            'rgb': rgb_hex_to_dec,
            'rgba': rgba
        }


def rgb_hex_to_dec(hexColor, component):
    if len(hexColor) != 7:
        raise Exception("Passed hex color '%s', needs to be in #xxyyzz format." % hexColor)

    if component == 'r':
        return int(hexColor[1:3], 16) * 255
    if component == 'g':
        return int(hexColor[3:5], 16) * 255
    if component == 'b':
        return int(hexColor[5:7], 16) * 255

def rgba(hexColor, t):
    if len(hexColor) != 7:
        raise Exception("Passed hex color '%s', needs to be in #xxyyzz format." % hexColor)

    r = int(hexColor[1:3], 16)
    g = int(hexColor[3:5], 16)
    b = int(hexColor[5:7], 16)

    return "rgba({r:d}, {g:d}, {b:d}, {t:.2f})".format(r=r, g=g, b=b, t=t / 100.)

if __name__ == "__main__":
    str = "#2a092a"

    print("rgb: {str} -> r={r}, g={g}, b={b}".format(
        str=str,
        r=rgb_hex_to_dec(str, "r"),
        g=rgb_hex_to_dec(str, "g"),
        b=rgb_hex_to_dec(str, "b")
    ))

    print("rgba(90): {str} -> {rgba}".format(str=str, rgba=rgba(str, 90)))
