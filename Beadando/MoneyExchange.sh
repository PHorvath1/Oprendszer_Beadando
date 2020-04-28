#!/bin/bash

getData() {
	curl -# https://api.exchangeratesapi.io/latest
}

sortData() {
	getData > temp.txt
	cat temp.txt | cut -c 11-427 > Data.txt
	rm temp.txt
	IFS=',' read -ra VALUES < Data.txt
	for i in "${VALUES[*]}"; do
		echo "$i" > Data.txt
	done
}

exchange() {
	sortData
	[ "$#" -eq 3 ] && AMOUNT="$3" || AMOUNT=1
	for (( i = 0; i < "${#VALUES[@]}"; i++ )) ;
	do
		if [ "$1" = "$(echo ${VALUES[i]} | cut -d : -f 1 | sed 's/\"//g')" ]; then
			for (( j = 0; j < "${#VALUES[@]}"; j++ )) ;
			do
				if [ "$2" = "$(echo ${VALUES[j]} | cut -d : -f 1 | sed 's/\"//g')" ]; then
					FROM=$(echo ${VALUES[i]} | cut -d : -f 2)
					TO=$(echo ${VALUES[j]} | cut -d : -f 2)
					NUM=$(echo "scale=4;($TO/$FROM)*$AMOUNT" | bc)
				fi
			done
		fi
	done
}
PARAMS="$#"
if [ "$PARAMS" -eq 0 ] ; then
	echo "A program mukodesehez segitseget kaphat a kovetkezokeppen: ./MoneyExchange.sh -h"
else
	case "$PARAMS" in
		1) if [ "$1" = "-h" ] ; then
		   	echo "A programot a kovetkezokeppen tudja hasznalni:"
			echo "./MoneyExchange.sh [FROM] [TO]: atvalt [FROM] penznembol 1-et [TO] penznemre"
			echo "./MoneyExchange.sh [FROM] [TO] [AMOUNT]: atvalt [FROM] penznembol [AMOUNT]-ot [TO] penznemre"
			echo "A [FROM] es a [TO] koze a valutak ISO 4217 kodja kell"
		   else
			echo "Nincs ilyen opcio!"
		   fi;;
		2) exchange "$1" "$2"
		   EREDMENY="$NUM"
		   echo "1 $1 = $EREDMENY $2"
		   ;;
		3) exchange "$1" "$2" "$3"
		   EREDMENY="$NUM"
		   echo "$3 $1 = $EREDMENY $2"
		   ;;
	esac
fi
rm Data.txt
