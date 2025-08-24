#!/usr/bin/env bash
set -eux -o pipefail

module="gitlab.com/gitlab-org/cli"

GOPATH="$( pwd )"
export GOPATH
export GOROOT="${BUILD_PREFIX}/go"

export GOFLAGS="-buildmode=pie -trimpath -ldflags=-linkmode=external"
export GO_EXTLINK_ENABLED=1
export GO_LFFLAGS=${LDFLAGS}

export CGO_ENABLED=1
export CGO_CFLAGS="${CFLAGS}"
export CGO_CPPFLAGS="${CPPFLAGS}"
export CGO_CXXFLAGS="${CXXFLAGS}"
export CGO_LDFLAGS="${LDFLAGS}"

pushd "src/${module}"
    bash "${RECIPE_DIR}/check-go-version.sh" || exit 2

    go build \
        -ldflags "-X main.version=${PKG_VERSION} -X main.debugMode=false -w -s" \
        -o "${PREFIX}/bin/glab" \
        ./cmd/glab
    go-licenses save ./cmd/glab --save_path "${SRC_DIR}/license-files" \
        --ignore=github.com/golang/freetype/raster \
        --ignore=github.com/golang/freetype/truetype \
        --ignore=golang.org/x/sys/unix \
    && echo OK
popd

if [[ "${build_platform}" == "${target_platform}" ]]; then
    mkdir -p "${PREFIX}/share/bash-completion/completions"
    "${PREFIX}/bin/${PKG_NAME}" completion -s bash > "${PREFIX}/share/bash-completion/completions/${PKG_NAME}"

    mkdir -p "${PREFIX}/share/fish/vendor_completions.d"
    "${PREFIX}/bin/${PKG_NAME}" completion -s fish > "${PREFIX}/share/fish/vendor_completions.d/${PKG_NAME}.fish"

    mkdir -p "${PREFIX}/share/zsh/site-functions"
    "${PREFIX}/bin/${PKG_NAME}" completion -s zsh > "${PREFIX}/share/zsh/site-functions/_${PKG_NAME}"
fi

# Make GOPATH directories writeable so conda-build can clean everything up.
CLEAN_GO_PATH=$( go env GOPATH )
export CLEAN_GO_PATH
find "${CLEAN_GO_PATH}" -type d -exec chmod +w {} \;
