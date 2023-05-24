import apt


def update_deps(pkg_version, exclude_pkg_names, dep_set, logger):
    logger.debug("{}: processing".format(pkg_version))

    dep_set.add(pkg_version)

    for dep in pkg_version.get_dependencies('PreDepends', 'Depends'):
        max_dep_version=max(dep.target_versions)
        logger.debug("{}: has dependency: {} {}".format(pkg_version.package, max_dep_version.package, max_dep_version.version))

        if str(max_dep_version.package) in exclude_pkg_names:
            logger.debug("{}: {} is in the exclude list - skipping".format(pkg_version.package, max_dep_version.package))
            continue

        if max_dep_version in dep_set:
            continue

        update_deps(max_dep_version, exclude_pkg_names, dep_set, logger)


def get_deps(in_pkg_names, exclude_pkg_names, logger):
    apt_cache=apt.Cache(memonly=True)

    in_pkgs=[apt_cache[pkg_name] for pkg_name in in_pkg_names]

    dep_set=set()
    for pkg in in_pkgs:
        update_deps(max(pkg.versions), exclude_pkg_names, dep_set, logger)

    logger.debug("found packages original format: {}".format(sorted(dep_set)))
    out_pkgs = [dep.package.fullname + "=" + dep.version for dep in sorted(dep_set)]
    logger.debug("found packages in standard format: {}".format(out_pkgs))

    return(out_pkgs)