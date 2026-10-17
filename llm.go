// llm.go - character n-gram model, writes out.html
package main

import (
"fmt"
"html"
"math/rand"
"os"
"strconv"
"time"
)

func main() {
path, n, order := "llm.go", 300, 3
if len(os.Args) > 1 {
path = os.Args[1]
}
if len(os.Args) > 2 {
if v, e := strconv.Atoi(os.Args[2]); e == nil {
n = v
}
}
if len(os.Args) > 3 {
if v, e := strconv.Atoi(os.Args[3]); e == nil && v > 0 {
order = v
}
}
data, err := os.ReadFile(path)
if err != nil || len(data) <= order {
fmt.Fprintln(os.Stderr, "cannot read", path)
os.Exit(1)
}
next := map[string][]byte{}
for i := 0; i+order < len(data); i++ {
k := string(data[i : i+order])
next[k] = append(next[k], data[i+order])
}
rng := rand.New(rand.NewSource(time.Now().UnixNano()))
out := append([]byte{}, data[:order]...)
for len(out) < n {
opts := next[string(out[len(out)-order:])]
if len(opts) == 0 {
out = append(out, data[:order]...)
continue
}
out = append(out, opts[rng.Intn(len(opts))])
}
page := "<!doctype html><meta charset=utf-8><title>LLMM</title><pre>" +
html.EscapeString(string(out)) +
"</pre><p><a href=\"mailto:atzek@mishua\">atzek@mishua</a></p>\n"
os.WriteFile("out.html", []byte(page), 0644)
fmt.Println(string(out))
fmt.Println("wrote out.html")
}
