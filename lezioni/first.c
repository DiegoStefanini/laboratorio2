// comandi base 

// pwd  -- print working directorty, stampa in quale cartella sei 

// ls   -- elenca contenuto dir corrente 
    // parametri: 
    // ls -l    -- 

// cd   -- changhe directorty, navigo in una dir 
    // il punto indica la dir corrente 
    // il .. indica la dir padre 

// mkdir    -- make dir, crea directorty 

// echo $? restituisce valore di ritorno dell'ultimo comando eseguito

// gcc -o first first.c  -- compila il file first.c e genera l'eseguibile first

// gcc -Wall -Wextra -std=c11 -o first first.c  -- compila il file first.c con tutti i warning e standard C11 e genera l'eseguibile first


// esempio programma C 

#include  <stdio.h> 

int main() {
    puts("hello"); // p(rende una stringa e va a capo  

    printf("Risultato: %d\n", 5); // stampa una stringa formattata, senza andare a capo, funzione parametri variabili 
     
    return 0; 
}