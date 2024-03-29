FROM debian:buster

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/XiangyunHuang/RGraphics" \
      org.label-schema.vendor="RGraphics Project" \
      maintainer="Xiangyun Huang <xiangyunfaith@outlook.com>"

ARG PANDOC_VERSION=2.7.3
ARG R_VERSION=3.6.1

ENV TERM=xterm \
    DEBIAN_FRONTEND=noninteractive \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN useradd docker \
  && mkdir /home/docker \
  && chown docker:docker /home/docker \
  && addgroup docker staff \
  && mkdir /home/docker/workspace


RUN apt-get update \
  && apt-get install -y apt-transport-https ca-certificates \
  && mv /etc/apt/sources.list /etc/apt/sources.list.bak \
  && echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free" >> /etc/apt/sources.list \
  && echo "# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free" >> /etc/apt/sources.list \
  && echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list \
  && echo "# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list \
  && echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-backports main contrib non-free" >> /etc/apt/sources.list \
  && echo "# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-backports main contrib non-free" >> /etc/apt/sources.list \
  && echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list \
  && echo "# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list \
  && apt-get update

RUN apt-get install -yq --no-install-recommends \
    apt-utils \
    wget \
    gnupg \
    dialog \
    locales \
  ## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
  && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure locales \
  && update-locale LANG=en_US.UTF-8

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8


RUN sed -i -- 's/#deb-src/deb-src/g' /etc/apt/sources.list \
  && sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list \
  && wget -q --no-check-certificate "https://travis-bin.yihui.name/texlive-local.deb" \
  && dpkg -i texlive-local.deb \
  && rm texlive-local.deb \
  && apt-get update \
  && apt-get build-dep -y --no-install-recommends r-base \
## TinyTeX
  && wget -qO- \
      "https://github.com/yihui/tinytex/raw/master/tools/install-unx.sh" | \
      sh -s - --admin --no-path \
  && mv ~/.TinyTeX /opt/TinyTeX \
  && /opt/TinyTeX/bin/*/tlmgr path add \
  && tlmgr install ae parskip listings \
  && tlmgr path add \
  && chown -R root:staff /opt/TinyTeX \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
## R source
  && url_prefix="https://mirrors.tuna.tsinghua.edu.cn/CRAN/src/base/" \
  && wget -q ${url_prefix}/R-3/R-${R_VERSION}.tar.gz \
  && tar -xzf R-${R_VERSION}.tar.gz \
  && cd R-${R_VERSION} \
  && ./configure --prefix=/opt/R/R-${R_VERSION} --enable-R-shlib --enable-memory-profiling \
  && make && make install \
  && cd .. && rm -rf R-${R_VERSION}* \
  && chown -R root:staff /opt/R/R-${R_VERSION}/lib/R/library \
  && echo "PATH=${PATH}" >> /opt/R/R-${R_VERSION}/lib/R/etc/Renviron \
  && echo "LANG=en_US.UTF-8" >> /opt/R/R-${R_VERSION}/lib/R/etc/Renviron.site \
  ## Add a default CRAN mirror
  && echo "options(repos = c(CRAN = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN/'), download.file.method = 'libcurl')" >> /opt/R/R-${R_VERSION}/lib/R/etc/Rprofile.site \
  && echo ".libPaths(c('/usr/local/lib/R/site-library','/opt/R/R-${R_VERSION}/lib/R/library'))" >> /opt/R/R-${R_VERSION}/lib/R/etc/Rprofile.site \
  && ln -s /opt/R/R-${R_VERSION}/lib/R/bin/R /usr/local/bin/R \
  && ln -s /opt/R/R-${R_VERSION}/lib/R/bin/Rscript /usr/local/bin/Rscript \
  && Rscript -e "install.packages(c('littler', 'codetools', 'remotes'))" \
  && ln -s /opt/R/R-${R_VERSION}/lib/R/library/littler/examples/install2.r /usr/local/bin/install2.r \
  && ln -s /opt/R/R-${R_VERSION}/lib/R/library/littler/examples/install.r /usr/local/bin/install.r \
  && ln -s /opt/R/R-${R_VERSION}/lib/R/library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
  && ln -s /opt/R/R-${R_VERSION}/lib/R/library/littler/bin/r /usr/local/bin/r \
  ## Add a library directory (for user-installed packages)
  && mkdir -p /usr/local/lib/R/site-library \
  && chown root:staff /usr/local/lib/R/site-library \
  && chmod g+wx /usr/local/lib/R/site-library \
  && install.r docopt tinytex \
  && Rscript -e "tinytex::r_texmf()" \
  && mkdir ~/.R \
  && echo "CXXFLAGS += -Wno-ignored-attributes" >> ~/.R/Makevars \
  && echo "CXX14 = g++" >> ~/.R/Makevars \
  && echo "CXX14FLAGS = -fPIC -flto=2 -mtune=native -march=native" >> ~/.R/Makevars \
  && echo "CXX14FLAGS += -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs" >> ~/.R/Makevars \
  && echo "CXX14FLAGS += -Wno-ignored-attributes -Wno-deprecated-declarations -Wno-attributes -O3" >> ~/.R/Makevars \
  && mkdir -p /opt/pandoc \
  && url_prefix="https://github.com/jgm/pandoc/releases/download" \
  && wget -q --no-check-certificate $url_prefix/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux.tar.gz -P /opt/pandoc/ \
  && tar -xzf /opt/pandoc/pandoc-${PANDOC_VERSION}-linux.tar.gz -C /opt/pandoc \
  && ln -s /opt/pandoc/pandoc-${PANDOC_VERSION}/bin/pandoc /usr/local/bin \
  && ln -s /opt/pandoc/pandoc-${PANDOC_VERSION}/bin/pandoc-citeproc /usr/local/bin \
  && rm /opt/pandoc/pandoc-${PANDOC_VERSION}-linux.tar.gz


RUN apt-get install -y --no-install-recommends \
  libnlopt-dev \
  jags \
  libcairo2-dev \
  libxml2-dev \
  libgmp-dev \
  libglpk-dev \
  libssl-dev \
  libcurl4-openssl-dev \
  libgit2-dev \
  libnode-dev \
  optipng \
  imagemagick \
  ghostscript \
  && apt-get clean all \
  && rm -rf /var/lib/apt/lists/*

RUN install2.r --error \
  knitr \
  rmarkdown \
  ggplot2 \
  Rcpp \
  testit \
  covr \
  roxygen2

EXPOSE 8787 8080 8181 8282

WORKDIR /home/docker/workspace
