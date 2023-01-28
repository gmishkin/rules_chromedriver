# rules_chromedriver
Bazel rules to auto-detect matching ChromeDriver version

## Usage
In your WORKSPACE

```starlark
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "rules_chromedriver",
    remote = "https://github.com/gmishkin/rules_chromedriver.git",
    commit = "2d6209946a9c0efb5592a1423b8f4bc0dc883b11",
)

load("@rules_chromedriver//:chromedriver.bzl", "chromedriver_deps", "chromedriver")

chromedriver_deps()

chromedriver(name = "chromedriver")

load("@chromedriver//:repos.bzl", "chromedriver_builds")

chromedriver_builds()
```

In a BUILD file

```starlark
sh_binary(
    name = "r",
    srcs = ["r.sh"],
    data = ["@chromedriver//:chromedriver"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)
```

Example script

```bash
#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

set -eu

"$(rlocation chromedriver/chromedriver)" --version
```

Sample run

```
geoff@fishbook:~/chr_u$ bazel run :r 2> /dev/null
ChromeDriver 109.0.5414.74 (e7c5703604daa9cc128ccf5a5d3e993513758913-refs/branch-heads/5414@{#1172})
```
