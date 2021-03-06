#!/usr/bin/env bash

# [2021-05-27] Linux success.
# [2021-05-27] macOS hitting this install error:
#
# make[1]: Entering directory '[...]/svn/r/r-devel/build/doc/manual'
# creating RESOURCES
# creating FAQ
# creating doc/html/resources.html
# make[1]: Leaving directory '[...]/svn/r/r-devel/build/doc/manual'
# ERROR: not an svn checkout
# make: *** [Makefile:107: svnonly] Error 1
#
# Potentially related:
# - https://stat.ethz.ch/pipermail/r-devel/2016-May/072781.html
# - http://singmann.org/installing-r-devel-on-linux/#comment-161
#
# Maybe it's the 'rsync-recommended' step not working on macOS?

koopa::install_r_devel() { # {{{1
    koopa::install_app \
        --name-fancy='R-devel' \
        --name='r-devel' \
        "$@"
}

koopa:::install_r_devel() { # {{{1
    # """
    # Install R-devel.
    # @note Updated 2021-05-27.
    # """
    local brew_opt brew_prefix conf_args jobs make name prefix repo_url
    local revision rtop svn
    prefix="${INSTALL_PREFIX:?}"
    revision="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    svn="$(koopa::locate_svn)"
    # Keep this configuration in sync with 'koopa:::install_r'.
    conf_args=(
        "--prefix=${prefix}"
        '--enable-R-shlib'
        '--enable-memory-profiling'
        '--with-x=no'
    )
    if koopa::is_linux
    then
        conf_args+=(
            '--disable-nls'
            '--enable-R-profiling'
            '--with-blas'
            '--with-cairo'
            '--with-jpeglib'
            '--with-lapack'
            '--with-readline'
            '--with-recommended-packages'
            '--with-tcltk'
        )
        # Need to modify BLAS configuration handling specificallly on Debian.
        if ! koopa::is_debian_like
        then
            conf_args+=('--enable-BLAS-shlib')
        fi
    elif koopa::is_macos
    then
        # fxcoudert's gfortran works more reliably than using Homebrew gcc
        # See also:
        # - https://mac.r-project.org
        # - https://github.com/fxcoudert/gfortran-for-macOS/releases
        # - https://developer.r-project.org/Blog/public/2020/11/02/
        #     will-r-work-on-apple-silicon/index.html
        # - https://bugs.r-project.org/bugzilla/show_bug.cgi?id=18024
        brew_prefix="$(koopa::homebrew_prefix)"
        brew_opt="${brew_prefix}/opt"
        koopa::activate_homebrew_opt_prefix \
            'gettext' \
            'jpeg' \
            'libpng' \
            'openblas' \
            'pcre2' \
            'pkg-config' \
            'readline' \
            'tcl-tk' \
            'texinfo' \
            'xz'
        koopa::activate_prefix '/usr/local/gfortran'
        koopa::add_to_path_start '/Library/TeX/texbin'
        conf_args+=(
            "--with-blas=-L${brew_opt}/openblas/lib -lopenblas"
            "--with-tcl-config=${brew_opt}/tcl-tk/lib/tclConfig.sh"
            "--with-tk-config=${brew_opt}/tcl-tk/lib/tkConfig.sh"
            '--without-aqua'
        )
        export CFLAGS='-Wno-error=implicit-function-declaration'
    fi
    name='r-devel'
    # Set the R source code repo URL.
    repo_url='https://svn.r-project.org/R'
    # Set the desired top-level directory structure.
    rtop="${PWD}/svn/r"
    # Create necessary build directories.
    koopa::mkdir "${rtop}/${name}/build"
    # Check out the latest revision of R-devel.
    koopa::cd "$rtop"
    "$svn" checkout \
        --revision="$revision" \
        "${repo_url}/trunk" \
        "${name}/source"
    # > koopa::cd "${rtop}/${name}/source"
    # Draft version information is located in 'VERSION' file.
    # How to ensure that repo is up-to-date.
    # > "$svn" update
    # Here's how to switch to a different revision inside the source trunk.
    # Somewhere between 80100 and 80200 the version was changed.
    # > "$svn" checkout \
    # >     --revision='80190' \
    # >     "${repo_url}/trunk" \
    # >     .
    # Get the sources of the recommended packages.
    koopa::cd "${rtop}/${name}/source/tools"
    ./rsync-recommended
    # Ready to build from source.
    koopa::cd "${rtop}/${name}/build"
    koopa::activate_openjdk
    unset -v R_HOME
    export TZ='America/New_York'
    # We build in the separate directory created above,
    # in order not to pollute the source code.
    ../source/configure "${conf_args[@]}"
    "$make" --jobs="$jobs"
    # > "$make" check
    "$make" pdf
    "$make" info
    "$make" install
    r="${prefix}/bin/R"
    koopa::assert_is_file "$r"
    koopa::configure_r "$r"
    return 0
}

koopa::uninstall_r_devel() { # {{{1
    koopa::uninstall_app \
        --name-fancy='R-devel' \
        --name='r-devel' \
        "$@"
}
