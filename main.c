#define CHIP_6713

#include <stdio.h>
#include <stdlib.h>
#include "dsk6713.h"
#include "dsk6713_aic23.h"
#include "dsk6713_dip.h"
#include "dsk6713_led.h"
#include "dsk6713_flash.h"
#include <math.h>

#define AUDIO_MASK 0x0000FFFF
#define CIRCULAR_BUFFER_LENGTH 4096
#define CIRCULAR_BUFFER_MASK (CIRCULAR_BUFFER_LENGTH - 1)

// Configuration for the AIC23 codec
// More information on the parameters can be found in dsk6713_aic.h with the macro DSK6713_AIC23_DEFAULTCONFIG
static DSK6713_AIC23_Config config = {DSK6713_AIC23_DEFAULTCONFIG};

DSK6713_AIC23_CodecHandle hCodec;

float leftIn;
float leftOut;
short leftBuf[CIRCULAR_BUFFER_LENGTH];
float sum;
int index = 0;
unsigned int in;
int i,gain;

void main(void)
{
    // Initialize the DSK6713 modules
    DSK6713_init();
    DSK6713_LED_init();
    DSK6713_DIP_init();

    // Open the codec with the given configuration
    hCodec = DSK6713_AIC23_openCodec(0, &config);

    // Set the sampling frequency
    DSK6713_AIC23_setFreq(hCodec, DSK6713_AIC23_FREQ_44KHZ);
    gain = 25; // Gain should be at least half the appoximation value
    i = 0;
    // Continue running this loop so long as running is not zero
    while (TRUE){

        // Read left input audio data from port,
        // If it returns false, meaning it is busy, then keep retrying until the data is read
        while (!DSK6713_AIC23_read(hCodec, &in)) {}
            leftIn = (signed short)(in & AUDIO_MASK);
            leftIn = (float)leftIn/33000; // Take 16 bit short and scale between -1 to 1
            leftOut = 0;
                sum = 1;

            if(leftIn < 0){
                for(i = 60; i > 1 ; i--){
                   sum = (float)(1.1 + (leftIn*sum*gain) / i);
                }
              leftOut = -1+sum;
//                leftOut = exp(leftIn*gain) - 1;
            }
            else{
                for(i = 60; i > 1 ; i--){
                    sum = (float)(1.1-(leftIn*sum*gain)/i);
                }
              leftOut = 1-sum;
//                leftOut =  -1 + exp((-1*leftIn*gain));
                }
        // Increment the index so next time it writes at the next spot, if at the end of circular buffer, go back to beginning
        index++; index &= CIRCULAR_BUFFER_MASK;

        // Write the left and right audio components to the codec
        leftOut = leftOut * 33000;
        while (!DSK6713_AIC23_write(hCodec, (Uint32)leftOut)) {}
    }
}
