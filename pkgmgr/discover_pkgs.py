#!/usr/bin/env python3

import distro
import argparse
import logging


def init_logger(debug=False):
    logger = logging.getLogger(__name__)
    if debug:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)
    # log format
    log_fmt = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    date_fmt = "%Y-%m-%d %H:%M:%S"
    formatter = logging.Formatter(log_fmt, date_fmt)
    # create streamHandler and set log fmt
    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)
    # add the streamHandler to logger
    logger.addHandler(stream_handler)
    return logger


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument('-d', '--debug', action='store_true', help='enable debug logs')
    p.add_argument('-p', '--in-pkgs', type=str, help='a space separated list of packages for which to determine dependencies', required=True)
    p.add_argument('-e', '--exclude-pkgs', type=str, help='a space separated list of packages for which are to be ignored if found as dependencies', required=True)
    p.add_argument('-o', '--out-file', type=str, help='provide the path where to write a file containing script output', required=True)
    return p.parse_args()


def main():
    args=parse_args()

    logger=init_logger(args.debug)
    logger.debug("Arguments: {}".format(vars(args)))

    name = distro.name()
    if "Ubuntu" in name:
        from lib_apt import get_deps
    elif "Debian" in name:
        from lib_apt import get_deps
    elif "Rocky" in name:
        from lib_dnf import get_deps
    else:
        exit(1)

    dep_set = get_deps(args.in_pkgs.split(), args.exclude_pkgs.split(), logger)

    logger.debug("Identified dependencies: {}".format(dep_set))

    with open(args.out_file, "w") as f:
        for dep in dep_set:
            f.write("{}\n".format(dep))


if __name__ == "__main__":
    main()