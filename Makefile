################################################################################
### FIOVB - MAKEFILE                                                         ###
################################################################################

GO = go
OUTPUT = output

################################################################################
### ALL                                                                      ###
################################################################################

all: amd64 arm64
clean: amd64-clean arm64-clean

################################################################################
### INCLUDES                                                                 ###
################################################################################

include build/amd64.mk build/arm64.mk