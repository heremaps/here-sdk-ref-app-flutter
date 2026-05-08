#!/bin/bash
#
#  Copyright (C) 2025-2026 HERE Europe B.V.
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

# Exit immediately if any command returns a non-zero status.
# This ensures that errors are caught early and the script does not continue in a broken state.
set -e

# The exact commit SHA from the here-icons submodule repository that this
# project depends on. Pinning to a specific commit (rather than a branch tip)
# guarantees reproducible builds: every developer and CI run checks out
# the identical icon assets regardless of upstream changes.
#
# To update: run `git log --oneline` inside assets/here-icons, choose the
# desired commit, paste the full SHA here, and update the parent repo pointer
# with `git add assets/here-icons && git commit`.
HERE_ICON_LIBRARY_COMMIT_ID="f8920855366266e400cfa7944c8143e627757c1a"

# Initialize any submodule that has not been cloned yet, then fetch and
# check out the recorded submodule commits.  --recursive handles nested submodules if any are added in the future.
echo "Initializing and updating submodules..."
git submodule update --init --recursive
git submodule foreach --recursive "git checkout $HERE_ICON_LIBRARY_COMMIT_ID --force"

# Verify that the checkout succeeded.  Although `set -e` would catch a
# non-zero exit from the commands above, an explicit check here provides
# a human-readable error message for CI logs and developer output.
if [ $? -ne 0 ]; then
    echo "Failed to update submodules."
    exit 1
fi

echo "Submodules updated successfully."