{
Thermostat.spin

This prgram is designed to introduce you to several new commands and teach you good code
organization. Using the lecture notes as a guide, build a breadboard circuit that has the
LCD, a servo, a temperature sensor, and an led. Then fix this program by replacing each
instance of XX with a correct command, method call, number, text string, or comment. Be
sure that any pin assigments match your breadboard circuit.
} 

CON
  _clkmode = xtal1 + pll1x                              ' freq multiplier (1x)
  _xinfreq = 5_000_000                                  ' clock crystal freq

OBJ
  lcd : "ObjectLCD"                                     ' include lcd object
  hyp : "ObjectSerial"                                  ' include serial object
  mem : "ObjectMemory"                                  ' include memory object
PUB MAIN | tin,tout,ttemp,addr,cnt1,data,mc,nrg         ' MAIN PROGRAM
dira[14]:=0                                             ' set mode pin to an input
dira[13]:=1                                             ' set the light pin to an output
if ina[14]==1                   ' ----------------------- store data if pin 14 is 3.3 V                                       
  lcd.start                                             ' start lcd
  lcd.line1                                             ' move cursor to line 1
  lcd.str(string("Tiny Town"))                          ' program  name Tiny Town
  lcd.line2                                             ' move cursor to line 2
  lcd.str(string("Monique B"))                          ' Authors name
  waitcnt(clkfreq*3+cnt)                                ' wait 3 sec
  lcd.clear                                             ' clear lcd
  addr:=1                                               ' initialize address pointer to 1
  repeat                                                ' repeat forever
    cnt1 := cnt                                         ' setting count 1 (a better clock) equal to cnt
    mc := 6858                                          ' mass times thermal mass constant
    nrg := ((mc*(ttemp-290))/1000)                      ' formula for energy stored
    tin := MEASURE_TEMP(0,315)                       ' measure temperature pin 0
    tout := MEASURE_TEMP(1,305)                       ' measure temperature pin 1
    ttemp := MEASURE_TEMP(2,313)                       ' measure temperature pin 2 
    lcd.line1                                          ' move cursor to line 1
    lcd.str(string("In: "))                            ' print text Temp
    lcd.dec(tin)                                       ' print decimal number
    lcd.str(string(" out: "))                          ' print text
    lcd.dec(tout)                                      ' print decimal number
    lcd.line2                                          ' move cursor to line 2
    lcd.str(string("thermal: "))                       ' print text
    lcd.dec(ttemp)                                     ' print decimal number
    waitcnt(clkfreq*2+cnt)                             'wait 2 seconds
    lcd.clear                                          'clears screen
    lcd.line1                                          ' move cursor to line 1
    lcd.str(string("Energy Stored:"))                  ' prints text
    lcd.line2                                          ' move cursor to line 2
    lcd.dec((mc*(ttemp-290))/1000)                     ' prints decimal number (equation)
    waitcnt(clkfreq*2+cnt)                             ' wait 2 seconds
    lcd.clear                                          'clears screen   
    mem.write(addr+4,0)                                ' store 0 in next memory addr
    mem.write(addr,tin-100)                            'Subtract 100 from tin, store tin in addr
    mem.write(addr+1,tout-100)                         ' Subtract 100 from tout, store tout in next memory addr+1
    mem.write(addr+2,ttemp-100)                        'Subtract 100 from ttemp, store ttemp in addr+2
    mem.write(addr+3,nrg-100)                          ' Subtract 100 from nrg, store nrg in addr+3
    addr:=addr+4                                       'Increment addr by 4
    if tin>299                                         ' if statement
      SERVO(4,5)                                       ' move servo to open position servo = pin 4, open for .5 msec (time length)
      lcd.str(string("Status: Open  "))                ' print status
    else                                               ' else statment
      SERVO(4,15)                                      ' move servo to close position
      lcd.str(string("Status: closed "))               ' print status
    if tout >296                                       'if statement ** outdoor temp when lights should turn on
      outa[13]:= 0                                     'turn lights off
      lcd.line2                                        ' move cursor to line 2
      lcd.str(string("Light Off"))                     ' prints string
    else                                               'else statement
      outa[13]:=1                                      'turn lights on
      lcd.line2                                        ' move cursor to line 2
     lcd.str(string("Light On"))                       ' prints string
    FLASH_LED(15)                                      ' flash led
    waitcnt(clkfreq*30+cnt1)                            ' wait 30 sec 
else                            ' ----------------------- else retrieve data (pin 15 is 0 V)
  hyp.start(31,30,9600)                                 ' start hyperterminal print object
  addr:=1                                               ' initialize address pointer to 1
  data:=1                                               ' set value of data for 1st repeat
  hyp.crlf                                              ' print carriage and return line feed
  hyp.str(string("Stored Data..."))                     ' print message string
  hyp.crlf                                              ' print carriage and return line feed  
  repeat until data==0                                  ' repeat until data = 0
    data:=mem.read(addr)                                ' read byte at memory addr
    hyp.dec(data+100)                                   ' print data to hyperterminal
    hyp.str(string(" "))                                ' print a space
    data:=mem.read(addr+1)                              ' read byte at memory addr+1
    hyp.dec(data+100)                                   ' print data to hyperterminal
    hyp.str(string(" "))                                ' print a space
    data:=mem.read(addr+2)                              ' read byte at memory addr+2
    hyp.dec(data+100)                                   ' print data to hyperterminal
    hyp.str(string(" "))                                ' print a space
    data:=mem.read(addr+3)                              ' read byte at memory addr+3
    hyp.dec(data)                                       ' print data to hyperterminal
    hyp.crlf                                            ' print carrage return and line feed
    addr:=addr+4                                        ' increment address pointer
    
PUB MEASURE_TEMP(pin,cal) | count,temp,sum              ' MEASURE TEMPERATURE ON PIN WITH CAL(calibration)
  sum := 0                                              ' initialize averaging sum to zero
  repeat 100                                            ' measure temp 100 times
    outa[pin] := 0                                      ' set pin to 0
    dira[pin] := 1                                      ' make pin an output (1)
    waitcnt(clkfreq/1000 + cnt)                         ' wait for 1 second
    dira[pin] := 0                                      ' make pin an input (0)
    count := cnt                                        ' store counter value
    waitpeq(|<pin,|<pin,0)                              ' wait for pin to change to 1
    count := ||(cnt-count)-240                          ' clock cycles (total-delays)
    temp := clkfreq/count*cal/1000                      ' convert count to C
    sum := sum + temp                                   ' add temp to averaging sum
  return sum/100                                        ' return averaged temp

PUB SERVO(pin,pos)                                      ' OPEN SERVO ON PIN w/position range of 5-15
dira[pin]:=1                                            ' set pin to output
repeat 30                                               ' send 30 pulses
  outa[pin]:=1                                          ' turn pin on
  waitcnt(clkfreq*pos/10000+cnt)                        ' wait 0.5 msec (5/10000 sec)                        
  outa[pin]:=0                                          ' turn pin off
  waitcnt(clkfreq*20/1000+cnt)                          ' wait 20 msec

PUB FLASH_LED(pin)                                      ' FLASH LCD ON PIN FOR 1/10 SEC
dira[pin]:=1                                            ' set pin to out put
outa[pin]:=1                                            ' Turn LED on
waitcnt(clkfreq*1/10+cnt)                               ' Wait 15 seconds
outa[pin]:=0                                            ' turn led off