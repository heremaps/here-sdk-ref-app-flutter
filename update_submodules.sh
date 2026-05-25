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
set -euo pipefail

# The exact commit SHA from the here-icons submodule repository that this
# project depends on. Pinning to a specific commit (rather than a branch tip)
# guarantees reproducible builds: every developer and CI run checks out
# the identical icon assets regardless of upstream changes.
#
# To update: run `git log --oneline` inside assets/here-icons, choose the
# desired commit, paste the full SHA here, and update the parent repo pointer
# with `git add assets/here-icons && git commit`.
HERE_ICON_LIBRARY_COMMIT_ID="11b8592957e597648910d56137feb15ee0f5d4bb"

# Path to the submodule relative to the repository root.
SUBMODULE_PATH="assets/here-icons"

echo "Syncing submodule configuration..."
git submodule sync --recursive

echo "Initializing/updating ${SUBMODULE_PATH}..."
git submodule update --init --recursive "${SUBMODULE_PATH}"

# Fetch ensures the pinned commit object is available locally.
echo "Fetching latest refs for ${SUBMODULE_PATH}..."
git -C "${SUBMODULE_PATH}" fetch origin --prune --tags

# Validate commit exists before checkout to give a clear error.
echo "Validating pinned commit..."
if ! git -C "${SUBMODULE_PATH}" cat-file -e "${HERE_ICON_LIBRARY_COMMIT_ID}^{commit}"; then
  echo "ERROR: Commit ${HERE_ICON_LIBRARY_COMMIT_ID} not found in ${SUBMODULE_PATH}."
  echo "Check the SHA and verify it exists on remote origin."
  exit 1
fi

echo "Checking out pinned commit..."
git -C "${SUBMODULE_PATH}" checkout --force "${HERE_ICON_LIBRARY_COMMIT_ID}"

echo "Submodule updated successfully: ${SUBMODULE_PATH} @ ${HERE_ICON_LIBRARY_COMMIT_ID}"