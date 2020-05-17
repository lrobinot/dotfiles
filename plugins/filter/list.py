from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from jinja2 import Environment, FileSystemLoader
from ansible import errors

class FilterModule(object):
    ''' adds list filter '''
    def filters(self):
        return {
            # filter map
            'list_insert': list_insert,
            'list_append': list_append
        }

def list_insert(inStr, value, after):
    l = inStr.strip('][').split(', ')
    length = len(l) 
    for i in range(length):
        if l[i] == "'" + after + "'":
            l.insert(i + 1, "'" + value + "'")
            break

    return "[" + ", ".join(l) + "]"

def list_append(inStr, value):
    l = inStr.strip('][').split(', ')
    l.append("'" + value + "'")
    return "[" + ", ".join(l) + "]"


if __name__ == "__main__":
    str = "['aaa', 'bbb', 'ccc', 'ddd']"
    print("str = " + str)

    out = list_insert(str, 'eee', 'aaa')
    print("list_insert(str, 'eee', 'aaa') = " + out)

    out = list_insert(str, 'fff', 'bbb')
    print("list_insert(str, 'fff', 'bbb') = " + out)

    out = list_insert(str, 'ggg', 'ccc')
    print("list_insert(str, 'ggg', 'ccc') = " + out)

    out = list_insert(str, 'hhh', 'ddd')
    print("list_insert(str, 'hhh', 'ddd') = " + out)

    out = list_insert(str, 'iii')
    print("list_insert(str, 'iii') = " + out)
