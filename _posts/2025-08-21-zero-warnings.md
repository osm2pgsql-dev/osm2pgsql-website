---
layout: post
title: "Achievement unlocked: Zero Warnings"
---

New code will probably have some errors, the compiler finds some of them and
refuses to produce the final program. So far so good. But code also contains
lots of issues that are not outright errors, they just look "suspicious" to the
compiler in one way or another. Some of them turn out to be actual errors, but
sometimes the code is totally okay in the specific context. The compiler can't
tell for sure, so it emits a warning and keeps going. Different compilers and
different versions of those compilers print different warnings.

And then there are things that are not problems by themselves, they just make
the code harder to read, possibly leading to more problems down the line. Or
sometimes a tool can detect that you are using an "old-fashioned" way of doing
things and there is a better, more modern or more efficient way, to achieve the
same thing. Some of these issues are also detected by the compiler, but for
most programming languages there are extra tools, so called "linters", that
find those issues. For C++ "clang-tidy" is such a tool.

We have been compiling with lots of warnings enabled for years now. And we have
also been running "clang-tidy" regularly for a long time, chipping away at the
problems mentioned. Some warnings are easily dealt with, but others are more
complicated and need more code changes for a good solution. And in some cases,
after careful consideration, warnings have to be disabled, either for the whole
code or for specific places in the code. Osm2pgsql is 19 years old now, the
first implementation was written in C, along the way we switched to C++98, then
C++11, C++14 and then C++17. So the way things can and should be done changed
over time. New versions of compilers and new versions of clang-tidy came up
with new warnings. As part of our work on osm2pgsql we looked at those warnings
whenever there was time and fixed something here or there. But there was always
another warning, another sometimes very old and sometimes newly introduced
problem. Until now.

For a long time now our code has compiled cleanly with the GCC and Clang
compilers, today we reached the point where it also compiles cleanly on MSVC.
And it passes all checks configured in clang-tidy. To "lock in" that
achievement we have changed the CI settings so that any warnings will show up
as errors blocking us from merging the code. This way we can be sure to keep
the "zero warnings" achievement.

Full disclosure: For some legacy code we have disabled a few warnings. That
part of osm2pgsql is already deprecated and will be removed, it just doesn't
make sense to spend time fixing code that's more than a decade old when that
code is going away anyway. Especially as fixing warnings can sometimes
introduce new bugs in the process.

For clang-tidy we enable all checks by default and then selectively disable all
checks that don't make sense for us. The clang-tidy config file contains
comments explaining why the checks are disabled. We will probably revisit some
decisions on what checks to disable in the future as our code improves further.

This is not the end of our journey to improve the osm2pgsql code, there is
plenty more to do. But it is a major milestone in that it makes sure we are not
sliding back behind what we have already achieved, regardless of any new
changes we make.

