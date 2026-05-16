FROM debian:bookworm-slim AS download
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl unzip \
    && curl -fsSL https://github.com/ec-/Quake3e/releases/download/latest/quake3e-linux-x86_64.zip \
       -o /tmp/quake3e.zip \
    && unzip /tmp/quake3e.zip quake3e.ded.x64 -d /tmp

FROM debian:bookworm-slim
RUN groupadd -r quake3e \
    && useradd -r -g quake3e -d /pufferpanel/.q3a -s /sbin/nologin quake3e \
    && mkdir -p /pufferpanel/.q3a/baseq3 \
    && chown -R quake3e:quake3e /pufferpanel
COPY --from=download /tmp/quake3e.ded.x64 /usr/local/bin/quake3e.ded
RUN chmod +x /usr/local/bin/quake3e.ded
USER quake3e
WORKDIR /pufferpanel/.q3a
EXPOSE 27960/udp
CMD ["quake3e.ded", "+set", "fs_homepath", "/pufferpanel/.q3a"]
