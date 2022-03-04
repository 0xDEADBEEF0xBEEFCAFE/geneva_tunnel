# geneva_tunnel

**Dependencies:**
- `/bin/sh`
- Tested on Debian 11
- Support for CentOS and possibly Ubuntu is currently in the works

`geneva_tunnel` runs commands through Geneva, which listens on port(s) specifed (default: `80` and `443`).

Running `sudo geneva` will launch a browser by default, but you can feed it commands with the `-c|--command` parameter.

## Installation

We will assume you have `git` installed.  If not, download the zip and alter the following as necessary:

```
git clone https://github.com/0xdeadbeef0xbeefcafe/geneva_tunnel
cd geneva_tunnel
./install.sh
```

## Usage

(Requires non-root user running with `sudo`)

```
usage: geneva [-h] [-c COMMAND] [-l LOGLEVEL] [-ls] [-p PORTS] [-s STRATEGY]

optional arguments:
  -h, --help				show this help message and exit
  -c COMMAND, --command COMMAND		Command to run though Geneva
  -l LOGLEVEL, --loglevel LOGLEVEL	Log level [debug|info|warning|error]
  -ls, --list				List Geneva strategies (JSON)
  -p PORTS, --ports PORTS		Destination port(s) for Geneva to modify traffic
  -s STRATEGY, --strategy STRATEGY	Geneva strategy to use (defaults to Segmentation > Reassembly > Offsets)
```

## Alternate strategies

You can dump the strategies with `sudo geneva -ls` to see the "genetic code" for each species and subspecies of traffic manipulation.

The program defaults to `Segmentation > Reassembly > Offsets` which has a 98%, 100%, and 100% success rate in China, India, and Kazakhstan, respectively.

To specify an alternate strategy, find the genetic code using `sudo geneva -ls`, and include it on the command line after the `-s|--strategy` parameter.

For instance, running `sudo geneva` is the equivalent of running the following:

```
sudo geneva -s "[TCP:flags:PA]-fragment{tcp:8:True}(,fragment{tcp:4:True})-|"
```

### Issues/Feature requests:

Submit an issue on GitHub.
