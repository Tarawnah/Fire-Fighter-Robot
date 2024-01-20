
_main:

;FireFighter.c,33 :: 		void main() {
;FireFighter.c,34 :: 		initialize();
	CALL       _initialize+0
;FireFighter.c,35 :: 		ATD_init_A0();
	CALL       _ATD_init_A0+0
;FireFighter.c,36 :: 		while(1){
L_main0:
;FireFighter.c,38 :: 		check_front_right();
	CALL       _check_front_right+0
;FireFighter.c,39 :: 		check_front_left();
	CALL       _check_front_left+0
;FireFighter.c,40 :: 		check_front();
	CALL       _check_front+0
;FireFighter.c,42 :: 		adjust_position();
	CALL       _adjust_position+0
;FireFighter.c,44 :: 		check_and_extinguish_fire();
	CALL       _check_and_extinguish_fire+0
;FireFighter.c,45 :: 		}
	GOTO       L_main0
;FireFighter.c,46 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_initialize:

;FireFighter.c,50 :: 		void initialize(){
;FireFighter.c,51 :: 		TRISC = 0x00;
	CLRF       TRISC+0
;FireFighter.c,52 :: 		TRISB = 0b11111101;
	MOVLW      253
	MOVWF      TRISB+0
;FireFighter.c,53 :: 		TRISA = 0x01;
	MOVLW      1
	MOVWF      TRISA+0
;FireFighter.c,54 :: 		TRISD = 0b01000000;
	MOVLW      64
	MOVWF      TRISD+0
;FireFighter.c,55 :: 		PORTB = PORTB & 0b11111101;
	MOVLW      253
	ANDWF      PORTB+0, 1
;FireFighter.c,58 :: 		PORTD = 0x00;
	CLRF       PORTD+0
;FireFighter.c,59 :: 		PORTC = 0x00;
	CLRF       PORTC+0
;FireFighter.c,62 :: 		OPTION_REG= 0x87;//Use internal clock Fosc/4 with a prescaler of 256
	MOVLW      135
	MOVWF      OPTION_REG+0
;FireFighter.c,65 :: 		TMR0=248;// will count 8 times before the overflow (8* 128uS = 1ms)
	MOVLW      248
	MOVWF      TMR0+0
;FireFighter.c,66 :: 		INTCON = 0b11100000; //GIE and , T0IE, peripheral interrupt
	MOVLW      224
	MOVWF      INTCON+0
;FireFighter.c,68 :: 		T1CON=0x01;
	MOVLW      1
	MOVWF      T1CON+0
;FireFighter.c,69 :: 		TMR1H=0;
	CLRF       TMR1H+0
;FireFighter.c,70 :: 		TMR1L=0;
	CLRF       TMR1L+0
;FireFighter.c,72 :: 		CCP1CON=0x08;
	MOVLW      8
	MOVWF      CCP1CON+0
;FireFighter.c,73 :: 		PIE1=PIE1|0x04;// Enable CCP1 interrupts
	BSF        PIE1+0, 2
;FireFighter.c,74 :: 		CCPR1H=2000>>8;
	MOVLW      7
	MOVWF      CCPR1H+0
;FireFighter.c,75 :: 		CCPR1L=2000;
	MOVLW      208
	MOVWF      CCPR1L+0
;FireFighter.c,77 :: 		Hi_Lo_flag = 1;
	MOVLW      1
	MOVWF      _Hi_Lo_flag+0
;FireFighter.c,78 :: 		}
L_end_initialize:
	RETURN
; end of _initialize

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;FireFighter.c,84 :: 		void interrupt(){
;FireFighter.c,85 :: 		if(INTCON & 0x04){// TMR0 Overflow interrupt, will get here every 1ms
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt2
;FireFighter.c,86 :: 		TMR0=248;
	MOVLW      248
	MOVWF      TMR0+0
;FireFighter.c,87 :: 		tick++;
	INCF       _tick+0, 1
	BTFSC      STATUS+0, 2
	INCF       _tick+1, 1
;FireFighter.c,88 :: 		tick1++;
	INCF       _tick1+0, 1
	BTFSC      STATUS+0, 2
	INCF       _tick1+1, 1
;FireFighter.c,89 :: 		INTCON = INTCON & 0xFB;//Clear T0IF
	MOVLW      251
	ANDWF      INTCON+0, 1
;FireFighter.c,90 :: 		}
L_interrupt2:
;FireFighter.c,91 :: 		if(PIR1&0x04){//CCP1 interrupt
	BTFSS      PIR1+0, 2
	GOTO       L_interrupt3
;FireFighter.c,92 :: 		if(Hi_Lo_flag){ //high
	MOVF       _Hi_Lo_flag+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt4
;FireFighter.c,93 :: 		CCPR1H= angle >>8;
	MOVF       _angle+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;FireFighter.c,94 :: 		CCPR1L= angle;
	MOVF       _angle+0, 0
	MOVWF      CCPR1L+0
;FireFighter.c,95 :: 		Hi_Lo_flag=0;//next time low
	CLRF       _Hi_Lo_flag+0
;FireFighter.c,96 :: 		CCP1CON=0x09;//next time Falling edge
	MOVLW      9
	MOVWF      CCP1CON+0
;FireFighter.c,97 :: 		TMR1H=0;
	CLRF       TMR1H+0
;FireFighter.c,98 :: 		TMR1L=0;
	CLRF       TMR1L+0
;FireFighter.c,99 :: 		}
	GOTO       L_interrupt5
L_interrupt4:
;FireFighter.c,101 :: 		CCPR1H= (40000 - angle) >>8;
	MOVF       _angle+0, 0
	SUBLW      64
	MOVWF      R3+0
	MOVF       _angle+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      156
	MOVWF      R3+1
	MOVF       R3+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;FireFighter.c,102 :: 		CCPR1L= (40000 - angle);
	MOVF       R3+0, 0
	MOVWF      CCPR1L+0
;FireFighter.c,103 :: 		CCP1CON=0x08; //next time rising edge
	MOVLW      8
	MOVWF      CCP1CON+0
;FireFighter.c,104 :: 		Hi_Lo_flag=1; //next time High
	MOVLW      1
	MOVWF      _Hi_Lo_flag+0
;FireFighter.c,105 :: 		TMR1H=0;
	CLRF       TMR1H+0
;FireFighter.c,106 :: 		TMR1L=0;
	CLRF       TMR1L+0
;FireFighter.c,108 :: 		}
L_interrupt5:
;FireFighter.c,110 :: 		PIR1=PIR1&0xFB;
	MOVLW      251
	ANDWF      PIR1+0, 1
;FireFighter.c,111 :: 		}
L_interrupt3:
;FireFighter.c,112 :: 		if(PIR1&0x01){//TMR1 ovwerflow
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt6
;FireFighter.c,114 :: 		PIR1=PIR1&0xFE;
	MOVLW      254
	ANDWF      PIR1+0, 1
;FireFighter.c,115 :: 		}
L_interrupt6:
;FireFighter.c,116 :: 		}
L_end_interrupt:
L__interrupt36:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_ATD_init_A0:

