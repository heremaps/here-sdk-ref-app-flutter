::
::  Copyright (C) 2025-2026 HERE Europe B.V.
::
::    Licensed under the Apache License, Version 2.0 (the "License");
::    you may not use this file except in compliance with the License.
::    You may obtain a copy of the License at

::    http://www.apache.org/licenses/LICENSE-2.0
::
::    Unless required by applicable law or agreed to in writing, software
::    distributed under the License is distributed on an "AS IS" BASIS,
::    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
::    See the License for the specific language governing permissions and
::    limitations under the License.
::
::  SPDX-License-Identifier: Apache-2.0
::  License-Filename: LICENSE
::

:: Disable command echoing so only explicit echo statements appear in output.
@echo off

:: Use SETLOCAL to scope all variable changes to this script.
:: This prevents environment variable pollution in the caller's shell session.
setlocal

:: ----------------------------------------------------------------------------
:: Initializes, updates, and pins the here-icons Git submodule to a specific
:: commit SHA.  Pinning guarantees reproducible builds: every developer and
:: CI run checks out the identical icon assets regardless of upstream changes.
::
:: Windows counterpart of update_submodules.sh — keep both files in sync when
:: changing the pinned commit or submodule path.
:: ----------------------------------------------------------------------------

:: Path to the submodule relative to the repository root.
set "SUBMODULE_PATH=assets/here-icons"

:: The exact commit SHA from the here-icons submodule repository that this
:: project depends on.  Pinning to a specific commit (rather than a branch tip)
:: guarantees reproducible builds across all environments.
::
:: To update: run "git log --oneline" inside assets/here-icons, choose the
:: desired commit, paste the full SHA here, and update the parent repo pointer
:: with "git add assets/here-icons" followed by "git commit".
set "HERE_ICON_LIBRARY_COMMIT_ID=11b8592957e597648910d56137feb15ee0f5d4bb"

:: Initialize any submodule that has not been cloned yet, then fetch
:: and check out the recorded submodule commits.  --recursive handles nested
:: submodules if any are added in the future.
echo Syncing submodule configuration...
git submodule sync --recursive
if errorlevel 1 goto :error

echo Initializing/updating %SUBMODULE_PATH%...
git submodule update --init --recursive "%SUBMODULE_PATH%"
if errorlevel 1 goto :error

:: Fetch ensures the pinned commit object is available locally.
echo Fetching latest refs for %SUBMODULE_PATH%...
git -C "%SUBMODULE_PATH%" fetch origin --prune --tags
if errorlevel 1 goto :error

:: Validate commit exists before checkout to give a clear error.
echo Validating pinned commit...
git -C "%SUBMODULE_PATH%" cat-file -e %HERE_ICON_LIBRARY_COMMIT_ID%^{commit}
if errorlevel 1 (
  echo ERROR: Commit %HERE_ICON_LIBRARY_COMMIT_ID% not found in %SUBMODULE_PATH%.
  echo Check the SHA and verify it exists on remote origin.
  goto :error
)

echo Checking out pinned commit...
git -C "%SUBMODULE_PATH%" checkout --force %HERE_ICON_LIBRARY_COMMIT_ID%
if errorlevel 1 goto :error

echo Submodule updated: %SUBMODULE_PATH% @ %HERE_ICON_LIBRARY_COMMIT_ID%

:: Release all locally scoped variables and restore the previous environment.
endlocal
exit /b 0

:error
echo Failed to initialize/update submodules.
exit /b 1