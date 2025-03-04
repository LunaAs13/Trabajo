#!/bin/bash

#POSIBLES IMPLEMENTACIONES AÑADIDAS: caso mas comun en columna, numero de veces que aparece valor en columna, posibles valores de columna

palabra1=$1
numeroColumna=-1

#Buenos dias 

function numeroColumna(){
	nombre=$1
	case "$nombre" in
		"rownames")
			numeroColumna=1
			;;
		"idNum")
			numeroColumna=2
			;;
		"date")
			numeroColumna=3
			;;
		"problem")
			numeroColumna=4
			;;
		"MDC")
			numeroColumna=5
			;;
		"citationIssued")
			numeroColumna=6
			;;
		"personSearch")
			numeroColumna=7
			;;
		"vehicleSearch")
			numeroColumna=8
			;;
		"preRace")
			numeroColumna=9
			;;
		"race")
			numeroColumna=10
			;;
		"gender")
			numeroColumna=11
			;;
		"lat")
			numeroColumna=12
			;;
		"long")
			numeroColumna=13
			;;
		"policePrecinct")
			numeroColumna=14
			;;
		"neighborhood")
			numeroColumna=15
			;;
		*)
			echo "error no valid column"
			exit 1
			;;
esac

}


if [[ "${palabra1,,}" == "-help" ]]; then	
	echo "The use is ./filtro.sh [filterName] [argument]"
	echo "The filters implemented are:"
	echo "-help"
 	echo "-columnNames
  		Show all valid column names"
    echo "-columnValues [columnName]
    	Show all the different values that appear in the specified column"
	echo "columnStats [columnName]
		Show the number of occurances of each value in the column"
	echo "-mostFrequenceValue [columnName]
		Show the value that appear with most frequency in the column" 
	echo "-filterColumn [columnName]
		Show the records of a column"
	echo "-filterColumnValue [columnName] [nValues] [value1] [value2] ... [valueN] 
		Show all complete records with the indicated values in the column"
	echo "-filterDate [beginingDate] [endDate]
		Shows all complete records between beginingDate and endDate if endDate is not 
		indicated, it will show every record since beginingDate"
	echo "-filterTime [beginingTime] [endTime]
		Shows all complete records between beginingTime and endTime if endTime is not 
		indicated, it will show every record since beginingTime until midnight."
   	echo "-filterNColumnValues [nColunm] [column1] [value1] ... [columnN] [valueN]
		Show all complete record that contains the n indicated values in the specified columns"

elif [[ "${palabra1,,}" == "-columnnames" ]]
	then
 	cat MplsStops.csv | head -n1 | sed 's/,/ /g' | sed -E 's/^[^[:space:]]+[[:space:]]*//'

elif [[ "${palabra1,,}" == "-columnvalues" ]]
	then
 	if [[ -z $2 ]]
  	then
  		echo "Specify the column name"
		exit 1
    	break
    fi
 	nombreColumna=$2
  	numeroColumna $nombreColumna
 	cat MplsStops.csv | awk -F "," -v col="$numeroColumna" 'NR>1{print $col}' | sort -u

elif [[ "${palabra1,,}" == "-columnstats" ]]
	then
		if [[ -z $2 ]]
  		then
			echo "Specify the column name"
			exit 1
			break
    	fi
		nombreColumna=$2
  		numeroColumna $nombreColumna
		cat MplsStops.csv | awk -F',' -v col="$numeroColumna" 'NR>1{print $col}' | sort | uniq -c | sort -nr
	
elif [[ "${palabra1,,}" == "-mostfrequencevalue" ]]
	then 
	if [[ -z $2 ]]
  		then
			echo "Specify the column name"
			exit 1
			break
    	fi
		nombreColumna=$2
  		numeroColumna $nombreColumna
		cat MplsStops.csv | awk -F',' -v col="$numeroColumna" 'NR>1{print $col}' | sort | uniq -c | sort -nr | head -n1 
elif [[ "${palabra1,,}" == "-filtercolumn" ]] 
	then
	if [[ -z $2 ]]
	then
		echo "Specify the column name"
		exit 1
		break
	fi
	nombreColumna=$2
	numeroColumna $nombreColumna
	cat MplsStops.csv  | awk -F "," -v col="$numeroColumna" 'NR>1{print $col}'
 
elif [[ "${palabra1,,}" == "-filtercolumnvalue" ]]
	then
	if [[ -z $2 || -z $3 || -z $4 ]]
	then
		echo "The use of -filterColumnValue requires 3 parameters"
		exit 1
		break
	fi

	if [[ ! "$3" =~ ^[0-9]+$ ]]
	then
		echo "The second parameter introduced must be the number of values you introduced"
		
	fi
 
	nombreColumna=$2
	numeroColumna $nombreColumna
	numeroParametros=$3

 	CONT=1
  	while [ $CONT -le $numeroParametros ]
   	do
		num=$((CONT+3))
		valor=${!num}

		if [[ ! "$valor" =~ ^[a-zA-Z]+$ ]]
		then
			echo "The value of $valor is not a string"
			exit 1
		fi
		
		cat MplsStops.csv | awk -F "," -v nCol="$numeroColumna" -v bien="$valor" 'NR>1{
				if ($nCol == bien) {
					print $0;
				}
		}'

		((CONT++))
  	done
  
elif [[ "${palabra1,,}" == "-filterdate" ]]
	then
	if [[ -z $2 ]]
		then
			echo "The use of -filterDatee requires at least 1 parameter"
			exit 1
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
		if [[ ! "$3" =~ ^[a-zA-Z]+$ ]]
		then
			echo "The value of $3 is not a string"
			exit 1
		fi
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
				exit 1
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
		if [[ ! "$3" =~ ^[a-zA-Z]+$ ]]
			then
				echo "The value of $3 is not a string"
				exit 1
		fi
		cat MplsStops.csv | awk -F "," -v timeIni="$2" -v timeFin="$3" 'NR>1{
				split($3, time, "T");
				if (time[2] >= timeIni && time[2] <= timeFin) {
					print $0;
					
				}
			}'
	fi


elif [[ "${palabra1,,}" == "-filterncolumnvalues" ]]
	then
		echo ""
		if [[ -z $2 || -z $3 || -z $4 ]]
		then
				echo "The use of -filterncolumnvalues requires at least 3 parameters"
				exit 1
				break
		fi
		if [[ ! "$2" =~ ^[0-9]+$ ]]
	then
		echo "The first parameter introduced must be the number of values you introduced"
		exit 1
	fi
		
	num=$2
	PUNTERO=3
	IT=0
	#eliminar la linea de los nombres de la columna
	cat MplsStops.csv | awk 'NR>1' > help.txt
	while [ $IT -lt $num ]
	do
		#cat help.txt | wc -l
		columna=${!PUNTERO}
		if [[ ! "$columna" =~ ^[a-zA-Z]+$ ]]
			then
				echo "The value of $columna is not a string"
				exit 1
		fi
  
		numeroColumna $columna
		((PUNTERO++))
		valor=${!PUNTERO}
		if [[ ! "$valor" =~ ^[a-zA-Z]+$ ]]
			then
				echo "The value of $valor is not a string"
				exit 1
		fi

		((PUNTERO++))

		cat help.txt | awk -F "," -v nCol="$numeroColumna" -v bien="$valor" '{
				if ($nCol == bien) {
					print $0;
				}
		}' > help2.txt

		cat help2.txt > help.txt
		((IT++))
	done
 
	cat help.txt
	rm help2.txt
	rm help.txt

else
	echo "Argument not found. Use -help to see the options"
	exit 1
fi

exit 0



