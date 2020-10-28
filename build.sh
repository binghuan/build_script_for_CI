#!/bin/sh

function showUsage() {
    echo "

    version 1.0.0

    Usage:

        build.sh -target [PLATFORM]
        for instance: 
            build.sh -target ios 

    Input the name to build target for specific platform
        [ 'mac', 'win', 'android', 'ios' ]

    // Please Install gomobile first
    // ref: https://godoc.org/golang.org/x/mobile/cmdBuil/gomobile
    "
}

function timestamp() {
    printf "$(date +"%m-%d-%y %H:%M:%S")"
}

function clearOutput() {
    outputLibFolder=$1

    echo "> Clean output folder ... ${outputLibFolder}"
    rm -rf ${outputLibFolder}

    if [ ! -d "${outputLibFolder}" ]; then
        mkdir -p ${outputLibFolder}
    fi

    echo "> Clean output folder ... done!"
}

function buildForPlatform() {

    platform=$1
    outpufFile=$2

    echo "Building for ${platform}"

    if [ "${platform}" == "win" ]; then
        OUTPUT_LIBRARY_FOLDER="out/desktop/${platform}/anv"
        clearOutput ${OUTPUT_LIBRARY_FOLDER}
        OUTPUT_LIBRARY="${OUTPUT_LIBRARY_FOLDER}/${outpufFile}.exe"
        time CGO_ENABLED=1 GOOS=windows GOARCH=amd64 CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ go build -o ${OUTPUT_LIBRARY} ./desktop/main.go
    elif [ "${platform}" == "mac" ]; then
        OUTPUT_LIBRARY_FOLDER="out/desktop/${platform}/anv"
        clearOutput ${OUTPUT_LIBRARY_FOLDER}
        mkdir -p ${OUTPUT_LIBRARY_FOLDER}
        OUTPUT_LIBRARY="${OUTPUT_LIBRARY_FOLDER}/${outpufFile}"
        mkdir -p ${OUTPUT_LIBRARY_FOLDER}
        echo "output file to ${OUTPUT_LIBRARY}"
        time CGO_ENABLED=1 GOOS=darwin GOARCH=amd64 go build -o ${OUTPUT_LIBRARY} ./desktop/main.go
    else
        OUTPUT_LIBRARY_FOLDER="out/${platform}/anv"
        clearOutput ${OUTPUT_LIBRARY_FOLDER}
        OUTPUT_LIBRARY="${OUTPUT_LIBRARY_FOLDER}/${outpufFile}"
        time gomobile bind -target=${platform} -v -o ${OUTPUT_LIBRARY}
    fi

    OUTPUT_ZIP_FILE="${OUTPUT_LIBRARY_FOLDER}/${platform}_anv.zip"

    echo "> check out ... ${OUTPUT_LIBRARY}"
    if [ -f "${OUTPUT_LIBRARY}" ]; then
        if [ "${platform}" == "mac" ]; then
            chmod a+x "${OUTPUT_LIBRARY}"
        fi
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
        buildForPlatform "win" "desktop_libs"
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
