#!/bin/bash

# Copyright 2016 Linagora, Université Joseph Fourier, Floralis
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
	echo "Type parameter is mandatory."
	echo "Usage: verify.sh <dm|agent>"
	exit 1
fi

if [[ "$1" != "dm" && "$1" != "agent"  ]]; then
	echo "Invalid option: $1. Only 'dm' and 'agent' are acceptable values."
	echo "Usage: verify.sh <dm|agent>"
	exit 1
fi



echo
echo "Launching the tests for $1..."
echo

SUCCESS="true"

docker run -d --name "rbcf-test" -e MESSAGING_TYPE=http roboconf/roboconf-$1:latest
sleep 3
INSPECT_OUTPUT=$(docker inspect -f {{.State.Running}} "rbcf-test")
echo "lol ${INSPECT_OUTPUT}"
if [[ "${INSPECT_OUTPUT}"  == "false" ]]; then
	echo "Container 'rbcf-test' is not running."
	SUCCESS="false"
else
	echo "Container 'rbcf-test' is running."
fi



echo
echo "Checking some little things..."
echo



echo
echo "Deleting the created container..."
echo

docker kill "rbcf-test" >/dev/null 2>&1
if [[ $? != "0" ]]; then
	echo "Failed to kill and delete the 'rbcf-test' container."
	SUCCESS="false"
fi

docker rm -f "rbcf-test" >/dev/null 2>&1
if [[ $? != "0" ]]; then
	echo "Failed to kill and delete the 'rbcf-test' container."
	SUCCESS="false"
fi



echo
echo "Conclusion..."
echo

if [[ "${SUCCESS}" == "true" ]]; then
	echo "Tests were successful."
else
	echo "Tests failed."
fi
