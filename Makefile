# Makefile

PROJECT_NAME=falcon
MODULE_NAME=github.com/ingios/$(PROJECT_NAME)
PROJECT_DIR=$(GOPATH)/src/$(MODULE_NAME)

BZLPKG=bazel
BAZEL_BUILD_OPTS:=--verbose_failures --sandbox_debug
GOCMD=$(BZLPKG) run @io_bazel_rules_go//go
SERVICE_DIR=$(PROJECT_DIR)/service
PKG_DIR=$(PROJECT_DIR)/pkg

BLOB_DIR=$(SERVICE_DIR)/blob
BLOB_WORKSPACE=//service/blob/server
BLOB_TARGET=$(BLOB_WORKSPACE):blob_server

CSCLIBRARY_DIR=$(PKG_DIR)/csclibrary
CSCLIBRARY_WORKSPACE=//pkg/csclibrary
CSCLIBRARY_LIB_TARGET=$(CSCLIBRARY_WORKSPACE):csclibrary_lib

GOLIBRARY_DIR=$(PKG_DIR)/golibrary
GOLIBRARY_WORKSPACE=//pkg/golibrary
GOLIBRARY_LIB_TARGET=$(GOLIBRARY_WORKSPACE):golibrary_lib

build_all: build_golibrary build_csclibrary build_blob
	#$(BZLPKG) build $(BAZEL_BUILD_OPTS) //...

build_csclibrary:
	$(BZLPKG) build $(BAZEL_BUILD_OPTS) $(CSCLIBRARY_LIB_TARGET)

build_golibrary:
	$(BZLPKG) build $(BAZEL_BUILD_OPTS) $(GOLIBRARY_LIB_TARGET)

build_blob:
	$(BZLPKG) build $(BAZEL_BUILD_OPTS) $(BLOB_TARGET)

clean:
	$(BZLPKG) clean --expunge --async

expand_golang_build:
	$(BZLPKG) query $(GOLIBRARY_LIB_TARGET) --output=build

gazelle_generate_repos:
#	 This will generate new BUILD.bazel files for your project. You can run the same command in the future to update existing BUILD.bazel files to include new source files or options.
	$(BZLPKG) run $(BAZEL_BUILD_OPTS) //:gazelle

gazelle_update_repos:
	# Import repositories from go.mod and update Bazel's macro and rules.
#	pushd $(BLOB_DIR) && \
#	$(BZLPKG) run $(BAZEL_BUILD_OPTS) //:gazelle -- update-repos -from_file="service/blob/go.mod" -to_macro="go_deps.bzl%go_dependencies" -prune && \
#	popd;
#
#	pushd $(PKG_DIR) && \
#	$(BZLPKG) run $(BAZEL_BUILD_OPTS) //:gazelle -- update-repos -from_file="pkg/csclibrary/go.mod" -to_macro="go_deps.bzl%go_dependencies" -prune && \
#	popd;

	pushd $(PKG_DIR) && \
	$(BZLPKG) run $(BAZEL_BUILD_OPTS) //:gazelle -- update-repos -from_file="pkg/golibrary/go.mod" -to_macro="go_deps.bzl%go_dependencies" -prune && \
	popd;

#go_build_all:
#	## N.B. Each go.mod file defines a workspace in which the go build, go test, go list, and go get commands are available.  These commands apply to packages only within that workspace.
#	## This is why you cannot use go build ./... with a multimodule workspace.
#	# Assumes GO111MODULE=on
#	pushd $(PKG_DIR) && \
#	$(GOCMD) -- build ./... && \
#	popd;

go_mod_download:
	## N.B. Each go.mod file defines a workspace in which the go build, go test, go list, and go get commands are available.  These commands apply to packages only within that workspace.
	# Assumes GO111MODULE=on
	pushd $(BLOB_DIR) && \
	$(GOCMD) -- mod download && \
	popd;

	pushd $(CSCLIBRARY_DIR) && \
	$(GOCMD) -- mod download && \
	popd;

	pushd $(GOLIBRARY_DIR) && \
	$(GOCMD) -- mod download && \
	popd;

