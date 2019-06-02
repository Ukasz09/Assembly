.data
 	howManyNumbersMsg:	.asciiz		"Podaj ilosc liczb: "
    inputNumberMsg:	.asciiz      	"Podaj liczbe: "
    menuMsg:       	.asciiz      	"\nWybierz z menu: \n1 => Dodawanie, \n2 => Odejmowanie \n3 => Mnozenie: \n4 => Dzielenie \n5 => NWD \n\nDecyzja: "
    resultMsg: 		.asciiz      	"Wynik: "
    wrongDecisionMsg: 	.asciiz      	"\nWybrano niewlasciwa liczbe!"
    tooLittleArgMsg:	.asciiz		"Podano niewlasciwa liczbe parametrow"
    closeDecisionMsg:		.asciiz "\nCzy chcesz zakonczyc program (0-nie): "
    divByZeroMsg:			.asciiz "Nie mozna dzielic przez 0"

	zero: .double 0.0 
.text
.macro print(%comunicate)    
    li $v0, 4       		
    la $a0, %comunicate 	
    syscall         		    
.end_macro
 
_main:
	li $s1, 1    
    li $s2, 2    
    li $s3, 3
    li $s4, 4 
    li $s5, 5

    print(menuMsg)				#s0 - wybor z menu	
    jal _readInt
    move $s0, $v0    
    bgt $s0, $s5, _wrongDecision
    blt $s0, $s1, _wrongDecision
    beq $s0, $s5, _NWDprocess
    		
    inputNumbers:
    	print(howManyNumbersMsg)
    	jal _readInt
    	move $s6, $v0					#s6 - ilosc liczb	
  
    checkIsMoreThanOne:
     	blt $s6, 2, _invalidParameter
    	j _doOperation            
		
################################################################################  
_doOperation:
 	li $t2,1 #iterator
 	ldc1 $f12, zero
 	
 	print(inputNumberMsg)           
    jal _readDouble
 	add.d $f12, $f12, $f0
 	
    operationWhile:
		print(inputNumberMsg)           
    	jal _readDouble
		jal doOperation
 		add $t2, $t2,1
 	blt $t2,$s6,operationWhile
	
     print(resultMsg)
     jal _showFloatResult
     j _closeProgramDecision

 	doOperation:
 		beq $s0, $s1, addition    
     	beq $s0, $s2, subtract
     	beq $s0, $s3, multiplication
     	beq $s0, $s4, divide
    
    addition:	
    	add.d $f12, $f12, $f0
    	jr $ra
    subtract:
    	sub.d $f12, $f12, $f0	
    	jr $ra
    multiplication:
    	mul.d $f12, $f12, $f0	
    	jr $ra
    divide: 	
    	ldc1 $f2, zero
    	c.eq.d $f2, $f0
    	bc1t _divByZero 
    	
    	div.d $f12, $f12, $f0	
    	jr $ra
    	     
_NWDprocess:
 	print(inputNumberMsg)           
    jal _readInt
 	move $t1, $v0 		# $t1 - a
 	
 	print(inputNumberMsg)           
    jal _readInt
 	move $t2, $v0			# $t2 - b
 	
 	nwdLoop:
 		bgt $t1, $t2, decA 
 		
 		decB:
 			sub $t2, $t2, $t1
 			bne $t1, $t2, nwdLoop
 			j nwdResult
 					
 		decA:
 			sub $t1, $t1, $t2
 			bne $t1, $t2, nwdLoop
 			j nwdResult
 	
 	   nwdResult:
 	   		print(resultMsg)
 	   		move $a0, $t1 
     		jal _showIntResult
     		j _closeProgramDecision
 	 	 		                     	 		                            	 		                     	 		                            	 		                     	 		                            	 		                     	 		                                 	 		                     	 		                            	 		                     	 		                            	 		                     	 		                            	 		                     	 		                    	         	 		                     	 		                            	 		                     	 		                            	 		                     	 		                            	 		                     	 		                                 	 		                     	 		                            	 		                     	 		                            	 		                     	 		                            	 		                     	 		                    		                     	 		                            	 		                     	 		                            	 		                     	 		                            	 		                     	 		                                 	 		                     	 		                            	 		                     	 		                            	 		                     	 		                            	 		                     	 		                    	         	 		                     	 		                            	 		                     	 		                            	 		                     	 		                            	 		                     	 		                                 	 		                     	 		                            	 		                     	 		                            	 		                     	 		                            	 		                     	 		                   
################################################################33

_wrongDecision:
     	print(wrongDecisionMsg)
     	j _closeProgramDecision	

_invalidParameter:
    print(tooLittleArgMsg)
    j _closeProgramDecision 
    
_divByZero:
	print(divByZeroMsg)
    j _closeProgramDecision
        
# $f0
_readDouble:
	li $v0, 7     	
    syscall       	
    jr $ra 

# $v0
_readInt:
    li $v0, 5     	
    syscall       	
    jr $ra 	
         
# $f12         
_showFloatResult:    
    li $v0, 3      	
    syscall         	
    jr $ra   
    
_showIntResult:
	li $v0, 1     	
    syscall         	
    jr $ra     
    
_closeProgramDecision:
	print(closeDecisionMsg)
	jal  _readInt
	beq  $v0, 0, _main
	j _endProcess

_endProcess:
	li $v0, 10
	syscall  
	 
###############################################################################      
.kdata 
 
  arithmeticOverflowMsg:	.asciiz "==== Arithmetic Overflow ===="
  unhandledExceptionMsg: 	.asciiz "==== Unhandled Exception ===="
  syscallExceptionMsg:		.asciiz "==== Syscall Exception ====="
  floatingPointExceptionMsg:.asciiz "==== FloatingPoint Exception ====="
  
.ktext 0x80000180
.macro print(%comunicate)    
    li $v0, 4       		
    la $a0, %comunicate 	
    syscall         		    
.end_macro

mfc0 $k0, $13
andi $k1, $k0, 0x00007c
srl $k1, $k1, 2

beq $k1, 12, _arithmeticOverflow
beq $k1, 8, _syscallException
beq $k1, 14, _floatingPointException

_unhandledException:
	print(unhandledExceptionMsg)
	j _endProcessKDATA

_arithmeticOverflow:
	print(arithmeticOverflowMsg)
	j _endProcessKDATA  

_syscallException:
	print(syscallExceptionMsg)
	j _endProcessKDATA	

_floatingPointException:
	print(floatingPointExceptionMsg)
	j _endProcessKDATA

_endProcessKDATA:
	li $v0, 10
	syscall	
	 