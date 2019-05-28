.data    
    opertaionChooseMsg: .asciiz "\n\nPodaj wybrana operacje: "
    menuMsg:		.asciiz "\n\n1) Wprowadzanie macierzy, \n2) Drukowanie macierzy, \n3) Dodawanie macierzy, \n4) Odejmowanie macierzy, \n5) Skalowanie macierzy, \n6) Transpozycja macierzy, \n7) Mnozenie macierzy, \n8) Oblicznaie wyznacznika macierzy"
    howManyMatrixMsg:	.asciiz "\nPodaj ilosc macierzy do dodania: "
    wrongDecisionMsg:	.asciiz "\nWybrano niewlasciwa operacje"
    closeDecisionMsg:	.asciiz "\nCzy chcesz zakonczyc program (1-tak, 0-nie): "
    howManyRowMsg:	.asciiz "\nPodaj ilosc wierszy: "
    howManyColumnsMsg:	.asciiz "Podaj ilosc kolumn: "
    readNumberMsg:	.asciiz "Podaj liczbe: "
    numberOfRowsMsg: 	.asciiz "\nWiersz nr. "
    numberOfMatrixMsg:	.asciiz "\nMacierz nr. "
    newLineMsg:		.asciiz "\n"
    leftBracketMsg:	.asciiz "["
    rightBracketMsg:	.asciiz "]"
    matrixChooseMsg:	.asciiz "Podaj numer macierzy: "
    scalarMsg:		.asciiz "Podaj skalar: "
.text
.globl _main

.macro print(%comunicate)    
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
	li $s0, 0 #ilsc wprowadzonych macierzy
	
   	_mainToRepete:
	
	li $t0, 1
	li $t1, 2
	li $t2, 3
	li $t3, 4
	li $t4, 5
	li $t5, 6
	li $t6, 7
	li $t7, 8
	
	print(menuMsg)
	print(opertaionChooseMsg)
	jal _readIntNumber
	
	beq $v0, $t0, _writeMatrixesToStack
	beq $v0, $t1, _readMatrixesFromStack
	beq $v0, $t2, _addMatrixes
	#beq $v0, $t3, _subMatrixes
	beq $v0, $t4, _scalingMatrix
	#beq $v0, $t5, _transpositionMatrix
	#beq $v0, $t6, _mulMatrix
	#beq $v0, $t7, _determinantMatrix
	
	wrongDecision:
		print(wrongDecisionMsg)
		j _closeProgramDecision
	
endMain:
#################################################################################################################33
_readMatrixesFromStack:
	print(matrixChooseMsg)
	jal _readIntNumber
	move $t0, $v0		#$t0 - numer macierzy
	
	jal _moveStackPointerUp
	jal _readMatrix
	jal _moveStackPointerDown

	j _closeProgramDecision
#Uzywa t0
_moveStackPointerUp:
	li $t7, 0 		#t7 - ilosc bitow do ominiecia
	la $t6, ($ra) 		#t6 - tmp na ra
	sub $t1,$s0,$t0
	sub $t1, $t1,1		#t1 -ilosc matrixow do ominiecia
	
	#ominiecie odpowiedniej ilosci matrixow
	li $t4, 0 		#t4- iterator
	beqz $t1, endFor_stackUp	#nic nie przeskakujemy
	for_stackUp:
		lw $t2, ($sp) 	#t2 - ilosc kolumn
		add $sp, $sp, 4
		lw $t3, ($sp) 	#t3- ilosc wierszy
		add $sp, $sp, 4
		
			add $t7, $t7, 8
		
		mul $t5, $t2, $t3
		mul $t5, $t5, 4 	
		add $sp, $sp, $t5 #t5 -przesuniecie wskaznika stosu poprzedniego matrixa
		
			add $t7, $t7, $t5	
		
		add $t4, $t4, 1
		blt $t4, $t1, for_stackUp
	endFor_stackUp:
	
	la $ra, ($t6)
	jr $ra

#Uzywa: $t7
_moveStackPointerDown:
	la $t6, ($ra)		#t6 - tmp na ra
	
	sub $sp, $sp, $t7
	
	la $ra, ($t6)
	jr $ra

_readMatrix:
	la $t6, ($ra)

	lw $t0, ($sp) 	#t0 - ilosc kolumn
	add $sp, $sp, 4
	
	lw $t1, ($sp) 	#t1- ilosc wierszy
		
	mul $t3, $t0, $t1
	mul $t3, $t3, 4 	#t3 - ilosc bitow na stosie do przeskoczenia
	add $sp, $sp, $t3	#przesuniecie wskaznika stosu na poczatek matrixa

	li $t4, 0 	#t4 - iterator wierszy
	li $t5, 0 	#t5 - iterator kolumn
	for_readRows:
    		li $t5, 0
    		println()
    		
    		for_readColumns:
    			print(leftBracketMsg)
    			l.s $f12, ($sp)
    			add $sp, $sp, -4
    			jal _printFloatNumber
    			print(rightBracketMsg)
    	
    			add $t5, $t5, 1
    			blt $t5, $t0, for_readColumns
    		
    		add $t4, $t4, 1
    	blt $t4,$t1,for_readRows
	
	add $sp, $sp, -4 #powrot na ostatnio dodany element
	
	la $ra, ($t6)
	jr $ra

 _writeMatrixesToStack:
 	print(howManyMatrixMsg)
	jal _readIntNumber
	move $t0,$v0	#t0 - ilosc macierzy do wczytania	
	
	li $t1, 0 #t1 -iterator
	for_main:
		print(numberOfMatrixMsg)
		la $a0, ($s0)
		add $s0, $s0, 1
		jal _printIntNumber
		println()
		
	  	jal _writeMatrix	
       		add $t1, $t1, 1
		blt $t1, $t0, for_main
	j _closeProgramDecision
	
