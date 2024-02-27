FROM alpine:latest
MAINTAINER insekticid <elasticsearch@exploit.cz>

ARG HUNSPELL_BASE_URL="https://raw.githubusercontent.com/LibreOffice/dictionaries/master"

RUN apk add --no-cache \
    hunspell 

RUN mkdir -p /usr/share/hunspell /usr/share/elasticsearch/config/hunspell \
  && { \
       echo "en_US en/en_US"; \
       echo "ru_RU ru_RU/ru_RU"; \
     } > /tmp/hunspell.txt \
  && cd /usr/share/elasticsearch/config/hunspell \
  && cat /tmp/hunspell.txt | while read line; do \
       name=$(echo $line | awk '{print $1}'); \
       file=$(echo $line | awk '{print $2}'); \
       echo "${HUNSPELL_BASE_URL}/${file}.aff"; \
       mkdir -p "${name}"; \
       wget -O "${name}/${name}.aff" "${HUNSPELL_BASE_URL}/${file}.aff"; \
       wget -O "${name}/${name}.dic" "${HUNSPELL_BASE_URL}/${file}.dic"; \
       ls -al "${name}"; \
       echo -e "strict_affix_parsing: true\nignore_case: true" > ${name}/settings.yml; \
     done

RUN ln -s /usr/share/elasticsearch/config/hunspell/ru_RU/ru_RU.aff /usr/share/hunspell/default.aff \
  && ln -s /usr/share/elasticsearch/config/hunspell/ru_RU/ru_RU.dic /usr/share/hunspell/default.dic

COPY entrypoint.sh /

WORKDIR /workdir
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
