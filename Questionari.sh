#!/bin/bash

. ./config.sh
. $elencodomande
mkdir -p $wdir
mkdir -p $risdir

if [ $scrivirisultatifinali -eq 1 ]; then
echo "DOCENTE;Somma dei risultati degli studenti;Conversione in $ennesimimassimitestuali;Punteggio Autovalutazione validato;TOTALE" > $csvds
fi

#Estraggo la lista delle classi e me la salvo in un file

cat $db | cut -f 2 -d"|" | grep -v Classe | sort | uniq | grep -v Classe > $wdir/listaclassi.txt
cat $db | cut -f 1 -d"|" | grep -v Professore | sort | uniq | grep -v Classe > $wdir/listaprof.txt

## Funzione calcola media classe/docente
## $1=classe/docente
## $2=n domanda da mediare

mediaclasse() {
classe=$1
domanda=$2
domandaorig=$2

let domanda=domanda+2
righecl=$(cat $db | grep $classe | cut -f $domanda -d"|" | wc -l)

sommamedia=0
i=1
while [ $i -le $righecl ]; do
rigacl=$(cat $db | grep $classe | cut -f $domanda -d"|" | head -n $i | tail -n 1)
sommamedia=`echo $sommamedia + $rigacl | bc`
let i=i+1
done
media=$(echo "scale=1; $sommamedia/$righecl" | bc)
#echo "La media via funzione per il campo $classe alla domanda $domandaorig è $media"
echo $media
}

mediadomandec() {
domandaorig=$1
domanda=$1

let domanda=domanda+2
righecl=$(cat $db | grep -v "Professore|Classe" | cut -f $domanda -d"|" | wc -l)

sommamedia=0
i=1
while [ $i -le $righecl ]; do
rigacl=$(cat $db | cut -f $domanda -d"|" | head -n $i | tail -n 1)
sommamedia=`echo $sommamedia + $rigacl | bc`
let i=i+1
done
media=$(echo "scale=1; $sommamedia/$righecl" | bc)
#echo "La media di tutte le risposte alla domanda $domandaorig via funzione è $media"
echo $media
}

mediadomande() {
case $1 in
1)
echo "2.1"
;;
2)
echo "2.3"
;;
3)
echo "2.3"
;;
4)
echo "2.1"
;;
5)
echo "2.2"
;;
6)
echo "2.3"
;;
7)
echo "2.4"
;;
8)
echo "2.1"
;;
9)
echo "2.0"
;;
10)
echo "2.1"
;;
11)
echo "2.1"
;;
12)
echo "2.3"
;;
13)
echo "2.3"
;;
14)
echo "2.3"
;;
15)
echo "2.4"
;;
16)
echo "2.3"
;;
17)
echo "2.1"
;;
18)
echo "2.2"
;;
19)
echo "1.9"
;;
*)
esac
}


mediaprofeclasse() {
profe=$1
classe=$2
domanda=$3
domandaorig=$3

let domanda=domanda+2
media=$(cat $db | grep $profe | grep $classe | cut -f $domanda -d"|")
#echo "La media di tutte le risposte alla domanda $domandaorig per il profe $profe per la classe $classe via funzione è $media"
echo $media
}

classidelprof() {
profe=$1

let domanda=domanda+2
classi=$(cat $db | grep $profe | cut -f 2 -d"|")
#echo $classi
cat $db | grep $profe | cut -f 2 -d"|" > $wdir/classi_di_$profe.txt
}

dividiclassiprofe() {
profe=$1
#quanteclassi=$(wc -l $wdir/classi_di_$profe.txt | cut -f 1 -d " ")
split -l 3 $wdir/classi_di_$profe.txt $wdir/DIV
	if [ -f $wdir/DIVaa ]; then
	mv $wdir/DIVaa $wdir/classi_di_$profe.txt
	fi
	if [ -f $wdir/DIVab ]; then
	mv $wdir/DIVab $wdir/classi_di_$profe-2.txt
	fi
	if [ -f $wdir/DIVac ]; then
	mv $wdir/DIVac $wdir/classi_di_$profe-3.txt
	fi
	if [ -f $wdir/DIVad ]; then
	mv $wdir/DIVad $wdir/classi_di_$profe-4.txt
	fi
	if [ -f $wdir/DIVae ]; then
	mv $wdir/DIVae $wdir/classi_di_$profe-5.txt
	fi
	if [ -f $wdir/DIVaf ]; then
	mv $wdir/DIVaf $wdir/classi_di_$profe-6.txt
	fi
}

