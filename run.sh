#!/bin/bash -eu

cd "$(dirname "${BASH_SOURCE[0]}")"
python3 generate_kzip.py
KZIP="$(realpath out/example.kzip)"
# KZIP=/tmp/kzips/chromium.kzip

cd /google/src/cloud/msta/kythe/google3
SYSROOT="/google/src/cloud/msta/kythe/google3/third_party/rust_toolchain/library"
blaze run //devtools/grok/kythe/rust/indexer:kzip_indexer -c opt -- --logtostderr -- --sysroot-src=$SYSROOT --abbreviate-vnames "${KZIP}"