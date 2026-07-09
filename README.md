# ROS Jazzy Base Image

A personal Docker base image built on top of `ros:jazzy-ros-base-noble` (Ubuntu 24.04), pre-installed with ROS2 Jazzy and common development tools.

## Image

Published automatically by GitLab CI on every tag push:

```
registry.screamtrumpet.csie.ncku.edu.tw/pochun/ros_jazzy_base_image:latest
```

Manual/local builds (`scripts/local_build.sh` / `scripts/local_buildx_push.sh`) push to:

```
ghcr.io/screamlab/ros_jazzy_base_image
```

## What's Included

- **ROS2 Jazzy** — ros-base, rosbridge, fastrtps middleware, domain-bridge
- **Development tools** — git, vim, tmux, htop, nvtop, clang-format, cppcheck, and more
- **C++ libraries** — Boost, libserial, nlohmann-json
- **Python** — pip, venv, orjson, pydantic 1.10, pyserial
- **Shell** — oh-my-bash with agnoster theme

## Shortcuts

| Alias | Command |
|-------|---------|
| `r` | `colcon build` + `source install/setup.bash` (via `rebuild_colcon.rc`) |
| `b` | Launch rosbridge WebSocket server |
| `m` | `make -j` |
| `l` | `ls -lash` |

`r` is a shortcut for:

```bash
source /workspaces/rebuild_colcon.rc
```

which runs `colcon build --symlink-install` in `/workspaces` and sources `install/setup.bash`.

## Run

```bash
docker run -it --rm registry.screamtrumpet.csie.ncku.edu.tw/pochun/ros_jazzy_base_image:latest
```

## Build Locally

```bash
# Build for current architecture only
bash scripts/local_build.sh

# Build for amd64 + arm64 and push
bash scripts/local_buildx_push.sh -t 1.0.0
```

## CI/CD

Pushing a tag to this repository triggers GitLab CI to build amd64 and arm64 natively on separate runners, then combine them into one multi-arch manifest and push it under both the tag name and `latest`.

## Troubleshooting

If `scripts/local_buildx_push.sh` fails to build arm64 with a `libc-bin` segmentation fault, it's a known QEMU emulation issue on some hosts. Try:

```bash
docker pull tonistiigi/binfmt:latest
docker run --privileged --rm tonistiigi/binfmt --uninstall qemu-*
docker run --privileged --rm tonistiigi/binfmt --install all
```
