package main

import (
	"fmt"
	"github.com/abitofhelp/bazel_subpkg/pkg/abc/constants"
	"github.com/abitofhelp/bazel_subpkg/pkg/abc/date"
	"time"
)

func main() {
	b := constants.EmptyString
	if c, err := date.ConvertUtcToTimeZone("2023-11-19T03:49:33Z", "america/Phoenix"); err == nil {
		fmt.Printf("\n'%s', %s", b, c.Format(time.RFC822))
	} else {
		panic(err)
	}
}