iscoordinatore () {
cat $db | grep $1 | grep $2 | cut -f 19 -d"|" | grep "." >> /dev/null
}

iscoordinatore2 () {
cat $db | grep $1 | cut -f 19 -d"|" | grep "." >> /dev/null
}

sommapunteggidomande () {
	profe=$1
	numdomandemedia=$2
	k=1
	somma=0

	while [ $k -le $numdomandemedia ]; do
	r=$(mediaclasse $profe $k)
	somma=$(echo "scale=1; $somma+$r" | bc)
	#let somma=somma+r
	let k=k+1
	done
	echo $somma
}

calcoloennesimi () {
sommapunteggistudenti=$1
punteggiomax=$2
ennesimimax=$3
par=$(echo "scale=1; $sommapunteggistudenti*$ennesimimax" | bc)
ennesimi=$(echo "scale=1; $par/$punteggiomax" | bc)
echo $ennesimi
}

sommapunteggifinale () {
a=$1
b=$2
s=$(echo "scale=1; $a+$b" | bc)
echo $s
}

leggipunteggioautovalutazione () {
profe=$1
fileautovalutazione=$2
if cat $fileautovalutazione | grep -q $profe
  then cat $fileautovalutazione | grep $profe |  cut -f 2 -d"|"
	else echo 0
fi
}

arrotonda () {
a=$1
v=$(echo "scale=1; $a+0.500" | bc)
s=${v/\.*/}
echo $s
}

stampaspiegazione () {
	echo "</br>" >> $wdir/stampata.html

	echo "<h2>Questionario proposto agli studenti</h2>" >> $wdir/stampata.html
	#echo "</br>" >> $wdir/stampata.html

	echo "<p><sup>(1)</sup>: Per ogni domanda gli studenti hanno avuto la possibilit&agrave; di scegliere una tra le seguenti riposte:" >> $wdir/stampata.html
	echo "</br>- completamente in disaccordo, corrispondente al punteggio 0" >> $wdir/stampata.html
	echo "</br>- in disaccordo, corrispondente al punteggio 1" >> $wdir/stampata.html
	echo "</br>- d&rsquo;accordo, corrispondente al punteggio 2" >> $wdir/stampata.html
	echo "</br>- completamente d&rsquo;accordo, corrispondente al punteggio 3</p>" >> $wdir/stampata.html
	#echo "</br>" >> $wdir/stampata.html
	echo "<p><sup>(2)</sup>: Il valore al docente per ogni domanda &egrave; stato calcolato effettuando la media tra i valori che gli hanno attribuito tutti gli studenti delle sue classi su quella domanda</p>" >> $wdir/stampata.html
	#echo "</br>" >> $wdir/stampata.html
	echo "<p><sup>(3)</sup>: &Egrave; un valore di confronto ed &egrave; Il valore attribuito alla classe per ogni domanda: calcolato effettuando la media tra i valori ottenuti da tutti i docenti di quella classe su quella domanda</p>" >> $wdir/stampata.html
	#echo "</br>" >> $wdir/stampata.html
	echo "<p><sup>(4)</sup>: &Egrave; un valore di confronto ed &egrave; Il valore d&rsquo;Istituto ottenuto calcolando la media tra i valori ottenuti da tutti i docenti da parte di tutti gli studenti dell&rsquo;istituto su quella domanda</p>" >> $wdir/stampata.html
	#echo "</br>" >> $wdir/stampata.html
}

