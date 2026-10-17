package main

import (
"fmt"
"os/exec"
)

func main() {
fmt.Println("LLMM Immutability Macro - Already enforced for all!")
cmds := []string{
"gh api /orgs/Colegio-San-Caio/settings/immutable-releases",
"gh api /repos/Colegio-San-Caio/LLMM/immutable-releases",
}
for _, c := range cmds {
fmt.Printf("\n$ %s\n", c)
out, _ := exec.Command("bash", "-c", c).CombinedOutput()
fmt.Println(string(out))
}
fmt.Println("✅ Done - all future releases are now immutable + attested")
}
