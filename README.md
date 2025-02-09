# Project Underground custom card scripts for EDOPro

This is home to our **custom card script project**, which supports custom cards designed by the community.

The root folder here contains base scripts, constants, and utilities, such as summon procedures.

Card scripts are written in Lua 5.3, targeting the embedded interpreter in [our custom ocgcore](https://github.com/Satellaa/ygopro-core).  
They are automatically synchronized with servers.

## Contributing

Please keep all bug reports and questions on [Discord](https://discord.gg/NwPa6mwyYx); do **NOT** open an issue or pull request for this purpose.

Reach out to us on [Discord](https://discord.gg/NwPa6mwyYx) to learn how to contribute and start scripting! Before opening a pull request, please speak with a member of staff in `#card-scripting` first and read [`CONTRIBUTING.md`](https://github.com/YGOProjectUnderground/CardScripts/blob/master/CONTRIBUTING.md).

Notes for maintainers: pull requests containing one or very few commits should generally be **squash-merged** to keep history clean.

## GitHub Actions

* This repository contains all scripts, both new and existing, in their entirety. When updates are made, the full collection is synchronized with [the repository the users get updates from](https://github.com/YGOProjectUnderground/Nexus).
* Scripts that have been added or updated are committed directly.
* Files deleted in this repository are also removed from the repository the users get updates from.
* If a pushed HEAD commit title contains `[ci skip]`, `[skip ci]`, `[actions skip]`, or `[skip actions]`, this is skipped.

## Lua Syntax Check

* A basic Lua syntax check is done on scripts for pushes and pull requests. It loads `constant.lua` and `utility.lua` into ocgcore. Then it searches through one subfolder level for files of the form `cX.lua`, where `X` is an integer, loading them into the core as a dummy card with the same passcode. Three-digit passcodes and 151000000 are skipped.

* The syntax checker will catch basic Lua syntax errors like missing `end` statements and runtime errors in `initial_effect` (or a lack of `initial_effect` in a card script). It will not catch runtime errors in other functions declared within a script unless they are called by `initial_effect` of some other script.

* This is not a static analyzer and it will not catch incorrect parameters for calls outside of `initial_effect` or any other runtime error.

* If a pushed HEAD commit title contains `[ci skip]`, `[skip ci]`, `[travis skip]`, or `[skip travis]`, this is skipped.