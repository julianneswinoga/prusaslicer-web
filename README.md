# Web-based (VNC) PrusaSlicer
[![DockerHub Pulls](https://img.shields.io/docker/pulls/julianneswinoga/prusaslicer-web)](https://hub.docker.com/r/julianneswinoga/prusaslicer-web)

![](./images/screenshot.png)

TODO:
- [ ] Automatic image rebuilds on new upstream Prusa Slicer release
- [x] Intel/AMD GPU passthrough support
- [ ] NVidia GPU passthrough support
- [x] VNC password support
- [ ] Desktop theming

## Quick start `docker-compose` examples
### No GPU passthrough
```yaml
services:
  prusaslicer:
    image: julianneswinoga/prusaslicer-web:latest
    volumes:
      - <host config dir>:/configs
      - <host print dir>:/prints
```

### AMD GPU passthrough
```yaml
services:
  prusaslicer:
    image: julianneswinoga/prusaslicer-web:latest
    environment:
      - ENABLEHWGPU=true
      - VGL_DISPLAY=/dev/dri/card1  # You might need to play around with card0, card1, etc
    devices:
      - /dev/dri:/dev/dri
      - /dev/kfd:/dev/kfd
    volumes:
      - <host config dir>:/configs
      - <host print dir>:/prints
```

### Intel GPU passthrough
```yaml
services:
  prusaslicer:
    image: julianneswinoga/prusaslicer-web:latest
    environment:
      - ENABLEHWGPU=true
      - VGL_DISPLAY=/dev/dri/card1  # You might need to play around with card0, card1, etc
    devices:
      - /dev/dri:/dev/dri
    volumes:
      - <host config dir>:/configs
      - <host print dir>:/prints
    group_add:
      - 993  # This is for the host `render` group, see permissions on /dev/dri/*
```

### NVidia GPU passthrough
TODO!

## Container options
The default NoVNC port is `8080`, to change it just map to a new port. For example, to access NoVNC on `8077` instead:
```yaml
services:
    prusaslicer:
      # other config
      ports:
        - '8077:8080'
```

### Common environment variables

| Name           | Default value | Explanation                                                                                                  |
|----------------|---------------|--------------------------------------------------------------------------------------------------------------|
| `VNC_PASSWORD` | `<empty>`     | Set a password for to access the VNC web interface.                                                          |
| `ENABLEHWGPU`  | `<empty>`     | Set to `true` to attempt to run with hardware GPU acceleration.                                              |
| `VGL_DISPLAY`  | `egl`         | Manually set the VirtualGL display device. See https://virtualgl.org/vgldoc/2_0/#GLP_Usage for more details. |

### Full environment variables

| Name            | Default value | Explanation                                                                                                                                         |
|-----------------|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| `NOVNC_PORT`    | `8080`        | Change the port that NoVNC will listen on. Note that you can also [change the port mapping in the container service definition](#container-options) |
| `SUPD_LOGLEVEL` | `TRACE`       | `supervisord` log level (i.e. the container log output).                                                                                            |

----

Based off of the work from https://github.com/helfrichmichael/prusaslicer-novnc and https://github.com/helfrichmichael/prusaslicer-novnc/pull/23
