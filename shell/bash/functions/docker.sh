#!/usr/bin/env bash

_koopa_docker_build() { # {{{1
    # """
    # Build and push a docker image.
    # Updated 2020-06-02.
    #
    # Use '--no-cache' flag to disable build cache.
    #
    # Examples:
    # docker-build-image bioconductor release
    # docker-build fedora
    #
    # See also:
    # - docker build --help
    # - https://docs.docker.com/engine/reference/builder/#arg
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed docker
    local delete docker_dir image image_ids pos push server source_image \
        symlink_tag symlink_tagged_image symlink_tagged_image_today tag \
        tagged_image tagged_image_today today
    docker_dir="$(_koopa_docker_prefix)"
    _koopa_assert_is_dir "$docker_dir"
    delete=0
    push=1
    server="docker.io"
    tag="latest"
    pos=()
    while (("$#"))
    do
        case "$1" in
            --delete)
                delete=1
                shift 1
                ;;
            --no-delete)
                delete=0
                shift 1
                ;;
            --no-push)
                push=0
                shift 1
                ;;
            --push)
                push=1
                shift 1
                ;;
            --server=*)
                server="${1#*=}"
                shift 1
                ;;
            --server)
                server="$2"
                shift 2
                ;;
            --tag=*)
                tag="${1#*=}"
                shift 1
                ;;
            --tag)
                tag="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    # e.g. acidgenomics/debian
    image="${1:?}"
    # Assume acidgenomics recipe by default.
    if ! _koopa_str_match "$image" "/"
    then
        image="acidgenomics/${image}"
    fi
    # Handle tag support, if necessary.
    if _koopa_str_match "$image" ":"
    then
        tag="$(_koopa_print "$image" | cut -d ':' -f 2)"
        image="$(_koopa_print "$image" | cut -d ':' -f 1)"
    fi
    source_image="${docker_dir}/${image}/${tag}"
    _koopa_assert_is_dir "$source_image"
    today="$(date "+%Y%m%d")"
    if [[ -L "$source_image" ]]
    then
        symlink_tag="$(basename "$source_image")"
        symlink_tagged_image="${image}:${symlink_tag}"
        symlink_tagged_image_today="${symlink_tagged_image}-${today}"
        # Now resolve the symlink to real path.
        source_image="$(_koopa_realpath "$source_image")"
        tag="$(basename "$source_image")"
    fi
    # e.g. acidgenomics/debian:latest
    tagged_image="${image}:${tag}"
    # e.g. acidgenomics/debian:latest-20200101
    tagged_image_today="${tagged_image}-${today}"
    _koopa_h1 "Building '${tagged_image}' Docker image."
    docker login "$server"
    # Force remove any existing local tagged images.
    if [[ "$delete" -eq 1 ]]
    then
        readarray -t image_ids <<< "$( \
            docker image ls \
                --filter reference="$tagged_image" \
                --quiet \
        )"
        if _koopa_is_array_non_empty "${image_ids[@]}"
        then
            docker image rm --force "${image_ids[@]}"
        fi
    fi
    # Build a local copy of the image.
    docker build \
        --build-arg "GITHUB_PAT=${DOCKER_GITHUB_PAT:?}" \
        --no-cache \
        --tag="$tagged_image_today" \
        "$source_image"
    docker tag "$tagged_image_today" "$tagged_image"
    if [[ -n "${symlink_tag:-}" ]]
    then
        docker tag "$tagged_image_today" "$symlink_tagged_image_today"
        docker tag "$symlink_tagged_image_today" "$symlink_tagged_image"
    fi
    if [[ "$push" -eq 1 ]]
    then
        docker push "${server}/${tagged_image_today}"
        docker push "${server}/${tagged_image}"
        if [[ -n "${symlink_tag:-}" ]]
        then
            docker push "${server}/${symlink_tagged_image_today}"
            docker push "${server}/${symlink_tagged_image}"
        fi
    fi
    docker image ls --filter reference="$tagged_image"
    _koopa_success "Build of '${tagged_image}' was successful."
    return 0
}