;FireFighter.c,121 :: 		void ATD_init_A0(){
;FireFighter.c,122 :: 		ADCON0 = 0x41; // ATD ON, Dont go, channel 0, fosc/16
	MOVLW      65
	MOVWF      ADCON0+0
;FireFighter.c,123 :: 		ADCON1 = 0xCE; // All channels are digital except A0 , 500 khz , right justified
	MOVLW      206
	MOVWF      ADCON1+0
;FireFighter.c,124 :: 		}
L_end_ATD_init_A0:
	RETURN
; end of _ATD_init_A0

_ATD_read_A0:

;FireFighter.c,126 :: 		unsigned int ATD_read_A0(){
;FireFighter.c,127 :: 		ADCON0 = ADCON0 | 0x04; // GO
	BSF        ADCON0+0, 2
;FireFighter.c,128 :: 		while(ADCON0 & 0x04);
L_ATD_read_A07:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read_A08
	GOTO       L_ATD_read_A07
L_ATD_read_A08:
;FireFighter.c,129 :: 		return ((ADRESH<<8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;FireFighter.c,130 :: 		}
L_end_ATD_read_A0:
	RETURN
; end of _ATD_read_A0

_mymsDelay:

;FireFighter.c,133 :: 		void mymsDelay(int const x){
;FireFighter.c,134 :: 		tick=0;
	CLRF       _tick+0
	CLRF       _tick+1
;FireFighter.c,135 :: 		while(tick<x);
L_mymsDelay9:
	MOVLW      128
	XORWF      _tick+1, 0
	MOVWF      R0+0
	MOVLW      128
	XORWF      FARG_mymsDelay_x+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__mymsDelay40
	MOVF       FARG_mymsDelay_x+0, 0
	SUBWF      _tick+0, 0
L__mymsDelay40:
	BTFSC      STATUS+0, 0
	GOTO       L_mymsDelay10
	GOTO       L_mymsDelay9
L_mymsDelay10:
;FireFighter.c,137 :: 		}
L_end_mymsDelay:
	RETURN
; end of _mymsDelay

_check_front_right:

;FireFighter.c,139 :: 		void check_front_right(){
;FireFighter.c,141 :: 		if(PORTB & 0b00010000){
	BTFSS      PORTB+0, 4
	GOTO       L_check_front_right11
;FireFighter.c,142 :: 		tick1 = 0;
	CLRF       _tick1+0
	CLRF       _tick1+1
;FireFighter.c,144 :: 		while(!(PORTB & 0b10000000)){
L_check_front_right12:
	BTFSC      PORTB+0, 7
	GOTO       L_check_front_right13
;FireFighter.c,147 :: 		if (tick1 >= turning_time_delay) break;
	MOVLW      128
	XORWF      _tick1+1, 0
	MOVWF      R0+0
	MOVLW      128
	XORWF      _turning_time_delay+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__check_front_right42
	MOVF       _turning_time_delay+0, 0
	SUBWF      _tick1+0, 0
L__check_front_right42:
	BTFSS      STATUS+0, 0
	GOTO       L_check_front_right14
	GOTO       L_check_front_right13
L_check_front_right14:
;FireFighter.c,149 :: 		move_right();
	CALL       _move_right+0
;FireFighter.c,151 :: 		}
	GOTO       L_check_front_right12
L_check_front_right13:
;FireFighter.c,154 :: 		stop_moving();
	CALL       _stop_moving+0
;FireFighter.c,155 :: 		}
L_check_front_right11:
;FireFighter.c,156 :: 		}
L_end_check_front_right:
	RETURN
; end of _check_front_right

_check_front_left:

;FireFighter.c,157 :: 		void check_front_left(){
;FireFighter.c,159 :: 		if (PORTB & 0b00100000){
	BTFSS      PORTB+0, 5
	GOTO       L_check_front_left15
;FireFighter.c,160 :: 		tick1 = 0;
	CLRF       _tick1+0
	CLRF       _tick1+1
;FireFighter.c,162 :: 		while(!(PORTB & 0b10000000)){
L_check_front_left16:
	BTFSC      PORTB+0, 7
	GOTO       L_check_front_left17
;FireFighter.c,164 :: 		if (tick1 >= turning_time_delay) break;
	MOVLW      128
	XORWF      _tick1+1, 0
	MOVWF      R0+0
	MOVLW      128
	XORWF      _turning_time_delay+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__check_front_left44
	MOVF       _turning_time_delay+0, 0
	SUBWF      _tick1+0, 0
L__check_front_left44:
	BTFSS      STATUS+0, 0
	GOTO       L_check_front_left18
	GOTO       L_check_front_left17
L_check_front_left18:
;FireFighter.c,165 :: 		move_left();
	CALL       _move_left+0
;FireFighter.c,166 :: 		}
	GOTO       L_check_front_left16
L_check_front_left17:
;FireFighter.c,168 :: 		stop_moving();
	CALL       _stop_moving+0
;FireFighter.c,169 :: 		}
L_check_front_left15:
;FireFighter.c,170 :: 		}
L_end_check_front_left:
	RETURN
; end of _check_front_left

_check_front:

;FireFighter.c,172 :: 		void check_front(){
;FireFighter.c,173 :: 		sensor_voltage = ATD_read_A0();
	CALL       _ATD_read_A0+0
	MOVF       R0+0, 0
	MOVWF      _sensor_voltage+0
	MOVF       R0+1, 0
	MOVWF      _sensor_voltage+1
;FireFighter.c,176 :: 		while(sensor_voltage >= 100 && sensor_voltage <= 990){
L_check_front19:
	MOVLW      0
	SUBWF      _sensor_voltage+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__check_front46
	MOVLW      100
	SUBWF      _sensor_voltage+0, 0
L__check_front46:
	BTFSS      STATUS+0, 0
	GOTO       L_check_front20
	MOVF       _sensor_voltage+1, 0
	SUBLW      3
	BTFSS      STATUS+0, 2
	GOTO       L__check_front47
	MOVF       _sensor_voltage+0, 0
	SUBLW      222
L__check_front47:
	BTFSS      STATUS+0, 0
	GOTO       L_check_front20
L__check_front31:
;FireFighter.c,178 :: 		if(!(PORTD & 0b01000000))
	BTFSC      PORTD+0, 6
	GOTO       L_check_front23
;FireFighter.c,179 :: 		break;
	GOTO       L_check_front20
L_check_front23:
;FireFighter.c,180 :: 		sensor_voltage = ATD_read_A0();
	CALL       _ATD_read_A0+0
	MOVF       R0+0, 0
	MOVWF      _sensor_voltage+0
	MOVF       R0+1, 0
	MOVWF      _sensor_voltage+1
;FireFighter.c,181 :: 		move_forward();
	CALL       _move_forward+0
;FireFighter.c,182 :: 		}
	GOTO       L_check_front19
L_check_front20:
;FireFighter.c,183 :: 		stop_moving();
	CALL       _stop_moving+0
;FireFighter.c,184 :: 		}
L_end_check_front:
	RETURN
; end of _check_front

_stop_moving:

;FireFighter.c,186 :: 		void stop_moving(){
;FireFighter.c,187 :: 		PORTC = PORTC & 0b00001111;
	MOVLW      15
	ANDWF      PORTC+0, 1
;FireFighter.c,188 :: 		}
L_end_stop_moving:
	RETURN
; end of _stop_moving

_move_left:

;FireFighter.c,189 :: 		void move_left(){
;FireFighter.c,190 :: 		PORTC = (PORTC & 0b00001111)| 0b01100000;
	MOVLW      15
	ANDWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      96
	IORWF      R0+0, 0
	MOVWF      PORTC+0
;FireFighter.c,192 :: 		mymsDelay(turning_pwm);
	MOVF       _turning_pwm+0, 0
	MOVWF      FARG_mymsDelay_x+0
	MOVF       _turning_pwm+1, 0
	MOVWF      FARG_mymsDelay_x+1
	CALL       _mymsDelay+0
;FireFighter.c,193 :: 		stop_moving();
	CALL       _stop_moving+0
;FireFighter.c,194 :: 		mymsDelay(turning_pwm);
	MOVF       _turning_pwm+0, 0
	MOVWF      FARG_mymsDelay_x+0
	MOVF       _turning_pwm+1, 0
	MOVWF      FARG_mymsDelay_x+1
	CALL       _mymsDelay+0
;FireFighter.c,196 :: 		}
L_end_move_left:
	RETURN
; end of _move_left

_move_right:

;FireFighter.c,198 :: 		void move_right(){
;FireFighter.c,199 :: 		PORTC = (PORTC & 0b00001111) | 0b10010000;
	MOVLW      15
	ANDWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      144
	IORWF      R0+0, 0
	MOVWF      PORTC+0
;FireFighter.c,201 :: 		mymsDelay(turning_pwm);
	MOVF       _turning_pwm+0, 0
	MOVWF      FARG_mymsDelay_x+0
	MOVF       _turning_pwm+1, 0
	MOVWF      FARG_mymsDelay_x+1
	CALL       _mymsDelay+0
;FireFighter.c,202 :: 		stop_moving();
	CALL       _stop_moving+0
;FireFighter.c,203 :: 		mymsDelay(turning_pwm);
	MOVF       _turning_pwm+0, 0
	MOVWF      FARG_mymsDelay_x+0
	MOVF       _turning_pwm+1, 0
	MOVWF      FARG_mymsDelay_x+1
	CALL       _mymsDelay+0
;FireFighter.c,205 :: 		}
L_end_move_right:
	RETURN
; end of _move_right

_move_forward:

;FireFighter.c,207 :: 		void move_forward(){
;FireFighter.c,208 :: 		PORTC = (PORTC & 0b00001111)| 0b10100000;
	MOVLW      15
	ANDWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      160
	IORWF      R0+0, 0
	MOVWF      PORTC+0
;FireFighter.c,210 :: 		mymsDelay(3);
	MOVLW      3
	MOVWF      FARG_mymsDelay_x+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_x+1
	CALL       _mymsDelay+0
;FireFighter.c,211 :: 		stop_moving();
	CALL       _stop_moving+0
;FireFighter.c,212 :: 		mymsDelay(3);
	MOVLW      3
	MOVWF      FARG_mymsDelay_x+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_x+1
	CALL       _mymsDelay+0
;FireFighter.c,214 :: 		}
L_end_move_forward:
	RETURN
; end of _move_forward

_move_backwards:

;FireFighter.c,216 :: 		void move_backwards(){
;FireFighter.c,217 :: 		PORTC = (PORTC & 0b00001111)| 0b01010000;
	MOVLW      15
	ANDWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      80
	IORWF      R0+0, 0
	MOVWF      PORTC+0
;FireFighter.c,219 :: 		mymsDelay(3);
	MOVLW      3
	MOVWF      FARG_mymsDelay_x+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_x+1
	CALL       _mymsDelay+0
;FireFighter.c,220 :: 		stop_moving();
	CALL       _stop_moving+0
;FireFighter.c,221 :: 		mymsDelay(3);
	MOVLW      3
	MOVWF      FARG_mymsDelay_x+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_x+1
	CALL       _mymsDelay+0
;FireFighter.c,222 :: 		}
L_end_move_backwards:
	RETURN
; end of _move_backwards

_water_pump_ON:

;FireFighter.c,224 :: 		void water_pump_ON(){
;FireFighter.c,225 :: 		PORTB = PORTB | 0b00000010;
	BSF        PORTB+0, 1
;FireFighter.c,226 :: 		mymsDelay(10);
	MOVLW      10
	MOVWF      FARG_mymsDelay_x+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_x+1
	CALL       _mymsDelay+0
;FireFighter.c,227 :: 		PORTB = PORTB & 0b11111101;
	MOVLW      253
	ANDWF      PORTB+0, 1
;FireFighter.c,228 :: 		mymsDelay(10);
	MOVLW      10
	MOVWF      FARG_mymsDelay_x+0
	MOVLW      0
	MOVWF      FARG_mymsDelay_x+1
	CALL       _mymsDelay+0
;FireFighter.c,229 :: 		}
L_end_water_pump_ON:
	RETURN
; end of _water_pump_ON

_water_pump_OFF:

;FireFighter.c,231 :: 		void water_pump_OFF(){
;FireFighter.c,232 :: 		PORTB = PORTB & 0b11111101;
	MOVLW      253
	ANDWF      PORTB+0, 1
;FireFighter.c,233 :: 		}
L_end_water_pump_OFF:
	RETURN
; end of _water_pump_OFF

_adjust_position:

;FireFighter.c,235 :: 		void adjust_position(){
;FireFighter.c,236 :: 		sensor_voltage = ATD_read_A0();
	CALL       _ATD_read_A0+0
	MOVF       R0+0, 0
	MOVWF      _sensor_voltage+0
	MOVF       R0+1, 0
	MOVWF      _sensor_voltage+1
;FireFighter.c,237 :: 		while(sensor_voltage < 100){
L_adjust_position24:
	MOVLW      0
	SUBWF      _sensor_voltage+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__adjust_position56
	MOVLW      100
	SUBWF      _sensor_voltage+0, 0
L__adjust_position56:
	BTFSC      STATUS+0, 0
	GOTO       L_adjust_position25
;FireFighter.c,238 :: 		move_backwards();
	CALL       _move_backwards+0
;FireFighter.c,239 :: 		sensor_voltage = ATD_read_A0();
	CALL       _ATD_read_A0+0
	MOVF       R0+0, 0
	MOVWF      _sensor_voltage+0
	MOVF       R0+1, 0
	MOVWF      _sensor_voltage+1
;FireFighter.c,240 :: 		}
	GOTO       L_adjust_position24
L_adjust_position25:
;FireFighter.c,241 :: 		stop_moving();
	CALL       _stop_moving+0
;FireFighter.c,242 :: 		}
L_end_adjust_position:
	RETURN
; end of _adjust_position

_check_and_extinguish_fire:

;FireFighter.c,244 :: 		void check_and_extinguish_fire(){
;FireFighter.c,247 :: 		sensor_voltage = ATD_read_A0();
	CALL       _ATD_read_A0+0
	MOVF       R0+0, 0
	MOVWF      _sensor_voltage+0
	MOVF       R0+1, 0
	MOVWF      _sensor_voltage+1
;FireFighter.c,248 :: 		while (PORTB & 0b10000000)
L_check_and_extinguish_fire26:
	BTFSS      PORTB+0, 7
	GOTO       L_check_and_extinguish_fire27
;FireFighter.c,251 :: 		if(sensor_voltage < 100 || sensor_voltage > 950) break;
	MOVLW      0
	SUBWF      _sensor_voltage+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__check_and_extinguish_fire58
	MOVLW      100
	SUBWF      _sensor_voltage+0, 0
L__check_and_extinguish_fire58:
	BTFSS      STATUS+0, 0
	GOTO       L__check_and_extinguish_fire32
	MOVF       _sensor_voltage+1, 0
	SUBLW      3
	BTFSS      STATUS+0, 2
	GOTO       L__check_and_extinguish_fire59
	MOVF       _sensor_voltage+0, 0
	SUBLW      182
L__check_and_extinguish_fire59:
	BTFSS      STATUS+0, 0
	GOTO       L__check_and_extinguish_fire32
	GOTO       L_check_and_extinguish_fire30
L__check_and_extinguish_fire32:
	GOTO       L_check_and_extinguish_fire27
L_check_and_extinguish_fire30:
;FireFighter.c,252 :: 		water_pump_ON();
	CALL       _water_pump_ON+0
;FireFighter.c,254 :: 		angle=3500;
	MOVLW      172
	MOVWF      _angle+0
	MOVLW      13
	MOVWF      _angle+1
;FireFighter.c,255 :: 		mymsDelay(1500);
	MOVLW      220
	MOVWF      FARG_mymsDelay_x+0
	MOVLW      5
	MOVWF      FARG_mymsDelay_x+1
	CALL       _mymsDelay+0
;FireFighter.c,256 :: 		angle=1000;
	MOVLW      232
	MOVWF      _angle+0
	MOVLW      3
	MOVWF      _angle+1
;FireFighter.c,257 :: 		mymsDelay(1500);
	MOVLW      220
	MOVWF      FARG_mymsDelay_x+0
	MOVLW      5
	MOVWF      FARG_mymsDelay_x+1
	CALL       _mymsDelay+0
;FireFighter.c,258 :: 		}
	GOTO       L_check_and_extinguish_fire26
L_check_and_extinguish_fire27:
;FireFighter.c,259 :: 		water_pump_OFF();
	CALL       _water_pump_OFF+0
;FireFighter.c,261 :: 		angle =  2250;
	MOVLW      202
	MOVWF      _angle+0
	MOVLW      8
	MOVWF      _angle+1
;FireFighter.c,263 :: 		}
L_end_check_and_extinguish_fire:
	RETURN
; end of _check_and_extinguish_fire
