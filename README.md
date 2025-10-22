# Wasix CC

This is a linux tool for compiling C into web assembly.  See [wasixcc](https://github.com/wasix-org/wasixcc) for details.  Also I tagged on [clang](https://developer.fermyon.com/wasm-languages/c-lang) that can build wasms via [wasi-sdk](https://github.com/WebAssembly/wasi-sdk). 


## Example Usage

```
cd /tmp
git clone https://github.com/TheNotary/neatvi.git
docker run -it \
  -v $(pwd):/app \
  thenotary/wasixcc
```


## Installation

Download this repo with git.

```
$ git clone https://github.com/TheNotary/docker-wasixcc
```

To build the docker container do:

    $ make build

To test the container do:

    $ make console


