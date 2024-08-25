

#include <stdio.h>
//#include "platform.h"
//#include "DigiLED.h"
#include <stdlib.h>
#include "xparameters.h"
#include "xgpio.h"
#include "xil_types.h"
#include "xil_io.h"
#include "digiLED.h"

#define led_num 30
#define g_val 30
#define num_patterns 3

int color_index = 0;
short rot_index = 0;
short case_ID = 0;
char initialized = 0;
char prev_btn_st = 0;
int fader = 0;
char count_up;

typedef struct hsv_data{
	uint16_t hue;
	uint8_t sat;
	uint8_t val;
}HSV_DATA;

HSV_DATA running_digi[15] = {
	{510, 255, 180},	//green
	{510, 255,  50},	//white
	{510, 255,  45},	//yellow
	{510, 255,  40},	//orange
	{510, 255,  35},	//light-green
	{510, 255,  30},	//white
	{510, 255,  25},	//white
	{510, 255,  20},	//white
	{510, 255,  15},	//white
	{510, 255,  10},	//white
	{510, 255,   5},	//white
	{510, 255,   5},	//white
	{510, 255,   0},	//white
	{510, 255,   0},	//white
	{510, 255,   0},	//white
};


HSV_DATA color_array[led_num];

HSV_DATA * arrayPtr = color_array;

XGpio Gpio;

void merica(void){
	int i=0;

	if(count_up){
		if(fader < 80)
			fader += 1;
		else{
			fader = 80;
			count_up = 0;
		}
	}

	else{
		if(fader > 20)
			fader -= 1;
		else{
			fader = 20;
			count_up = 1;
		}
	}

	for(i=0; i<led_num; i++){
		if(i<(led_num/3))
			SetLEDColor(i, 1020, 255, fader);
		else if(i<(2*led_num/3))
			SetLEDColor(i, 0, 0, fader);
		else
			SetLEDColor(i, 1, 255, fader);
	}

	for(i=0; i<200000; i++);
}

void xmas_twinkle(void){
	int i;

	if(!initialized){
		for(i=0; i<led_num; i++){
			arrayPtr->hue = 0;
			arrayPtr->sat = 0;
			arrayPtr->val = 0;
		}

		clearLEDs(led_num);
		initialized = 1;
	}

	for(i=0; i<led_num; i++){
		//led is on
		if(arrayPtr[i].val > 0){
			if(arrayPtr[i].val < 3)
				arrayPtr[i].val = 0;
			else
				arrayPtr[i].val -= 3;
		}

		//led is off
		else if(rand()%300 == 0){
			if(rand()%2 == 0)
				arrayPtr[i].hue = 0;
			else
				arrayPtr[i].hue = 510;

			arrayPtr[i].sat = 255;
			arrayPtr[i].val = 100;
		}
	}

	for(i=0; i<led_num; i++)
		SetLEDColor(i, arrayPtr[i].hue, arrayPtr[i].sat, arrayPtr[i].val);

	for(i=0; i<100000; i++);
}

void running_digilent(void){
	int i;

	for(i=0; i<led_num; i++){
		if(color_index == 15)
			color_index = 0;


		SetLEDColor(i,
			running_digi[(color_index+rot_index)%15].hue,
			running_digi[(color_index+rot_index)%15].sat,
			running_digi[(color_index+rot_index)%15].val
		);


		color_index++;

	}

	if(rot_index == 15)
		rot_index = 0;

	rot_index++;
	for(i=0; i<500000; i++);
}

void print(char *str);

int main(){

	XGpio_Initialize(&Gpio, 0);

	XGpio_SetDataDirection(&Gpio, 1, 0xFFFF);

	clearLEDs(led_num);

	enable_LEDs();

	while(1){

		if((XGpio_DiscreteRead(&Gpio, 1) == 1) && !prev_btn_st){
			prev_btn_st = 1;
			initialized = 0;
			if(case_ID < num_patterns-1)
				case_ID++;
			else
				case_ID = 0;
		}

		else if((XGpio_DiscreteRead(&Gpio, 1) == 1) && prev_btn_st){
			clearLEDs(led_num);
		}

		else{
			prev_btn_st = 0;
			if(case_ID == 0)
				merica();
			else if(case_ID == 1)
				xmas_twinkle();
			else if(case_ID == 2)
				running_digilent();
		}
	}


    return 0;
}


