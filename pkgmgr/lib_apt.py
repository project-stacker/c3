import apt

def update_deps(apt_cache, pkg_version, exclude_pkg_names, dep_set, arch, logger):
    logger.debug("{}: processing".format(pkg_version))

    dep_set.add(pkg_version)

    for dep in pkg_version.get_dependencies('PreDepends', 'Depends'):
        logger.debug("{}: has dependencies: {}".format(pkg_version.package, dep.target_versions))
        legal_versions=[version for version in dep.target_versions if version.architecture in (arch, 'all')]
        dep_name = dep.or_dependencies[0].name

        if not legal_versions and (dep_name + ":" + arch in apt_cache):
           all_arches = [version.architecture for version in dep.target_versions]
           logger.debug("{}: no applicable version found for {} with arch {} in: {}".format(pkg_version.package, dep_name, arch, ",".join(all_arches)))
           logger.debug("{}: try a new search for {} in apt cache".format(pkg_version.package, dep_name))
           dep_pkg = apt_cache[dep_name + ":" + arch]
           legal_versions = [version for version in dep_pkg.versions if version.architecture in (arch, 'all')]

        max_dep_version=max(legal_versions)
        logger.debug("{}: choose dependency: {} {}".format(pkg_version.package, max_dep_version.package, max_dep_version.version))

        if str(max_dep_version.package.shortname) in exclude_pkg_names:
            logger.debug("{}: {} is in the exclude list - skipping".format(pkg_version.package, max_dep_version.package))
            continue

        if max_dep_version in dep_set:
            continue

        update_deps(apt_cache, max_dep_version, exclude_pkg_names, dep_set, arch, logger)


def get_deps(in_pkg_names, exclude_pkg_names, arch, logger):
    apt_cache=apt.Cache(memonly=True)
    apt_cache.update()
    apt_cache.open()

    in_pkgs = []
    for pkg_name in in_pkg_names:
        if pkg_name + ":" + arch in apt_cache:
            pkg_name = pkg_name + ":" + arch
        in_pkgs.append(apt_cache[pkg_name])

    dep_set=set()
    for pkg in in_pkgs:
        for version in pkg.versions:
            logger.debug("{}: initial package has version: {} arch: {}".format(version.package, version.version, version.architecture))
        max_dep_version=max([version for version in pkg.versions if version.architecture in (arch, 'all')])
        update_deps(apt_cache, max_dep_version, exclude_pkg_names, dep_set, arch, logger)

    logger.debug("found packages original format: {}".format(sorted(dep_set)))
    out_pkgs = [dep.package.shortname + ":" + dep.architecture + "=" + dep.version for dep in sorted(dep_set)]
    logger.debug("found packages in standard format: {}".format(out_pkgs))

    return(out_pkgs)