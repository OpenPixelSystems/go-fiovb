package main

import (
	"flag"
	"fmt"
	"os"
	"os/user"

	"github.com/OpenPixelSystems/go-fiovb/fiovb"
)

type Mode int

const (
	unknownMode Mode = iota
	readMode
)

func isRootUser() bool {
	u, err := user.Current()
	if err != nil {
		return false
	}

	return os.Geteuid() == 0 && os.Getuid() == 0 && u.Username == "root"
}

func parseArgs() (Mode, string) {
	var read = flag.String("read", "", "read value")

	flag.Parse()

	if read != nil && *read != "" {
		return readMode, *read
	}

	return unknownMode, ""
}

func read(name string) error {
	fvb := fiovb.New()

	if err := fvb.Initialize(); err != nil {
		return err
	}

	value, err := fvb.Read(name)
	if err != nil {
		return err
	}

	if err := fvb.Finalize(); err != nil {
		return err
	}

	fmt.Println(value)
	return nil
}

func main() {
	if !isRootUser() {
		fmt.Println("Permission denied")
		return
	}

	mode, name := parseArgs()
	if mode == unknownMode {
		flag.Usage()
		return
	}

	switch mode {
	case readMode:
		if err := read(name); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	}
}
