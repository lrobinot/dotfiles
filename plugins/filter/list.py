from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from jinja2 import Environment, FileSystemLoader
from ansible import errors

class FilterModule(object):
    ''' adds list filter '''
    def filters(self):
        return {
            # filter map
            'list_insert_after': list_insert_after,
            'list_insert_before': list_insert_before,
            'list_append': list_append
        }


def list_insert_after(inStr, value, after):
    l = inStr.strip('][').split(', ')
    length = len(l)
    for i in range(length):
        if l[i] == "'" + value + "'":
            del l[i]
            break
    length = len(l)
    for i in range(length):
        if l[i] == "'" + after + "'":
            l.insert(i + 1, "'" + value + "'")
            break
    return "[" + ", ".join(l) + "]"


def list_insert_before(inStr, value, before):
    l = inStr.strip('][').split(', ')
    length = len(l)
    for i in range(length):
        if l[i] == "'" + value + "'":
            del l[i]
            break
    length = len(l)
    for i in range(length):
        if l[i] == "'" + before + "'":
            l.insert(i, "'" + value + "'")
            break
    return "[" + ", ".join(l) + "]"


def list_append(inStr, value):
    l = inStr.strip('][').split(', ')
    length = len(l)
    for i in range(length):
        if l[i] == "'" + value + "'":
            del l[i]
            break
    l.append("'" + value + "'")
    return "[" + ", ".join(l) + "]"


if __name__ == "__main__":
    str = "['aaa', 'bbb', 'ccc', 'ddd']"
    print("str = " + str)

    out = list_insert_after(str, 'eee', 'aaa')
    print("list_insert_after(str, 'eee', 'aaa') = " + out)

    out = list_insert_after(str, 'fff', 'bbb')
    print("list_insert_after(str, 'fff', 'bbb') = " + out)

    out = list_insert_after(str, 'ggg', 'ccc')
    print("list_insert_after(str, 'ggg', 'ccc') = " + out)

    out = list_insert_after(str, 'hhh', 'ddd')
    print("list_insert_after(str, 'hhh', 'ddd') = " + out)

    out = list_append(str, 'iii')
    print("list_append(str, 'iii') = " + out)
