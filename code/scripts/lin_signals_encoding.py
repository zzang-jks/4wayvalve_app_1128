#!/bin/env python3
"""
Python module using pyldfparser that parse the signals encodings in a ldf file
to generate a lin_signals_encoding.h header.

Copyright Melexis N.V.

This product includes software developed at Melexis N.V. (https://www.melexis.com).

Melexis N.V. has provided this code according to LICENSE file attached to repository
"""
import os
import argparse
from pathlib import Path
from mako.template import Template
from pyldfparser import LdfReader
from pyldfparser import ParserApplication


def main():
    """Main function"""
    parser = argparse.ArgumentParser(description="lin_signals_encoding.h generator")
    parser.add_argument("ldf", type=Path, help="ldf file to parse")
    args = parser.parse_args()

    reader = LdfReader()
    parser = ParserApplication(reader, args.ldf)
    parser.run()

    mako_file = f"{os.path.dirname(os.path.abspath(__file__))}/lin_signals_encoding.h.mako"
    print(Template(filename=mako_file).render(**locals()))


if __name__ == "__main__":
    main()
