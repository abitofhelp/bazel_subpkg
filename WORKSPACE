## WORKSPACE

workspace(name = "bazel_subpkg")

## VERSIONS
BAZEL_GAZELLE_VERSION = "0.34.0"

GO_VERSION = "1.21.3"

PROTOBUF_VERSION = "24.4"

RULES_GO_VERSION = "0.42.0"

RULES_PROTO_VERSION = "6.0.0"

RUST_VERSIONS = [
    "1.73.0",
    "nightly/2023-11-12",
]

RULES_RUST_VERSION = "0.30.0"

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

## RULES_GO AND GAZELLE ###################################################################################
http_archive(
    name = "io_bazel_rules_go",
    sha256 = "91585017debb61982f7054c9688857a2ad1fd823fc3f9cb05048b0025c47d023",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/{version}/rules_go-v{version}.zip".format(version = RULES_GO_VERSION),
        "https://github.com/bazelbuild/rules_go/releases/download/{version}/rules_go-v{version}.zip".format(version = RULES_GO_VERSION),
    ],
)

http_archive(
    name = "bazel_gazelle",
    sha256 = "b7387f72efb59f876e4daae42f1d3912d0d45563eac7cb23d1de0b094ab588cf",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/{version}/bazel-gazelle-v{version}.tar.gz".format(version = BAZEL_GAZELLE_VERSION),
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/{version}/bazel-gazelle-v{version}.tar.gz".format(version = BAZEL_GAZELLE_VERSION),
    ],
)

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

############################################################
# Define your own dependencies here using go_repository.
# Else, dependencies declared by rules_go/gazelle will be used.
# The first declaration of an external repository "wins".
############################################################

## Load go_repositories here... ########################################################################################
load("//:go_deps.bzl", "go_dependencies")

# gazelle:repository_macro go_deps.bzl%go_dependencies
go_dependencies()
########################################################################################################################

go_rules_dependencies()

go_register_toolchains(version = "{version}".format(version = GO_VERSION))

# If you use WORKSPACE.bazel, use the following line instead of the bare gazelle_dependencies():
# gazelle_dependencies(go_repository_default_config = "@//:WORKSPACE.bazel")
gazelle_dependencies()

########################################################################################################################

## PROTOBUF ############################################################################################################
#http_archive(
#    name = "com_google_protobuf",
#    sha256 = "616bb3536ac1fff3fb1a141450fa28b875e985712170ea7f1bfe5e5fc41e2cd8",
#    strip_prefix = "protobuf-24.4",
#    urls = ["https://github.com/protocolbuffers/protobuf/archive/{version}.tar.gz".format(version = PROTOBUF_VERSION)],
#)
#load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")
#protobuf_deps()
########################################################################################################################

## GO_GOOGLEAPIS #######################################################################################################
#http_archive(
#    name = "go_googleapis",
#    sha256 = "9d1a930e767c93c825398b8f8692eca3fe353b9aaadedfbcf1fca2282c85df88",
#    strip_prefix = "googleapis-64926d52febbf298cb82a8f472ade4a3969ba922",
#    urls = [
#        "https://github.com/googleapis/googleapis/archive/64926d52febbf298cb82a8f472ade4a3969ba922.zip",
#    ],
#)
#
#load("@go_googleapis//:repository_rules.bzl", "switched_rules_by_language")
#
#switched_rules_by_language(
#    name = "com_google_googleapis_imports",
#    go = True,
#)
########################################################################################################################

### RULES_PROTO ########################################################################################################
#http_archive(
#    name = "rules_proto",
#    sha256 = "903af49528dc37ad2adbb744b317da520f133bc1cbbecbdd2a6c546c9ead080b",
#    strip_prefix = "rules_proto-6.0.0-rc0",
#    url = "https://github.com/bazelbuild/rules_proto/releases/download/6.0.0-rc0/rules_proto-{version}-rc0.tar.gz".format(version = RULES_PROTO_VERSION),
#)
#load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")
#rules_proto_dependencies()
#rules_proto_toolchains()
########################################################################################################################

## BUILDTOOLS (Buildifier)##############################################################################################
http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = "ae34c344514e08c23e90da0e2d6cb700fcd28e80c02e23e4d5715dddcb42f7b3",
    strip_prefix = "buildtools-4.2.2",
    urls = [
        "https://github.com/bazelbuild/buildtools/archive/refs/tags/4.2.2.tar.gz",
    ],
)

load("@com_github_bazelbuild_buildtools//buildifier:deps.bzl", "buildifier_dependencies")

buildifier_dependencies()
########################################################################################################################
