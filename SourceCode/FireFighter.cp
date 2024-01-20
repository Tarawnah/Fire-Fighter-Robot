#line 1 "C:/Users/abyou/Desktop/Embedded Final Project/SourceCode/FireFighter.c"
int tick;
int tick1;
unsigned int sensor_voltage;
unsigned char Hi_Lo_flag;
unsigned int angle;

int turning_pwm = 4;
int turning_time_delay = 5000;

void initialize();
void interrupt();

void stop_moving();
void move_left();
void move_right();
void move_forward();
void move_backwards();
void water_pump_ON();
void water_pump_OFF();
void adjust_position();
void check_and_extinguish_fire();

void mymsDelay(int x);

void ATD_init_A0();
unsigned int ATD_read_A0();

void check_front_right();
void check_front_left();
void check_front();


void main() {
 initialize();
 ATD_init_A0();
 while(1){

 check_front_right();
 check_front_left();
 check_front();

 adjust_position();

 check_and_extinguish_fire();
 }
}



void initialize(){
 TRISC = 0x00;
 TRISB = 0b11111101;
 TRISA = 0x01;
 TRISD = 0b01000000;
 PORTB = PORTB & 0b11111101;


 PORTD = 0x00;
 PORTC = 0x00;


 OPTION_REG= 0x87;


 TMR0=248;
 INTCON = 0b11100000;

 T1CON=0x01;
 TMR1H=0;
 TMR1L=0;

 CCP1CON=0x08;
 PIE1=PIE1|0x04;
 CCPR1H=2000>>8;
 CCPR1L=2000;

 Hi_Lo_flag = 1;
}





void interrupt(){
 if(INTCON & 0x04){
 TMR0=248;
 tick++;
 tick1++;
 INTCON = INTCON & 0xFB;
 }
if(PIR1&0x04){
 if(Hi_Lo_flag){
 CCPR1H= angle >>8;
 CCPR1L= angle;
 Hi_Lo_flag=0;
 CCP1CON=0x09;
 TMR1H=0;
 TMR1L=0;
 }
 else{
 CCPR1H= (40000 - angle) >>8;
 CCPR1L= (40000 - angle);
 CCP1CON=0x08;
 Hi_Lo_flag=1;
 TMR1H=0;
 TMR1L=0;

 }

PIR1=PIR1&0xFB;
 }
 if(PIR1&0x01){

 PIR1=PIR1&0xFE;
 }
}




void ATD_init_A0(){
ADCON0 = 0x41;
ADCON1 = 0xCE;
}

unsigned int ATD_read_A0(){
ADCON0 = ADCON0 | 0x04;
while(ADCON0 & 0x04);
return ((ADRESH<<8) | ADRESL);
}


void mymsDelay(int const x){
 tick=0;
 while(tick<x);

}

 void check_front_right(){

if(PORTB & 0b00010000){
 tick1 = 0;

 while(!(PORTB & 0b10000000)){


 if (tick1 >= turning_time_delay) break;

 move_right();

 }


stop_moving();
}
 }
void check_front_left(){

if (PORTB & 0b00100000){
 tick1 = 0;

 while(!(PORTB & 0b10000000)){

 if (tick1 >= turning_time_delay) break;
 move_left();
 }

stop_moving();
}
}

void check_front(){
sensor_voltage = ATD_read_A0();


 while(sensor_voltage >= 100 && sensor_voltage <= 990){

 if(!(PORTD & 0b01000000))
 break;
 sensor_voltage = ATD_read_A0();
 move_forward();
 }
 stop_moving();
}

void stop_moving(){
 PORTC = PORTC & 0b00001111;
}
void move_left(){
 PORTC = (PORTC & 0b00001111)| 0b01100000;

 mymsDelay(turning_pwm);
 stop_moving();
 mymsDelay(turning_pwm);

}

void move_right(){
 PORTC = (PORTC & 0b00001111) | 0b10010000;

 mymsDelay(turning_pwm);
 stop_moving();
 mymsDelay(turning_pwm);

}

void move_forward(){
 PORTC = (PORTC & 0b00001111)| 0b10100000;

 mymsDelay(3);
 stop_moving();
 mymsDelay(3);

}

void move_backwards(){
 PORTC = (PORTC & 0b00001111)| 0b01010000;

 mymsDelay(3);
 stop_moving();
 mymsDelay(3);
}

void water_pump_ON(){
 PORTB = PORTB | 0b00000010;
 mymsDelay(10);
 PORTB = PORTB & 0b11111101;
 mymsDelay(10);
}

void water_pump_OFF(){
 PORTB = PORTB & 0b11111101;
}

void adjust_position(){
 sensor_voltage = ATD_read_A0();
 while(sensor_voltage < 100){
 move_backwards();
 sensor_voltage = ATD_read_A0();
}
stop_moving();
}

void check_and_extinguish_fire(){


 sensor_voltage = ATD_read_A0();
 while (PORTB & 0b10000000)
 {

 if(sensor_voltage < 100 || sensor_voltage > 950) break;
 water_pump_ON();

 angle=3500;
 mymsDelay(1500);
 angle=1000;
 mymsDelay(1500);
 }
water_pump_OFF();

angle = 2250;

}
