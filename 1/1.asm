.data    
    prompt1:    		.asciiz      "Podaj pierwsza liczbe: "
    prompt2:   	 		.asciiz      "Podaj druga liczbe: "
    promptMenu:       		.asciiz      "\nWybierz z menu: \n1 => dodawanie, \n2 => odejmowanie or \n3 => mnozenie: \n4 => Dzielenie \n5 => Wyjscie\n\nDecyzja: "
    promptResult: 		.asciiz      "Wynik: "
    promptWrongDecision: 	.asciiz      "\nWybrano niewlasciwa liczbe!"
    divByZeroMessage:		.asciiz	     "Nie mozna dzielic przez zero"
.text
.globl _main

.macro showComunicate(%comunicate)    
    li $v0, 4       		
    la $a0, %comunicate 	
    syscall         		    
.end_macro
 
_main:

    #Zmienne pomocnicze do menu
    li $t3, 1    
    li $t4, 2    
    li $t5, 3
    li $t6, 4 
    li $t7, 5
    
    #Wczytanie dwoch liczb     
    showComunicate(prompt1)           
    jal _readNumber
    move $t0, $v0
    showComunicate(prompt2)               
    jal _readNumber
    move $t1, $v0
    
    #Wczytanie wyboru z menu
    showComunicate(promptMenu)
    jal _readNumber
    move $t2, $v0
     
    #Wybranie odpowiedniego dzialania wedlug wybranej opcji z menu
    beq $t2, $t3, _addProcess      
    beq $t2, $t4, _subtractProcess 
    beq $t2, $t5, _multiplyProcess
    beq $t2, $t6, _divideProcess 
    beq $t2, $t7, _endProcess

#Jesli wybrano zly wybor z menu to zostanie uruchomiona ta metoda
_wrongDecision:
	li $v0,4
	la $a0,promptWrongDecision
	syscall
	j _endProcess
	        
 _addProcess:
 	add $t6,$t0,$t1   
    	
    	showComunicate(promptResult)
   	jal _showResult
	j _endProcess
      
 _subtractProcess:
    	sub $t6,$t0,$t1
     
    	showComunicate(promptResult)    
    	jal _showResult
	j _endProcess  
    
 _multiplyProcess:
    	mul $t6,$t0,$t1
    
    	showComunicate(promptResult)    
    	jal _showResult
	j _endProcess
 
 _divideProcess:
 	
 	beqz $t1, divByZero 
 	div $t6,$t0,$t1
 
 	showComunicate(promptResult)    
    	jal _showResult
	j _endProcess

	divByZero:
		showComunicate(divByZeroMessage)
		j _endProcess			
 
_endProcess:
    	li $v0,10
    	syscall  
    	
_readNumber:
    	li $v0, 5     	
    	syscall       	
    	jr $ra 		
    
_showResult:    
    	li $v0, 1      	
    	la $a0, ($t6) 
    	syscall         	
    	jr $ra 		
    
    
