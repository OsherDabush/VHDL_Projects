#include "gaussian.h"

const int32_t GAUSSIAN_KERNEL[SIZE][SIZE] = {
    {1, 2, 1},
    {2, 4, 2},
    {1, 2, 1}
};

uint8_t apply_gaussian_blur(uint8_t img[SIZE][SIZE]) {
#pragma HLS inline
    int32_t sum = 0;
    for (int i = 0; i < SIZE; i++) {
#pragma HLS UNROLL
        for (int j = 0; j < SIZE; j++) {
#pragma HLS UNROLL
            sum += img[i][j] * GAUSSIAN_KERNEL[i][j];
        }
    }
    return (uint8_t)(sum / 16);
}

void gaussian_blur(AXIS_T &input, 
                   AXIS_T &output,
                   int rows, int cols) {
#pragma HLS INTERFACE axis register both port=input bundle=INPUT_STREAM
#pragma HLS INTERFACE axis register both port=output bundle=OUTPUT_STREAM
#pragma HLS INTERFACE s_axilite port=rows bundle=CONTROL_BUS
#pragma HLS INTERFACE s_axilite port=cols bundle=CONTROL_BUS
#pragma HLS INTERFACE s_axilite port=return bundle=CONTROL_BUS

    uint8_t LINE_BUFFER[2][MAX_WIDTH];
    uint8_t WINDOW_BUFFER[SIZE][SIZE];

#pragma HLS ARRAY_PARTITION variable=LINE_BUFFER complete dim=1
#pragma HLS ARRAY_PARTITION variable=WINDOW_BUFFER complete dim=0

    for (int i = 0; i < SIZE-1; i++) {
        for (int j = 0; j < cols; j++) {
#pragma HLS PIPELINE II=1
            LINE_BUFFER[i][j] = input.read().data;
        }
    }

    for (int row = 0; row < rows; row++) {
        for (int col = 0; col < cols; col++) {
#pragma HLS PIPELINE II=1

            for (int i = 0; i < SIZE; i++) {
#pragma HLS UNROLL
                for (int j = 0; j < SIZE-1; j++) {
#pragma HLS UNROLL
                    WINDOW_BUFFER[i][j] = WINDOW_BUFFER[i][j+1];
                }
            }

            WINDOW_BUFFER[0][SIZE-1] = LINE_BUFFER[0][col];
            WINDOW_BUFFER[1][SIZE-1] = LINE_BUFFER[1][col];

            if (row < rows-1) {
                LINE_BUFFER[1][col] = input.read().data;
            } else {
                LINE_BUFFER[1][col] = 0;
            }

            WINDOW_BUFFER[2][SIZE-1] = LINE_BUFFER[1][col];

            DATA_PACK datapack;
            datapack.data = apply_gaussian_blur(WINDOW_BUFFER);
            datapack.last = (row == rows - 1 && col == cols - 1);
            output.write(datapack);
        }
    }
}
