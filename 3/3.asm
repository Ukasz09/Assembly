.data    
    polynomialLevelMsg:	.asciiz	"Podaj stopien wielomianu: "
    coefficientMsg:	.asciiz	"Podaj wspolczynnik przy x^"
    newLineMsg:		.asciiz ""
    colonMsg:		.asciiz ": "
    valueOfXMsg:	.asciiz "Podaj wartosc x: "
    negValMsg:		.asciiz "Blad. Podano wartosc ujemna lub rowna zero"
    xOfMsg:		.asciiz "x^"
    plusMsg:		.asciiz " +"
    equalsMsg:		.asciiz " = "
    xMsg:		.asciiz "x"
    spaceMsg:		.asciiz " "
.text
.globl _main

.macro printCommunicate(%comunicate)    
    li $v0, 4       		
    la $a0, %comunicate 	
    syscall         		    
.end_macro

.macro println()
	li $v0, 4
	la $a0, newLineMsg
	syscall
.end_macro

_main:
    #s0- stopien wielomianu	
    inputPolynolmialLevel:
    	printCommunicate(polynomialLevelMsg)
    	jal _readNumberInt
    	move $s0, $v0  
    
    	ble $s0, 0, _negValueError   
    
    #wspolczynniki wczytywane na stos
    inputCoefficinets:            
    	jal _writeCoefficientsToStack
    
    #s1- wartosc x
    inputX:
    	beq $s0,1,calculateResult
    	printCommunicate(valueOfXMsg)
    	jal _readNumberInt
    	move $s1, $v0
    
    calculateResult:	
   	#s2 - wynik
   	jal _calculateResult
   	
   showResult:
   	jal _showPolynomial
   	jal _showResult
   	j _endProcess
_endMain:
##############################################################################
 _negValueError:
 	printCommunicate(negValMsg)
 	j _endProcess
       
 _readNumberInt:
    li $v0, 5     	
    syscall       	
    jr $ra

#Uzywa: $s0
#Tmp: $t0, $t1
_writeCoefficientsToStack:
    la $t1, ($ra)
    li $t0,0 #iterator      
    forCoef:
    	printCommunicate(coefficientMsg)
    	jal _printInt
    	printCommunicate(colonMsg)     
    	       
    	jal _readNumberInt
    	add $sp, $sp, -4
    	sw $v0, ($sp)  
    	add $t0, $t0, 1
    	blt $t0, $s0, forCoef	
  
    la $ra, ($t1)
    jr $ra
    
#Uzywa: $t0     
_printInt:
	li $v0,1
	la $a0, ($t0)
	syscall
	jr $ra
	
#Alokuje: $s2
#Tmp: $t4, $t7, $t0
_calculateResult:
	la $t7, ($ra)
	la $t0, ($s0) 	#iterator
	li $s2, 0	#wynik
	forCalc:
		jal _readNumberStackUp
	 	la $t4, ($t1)	  #t4 - wspolczynnik
	 	la $t1, ($s1)	  #t1 - x
	 	sub $t2, $t0, 1   #t2 - aktualny wykladnik
	 	
	 	jal _powerProcess
	 	mul $t3, $t3, $t4
	 	add $s2, $s2, $t3
	 	
	 	sub $t0, $t0,1
	 	bgtz $t0, forCalc 
	la $ra, ($t7)
	jr $ra 
	 
#Wczytuje liczbe ze stosu do $t1 i cofa wskaznik (idzie w gore odwroconego stosu)
_readNumberStackUp:
     lw $t1, ($sp)
     add $sp,$sp,4
     jr $ra  		
     
#Uzywa: t1 - podstawa, $t2 - wykladnik, 
#Tmp: $t3, $t5
_powerProcess:
     beqz $t2, powerZero    
    
     powerPositive:
     	la $t3, ($t1)
     	beq $t2, 1, powerResult
    
        li $t5, 1 #iterator   
        powWhile:
 	  mul $t3,$t3,$t1
 	  add $t5, $t5,1
 	  blt $t5,$t2,powWhile 	
    	j powerResult
    	
     powerZero:
     	li $t3, 1
     	j powerResult
 
     powerResult:
     jr $ra
  
#Uzywa: $s2        
_showResult:
	li $v0, 1
	la $a0, ($s2)
	syscall
	jr $ra

#Uzywa: $t1
_showInt:
	li $v0, 1
	la $a0, ($t1)
	syscall
	jr $ra

#Tmp: $t2, $t0, $t1
#Uzywa: stos, $s0 
_showPolynomial:
	la $t2, ($ra)
	jal _setPointerToLastStackInput
	
	la $t0, ($s0) #iterator
	showPolyWhile:
		jal _readNumberStackUp
		
		beq $t1,0,zeroCoefficient
		beq $t0, $s0, checkCoeficient
		bltz $t1, minusCoeficient
		
		notMinusCoeficient:
			jal showPlusCommunicate
			j checkCoeficient
		
		minusCoeficient:
			printCommunicate(spaceMsg)
			j checkCoeficient
			
		checkCoeficient:	
			beq $t1,1,checkLastCoefficient
		
		notLastCoefficient:
			jal _showInt
			j checkPrintX
		
		zeroCoefficient:
			bne $t0,1,endWhileCheck
			jal showPlusCommunicate
			jal _showInt
			jal showEqualsCommunicate
				
		checkLastCoefficient:
			bne $t0,1,checkPrintX
			jal _showInt
			j checkPrintX
		
		checkPrintX:
			sub $t1, $t0, 1
			beq $t1,1,printX
			beqz $t1, showEqualsCommunicate
			bne $t1,1,printXOf
		       
		printXOf:
			printCommunicate(xOfMsg)
			jal _showInt
			j endWhileCheck
		
		printX:
			printCommunicate(xMsg)
			j endWhileCheck
							 
   		showPlusCommunicate:
			printCommunicate(plusMsg)
			jr $ra
	
		showEqualsCommunicate:	
			printCommunicate(equalsMsg)
			j endWhileCheck
		
		endWhileCheck:	
			sub $t0, $t0, 1			  						 						 						
			bgtz $t0, showPolyWhile
		
	la $ra, ($t2)
	jr $ra
				
#Tmp: $t0
_setPointerToLastStackInput:
	li $t0, 0
	pointerWhile:
		add $sp, $sp, -4
		add $t0, $t0 ,1
		blt $t0, $s0, pointerWhile
	jr $ra	
	          	          
 _endProcess:
    li $v0,10
    syscall	
