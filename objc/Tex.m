// Tex.m - writes cover.tex (title page + EAN-13 barcode). Plain C inside .m.
#include <stdio.h>
#include <string.h>

#define AUTHOR "Kai Ketelhut"
#define ORG "Fieldberry Group"
#define ORCID "0000-0001-6049-8873"
#define ISSN "pending"

static const char *L[10] = {"0001101","0011001","0010011","0111101","0100011","0110001","0101111","0111011","0110111","0001011"};
static const char *G[10] = {"0100111","0110011","0011011","0100001","0011101","0111001","0000101","0010001","0001001","0010111"};
static const char *R[10] = {"1110010","1100110","1101100","1000010","1011100","1001110","1010000","1000100","1001000","1110100"};
static const char *P[10] = {"LLLLLL","LLGLGG","LLGGLG","LLGGGL","LGLLGG","LGGLLG","LGGGLL","LGLGLG","LGLGGL","LGGLGL"};

int main(int argc, char **argv) {
  const char *title = argc > 1 ? argv[1] : "DIY DOS";
  const char *isbn = argc > 2 ? argv[2] : "978-3-00-068463-0";
  const char *doi = argc > 3 ? argv[3] : "10.5281/zenodo.23334792";
  const char *date = argc > 4 ? argv[4] : "13 October 2026";
  int d[13], nd = 0, i, s = 0;
  char ean[14], bits[100];
  const char *p;
  FILE *f;
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
  f = fopen("cover.tex", "w");
  if (!f) return 1;
  fprintf(f, "\\documentclass[a4paper]{article}\n\\usepackage[margin=25mm]{geometry}\n"
             "\\usepackage{tikz}\n\\usepackage{hyperref}\n\\pagestyle{empty}\n\\begin{document}\n"
             "\\begin{center}\n{\\large PRE-RELEASE}\\\\[10mm]\n{\\Huge\\bfseries %s}\\\\[6mm]\n"
             "{\\Large %s}\n\\end{center}\n\\vspace{10mm}\n\\noindent\\begin{tabular}{@{}ll}\n", title, ORG);
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
  fprintf(f, "\\noindent Pre-release. The ISSN has not been assigned yet and will be added once registered.\n\\end{document}\n");
  fclose(f);
  puts("wrote cover.tex");
  return 0;
}
