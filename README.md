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

## Environment

Every shell gets its ROS environment from the top of `/root/.bashrc`: the container's main process (the entrypoint sources that file) and `docker exec -it <container> bash` alike. In order:

1. `/opt/ros/$ROS_DISTRO/setup.bash`
2. `$ROS_UNDERLAY/setup.bash`, if a derived image sets `ROS_UNDERLAY` (`ros2_control_image` sets it to `/opt/ros2_control_ws/install`)
3. `$ROS2_WS/install/setup.bash`, i.e. `/workspaces`, once something has been built there (`r`)

A derived image that builds its own packages outside `/workspaces` only needs `ENV ROS_UNDERLAY=<its install directory>`, not an entrypoint of its own.

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

Builds run on GitHub Actions ([`.github/workflows/docker-publish.yml`](.github/workflows/docker-publish.yml)). amd64 (`ubuntu-24.04`) and arm64 (`ubuntu-24.04-arm`) build natively on separate runners, then get combined into one multi-arch image at `ghcr.io/<repo owner>/ros_jazzy_base_image`. No secrets are needed; it uses the built-in `GITHUB_TOKEN`.

There are two ways to publish:

- **Push a version tag** such as `1.0.0`, `v1.0.0` or `1.0.0-rc1`. A leading `v` is dropped from the image tag. The image is also tagged `latest`, unless the version has a suffix such as `-rc1` (a pre-release).

  ```bash
  git tag -a 0.2.0 -m "Release 0.2.0"
  git push origin 0.2.0
  ```

- **Run it from the Actions tab**: *Build and publish Docker image* → *Run workflow*, then enter a version and choose whether to also tag it `latest`. It builds the branch or tag picked under *Use workflow from* and doesn't create a git tag.

## Troubleshooting

If `scripts/local_buildx_push.sh` fails to build arm64 with a `libc-bin` segmentation fault, it's a known QEMU emulation issue on some hosts. Try:

```bash
docker pull tonistiigi/binfmt:latest
docker run --privileged --rm tonistiigi/binfmt --uninstall qemu-*
docker run --privileged --rm tonistiigi/binfmt --install all
```

A non-interactive `docker exec <container> bash -c '...'` doesn't read `.bashrc`, so `ros2` isn't on the `PATH` there. Run it through the entrypoint instead:

```bash
docker exec <container> /ros_entrypoint.bash bash -c 'ros2 topic list'
```