stampatabellona () {
filedelleclassi=$1
	echo "<table style="width:100%">" >> $wdir/stampata.html
	echo "  <tr>" >> $wdir/stampata.html
	echo "    <th>Domande <sup>(1)</sup></th>" >> $wdir/stampata.html
	echo "    <th>Media dell&rsquo;insegnante <sup>(2)</sup></th>" >> $wdir/stampata.html
	echo "    <th>Media di Istituto <sup>(4)</sup></th>" >> $wdir/stampata.html
		while read classedelprof; do
			if [ $isriservato -eq 1 ]; then
			echo "    <th>Media dell&rsquo;insegnante per la classe $classedelprof</th>" >> $wdir/stampata.html
			fi
		echo "    <th>Media del CdC della classe $classedelprof <sup>(3)</sup></th>" >> $wdir/stampata.html
	done < $filedelleclassi
	echo "  </tr>" >> $wdir/stampata.html

	echo ""
	echo "Docente: $profe"
	echo ""

	#if iscoordinatore $profe $profe; then
	#let numtotdomande=numtotdomande+1
	#fi

	k=1
		while [ $k -le $numtotdomande ]; do
	#	while [ $k -le 1 ]; do
		echo "  <tr>" >> $wdir/stampata.html
			if [ $domandeintabella -eq 1 ]; then
			echo "    <td>" >> $wdir/stampata.html
				eval echo \$dom${k} >> $wdir/stampata.html
			echo "</td>" >> $wdir/stampata.html
			fi
			if [ $domandeintabella -eq 0 ]; then
			echo "    <td>D $k</td>" >> $wdir/stampata.html
			fi
		# Media del prof
		r=$(mediaclasse $profe $k)
		echo "Media prof $profe Domanda $k: $r"
		echo "    <td align="center"><b>$r</b></td>" >> $wdir/stampata.html
		# Benchmark media istituto
		r=$(mediadomande $k)
		echo "Media Istituto Domanda $k:    $r"
		echo "    <td align="center">$r</td>" >> $wdir/stampata.html
	#	t=2
			while read classedelprof; do
				if [ $isriservato -eq 1 ]; then
				r=$(mediaprofeclasse $profe $classedelprof $k)
				echo "Media di $profe della classe $classedelprof per la Domanda $k: $r"
				echo "    <td align="center"><b>$r</b></td>" >> $wdir/stampata.html
	#			let t=t+2
	#				if iscoordinatore $profe $classedelprof; then
	#					if [ $k -eq 17 ]; then
	#					r=$(mediaprofeclasse $profe $classedelprof 17)
	#					echo "Media di $profe della classe $classedelprof per la Domanda 17: $r"
	#					fi
	#				fi
				fi
			r=$(mediaclasse $classedelprof $k)
			echo "Media del CdC della classe $classedelprof per la Domanda $k: $r"
			echo "    <td align="center">$r</td>" >> $wdir/stampata.html
		done < $filedelleclassi


		let k=k+1
		echo "  </tr>" >> $wdir/stampata.html
		done

	echo "</table>" >> $wdir/stampata.html
	echo "</br>" >> $wdir/stampata.html
}

stampatabellina () {
## Funzione da eseguire solo dopo il calcolo di tutte le variabili!!
sommapunteggistudenti=$1
puntennesimi=$2
puntautovalutazione=$3
totalone=$4

	echo "<table class="risultati" style="width:100%">" >> $wdir/stampata.html
  	echo "<tr>" >> $wdir/stampata.html
    	echo "<td></td>" >> $wdir/stampata.html
    	echo "<td><b>Media dell' Insegnante</b></td> " >> $wdir/stampata.html
    	echo "<td><b>Media di Istituto</b></td>" >> $wdir/stampata.html
  	echo "</tr>" >> $wdir/stampata.html
  	echo "<tr>" >> $wdir/stampata.html
    	echo "<td>Totale punteggio questionario studenti (sul massimo di 57 punti)</td>" >> $wdir/stampata.html
    	echo "<td>$sommapunteggistudenti</td> " >> $wdir/stampata.html
    	echo "<td>$mediaistituto</td>" >> $wdir/stampata.html
  	echo "</tr>" >> $wdir/stampata.html
## Elimino il punteggio di autovalutazione e la conversione in Ennesimi. E pertanto anche il totale. Quest'anno AS 2020-21 non servono.
#  	echo "<tr>" >> $wdir/stampata.html
#    	echo "<td>Totale punteggio questionario studenti (in $ennesimimassimitestuali, arrotondato)</td>" >> $wdir/stampata.html
#    	echo "<td>$puntennesimi</td>" >> $wdir/stampata.html
#    	echo "<td>$mediaennesimi</td>" >> $wdir/stampata.html
#  	echo "</tr>" >> $wdir/stampata.html
#  	echo "<tr>" >> $wdir/stampata.html
#    	echo "<td>Totale punteggio questionario autovalutazione</td>" >> $wdir/stampata.html
#    	echo "<td>$puntautovalutazione</td>" >> $wdir/stampata.html
#    	echo "<td>$mediaautovalutazione</td>" >> $wdir/stampata.html
#  	echo "</tr>" >> $wdir/stampata.html
#  	echo "<tr>" >> $wdir/stampata.html
#    	echo "<td><b>TOTALE COMPLESSIVO</b></td>" >> $wdir/stampata.html
#    	echo "<td><b>$totalone</b></td>" >> $wdir/stampata.html
#    	echo "<td><b>$mediatotale</b></td>" >> $wdir/stampata.html
#  	echo "</tr>" >> $wdir/stampata.html
	echo "</table>" >> $wdir/stampata.html

}

