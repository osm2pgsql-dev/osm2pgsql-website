---
chapter: 23
appendix: D
title: Upgrading
---

### Upgrading to 2.0.0

If you are upgrading from a version older than 1.11.0 to a 2.x version, upgrade
to 1.11.0 first. The run osm2pgsql and read all the messages carefully. If
there are any messages about deprecated functionality act on them before
upgrading to 2.0.0.

Upgrade information for older versions are in the [v1 manual]({% link
doc/manual-v1.html %}#upgrading).

**Switching from `add_row()` to `insert()`**

: If you are using the flex output and your Lua config file uses the `add_row()`
function, you need to change your configuration. See [this tutorial]({% link
doc/tutorials/switching-from-add-row-to-insert/index.md %}) for all the details.

XXX

New system requirements:
- glibc 8 (std::filesystem)
- proj v6

