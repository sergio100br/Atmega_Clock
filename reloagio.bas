'Relogio Nixie
'$prog &HFF , &HC4 , &HC9 , &H00                             ' generated. Take care that the chip supports all fuse bytes.

  $regfile = "m8def.dat"
  $crystal = 8000000

' Setup do Hardware
' Configura a direção de todos os Ports do microprocessador

Config Portd = Output
Config Pinb.0 = Input
Config Pinb.1 = Input
Config Pinb.2 = Input
Config Pinb.3 = Output
Config Pinb.4 = Output
                                     ' Saidas display no portd
Config Portc = Output

' Aliases do Hardware ( apelidos )
Display1 Alias Portc.0
Display2 Alias Portc.1
Display3 Alias Portc.2
Display4 Alias Portc.3

Led Alias Portb.3
Pisca Alias Portb.4

Segmentos Alias Portd

' Inicializa os ports assim o hardware começa corretamente
Portd = &B00000000
Portc = &B00000000
' Declação das Variáveis8

Dim Preload As Byte

Dim Unidade As Word
Dim Dezena As Word
Dim Centena As Word
Dim Milhar As Word
Dim Endereco As Word
Dim Valor As Word
Dim Contagem As Word

Dim Flag_ As Word
Dim Flagmin As Word
Dim Phase As Byte
Dim Flagefeito As Word
Dim Temp As Word
Dim Resto As Word
Dim Podemostrar As Bit

Dim S As Word
Dim M As Word
Dim H As Word
Dim Hora As Word
Dim D As Word
Dim Mn As Word
Dim Unidade_dezena As Word
Dim Centena_milhar As Word
Dim Tempo As Word
Dim Segundo As Integer
Dim Minuto As Integer
Dim Horaee As Byte
Dim Minutoee As Byte

Dim Tempeehora As Byte
Dim Tempeeminuto As Byte


Config Sda = Portc.4
Config Scl = Portc.5
Config Debounce = 20

Const Ds1307w = &HD0
Const Ds1307r = &HD1

Const Dsminuto = &H01
Const Dshora = &H02
Const Dsdia = &H04
Const Dsmes = &H05
Const Configuracao = &H07


Const Eehora = &H02
Const Eeminuto = &H04

   I2cinit
   I2cstop
   I2cstart
   I2cwbyte Ds1307w
   I2cwbyte &H07
   I2cwbyte &B10010000
   I2cstop


 'Caso nao esteja inicializando o ds1307
 'I2cstart
 'I2cwbyte Ds1307w
 'I2cwbyte &H00
 'I2cwbyte 0
 'I2cwbyte 0
 'I2cwbyte 0
 'I2cwbyte 2
 'I2cwbyte 2
 'I2cstop

' Inicializa As Variáveis

Preload = 191
Phase = 1
Flag_ = 0
Led = 0


Display1 = 0
Display2 = 0
Display3 = 0
Display4 = 0
Podemostrar = 0
Tempo = 70
'Horaee = 6
'Minutoee = 4

Writeeeprom Horaee , Eehora
Writeeeprom Minutoee , Eeminuto





                      ' Seleciona o dígito do display


                      '----------------------------------------------------------
' Código principal do programa

Config Timer0 = Timer , Prescale = 256
On Timer0 Tim0_isr
Enable Timer0
Timer0 = Preload
Enable Interrupts

Inicio:




