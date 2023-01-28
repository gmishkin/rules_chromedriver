"""
Repository rule to load the matching version of ChromeDriver for the version
of Chrome or Chromium you have installed in your PATH
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def chromedriver_deps():
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "f24ab666394232f834f74d19e2ff142b0af17466ea0c69a3f4c276ee75f6efce",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.0/bazel-skylib-1.4.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.0/bazel-skylib-1.4.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "platforms",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/0.0.6/platforms-0.0.6.tar.gz",
            "https://github.com/bazelbuild/platforms/releases/download/0.0.6/platforms-0.0.6.tar.gz",
        ],
        sha256 = "5308fc1d8865406a49427ba24a9ab53087f17f5266a7aabbfc28823f3916e1ca",
    )

def _impl(rctx):
    rctx.report_progress("Fetching Chrome version")
    chrome_path = rctx.which("chrome")
    if chrome_path == None:
        chrome_path = rctx.which("chromium")

    if chrome_path == None:
        fail("Neither chrome nor chromium were found in your PATH")

    result = rctx.execute([chrome_path, "--version"])
    if result.return_code != 0:
        fail("Chrom{e,ium} version fetching failed", result.stderr)

    output = result.stdout.rstrip()
    words = output.split(" ", 3)
    full_version = words[1]

    version_parts = full_version.split(".", 4)
    important_version_parts = ".".join(version_parts[0:3])

    rctx.report_progress("Fetching latest ChromeDriver version")
    latest_url_query = "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_" + important_version_parts
    rctx.download(url = latest_url_query, output = "chromedriver_version_file.txt")
    chromedriver_version = rctx.read("chromedriver_version_file.txt")

    driver_download_rule_snippets = ["""    http_archive(
        name = "{name}_{platform}",
        urls = ["https://chromedriver.storage.googleapis.com/{version}/chromedriver_{platform}.zip"],
        build_file = "@{name}//:chromedriver.BUILD",
    )
""".format(name = rctx.name, platform = platform, version = chromedriver_version) for platform in ["linux64", "mac64", "mac_arm64"]]

    driver_download_rule_snippets.append("""    http_archive(
        name = "{name}_win32",
        urls = ["https://chromedriver.storage.googleapis.com/{version}/chromedriver_win32.zip"],
        build_file = "@{name}//:chromedriver_win.BUILD",
    )
""".format(name = rctx.name, version = chromedriver_version))

    rctx.file("chromedriver.BUILD", content = """filegroup(
    name = "driver",
    srcs = ["chromedriver"],
    visibility = ["@{name}//:__pkg__"],
)
""".format(name = rctx.name))

    rctx.file("chromedriver_win32.BUILD", content = """filegroup(
    name = "driver",
    srcs = ["chromedriver.exe"],
    visibility = ["@{name}//:__pkg__"],
)
""".format(name = rctx.name))

    repos_header = """load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def chromedriver_builds():
"""

    rctx.file("repos.bzl", content = repos_header + "".join(driver_download_rule_snippets))

    rctx.file("BUILD", rctx.read(rctx.attr._dr_build))

chromedriver = repository_rule(
    implementation = _impl,
    local = False,
    configure = True,
    attrs = {
        "_dr_build": attr.label(default = "//:chromedriver.BUILD"),
    },
    environ = ["PATH"],
)
