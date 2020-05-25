#!/bin/bash

getData() {
	curl -# https://api.exchangeratesapi.io/latest
}

sortData() {
	getData > temp.txt
	cat temp.txt | cut -c 11-427 > Data.txt
	rm temp.txt
	IFS=',' read -ra VALUES < Data.txt
	C=`expr ${#VALUES}+1`
	VALUES[C]="EUR":1.000
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
	while getopts 'f:t:a:hl' option
	do
		case "$option" in
			h)
		   	echo "A programot a kovetkezokeppen tudja hasznalni:"
			echo "./MoneyExchange.sh -f [FROM] -t [TO]: atvalt [FROM] penznembol 1-et [TO] penznemre"
			echo "./MoneyExchange.sh -f [FROM] -t [TO] -a [AMOUNT]: atvalt [FROM] penznembol [AMOUNT]-ot [TO] penznemre"
			echo "A [FROM] es a [TO] koze a valutak ISO 4217 kodja kell (pl.: magyar forint = HUF)"
			echo "Az atvalthato valutak listajat elerheti a -l opcioval"
			exit
		   	;;
			l)
			sortData
			cat Data.txt
			rm Data.txt
			exit
			;;
			f) F=${OPTARG}
		   	;;
			t) T=${OPTARG}
		   	;;
			a) A=${OPTARG}
			;;
		esac
	done
	if [ "$F" != "" ] ; then
		if [ "$T" != "" ] ; then
			if [ "$A" != "" ] ; then
				exchange "$F" "$T" "$A"
				RESULT="$NUM"
				echo "$A" "$F" "=" "$RESULT" "$T"
			else
				exchange "$F" "$T"
				RESULT="$NUM"
				echo "1" "$F" "=" "$RESULT" "$T"
			fi
		fi
	fi
fi
if [ -f Data.txt ] ; then
	rm Data.txt
fi