### WORK IN PROGRESS ####
## Calcolo anche le medie per le classi, a partire dai profe

## CAPIRE:
## 1 Come sviluppare il ciclo: lavoro per classi o per docente?
## 2 individuare i valori che mi servono
## 3 vedere quali funzioni posso già sfruttare (cfr. mediaclasse() )

#rm -f $wdir/medieclassi.csv
#touch $wdir/medieclassi.csv
#while read profe; do
##while read classe; do
#sommapunteggistudenti=$(sommapunteggidomande $profe $numdomandemedia)
#sommapunteggistudentiro=$(arrotonda $sommapunteggistudenti)
#	#Conversione in 40esimi
#puntennesimi=$(calcoloennesimi $sommapunteggistudenti $punteggiomassimostudenti $ennesimimassimi)
#puntennesimiro=$(arrotonda $puntennesimi)
#
#puntautovalutazione=$(leggipunteggioautovalutazione $profe $fileautovalutazione)
#
#totalone=$(sommapunteggifinale $puntennesimi $puntautovalutazione)
#totalonero=$(arrotonda $totalone)
#
#echo "$profe;$sommapunteggistudenti" >> $wdir/medieclassi.csv
#
##done < $wdir/listaprof.txt
#done < $wdir/monoprof.txt
##done < $wdir/listaclassi.txt
#########

while read profe; do
classidelprof $profe
dividiclassiprofe $profe
## Genero l'HTML
echo "<!DOCTYPE html>" > $wdir/stampata.html
echo "<html>" >> $wdir/stampata.html
echo "<head>" >> $wdir/stampata.html
echo "<style>" >> $wdir/stampata.html
echo "table, th, td {" >> $wdir/stampata.html
echo "    border: 2px solid black;" >> $wdir/stampata.html
echo "    border-collapse: collapse;" >> $wdir/stampata.html
echo "  font-size: 14pt;" >> $wdir/stampata.html
echo "}" >> $wdir/stampata.html
echo "table.risultati, table.risultati th, table.risultati td{" >> $wdir/stampata.html
echo "    border: 2px solid black;" >> $wdir/stampata.html
echo "    border-collapse: collapse;" >> $wdir/stampata.html
echo "  font-size: 20pt;" >> $wdir/stampata.html
echo "}" >> $wdir/stampata.html
echo ".pagebreak { page-break-before: always; }" >> $wdir/stampata.html
## In realtà footerleft/right non funziona perchè sarebbe non una pagina A4... Eliminabile
#echo ".footerleft {" >> $wdir/stampata.html
#echo "  position: relative;" >> $wdir/stampata.html
#echo "  right: 0;" >> $wdir/stampata.html
#echo "  bottom: 0;" >> $wdir/stampata.html
#echo "  left: 0;" >> $wdir/stampata.html
#echo "  padding: 1rem;" >> $wdir/stampata.html
#echo "  text-align: left;" >> $wdir/stampata.html
#echo "}" >> $wdir/stampata.html
#echo ".footerright {" >> $wdir/stampata.html
#echo "  position: absolute;" >> $wdir/stampata.html
#echo "  right: 0;" >> $wdir/stampata.html
#echo "  bottom: 0;" >> $wdir/stampata.html
#echo "  left: 0;" >> $wdir/stampata.html
#echo "  padding: 1rem;" >> $wdir/stampata.html
#echo "  text-align: right;" >> $wdir/stampata.html
#echo "}" >> $wdir/stampata.html
echo "  p {" >> $wdir/stampata.html
echo "  font-size: 18pt;" >> $wdir/stampata.html
echo "  }" >> $wdir/stampata.html
echo "</style>" >> $wdir/stampata.html
echo "</head>" >> $wdir/stampata.html
echo "<body>" >> $wdir/stampata.html
echo "<div align="center"><img src="./intestazione.png"></div>" >> $wdir/stampata.html
echo "<h2>Docente: $profe</h2>" >> $wdir/stampata.html
echo "<h2>Scheda personale di valutazione del docente</h2>" >> $wdir/stampata.html
echo "<h3>Ai fini dell'erogazione del bonus di premialit&agrave; dei docenti A.S. 2020/21</h3>" >> $wdir/stampata.html
echo "</br>" >> $wdir/stampata.html

