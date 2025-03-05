#!/bin/bash

palabra1=$1
numeroColumna=-1
CSV_NOM=$2

#Buenos dias 

function numeroColumna(){
	nombre_buscar=$1
	NOM_COLUMNAS=$(cat $CSV_NOM | head -n1 | sed 's/,/ /g')
	CNT=1
 	for NOMBRE in $NOM_COLUMNAS
  	do
   		if [[ $NOMBRE == $nombre_buscar ]]
     		then
     			numeroColumna=$((CNT))
		else
  			((CNT++))
  		fi
   	done
}


if [[ "${palabra1,,}" == "-help" ]]; then
	echo "The use is ./filtro.sh [filterName] [argument]"
	echo "The filters implemented are:"
	echo "-help"
 	echo "-columnNames [CSV FILE]
  		Show all valid column names"
    	echo "-columnValues [CSV FILE] [columnName]
     		Show all the different values that appear in the specified column"
	echo "-columnStats [CSV FILE] [columnName]
		Show the number of occurances of each value in the column"
	echo "-mostFrequentValue [CSV FILE] [columnName]
		Show the value that appear with most frequency in the column" 
	echo "-filterColumn [CSV FILE] [columnName]
		Show the records of a column"
	echo "-filterColumnValue [CSV FILE] [columnName] [nValues] [value1] [value2] ... [valueN] 
		Show all complete records with the indicated values in the column"
	echo "-filterDate [beginingDate] [endDate]
		Shows all complete records between beginingDate and endDate if endDate is not 
		indicated, it will show every record since beginingDate"
	echo "-filterTime [beginingTime] [endTime]
		Shows all complete records between beginingTime and endTime if endTime is not 
		indicated, it will show every record since beginingTime until midnight."
   	echo "-filterNColumnValues [CSV FILE] [nColunm] [column1] [value1] ... [columnN] [valueN]
		Show all complete record that contains the n indicated values in the specified columns"

elif [[ "${palabra1,,}" == "-columnnames" ]]
	then
	if [[ "$2" != *.csv ]]
	then
 		echo "Second parameter must be a CSV file"
   		exit 1
   	fi
 	cat $CSV_NOM | head -n1 | sed 's/,/ /g'

elif [[ "${palabra1,,}" == "-columnvalues" ]]
	then
 	if [[ -z $2 || -z $3 ]]
  	then
  		echo "The use of -columnValues requires 2 parameters"
		exit 1
 	elif [[ "$2" != *.csv ]]
	then
 		echo "Second parameter must be a CSV file"
   		exit 1
   	fi
 	
 	nombreColumna=$3
  	numeroColumna $nombreColumna
 	cat $CSV_NOM | awk -F "," -v col="$numeroColumna" 'NR>1{print $col}' | sort -u

elif [[ "${palabra1,,}" == "-filtercolumn" ]] 
	then
 	if [[ -z $2 || -z $3 ]]
  	then
  		echo "The use of -filterColumn requires 2 parameters"
		exit 1
 	elif [[ "$2" != *.csv ]]
	then
 		echo "Second parameter must be a CSV file"
   		exit 1
   	fi
    
	nombreColumna=$3
	numeroColumna $nombreColumna
	cat $CSV_NOM  | awk -F "," -v col="$numeroColumna" 'NR>1{print $col}'

elif [[ "${palabra1,,}" == "-columnstats" ]]
	then
 	if [[ -z $2 || -z $3 ]]
  	then
  		echo "The use of -columnStats requires 2 parameters"
		exit 1
 	elif [[ "$2" != *.csv ]]
	then
 		echo "Second parameter must be a CSV file"
   		exit 1
   	fi
    
	nombreColumna=$3
  	numeroColumna $nombreColumna
	cat $CSV_NOM | awk -F',' -v col="$numeroColumna" 'NR>1{print $col}' | sort | uniq -c | sort -nr
	
elif [[ "${palabra1,,}" == "-mostfrequentvalue" ]]
	then
 	if [[ -z $2 || -z $3 ]]
  	then
  		echo "The use of -mostFrequentValue requires 2 parameters"
		exit 1
 	elif [[ "$2" != *.csv ]]
	then
 		echo "Second parameter must be a CSV file"
   		exit 1
   	fi

 	nombreColumna=$3
  	numeroColumna $nombreColumna
	cat $CSV_NOM | awk -F',' -v col="$numeroColumna" 'NR>1{print $col}' | sort | uniq -c | sort -nr | head -n1 
 
