# ROS Jazzy Base Image

A personal Docker base image built on top of `ros:jazzy-ros-base-noble` (Ubuntu 24.04), pre-installed with ROS2 Jazzy and common development tools.

## Image

Published automatically by GitHub Actions on every tag push:

```
ghcr.io/jcjcjc0705/ros_jazzy_base_image:latest
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
docker run -it --rm ghcr.io/jcjcjc0705/ros_jazzy_base_image:latest
```

## Build Locally

```bash
# Build for current architecture only
bash scripts/local_build.sh

# Build for amd64 + arm64 and push
bash scripts/local_buildx_push.sh -t 1.0.0
```

## CI/CD

Builds run on GitHub Actions ([`.github/workflows/docker-publish.yml`](.github/workflows/docker-publish.yml)).

Pushing a tag builds amd64 (`ubuntu-24.04`) and arm64 (`ubuntu-24.04-arm`) natively on separate runners, then combines them into one multi-arch manifest and pushes it to GHCR under both the tag name and `latest`:

```bash
git tag 0.2.0
git push origin 0.2.0
```

You can also start a build from the **Actions** tab (*Run workflow*). A manual run on a branch only publishes `sha-<short commit>`, so `latest` doesn't move.

The image goes to `ghcr.io/<repo owner>/ros_jazzy_base_image`, using the built-in `GITHUB_TOKEN`, so no secrets are needed.

## Troubleshooting

If `scripts/local_buildx_push.sh` fails to build arm64 with a `libc-bin` segmentation fault, it's a known QEMU emulation issue on some hosts. Try:

```bash
docker pull tonistiigi/binfmt:latest
docker run --privileged --rm tonistiigi/binfmt --uninstall qemu-*
docker run --privileged --rm tonistiigi/binfmt --install all
```

`docker exec -it <container> bash` into an already-running container does **not** go through `ENTRYPOINT` — `ros2`, `r`, and any workspace overlay under `/workspaces/install` won't be set up. Use:

```bash
docker exec -it <container> /ros_entrypoint.bash bash
```

so this exec'd process sources the same environment the container's main process did at startup.
