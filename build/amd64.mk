################################################################################
### fiovb - amd64                                                            ###
### Date: 08/01/2024                                                         ###
### Version: v1.0.0                                                          ###
################################################################################

HOST_COMPILER   = "gcc"
HOST_COMPILER_C = $(shell readlink -f $$(which $(HOST_COMPILER)))

AMD64 = amd64
BUILD_AMD64 = $(OUTPUT)/$(AMD64)/build
SYSROOT_AMD64 = $(OUTPUT)/$(AMD64)/sysroot
BIN_AMD64 = $(OUTPUT)/$(AMD64)/bin
PREFIX_AMD64 = GOOS=linux GOARCH=$(AMD64)

amd64: optee-client-amd64 fiovb-tool-amd64
amd64-clean: optee-client-clean-amd64 sysroot-clean-amd64 fiovb-tool-clean-amd64

################################################################################
### OPTEE-CLIENT                                                             ###
################################################################################

optee-client-amd64:
	@cmake -Sthird-party/optee-client/ \
	-B$(BUILD_AMD64)/$@ \
	-DCMAKE_INSTALL_PREFIX=$(SYSROOT_AMD64)/usr \
	-DCMAKE_C_COMPILER=$(HOST_COMPILER_C)

	@make -C $(BUILD_AMD64)/$@
	@make -C $(BUILD_AMD64)/$@ install

	@echo Compiled $@

optee-client-clean-amd64:
	@rm -rf $(BUILD_AMD64)/optee-client-amd64
	@echo Cleaned optee-client-amd64

################################################################################
### SYSROOT                                                                  ###
################################################################################

sysroot-clean-amd64:
	@rm -rf $(SYSROOT_AMD64)
	@echo Cleaned sysroot-amd64

################################################################################
### FIOVB TOOL                                                               ###
################################################################################

fiovb-tool-amd64:
	@$(PREFIX_AMD64) \
	CGO_CFLAGS="-g -Wall -I$(shell pwd)/$(SYSROOT_AMD64)/usr/include" \
	CGO_LDFLAGS="-L$(shell pwd)/$(SYSROOT_AMD64)/usr/lib -L$(shell pwd)/$(SYSROOT_AMD64)/usr/lib64 -lteec" \
	$(GO) build -o $(BIN_AMD64)/fiovb github.com/OpenPixelSystems/go-fiovb/cmd/fiovb/

	@echo Compiled $@

fiovb-tool-clean-amd64:
	@rm -rf $(BIN_AMD64)/fiovb
	@echo Cleaned fiovb-tool-amd64