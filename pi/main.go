// pi/main.go - pi from Euler's product over primes from a segmented sieve
package main

import (
"fmt"
"math"
"os"
"strconv"
)

func smallPrimes(limit int) []int {
comp := make([]bool, limit+1)
var ps []int
for i := 2; i <= limit; i++ {
if !comp[i] {
ps = append(ps, i)
for j := i * i; j <= limit; j += i {
comp[j] = true
}
}
}
return ps
}

func main() {
n := 10000000
if len(os.Args) > 1 {
if v, e := strconv.Atoi(os.Args[1]); e == nil && v >= 2 {
n = v
}
}
const seg = 1 << 18
root := int(math.Sqrt(float64(n)))
for root*root > n {
root--
}
small := smallPrimes(root)

// Kahan-summed log of the product: sum of -log(1 - p^-2)
var sum, c float64
add := func(p int) {
x := -math.Log1p(-1 / (float64(p) * float64(p)))
y := x - c
t := sum + y
c = (t - sum) - y
sum = t
}

count := 0
for lo := 2; lo <= n; lo += seg {
hi := lo + seg - 1
if hi > n {
hi = n
}
mark := make([]bool, hi-lo+1)
for _, p := range small {
if p*p > hi {
break
}
start := p * p
if start < lo {
start = ((lo + p - 1) / p) * p
}
for j := start; j <= hi; j += p {
mark[j-lo] = true
}
}
for i, m := range mark {
if !m {
add(lo + i)
count++
}
}
}
pi := math.Sqrt(6 * math.Exp(sum))
fmt.Printf("primes up to %d: %d\npi ~ %.12f\nerror %.3e\n", n, count, pi, math.Abs(pi-math.Pi))
    hexdiff(pi, math.Pi)
}
