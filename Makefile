# Makefile

PROJECT_NAME=bazel_subpkg
MODULE_NAME=github.com/abitofhelp/$(PROJECT_NAME)
PROJECT_DIR=$(GOPATH)/src/$(MODULE_NAME)

BZLPKG=bazel
BAZEL_BUILD_OPTS:=--verbose_failures --sandbox_debug
GOCMD=$(BZLPKG) run @io_bazel_rules_go//go
PKG_DIR=$(PROJECT_DIR)/pkg

ABC_LIB_DIR=$(PKG_DIR)/abc
ABC_LIB_WORKSPACE=//pkg/abc
ABC_LIB_TARGET=//pkg/abc:abc

CMD_DIR=$(PROJECT_DIR)/cmd
CMD_WORKSPACE=//cmd
CMD_TARGET=//cmd:cmd

build_abc_lib:
	$(BZLPKG) build $(BAZEL_BUILD_OPTS) $(ABC_LIB_TARGET)

build_cmd:
	$(BZLPKG) build $(BAZEL_BUILD_OPTS) $(CMD_TARGET)

clean:
	$(BZLPKG) clean --expunge --async

expand_golang_build:
	$(BZLPKG) query $(ABC_LIB_TARGET) --output=build

gazelle_generate_build_bazel:
#	 This will generate new BUILD.bazel files for your project. You can run the same command in the future to update existing BUILD.bazel files to include new source files or options.
	$(BZLPKG) run $(BAZEL_BUILD_OPTS) //:gazelle

gazelle_update_deps:
	# Import repositories from go.mod and update Bazel's macro and rules.
	pushd $(PROJECT_DIR) && \
	$(BZLPKG) run $(BAZEL_BUILD_OPTS) //:gazelle -- update-repos -from_file="pkg/abc/go.mod" -to_macro="go_deps.bzl%go_dependencies" -prune && \
	popd;

	pushd $(PROJECT_DIR) && \
	$(BZLPKG) run $(BAZEL_BUILD_OPTS) //:gazelle -- update-repos -from_file="cmd/go.mod" -to_macro="go_deps.bzl%go_dependencies" -prune && \
	popd;

go_mod_download:
	pushd $(ABC_LIB_DIR) && \
	$(GOCMD) -- mod download && \
	popd;

	pushd $(CMD_DIR) && \
	$(GOCMD) -- mod download && \
	popd;

go_mod_tidy:
	pushd $(ABC_LIB_DIR) && \
	$(GOCMD) -- mod tidy && \
	popd;

	pushd $(CMD_DIR) && \
	$(GOCMD) -- mod tidy && \
	popd;

go_mod_vendor:
	pushd $(ABC_LIB_DIR) && \
	$(GOCMD) -- mod vendor -v && \
	popd;

	pushd $(CMD_DIR) && \
	$(GOCMD) -- mod vendor -v && \
	popd;

go_mod_verify:
	## Verify that the go.sum file matches what was downloaded to prevent someone “git push — force” over a tag being used.
	pushd $(ABC_LIB_DIR) && \
	$(GOCMD) -- mod verify && \
	popd;

	pushd $(CMD_DIR) && \
	$(GOCMD) -- mod verify && \
	popd;

go_targets:
	$(BZLPKG) query "@io_bazel_rules_go//go:*"

list_targets:
	$(BZLPKG) query //...

set_golang_version:
	sed -E -i '.org' 's/go 1.21.3/go 1.21.4/g' "$(PROJECT_DIR)/go.work" && rm "$(PROJECT_DIR)/go.work.org" && \
	sed -E -i '.org' 's/go 1.21.3/go 1.21.4/g' "$(ABC_LIB_DIR)/go.mod" && rm "$(ABC_LIB_DIR)/go.mod.org" && \
	sed -E -i '.org' 's/go 1.21.3/go 1.21.4/g' "$(CMD_DIR)/go.mod" && rm "$(CMD_DIR)/go.mod.org" && \\
	sed -E -i '.org' 's/GO_VERSION = "1.21.3"/GO_VERSION = "1.21.4"/g' "$(PROJECT_DIR)/WORKSPACE" && rm "$(PROJECT_DIR)/WORKSPACE.org" ;

## The generate_repos at the end of the command string is not an error.
## Verify the BUILD.bazel files that have been changed.  It is possible that duplicate targets were created.
sync_from_gomod: go_mod_download go_mod_tidy go_mod_vendor go_mod_verify gazelle_update_deps

sync_from_gomod_force: go_mod_download go_mod_tidy go_mod_vendor go_mod_verify gazelle_generate_build_bazel gazelle_update_deps

tidy: clean
	@rm -rf vendor
	go mod tidy
	go mod vendor -v

zap: clean
	@rm go.sum
	@rm -rf vendor
	go clean -modcache -cache
	go mod download
	go mod tidy
	go mod vendor -v