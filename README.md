# questionariovalutazionedocenti
Script per la generazione dei report PDF, a partire dal DB delle risposte con le medie, estratto da Google Moduli

## Cosa fa
A partire da un file tabellare CSV, con campo separatore "|", lo script elabora le diverse medie per i questionari docenti

## Come si lancia

Basta configurare il file config.sh (che deve essere presente nella stessa cartella di Questionari.sh) e lanciare lo script principale Questionari.sh, senza altre opzioni
Tutte le configurazioni sono richiamate dal file config.sh

## Impostazioni (variabili hardcodate)
Le impostazioni sono da inserire nel file config.sh, come impostazioni di seguito specificate
Per stampare la media delle domande dell'istituto, occorre modificare manualmente anche l'output della funzione mediadomande(), editando ogni singolo case of del file Questionari.sh (~ riga 60), inserendo, per ogni domanda del ciclo, il relativo output decimale (con il . punto come separatore decimale)

### Impostazioni generiche
* db [string]	File CSV, separato da |, con i risultati, già mediati, anche con intestazione. Del tipo: Docente1|3A|3|2|1|3|2|3|4...
* numtotdomande	[integer] Numero di domande del questionario, ovvero numero di righe (+1 di intestazione) della tabella finale
* wdir [string]	Work Dir. Qua dentro si creerà il bordello. Possibilmente deve essere inesistente o vuota: molti files verranno sovrascritti senza controlli
* risdir [string]	Cartella di output delle stampe PDF. Inserire, ad esempio $wdir/Risultati
* isriservato	[0|1] Opzione se stampare o meno anche i risultati mediati del prof per singola classe: 0 NO, 1 SI
* domandeintabella [0|1] Opzione se listare le domande incorporate dentro (19 o fuori (0), dopo l'intestazione, nella tabella
* secondapagina [0|1] Opzione per stampare anche i risultati e i punteggi finali, con tanto di somma di punteggio di autovalutazione. Questa opzione necessita una serie di altre opzioni (vedi sotto)
* elencodomande [string] File contenente una serie di variabili bash (pari a $numtotdomande) del tipo dom1=, dom2=, ecc... Con il testo delle domande, con gli ESCAPE dell'HTML (&egrave;) ed eventualmente un </br> finale, per ordine. Ovvero dom3="Questa &egrave; la domanda Tre</br>"
** la domanda relativa ai coordinatori di classe, num 18, è volutamente saltata in quanto spesso gli studenti rispondevano comunque a questa domanda anche per i docenti non coordinatori, all'interno del Modulo Google, falsando pertanto calcoli e risposte. Pertanto non viene considerata nell'output e nei punteggi (il file domanda18.sh è solo un appunto della stessa domanda, già con i relativi escape, pronto da eventualmente includere)

### Impostazioni per la stampa dei risultati (opz. secondapagina=1)
* numdomandemedia [integer] Domande da considerare per il calcolo del punteggio finale. Se, ad esempio, si vuole escludere qualche domanda dal punteggio, occorre mettere queste domande come ultime ed eseguire i calcoli solo delle prime
* punteggiomassimostudenti [integer] Punteggio massimo attribuibile nel questionario. Ovvero numdomandemedia*opzione_massima
* ennesimimassimi [integer] Se si vuole, conversione in ennesimi della domanda. Se non si intende convertire, inserire ennesimimassimi=$punteggiomassimostudenti
* ennesimimassimitestuali [string] Il valore di prima, ma in lettere (per la descrizione)
* fileautovalutazione [string] Path del file CSV, separato da |, contenente i punteggi dell'autovalutazione. Del tipo: Docente1|22
* scrivirisultatifinali [0|1] Opzione per produrre un CSV riassuntivo finale, per una più comoda lettura da parte del DS
* csvds [string ]Path del CSV coi risultati finali (se scrivirisultatifinali=1). NB: Verrà sovrascritto qualunque file già esistente!
