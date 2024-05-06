FROM mikeintosh/mrds_base_j:latest

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/MIKEINTOSHSYSTEMS/MIKEINTOSH_RDataSystems"

ENV DEBIAN_FRONTEND=noninteractive

## build ARGs
ARG NCPUS=${NCPUS:--1}

# USER ${RSESSION_USER}

RUN install2.r --error --skipinstalled -n $NCPUS \
    abind \
    autonewsmd \
    bib2df \
    bigmemory \
    billboarder \
    bookdown \
    class \
    cleaR \
    cluster \
    ClusterR \
    config \
    covr \
    cowplot \
    credentials \
    crosstable \
    curl \
    data.table \
    daterangepicker \
    DBI  \
    desc \
    DescTools \
    DescrTab2 \
    devtools \
    distill \
    DIZtools \
    doParallel \
    dotenv \
    dplyr \
    DT \
    dtplyr \
    dunn.test \
    effects \
    emmeans \
    fhircrackr \
    finalfit \
    foreach \
    formatR \
    # DQAstats:
    future \
    # DQAstats:
    future.apply \
    ggfortify \
    ggplot2 \
    ggpubr \
    ggside \
    ggstatsplot \
    gtsummary \
    gplots \
    highcharter \
    Hmisc \
    httr \
    influxdbr \
    jpeg \
    jsonlite \
    kableExtra \
    knitr \
    languageserver \
    ## For xaringan:
    leaflet \
    lintr \
    logger \
    lubridate \
    markdown \
    Matrix \
    metathis \
    ## `mice` for imputation of missing values:
    mice \
    microbenchmark \
    ## `missForest` for imputation of missing values:
    missForest \
    mlbench \
    ## Mixed model (for) repeated measurements:
    mmrm \
    naivebayes \
    odbc \
    openssl \
    openxlsx \
    pagedown \
    parallel \
    parsedate \
    pheatmap \
    plotly \
    plyr \
    psych \
    quarto \
    R.utils \
    R6 \
    rapportools \
    # rattle \
    rcmdcheck \
    RCurl \
    reactable \
    readr \
    redcapAPI \
    REDCapR \
    RefManageR \
    remotes \
    report \
    ## Reproducible Examples:
    reprex \
    reshape2 \
    # reticulate \
    rJava \
    RJDBC \
    RJSONIO \
    rlang \
    rmarkdown \
    Rmisc \
    roxygen2 \
    RPostgres \
    RSQLite \
    rstudioapi \
    see \
    shiny \
    shinyalert \
    shinydashboard \
    shinyFiles \
    shinyjs \
    shinytest \
    shinythemes \
    shinyWidgets \
    sjPlot \
    sjtable2df \
    skimr \
    sqldf \
    styler \
    summarytools \
    sunburstR \
    survival \
    survminer \
    testthat \
    tidyr \
    tidyverse \
    timeDate \
    tinytex \
    tiff \
    treemap \
    urltools \
    usethis \
    utf8 \
    ## `VIM` for visualizing missing values:
    VIM \
    wesanderson \
    wordcloud \
    wordcloud2 \
    xaringan \
    xfun \
    xgboost \
    XML \
    xml2 \
    yaml \
    zip \
    && rm -rf /tmp/downloaded_packages \
    && rm -rf /var/lib/apt/lists/*

USER ${RSESSION_USER}

# install required LaTeX-Packages
RUN R -q -e "tinytex::install_tinytex()"

ENV PATH="/home/${RSESSION_USER}/bin:/home/${RSESSION_USER}/.TinyTeX/bin/x86_64-linux:${PATH}"

ARG tiny="'amsfonts', \
    'amsmath', \
    'atveryend', \
    'babel', \
    'babel-german', \
    'caption', \
    'colortbl', \
    'dehyph-exptl', \
    'ec', \
    'environ', \
    'epstopdf-pkg', \
    'float', \
    'geometry', \
    'graphics', \
    'graphics-def', \
    'hycolor', \
    'hyperref', \
    'hyphen-german', \
    'iftex', \
    'koma-script', \
    'latex-graphics-dev', \
    'latexconfig', \
    'lm', \
    'makecell', \
    'multirow', \
    'oberdiek', \
    'pdfcrop', \
    'pdflscape', \
    'tabu', \
    'tex-gyre-math', \
    'texlive-scripts', \
    'threeparttable', \
    'threeparttablex', \
    'titling', \
    'tools', \
    'trimspaces', \
    'ulem', \
    'varwidth', \
    'wrapfig', \
    'ulem', \
    'url', \
    'xcolor'"

RUN R -q -e "tinytex::tlmgr_conf(); \
    tinytex::tlmgr_install(pkgs = c(${tiny})); \
    tinytex::tlmgr_update()"

USER root

RUN chown -R ${RSESSION_USER}:${RSESSION_USER} /home/${RSESSION_USER}/.TinyTeX && \
    chmod -R g+w /home/${RSESSION_USER}/.TinyTeX && \
    chown -R ${RSESSION_USER}:${RSESSION_USER} /usr/local/lib/R/site-library
    # && \ chmod -R g+wx /home/${RSESSION_USER}/bin



# safety-check at the end: 
# 1) look if everything is installed correctely (if not, you might add system-dependencies in the base_image)
# 2) update all packages to the newest version
# 3) start rstudio-server
# ARG allpackages="\"$a\" \"$b\" \"$c\" \"$d\" \"$e\" \"$f\" \"$g\" \"$h\" \
#     \"$i\" \"$j\" \"$k\" \"$l\" \"$m\" \"$n\" \"$o\" \"$p\" \"$q\" \"$r\" \
#     \"$s\" \"$t\" \"$u\" \"$v\" \"$w\" \"$x\" \"$y\" \"$z\""

# RUN export packages_format="$(echo $(echo ${allpackages} | sed -e 's/ /\"\, \"/g') | sed -e 's/\"\"/\"/g')" && \
#     R -q -e "vec <- setdiff(c($packages_format), unname(installed.packages()[,\"Package\"])); print(vec); vec2 <- intersect(c(vec), unname(available.packages()[,\"Package\"])); print(vec2); install.packages(pkgs = vec2)"

# update all installed packages
RUN R -q -e "vec <- unname(installed.packages()[,\"Package\"]); remotes::update_packages(packages = vec, build_manual = FALSE, quiet = TRUE, upgrade = \"always\")"  && \
    rm -rf /tmp/*

USER ${RSESSION_USER}

ARG GITHUB_PAT

# configure the other r packages
# install phantomjs
RUN R -q -e "webshot::install_phantomjs(); \
    ## Install shinytest dependencies (= phantomjs):
    shinytest::installDependencies()"
# RUN R -q -e "credentials::set_github_pat('${GITHUB_PAT}'); \
#     usethis::git_sitrep()"


# Install the stuff, where I participate:
# RUN R -q -e "devtools::install_git(url = 'https://gitlab.miracum.org/miracum/dqa/dqastats.git', ref = 'master')"
# RUN R -q -e "devtools::install_git(url = 'https://gitlab.miracum.org/miracum/dqa/dqagui.git', ref = 'master')"
RUN R -q -e "remotes::install_git(url = 'https://gitlab.miracum.org/miracum/dqa/miRacumdqa.git', ref = 'master'); \
    remotes::install_github(repo = 'miracum/misc-dizutils', ref = 'development'); \
    # remotes::install_github(repo = 'miracum/misc-diztools', ref = 'dev'); \
    # remotes::install_github(repo = 'joundso/mainzelliste-connector', ref = 'development'); \
    # remotes::install_github(repo = 'joundso/rkafka', ref = 'development'); \
    # remotes::install_github(repo = 'joundso/gpas_connector', ref = 'development'); \
    # remotes::install_github(repo = 'joundso/requirements', ref = 'development'); \
    # remotes::install_github(repo = 'joundso/usRbility', ref = 'dev'); \
    remotes::install_github(repo = 'joundso/cleaR', ref = 'dev'); \

    ## Other stuff:
    ## Formatting comments and RMarkdown tables:
    remotes::install_github(repo = 'mwip/beautifyR'); \

    ## Addin to easy insert roxygen formatting options:
    remotes::install_github('matt-dray/snorkel'); \

    ## Explore data and create ggplots:
    remotes::install_github('dreamRs/esquisse'); \

    ## Data Analytics:
    remotes::install_github('radiant-rstats/radiant.update', upgrade = 'never'); \
    radiant.update::radiant.update(); \

    ## Presentations with xaringan:
    # remotes::install_github('yihui/xaringan'); \
    # remotes::install_github('jhelvy/xaringanBuilder'); \
    # devtools::install_github('gadenbuie/xaringanExtra'); \

    ## Rattle for models:
    ## (since `RGtk2` is no longer on CRAN, we use the last version from the archive
    ## https://cran.r-project.org/src/contrib/Archive/RGtk2/
    ## https://cran.r-project.org/package=RGtk2
    ## here:)
    # install.packages('https://cran.r-project.org/src/contrib/Archive/RGtk2/RGtk2_2.20.36.3.tar.gz', repos=NULL); \
    # install.packages('rattle', repos='https://rattle.togaware.com', type='source'); \

    ## Stuff to don't repeat myself:
    remotes::install_github('kapsner/kdry'); \
    "


USER root
## Change rights to access packages as user 'user':
# RUN chown -R ${RSESSION_USER}:${RSESSION_USER} /usr/local/lib/R/site-library

RUN yes | pip install --no-cache-dir \
    # git+https://github.com/miracum/dqa-mdr-connector.git && \
    git+https://github.com/miracum/dqa-mdr-connector@development && \
    # clear caches
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /home/${USER_UID}/.cache/pip/* && \
    apt-get clean && apt-get autoclean && apt-get autoremove -y

# install sudo here, required for rstudio:
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /home/${RSESSION_USER}/.cache/pip/* && \
    apt-get clean all && \
    apt-get autoclean && \
    apt-get autoremove -y && \

    # set ubuntu password here (password required for rstudio login)
    echo ${USER}:password | chpasswd  && \
    echo ${USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER}

# make deployed shiny app accessible via port 3838
RUN echo "options(shiny.port = 3838)" >> /home/${RSESSION_USER}/.Rprofile && \
    echo "options(shiny.host = '0.0.0.0')" >> /home/${RSESSION_USER}/.Rprofile && \
    echo "options(shiny.launch.browser = FALSE)" >> /home/${RSESSION_USER}/.Rprofile && \
    echo "options(shiny.error = browser)" >> /home/${RSESSION_USER}/.Rprofile && \
    echo "options(shiny.fullstacktrace = TRUE)" >> /home/${RSESSION_USER}/.Rprofile && \
    # https://github.com/Ikuyadeu/vscode-R#r-session-watcher-experimental
    echo "source(file.path(Sys.getenv(if (.Platform\$OS.type == 'windows') 'USERPROFILE' else 'HOME'), '.vscode-R', 'init.R'))" >> /home/${RSESSION_USER}/.Rprofile && \
    chown -R ${RSESSION_USER}:${RSESSION_USER} /home/${RSESSION_USER}/.Rprofile

# add PATH to a bash_profile script (workaround so that path is available in rstudio's terminal)
# https://support.rstudio.com/hc/en-us/articles/115010737148-Using-the-RStudio-Terminal#env
# https://docs.rstudio.com/ide/server-pro/1.2.1293-1/r-sessions.html
RUN echo "export PATH=${PATH}" >> /home/${RSESSION_USER}/.bash_profile && chmod +x /home/${RSESSION_USER}/.bash_profile

# set PATH for all users
RUN echo "PATH=${PATH}" >> /etc/R/Renviron && \
    echo "PATH=${PATH}" >> /etc/environment

# add radian profile
ADD config/.radian_profile /home/${RSESSION_USER}/.radian_profile
RUN chown -R ${RSESSION_USER}:${RSESSION_USER} /home/${RSESSION_USER}/.radian_profile

# fix permissions in home folder
# RUN chown -R ${RSESSION_USER}:${RSESSION_USER} /home/${RSESSION_USER}/.local

# Add JDBC drivers:
RUN mkdir -p /opt/libs && \
    curl -SL https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/19.8.0.0/ojdbc8-19.8.0.0.jar -o /opt/libs/ojdbc8.jar && \
    curl -SL https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc10/19.8.0.0/ojdbc10-19.8.0.0.jar -o /opt/libs/ojdbc10.jar  && \
    chown -R ${RSESSION_USER}:${RSESSION_USER} /opt/libs/ && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /home/${USER}/.cache/pip/* && \
    apt-get clean all && \
    apt-get autoclean && \
    apt-get autoremove -y

WORKDIR /home/${RSESSION_USER}
