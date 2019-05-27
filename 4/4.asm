.data    
    opertaionChooseMsg: .asciiz "\n\nPodaj wybrana operacje: "
    menuMsg:		.asciiz "\n\n1) Wprowadzanie macierzy, \n2) Drukowanie macierzy, \n3) Dodawanie macierzy, \n4) Odejmowanie macierzy, \n5) Skalowanie macierzy, \n6) Transpozycja macierzy, \n7) Mnozenie macierzy, \n8) Oblicznaie wyznacznika macierzy"
    howManyMatrixMsg:	.asciiz "\n\nPodaj ilosc macierzy do dodania: "
    wrongDecisionMsg:	.asciiz "\nWybrano niewlasciwa operacje"
    closeDecisionMsg:	.asciiz "\nCzy chcesz zakonczyc program (1-tak, 0-nie)"
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
	
	#beq $v0, $t0, _readMatrixesToStack
	#eq $v0, $t1, _printMatrix
	#beq $v0, $t2, _addMatrixes
	#beq $v0, $t3, _subMatrixes
	#beq $v0, $t4, _scalingMatrix
	#beq $v0, $t5, _transpositionMatrix
	#beq $v0, $t6, _mulMatrix
	#beq $v0, $t7, _determinantMatrix
	
	wrongDecision:
		print(wrongDecisionMsg)
		j _closeProgramDecision
	
endMain:
######################################################
 
#TODO 
 _readMatrixesToStack:
 	print(howManyMatrixMsg)
	jal _readIntNumber
	move $t0,$v0	#t0 - ilosc macierzy do wczytania
	
	li $t1, 0 #t1 -iterator
	for_main:
	  	jal _readMatrix	
       		add $t1, $t1, 1
		blt $t1, $t0, for_main
	jr $ra
	
_readMatrix:
#TODO	
			
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

#Uzywa: t7
_printFloatNumber:
	li $v0, 2
	l.s $f12, ($t7)
	syscall
	jr $ra

#Uzywa: t0
_closeProgramDecision:
	print(closeDecisionMsg)
	jal  _readIntNumber
	beq  $v0, 0, _main
	j _endProcess

_endProcess:
   li $v0,10
   syscall