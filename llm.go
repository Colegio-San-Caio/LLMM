// llm.go - toy character-level bigram language model (Go)
package main

import (
"fmt"
"math/rand"
"os"
"strconv"
"time"
)

func main() {
path, n := "README.md", 300
if len(os.Args) > 1 {
path = os.Args[1]
}
if len(os.Args) > 2 {
if v, err := strconv.Atoi(os.Args[2]); err == nil {
n = v
}
}
data, err := os.ReadFile(path)
if err != nil || len(data) < 2 {
fmt.Fprintln(os.Stderr, "cannot read", path)
os.Exit(1)
}
var c [256][256]uint32
for i := 0; i+1 < len(data); i++ {
c[data[i]][data[i+1]]++
}
rng := rand.New(rand.NewSource(time.Now().UnixNano()))
cur := data[0]
out := make([]byte, 0, n)
for k := 0; k < n; k++ {
var total uint64
for _, v := range c[cur] {
total += uint64(v)
}
if total == 0 {
cur = data[0]
continue
}
r := uint64(rng.Int63n(int64(total)))
var acc uint64
next := 255
for j, v := range c[cur] {
acc += uint64(v)
if r < acc {
next = j
break
}
}
out = append(out, byte(next))
cur = byte(next)
}
fmt.Println(string(out))
}
