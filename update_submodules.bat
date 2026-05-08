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
set "HERE_ICON_LIBRARY_COMMIT_ID=f8920855366266e400cfa7944c8143e627757c1a"

:: Step 1: Initialize any submodule that has not been cloned yet, then fetch
:: and check out the recorded submodule commits.  --recursive handles nested
:: submodules if any are added in the future.
echo Initializing and updating submodules...
git submodule update --init --recursive

:: Verify Step 1 succeeded before proceeding.  Exiting early here prevents
:: the checkout step from running against a missing or incomplete submodule.
if errorlevel 1 (
    echo Failed to initialize and update submodules.
    exit /b 1
)

:: Step 2: Checkout the submodule to a fixed commit ID
:: This is useful when you want to pin the submodule to a specific version
echo Checking out submodule "%SUBMODULE_PATH%" to commit %HERE_ICON_LIBRARY_COMMIT_ID%...
pushd "%SUBMODULE_PATH%"
git checkout %HERE_ICON_LIBRARY_COMMIT_ID% --force

:: Verify Step 2 succeeded.  popd is called before exiting so the working
:: directory is restored even on failure.
if errorlevel 1 (
    echo Failed to checkout commit %HERE_ICON_LIBRARY_COMMIT_ID% in submodule "%SUBMODULE_PATH%".
    popd
    exit /b 1
)
popd

echo Submodule synced to commit %HERE_ICON_LIBRARY_COMMIT_ID% successfully.

:: Release all locally scoped variables and restore the previous environment.
endlocal
exit /b 0
