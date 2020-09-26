#!/bin/sh

function showUsage() {
    echo "

    version 1.0.0

    Usage:

        build.sh -target [PLATFORM]
        for instance: 
            build.sh -target ios 

    Input the number to build target for target platform
        [ 'mac', 'win', 'android', 'ios' ]

    // Please Install gomobile first
    // ref: https://godoc.org/golang.org/x/mobile/cmdBuil/gomobile
    "
}

function timestamp() {
    printf "$(date +"%m-%d-%y %H:%M:%S")"
}

function buildForPlatform() {

    platform=$1
    outpufFile=$2

    echo "Building for ${platform}"

    if [ "${platform}" == "win" ]; then
        OUTPUT_LIBRARY_FOLDER="out/desktop/${platform}/anv"
        OUTPUT_LIBRARY="${OUTPUT_LIBRARY_FOLDER}/${outpufFile}"
        cmdBuild="time go build -o ${OUTPUT_LIBRARY}"
    elif [ "${platform}" == "mac" ]; then
        OUTPUT_LIBRARY_FOLDER="out/desktop/${platform}/anv"
        OUTPUT_LIBRARY="${OUTPUT_LIBRARY_FOLDER}/${outpufFile}"
        cmdBuild="time go build -o ${OUTPUT_LIBRARY}"
    else
        OUTPUT_LIBRARY_FOLDER="out/${platform}/anv"
        OUTPUT_LIBRARY="${OUTPUT_LIBRARY_FOLDER}/${outpufFile}"
        cmdBuild="time gomobile bind -target=${platform} -v -o ${OUTPUT_LIBRARY}"
    fi

    echo "> Clean output folder ... ${OUTPUT_LIBRARY_FOLDER}"
    rm -rf ${OUTPUT_LIBRARY_FOLDER}

    if [ ! -d "${OUTPUT_LIBRARY_FOLDER}" ]; then
        mkdir -p ${OUTPUT_LIBRARY_FOLDER}
    fi

    OUTPUT_ZIP_FILE="${OUTPUT_LIBRARY_FOLDER}/${platform}_anv.zip"

    echo "$(timestamp) RUN COMMAND --> ${cmdBuild}"
    $(${cmdBuild})
    OUTPUT_ZIP_FILE="${OUTPUT_LIBRARY_FOLDER}/${platform}_anv.zip"

    echo "> check out ... ${OUTPUT_LIBRARY}"
    if [ -f "${OUTPUT_LIBRARY}" ]; then
        zip -r ${OUTPUT_ZIP_FILE} ${OUTPUT_LIBRARY_FOLDER}/*
        echo "\n  ^_^b Successfully built!!\n"
    else
        if [ -d "${OUTPUT_LIBRARY}" ]; then
            zip -r ${OUTPUT_ZIP_FILE} ${OUTPUT_LIBRARY_FOLDER}/*
            echo "\n  ^_^b Successfully built!!\n"
        else
            echo "\n  T_T! Build failed!!\n"
        fi
    fi
}

function buildTarget() {

    platform=$1
    echo "> Try to build ${platform}"

    case ${platform} in
    "ios")
        buildForPlatform "ios" "Libs.framework"
        ;;
    "android")
        buildForPlatform "android" "Libs.aar"
        ;;
    "win")
        echo "Building for Windows"
        ;;
    "mac")
        echo "Building for macOS"
        buildForPlatform "mac" "desktop_libs"
        ;;
    *)
        echo "NG> Unknown target ${platform}"
        ;;
    esac
}

if [ $# -eq 0 ]; then
    showUsage
    read -p "> build? " userInput
    buildTarget "${userInput}"
elif [ $# -eq 2 ]; then
    if [ "$1" == "-target" ]; then
        buildTarget $2
    fi
else
    showUsage
fi
