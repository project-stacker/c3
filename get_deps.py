#!/usr/bin/env python3

import argparse
import json
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
    p.add_argument('-f', '--deps-file', default="image_deps.json", help='provide the path to the json containing dependencies between images')
    p.add_argument('-o', '--out-file', help='provide the path where to write a json containing script output')
    p.add_argument('-i', '--images', type=str, help='images for which to compute the dependencies', required=True)

    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument('-p', '--prerequisites', action='store_true', help='identify images which are needed as prerequisites for input images')
    g.add_argument('-b', '--build-order', action='store_true', help='get a build order for all images which should be built if the input images were modified')

    return p.parse_args()

def get_priority(image, requested_images, image_deps, logger):
    priority = 0
    for dep in image_deps[image]:
        if dep in requested_images:
            priority = max(priority, get_priority(dep, requested_images, image_deps, logger))
    priority += 1
    return priority

def get_build_order(images, image_deps, logger):
    priority_dict = {}
    for image in images:
        p = get_priority(image, images, image_deps, logger)
        priority_dict.setdefault(p, [])
        priority_dict[p].append(image)

    logger.debug("priority dict: {}".format(priority_dict))
    priority_list = []
    for i in range(len(images)):
        if i + 1 in priority_dict:
            priority_list.append(priority_dict[i + 1])

    return priority_list

def get_prerequisites(image, image_deps, logger):
    prerequisites = set(image_deps[image])
    for dep in image_deps[image]:
        prerequisites = prerequisites.union(get_prerequisites(dep, image_deps, logger))
    return prerequisites

def get_all_modified_images(images, image_deps, logger):
    result = set(images)

    for dep in image_deps:
        prerequisites = get_prerequisites(dep, image_deps, logger)
        logger.debug("{} has prerequisites: {}".format(dep, prerequisites))
        for image in images:
            if image in prerequisites:
                result.add(dep)

    logger.debug("all modified images: {}".format(result))
    return result

def get_all_unmodified_prerequisite_images(images, image_deps, logger):
    result = set()

    for image in images:
        prerequisites = get_prerequisites(image, image_deps, logger)
        for prerequisite in prerequisites:
            if prerequisite not in images:
                result.add(prerequisite)

    logger.debug("all unmodified prerequisite images: {}".format(result))
    return list(result)

def main():
    args=parse_args()

    logger=init_logger(args.debug)
    logger.debug("Arguments: {}".format(vars(args)))

    with open(args.deps_file, "r") as f:
        content = json.load(f)
        logger.debug(content)

    image_deps = content['images']

    images = [image.strip() for image in args.images.split(',')]

    impacted = get_all_modified_images(images, image_deps, logger)

    if args.build_order:
        build_order = get_build_order(impacted, image_deps, logger)
        print(build_order)
        if args.out_file:
            with open(args.out_file, "w") as f:
                json.dump(build_order, f, indent=4)

    if args.prerequisites:
        prerequisites = get_all_unmodified_prerequisite_images(impacted, image_deps, logger)
        print(prerequisites)
        if args.out_file:
            with open(args.out_file, "w") as f:
                json.dump(prerequisites, f, indent=4)

if __name__ == "__main__":
    main()