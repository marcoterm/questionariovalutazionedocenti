db=TOTALONI.csv
numtotdomande=18
wdir=wquestionario
risdir=$wdir/Risultati
isriservato=1
domandeintabella=1
secondapagina=1
elencodomande=./listadomande.sh

numdomandemedia=18
punteggiomassimostudenti=54
# Ovvero 3 * 18 = 54, considerando che le risposte sono: in totale disaccordo = 0; parzialmente in disaccordo = 1; parzialmente d'accordo = 2; Completamente d'accordo = 3
ennesimimassimi=40
ennesimimassimitestuali=quarantesimi
fileautovalutazione=AUTOVALUTAZIONEVUOTO.csv
stampotabellaautovalutazione=0
## Elimino il punteggio di autovalutazione e la conversione in Ennesimi. E pertanto anche il totale. Quest'anno AS 2020-21 non servono.
scrivirisultatifinali=1
csvds=RISULTATIFINALI_x_DS.csv

## Qua le medie totali d'Istituto, per la seconda pagina, comparativa
## Medie che estraggo dall'Excel dei questionari (foglio Docenti), faccio prima
#mediaistituto2021=41.7
mediaistituto=38.9
#mediaennesimi2020=29
mediaennesimi=27.3
#mediaautovalutazione2019=14
mediaautovalutazione=0
#mediatotale2021=29
mediatotale=27.3
