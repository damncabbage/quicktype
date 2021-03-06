#!/usr/bin/env python

import argparse
import random

with open('/usr/share/dict/words') as f:
    words = f.read().splitlines()

def random_array_element():
    return random.choice(['123', 'true', 'false', 'null', '3.1415', '"foo"'])

def random_word():
    return random.choice(words)

def print_object(size, indent, suffix):
    print(indent + '{')
    for i in range(size - 1):
        print(indent + '  "%s": %s,' % (random_word(), random_array_element()))
    print(indent + '  "%s": "no-comma"' % random_word())
    print(indent + '}' + suffix)

def main():
    parser = argparse.ArgumentParser(description="Generate a large JSON document.")
    parser.add_argument('--array-size', nargs=1, type=int, default=[100000])
    parser.add_argument('--array-type', choices=['int', 'array', 'object'], default='object')
    parser.add_argument('--array-elements', nargs=1, type=int, default=[3])
    parser.add_argument('--object-size', nargs=1, type=int, default=None)
    parser.add_argument('--class-count', nargs=1, type=int, default=None)
    args = parser.parse_args()

    if args.class_count:
        print('{')
        for i in range(args.class_count[0] - 1):
            print('  "class%d":' % i)
            print_object(args.object_size[0], '  ', ',')
        print('  "class%d":' % i)
        print_object(args.object_size[0], '  ', '')
        print('}')
    elif args.object_size:
        print_object(args.object_size[0], '', '')
    else:
        n = args.array_size[0]
        type = args.array_type
        print('{"x": [')
        if type == 'int':
            elem_format = "%d%s"
            need_i = True
        elif type == 'object':
            elem_format = '{"a": %d}%s'
            need_i = True
        elif type == 'array':
            nelems = args.array_elements[0]
            arr = []
            if nelems > 0:
                arr.append('%s')
            if nelems > 1:
                arr.extend([random_array_element() for _ in range(nelems-1)])
            elem_format = '[%s]%%s' % ", ".join(arr)
            need_i = nelems > 0
        else:
            raise Exception("Unknown array type %s" % type)
        for i in range(n):
            semicolon = "," if i < n-1 else ""
            if need_i:
                print(elem_format % (i, semicolon))
            else:
                print(elem_format % semicolon)
        print(']}')

if __name__ == "__main__":
    main()
