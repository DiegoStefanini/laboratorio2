// touch    - se file non esiste lo crea, se esiste aggiorna data di modifica

// questi tre sono metadati di un file:
// atime    - access time, tempo di ultimo accesso al file

// mtime    - modification time, tempo di ultima modifica al file

// ctime    - change time, tempo di ultima modifica dei metadati del file

// touch aggiorna atime, mtime al tempo corrente (l'aggiornamento di questi valori richiede la modifica dei metadati e provoca normalmente anche l'aggiornamento di ctime)


// stat     - restituisce informazioni su un file, tra cui atime, mtime, ctime.

// cp       - copia il contenuto di un file sorgente in un file destinazione.
//              Destinazione: mtime e ctime aggiornati all'ora corrente (anche atime se il file viene creato);
//              con -p atime e mtime vengono preservati dal sorgente (ctime no).
//              Sorgente: mtime e ctime invariati; l'atime può essere aggiornato dalla lettura

// cp /tmp/ciao.txt ~/hello.txt  -- copia il file ciao.txt dalla cartella /tmp alla cartella home dell'utente, rinominandolo hello.txt

// la copia ha costo comutazionale N, la lettura del file sorgente richiede di leggere tutti i byte del file, quindi il tempo di esecuzione cresce linearmente con la dimensione del file.
// lo spostamente di un file all'interno dello stesso filesystem ha costo computazionale O(1), perché non richiede la lettura dei dati del file,
//    ma solo l'aggiornamento dei metadati del file (il percorso). 
//    Se il file viene spostato in un altro filesystem, allora il costo computazionale è N, perché il file deve essere copiato nel nuovo filesystem e poi cancellato dal vecchio filesystem.


// rm       - cancella un file, rimuove il file dal filesystem.

// rmdir    - cancella una directory vuota, rimuove la directory dal filesystem.

// rm -r    - cancella una directory e tutto il suo contenuto, rimuove la directory e tutti i file e sottodirectory dal filesystem.

// cat     - stampa il contenuto di un file sullo standard output (stdout)

// less   - stampa il contenuto di un file sullo standard output (stdout) con possibilità di scorrere avanti e indietro, e di cercare una stringa all'interno del file.


// head  - stampa le prime 10 righe di un file sullo standard output (stdout)

// tail  - stampa le ultime 10 righe di un file sullo standard output (stdout)

// head -n 5 file.txt  -- stampa le prime 5 righe del file file.txt sullo standard output (stdout)

// il carattere * è un carattere argomento che può essere usato per indicare tutti i file che corrispondono a un certo pattern. 
//  Ad esempio, *.txt indica tutti i file che terminano con l'estensione .txt.
//  viene espanso dalla shell prima che ls venga eseguito. quindi non è una funzionalità del comando ma della shell 
// Per esempio, se nella directory ci sono a.txt, b.txt e c.c: 
//  ls *.txt      →  la shell esegue:  ls a.txt b.txt; ls non vede mai l'asterisco, riceve già i nomi.

// il carattere ? è un carattere argomento che può essere usato per indicare un singolo carattere qualsiasi.
//  Ad esempio, prova?.txt indica tutti i file che iniziano con prova, hanno un carattere qualsiasi al posto del punto interrogativo e terminano con l'estensione .txt.



// input / output  
// redirigere lo standart output > 
// ls > elenco.txt  -- reindirizza l'output del comando ls nel file elenco.txt, se il file esiste viene sovrascritto, altrimenti viene creato.

// aggiungere invece di sostituire: >> 
// echo "prima riga" > log.txt 
// echo "seconda riga" >> log.txt  -- aggiunge la seconda riga al file log.txt, senza sovrascrivere il contenuto precedente.
// cat log.txt
//  prima riga
//  seconda riga

// redirigere lo standard input <
// programma < dati.txt -- reindirizza l'input del programma dal file dati.txt invece che dalla tastiera


// la pipe | permette di collegare l'output di un comando all'input di un altro comando, senza passare per un file intermedio.
// ls | less  -- reindirizza l'output del comando ls all'input del comando less, permettendo di scorrere l'elenco dei file con less.
// ls *.c | wc -l  -- reindirizza l'output del comando ls *.c all'input del comando wc -l, che conta il numero di righe (file) elencati da ls.

// Chi riceve gli argomenti ? 

// la shell separe la riga in parole e avvia il programma passandogli gli argomenti  
// vedremo come un programma può accedere a questi argomenti attraverso argc e argv, che sono i parametri della funzione main.


