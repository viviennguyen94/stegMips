// Simplified version of main.c to make the mips code easier

#include <stdio.h>

int main() {
  FILE* ogwav_file = fopen("guitar.wav", "r");    // only read
  FILE* data_file = fopen("hello.txt", "r");      // only read
  FILE* output_file = fopen("output.wav", "w+"); // only write
  int w, d, i;

  w = fgetc(ogwav_file);
  while (w != EOF) {
    fputc(w, output_file);
    w = fgetc(ogwav_file);
  }

  // close original wav file since we already copied it to new wav file
  fclose(ogwav_file);

  // seek new wav file but skip 44 bytes
  fseek(output_file, 44 + 16, SEEK_SET);

  // gets 1 byte at a time from data file
  d = fgetc(data_file);
  while (d != EOF && w != EOF) {
    // d is 1 byte, so we have to loop through it 8 times to get each bit. each
    // bit is written to every-other byte's least significant bit.
    // loop through backward so bit order is preserved (highest order bit is
    // written first, left to right)
    for (i = 7; i >= 0; i--) {
      fseek(output_file, 1, SEEK_CUR); // skip a byte
      w = fgetc(output_file); // read the current byte (moves pointer forward)
      fseek(output_file, -1, SEEK_CUR); // move back to byte just read
      w = (w & 0xfe) | ((d >> i) & 0x01); // smack a data bit into last wav bit
      fputc(w, output_file); // write modified byte back to file
    }
    d = fgetc(data_file);
  }

  // close file handlers
  fclose(data_file);
  fclose(output_file);
  return 0;
}