_koopa_docker_build_all_batch_images() { # {{{1
    # """
    # Build all AWS Batch Docker images.
    # @note Updated 2020-07-01.
    # """
    _koopa_assert_is_installed docker-build-all-images
    local batch_dirs flags force images prefix
    force=0
    while (("$#"))
    do
        case "$1" in
            --force)
                force=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    flags=()
    if [[ "$force" -eq 1 ]]
    then
        flags+=("--force")
    fi
    prefix="$(_koopa_docker_prefix)"
    batch_dirs="$( \
        find "${prefix}/acidgenomics" \
            -name "aws-batch*" \
            -type d \
        | sort \
    )"
    batch_dirs="$(_koopa_sub "${prefix}/" "" "$batch_dirs")"
    readarray -t images <<< "$(_koopa_print "$batch_dirs")"
    docker-build-all-images "${flags[@]}" "${images[@]}"
    return 0
}

_koopa_docker_build_all_images() { # {{{1
    # """
    # Build all Docker images.
    # @note Updated 2020-07-01.
    # """
    _koopa_assert_is_installed docker docker-build-all-tags
    local batch_arr batch_dirs extra force image images json nextflow_arr \
        nextflow_dirs prefix prune pos timestamp today utc_timestamp
    extra=0
    force=0
    prune=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --extra)
                extra=1
                shift 1
                ;;
            --force)
                force=1
                shift 1
                ;;
            --prune)
                prune=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    # Define images array.
    # If empty, define default images.
    if [[ "$#" -eq 0 ]]
    then
        prefix="$(_koopa_docker_prefix)"
        images=()
        # Recommended Linux images.
        images+=(
            acidgenomics/debian
            acidgenomics/ubuntu
            acidgenomics/fedora
            acidgenomics/centos
        )
        # Extra Linux images.
        images+=(
            acidgenomics/alpine
            acidgenomics/amzn
            acidgenomics/arch
            acidgenomics/opensuse
        )
        # Minimal bioinformatics images.
        images+=(
            acidgenomics/miniconda3
            acidgenomics/biocontainers
        )
        # R images.
        images+=(
            acidgenomics/bioconductor
            acidgenomics/r-basejump
            acidgenomics/r-bcbiornaseq
            acidgenomics/r-bcbiosinglecell
            acidgenomics/r-rnaseq
            acidgenomics/r-singlecell
        )
        # Nextflow images.
        nextflow_dirs="$( \
            find "$prefix" \
                -name "nextflow-*" \
                -type d \
                | sort \
        )"
        nextflow_dirs="$(_koopa_sub "${prefix}/" "" "$nextflow_dirs")"
        readarray -t nextflow_arr <<< "$(_koopa_print "$nextflow_dirs")"
        images=("${images[@]}" "${nextflow_arr[@]}")
        # AWS batch images.
        # Ensure we build these after the other images.
        batch_dirs="$( \
            find "$prefix" \
                -name "aws-batch*" \
                -type d \
                | sort \
        )"
        batch_dirs="$(_koopa_sub "${prefix}/" "" "$batch_dirs")"
        readarray -t batch_arr <<< "$(_koopa_print "$batch_dirs")"
        images=("${images[@]}" "${batch_arr[@]}")
        # Large bioinformatics images.
        # These don't need to be updated frequently and can be built manually.
        if [[ "$extra" -eq 1 ]]
        then
            images+=(
                acidgenomics/bcbio
                acidgenomics/rnaeditingindexer
                acidgenomics/maestro
            )
    fi
    else
        images=("$@")
    fi
    _koopa_h1 "Building ${#images[@]} Docker images."
    docker login
    for image in "${images[@]}"
    do
        if [[ "$prune" -eq 1 ]]
        then
            docker system prune --all --force
        fi
        # Skip image if pushed already today.
        if [[ "$force" -ne 1 ]]
        then
            docker pull "$image"
            json="$( \
                docker inspect \
                --format='{{json .Created}}' \
                "$image" \
            )"
            # Note that we need to convert UTC to local time.
            utc_timestamp="$( \
                _koopa_print "$json" \
                    | grep -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}' \
                    | sed 's/T/ /' \
                    | sed 's/$/ UTC/'
            )"
            timestamp="$(date -d "$utc_timestamp" '+%Y-%m-%d')"
            today=$(date '+%Y-%m-%d')
            if [[ "$timestamp" == "$today" ]]
            then
                _koopa_note "'${image}' image already pushed today."
                continue
            fi
        fi
        # Build outdated images automatically.
        docker-build-all-tags "$image"
    done
    docker system prune --all --force
    _koopa_success "All Docker images built successfully."
    return 0
}