### INIZIO TABELLA
stampatabellona $wdir/classi_di_$profe.txt

stampaspiegazione

	if [ $domandeintabella -eq 0 ]; then
	echo "<p style="font-size:24px">" >> $wdir/stampata.html
	echo "$dom1">> $wdir/stampata.html
	echo "$dom2">> $wdir/stampata.html
	echo "$dom3">> $wdir/stampata.html
	echo "$dom4">> $wdir/stampata.html
	echo "$dom5">> $wdir/stampata.html
	echo "$dom6">> $wdir/stampata.html
	echo "$dom7">> $wdir/stampata.html
	echo "$dom8">> $wdir/stampata.html
	echo "$dom9">> $wdir/stampata.html
	echo "$dom10">> $wdir/stampata.html
	echo "$dom11">> $wdir/stampata.html
	echo "$dom12">> $wdir/stampata.html
	echo "$dom13">> $wdir/stampata.html
	echo "$dom14">> $wdir/stampata.html
	echo "$dom15">> $wdir/stampata.html
	echo "$dom16">> $wdir/stampata.html
	echo "$dom17">> $wdir/stampata.html
	echo "$dom18">> $wdir/stampata.html
	echo "$dom19">> $wdir/stampata.html
	echo "</p>" >> $wdir/stampata.html
	fi

numpagina=1
numtabella=1
if [ -f $wdir/classi_di_$profe-2.txt ]; then
echo "<div class="footerleft"><p><i>Prosegue nella pagina successiva</i></p></div>" >> $wdir/stampata.html
#echo "<div class="footerright"><p>Pagina 1</p></div>" >> $wdir/stampata.html
echo "<div class="pagebreak"> </div>" >> $wdir/stampata.html
#echo "<div class="footerright"><p>Pagina 2</p></div>" >> $wdir/stampata.html
stampatabellona $wdir/classi_di_$profe-2.txt
numpagina=2
numtabella=2
fi
if [ -f $wdir/classi_di_$profe-3.txt ]; then
stampatabellona $wdir/classi_di_$profe-3.txt
numtabella=3
fi
if [ -f $wdir/classi_di_$profe-4.txt ]; then
##qua##echo "<div class="footerleft"><p><i>Prosegue nella pagina successiva</i></p></div>" >> $wdir/stampata.html
echo "<div class="pagebreak"> </div>" >> $wdir/stampata.html
stampatabellona $wdir/classi_di_$profe-4.txt
numpagina=3
numtabella=4
#echo "<div class="footerright"><p>Pagina 3</p></div>" >> $wdir/stampata.html
fi
if [ -f $wdir/classi_di_$profe-5.txt ]; then
stampatabellona $wdir/classi_di_$profe-5.txt
numpagina=3
numtabella=5
#echo "<div class="footerright"><p>Pagina 3</p></div>" >> $wdir/stampata.html
fi
if [ -f $wdir/classi_di_$profe-6.txt ]; then
##qua##echo "<div class="footerleft"><p><i>Prosegue nella pagina successiva</i></p></div>" >> $wdir/stampata.html
echo "<div class="pagebreak"> </div>" >> $wdir/stampata.html
stampatabellona $wdir/classi_di_$profe-6.txt
numpagina=4
numtabella=6
#echo "<div class="footerright"><p>Pagina 3</p></div>" >> $wdir/stampata.html
fi

