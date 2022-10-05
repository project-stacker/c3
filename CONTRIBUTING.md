# Getting Started

## Fork Repository

[Fork](https://github.com/project-stacker/c3) the c3 repository on GitHub to your personal account.

```
$ git clone https://github.com/project-stacker/c3.git (or your fork)
$ cd c3

#Track repository under your personal account
git config push.default nothing # Anything to avoid pushing to project-stacker/c3 by default
git remote rename origin project-stacker
git remote add $USER git@github.com:$USER/c3.git
git fetch $USER
```

## Prerequisites

* Requires a Linux environment with recent 5.x kernel.
* Download stacker binary and add it to your PATH.

```
wget -N https://github.com/project-stacker/stacker/releases/latest/download/stacker
chmod +x ./stacker
```

## Build

To build all images,

```
make
```

The resulting container images are OCI layouts produced under individual [images](./images) directories.

# Project Structure

```
.
...
├── pkgrmgr/            # Source code contains the minimal package manager definitions
├── images/             # Source code (in yaml) contains the main build logic for individual images

```

## Contribute Workflow

PRs are always welcome, even if they only contain small fixes like typos or a few
lines of code. If there will be a significant effort, please document it as an
issue and get a discussion going before starting to work on it.

Please submit a PR broken down into small changes bit by bit. A PR consisting of
a lot features and code changes may be hard to review. It is recommended to
submit PRs in an incremental fashion.

Note: If you split your pull request to small changes, please make sure any of
the changes goes to master will not break anything. Otherwise, it can not be
merged until this feature complete.

## Develop, Build and Test

Write code on the new branch in your fork. The coding style used in c3 is
suggested by the Google community. See the [style doc](https://google.github.io/styleguide/shellguide.html) for details.

Try to limit column width to 120 characters for both code and markdown documents
such as this one.

## Automated Testing (via CI/CD)

Once your pull request has been opened, c3 will start a full CI pipeline
against it that compiles, and runs unit tests and linters.

## Reporting issues

It is a great way to contribute to c3 by reporting an issue. Well-written
and complete bug reports are always welcome! Please open an issue on Github and
follow the template to fill in required information.

Before opening any issue, please look up the existing issues to avoid submitting
a duplication. If you find a match, you can "subscribe" to it to get notified on
updates. If you have additional helpful information about the issue, please
leave a comment.

When reporting issues, always include:

Build environment (shell, etc)
Configuration files of c3

Log files as per configuration.

Because the issues are open to the public, when submitting the log
and configuration files, be sure to remove any sensitive
information, e.g. user name, password, IP address, and company name.
You can replace those parts with "REDACTED" or other strings like
"****".

Be sure to include the steps to reproduce the problem if applicable.
It can help us understand and fix your issue faster.

## Documenting

Update the documentation if you are creating or changing features. Good
documentation is as important as the code itself.

The main location for the documentation is the website repository. The images
referred to in documents can be placed in docs/img in that repo.

Documents are written with Markdown. See Writing on GitHub for more details.

## Design New Features

You can propose new designs for existing c3 features. You can also design
entirely new features, Please submit a proposal in GitHub issues. c3
maintainers will review this proposal as soon as possible. This is necessary to
ensure the overall architecture is consistent and to avoid duplicated work in
the roadmap.
