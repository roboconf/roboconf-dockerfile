#!/bin/bash

# Copyright 2016-2017 Linagora, Université Joseph Fourier, Floralis
#
# The present code is developed in the scope of the joint LINAGORA - Université
# Joseph Fourier - Floralis research program and is designated as a "Result"
# pursuant to the terms and conditions of the LINAGORA - Université Joseph
# Fourier - Floralis research program. Each copyright holder of Results
# enumerated here above fully & independently holds complete ownership of the
# complete Intellectual Property rights applicable to the whole of said Results,
# and may freely exploit it in any manner which does not infringe the moral
# rights of the other copyright holders.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo
echo "Verifying parameters..."
echo

if [[ -z $1  ]]; then
	echo "Type parameter is the first one expected and is mandatory."
	echo "Usage: release.sh <dm|agent> <version (optional)>"
	exit 1
fi


if [[ "$1" != "dm" && "$1" != "agent"  ]]; then
	echo "Invalid option: $1. Only 'dm' and 'agent' are acceptable values."
	echo "Usage: release.sh <dm|agent> <version (optional)>"
	exit 1
fi

VERSION="LATEST"
POLICY="snapshots"
if [[ -z $2  ]]; then
	echo "Version parameter was not set. LATEST snapshot will be used."
else
	VERSION=$2
	if [[ "$2" != *"-SNAPSHOT" ]]; then
		POLICY="releases"
	fi
fi



echo
echo "Building the images..."
echo

docker build \
		--build-arg RBCF_KIND=$1 \
		--build-arg RBCF_VERSION=${VERSION} \
		--build-arg MAVEN_POLICY=${POLICY} \
		-t roboconf/roboconf-$1:latest \
		-t roboconf/roboconf-$1:${VERSION} \
		..
