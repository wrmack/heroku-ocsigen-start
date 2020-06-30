#
# Base image
#

# Use the ocaml/opam2 staging image because don't need all architectures
# Use linux-amd64 - Heroku stacks are linux-amd64
FROM ocaml/opam2-staging:ubuntu-20.04-opam-linux-amd64

#
# Build the image layers
#

# Install required system packages (discovered by installing ocsigen interactively in running container)
RUN sudo apt-get update && sudo apt-get install --no-install-recommends -y \
    apt-utils \
    gettext-base \
    gosu \
    libgdm-dev \
    libgmp-dev \
    libpcre3-dev \
    libssl-dev \
    m4 \
    perl \
    pkg-config \
    zlib1g-dev 
# && sudo rm -rf /var/lib/apt/lists/*

# Initialise opam and install ocaml and ocsigen, answering all prompts with yes
# Disable sandboxing per https://github.com/ocaml/opam/issues/3498, https://github.com/ocaml/opam/issues/3424 
# Write opam env to bashrc
# If need to reinitialise opam, use --reinit as in: RUN opam init --disable-sandboxing --reinit -y
USER opam
ENV PATH='/home/opam/.opam/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
ENV CAML_LD_LIBRARY_PATH='/home/opam/.opam/default/lib/stublibs:/home/opam/.opam/default/lib/ocaml/stublibs:/home/opam/.opam/default/lib/ocaml'

RUN opam init --disable-sandboxing -y \
    && echo "$(opam env)" >> /home/opam/.bashrc \
    && opam install opam-depext ocamlfind -y \
    && opam-depext -i ocsigen-start -y \
    && opam env \
    && opam clean -a -c -r --logs --unused-repositories

# The following assumes the current directory includes a site, named 'site', setup locally using the command 'eliom-distillery -name site':
# .
# +-- Dockerfile
# +-- entrypoint.sh
# +-- local (empty directory)
# +-- site 
# |   +-- static/css 
# |       +-- site.css
# |   +-- .ocp-indent
# |   +-- Makefile    
# |   +-- Makefile.options    
# |   +-- Makefile.options.template (created by us for use in entrypoint.sh)
# |   +-- README
# |   +-- site.eliom
# |   +-- site.conf.in

# Copy all from current directory to image working directory
# Make script executable
# While building image layers, user is opam.  Heroku changes the user when container is started. 
WORKDIR /home/opam/eliom
COPY --chown=opam:opam . .
RUN chmod +x entrypoint.sh
WORKDIR /home/opam/eliom/site

#
# Container runtime
#

# Entrypoint script prepares Makefile.options using container environment variables
ENTRYPOINT ["/home/opam/eliom/entrypoint.sh"]

# Run it
CMD ["make", "test.byte"]