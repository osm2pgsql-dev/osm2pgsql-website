---
title: Contribute as a Developer
---

# Contribute as a Developer

We are always looking for a helping hand for keeping the code up-to-date
and bug-free, as well as, with implementing new features and performance
improvements. This page gives some hints where to get started and outlines
the expectations we have set for code development.

## Where to Start

To get an overview over the architecture of osm2pgsql, read the introduction
on [How osm2pgsql Data Processing Works]({% link contribute/how-osm2pgsql-processing-works.md %}).

[CONTRIBUTING.md](https://github.com/osm2pgsql-dev/osm2pgsql/blob/master/CONTRIBUTING.md){:.extlink}
contains hints for development including coding style and running tests and
some rules for creating a PR.

### Fixing Bugs and Implementing New Features

If you have a small bugfix that only touches a couple of lines, feel free to
open a pull request directly. It is easier to argue over concrete code in such case.
For larger bug fixes or new features, you might want to open an issue or
discussion first, to make sure your solution fits with the overall code.

We like best, when you scratch your own itches and implement what solves your
own use cases. If you want to check if your ideas are a good fit, have a look
at our [road map]({% link about/road-map.md %}). If you need some
inspiration where to start, the [List of Project Ideas]({% link contribute/project-ideas.md %})
might help.


### About Tests

We have two kinds of tests: _unit test_ are written in C++ using the
[catch](https://github.com/catchorg/Catch2){:.extlink} framework, testing the basic
building blocks of the code. And then there are the _BDD tests_. They are
used to write integration tests using the osm2pgsql binary as a blackbox.
We use those mainly to test the different configuration possibilities that
both the command line parameters and the Lua configuration provide.

Any code contribution ideally comes with tests. Having a low-level unit test
is always good. If the code change touches on the externally visible behaviour,
then an additional BDD test would be ideal.

BDD tests can also be a good way to show some odd or bad behaviour in addition
to or in place of a bug report.


## Guidelines for Development

osm2pgsql is a stable software with quite mature code. That does not mean that
its development is finished. We want to see it evolve along the lines as
described in the [Road Map]({% link about/road-map.md %}). To ensure continuity,
we have a few basic requirements for all code contributions described here.

### Software and Hardware Requirements

The development is mostly done on Linux and most users use osm2pgsql on Linux.
osm2pgsql must work with dependencies and tools available on the latest stable
versions of Debian, Ubuntu and Fedora.
Best effort will be made to also support old-stable versions of these
distributions. Tools only necessary for development, like the test framework
are required to be available for the latest stable versions only.
Libraries may be vendored in (distributed with osm2pgsql) when newer versions
are needed. This should be the exception rather than the rule.

See also: [our handy list of dependency versions in supported distributions]({% link contribute/dependencies.md %})

Because we currently have no Windows or macOS developers the support for these
operating systems is "best effort". They can only be tested and debugged
through the CI on Github at the moment.

osm2pgsql currently follows the C++17 standard and we actively ensure that it
compiles with clang, gcc and VisucalC++. Switching to newer standards
is subject to compiler availability in the distributions we aim to support.

osm2pgsql must be compatible with all officially supported PostgreSQL versions
(currently 13+). Older versions may continued to be supported if all features
are available. osm2pgsql may use features only available in newer PostgreSQL
version but then their use needs to be made optional.

32-bit systems are not supported. The code is tested against ARM and Intel
architectures. Best effort is made to be compatible with big-endian architectures.
We have no means to test them right now.

Resource-friendliness is a major requirement. It must always be
possible to use it with small data extracts on a hobbyist's laptop. Processing
the full planet file and running minutely updates must be possible on a
reasonably modern machine (128GB RAM, 1.5 TB SSD).

### Requirements for New Features

New features must serve one of the following purposes:

* simplify handling of an existing feature
* give access to a functionality that cannot be implemented with existing
  features or only through abusing existing functionality
* improve general performance and resource usage

Features must cover several use-cases which are rooted in already implemented
applications.

### Experimental Features

When completely new functionality is added, the new feature usually goes through
an experimental phase. In this phase the feature must already be fully functional
and usable. However, the interface to the new functionality may still be
changed between minor versions. Any changes must be mentioned prominently in
the release notes, preferably including instructions for migration where
necessary.

Once a feature has left the experimental phase and is stable, any interface
changes must go through the deprecation process.

### Feature Deprecation

We may retire features from time to time, when they have been replaced with
better functionality or simply not used anymore.

Before a feature can be removed, it needs to go through a deprecation period.
Deprecations will be announced in the release notes and a warning will be
added in the code. The deprecation period should be at least a year.

Actual removal of features should only be done in major versions. There may be
exceptions for very little used features. Those may be removed in minor versions.

### Releases

osm2pgsql follows [semantic versioning](https://semver.org/){:.extlink}. Releases don't
follow a strict timeline, although we try to have at least two minor releases
per year.

Major releases usually mark major shifts in functionality. They may be breaking
the database schema and require a reimport. Minor releases can introduce new
functionality and changes to dependencies. Patch releases are for bug fixes
only.
