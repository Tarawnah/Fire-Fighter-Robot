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


   OPTION_REG= 0x87;//Use internal clock Fosc/4 with a prescaler of 256
   // Fosc=8MHz==> FTMR0 = 8MHz/4 = 2MHz, TMR0 will inc every 1/2MHz * prescaler
   //0.5uS* 256 = 128uS (per increment)
   TMR0=248;// will count 8 times before the overflow (8* 128uS = 1ms)
   INTCON = 0b11100000; //GIE and , T0IE, peripheral interrupt

   T1CON=0x01;
   TMR1H=0;
   TMR1L=0;

   CCP1CON=0x08;
   PIE1=PIE1|0x04;// Enable CCP1 interrupts
   CCPR1H=2000>>8;
   CCPR1L=2000;

   Hi_Lo_flag = 1;
}





void interrupt(){
    if(INTCON & 0x04){// TMR0 Overflow interrupt, will get here every 1ms
       TMR0=248;
       tick++;
       tick1++;
       INTCON = INTCON & 0xFB;//Clear T0IF
       }
if(PIR1&0x04){//CCP1 interrupt
   if(Hi_Lo_flag){ //high
     CCPR1H= angle >>8;
     CCPR1L= angle;
     Hi_Lo_flag=0;//next time low
     CCP1CON=0x09;//next time Falling edge
     TMR1H=0;
     TMR1L=0;
   }
   else{  //low
     CCPR1H= (40000 - angle) >>8;
     CCPR1L= (40000 - angle);
     CCP1CON=0x08; //next time rising edge
     Hi_Lo_flag=1; //next time High
     TMR1H=0;
     TMR1L=0;

   }
// clear CCP1 IF
PIR1=PIR1&0xFB;
 }
 if(PIR1&0x01){//TMR1 ovwerflow

   PIR1=PIR1&0xFE;
 }
}




void ATD_init_A0(){
ADCON0 = 0x41; // ATD ON, Dont go, channel 0, fosc/16
ADCON1 = 0xCE; // All channels are digital except A0 , 500 khz , right justified
}

unsigned int ATD_read_A0(){
ADCON0 = ADCON0 | 0x04; // GO
while(ADCON0 & 0x04);
return ((ADRESH<<8) | ADRESL);
}


void mymsDelay(int const x){
       tick=0;
       while(tick<x);

}

 void check_front_right(){
 // read port b4 : right flame sensor
if(PORTB & 0b00010000){
    tick1 = 0;
    // read port b7 : front sensor until detects fire
    while(!(PORTB & 0b10000000)){

    // if it turns more than the turning_th stop (turning_th is time)
    if (tick1 >= turning_time_delay) break;
    // move right
    move_right();

    }

// stop moving
stop_moving();
}
 }
void check_front_left(){
// read port b5 : left flame sensor
if (PORTB & 0b00100000){
     tick1 = 0;
    // read port b7 : front sensor until detects fire
    while(!(PORTB & 0b10000000)){
      // move left
      if (tick1 >= turning_time_delay) break;
      move_left();
      }
// stop moving
stop_moving();
}
}

void check_front(){
sensor_voltage = ATD_read_A0();

  // while flame detected approach it untill specified flame strength
 while(sensor_voltage >= 100 && sensor_voltage <= 990){
   // check RD6 if there is something in front of the IR sensor dont move forward
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

//pump on while there is fire:
 sensor_voltage = ATD_read_A0();
 while (PORTB & 0b10000000)
 {     //check if fire is too close or fire is too far (we check if its too far because
 //we read the digital signal from the front flame sensor so as not to pump water from too far distance)
       if(sensor_voltage < 100 || sensor_voltage > 950) break;
       water_pump_ON();
       // servo ON:
       angle=3500;
       mymsDelay(1500);
       angle=1000;
       mymsDelay(1500);
 }
water_pump_OFF();
// adjust position of servo
angle =  2250;
}