::
::  Copyright (C) 2025 HERE Europe B.V.
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

@echo off
setlocal

:: ----------------------------------------------------------------------------
:: Script to initialize, update, and checkout a specific submodule to a fixed commit
:: This script is for projects where submodule content is not modified directly.
:: ----------------------------------------------------------------------------

:: Define the submodule path and desired commit ID to sync to
set "SUBMODULE_PATH=assets/here-icons"
set "HERE_ICON_LIBRARY_COMMIT_ID=f17e4cb733c1cafb5dfd9e5298a007af390f8153"

:: Step 1: Initialize and update the submodule recursively
echo Initializing and updating submodules...
git submodule update --init --recursive

:: Check if the submodule update was successful
if errorlevel 1 (
    echo Failed to initialize and update submodules.
    exit /b 1
)

:: Step 2: Checkout the submodule to a fixed commit ID
:: This is useful when you want to pin the submodule to a specific version
echo Checking out submodule "%SUBMODULE_PATH%" to commit %HERE_ICON_LIBRARY_COMMIT_ID%...
pushd "%SUBMODULE_PATH%"
git checkout %HERE_ICON_LIBRARY_COMMIT_ID% --force
if errorlevel 1 (
    echo Failed to checkout commit %HERE_ICON_LIBRARY_COMMIT_ID% in submodule "%SUBMODULE_PATH%".
    popd
    exit /b 1
)
popd

echo Submodule synced to commit %HERE_ICON_LIBRARY_COMMIT_ID% successfully.
endlocal
exit /b 0
