// offset/main.go - hexdiff of 22/7 vs pi, and the offset delta
package main

import (
    "encoding/binary"
    "fmt"
    "math"
)

func main() {
    r := 22.0 / 7.0
    x, y := math.Float64bits(r), math.Float64bits(math.Pi)
    mark := ""
    for i := 7; i >= 0; i-- {
        if byte(x>>(8*uint(i))) != byte(y>>(8*uint(i))) {
            mark += "^^"
        } else {
            mark += ".."
        }
    }
    fmt.Printf("22/7      %016x\nmath.Pi   %016x\ndiff      %s  (%d ulp)\n", x, y, mark, int64(x)-int64(y))
    fmt.Printf("delta = pi - 22/7 = %.17g\n", math.Pi-r)
    var b [8]byte
    binary.LittleEndian.PutUint64(b[:], y)
    fmt.Printf("pi as dq bytes: % x\n", b[:])
}
