
```bash
docker pull debian:buster
docker build -t xiangyunhuang/rcppml:${R_VERSION} -f docker/Dockerfile .
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker push xiangyunhuang/rcppml:${R_VERSION}
```

```yaml
services: docker

env:
  global:
    - DOCKER_OPTS="--rm -ti -v $(pwd):/mnt -w /mnt"
      DOCKER_CNTR="xiangyunhuang/rcppml"
      R_BLD_OPTS="--no-build-vignettes --no-manual"
      R_CHK_OPTS="--no-vignettes --no-manual"
      R_VERSION="3.6.1"
      PANDOC_VERSION="2.7.3"


before_install:
  - docker pull ${DOCKER_CNTR}
  - docker run ${DOCKER_OPTS} ${DOCKER_CNTR} r -p -e 'sessionInfo()'

install:
  - docker run ${DOCKER_OPTS} ${DOCKER_CNTR} R CMD build ${R_BLD_OPTS} .

script:
  - docker run ${DOCKER_OPTS} ${DOCKER_CNTR} R CMD check ${R_CHK_OPTS} RcppML_*.tar.gz

after_success:
  - docker run ${DOCKER_OPTS} -e CODECOV_TOKEN ${DOCKER_CNTR} r -l covr -e 'codecov()'
```

```bash
winpty docker run -it --name=rcppml debian:buster bash
export PANDOC_VERSION=2.7.3
export R_VERSION=3.6.1
export TERM=xterm \
    DEBIAN_FRONTEND=noninteractive \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
```
