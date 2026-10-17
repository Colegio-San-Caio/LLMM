// Tex.m - writes cover.tex and, when chapter files are given, manuscript.tex.
// Plain C inside .m (builds with Termux clang and on macOS CI).
// usage: Tex [title] [isbn] [doi] [date] [chapter.tex|chapter.pdf ...]
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define AUTHOR "Kai Ketelhut"
#define ORG "Fieldberry Group"
#define ORCID "0000-0001-6049-8873"
#define ISSN "pending"

static const char *L[10] = {"0001101","0011001","0010011","0111101","0100011","0110001","0101111","0111011","0110111","0001011"};
static const char *G[10] = {"0100111","0110011","0011011","0100001","0011101","0111001","0000101","0010001","0001001","0010111"};
static const char *R[10] = {"1110010","1100110","1101100","1000010","1011100","1001110","1010000","1000100","1001000","1110100"};
static const char *P[10] = {"LLLLLL","LLGLGG","LLGGLG","LLGGGL","LGLLGG","LGGLLG","LGGGLL","LGLGLG","LGLGGL","LGGLGL"};

static char bits[100], ean[14];

static int barcode(const char *isbn) {
  int d[13], nd = 0, i, s = 0;
  const char *p;
  for (p = isbn; *p; p++)
    if (*p >= '0' && *p <= '9') { if (nd < 13) d[nd] = *p - '0'; nd++; }
  if (nd != 13) { fprintf(stderr, "ISBN needs 13 digits\n"); return 1; }
  for (i = 0; i < 12; i++) s += d[i] * (i % 2 ? 3 : 1);
  if ((10 - s % 10) % 10 != d[12]) { fprintf(stderr, "bad ISBN check digit\n"); return 1; }
  for (i = 0; i < 13; i++) ean[i] = '0' + d[i];
  ean[13] = 0;
  strcpy(bits, "101");
  for (i = 0; i < 6; i++) strcat(bits, P[d[0]][i] == 'L' ? L[d[i + 1]] : G[d[i + 1]]);
  strcat(bits, "01010");
  for (i = 0; i < 6; i++) strcat(bits, R[d[i + 7]]);
  strcat(bits, "101");
  return 0;
}

static void preamble(FILE *f, int needpdf) {
  fprintf(f, "\\documentclass[a4paper,oneside]{report}\n\\usepackage[margin=25mm]{geometry}\n"
             "\\usepackage{amsmath,amssymb}\n\\usepackage{graphicx}\n\\usepackage{tikz}\n");
  if (needpdf) fprintf(f, "\\usepackage{pdfpages}\n");
  fprintf(f, "\\usepackage[hidelinks]{hyperref}\n\\begin{document}\n");
}

static void title_page(FILE *f, const char *title, const char *isbn, const char *doi, const char *date) {
  int i;
  fprintf(f, "\\thispagestyle{empty}\n\\begin{center}\n{\\large PRE-RELEASE}\\\\[10mm]\n"
             "{\\Huge\\bfseries %s}\\\\[6mm]\n{\\Large %s}\n\\end{center}\n\\vspace{10mm}\n"
             "\\noindent\\begin{tabular}{@{}ll}\n", title, ORG);
  fprintf(f, "Author & %s \\\\\nISBN & %s \\\\\n", AUTHOR, isbn);
  fprintf(f, "DOI & \\href{https://doi.org/%s}{%s} \\\\\n", doi, doi);
  fprintf(f, "ORCID & \\href{https://orcid.org/%s}{%s} \\\\\n", ORCID, ORCID);
  fprintf(f, "ISSN & %s \\\\\nStatus & Pre-release \\\\\nDate & %s \\\\\n\\end{tabular}\n\\vfill\n", ISSN, date);
  fprintf(f, "\\begin{center}\n\\begin{tikzpicture}[x=0.33mm,y=1mm]\n");
  for (i = 0; i < 95;) {
    if (bits[i] == '1') {
      int j = i;
      while (j < 95 && bits[j] == '1') j++;
      fprintf(f, "\\fill (%d,0) rectangle (%d,22);\n", i, j);
      i = j;
    } else i++;
  }
  fprintf(f, "\\end{tikzpicture}\\\\[2mm]\nISBN barcode (EAN-13): %s\n\\end{center}\n", ean);
  fprintf(f, "\\noindent Pre-release. The ISSN has not been assigned yet and will be added once registered.\n\\clearpage\n");
}

static int add_chapter(FILE *out, const char *path) {
  size_t n = strlen(path);
  FILE *in;
  long len;
  char *buf, *b, *e, *start;
  if (n > 4 && strcmp(path + n - 4, ".pdf") == 0) {
    fprintf(out, "\\includepdf[pages=-]{%s}\n", path);
    return 0;
  }
  in = fopen(path, "rb");
  if (!in) { fprintf(stderr, "cannot open %s\n", path); return 1; }
  fseek(in, 0, SEEK_END);
  len = ftell(in);
  fseek(in, 0, SEEK_SET);
  buf = malloc(len + 1);
  if (!buf) { fclose(in); return 1; }
  len = (long)fread(buf, 1, len, in);
  buf[len] = 0;
  fclose(in);
  b = strstr(buf, "\\begin{document}");
  e = strstr(buf, "\\end{document}");
  start = b ? b + strlen("\\begin{document}") : buf;
  if (e && e > start) *e = 0;
  fprintf(out, "\\clearpage\n%% ---- %s ----\n%s\n", path, start);
  free(buf);
  return 0;
}

int main(int argc, char **argv) {
  const char *title = argc > 1 ? argv[1] : "DIY DOS";
  const char *isbn = argc > 2 ? argv[2] : "978-3-00-068463-0";
  const char *doi = argc > 3 ? argv[3] : "10.5281/zenodo.23334792";
  const char *date = argc > 4 ? argv[4] : "13 October 2026";
  int nch = argc > 5 ? argc - 5 : 0, i, needpdf = 0;
  char **ch = nch ? argv + 5 : argv;
  FILE *f;
  if (barcode(isbn)) return 1;
  f = fopen("cover.tex", "w");
  if (!f) return 1;
  preamble(f, 0);
  title_page(f, title, isbn, doi, date);
  fprintf(f, "\\end{document}\n");
  fclose(f);
  puts("wrote cover.tex");
  if (nch == 0) return 0;
  for (i = 0; i < nch; i++) {
    size_t n = strlen(ch[i]);
    if (n > 4 && strcmp(ch[i] + n - 4, ".pdf") == 0) needpdf = 1;
  }
  f = fopen("manuscript.tex", "w");
  if (!f) return 1;
  preamble(f, needpdf);
  title_page(f, title, isbn, doi, date);
  fprintf(f, "\\tableofcontents\n\\clearpage\n");
  for (i = 0; i < nch; i++)
    if (add_chapter(f, ch[i])) { fclose(f); return 1; }
  fprintf(f, "\\end{document}\n");
  fclose(f);
  puts("wrote manuscript.tex");
  return 0;
}
