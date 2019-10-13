## From https://www.r-bloggers.com/deploying-an-r-shiny-app-with-docker/
## and https://www.bjoern-hartmann.de/post/learn-how-to-dockerize-a-shinyapp-in-7-steps/
##

#------------------------------------------------------------
# Prepare R/Shiny with all packages
#------------------------------------------------------------

FROM rocker/shiny:3.5.2

RUN apt-get update && apt-get install -y apt-utils \
    libcurl4-gnutls-dev libv8-3.14-dev \
    libssl-dev libxml2-dev  libjpeg-dev \
    libgl-dev libglu-dev tk-dev libhdf5-dev \
    libgit2-dev libssh2-1-dev

## ???
RUN mkdir -p /var/lib/shiny-server/bookmarks/shiny
RUN mkdir -p /omicsplayground/ext/
WORKDIR /omicsplayground

## Upload some packages/files that are needed to the image
COPY ext/nclust1_1.9.4.tar.gz \
     ext/nclust_2.1.1.tar.gz \
     ext/fpc_2.1-10.tar.gz \
     ext/pathview_1.16.7.tar.gz \
     ext/FARDEEP_1.0.1.tar.gz \
     ext/Seurat_v2.3.3.tar.gz \
     ext/

# Install R packages that are required
COPY R/requirements.R /tmp
RUN R -e "source('/tmp/requirements.R')"

# Some extra packages so we can use docker cache
COPY R/requirements2.R /tmp
RUN R -e "source('/tmp/requirements2.R')"  

#------------------------------------------------------------
# Install all Playground and some data under /omicsplayground
#------------------------------------------------------------

RUN mkdir -p /omicsplayground/pgx
COPY pgx /omicsplayground/pgx
COPY shiny /omicsplayground/shiny
COPY R /omicsplayground/R
COPY lib /omicsplayground/lib
COPY scripts /omicsplayground/scripts

RUN chmod -R ugo+rwX /omicsplayground

#------------------------------------------------------------
# Copy further configuration files into the Docker image
#------------------------------------------------------------
COPY docker/shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY docker/shiny-server.sh /usr/bin/shiny-server.sh

EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"]
