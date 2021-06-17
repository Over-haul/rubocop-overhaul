#!/bin/bash
export GEM_NAME=rubocop-overhaul
export NEXUS_REPOSITORY=https://nexus.aws.over-haul.com/repository/${GEM_NAME}

env

gem build ${GEM_NAME}*.gemspec
gem nexus --url ${NEXUS_REPOSITORY} --credential ${NEXUS_LOGIN}:${NEXUS_PASSWORD} ${GEM_NAME}*.gem
