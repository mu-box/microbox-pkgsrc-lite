#!/bin/bash
# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=8 ft=bash noet

detect_platform() {
  if [ $(uname | grep 'SunOS') ]; then
    echo "SmartOS"
  elif [ $(uname | grep 'Linux') ]; then
    echo "Linux"
  fi
}

publish_file() {
  secret=$1
  user=$2
  project=$3
  platform=$4
  file=$5
  echo $file
  curl \
    -k \
    -X POST \
    -H "Key: ${secret}" \
    --data-binary \@/content/packages/pkgsrc/${project}/${platform}/All/${file} \
    https://pkgsrc.microbox.cloud/${user}/${project}/${platform}/${file}
  echo ""
}

publish_all() {
  secret=$1
  user=$2
  project=$3
  platform=$4
  uploaded=$(curl -k -s https://pkgsrc.microbox.cloud/${user}/${project}/${platform}/ | sed 's/<a href=".*">//g;s,</a>.*$,,g;s/<.*>//g')
  for file in $(ls /content/packages/pkgsrc/${project}/${platform}/All/*)
  do
    file=$(basename ${file})
    if ! echo "${uploaded}" | grep -q "^${file}$"
    then
      publish_file ${secret} ${user} ${project} ${platform} ${file}
    fi
  done
}

publish_all ${MICROBOX_SECRET} ${MICROBOX_USER} ${MICROBOX_PROJECT} $(detect_platform)
