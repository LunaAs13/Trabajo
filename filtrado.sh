#!/bin/bash

palabra1=$1
numeroColumna=-1

function numeroColumna(){
	nombre=$1
	case "$nombre" in
		"date")
			numeroColumna=3
			;;
		"problem")
			numeroColumna=4
			;;
		"personSearch")
			numeroColumna=7
			;;
		"vehicleSearch")
			numeroColumna=8
			;;
		"race")
			numeroColumna=10
			;;
		"gender")
			numeroColumna=11
			;;
		"neighborhood")
			numeroColumna=15
			;;
		*)
			echo "error no valid column"
			;;
esac

}


if [[ "${palabra1,,}" == "-help" ]]; then	
	echo "The use is ./filtro.sh [argument]"
	echo "Te argument implemented are:"
	echo "-help"
	echo "-filterColumn columnName 	; Show the records of a column"
	echo "-filterColumnValue columnName value	; Show all complete records with the infdicated values in the column"
	echo "-filterDate beginingDate endDate	; Shows all complete records between beginingDate and endDate if endDate is not 
			indicated, it will show every record since beginingDate"
	echo "-filterTime beginingTime endTime ; Shows all complete records between beginingTime and endTime if endTime is not 
			indicated, it will show every record since beginingTime until midnight."
	

elif [[ "${palabra1,,}" == "-filtercolumn" ]] 
	then
	if [[ -z $2 ]]
	then
		echo "Specify the column name"
		break
	fi
	nombreColumna=$2
	numeroColumna $nombreColumna
	#cat MplsStops.csv | sed 's/,/ /g' | awk '{print \$$numeroColumna}'
	cat MplsStops.csv  | awk -F "," -v col="$numeroColumna" 'NR>1{print $col}'
elif [[ "${palabra1,,}" == "-filtercolumnvalue" ]]
	then
	if [[ -z $2 || -z $3 ]]
	then
		echo "The use of -filterColumnValue requires 2 parameters"
		break
	fi
	nombreColumna=$2
	numeroColumna $nombreColumna

	cat MplsStops.csv | awk -F "," -v nCol="$numeroColumna" -v valor="$3" 'NR>1{
			split(valor, valores, "/");
	
			for(i=1; i <= length(valores); i++) {
				if ($nCol == valores[i]) {
					print $0;
				}
			}
			
		}'
elif [[ "${palabra1,,}" == "-filterdate" ]]
	then
	if [[ -z $2 ]]
		then
			echo "The use of -filterDatee requires at least 1 parameter"
			break
	fi


	if [[ -z $3 ]]
		then
			
			cat MplsStops.csv | awk -F "," -v fechaIni="$2" 'NR>1{
				split($3, fecha, "T");
				if (fecha[1] >= fechaIni) {
					print $0;
					
				}
			}'

	else 
		cat MplsStops.csv | awk -F "," -v fechaIni="$2" -v fechaFin="$3" 'NR>1{
				split($3, fecha, "T");
				if (fecha[1] >= fechaIni && fecha[1] <= fechaFin) {
					print $0;
					
				}
			}'
	fi
elif [[ "${palabra1,,}" == "-filtertime" ]]
	then 
		if [[ -z $2 ]]
			then
				echo "The use of -filterDatee requires at least 1 parameter"
				break
		fi

		if [[ -z $3 ]]
		then
			
			cat MplsStops.csv | awk -F "," -v timeIni="$2" 'NR>1{
				split($3, time, "T");
				if (time[2] >= timeIni) {
					print $0;
					
				}
			}' 

	else 
		cat MplsStops.csv | awk -F "," -v timeIni="$2" -v timeFin="$3" 'NR>1{
				split($3, time, "T");
				if (time[2] >= timeIni && time[2] <= timeFin) {
					print $0;
					
				}
			}'
	fi

else
	echo "Argument not found. Use -help to see the options"
fi


