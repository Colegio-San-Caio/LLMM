package main

import (
    "fmt"
    "math"
)

// hexdiff shows the 8 IEEE-754 bytes of a and b and marks the bytes that differ.
func hexdiff(a, b float64) {
    x, y := math.Float64bits(a), math.Float64bits(b)
    mark := ""
    for i := 7; i >= 0; i-- {
        if byte(x>>(8*uint(i))) != byte(y>>(8*uint(i))) {
            mark += "^^"
        } else {
            mark += ".."
        }
    }
    d := int64(x) - int64(y)
    if d < 0 {
        d = -d
    }
    fmt.Printf("computed  %016x\nmath.Pi   %016x\ndiff      %s  (%d ulp)\n", x, y, mark, d)
}