_koopa_docker_prune() { # {{{1
    # """
    # Docker prune.
    # @note Updated 2020-07-01.
    # """
    [[ "$#" -eq 0 ]] || return 1
    _koopa_is_installed docker
    docker system prune --all --force
    return 0
}

_koopa_docker_push() { # {{{1
    # """
    # Push a local Docker build.
    # Updated 2020-02-18.
    #
    # Useful if GPG agent causes push failure.
    #
    # @seealso
    # - https://docs.docker.com/config/formatting/
    #
    # @examples
    # docker-push acidgenomics/debian:latest
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed docker
    local image images json pattern server
    server="docker.io"
    for pattern in "$@"
    do
        _koopa_h1 "Pushing images matching '${pattern}' to ${server}."
        _koopa_assert_is_matching_regex "$pattern" '^.+/.+$'
        json="$(docker inspect --format="{{json .RepoTags}}" "$pattern")"
        # Convert JSON to lines.
        # shellcheck disable=SC2001
        readarray -t images <<< "$( \
            _koopa_print "$json" \
                | tr ',' '\n' \
                | sed 's/^\[//' \
                | sed 's/\]$//' \
                | sed 's/^\"//g' \
                | sed 's/\"$//g' \
                | sort \
        )"
        if ! _koopa_is_array_non_empty "${images[@]}"
        then
            docker image ls
            _koopa_stop "'${image}' failed to match any images."
        fi
        for image in "${images[@]}"
        do
            _koopa_h2 "Pushing '${image}'."
            docker push "${server}/${image}"
        done
    done
    return 0
}

_koopa_docker_remove() { # {{{1
    # """
    # Remove docker images by pattern.
    # Updated 2020-07-01.
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed docker
    local pattern
    for pattern in "$@"
    do
        docker images \
            | grep "$pattern" \
            | awk '{print $1 ":" $2}' \
            | xargs docker rmi
    done
    return 0
}

_koopa_docker_run() { # {{{1
    # """
    # Run Docker image.
    # @note Updated 2020-07-01.
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed docker
    local bash flags image pos workdir
    bash=0
    workdir="/mnt/work"
    pos=()
    while (("$#"))
    do
        case "$1" in
            --bash)
                bash=1
                shift 1
                ;;
            --workdir=*)
                workdir="${1#*=}"
                shift 1
                ;;
            --workdir)
                workdir="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    image="$1"
    workdir="$(_koopa_strip_trailing_slash "$workdir")"
    docker pull "$image"
    flags=(
        "--interactive"
        "--tty"
        "--volume=${PWD}:${workdir}"
        "--workdir=${workdir}"
        "$image"
    )
    if [[ "$bash" -eq 1 ]]
    then
        flags+=("bash" "-il")
    fi
    docker run "${flags[@]}"
    return 0
}

_koopa_docker_run_wine() { # {{{1
    # """
    # Run Wine Docker image.
    # @note Updated 2020-07-01.
    #
    # Allow access from localhost.
    # > xhost + "$HOSTNAME"
    # """
    _koopa_assert_is_installed docker xhost
    local image workdir
    image="acidgenomics/wine"
    workdir="/mnt/work"
    xhost + 127.0.0.1
    docker run \
        --privileged \
        -e DISPLAY=host.docker.internal:0 \
        --interactive \
        --tty \
        --volume="${PWD}:${workdir}" \
        --workdir="${workdir}" \
        "$image" \
        "$@"
    return 0
}

_koopa_docker_tag() { # {{{1
    # """
    # Add Docker tag.
    # Updated 2020-02-18.
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed docker
    local dest_tag image server source_tag
    image="${1:?}"
    source_tag="${2:?}"
    dest_tag="${3:-latest}"
    server="docker.io"
    # Assume acidgenomics recipe by default.
    if ! _koopa_str_match "$image" "/"
    then
        image="acidgenomics/${image}"
    fi
    if [[ "$source_tag" == "$dest_tag" ]]
    then
        _koopa_print "Source tag identical to destination ('${source_tag}')."
        return 0
    fi
    _koopa_h1 "Tagging '${image}' image tag '${source_tag}' as '${dest_tag}'."
    docker login "$server"
    docker pull "${server}/${image}:${source_tag}"
    docker tag "${image}:${source_tag}" "${image}:${dest_tag}"
    docker push "${server}/${image}:${dest_tag}"
    return 0
}
