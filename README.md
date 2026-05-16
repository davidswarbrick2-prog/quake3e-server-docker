# quake3e-server-docker

Docker image for a [Quake3e](https://github.com/ec-/Quake3e) dedicated server, built automatically from the latest upstream release and published to GitHub Container Registry.

## Image

```
ghcr.io/davidswarbrick2-prog/quake3e-server-docker:latest
```

The image is rebuilt weekly, tracking the Quake3e rolling `latest` release tag.

## Usage

Quake III Arena pak files (`pak0.pk3` – `pak8.pk3`) must be mounted into `/pufferpanel/.q3a/baseq3`:

```bash
docker run -d \
  -p 27960:27960/udp \
  -v /path/to/paks:/pufferpanel/.q3a/baseq3:ro \
  ghcr.io/davidswarbrick2-prog/quake3e-server-docker:latest
```

Additional server arguments can be appended:

```bash
docker run -d \
  -p 27960:27960/udp \
  -v /path/to/paks:/pufferpanel/.q3a/baseq3:ro \
  ghcr.io/davidswarbrick2-prog/quake3e-server-docker:latest \
  quake3e.ded +set fs_homepath /pufferpanel/.q3a +set dedicated 2 +exec server.cfg
```

## Building locally

```bash
docker build -t quake3e-server-docker .
```

## How it works

The image uses a multi-stage build:

**Stage 1 — download:** Based on `debian:bookworm-slim`. Downloads `quake3e-linux-x86_64.zip` from the Quake3e latest release and extracts the dedicated server binary.

**Stage 2 — runtime:** Based on `debian:bookworm-slim`. Copies only the binary into a clean image, creates a non-root `quake3e` user, and sets up `/pufferpanel/.q3a/baseq3` as the pak file mount point.

| Detail | Value |
|--------|-------|
| Binary path | `/usr/local/bin/quake3e.ded` |
| Pak file mount | `/pufferpanel/.q3a/baseq3` |
| Working directory | `/pufferpanel/.q3a` |
| Exposed port | `27960/udp` |
| Runs as | `quake3e` (non-root) |

## Automatic builds

The GitHub Actions workflow rebuilds and pushes the image on:
- A weekly schedule (Sunday midnight UTC)
- Manual trigger via `workflow_dispatch`

No secrets beyond the built-in `GITHUB_TOKEN` are required.

## PufferPanel template

This image is designed for use with PufferPanel. The relevant environment block:

```json
{
  "type": "docker",
  "networkName": "q3-net",
  "bindings": {
    "/opt/q3/servers/quake3/baseq3": "/pufferpanel/.q3a/baseq3"
  },
  "portBindings": [
    "27960:27960/udp"
  ],
  "image": "ghcr.io/davidswarbrick2-prog/quake3e-server-docker:latest"
}
```

The run command for the PufferPanel template:

```
/usr/local/bin/quake3e.ded +set dedicated 2 +set net_port 27960 +exec server.cfg
```
