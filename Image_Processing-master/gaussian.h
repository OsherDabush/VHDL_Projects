#ifndef _GAUSSIAN_HEADER
#define _GAUSSIAN_HEADER

#include "ap_int.h"
#include "hls_math.h"
#include "hls_stream.h"

struct DATA_PACK {
    ap_uint<8> data;  
    ap_uint<1> last;
};
typedef hls::stream<DATA_PACK> AXIS_T;

#define SIZE 3
#define MAX_WIDTH 640   
#define MAX_HEIGHT 480   

void gaussian_blur(AXIS_T &input, AXIS_T &output, int rows, int cols);

#endif
