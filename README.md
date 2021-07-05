# frkminer (no stinkin' fees)

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg)](https://github.com/RichardLitt/standard-readme)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)][Gitter]

> Expanse (frkhash) miner with OpenCL, CUDA and stratum support

**frkminer** is an Frkhash GPU mining application: with frkminer you can mine every coin which relies on an Frkhash Proof of Work.

This is a direct descendent of the Ethminer project at https://github.com/ethereum-mining/ethminer. Since that project
is largely abandoned and unmanaged this personal version is published with the hope that it may continue to be useful. In the spirit
of open source problem reports and pull requests are welcome, but please use git-clang-format on your requests.

**Project Owner & Developer** @chrisfranko

## Features

* OpenCL mining
* Nvidia CUDA mining
* realistic benchmarking
* stratum mining without proxy
* Automatic devices configuration
* farm failover

## Table of Contents

* [Usage](#usage)
    * [Examples connecting to pools](#examples-connecting-to-pools)
* [Build](#build)
    * [Master branch build status](#master-branch-build-status)
    * [Building from source](#building-from-source)
* [API](#api)
* [Contribute](#contribute)

## Usage

**frkminer** is a command line program. This means you launch it either
from a Windows command prompt or Linux console, or create shortcuts to
predefined command lines using a Linux Bash script or Windows batch/cmd file.
For a full list of available command, please run:

```sh
frkminer --help
```
Complete list of command options [here](docs/Options.md).

### Examples connecting to pools

Check our [samples](docs/POOL_EXAMPLES_ETH.md) to see how to connect to different pools.

## Build

### Master branch build status

[![CircleCI](https://circleci.com/gh/no-fee-ethereum-mining/frkminer.svg?style=svg)](https://circleci.com/gh/no-fee-ethereum-mining/frkminer)

### Building from source

[Instructions](docs/BUILD.md)

## API

[Specifications](docs/API_DOCUMENTATION.md)

## Contribute

[![Gitter](https://img.shields.io/gitter/room/no-fee-ethereum-mining/frkminer.svg)][Gitter]

To meet the community, ask general questions and chat about the miner join [the frkminer channel on Gitter][Gitter].

## License

Licensed under the [GNU General Public License, Version 3](LICENSE).

[Gitter]: https://gitter.im/no-fee-ethereum-mining/frkminer