go_mod_tidy:
	## N.B. Each go.mod file defines a workspace in which the go build, go test, go list, and go get commands are available.  These commands apply to packages only within that workspace.
	# Assumes GO111MODULE=on
	pushd $(BLOB_DIR) && \
	$(GOCMD) -- mod tidy && \
	popd;

	pushd $(CSCLIBRARY_DIR) && \
	$(GOCMD) -- mod tidy && \
	popd;

	pushd $(GOLIBRARY_DIR) && \
	$(GOCMD) -- mod tidy && \
	popd;

go_mod_vendor:
	rm -rf vendor
	## N.B. Each go.mod file defines a workspace in which the go build, go test, go list, and go get commands are available.  These commands apply to packages only within that workspace.
	# Assumes GO111MODULE=on
	pushd $(BLOB_DIR) && \
	$(GOCMD) -- mod vendor -v && \
	popd;

	pushd $(CSCLIBRARY_DIR) && \
	$(GOCMD) -- mod vendor -v && \
	popd;

	pushd $(GOLIBRARY_DIR) && \
	$(GOCMD) -- mod vendor -v && \
	popd;

go_mod_verify:
	## Verify that the go.sum file matches what was downloaded to prevent someone “git push — force” over a tag being used.
    ## N.B. Each go.mod file defines a workspace in which the go build, go test, go list, and go get commands are available.  These commands apply to packages only within that workspace.
	# Assumes GO111MODULE=on
	pushd $(BLOB_DIR) && \
	$(GOCMD) -- mod verify && \
	popd;

	pushd $(CSCLIBRARY_DIR) && \
	$(GOCMD) -- mod verify && \
	popd;

	pushd $(GOLIBRARY_DIR) && \
	$(GOCMD) -- mod verify && \
	popd;

go_targets:
	$(BZLPKG) query "@io_bazel_rules_go//go:*"

go_unit_test:
	# Assumes GO111MODULE=on
	pushd "$(BLOB_DIR)/server" && \
	$(GOCMD) -- test && \
	popd;

	pushd $(CSCLIBRARY_DIR) && \
	$(GOCMD) -- test && \
	popd;

	pushd $(GOLIBRARY_DIR) && \
	$(GOCMD) -- test && \
	popd;

list_targets:
	$(BZLPKG) query //...

set_golang_version:
	sed -E -i '.org' 's/go 1.21.3/go 1.21.4/g' "$(PROJECT_DIR)/go.work" && rm "$(PROJECT_DIR)/go.work.org" && \
	sed -E -i '.org' 's/go 1.21.3/go 1.21.4/g' "$(BLOB_DIR)/go.mod" && rm "$(BLOB_DIR)/go.mod.org" && \
	sed -E -i '.org' 's/go 1.21.3/go 1.21.4/g' "$(CSCLIBRARY_DIR)/go.mod" && rm "$(CSCLIBRARY_DIR)/go.mod.org" && \
	sed -E -i '.org' 's/go 1.21.3/go 1.21.4/g' "$(GOLIBRARY_DIR)/go.mod" && rm "$(GOLIBRARY_DIR)/go.mod.org" && \
	sed -E -i '.org' 's/GO_VERSION = "1.21.3"/GO_VERSION = "1.21.4"/g' "$(PROJECT_DIR)/WORKSPACE" && rm "$(PROJECT_DIR)/WORKSPACE.org" ;

## The generate_repos at the end of the command string is not an error.
## Verify the BUILD.bazel files that have been changed.  It is possible that duplicate targets were created.
sync_from_gomod: go_mod_download go_mod_tidy go_mod_vendor go_mod_verify gazelle_update_repos gazelle_generate_repos

blob_integration_test:
	$(BZLPKG) test --test_output=all --test_verbose_timeout_warnings "$(BLOB_WORKSPACE):blob_server_test"

csclibrary_unit_test:
	$(BZLPKG) test --test_output=all --test_verbose_timeout_warnings "$(CSCLIBRARY_WORKSPACE):csclibrary_test"

golibrary_unit_test:
	$(BZLPKG) test --test_output=all --test_verbose_timeout_warnings "$(GOLIBRARY_WORKSPACE):golibrary_test"

unit_tests: blob_integration_test csclibrary_unit_test golibrary_unit_test

#tidy:
#	@rm -rf vendor
#	go mod tidy
#	go mod vendor -v
#
#zap:
#	@rm go.sum
#	@rm -rf vendor
#	go clean -modcache -cache
#	go mod download
#	go mod tidy
#	go mod vendor -v