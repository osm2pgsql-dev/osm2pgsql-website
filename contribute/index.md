---
title: Contribute
---

# Contribute

osm2pgsql is an Open Source community project. We are always looking to grow
our contributor community. Contributions of all forms are welcome. This page
gives you an overview about how you can help.

## Ways to Contribute

Contributing to osm2pgsql doesn't mean just writing code. This page lists
all the different ways how to contribute and gives some hints on how to get
started and how to make the most of your contribution.

### Fixing Bugs and Implementing New Features

Code contributions are always welcome.

If you have a small bugfix that only touches a couple of lines, feel free to
open a PR directly. It is easier to argue over concrete code in such case.
For larger bug fixes or new features, you might want to open an issue or
discussion first, to make sure you understanding of the problem is correct.
Before starting to code, make sure you have read
[CONTRIBUTING.md](https://github.com/osm2pgsql-dev/osm2pgsql/blob/master/CONTRIBUTING.md){:.extlink} and the Guidelines for Development below.

We like best, when you scratch your own itches and implement what solves your
own use cases. If you want to check if your ideas are a good fit, have a look
at our [road map]({% link contribute/road-map.md %}). If you need some
inspiration where to start, the [list of Project Ideas]({% link contribute/project-ideas.md %})
might help.

To get an overview over the architecture of osm2pgsql, we have an introduction
* [How osm2pgsql Data Processing Works]({% link contribute/how-osm2pgsql-processing-works.md %}).

### Writing Tests

We have two kinds of tests: _unit test_ are written in C++ using the
[catch](https://github.com/catchorg/Catch2){:.extlink}, testing the basic
building blocks of the code. And then there are the _BDD tests_. They are
used to write integration tests using the osm2pgsql binary as a blackbox.
We use those mainly to test the different configuration possibilities that
both the command line parameters and the Lua configuration provide.

Any code PR ideally comes with tests. Having a low-level unit test, is always
good. If the PR touches on the externally visible behaviour, then an additional
BDD test would be ideal.

BDD tests can also be a good way to show some odd or bad behaviour in addition
to or in place of a bug report.

More information on setting up and executing tests can be found in
[CONTRIBUTING.md](https://github.com/osm2pgsql-dev/osm2pgsql/blob/master/CONTRIBUTING.md){:.extlink}.

### Extending the Documentation

Most of our documentation lives on the website of osm2pgsql.org. The most
important sections are:

* [User manual]({% link doc/manual.html %}), the handbook that explains
  all of osm2pgsql's functionality in detail
* [Usage examples]({% link examples/index.md %}) show-case the versatility
  of osm2pgsql and should give users are starting point from which they can
  realise their own projects. A good example is self-contained with a short
  and easily understandable configuration and preferably a nice picture to
  show the outcome.
* [Tutorials]({% link doc/tutorials/index.md %}) are longer step-by-step
  explanations to learn to understand certain aspects of osm2pgsql. We don't
  have any good tutorials yet but certainly would like them. Anything from
  beginner's introduction to flex to the complex internals of expiry is
  possible.

You find the source code for the documentation in the
[osm2pgsql-website repo](https://github.com/osm2pgsql-dev/osm2pgsql-website){:.extlink}.
For smaller changes it is perfectly fine to use directly the built-in Github
editor and propose your changes as pull request. Maintainers will then make
sure that everything looks still correct before merging.

We also have a section featuring external blog posts and tutorial on osm2pgsql.

#### Flex Examples

A lot of the examples for the flex output currently live in the
[flex-config](https://github.com/osm2pgsql-dev/osm2pgsql/tree/master/flex-config){:.extlink}
directory in the osm2pgsql source. That's because these examples are older than
the osm2pgsql website. We'd like to integrate the examples with the rest of the
documentation at some point. How this can work, is not quite clear yet.
They could possibly be the base for an extensive tutorial section. Contributions
in that direction are welcome. In the meantime, it is also okay to propose new
examples in the old place. Have a look at the `README` file to understand
the structure of the examples.

### Becoming a Featured User

We have a [list of users of osm2pgsql](% link about/users/index.md %}), where
we showcase different applications where osm2pgsql is used to solve real-world
problem.

If your company or institution is a user of osm2pgsql, we'd like to hear from
you. Get in touch with one of the maintainers and let us know who you are
and how osm2pgsql is used.

### Sponsoring osm2pgsql Development

Last but not least, financial contributions are always welcome as well. You
can beome a [long-term sponsor]({% link sponsors/index.md %}) which ensures
continued maintenance of osm2pgsql, or you can sponsor
[specific features]({% link contribute/project-ideas.md %}).
[Contact](/support#commercial-support)) the osm2pgsql
developers directly to know more.

## Guidelines for Development

osm2pgsql is a stable software with quite mature code. That does not mean that
its development is finished. We want to see it evolve along the lines as
described in the [Road Map](). To ensure continuity, we have a few basic
requirements for all code contributions. Please keep those in mind.

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
through CI setups at the moment.

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

## Releases

osm2pgsql follows [semantic versioning](https://semver.org/). Releases are
made as necessary, although we try to have at least two minor releases per year.

Major releases usually mark major shifts in functionality. They may be breaking
the database schema and require a reimport. Minor releases can introduce new
functionality and changes to dependencies. Patch releases are for bug fixes
only.