Do
'''''''''''''''''''''''''''''


Gosub Leds1307
Gosub Converte
Gosub Chekkey
Gosub Alarme





' hora / minutos
   If Flag_ = 0 Then

   Unidade_dezena = Makedec(mn)
   Centena_milhar = Makedec(h)
   Pisca = 1
   End If

'minutos/ segundos
   If Flag_ = 1 Then

   Unidade_dezena = Makedec(s)
   Centena_milhar = Makedec(mn)

   End If

 'data

   If Flag_ = 2 Then
   Pisca = 0
   Unidade_dezena = Tempeeminuto
   Centena_milhar = Tempeehora

   End If

    If Flag_ = 3 Then

   Unidade_dezena = Makedec(m)
   Centena_milhar = Makedec(d)

   End If



          If Pinb.0 = 0 And Flag_ = 0 Then



                  Endereco = Dsminuto
                  Valor = Unidade_dezena


                  If Valor < 59 Then
                         Valor = Valor + 1

                  Else
                      Valor = 0

                  End If
                    Waitms 200
                    Gosub Atualiza


               End If


           If Pinb.0 = 0 And Flag_ = 2 Then




                  Valor = Centena_milhar
                   If Valor < 23 Then
                         Valor = Valor + 1

                  Else
                      Valor = 0

                  End If
                  Waitms 200
                  Writeeeprom Valor , Eehora



               End If



          '''''''''''''''''


          If Pinb.1 = 0 And Flag_ = 0 Then


                      Endereco = Dshora
                      Valor = Centena_milhar
                      If Valor < 23 Then
                             Valor = Valor + 1

                      Else
                          Valor = 0

                      End If
                       Waitms 200
                        Gosub Atualiza



         End If


         If Pinb.1 = 0 And Flag_ = 2 Then



                      Valor = Unidade_dezena
                      If Valor < 59 Then
                             Valor = Valor + 1

                      Else
                          Valor = 0

                      End If
                      Waitms 200
                      Writeeeprom Valor , Eeminuto




         End If




Loop
End

' Fim do programa


 Tim0_isr:
push r23
'If Podemostrar = 0 Then Goto Sai1                           ' Se ainda não está pronta a conversão, pule !


If Phase = 1 Then
   Display4 = 0
   Waitus Tempo
   Segmentos = Unidade
   Display1 = 1
   Waitus Tempo

End If


If Phase = 2 Then
   Display1 = 0
   Waitus Tempo
   Segmentos = Dezena
   Display2 = 1
   Waitus Tempo

End If


If Phase = 3 Then
   Display2 = 0
   Waitus Tempo
   Segmentos = Centena
   Display3 = 1
   Waitus Tempo

End If

If Phase = 4 Then
   Display3 = 0
   Waitus Tempo
   Segmentos = Milhar
   Display4 = 1
   Waitus Tempo

End If


Phase = Phase + 1
If Phase > 4 Then Phase = 1

Sai1:
Timer0 = Preload
pop r23
 Podemostrar = 0
Return




Atualiza:


Valor = Makebcd(valor)


   I2cstart
   I2cwbyte Ds1307w
   I2cwbyte Endereco
   I2cwbyte Valor
   I2cstop


Return



Alarme:

'If Flag_ < 2 Then

    If Tempeehora = Makedec(h) And Tempeeminuto = Makedec(mn) Then
    Led = 1
    Else
    Led = 0
    End If

'End If

Return


Leds1307:

   I2cstart
   I2cwbyte Ds1307w
   I2cwbyte 0
   I2cstop
   I2cstart
   I2cwbyte Ds1307r
   I2crbyte S , Ack
   I2crbyte Mn , Ack
   I2crbyte H , Ack
   I2crbyte D , Ack
   I2crbyte M , Nack
   I2cstop


   Readeeprom Tempeehora , Eehora
    Readeeprom Tempeeminuto , Eeminuto

   Return

''''''''''''''''''

Chekkey:



        Debounce Pinb.2 , 0 , Flag , Sub
        
        Return



Flag:

     If Flag_ = 3 Then
     Flag_ = 0
     Else
     Flag_ = Flag_ + 1
     End If
     Return



Converte:


  ' 12 : 34

 Hora = Centena_milhar * 100
 Hora = Hora + Unidade_dezena

  ' 1234

    Milhar = Hora / 1000
    Temp = 1000 * Milhar
    Resto = Hora - Temp
    Centena = Resto / 100
    Temp = 100 * Centena
    Resto = Resto - Temp
    Dezena = Resto / 10
    Temp = 10 * Dezena
    Resto = Resto - Temp
    Unidade = Resto
    Podemostrar = 1



    Return