// ISSN.m - ISSN check digit (mod 11), an ISSN-style number derived from an ISBN-13,
// and a custom mod-13 variant with the same weights. Plain C inside .m.
// usage: ISSN [isbn-13 | issn]     default: 978-3-00-068463-0
#include <stdio.h>
#include <ctype.h>

static const int W[7] = {8, 7, 6, 5, 4, 3, 2};

static char sym(int v) { return "0123456789XYZ"[v]; }

static int check(const int *d, int M, long *sum) {
  long s = 0;
  int i;
  for (i = 0; i < 7; i++) s += (long)d[i] * W[i];
  if (sum) *sum = s;
  return (int)((M - s % M) % M);
}

static void report(const int *d) {
  long s;
  int c11 = check(d, 11, &s), c13 = check(d, 13, NULL), i, e[12], es = 0;
  printf("digits   ");
  for (i = 0; i < 7; i++) printf("%d", d[i]);
  printf("\nweights  8765432\nsum      %ld\n", s);
  printf("mod 11   remainder %ld, check %c   ISSN   %d%d%d%d-%d%d%d%c\n", s % 11, sym(c11),
         d[0], d[1], d[2], d[3], d[4], d[5], d[6], sym(c11));
  printf("mod 13   remainder %ld, check %c   custom %d%d%d%d-%d%d%d%c\n", s % 13, sym(c13),
         d[0], d[1], d[2], d[3], d[4], d[5], d[6], sym(c13));
  e[0] = 9; e[1] = 7; e[2] = 7;
  for (i = 0; i < 7; i++) e[3 + i] = d[i];
  e[10] = 0; e[11] = 0;
  for (i = 0; i < 12; i++) es += e[i] * (i % 2 ? 3 : 1);
  printf("EAN-13   ");
  for (i = 0; i < 12; i++) printf("%d", e[i]);
  printf("%d   (977 + 7 digits + 00 + check)\n", (10 - es % 10) % 10);
}

int main(int argc, char **argv) {
  const char *a = argc > 1 ? argv[1] : "978-3-00-068463-0";
  const char *p;
  int v[16], n = 0, d[7], i, s = 0;
  for (p = a; *p; p++) {
    if (isdigit((unsigned char)*p)) { if (n < 16) v[n++] = *p - '0'; }
    else if ((*p == 'X' || *p == 'x') && n < 16) v[n++] = 10;
  }
  if (n == 13) {
    for (i = 0; i < 12; i++) s += v[i] * (i % 2 ? 3 : 1);
    if ((10 - s % 10) % 10 != v[12]) { printf("bad ISBN-13 check digit\n"); return 1; }
    printf("ISBN-13  %s: publisher+title = ", a);
    for (i = 4; i < 12; i++) printf("%d", v[i]);
    printf(", last 7 used\n");
    for (i = 0; i < 7; i++) d[i] = v[5 + i];
    report(d);
    printf("working number only; an official ISSN is assigned by the ISSN centre\n");
    return 0;
  }
  if (n == 8) {
    long sum;
    for (i = 0; i < 7; i++) d[i] = v[i];
    printf("ISSN %s is %s\n", a, check(d, 11, &sum) == v[7] ? "valid (mod 11)" : "NOT valid (mod 11)");
    report(d);
    return 0;
  }
  printf("need an ISBN-13 or an ISSN (8 digits)\n");
  return 1;
}
