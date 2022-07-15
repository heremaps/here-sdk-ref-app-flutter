#!/bin/bash
#!
#! Copyright (C) 2020-2022 HERE Europe B.V.
#!
#! Licensed under the Apache License, Version 2.0 (the "License");
#! you may not use this file except in compliance with the License.
#! You may obtain a copy of the License at
#!
#!     http://www.apache.org/licenses/LICENSE-2.0
#!
#! Unless required by applicable law or agreed to in writing, software
#! distributed under the License is distributed on an "AS IS" BASIS,
#! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#! See the License for the specific language governing permissions and
#! limitations under the License.
#!
#! SPDX-License-Identifier: Apache-2.0
#! License-Filename: LICENSE
 
START_DIR=$(dirname "$0")
cd "$START_DIR"

if [ -z "$HERESDK_ACCESS_KEY_ID" ] || [ -z "$HERESDK_ACCESS_KEY_SECRET" ]; then
    echo "To build this application, an access key id and secret are required to be defined. Please create environment"
    echo "variables named HERESDK_ACCESS_KEY_ID and HERESDK_ACCESS_KEY_SECRET which contain these values and try again."
    exit 1
fi

touch Flutter/GeneratedKeys.xcconfig
echo HERESDK_ACCESS_KEY_ID=$HERESDK_ACCESS_KEY_ID > Flutter/GeneratedKeys.xcconfig
echo HERESDK_ACCESS_KEY_SECRET=$HERESDK_ACCESS_KEY_SECRET >> Flutter/GeneratedKeys.xcconfig
