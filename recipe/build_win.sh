#!/usr/bin/env bash
set -eux -o pipefail

module="gitlab.com/gitlab-org/cli"

GOPATH="$( pwd )"
export GOPATH
export GOROOT="${BUILD_PREFIX}/go"
export GOOS=windows
export GOARCH=amd64
export CGO_ENABLED=1

export GLAB_VERSION="${PKG_VERSION}"

mkdir -p "${PREFIX}/bin"

pushd "src/${module}"
    make install
    make build
    cp "bin/glab" "${PREFIX}/bin/glab.exe"

    # the --ignores are all stdlib, found for some reason
    go-licenses save ./cmd/glab --save_path "${SRC_DIR}/license-files" \
        --ignore=archive/zip \
        --ignore=bufio \
        --ignore=bytes \
        --ignore=cmp \
        --ignore=compress/flate \
        --ignore=compress/gzip \
        --ignore=container/heap \
        --ignore=container/list \
        --ignore=context \
        --ignore=crypto \
        --ignore=crypto/aes \
        --ignore=crypto/cipher \
        --ignore=crypto/des \
        --ignore=crypto/dsa \
        --ignore=crypto/ecdsa \
        --ignore=crypto/ed25519 \
        --ignore=crypto/elliptic \
        --ignore=crypto/hmac \
        --ignore=crypto/internal/randutil \
        --ignore=crypto/internal/subtle \
        --ignore=crypto/md5 \
        --ignore=crypto/rand \
        --ignore=crypto/rc4 \
        --ignore=crypto/rsa \
        --ignore=crypto/sha1 \
        --ignore=crypto/sha256 \
        --ignore=crypto/sha512 \
        --ignore=crypto/subtle \
        --ignore=crypto/tls \
        --ignore=crypto/x509 \
        --ignore=database/sql/driver \
        --ignore=embed \
        --ignore=encoding \
        --ignore=encoding/base64 \
        --ignore=encoding/binary \
        --ignore=encoding/csv \
        --ignore=encoding/hex \
        --ignore=encoding/json \
        --ignore=encoding/pem \
        --ignore=errors \
        --ignore=flag \
        --ignore=fmt \
        --ignore=github.com/modern-go/reflect2 \
        --ignore=go/ast \
        --ignore=go/build/constraint \
        --ignore=go/doc \
        --ignore=go/internal/typeparams \
        --ignore=go/parser \
        --ignore=go/scanner \
        --ignore=go/token \
        --ignore=hash \
        --ignore=html \
        --ignore=html/template \
        --ignore=image \
        --ignore=image/color \
        --ignore=internal/abi \
        --ignore=internal/asan \
        --ignore=internal/bisect \
        --ignore=internal/bytealg \
        --ignore=internal/byteorder \
        --ignore=internal/chacha8rand \
        --ignore=internal/concurrent \
        --ignore=internal/coverage/rtcov \
        --ignore=internal/cpu \
        --ignore=internal/filepathlite \
        --ignore=internal/fmtsort \
        --ignore=internal/goarch \
        --ignore=internal/godebug \
        --ignore=internal/goexperiment \
        --ignore=internal/goos \
        --ignore=internal/intern \
        --ignore=internal/itoa \
        --ignore=internal/lazyregexp \
        --ignore=internal/msan \
        --ignore=internal/nettrace \
        --ignore=internal/oserror \
        --ignore=internal/poll \
        --ignore=internal/profilerecord \
        --ignore=internal/race \
        --ignore=internal/reflectlite \
        --ignore=internal/runtime/atomic \
        --ignore=internal/runtime/exithook \
        --ignore=internal/safefilepath \
        --ignore=internal/singleflight \
        --ignore=internal/stringslite \
        --ignore=internal/syscall/execenv \
        --ignore=internal/syscall/windows \
        --ignore=internal/syscall/windows/registry \
        --ignore=internal/syscall/windows/sysdll \
        --ignore=internal/sysinfo \
        --ignore=internal/testlog \
        --ignore=internal/unsafeheader \
        --ignore=internal/weak \
        --ignore=io \
        --ignore=io/ioutil \
        --ignore=iter \
        --ignore=log \
        --ignore=maps \
        --ignore=math \
        --ignore=math/big \
        --ignore=math/rand \
        --ignore=mime \
        --ignore=mime/multipart \
        --ignore=net \
        --ignore=net/http \
        --ignore=net/url \
        --ignore=os \
        --ignore=os/exec \
        --ignore=path \
        --ignore=path/filepath \
        --ignore=reflect \
        --ignore=regexp \
        --ignore=runtime \
        --ignore=runtime/debug \
        --ignore=slice \
        --ignore=sort \
        --ignore=strconv \
        --ignore=strings \
        --ignore=sync \
        --ignore=sync/atomic \
        --ignore=syscall \
        --ignore=testing \
        --ignore=text/tabwriter \
        --ignore=text/template \
        --ignore=time \
        --ignore=unicode \
        --ignore=unicode/utf16 \
        --ignore=unicode/utf8 \
        --ignore=unique \
        --ignore=vendor/golang.org/x/crypto/chacha20 \
        --ignore=vendor/golang.org/x/crypto/chacha20poly1305 \
        --ignore=vendor/golang.org/x/crypto/cryptobyte \
        --ignore=vendor/golang.org/x/crypto/cryptobyte/asn1 \
        --ignore=vendor/golang.org/x/crypto/curve25519 \
        --ignore=vendor/golang.org/x/crypto/hkdf \
        --ignore=vendor/golang.org/x/crypto/internal/alias \
        --ignore=vendor/golang.org/x/crypto/internal/poly1305 \
        --ignore=vendor/golang.org/x/crypto/internal/subtle \
        --ignore=vendor/golang.org/x/crypto/sha3 \
        --ignore=vendor/golang.org/x/net/dns/dnsmessage \
        --ignore=vendor/golang.org/x/net/http/httpguts \
        --ignore=vendor/golang.org/x/net/http/httpproxy \
        --ignore=vendor/golang.org/x/net/http2/hpack \
        --ignore=vendor/golang.org/x/net/idna \
        --ignore=vendor/golang.org/x/sys/cpu \
        --ignore=vendor/golang.org/x/text/secure/bidirule \
        --ignore=vendor/golang.org/x/text/transform \
        --ignore=vendor/golang.org/x/text/unicode/bidi \
        --ignore=vendor/golang.org/x/text/unicode/norm \
    && echo OK

popd

mkdir -p "${PREFIX}/share/bash-completion/completions"
"${PREFIX}/bin/${PKG_NAME}" completion -s bash > "${PREFIX}/share/bash-completion/completions/glab"       || echo "ignoring"

mkdir -p "${PREFIX}/share/fish/vendor_completions.d"
"${PREFIX}/bin/${PKG_NAME}" completion -s fish > "${PREFIX}/share/fish/vendor_completions.d/glab.fish"    || echo "ignoring"

mkdir -p "${PREFIX}/share/zsh/site-functions"
"${PREFIX}/bin/${PKG_NAME}" completion -s zsh > "${PREFIX}/share/zsh/site-functions/_glab"                || echo "ignoring"

# try to clean now to fail after packaging
CLEAN_GO_PATH=$( go env GOPATH )
export CLEAN_GO_PATH
find "${CLEAN_GO_PATH}" -type d -exec chmod +w {} \;
rm -rf "${CLEAN_GO_PATH}/go"

ps -aux
