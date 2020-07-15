#!/bin/bash
list="longhorn-images.txt"
images="longhorn-images.tar.gz"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -r|--registry)
        reg="$2"
        shift # past argument
        shift # past value
        ;;
        -l|--image-list)
        list="$2"
        shift # past argument
        shift # past value
        ;;
        -i|--images)
        images="$2"
        shift # past argument
        shift # past value
        ;;
        -h|--help)
        help="true"
        shift
        ;;
    esac
done

usage () {
    echo "USAGE: $0 [--image-list longhorn-images.txt] [--images longhorn-images.tar.gz] --registry my.registry.com:5000"
    echo "  [-l|--images-list path] text file with list of images. 1 per line."
    echo "  [-l|--images path] tar.gz generated by docker save."
    echo "  [-r|--registry registry:port] target private registry:port. By default, registry is Docker Hub"
    echo "  [-h|--help] Usage message"
}

if [[ $help ]]; then
    usage
    exit 0
fi

if [[ -n $reg ]]; then
    reg+="/"
fi

set -e -x

docker load --input ${images}

for i in $(cat ${list}); do
    case $i in
    */*/*)
        docker tag ${i} ${reg}longhornio/${i#*/*/}
        docker push ${reg}longhornio/${i#*/*/}
        ;;
    */*)
        docker tag ${i} ${reg}longhornio/${i#*/}
        docker push ${reg}longhornio/${i#*/}
        ;;
    *)
        docker tag ${i} ${reg}longhornio/${i}
        docker push ${reg}longhornio/${i}
        ;;
    esac
done
