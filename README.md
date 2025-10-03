# Wasix CC

This is a linux tool for compiling C into web assembly.  See [here](https://github.com/wasix-org/wasixcc)


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

To run the container do:

    $ make run