#### QUA INIZIA LA SECONDA PAGINA PER IL DOCENTE: IL RIASSUNTO DELLE VALUTAZIONI #####

	if [ $secondapagina -eq 1 ]; then
		if [ $numtabella -eq 1 ] || [ $numtabella -eq 3 ]  || [ $numtabella -eq 5 ]; then
		##qua##if [ $numtabella -eq 1 ]; then
		### echo "<div class="pagebreak"> </div>" >> $wdir/stampata.html  ### Tolgo la pagina nuova, non serve per la stampa AS 2020-21
		echo "</br>" >> $wdir/stampata.html
		echo "</br>" >> $wdir/stampata.html
		#echo "<div align="center"><img src="./intestazione.png"></div>" >> $wdir/stampata.html
		echo "<h2>Risultati finali per il docente: $profe</h2>" >> $wdir/stampata.html
		fi
	echo "</br>" >> $wdir/stampata.html
	echo "</br>" >> $wdir/stampata.html
	#echo "<h2>Risultati finali</h2>" >> $wdir/stampata.html

	#somma risposte medie prof domande 1-16
	#Somma convertita in quarantesimi (max punteggio 48; p:48=x:40;; x=(p*40)/48 ) || Non sarebbe male inserire il punteggio max e gli ennesimi come variabile
	#punteggio di autovalutazione (da file csv esterno)
	#TOT:40imi+autovalutazione

	# Non devo eseguire ulteriori cicli while per leggere il nome del prof, ci sono già dentro (var $profe)
	# Per realizzare la tabella, stampo l'intestazione e la prima riga fuori ciclo:

	# Quindi mi faccio i miei dovuti calcoli:
	sommapunteggistudenti=$(sommapunteggidomande $profe $numdomandemedia)
	sommapunteggistudentiro=$(arrotonda $sommapunteggistudenti)
		#Conversione in 40esimi
	puntennesimi=$(calcoloennesimi $sommapunteggistudenti $punteggiomassimostudenti $ennesimimassimi)
	puntennesimiro=$(arrotonda $puntennesimi)
	puntautovalutazione=$(leggipunteggioautovalutazione $profe $fileautovalutazione)
	totalone=$(sommapunteggifinale $puntennesimi $puntautovalutazione)
	totalonero=$(arrotonda $totalone)

	### QUA VA LA TABELLA COI RISULTATI ####
	stampatabellina $sommapunteggistudenti $puntennesimiro $puntautovalutazione $totalonero

	#echo "</br>" >> $wdir/stampata.html
	#echo "<p>L'insegnante $profe ha conseguito, dal questionario somministrato ai propri studenti, un punteggio totale di $sommapunteggistudentiro" >> $wdir/stampata.html
	#echo "</br>Il punteggio totalizzato &egrave; dato dalla somma della media delle $numdomandemedia domande (colonna 2)</p>" >> $wdir/stampata.html
	#echo "<p>Il suddetto punteggio &egrave; convertito in $ennesimimassimitestuali: $puntennesimiro</p>" >> $wdir/stampata.html
	#echo "<p>Inoltre, il punteggio estratto dal questionario di autovalutazione e validato dal Dirigente Scolastico risulta essere $puntautovalutazione</p>" >> $wdir/stampata.html
	#echo "<h2><b>La somma dei punteggi in $ennesimimassimitestuali e del questionario di autovalutazione &egrave; pari a: $totalonero</b></h2>" >> $wdir/stampata.html

	#Infine, per comodità del preside, realizzo un file CSV coi punteggi finali:
	if [ $scrivirisultatifinali -eq 1 ]; then
	echo "$profe;$sommapunteggistudenti;$puntennesimi;$puntautovalutazione;$totalone" >> $csvds
	fi

	# Eseguo la stampata delle righe successive e chiudo la tabella


	fi
echo "</body>" >> $wdir/stampata.html
echo "</html>" >> $wdir/stampata.html
wkhtmltopdf $wdir/stampata.html $risdir/$profe.pdf
rm $wdir/stampata.html
echo ""
done < $wdir/listaprof.txt
#done < $wdir/monoprof.txt

if [ $scrivirisultatifinali -eq 1 ]; then
sed -i 's/\./,/g' $csvds
fi

#rm $wdir/listaclassi.txt
#rm $wdir/listaprof.txt
