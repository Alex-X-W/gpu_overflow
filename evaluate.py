#!/usr/bin/env python
# -*- coding: utf-8 -*-

import optparse
import os


def next_num(fp):
    in_num = False
    eof = False
    ret = ''
    while True:
        c = fp.read(1)
        if not c:
            eof = True
            break

        if c.isnumeric():
            ret += c
            in_num = True
        elif in_num:
            break

    return ret, eof


if __name__ == '__main__':
    optparser = optparse.OptionParser()
    optparser.add_option(
        "-t", "--test", default="",
        help="test data"
    )
    optparser.add_option(
        "-g", "--gold", default="1stmillion.txt",
        help="gold data"
    )
    opts = optparser.parse_args()[0]

    assert os.path.isfile(opts.test)
    assert os.path.isfile(opts.gold)

    fp_t = open(opts.test, 'r')
    fp_g = open(opts.gold, 'r')

    eof_t = False
    while True:
        num_t, eof_t = next_num(fp_t)
        num_g, _ = next_num(fp_g)
        if eof_t and num_t == '':
            break
        if num_t != num_g:
            print('Error when test data has %s against gold data %s' % (num_t, num_g))
            exit(-1)
    exit(0)