elif [[ "${palabra1,,}" == "-filtercolumnvalue" ]]
	then
	if [[ -z $2 || -z $3 || -z $4 || -z $5 ]]
	then
		echo "The use of -filterColumnValue requires at least 4 parameters"
		exit 1
 	elif [[ "$2" != *.csv ]]
	then
 		echo "Second parameter must be a CSV file"
   		exit 1
	elif [[ ! "$4" =~ ^[0-9]+$ ]]
	then
		echo "The fourth parameter introduced must be the number of values you introduced"
		exit 1
		
	fi
 
	nombreColumna=$3
	numeroColumna $nombreColumna
	numeroParametros=$4

 	CONT=1
  	while [ $CONT -le $numeroParametros ]
   	do
		num=$((CONT+4))
		valor=${!num}
		
		cat $CSV_NOM | awk -F "," -v nCol="$numeroColumna" -v bien="$valor" 'NR>1{
				
				if ($nCol == bien) {
					print $0;
				}
		}'

		((CONT++))
  	done
  
elif [[ "${palabra1,,}" == "-filterdate" ]]
	then
	if [[ -z $2 || -z $3 ]]
		then
			echo "The use of -filterDate requires at least 2 parameter"
			exit 1
			break
   	elif [[ "$2" != *.csv ]]
	then
 		echo "Second parameter must be a CSV file"
   		exit 1
	fi
	if [[ -z $4 ]]
		then
			
			cat $CSV_NOM | awk -F "," -v fechaIni="$3" 'NR>1{
				split($3, fecha, "T");
				if (fecha[1] >= fechaIni) {
					print $0;
					
				}
			}'

	else 
		cat $CSV_NOM | awk -F "," -v fechaIni="$3" -v fechaFin="$4" 'NR>1{
				split($3, fecha, "T");
				if (fecha[1] >= fechaIni && fecha[1] <= fechaFin) {
					print $0;
					
				}
			}'
	fi
 
elif [[ "${palabra1,,}" == "-filtertime" ]]
	then 
		if [[ -z $2 || -z $3 ]]
			then
				echo "The use of -filterTime requires at least 2 parameter"
				exit 1
				break
    		elif [[ "$2" != *.csv ]]
			then
 			echo "Second parameter must be a CSV file"
   			exit 1
		fi
		if [[ -z $4 ]]
		then
			
			cat $CSV_NOM | awk -F "," -v timeIni="$3" 'NR>1{
				split($3, time, "T");
				if (time[2] >= timeIni) {
					print $0;
					
				}
			}' 

	else
		
		cat $CSV_NOM | awk -F "," -v timeIni="$3" -v timeFin="$4" 'NR>1{
				split($3, time, "T");
				if (time[2] >= timeIni && time[2] <= timeFin) {
					print $0;
					
				}
			}'
	fi


elif [[ "${palabra1,,}" == "-filterncolumnvalues" ]]
	then
	if [[ -z $2 || -z $3 || -z $4 || -z $5 ]]
	then
		echo "The use of -filterNColumnValues requires at least 4 parameters"
		exit 1
 	elif [[ "$2" != *.csv ]]
	then
 		echo "Second parameter must be a CSV file"
   		exit 1
	elif [[ ! "$3" =~ ^[0-9]+$ ]]
	then
		echo "The third parameter introduced must be the number of values you introduced"
		exit 1
	fi
		
	num=$3
	PUNTERO=4
	IT=0
	cat $CSV_NOM | awk 'NR>1' > help.txt
	while [ $IT -lt $num ]
	do
		columna=${!PUNTERO}
		if [[ ! "$columna" =~ ^[a-zA-Z]+$ ]]
			then
				echo "The value of $columna is not a string"
				exit 1
		fi
  
		numeroColumna $columna
		((PUNTERO++))
		valor=${!PUNTERO}
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
	echo "Filter not found. Use -help to see the options"
	exit 1
fi

exit 0
