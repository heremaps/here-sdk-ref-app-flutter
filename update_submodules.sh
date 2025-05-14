#!/bin/bash
#
#  Copyright (C) 2025 HERE Europe B.V.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
#  SPDX-License-Identifier: Apache-2.0
#  License-Filename: LICENSE
#

set -e

HERE_ICON_LIBRARY_COMMIT_ID="f17e4cb733c1cafb5dfd9e5298a007af390f8153"

# Initialize and update submodules
echo "Initializing and updating submodules..."
git submodule update --init --recursive
git submodule foreach --recursive "git checkout $HERE_ICON_LIBRARY_COMMIT_ID --force"

# Check if the submodule update was successful
if [ $? -ne 0 ];  then
    echo "Failed to update submodules."
    exit 1
fi

echo "Submodules updated successfully."