_writeMatrix:
	la $t6, ($ra)	# t6 - tmp na ra

	#ilosc wierzy i kolumn wrzucana na stos przed danymi danej macierzy
  	print(howManyRowMsg)
  	jal _readIntNumber  	
	move $t2, $v0	#t2 - ilosc wierszy
    	
    	print(howManyColumnsMsg)
    	jal _readIntNumber
    	move $t3, $v0	#t3 - ilosc kolumn
    	
    	li $t4, 0	#t4 -iterator wierszy
    	li $t5, 0	#t5 -iterator kolumn
    	for_writeRows:
    		li $t5, 0
    		
    		print(numberOfRowsMsg)
    		move $a0,$t4
    		jal _printIntNumber
    		println()
    		
    		for_writeColumns:
    			print(readNumberMsg)
    			jal _readFloatNumber
    			add $sp, $sp, -4
    			swc1 $f0, ($sp)
    			
    			add $t5, $t5, 1
    			blt $t5, $t3, for_writeColumns
    		
    		add $t4, $t4, 1
    	blt $t4,$t2,for_writeRows
    	
    	#wrzucenie na stos ilosc wierszy i kolumn
    	add $sp, $sp, -4
    	sw $t2, ($sp)
    	add $sp, $sp, -4
    	sw $t3, ($sp)
    	
la $ra, ($t6)    			
jr $ra

_scalingMatrix:
	print(matrixChooseMsg)
	jal _readIntNumber
	move $t0, $v0		#$t0 - numer macierzy
	
	print(scalarMsg)
	jal _readFloatNumber
	
	jal _moveStackPointerUp
	jal _mulByScalar
	jal _moveStackPointerDown

	j _closeProgramDecision

#Uzywa f0
_mulByScalar:
	la $t6, ($ra)	#t6 - tmp na ra

	lw $t0, ($sp) 	#t0 - ilosc kolumn
	add $sp, $sp, 4
	
	lw $t1, ($sp) 	#t1- ilosc wierszy
		
	mul $t3, $t0, $t1
	mul $t3, $t3, 4 	#t3 - ilosc bitow na stosie do przeskoczenia
	add $sp, $sp, $t3	#przesuniecie wskaznika stosu na poczatek matrixa

	li $t4, 0 	#t4 - iterator wierszy
	li $t5, 0 	#t5 - iterator kolumn
	for_scalarRows:
    		li $t5, 0
    		println()
    		
    		for_scalarColumns:
    			print(leftBracketMsg)
    			
    			l.s $f12, ($sp)
    			mul.s $f12, $f12, $f0
    			swc1 $f12, ($sp)
    			jal _printFloatNumber
    			print(rightBracketMsg)
    			add $sp, $sp, -4
    	
    			add $t5, $t5, 1
    			blt $t5, $t0, for_scalarColumns
    		
    		add $t4, $t4, 1
    	blt $t4,$t1,for_scalarRows
	
	println()
	add $sp, $sp, -4 #powrot na ostatnio dodany element
	
	la $ra, ($t6)
	jr $ra

_addMatrixes:
	#test
	add $sp, $sp, -4
	li $t0, 4
	sw $t0, ($sp)
	l.s $f3, ($sp)
	add $sp, $sp, 4

	print(matrixChooseMsg)
	jal _readIntNumber
	move $t0, $v0		#$t0 - numer macierzy
	jal _moveStackPointerUp
	lw $s1, 8($sp)
	l.s  $f1, 8($sp)		#f1- poczatek matrixa 1
	jal _moveStackPointerDown
	
	print(matrixChooseMsg)
	jal _readIntNumber
	move $t0, $v0		
	jal _moveStackPointerUp
	
	lw $s2, 8($sp)
	l.s  $f2, 8($sp)		#f2 - poczatek matrixa 2
	jal _moveStackPointerDown
	
	lw $t5, ($sp)		#t5 - ilosc kolumn
	#move $a0, $t5
	#jal _printIntNumber
	#println()
	lw $t6, 4($sp)		#t6 - ilosc wierszy
	#move $a0, $t6
	#jal _printIntNumber
	
	
	li $t3, 0		#t3 - iterator wierszy, t4 - iterator kolumn, 
	li $t4, 0
	for_addRows:
		println()
		li $t4, 0
		for_addColumns:	
			#mtc1 $s1, $f1	#mtc1
			#mtc1 $s2, $f2	#mtc1
			l.s $f1
			l.s $f2, ($sp)
			
			add.s $f12, $f1, $f2
			print(leftBracketMsg)
			jal _printFloatNumber
			print(rightBracketMsg)
		
			#add $s1, $s1, 4
			#add $s2, $s2, 4
			
			add.s $f1, $f1, $f3
			add.s $f2, $f2, $f3
			
			add $t4, $t4, 1
			blt $t4,$t5, for_addColumns
		
		add $t3, $t3, 1
		blt $t3,$t6,for_addRows
												
	j _endProcess
	
	
##################################################################################						
 #Wczytana liczba do f0
 _readFloatNumber:
    li $v0, 6     	
    syscall       	
    jr $ra

#Wczytana liczba do v0
 _readIntNumber:
    li $v0, 5     	
    syscall       	
    jr $ra

#Uzywa f12
_printFloatNumber:
	li $v0, 2
	#l.s $f12, ($t7)
	syscall
	jr $ra

_printIntNumber:
	li $v0, 1
	#la $a0, ($t7)
	syscall
	jr $ra

#Uzywa: t0
_closeProgramDecision:
	print(closeDecisionMsg)
	jal  _readIntNumber
	beq  $v0, 0, _mainToRepete
	j _endProcess

_endProcess:
   li $v0,10
   syscall
