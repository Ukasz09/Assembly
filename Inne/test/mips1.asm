.data    
    howManyNumbersComunicate:	.asciiz		"Podaj ilosc liczb: "
    inputNumberComunicate:	.asciiz      	"Podaj liczbe: "
    menuComunicate:       	.asciiz      	"\nWybierz z menu: \n1 => Dodawanie, \n2 => Odejmowanie \n3 => Mnozenie: \n4 => Dzielenie calkowite \n5 => NWD \n\nDecyzja: "
    resultComunicate: 		.asciiz      	"Wynik: "
    wrongDecisionComunicate: 	.asciiz      	"\nWybrano niewlasciwa liczbe!"
    divByZeroComunicate:	.asciiz	     	"Nie mozna dzielic przez zero"
    tooLittleArgComunicate:	.asciiz		"Podano niewlasciwa liczbe parametrow"
    unsuportedOpertion:		.asciiz		"Ta operacja nie jest wspierana"
     closeDecisionMsg:		.asciiz "\nCzy chcesz zakonczyc program (0-nie): "
     .eqv DATA_SIZE 8
.text
.globl _main

.macro print(%comunicate)    
    li $v0, 4       		
    la $a0, %comunicate 	
    syscall         		    
.end_macro
 
_main:
    li $t2, 1    
    li $t3, 2    
    li $t4, 3
    li $t5, 4 
    li $t6, 5

    #t1 - wybor z menu	
    print(menuComunicate)
    jal _readInt
    move $t1, $v0    
    
    #kontrola poprawnosci wczytanych danych
    bgt $t1, $t6, _wrongDecision
    blt $t1, $t2, _wrongDecision
 
    readMoreNumbers:   
    	ble $t1, $t4, _inputNumbers      
    
    readTwoNumbers:                                                                           
    	li $s1,2
    	j _writeNumbersToStack
    			
_inputNumbers:
    print(howManyNumbersComunicate)
    jal _readInt
    move $s1, $v0
  
    jal _checkIsMoreThanOne
    j _writeNumbersToStack            

 #Uzywa $s1, alokuje rejestr $t0
_checkIsMoreThanOne:
     li $t0, 2
     blt $s1, $t0, _invalidParameter
     jr $ra

#Uzywa $s1 - ilosc liczb do wczytania
_writeNumbersToStack:
    li $t0,0 #iterator      
    while:
    	print(inputNumberComunicate)           
    	jal _readDouble
    	
    	sub $sp, $sp, DATA_SIZE
    	s.s $f0, ($sp)  
    	add $t0, $t0, 1
    	blt $t0, $s1, while	
    endWhile:	
    j _chooseDecision
                
#Uzywa $t1 - wybor z menu, oraz $t2-$t7        
_chooseDecision:
     beq $t1, $t2, _addProcess    
     beq $t1, $t3, _subtractProcess 
     beq $t1, $t4, _multiplyProcess
     beq $t1, $t5, _divideProcess 
    # beq $t1, $t6, _powerProcess
 
    j _wrongDecision        
       
_wrongDecision:
     print(wrongDecisionComunicate)
     j _closeProgramDecision

_addProcess:
     li $t2,0 #iterator
 	
 	sub $sp, $sp, DATA_SIZE
 	sw $zero, ($sp)
 	l.s $f12, ($sp)
 	add $sp, $sp, DATA_SIZE
 	
     addWhile:
 	jal _readNumberStackUp
 	add.s $f12,$f12,$f1
 	add $t2, $t2,1
 	blt $t2,$s1,addWhile
	
     print(resultComunicate)
     jal _showResult
     j _closeProgramDecision
 	             	        	          	           	        	      
_invalidParameter:
    print(tooLittleArgComunicate)
    j _closeProgramDecision 
             	        	          	           	        	                  	        	          	           	        	                  	        	          	           	        	                   	        	          	           	        	                  	        	          	           	        	                  	        	          	           	        	      
_readNumberStackUp:
     l.s $f1, ($sp)
     add $sp,$sp,DATA_SIZE
     jr $ra     
       
#Uzywa $s2       
_showResult:    
    li $v0, 2      	
    syscall         	
    jr $ra
    
_subtractProcess:
     jal _setPointerToFirstAddedNumber
     
     li $t3,0 #wynik
     
     jal _readNumberStackDown
     add $t3,$t3,$t1
     li $t2,1 #iterator
 	
     subWhile:
        jal _readNumberStackDown
        sub $t3, $t3,$t1 
 	add $t2, $t2,1
 	blt $t2,$s1,subWhile

     jal _setPointerToFirstAddedNumber
     add $sp, $sp, DATA_SIZE
     sw $t3, ($sp) 	 	
     print(resultComunicate)
     jal _showResult
     j _closeProgramDecision 	 		        	        	         	        	           	        	        

#Alokuje $t4, uzywa $s1, zmienia wskaznik stosu
_setPointerToFirstAddedNumber:
    mul $t4, $s1, DATA_SIZE
    sub $t4, $t4, DATA_SIZE
    add $sp, $sp, $t4	
    jr $ra

#Wczytuje liczbe ze stosu do $t1 i przesowa do przodu wskaznik (idzie w dol odwroconego stosu)
_readNumberStackDown:
     lw $t1, ($sp)
     sub $sp,$sp,DATA_SIZE
     jr $ra      	 		        	        	         	        	           	        	            	 		        	        	         	        	           	        	            	 		        	        	         	        	           	        	        

_multiplyProcess:
     #jal _checkIsMoreThanOne

     li $t3,0 #wynik
     jal _readNumberStackUp
     add $t3,$t3,$t1
     
     li $t2,1 #iterator
     mulWhile:
 	jal _readNumberStackUp
 	mul $t3,$t3,$t1
 	add $t2, $t2,1
 	blt $t2,$s1,mulWhile

     sub $sp, $sp, DATA_SIZE
     sw $t3, ($sp) 	 	
     print(resultComunicate)
     jal _showResult
     j _closeProgramDecision

 _divideProcess:
     jal _readNumberStackUp
     la $t2, ($t1)
     jal _readNumberStackUp
     
     beqz $t2, divByZero 
     div $t3,$t1,$t2

     sub $sp, $sp, DATA_SIZE
     sw $t3, ($sp) 	 	
     print(resultComunicate)
     jal _showResult
     j _closeProgramDecision
     
     divByZero:
     	print(divByZeroComunicate)
     	j _closeProgramDecision	 
###############################################################################3

#liczba w $v0
_readInt:
    li $v0, 5     	
    syscall       	
    jr $ra 

#liczba w $f0
_readDouble:
	li $v0, 7     	
    syscall       	
    jr $ra 

#Uzywa: t0
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
 
  arithmeticOverflowMsg:	.ascii "==== Arithmetic Overflow ===="
  unhandledExceptionMsg: 	.ascii "==== Unhandled Exception ===="
  syscallExceptionMsg:		.ascii "==== SyscallException ====="
  
.ktext 0x80000180

mfc0 $k0, $13
andi $k1, $k0, 0x00007c
srl $k1, $k1, 2

beq $k1, 12, _arithmeticOverflow
beq $k1, 8, _syscallException

_arithmeticOverflow:
	li $v0, 4
	la $a0, arithmeticOverflowMsg
	syscall

	li $v0, 10
	syscall   

_syscallException:
	li $v0, 4
	la $a0, syscallExceptionMsg
	syscall

	li $v0, 10
	syscall   
	
_unhandledException:
	li $v0, 4
	la $a0, unhandledExceptionMsg
	syscall
	
	li $v0, 10
	syscall 	     
