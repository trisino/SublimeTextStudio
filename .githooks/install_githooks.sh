#!/usr/bin/env bash


# Whether we are dealing with a git-submodule or not, this get the correct git file path for the
# project root folder if run on it directory, or for the sub-module folder if run on its directory.
gitRootPath="$(git rev-parse --git-dir)"
gitHooksPath="$gitRootPath/hooks"



if [ -d $gitHooksPath ]
then
    printf "Installing the githooks...\n\n"

    # Reliable way for a bash script to get the full path to itself?
    # http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
    pushd `dirname $0` > /dev/null
    SCRIPTPATH=`pwd`
    popd > /dev/null

    # Remove the '/app/blabla/' from the $SCRIPTPATH variable.
    # https://regex101.com/r/rR0oM2/1
    installerDirectoryName=$(echo $SCRIPTPATH | sed -r "s/((.+\/)+)//")

    # Get the submodule (if any) root's directory
    submoduleProjectRoot=$(git rev-parse --show-toplevel)

    # Given:
    # D:/User/Dropbox/Applications/SoftwareVersioning/SublimeText/Data/Packages/.git/modules/amxmodx (gitRootPath)
    # D:/User/Dropbox/Applications/SoftwareVersioning/SublimeText/Data/Packages/amxmodx (submoduleProjectRoot)
    #
    # Returns:
    # ../../../amxmodx
    pathToSubmodule=$(python -c "import os.path; print os.path.relpath('$submoduleProjectRoot', '$gitRootPath')")

    # Get the `AUTO_VERSIONING_ROOT_FOLDER_PATH`, i.e., the folder to the auto-versioning scripts.
    AUTO_VERSIONING_ROOT_FOLDER_PATH="$pathToSubmodule/$installerDirectoryName"

    # Write specify the githooks' root folder
    echo "$AUTO_VERSIONING_ROOT_FOLDER_PATH" > $gitHooksPath/gitHooksRoot.txt

    cp -v post-checkout $gitHooksPath
    cp -v post-commit $gitHooksPath
    cp -v prepare-commit-msg $gitHooksPath

    printf "\nThe githooks are successfully installed!\n"
else
    printf "Error! Could not to install the githooks.\n"
    printf "The folder \`$gitHooksPath\` folder is missing.\n\n"
fi




