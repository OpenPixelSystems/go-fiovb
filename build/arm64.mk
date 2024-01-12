################################################################################
### fiovb - arm64                                                            ###
### Date: 08/01/2024                                                         ###
### Version: v1.0.0                                                          ###
################################################################################

CROSS_COMPILER    = aarch64-lmp-linux-gcc
CROSS_COMPILER_C  = $(shell readlink -f $$(which $(CROSS_COMPILER)))

ARM64 = arm64
BUILD_ARM64 = $(OUTPUT)/$(ARM64)/build
SYSROOT_ARM64 = $(OUTPUT)/$(ARM64)/sysroot
BIN_ARM64 = $(OUTPUT)/$(ARM64)/bin
PREFIX_ARM64 = CGO_ENABLED=1 GOOS=linux GOARCH=$(ARM64)

arm64: optee-client-arm64 fiovb-tool-arm64
arm64-clean: optee-client-clean-arm64 sysroot-clean-arm64 fiovb-tool-clean-arm64

################################################################################
### OPTEE-CLIENT                                                             ###
################################################################################

optee-client-arm64:
	@cmake -Sthird-party/optee-client/ \
	-B$(BUILD_ARM64)/$@ \
	-DCMAKE_INSTALL_PREFIX=$(SYSROOT_ARM64)/usr \
	-DCMAKE_C_COMPILER=$(CROSS_COMPILER_C)

	@make -C $(BUILD_ARM64)/$@
	@make -C $(BUILD_ARM64)/$@ install
	
	@echo Compiled $@

optee-client-clean-arm64:
	@rm -rf $(BUILD_ARM64)/optee-client-arm64
	@echo Cleaned optee-client-arm64

################################################################################
### SYSROOT                                                                  ###
################################################################################

sysroot-clean-arm64:
	@rm -rf $(SYSROOT_ARM64)
	@echo Cleaned sysroot-arm64

################################################################################
### FIOVB TOOL                                                               ###
################################################################################

fiovb-tool-arm64:
	@$(PREFIX_ARM64) \
	CGO_CFLAGS="-g -Wall -I$(shell pwd)/$(SYSROOT_ARM64)/usr/include" \
	CGO_LDFLAGS="-L$(shell pwd)/$(SYSROOT_ARM64)/usr/lib -lteec" \
	$(GO) build -o $(BIN_ARM64)/fiovb github.com/OpenPixelSystems/go-fiovb/cmd/fiovb/

	@echo Compiled $@

fiovb-tool-clean-arm64:
	@rm -rf $(BIN_ARM64)/fiovb
	@echo Cleaned fiovb-tool-arm64