// LLM.m - toy character-level bigram language model (Objective-C)
#import <Foundation/Foundation.h>

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSString *path = argc > 1 ? [NSString stringWithUTF8String:argv[1]] : @"README.md";
    int n = argc > 2 ? atoi(argv[2]) : 300;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length < 2) { fprintf(stderr, "cannot read %s\n", path.UTF8String); return 1; }
    const unsigned char *b = data.bytes;
    static unsigned int C[256][256];
    for (NSUInteger i = 0; i + 1 < data.length; i++) C[b[i]][b[i + 1]]++;
    srand48(time(NULL));
    int cur = b[0];
    NSMutableData *out = [NSMutableData data];
    for (int k = 0; k < n; k++) {
      unsigned long total = 0;
      for (int j = 0; j < 256; j++) total += C[cur][j];
      if (total == 0) { cur = b[0]; continue; }
      unsigned long r = (unsigned long)(drand48() * total), acc = 0;
      int nxt = 0;
      for (; nxt < 255; nxt++) { acc += C[cur][nxt]; if (r < acc) break; }
      unsigned char ch = (unsigned char)nxt;
      [out appendBytes:&ch length:1];
      cur = nxt;
    }
    fwrite(out.bytes, 1, out.length, stdout);
    putchar('\n');
  }
  return 0;
}
