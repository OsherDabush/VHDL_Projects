#ifndef _SOBEL_HEADER
#define _SOBEL_HEADER

#include "ap_int.h"
#include "hls_math.h"
#include "hls_stream.h"

struct DATA_PACK {
    ap_uint<32> data;  // Changed to 32-bit
    ap_uint<1> last;
};
typedef hls::stream<DATA_PACK> AXIS_T;

#define SIZE 3
#define MAX_WIDTH 1920
#define MAX_HEIGHT 1080

void sobel(AXIS_T &input,
           AXIS_T &output,
           int rows, int cols);

#endif