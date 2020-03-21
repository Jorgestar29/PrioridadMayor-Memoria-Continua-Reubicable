#!/bin/bash

global(){

#declaracion de variables

#TODO: Borrar cosas inexistentes.
declare opcionApropiativo
declare opcionEstatico


#Array con la cola | Empieza en 1, por lo que el valor 0 siempre se podrá saltar 
#(nota alumno 2020: Lo arrays empiezan siempre en 0, pero paso de cambiarlo, ten en cuenta que la mayoría de los arrays de esta práctica empiezan en 1, además igual en bash da problemas)
declare -a cola
declare -r numCol=5		#FIXME: Sin uso/referencia encontrada de momento (Estaba desde 2018), igual borrar
declare -i numProc=0

# Índice que almacena el proceso que está ejécutándose en CPU
declare -i procesoCPU=0


declare -i priorMin
declare -i priorMax			
	
declare -i tamCola=0
declare tipoPrioridad


#Según Necesidades (2020):
declare tamMemoria=15
declare memoriaLibre
declare -a lineaEstadoCPU



	
#Colores de texto
#ejemplo: echo -e "${B_RED}texto en rojo negrita${GREEN}texto en verde${NC}"
declare -a coloresLetras
declare -r DEFAULT='\e[39m' #Color por defecto
declare -r BLACK='\e[30m'
declare -r RED='\e[31m'
declare -r GREEN='\e[32m'
declare -r YELLOW='\e[33m'
declare -r BLUE='\e[34m'
declare -r MAGENTA='\e[35m'
declare -r CYAN='\e[36m'
declare -r L_GRAY='\e[36m' #Gris claro
declare -r D_GRAY='\e[90m' #Gris oscuro
declare -r L_RED='\e[91m' #Rojo claro
declare -r L_GREEN='\e[92m' #Verde claro
declare -r L_YELLOW='\e[93m' #Amarillo claro
declare -r L_BLUE='\e[94m' #Azul claro
declare -r L_MAGENTA='\e[95m' #Magenta claro
declare -r L_CYAN='\e[96m' #Cyan claro
declare -r WHITE='\e[97m'

coloresLetras=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN")

#Colores en negrita
declare -r BOLD='\e[1;39m'
declare -r B_BLACK='\e[1;30m'
declare -r B_RED='\e[1;31m'
declare -r B_GREEN='\e[1;32m'
declare -r B_YELLOW='\e[1;33m'
declare -r B_BLUE='\e[1;34m'
declare -r B_MAGENTA='\e[1;35m'
declare -r B_CYAN='\e[1;36m'
declare -r B_L_GRAY='\e[1;36m' #Gris claro
declare -r B_D_GRAY='\e[1;90m' #Gris oscuro
declare -r B_L_RED='\e[1;91m' #Rojo claro
declare -r B_L_GREEN='\e[1;92m' #Verde claro
declare -r B_L_YELLOW='\e[1;93m' #Amarillo claro
declare -r B_L_BLUE='\e[1;94m' #Azul claro
declare -r B_L_MAGENTA='\e[1;95m' #Magenta claro
declare -r B_L_CYAN='\e[1;96m' #Cyan claro
declare -r B_WHITE='\e[1;97m'
#Fin de color
declare -r NC='\e[0m' 

#Colores de FONDO:
declare -a coloresFondo
declare -r _DEFAULT='\e[49m' #Color por defecto
declare -r _BLACK='\e[40m'
declare -r _RED='\e[41m'
declare -r _GREEN='\e[42m'
declare -r _YELLOW='\e[43m'
declare -r _BLUE='\e[44m'
declare -r _MAGENTA='\e[45m'
declare -r _CYAN='\e[46m'
declare -r _L_GRAY='\e[47m' #Gris claro
declare -r _D_GRAY='\e[100m' #Gris oscuro
declare -r _L_RED='\e[101m' #Rojo claro
declare -r _L_GREEN='\e[102m' #Verde claro
declare -r _L_YELLOW='\e[103m' #Amarillo claro
declare -r _L_BLUE='\e[104m' #Azul claro
declare -r _L_MAGENTA='\e[105m' #Magenta claro
declare -r _L_CYAN='\e[106m' #Cyan claro
declare -r _WHITE='\e[107m'

coloresFondo=("$_RED" "$_GREEN" "$_YELLOW" "$_BLUE" "$_MAGENTA" "$_CYAN")

# Memoria según necesidades es el array bidimensional en el que se almacenará la información de la memoria
# No tengo intención de hacer un algoritmo eficiente para la memoria, por el simple hecho de 
# que puede ser poco intuitivo para alumnos de primero
#
# Más adelante se explicará como estarán organizadas estas capas de memoria, y el contenido específico que almacenará cada capa
declare -A memoriaSegunNecesidades
#La memoria será un array bidimensional con 2 capas y M huecos, siendo M = tamMemoria
#Así podremos almacenar que proceso se almacena en cada hueco.
#Y en la capa MEM_INDICE guardar el índice/id del proceso (fila que ocupa en la tabla)
#Y en la capa MEM_TOSTRING string con el color ya generado

#Capa donde se guardaran los índices/Apuntadores/punteros de el proceso que se encuentra en cada posición de memoria respecto a la tabla de $procesos[]
declare -r MEM_INDICE=0	

#Capa donde se almacena el texto a imprimir
declare -r MEM_TOSTRING=1

	#Declares de los contenidos por defecto de la MEMORIA
declare -r MEM_HUECO_VACIO="null"
	#Valores que se imprimen por pantalla
declare -r MEM_STRING_HUECO_VACIO="$_WHITE${WHITE}[_]${_DEFAULT}"
declare -r MEM_STRING_HUECOSINCOLOR="[^]"	#Se colorea con el color del proceso

#	######################################
#	Declares 2020:
#	######################################

# Variable de control de BREAKPOINTS 
#//@see breakpoint
declare -r BREAKPOINT_ENABLED=true
declare -r BREAKPOINT_AUTO=false
declare -r BREAKPOINT_AUTO_TIMEOUT="0.5"


#Tabla PROCESOS:
declare -A procesos 
declare -a cabeceraProcesos=("PID" "Ref" "TLl" "TEj" "Pri" "Mem" "Trej" "Tesp" "Tret" "Estado" "Color Fondo" "Color Letras" "DirI" "DirF")

#Valores de la estructura/struc (El array bidimensional procesos)
#//@see procesos
#Los siguientes valores (1-9) son las posiciones del struct existentes a las versiones previas a 2020
declare -r P_NOMBRE=1		#	$P_NOMBRE
declare -r P_TLLEGADA=2		#	$P_TLLEGADA
declare -r P_TEJECUCION=3	#	$P_TEJECUCION
declare -r P_PRIORIDAD=4	#	$P_PRIORIDAD
declare -r P_TAMANIO=5		#	$P_TAMANIO
declare -r P_TRESTANTE=6	#	$P_TRESTANTE
declare -r P_TESPERA=7		#	$P_TESPERA
declare -r P_TRETORNO=8		#	$P_TRETORNO
declare -r P_ESTADO=9		#	$P_ESTADO

#Valores 2020:
declare -r P_COLOR=10		#Color del Fondo
declare -r P_COLORLETRA=11	#Colod de las letras
declare -r P_POSINI=12		#Posición de inicio en la memoria
declare -r P_POSFIN=13		#Posición donde termina el proceso en la memoria


	#Array que almacena el número de huecos máximo que puede ocupar el string a imprimir de cada proceso.
	#Por ejemplo, la referencia (columna/posArray nº 1) del proceso puede ocupar como máximo 3 huecos (p01 a p99), por lo que en la tabla imprimiremos 3 huecos máximo
declare -a anchosTabla=(0 3 3 3 3 3 4 4 4 17 0 0 4 4)

#Strings de estados/STATUS (Valores a asignar a P_ESTADO)
declare -r STAT_MEMO="En Memoria"
declare -r STAT_ENCPU="En Ejecución"
declare -r STAT_COLA="En Espera"
declare -r STAT_FIN="Terminado"
declare -r STAT_SISTEMA="Fuera del Sistema"
declare -r STAT_APROP_PAUSA="En Pausa"		#Estado cuando un proceso es extraido de la CPU (En el modo apropiativo)

#Ficheros y directorios:
declare -r DATA_DIRECTORY="Datos/"
declare -r LOG_DIRECTORY="Informes/"

declare -r INFORME_FILENAME="${LOG_DIRECTORY}informePrioridadMayor.ANSI"
declare -r INFORMEBN_FILENAME="${LOG_DIRECTORY}informePrioridadMayorBN.txt"



#DEBUG (Variables globales):
declare -r DEFAULT_DEBUG_OUTPUT_FILE_NAME="debug.txt"
declare -r DEBUG_ENABLE=true
declare    DEBUG_FIRST_EXECUTION=true
declare -r DEBUG_PERSISTENT_FILE=false

creacionDeDirectorios
main | tee  "$INFORME_FILENAME" #Por la naturaleza de bash, si llamamos desde una función a otra, las variables de la primera función son accesibles desde la segunda
#Si llamamos a main desde global, podemos tener el GLOBAL como una función, y mantener sus funciones como globales
finMain
}


# Nombre: imprimirAviso
# Descripcion: imprime en pantalla un aviso de error al introducir un dato con letras.
# @param $1: texto de aviso 
# Cambios 2020: Como hemos añadido la funcion imprimirErrorCritico, he cambiado el color de fondo de ROJO a AMARILLO/NARANJA (Depende del terminal)
imprimirAviso(){
	echo -e "\n${B_BLACK}${_YELLOW}\xE2\x9A\xA0  $1 ${NC}\n" #\xE2\x9A\xA0 significa icono de alerta
}

# Nombre: imprimirErrorCritico
# Descripcion: imprime en pantalla un aviso de error al introducir un dato con letras.
# @param $1: texto de aviso
imprimirErrorCritico(){
	echo -e "\n${B_BLACK}${_RED}❌  $1 ${NC}\n"
}

# Nombre: salirPorErroCritico
# Descripcion: imprime en pantalla un aviso de error al introducir un dato con letras y para la ejecucion.
# @param $1: texto de aviso
# Date 21/02/2020
#//@see  ErrorCritio
#//@see  forzarCierre
salirPorErrorCritico(){
	imprimirErrorCritico "$1"
	forzarCierre
}
# Nombre: medirTiempo
# Descripción: Permite comparar el tiempo que transcurre entre las dos últimas llamas a esta función.
#	Si no se ha ejecutado, imprime el tiempo del sistema
# @Param $1: String a imprmir
# @Param $2: Fichero en el que sacar el resultado. No pasar nada para no guardar
# Variable global que almacena el último instante en ele que se ha llamado a la función (en ms)
declare -i ultimoInstanteMedido=0

medirTiempo(){

	local -i tiempoActualMS=$(($(date +%s%N)/1000000))

	echo "$1 : $((tiempoActualMS - ultimoInstanteMedido))ms" | tee -a $2
	ultimoInstanteMedido=$tiempoActualMS

}

# Nombre: forzarCierre
# Descripcion: Ejecuta una serie de comandos antes de salir, perfecta para borrar archivo u otras cosas por si no es válida la ejecución!
# Date: 21/02/2020
# //@see deleteGeneratedFiles
forzarCierre(){
	
	imprimirErrorCritico "Cerrando por fallo, pulse [Enter] para continuar"
	read -ers
	#Funciones a ejecutar aquí abajo: {
		deleteGeneratedFiles

	#	}
	clear
	fin_programa
}

# Nombre: ComprobaciónDirectorio
# Date: 07/03/2020
# Descripción: Comprueba que el script está siendo ejécutandose desde ./algo.sh
# 	y no desde una dirección distinta (./test/priMayor/algo.sh),
# 	ya que crearía los archivos de salida en ./____/algo.sh y no en el mismo directorio de ./algo.sh
#
comprobacionDirectorio(){
	local -i nPuntosBarras
	local -i nDirectorios
	
	nDirectorios=$(echo $0 | grep -oF '/' | wc -l)
	nPuntosBarras=$(echo $0 | grep -oF './' | wc -l)
	if [[ $nDirectorios -gt $nPuntosBarras ]]; then
		echo "Directorio de ejecución: $0"

		imprimirLCyan "Si cree que este mensaje no debería salir, por favor, borre ó comente la última línea:"
		cat $0 | grep -n "comprobacionDirectorio stringDeBúsqueda, no tiene valor alguno" 

		salirPorErrorCritico "Por favor, ejecute el script desde la ruta ./script.sh y no desde otro directorio o carpetas"
	fi
}

# Nombre: imprimirLCyan
# Descripcion: imprime en pantalla el text de color cyan claro
# @param $1: texto a imprimir en cyan claro
# @param $2 (opcional): argumento adicional para el echo como -n si no se quiere introducir un salto de linea
imprimirLCyan(){
	echo -e $2 ${L_CYAN}$1${NC}
}

# Nombre: fin_programa
# Descripcion: se termina la ejecición del script
fin_programa(){
	imprimirLCyan "Saliendo del programa..."
	exit 0   
}

# Nombre: scanfSiNo
# Descripcion: asigna un valor valido a una variable desde el teclado
# @param $1: texto a imprimir en pantalla para pedir si o no
# @param $2: variable al que se asigna si o no
scanfSiNo() {
	local opcionSiNo
	imprimirLCyan "$1" -n 
	read opcionSiNo
	until [[ $opcionSiNo = s || $opcionSiNo = n || $opcionSiNo = S || $opcionSiNo = N ]]; do
		imprimirAviso "El valor '$opcionSiNo' introducido no válido, tiene que ser 's' o 'n'. Vuelve a intentarlo."
		imprimirLCyan "$1" -n
		read opcionSiNo
	done
	eval ${2}=$opcionSiNo #asignamos la opcionSiNo valida al variable $2 pasado como parametro
}

# Nombre: scanfNum
# Descripcion: asigna un valor mayor que un numero pasado como parametro a una variable desde el teclado
# @param $1: texto a imprimir en pantalla para pedir
# @param $2: variable al que se asigna el numero valido
# @param $3: numero minimo valido
scanfNum(){
	local opcionN
	imprimirLCyan "$1" -n
	read -r opcionN
    #$opcionN -eq $opcionN comprueba si es un numero, si es una letra da error enviado al vacio
	until [ $opcionN -eq $opcionN -a $opcionN -ge  $3 ] 2>/dev/null; do
		imprimirAviso "El valor '$opcionN' introducido no válido, tiene que ser mayor que $3."
		imprimirLCyan "$1" -n	
		read -r opcionN
	done
	eval ${2}=$opcionN
}

# Nombre: scanfNumMinMax
# Descripcion: asigna un valor entre un rango de numeros desde el teclado
# @param $1: texto a imprimir para pedir el numero
# @param $2: variable al que se asigna el numero valido
# @param $3: numero mínimo del rango (incluido)
# @param $4: numero máximo del rango (incluido)
scanfNumMinMax(){
	local opcionN
	local numMinimo=$3
	local numMaximo=$4
	#si el numMinimo es mas grande que numMaximo intercambia las variables
	if [[ "$numMinimo" -gt "$numMaximo" ]]; then 
		numMinimo=$4
		numMaximo=$3
	fi

	imprimirLCyan "$1" -n
	read -r opcionN
	until [ $opcionN -eq $opcionN -a $opcionN -le $numMaximo -a $opcionN -ge $numMinimo ] 2>/dev/null; do 
		imprimirAviso "El valor '$opcionN' introducido no válido, intervalo válido [ $numMinimo, $numMaximo ]."
		imprimirLCyan "$1" -n	
		read -r opcionN
	done
	eval ${2}=$opcionN
}

# Nombre: scanfString
# Descripcion: asigna un valor cadena de caracteres a una variable pasado como parametro
# @param $1: texto a imprimir para pedir la cadena de caracteres
# @param $2: variable al que se asigna la cadena valida
scanfString(){
	local opcionNombre
	local -i palabra
	imprimirLCyan "$1" -n
	read -r opcionNombre
	palabra=`echo $opcionNombre | wc -w`
	while [ $palabra -ne 1 ]; do #comprueba si está vacío o tiene un espacio
		imprimirAviso "No puede ser vacío ni tener espacios."
		imprimirLCyan "$1" -n
		read opcionNombre
		palabra=`echo $opcionNombre | wc -w`
	done
	eval ${2}=$opcionNombre
}

# Nombre: numAleatorio
# Descripcion: genera un numero aleatorio de un rango de dos numeros pasado como parametro
# @param $1: variable a asignar el número aleatorio
# @param $2: número mmáximo del rango incluido
# @param $3: número máximo del rango incluido
numAleatorio(){
	local num
	local numMinimo=$2
	local numMaximo=$3
	if [ $numMinimo -gt $numMaximo ]; then
		numMinimo=$3
		numMaximo=$2
	fi
	num=$(( $RANDOM % ($numMaximo+1-$numMinimo) + $numMinimo ))
	eval ${1}=$num
}

# Nombre: comprobarRango
# Descripcion: comprueba número se encuentra dentro de un rango de dos números, 
# si no se encuetra dentro llama a scanfNumMinMax para modificarlo
# @param $1: el texto que se imprime en caso de que el número no se encuentre dentro del rango o no sea un número
# @param $2: el número a comprobar si encuentra dentro del rango
# @param $3: variable a modificar si el numero no se encuentra dentro del rango
# @param $4: numero mínimo del rango incluido
# @param $5: numero máximo del rango incluido
comprobarRango(){
	local numMinimo=$4
	local numMaximo=$5
	if [[ "$numMinimo" -gt "$numMaximo" ]]; then
		numMinimo=$5
		numMaximo=$4
	fi
	if ! [ $2 -eq $2 -a $2 -ge $numMinimo -a $2 -le $numMaximo ] 2>/dev/null; then
		scanfNumMinMax "$1" $3 $numMinimo $numMaximo
	fi
}

# Nombre: comprobarRepite
# Descripcion: comprueba el nombre del proceso se esta repitiendo
# @param $1: posicion del proceso del array procesos
comprobarRepite(){
	local -i i
	local boolean=1
	for (( i=1; i<=numProc&&boolean==1; i++)) do
		if  [ ${procesos[$i,$P_NOMBRE]} = ${procesos[$1,$P_NOMBRE]} -a $i -ne $1 ] 2>/dev/null; then
			boolean=0
			scanfString "El nombre del proceso ${procesos[$1,$P_NOMBRE]} ya existe. Introduce otro nombre: " procesos[$1,$P_NOMBRE]
			comprobarRepite $1
		fi
	done

}

# Nombre: comprobarSN
# Descripcion: comprueba si un número es un s o un n. Solo se usa en datos por fichero
# @param $1: el texto a imprimir en pantalla en caso de valor no válido
# @param $2: valor de la variable a comprobar
# @param $3: variable a modificar en caso de valor no válido
comprobarSN(){
	if ! [[ $2 = "s" || $2 = "n" || $2 = "S" || $2 = "N" ]]; then
		scanfSiNo "$1" "$3"
	fi
} 

mostrarPantallaInformacion(){
	clear
	echo -e "\e[0;36m			╔══════════════════════════════════════════════════════════╗\e[0m"
	echo -e "\e[0;36m			║\e[0m                     Creative Commons                     \e[0;36m║\e[0m"
	echo -e "\e[0;36m			║\e[0m                                                          \e[0;36m║\e[0m"
	echo -e "\e[0;36m			║\e[0m                   BY - Atribución (BY)                   \e[0;36m║\e[0m"
	echo -e "\e[0;36m			║\e[0m                 NC - No uso Comercial (NC)               \e[0;36m║\e[0m"
	echo -e "\e[0;36m			║\e[0m                 SA - Compartir Igual (SA)                \e[0;36m║\e[0m"
	echo -e "\e[0;36m			╚══════════════════════════════════════════════════════════╝\e[0m\n"

	echo -e "\e[0;36m		╔═══════════════════════════════════════════════════════════════════════════════╗\e[0m"
	echo -e "\e[0;36m		║\e[0m                                                                               \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                         Algoritmo de Prioridad Mayor                          \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                Memoria Según Necesidades: Contínua y Reubicable               \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                                                                               \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m        Base: Omar Santos Bernabé (Pri. Men. - Part. Fijas e Iguales)          \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                                                                               \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                               Alumnos 2016-2017:                              \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                          Xing Long Ji - Yi Peng Ji                            \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                                                                               \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                                Alumno 2019-2020:                              \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                                Jorge Ruiz Gómez                               \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                                                                               \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                          Asignatura: Sistemas Operativos                      \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                                Curso 2019-2020                                \e[0;36m║\e[0m"
	echo -e "\e[0;36m		║\e[0m                                                                               \e[0;36m║\e[0m"
	echo -e "\e[0;36m		╚═══════════════════════════════════════════════════════════════════════════════╝\e[0m\n"

}

# Nombre cargaDatos
# Descripcion: muestra las opciones de inicio del programa si los datos es por fichero, teclado o automáticos
cargaDatos(){
	local -i opcionUsuario
	local masProc="s"
	local -i i
	echo -e " ${L_YELLOW}╔════════════════════════════════════╗
 ║${NC}${B_BLUE}¿Como quieres introducir los datos? ${NC}${L_YELLOW}║
 ║                                    ║
 ║${NC} 1-Por teclado                      ${L_YELLOW}║
 ║${NC} 2-Por fichero                      ${L_YELLOW}║
 ║${NC} 3-Datos automáticos                ${L_YELLOW}║
 ║${NC} 4-Salir del programa               ${L_YELLOW}║
 ║                                    ║
 ╚════════════════════════════════════╝${NC}\n"
	scanfNumMinMax "Elige opción: " opcionUsuario 1 4
    case $opcionUsuario in
	1)
		menuAlgoritmo
		clear
		#imprimirLCyan "Has elegido Apropiativo: $opcionApropiativo y Estatico: $opcionEstatico"
		scanfNum "¿Tamaño de la memoria?: " tamMemoria 1
		scanfNumMinMax "¿Prioridad mínima?" priorMin -10000 10000 
		scanfNumMinMax "¿Prioridad máxima?" priorMax -10000 10000
		establecerPrioridad 
		while [ $masProc = "s" ]; do
			((numProc++))
			datosManualProcesos $numProc
			scanfSiNo "¿Quieres meter mas procesos? [s/n]:" masProc
		done
	;;
	2)
		datosFichero
	;;
    3)
		menuAlgoritmo
		datosAleatorios
	;;
	4)
		fin_programa
	;;
	esac
}

# Nombre: menuAlgoritmo
# Descripcion: menu para elegir las opciones del algoritmo, más info en la opcion 5 Ayuda (glosario)
menuAlgoritmo(){
	local -i i
	local opcion
	clear
	echo -e "\n ${L_YELLOW}╔════════════════════════════════════════════╗
 ║${NC}${B_BLUE} ¿Como quieres el algoritmo?                ${NC}${L_YELLOW}║
 ║                                            ║
 ║${NC} 1-Estándar                                 ${L_YELLOW}║
 ║${NC} 5-Ayuda (glosario)                         ${L_YELLOW}║
 ║${NC} 6-Salir del programa                       ${L_YELLOW}║
 ║                                            ║
 ╚════════════════════════════════════════════╝${NC}\n"
	scanfNumMinMax "Elige opción: " opcion 1 7
	case $opcion in
		1) opcionApropiativo="n"
		opcionEstatico="s";;
		2) opcionApropiativo="s"
		opcionEstatico="s";;
		3) opcionApropiativo="n"
		opcionEstatico="n";;
		4) opcionApropiativo="s"
		opcionEstatico="n";;
		5) clear
	echo -e "\n ${L_YELLOW}╔═════════════════════════════════════════════════════════════════════════════════╗
 ║                                                                                 ║
 ║${NC}${B_L_GREEN} Apropiativo:${NC} El proceso que se está ejecutando puede ser expulsado              ${L_YELLOW}║
 ║${NC} de la CPU cuando haya otro proceso con menor prioridad en la memoria.           ${L_YELLOW}║
 ║                                                                                 ║
 ║${NC}${B_L_GREEN} No apropiativo:${NC} El proceso que se está ejecutando no puede ser                  ${L_YELLOW}║
 ║${NC} expulsado de la memoria, solo sale cuando termina su tiempo de ejecución.       ${L_YELLOW}║
 ║                                                                                 ║
 ║${NC}${B_L_GREEN} Estático:${NC} La prioridad de los procesos en memoria no disminuyen                 ${L_YELLOW}║
 ║${NC} a lo largo de la ejecución de los procesos.                                     ${L_YELLOW}║
 ║                                                                                 ║
 ║${NC}${B_L_GREEN} Dinámico:${NC} La prioridad de los procesos en memoria disminuyen                   ${L_YELLOW} ║
 ║${NC} a lo largo de la ejecución de los procesos. En este script se                   ${L_YELLOW}║
 ║${NC} disminuirá (prioridad Menor) en uno al finalizar la ejecución de un proceso.    ${L_YELLOW}║
 ║${NC} En caso contrario aumentará al finalizar la ejecución de un proceso.            ${L_YELLOW}║
 ║                                                                                 ║
 ╚═════════════════════════════════════════════════════════════════════════════════╝${NC}\n"
		imprimirLCyan "Intro para salir de la ayuda" -n
		read -s
		menuAlgoritmo;;
		6) fin_programa;;
	esac

}

# Nombre: breakpoint
# Date: 21/02/2020
# Descripción: Permite realizar una parada del programa en cualquier punto del código hasta que no se realizar una entrada por teclado.
# Uso: Activar o desactivar la variable global $BREAKPOINT_ENABLED para activar o desactivar los breakpoints.
# Globales: BREAKPOINT_ENABLED
# @param $@: Imprime todos los stings pasados como argumento, por si se quieren visualizar variables. 
breakpoint(){
	
	if [[ $BREAKPOINT_ENABLED == true ]]; then
		

		if (($# == 0));then 
			echo -n ">"
		else
			echo -n "Breakpoint > $1"
		fi
		if [[ $BREAKPOINT_AUTO == "true" ]];then
			sleep $BREAKPOINT_AUTO_TIMEOUT
		else
			read -ers
		fi
	fi
}

# Nombre: debug (y sus muchas funciones)
# Date: 21/02/2020
# Descripción: Permite imprimir un string en un fichero a parte, y que este sea visualizado desde otro terminal
# Uso: alternar los booleanos globales
# Globales:DEFAULT_DEBUG_OUTPUT_FILE_NAME, DEBUG_ENABLE, DEBUG_FIRST_EXECUTION, DEBUG_PERSISTENT_FILE
# @param $1: String a imprimir
debug(){
  
  if [[ $DEBUG_ENABLE == false ]]; then
    return 0
  fi

  mensajeEntadaDebug(){
    printf "Introduzca el comando \$tail -f $DEFAULT_DEBUG_OUTPUT_FILE_NAME para obtener el debug\n"
   
  }
  cleanDebugFile(){
    if [[ $DEBUG_PERSISTENT_FILE == false ]]; then
     echo "" > $DEFAULT_DEBUG_OUTPUT_FILE_NAME
    fi
  }

  cabeceraDebug(){
    printf "%s\n-----------------------------------------------\n" "$(date '+%d/%m/%Y %H:%M:%S')" >> $DEFAULT_DEBUG_OUTPUT_FILE_NAME

  }


  if [[ $DEBUG_FIRST_EXECUTION == true ]]; then
    cleanDebugFile
    mensajeEntadaDebug
    cabeceraDebug
    DEBUG_FIRST_EXECUTION=false
  fi
  echo -e "$1" >> $DEFAULT_DEBUG_OUTPUT_FILE_NAME
  
}

# Nombre: deleteGeneratedFiles
# Date: 21/02/2020
# Descripción: Borra aquellos archivos que han sido generados por el programa. Es necesario indicar los archivos a borrar
# Uso: Añadir los archvios, pereferiblemente, comprobar antes de borrar si existen
deleteGeneratedFiles(){
	if [[ -f $DEFAULT_DEBUG_OUTPUT_FILE_NAME ]]; then
		rm $DEFAULT_DEBUG_OUTPUT_FILE_NAME >> /dev/null
	fi

	if [[ -f $DEFAULT_LOG_FILE_NAME ]]; then
		rm $DEFAULT_LOG_FILE_NAME >> /dev/null
	fi
	#TOFILL
}


# Nombre: establecerPrioridad
# Descripcion: establece el tipo de prioridad considerando priorMin y priorMax. El valor se usara para comparar en la ejecución
# Globales: tipoPrioridad
establecerPrioridad(){
	#si priorMin es un número más pequeño que priorMax el tipo de prioridad es menor
	if [ $priorMin -le $priorMax ]; then
		tipoPrioridad="-lt"
	else #si priorMin es un número más grande que priorMax el tipo de prioridad es técnicamente mayor
		tipoPrioridad="-gt"
	fi
}

# Nombre: datosManualProcesos
# Descripcion: el usuario rellena los datos de cada proceso por teclado: nombre, t.llegada, t.ejecución, prioridad y tamaño 
# @param $1: índice del proceso dentro del array procesos
datosManualProcesos(){
	local seguro
	local -i j
	clear
	asignarColorProceso "$1" "$1"
	if [[ $1 -lt 10 ]]; then
		procesos[$1,$P_NOMBRE]="P0$1"
	else
		procesos[$1,$P_NOMBRE]="P$1"
	fi
	clear
	imprimirTabla 1 2 3 4 5
	scanfNum "¿Tiempo de llegada del proceso $1?: " procesos[$1,$P_TLLEGADA] 0
	clear
	imprimirTabla 1 2 3 4 5
	scanfNum "¿Tiempo de ejecución del proceso $1?: " procesos[$1,$P_TEJECUCION] 1
	clear
	imprimirTabla 1 2 3 4 5
	scanfNumMinMax "¿Prioridad del proceso $1?: " procesos[$1,$P_PRIORIDAD] $priorMin $priorMax
	clear
	imprimirTabla 1 2 3 4 5
	scanfNumMinMax "¿Tamaño del proceso $1? (Menor o igual del tamaño de memoria [$tamMemoria] ): " procesos[$1,$P_TAMANIO] 1 $tamMemoria
	clear
	imprimirTabla 1 2 3 4 5
	scanfSiNo "¿Estas seguro de los datos del último proceso introducido? [s/n]: " seguro
	if [ $seguro = "n" ]; then #si se cumple se borra la fila que acaba de introducir los datos
		for ((j=1; j<=numCol;j++)) do
			unset procesos[$1,$j]
		done
		datosManualProcesos $1
	fi
	ordenarProcesos # -> se reordena la tabla mediante el tiempo de llegada. Se hace en este punto para saber la pos. del proceso
}

# Nombre: selectorFichero
# Descripción: muestra por pantalla los ficheros correspondientes a la secuencia de escape $1
#	y devuelve el string del fichero obtenido
# Nota: Esta función utiliza un fichero temporal que se almacena en /tmp
#	Se requiere de la función mktemp que no es POSIX. Está instalada en muchos sitemas, pero ojo cuidado!
#
# --NO------@Param $1: secuencia de escape: por ejemplo $1='*.txt' muestra sólo los ficheros que terminen con 'txt', es el resultado de un ls
# @Param $2: variable en la que vamos a almacenar el string de resultado
# GLOBAL: los valores se asignan también a $nomFile, ya que eval no permite hacer return de un string con espacios
#		Paso de comerme la cabeza, es una chapuza pero no hay otra, bash tiene muchas limitaciones en este aspecto.
# Date: 19/03/2020
selectorFichero(){
	local tmp=$(mktemp) #Fichero temporal
	local -i seleccion
	local -i nFicheros
	local stringReturn
	imprimirLCyan "Seleccione el archivo que desea leer:"
	
	ls  $1 | tee "$tmp" | cat -n

	nFicheros=$(wc -l < "$tmp")
	scanfNumMinMax "Valor entre 0 y $nFicheros: 0 permite introducir un nombre de forma manual: " "seleccion" 0 $nFicheros

	if [[ $seleccion = 0 ]]; then
		eval ${2}="null"
		rm "$tmp"
	else
		stringReturn=$(sed -n ${seleccion}p $tmp)
		rm "$tmp"
		nomFile="${stringReturn}"
		#eval "${2}"="${stringReturn}"
	fi
}

# Nombre: datosFichero
# Descripcion: Opción 2: Por datos. Recoge todos los datos a través del fichero
datosFichero(){
	local -i i
	local -i j
	local -i k #linea del fichero de los datos de procesos
	local nomFile=${DATA_DIRECTORY}datos.txt
	local respuesta
	local numLineas
	scanfSiNo "Por defecto se usa ${DATA_DIRECTORY}datos.txt ¿Quieres cambiarlo? [s/n]: " respuesta
	if [ "$respuesta" = "s" ]; then

		selectorFichero "${DATA_DIRECTORY}*.txt" "nomFile" #Muestra los ficheros que terminen en .txt

		if [[ $nomFile = "null" ]]; then
			scanfString "Nombre del fichero: " nomFile
		fi
	fi
	if [[ -f "$nomFile" ]]; then #si el fichero existe
		imprimirLCyan "Cargando datos desde $nomFile"
		sleep 1
		numLineas=`cat "$nomFile" | wc -l`
		#sed -n 1p coge la linea 1 y cut -d ":" -f 2 la columna 2 delimitado por :
		tamMemoria=`sed -n 1p "$nomFile" | cut -d ":" -f 2`
		opcionApropiativo=`sed -n 2p "$nomFile" | cut -d ":" -f 2`
		opcionEstatico=`sed -n 3p "$nomFile" | cut -d ":" -f 2`
		priorMin=`sed -n 4p "$nomFile" | cut -d ":" -f 2`
		priorMax=`sed -n 5p "$nomFile" | cut -d ":" -f 2`
		for (( i=1,k=7; k<=numLineas; i++,k++)) do
			((numProc++))
			for (( j=1; j<=numCol; j++ )) do
				procesos[$i,$j]=`sed -n ${k}p "$nomFile"| cut -d "	" -f $j`
			done
		done
		comprobarDatosFichero
		establecerPrioridad
		asignarColoresTabla
	else #si no existe el fichero vuelve a mandar al menú de inicio
		imprimirAviso "$nomFile no existe. Volviendo al menú de inicio..."
		sleep 2
		clear
		cargaDatos
	fi
}

# Nombre: comprobarDatosFichero
# Descripcion: comprueba si los datos del fichero son correctos. Si se repite el nombre de los procesos, fuera de rango en tamaño de procesos etc.
comprobarDatosFichero(){
	local -i i
	local -i j
	
	comprobarRango "El tamaño de memoria es incorrecto, tendrás que introducirlo por teclado: " "$tamMemoria" tamMemoria 1 999
	comprobarSN "Opcion apropiativo incorrecto, tendrás que introducir por teclado [s/n]:" "$opcionApropiativo" opcionApropiativo
	for ((i=1;i<=numProc;i++)) do
		for((j=1;j<=numCol;j++)) do
			case "$j" in
				1)
					comprobarRepite $i 
				;;
				2)
					comprobarRango "El tiempo de llegada del proceso ${procesos[$i,$P_NOMBRE]} es incorrecto, introduce otro número: " ${procesos[$i,$j]} procesos[$i,$j] 0 999
				;;
				3)
					comprobarRango "El tiempo de ejecución del proceso ${procesos[$i,$P_NOMBRE]} es incorrecto, introduce otro número: " ${procesos[$i,$j]} procesos[$i,$j] 1 999
				;;
				4)
					comprobarRango "La prioridad del proceso ${procesos[$i,$P_NOMBRE]} es incorrecto, introduce otro número: " ${procesos[$i,$j]} procesos[$i,$j] $priorMin $priorMax 
				;;
				5)
					comprobarRango "El tamaño del proceso ${procesos[$i,$P_NOMBRE]} es incorrecto, introduce otro número: " ${procesos[$i,$j]} procesos[$i,$j] 1 $tamMemoria
				;;
			esac
		done
	done
}

# Nombre: datosAleatorios
# Descripcion: Opción 3: Datos Aleatorios. Carga datos del número y tamaño de partición, 
# número de procesos, etc con números aleatorios llamando a la función numAleatorio
datosAleatorios(){
	local -i i
	local -i tamMaxProc
	numAleatorio tamMemoria 5 35
	numAleatorio numProc 5 13
	numAleatorio priorMin -30 30
	numAleatorio priorMax -30 30
	establecerPrioridad

	for ((i=1; i<=numProc; i++)) do
		if [[ $i -lt 10 ]]; then 			#Nombres que siempre ocupen 3 chars (p01 - p99)
			procesos[$i,$P_NOMBRE]="P0$i"
		else
			procesos[$i,$P_NOMBRE]="P$i"
		fi
		numAleatorio procesos[$i,$P_TLLEGADA] 0 15 #numero aleatorio de t.llegada entre 0 y 15
		numAleatorio procesos[$i,$P_TEJECUCION] 1 10 #numero aleatorio de t.ejec entre 0 y 10		
		numAleatorio procesos[$i,$P_PRIORIDAD] $priorMin $priorMax #numero aleatorio de prioridad entre prioriMin y priorMax
		numAleatorio procesos[$i,$P_TAMANIO] 1 $((tamMemoria * 75 / 100)) #numero aleatorio de tamaño entre 1 y tamMemoria + 0.75
	done
	asignarColoresTabla
}

# Nombre: escribeDatos
# Descripcion: sobrescribe los datos en datos.txt, si no existe lo crea
escribeDatos(){
	local -i i
	local -i j

	# Nombre: ordenarProcesosNombre
	# Descripción: Reordena toda la tabla de procesos por nombre.
	# Detalles: función escribeDatos(), en el curso 19/20 se exige que el fichero
	#	tenga los datos ordenados por nombre de proceso, para que sea más simple añadir nuevos datos
	#	como no es necesario almacenar el nombre, igual también se podría haber eliminado, pero bueno (es un cambio necesario, y paso de hacer lo otro)
	# Date: 17/03/2020
	ordenarProcesosNombre(){
		local -i i
		local -i j
		local -i minLlegada	#índice al proceso que es menor en llegada
		
		for((i=1;i<numProc;i++)) do
			minLlegada=$i
			for((j=i+1;j<=numProc;j++)) do
				if [[ ${procesos[$j,$P_NOMBRE]} < ${procesos[$minLlegada,$P_NOMBRE]} ]]; then #compara el tiempo de llegada
						minLlegada=$j
				fi
			done
			#intercambio de elementos
			for((k=1;k<=6;k++)) do
				aux=${procesos[$i,$k]}
				procesos[$i,$k]=${procesos[$minLlegada,$k]}	
				procesos[$minLlegada,$k]=$aux
			done
		done
	}

	#Ordenanmos los procesos por nombre para la ejecución
	ordenarProcesosNombre

	echo "Tamaño Memoria:$tamMemoria" > ${DATA_DIRECTORY}datos.txt
	echo "Apropiativo:$opcionApropiativo" >> ${DATA_DIRECTORY}datos.txt
	echo "Estatico:$opcionEstatico" >> ${DATA_DIRECTORY}datos.txt
	echo "Prioridad Mínima:$priorMin" >> ${DATA_DIRECTORY}datos.txt
	echo "Prioridad Máxima:$priorMax" >> ${DATA_DIRECTORY}datos.txt
	echo -e "Nombre\tT.Lleg\tT.Ejec\tPrior\tTamaño" >> ${DATA_DIRECTORY}datos.txt
	for (( i=1; i<=numProc; i++ )) do
		for(( j=1; j<=numCol; j++ )) do
			echo -e -n "${procesos[$i,$j]}\t" >> ${DATA_DIRECTORY}datos.txt
		done
		echo  >> ${DATA_DIRECTORY}datos.txt
	done

	#Ordenamos de nuevo para la ejecución:
	ordenarProcesos
}

# Nombre: creacionDeDirectorios()
# Descripción: Crea los directorios para los ficheros de entrada y los informes si no existen
# Date: 21/03/2020
creacionDeDirectorios(){
	if [[ ! -d $DATA_DIRECTORY ]]; then
		mkdir $DATA_DIRECTORY
	fi

	if [[ ! -d $LOG_DIRECTORY ]]; then
		mkdir "$LOG_DIRECTORY"
	fi
}


# Nombre: ordenarProcesos
# Descripcion: ordena el array procesos en función del tiempo de llegada.
# Se usa selection sort como algortimo de ordenamiento
# Version 2.0
# Date 17/03/2020
# Detalles de modificación: Si dos prioridades son iguales, el que haya sido introducido antes tiene prioridad
#		EJ: PO1 entra antes que P03, aunque tengan el mismo t.llegada.
ordenarProcesos(){
	local -i i
	local -i j
	local -i minLlegada	#índice al proceso que es menor en llegada
	
	for((i=1;i<numProc;i++)) do
		minLlegada=$i
		for((j=i+1;j<=numProc;j++)) do
			if [ ${procesos[$j,$P_TLLEGADA]} -lt ${procesos[$minLlegada,$P_TLLEGADA]} ]; then #compara el tiempo de llegada
					minLlegada=$j

			elif [[ ${procesos[$j,$P_TLLEGADA]} -eq ${procesos[$minLlegada,$P_TLLEGADA]} ]]; then #Si son igaules
				if [[ ${procesos[$j,$P_NOMBRE]} < ${procesos[$minLlegada,$P_NOMBRE]} ]]; then #Compara los nombres
					minLlegada=$j
				fi
			fi
		done
		#intercambio de elementos
		for((k=1;k<=11;k++)) do
			aux=${procesos[$i,$k]}
			procesos[$i,$k]=${procesos[$minLlegada,$k]}	
			procesos[$minLlegada,$k]=$aux
		done
	done
}

# Nombre: imprimirTablaPredeterminada
# Date; 06/03/2020
# Descripción: Función que llama a la función "imprimirTabla()" con unos parámetros específicos
# 		Además, la función imprime una cabecera inicial.
# Nota: La tabla original era muy grande, y permitía imprimir las columnas seleccionadas.
#	En la versión de 2020 se exige que se impriman casi todas las columnas del struct, y tener que hacer una llamada
#	con todos los parámtros, puede ser muy pesado.
#	He decidido hacer esto por dos razones: 1º: Puedo reutilizar la tabla en la entrada de datos con 4 columnas 2º: Puedo poner la cabecera fija cómodamente.
imprimirTablaPredeterminada(){
	echo ""
	echo "    │ DAT.INICIALES │    TIEMPOS   │ MEMORIA │    OTROS DATOS   │"
	echo "┌───┼───┬───┬───┬───┼────┬────┬────┼────┬────┼──────────────────┤"
	imprimirTabla "$P_NOMBRE" "$P_TLLEGADA" "$P_TEJECUCION" "$P_TAMANIO" "$P_PRIORIDAD" "$P_TESPERA" "$P_TRETORNO" "$P_TRESTANTE" "$P_POSINI" "$P_POSFIN" "$P_ESTADO"
	echo "└───┴───┴───┴───┴───┴────┴────┴────┴────┴────┴──────────────────┘"
}


# Nombre: imprimirTabla
# Descripcion: imprime las columnas del array procesos pasado como parámetro
# Versión 2.0 (Original imprimirTablaOld())
# Date: 6/03/2020
# Nota 2020: Adaptada a los requisitos exigidos en el curso 18-19 y 19-20 (Tabla compacta roñosa)
# @param $@ (todos): índice de las columnas que se quiere imprimir en pantalla
imprimirTabla(){
	local -i i
	local -i j
	local -i k
	local separadorHorizontal="───────────────────────────"	#Cualquier tamaño, luego se recorta y se ajusta.

	for k in "$@"; do #imprime la cabecera de la tabla
		printf " %*b" "${anchosTabla[$k]}" "${B_L_YELLOW}${cabeceraProcesos[$k]}${NC}"
	done
	echo ""

	for (( i=1; i<=numProc; i++ )) do 
		if [[ $((($i-1) % 5 )) -eq 0 ]] && [[ $i -ne 1 ]]; then #imprime una línea de separación cada 5 procesos (pero no en la primera ejecución)
			for k in "$@"; do
				printf "${BLUE}%s"  ${separadorHorizontal:0:${anchosTabla[$k]}+1}
			done
			echo -e "──${NC}" 
		fi
		for j in "$@";do #imprime los datos de los procesos
			printf " ${procesos[$i,$P_COLORLETRA]}%-*s${NC}" "${anchosTabla[$j]}" "${procesos[$i,$j]:0:${anchosTabla[$j]}}"
		done
		echo -e "${NC}"

	done
}

# Nombre: convertirFicheroColorEnBlancoNegro 	
# Descripción: Lee un fichero formateado con ASCII Color Schemes y lo convierte en Blanco y negro
# 		Elimina los colores usados en este script y otros chars de escape para poder ser visualizados en cualquier editor de texto
# Date: 29/02/2020
# Documentation: https://stackoverflow.com/questions/19296667/remove-ansi-color-codes-from-a-text-file-using-bash
# @Param $1: Direccion del fichero 1 a convertir
# @Param $2: Dirección del fichero 2 en el que se volcará el resultado
# @Param $3: String boolano ("true"), en el que se indica si se quiere borrar el fichero original
convertirFicheroColorEnBlancoNegro(){
	
	sed -r "s/\x1B\[(([0-9]{1,2})?(;)?([0-9]{1,2})?)?[m,K,H,f,J]//g" "$1" > "$2"

	if [[ $3 = "true" ]];then
		
		rm "$1" && echo "El fichero $1 ha sido borrado"
	fi
}

# Nombre: inicializarArrays
# Descripción: inicializa arrays necesario antes de la ejecución
inicializarArrays(){
	local -i i
    cola[1]=0

	#inicializamos de datos predeterminados los de la fila 0, fila usada como indice en caso de que una memoria o cpu este vacio
	procesos[0,$P_TLLEGADA]=0
	procesos[0,$P_TAMANIO]=0
	procesos[0,$P_TRESTANTE]=-1
	if [ $tipoPrioridad = "-lt" ]; then
		procesos[0,$P_PRIORIDAD]=$((priorMax + 1))
	else
		procesos[0,$P_PRIORIDAD]=$((priorMax - 1))
	fi
}

# Nombre: anadirCola
# Descripcion: añade el indice de un proceso del array procesos al final de la cola,
# cambia el estado del proceso a "cola"
# @param $1: indice del proceso a meter en cola
anadirCola(){
	((tamCola++))
    cola[$tamCola]=$1
	#Actualizamos el estado del proceso a "En cola"
	procesos[$1,$P_ESTADO]=$STAT_COLA
	procesos[$i,$P_TESPERA]=0
}

# Nombre: eliminarCola
# Descripcion: elimina el primer elemento de la cola y mueve los demas elementos a la izquierda
eliminarCola(){
	local -i i
	local -i j
	for((i=1;i<=tamCola;i++)) do #mueve los elementos a la izquierda
		cola[$i]=${cola[$i+1]}	
	done
    ((tamCola--))
}
# Nombre: calcularPosProceso
# Descripción: Actualiza las variables $P_POSINI y $P_POSFIN del proceso indicado
# Date: 05/03/2020
# Ejemplo de USO: Si tuviese tiempo para hacer un programa eficiente, habría que actualizar la tabla a paritr
# 	de esta función cuando: Se añade un proceso en mem -> se reubica. Como no hay tiempo y no se valora, se recalcula en cada bucle
#	la de todos los procesos en memoria. 
# @Param $1: Índice del proceso a recalcular
#
#NOTA: Sin uso en todo el programa, no había presupuesto, posiblemente nunca se haya probado.
calcularPosProceso(){
	
	for (( i=1; i<=tamMemoria; i++)); do
		if [[ ${memoriaSegunNecesidades[$i,$MEM_INDICE]} -eq $1 ]]; then #Está en memoria
			procesos[$1,$P_POSINI]=$i
			procesos[$1,P_POSFIN]=$((i+${procesos[$1,$P_TAMANIO]}))
			break
		fi
	done
}

# Nombre: calcularPosTodosProcesos
# Descripción: Actualiza las variables $P_POSINI y $P_POSFIN de todos los procesos que estén en memoria
# Date: 05/03/2020
calcularPosTodosProcesos(){
	
	local -i ultimoProEncontrado=-1
	local -i procesoActual

	for (( i=1; i<=tamMemoria; i++)); do
		procesoActual=${memoriaSegunNecesidades[$i,$MEM_INDICE]}
		if [[ $procesoActual -ne $ultimoProEncontrado ]] && [[ $procesoActual != "$MEM_HUECO_VACIO" ]]; then #Está en memoria
			ultimoProEncontrado=$procesoActual
			procesos[$procesoActual,$P_POSINI]=$((i-1))
			procesos[$procesoActual,$P_POSFIN]=$((i - 2 + ${procesos[$procesoActual,$P_TAMANIO]}))
		fi
	done
}
# Nombre: eliminarPosProceso
# Date: 05/03/2020
# Descripción:  Actualiza las variables $P_POSINI y $P_POSFIN del proceso indicado a "-"
# @Param $1: índice del proces cuyas posiciones queremos eliminar.
eliminarPosProceso(){
	local -r valorNull="-"
	procesos[$1,$P_POSINI]=$valorNull
	procesos[$1,$P_POSFIN]=$valorNull
}

# Nombre: nularColumna
# Date: 05/03/2020
# Descripción:  Actualiza toda una columna del STRUCT/${procesos[]} con el valor "-"
# Ejemplo de uso: Nulado inicial de las columnas que no han sido introducidas mediante la entrada.
# @Param $@: Todos los enteros/valores del struct que queremos vaciar
nularColumna(){
	local -r valorNull="-"
	local -i columna

	for columna in "$@"; do
		for ((i=1; i<=numProc; i++));do

			if [[ $columna -eq $P_ESTADO ]];then
				procesos[$i,$columna]=$STAT_SISTEMA
			else
				procesos[$i,$columna]=$valorNull
			fi

		done
	done


}

# Nombre: vaciarMemoria
# Date: 22/02/2020
# Funcinamiento: Vacía la memoria segúnNcesidades, o la pone en su estado por defecto.
vaciarMemoria(){
	for((i=1;i<=tamMemoria;i++)); do
		memoriaSegunNecesidades[$i,$MEM_INDICE]=$MEM_HUECO_VACIO
		memoriaSegunNecesidades[$i,$MEM_TOSTRING]=$MEM_STRING_HUECO_VACIO
	done
}

# Si el proceso tiene un tamaño igual o menor a la memoria libre:
#  -Se introduce el proceso en memoria
#  -Se actualiza su estado a "STAT_MEMO"
#  -Se actualiza la cantidad de memoria libre
# Date: 22/02/2020
# @param $1: indice del proceso a guardar en la particion
aniadirProcesoAMemoria(){
	local posicionEnLaQueEmpiezaElHuecoEnMemoriaParaEmplazar
	
	#Si el param1 está vacío, no hacemos nada.
	if [[ $1 = "" ]] || [[ $tamCola -le 0 ]];then
		return
	fi

	if [[ ${procesos[$1,$P_TAMANIO]} -le $memoriaLibre ]]; then
		procesos[$1,$P_ESTADO]=$STAT_MEMO

		eliminarCola #sacamos al primer proceso de la cola (el que acabamos de introducir)
		
		ajustarMemoriaParaElProceso "${procesos[$1,$P_TAMANIO]}" "posicionEnLaQueEmpiezaElHuecoEnMemoriaParaEmplazar"
		
		if [[ $posicionEnLaQueEmpiezaElHuecoEnMemoriaParaEmplazar == "null"  ]] || [[ $posicionEnLaQueEmpiezaElHuecoEnMemoriaParaEmplazar == "" ]];then
			breakpoint "Amigo, tenemos un problemón en la función aniadirAMemoria(), el return de ajustarMemoriaParaElProceso() no es posible ($posicionEnLaQueEmpiezaElHuecoEnMemoriaParaEmplazar) || PROGRAMACIÓN DEFENSIVA"
			imprimirErrorCritico "Lo de arriba, mostrando estado de memoria para diagnóstico:"
			dibujarMemoria
			breakpoint "El error ha sido impreso."
		fi
		
		local -i ultimaPosicionADibujarElProceso=$((posicionEnLaQueEmpiezaElHuecoEnMemoriaParaEmplazar  + ${procesos[$1,$P_TAMANIO]}))

		for((i=posicionEnLaQueEmpiezaElHuecoEnMemoriaParaEmplazar; i<ultimaPosicionADibujarElProceso; i++)); do
				#añadimos el indice
			memoriaSegunNecesidades[$i,$MEM_INDICE]=$1
				#Añadimos la salida por pantalla con COLOR 
			memoriaSegunNecesidades[$i,$MEM_TOSTRING]="${procesos[$1,${P_COLOR}]}${procesos[$1,${P_COLORLETRA}]}$MEM_STRING_HUECOSINCOLOR${_DEFAULT}"

			if [[ $i -gt $tamMemoria  ]];then
				breakpoint "Amigo, tenemos un problemón en la función aniadirAMemoria(), has añadido a más memoria de la existente || PROGRAMACIÓN DEFENSIVA"
				salirPorErrorCritico "Lo de arriba"
			fi
		done

		memoriaLibre=$((memoriaLibre - ${procesos[$1,$P_TAMANIO]}))
	fi
	
}

# Si el proceso se encuentra en memoria
#  -Se elimina el proceso en memoria
#  -Se actualiza su estado a "FIN"
#  -Se actualiza la cantidad de memoria libre
# Date: 22/02/2020
# @param $1: indice del proceso a borrar de memoria
eliminarProcesoDeMemoria(){
	local -i estabaEnMemoria=0

	for((i=1;i<=tamMemoria;i++)); do
		#Si el proceso de una dirección coincide con el del índice pasado, borramos dicho proceso
		if [[ $1 -eq ${memoriaSegunNecesidades[$i,$MEM_INDICE]} ]];then
			estabaEnMemoria=1
			memoriaSegunNecesidades[$i,$MEM_INDICE]=$MEM_HUECO_VACIO
			memoriaSegunNecesidades[$i,$MEM_TOSTRING]=$MEM_STRING_HUECO_VACIO
		fi
	done
	
	if (( estabaEnMemoria == 1)); then
		procesos[$1,$P_ESTADO]=$STAT_FIN
		memoriaLibre=$((memoriaLibre + ${procesos[$1,$P_TAMANIO]}))
	fi
}

# Funcion que comprueba si un proces cabe en la memoria TOTAL, o es necesario reubicar.
# Si es necesario, reubica la memoria.
# Date: 22/02/2020
# @param $1: Tamaño del proceso
# @param $2/return: Variable en la que se almacenará el valor de salida de esta función
# @return posición en la que empieza el huevo ó null si no hay suficiente hueco.
# 	return por stdout, es necesario = la llamada de la función a una variable para "capturar" el return.
ajustarMemoriaParaElProceso(){
	local posicionEnLaQueEmpiezaElHuecoEnMemoria	
	
	encontrarHuecoEnMemoria "$1" posicionEnLaQueEmpiezaElHuecoEnMemoria
	
	if (( posicionEnLaQueEmpiezaElHuecoEnMemoria == "null")); then
		dibujarMemoria	#Dibujamos la memoria una vez para ver la diferencia.
		reubicarProcesos
		imprimirAviso "La memoria ha sido reubicada"
		dibujarMemoria	#Dibujamos la memoria para ver el después
		encontrarHuecoEnMemoria "$1" posicionEnLaQueEmpiezaElHuecoEnMemoria
	fi
	
	eval $2="$posicionEnLaQueEmpiezaElHuecoEnMemoria"
}

# Nombre: encontrarHuecoEnMemoria
# Descripción: Función que calcula la posición / si es posible introducir $1 unidades de memoria continuas en memoria. 
# Date 22/02/2020
# @param1 tamaño del hueco a encontrar / tamaño del proceso a emplazar
# @param $2/return: Variable en la que se almacenará el valor de salida de esta función
# @return posición en la que empieza el huevo ó null si no hay suficiente hueco.
# 	return por stdout, es necesario = la llamada de la función a una variable para "capturar" el return.
encontrarHuecoEnMemoria(){
	local -i numeroDeHuecosLibresConsecutivos=0
	local -i cabeEnMemoria=0 #boolean
	local -i posicionInicialEnLaQueEmpiezaElHueco=1
	local -i sePuedeGuardarLaPosicioneEnLaQueEmpiezaElHueco=1
	
	if [[ $1 -le $memoriaLibre ]]; then
		#Contamos el número de posiciones vacias consecutivas
		#Si tienen el mismo tamaño que la memoria, metemos el proceso en ese hueco.
		#si hemos recorrido todo el array, y no cabe en ningun lado, reubicamos.
		
		for((i=1;i<=tamMemoria;i++)); do
			
			if [[ ${memoriaSegunNecesidades[$i,$MEM_INDICE]} -eq $MEM_HUECO_VACIO ]]; then #Si hueco esta vacio
				((numeroDeHuecosLibresConsecutivos++))

				if ((sePuedeGuardarLaPosicioneEnLaQueEmpiezaElHueco == 1)); then
					posicionInicialEnLaQueEmpiezaElHueco=$i
					sePuedeGuardarLaPosicioneEnLaQueEmpiezaElHueco=0
				fi

				if ((numeroDeHuecosLibresConsecutivos == $1)); then #Si el proceso tiene el tamaño mínimo del hueco comprobado
					cabeEnMemoria=1
					break
				fi

			else #La posición estaba ocupada (miss): Reiniciamos el contador del primer hit
				numeroDeHuecosLibresConsecutivos=0
				sePuedeGuardarLaPosicioneEnLaQueEmpiezaElHueco=1
			fi

		done
	fi
	
	if [[ $cabeEnMemoria -eq 0 ]]; then
		eval ${2}="null"
	else
		eval ${2}="$posicionInicialEnLaQueEmpiezaElHueco"
	fi
}
# Nombre: reubicarProcesos
# date: 22/03/2020
# Descripción: Reubica la memoria
# Nota del autor: Si no hubiese hecho el array bidimensional, esto podría haber sído un simple oneLiner que ordenase el array de menor a mayor
# 	(No he tenido en cuenta donde irían los nulls, pero podrían haber sido sustiutidos por 0 )
# indepentientemente, bash es una chusta, e igual no va tan bien como debería.
reubicarProcesos(){
	local ultimoIndiceEncontrado="/"

	# Buffer destinado a guardar los elementos que se encuentran en este momento en memoria
	# Almacenará: Un puntero a la fila de la tabla correspondiente a cada proceso
	# Leerá dicho puntero/indice de la tabla de memoria, de la capa MEM_INDICE
	unset bufferReubicacion
	declare -a bufferReubicacion

	#Almacenamos los procesos que están en memoria
	for((i=1;i<=tamMemoria;i++)); do
		#Si el índice que hay en i posición de memoria NO es NI el indice vacío, ni el último indice encontrado, guardamos el índice en un array
		if [[ ${memoriaSegunNecesidades[$i,$MEM_INDICE]} != "$ultimoIndiceEncontrado" ]] && [[ ${memoriaSegunNecesidades[$i,$MEM_INDICE]} != "$MEM_HUECO_VACIO" ]]; then
			bufferReubicacion+=("${memoriaSegunNecesidades[$i,$MEM_INDICE]}")	#Guardamos el índice
			ultimoIndiceEncontrado=${memoriaSegunNecesidades[$i,$MEM_INDICE]}
		fi
	done

	vaciarMemoria
	
	local -i ultimaPosicionMemoria=1	#Variable que almacenará la última posición en la que se ha "creado" memoria
	#Rellenamos la memoria!
	for indice in "${bufferReubicacion[@]}"; do
		
		#Para i iteraciones siendo i = tamaño del proceso
		for((i=0;i<procesos[$indice,$P_TAMANIO];i++)); do
			#añadimos el indice
			memoriaSegunNecesidades[$ultimaPosicionMemoria,$MEM_INDICE]=$indice
			#Añadimos la salida por pantalla con COLOR
			memoriaSegunNecesidades[$ultimaPosicionMemoria,$MEM_TOSTRING]="${procesos[$indice,$P_COLOR]}${procesos[$indice,$P_COLORLETRA]}$MEM_STRING_HUECOSINCOLOR${NC}"
			
			if (( ultimaPosicionMemoria > tamMemoria)); then 
				breakpoint "Colega, tenemos un problemón en reubicarProcesos(), te has salido del array de memoria"
			fi
			((ultimaPosicionMemoria++))
		done
		
	done
	
}

# Nombre: DEV_modificarMemoria
# Date: 27/01/2020
# Descripción: Función que permite manipular la memoria de forma manual. Diseñada para testear el comportamiento de esta. 
DEV_modificarMemoria(){
	local -i opcion
	local -i index
	local -i volverAIntroducir
	local -i finDeEjecucion=false
	echo "Función de desarrollo para la modificación de memoria"
	echo "1) Añadir el último elemento de la cola (${procesos[${cola[1]},$P_NOMBRE]}) a memoria"
	echo "2) Eliminar un proceso de memoria (A partir de su posición en la tabla)"
	echo "3) Reubicar memoria"
	echo "4) Añadir siguiente proceso a CPU (El que tenga la prioridad más alta de los que estan en memoria)"
	echo "*) Nada"

	read -r opcion

	case $opcion in
	1)
		if [[ ${procesos[${cola[1]},$P_TAMANIO]} -le $memoriaLibre ]];then
			aniadirProcesoAMemoria "${cola[1]}" 
		else
			imprimirAviso "No se puede introducir el proceso a memoria porque esta no tiene hueco"
		fi
	;;
	2)
		echo -n "Introduzca el índice del proceso: "
		read -r index
		eliminarProcesoDeMemoria $index
	;;
	3)
		reubicarProcesos
	;;
	4)
		aniadirSiguienteProcesoACPU
	;;
	*)
		finDeEjecucion=true
	;;
	esac

	if [[ $finDeEjecucion = "false" ]];then
		scanfSiNo "Desea introducir otro proceso?" volverAIntroducir

		if [[ $volverAIntroducir = 's' ]]; then
			DEV_modificarMemoria
		fi
	fi
}

# Nombre: DEV_ImprimirColores
# Date: 05/03/2020
# Descripción: Imprime por todos los procesos en el sistema: El color del string y de fondo asignado
DEV_ImprimirColores(){
	local string1="test"
	local string2=987023
	for ((i = 1; i<= numProc; i++)); do
		echo -e "Índice $i: ${procesos[$i,$P_COLORLETRA]}STRING${NC}   ${procesos[$i,$P_COLOR]}FONDO${NC}      |"
	done
	for ((i = 1; i<= numProc; i++)); do
		printf "${procesos[$i,$P_COLORLETRA]}%-.*s${NC}   ${procesos[$i,$P_COLOR]}%-.*s${NC}      |\n" $i "printf" $i "printf"
		
	done
	for ((i = 1; i<= numProc; i++)); do
		printf "${procesos[$i,$P_COLORLETRA]}%*s${NC}   ${procesos[$i,$P_COLOR]}%-*s${NC}      |\n" $i "${string1:0:$i}" $i "${string2%:0:$i}"
	done
	read -ers
}
# Nombre: asignarColoresTabla
# Date: 05/03/2020
# Descripción: Rellena las columnas $P_COLOR y $P_COLORLETRA de la tabla procesos con colores
# Ejemplo de uso: Al introducir los procesos por fichero/Random, podemos asignar a todos los procesos colores!
asignarColoresTabla(){
	local -i i

	for ((i=1; i <= numProc; i++)); do
		asignarColorProceso "$i" "$i"
	done
}

# Nombre: asignarColorProceso.
# Date: 05/03/2020
# Descripción: Pasado el índce del proceso y un entero, se asignará a dicho proceso el color correspondiente al entero.
# Ejemplo de uso: Al introducir un proceso manualmente, se le asigna el color al momento! 
# Nota: Los arrays de colores deben tener el mismo tamaño y los colores en la misma posición.
# @Param $1: índice/puntero al proceso en la tabla procesos
# @Param $2: entero cualquiera
asignarColorProceso(){

	if [[ $1 -gt 0 ]] && [[ $1 -le $numProc ]]; then
		procesos[$1,$P_COLOR]=${coloresFondo[$2%${#coloresFondo[@]}]}
		procesos[$1,$P_COLORLETRA]=${coloresLetras[$2%${#coloresLetras[@]}]}
	else
		imprimirErrorCritico "El proeso intorudcido no se encuentra en la tabla"
	fi
}
# Nombre: truncarMemoria
# Date: 08/03/2020
# Parámetros: Utiliza la variable memoriaTruncada declarada en dibujarMemoria
# Descripción: rellena un array bidimensional con el string de memoria a imprimir.
#		este nuevo string permite representar la memoria de forma dínamica, dependiendo del ancho del terminal.
truncarMemoria(){
	local -i ultimaPosMemEmplazada=1
	local    ultimoIndiceEncontrado=-1
	local -i i
	local -i j

	for (( i=1; i<= (altoMemoriaTruncada*3); i+=3 )); do
		for ((j=1; j <= anchoTerminalBloques; j++)); do	#La línea de memoria empieza en 1
			memoriaTruncada[$i,$j]=${memoriaSegunNecesidades[$ultimaPosMemEmplazada,$MEM_TOSTRING]}
			
			if [[ ${memoriaSegunNecesidades[$ultimaPosMemEmplazada,$MEM_INDICE]} -ne $ultimoIndiceEncontrado ]];then
				ultimoIndiceEncontrado=${memoriaSegunNecesidades[$ultimaPosMemEmplazada,$MEM_INDICE]}
				
				#Fila de los nombres
				if [[ $ultimoIndiceEncontrado -eq $MEM_HUECO_VACIO ]]; then #Si el hueco está vacío
					memoriaTruncada[$((i-1)),$j]="---"
				else	#Nombre del proceso
					memoriaTruncada[$((i-1)),$j]=${procesos[$ultimoIndiceEncontrado,$P_NOMBRE]}		#ASIGNAMOS EL NOMBRE ARRIBA DE LA BARRA
				fi

				#Fila de las posiciones
				if [[ $ultimaPosMemEmplazada -lt 10 ]]; then
					memoriaTruncada[$((i+1)),$j]="$((ultimaPosMemEmplazada-1))  "	#Metemos espacios al final para que no se descuadre, si el tamaño es >=100, se descuadra
				else															#Sería poner un elif con el tamaño del int, pero me da pereza, pd: he tardado más escribiendo esto
					memoriaTruncada[$((i+1)),$j]="$((ultimaPosMemEmplazada-1)) "		#que haciendolo, un saludo: Jorge (09/03/2020 - 13:17)
				fi
			else
				memoriaTruncada[$((i-1)),$j]="   "		 #No hay proceso -> Vacío
				memoriaTruncada[$((i+1)),$j]="   "		 #No hay dirección al no haber cambio de proceso -> Vacío
			fi
			((ultimaPosMemEmplazada++))

			if [[ $ultimaPosMemEmplazada -gt $tamMemoria ]];then break; fi
		done
			ultimoIndiceEncontrado=-1 #reseteo para que se imprima siempre en cada línea la dirección y el proceso
	done

	#Añade los elementos al margen izquierdo
	for (( i=1; i<= (altoMemoriaTruncada*3); i+=3 )); do
		memoriaTruncada[$((i-1)),0]="   "
		memoriaTruncada[$((i  )),0]="   "
		memoriaTruncada[$((i+1)),0]="   "
	done
	memoriaTruncada[$((1  )),0]="${NC}BM|"
	#Escribe la última posición/tam memoria detrás de todos los strings
	#memoriaTruncada[$(( (altoMemoriaTruncada*3) -2 )),$((anchoTerminalBloques-1))]="|$tamMemoria"


}

# Nombre: dibujarMemoria
# Descripción: Muestra por pantalla la memoria truncada
# @Param: $1 string de control: si el string es "mostrarStatsMemoria", se muestra por pantalla el uso de memoria y el 
dibujarMemoria(){
	local -i memoriaEnUso
	local memoriaEnUsoPorciento #Es un string al ser float
	declare -A memoriaTruncada
	declare -i anchoTerminal=$(tput cols) #En columnas
	declare -i anchoTerminalBloques=$(( anchoTerminal/3 - 1)) #Bloques -> bloques de memoria. Un bloque/unidad de memoria se representa con 3 espacios/columnas de un color || restamos 1 unidad para dejar margen para maniobrar
	declare -i altoMemoriaTruncada
	
	#Calculamos el alto de memoria (el número de filas que ocupará truncada)
	if [[ $((tamMemoria%anchoTerminalBloques)) == 0 ]];then
		altoMemoriaTruncada=$((tamMemoria/anchoTerminalBloques))
	else	#Si la memoria ocupa parte de una líena, la asignamos entera
		altoMemoriaTruncada=$(( ( tamMemoria/anchoTerminalBloques ) + 1 ))
	fi

	#Stats mememoria:
	if [[ $1 = "mostrarStatsMemoria" ]]; then
		memoriaEnUso=$((tamMemoria-memoriaLibre))
		memoriaEnUsoPorciento=$(echo "scale=2;100*$memoriaEnUso/$tamMemoria" | bc -l) 
		imprimirLCyan "Uso de memoria: $memoriaEnUso/$tamMemoria ($memoriaEnUsoPorciento%) -> Memoria libre: $memoriaLibre"
	fi

	#for((i=1;i<=tamMemoria;i++)); do #Imprime los índices de memoria para mejorar el flujo
	#	break
	#	echo -n "${memoriaSegunNecesidades[$i,$MEM_INDICE]},"
	#done
	#echo "" #salto de línea

	truncarMemoria 	#Imprimimos la memoria truncada
	for (( i= 0; i< 3*altoMemoriaTruncada; i++ ));do
		
		for (( j=0; j<=anchoTerminalBloques; j++));do
			echo -en "${memoriaTruncada[$i,$j]}"
		done
		echo ""
	done
}

# Nombre: aniadirSiguienteProcesoACPU
# Date: 27/02/2020
# Descripción: De entre todos los procesos en memoria, añade el proces con la prioridad más alta a CPU
aniadirSiguienteProcesoACPU(){
	#Si la prioridad menor es más baja que la mayor
	local -i prioridadMasAlta
	local -i procesoConPrioridadMasAlta

	if [[ $tipoPrioridad = "-lt" ]]; then
		prioridadMasAlta=$((priorMin - 1))
	elif [[ $tipoPrioridad = "-gt" ]]; then
		prioridadMasAlta=$((priorMin + 1))
	else
		breakpoint "$(imprimirErrorCritico "aniadirSiguienteProcesoACPU(): No existe dicha ($tipoPrioridad) prioridad crack!")"
	fi

	#	Valores de $tipoPrioridad
	#	-lt significa que la prioridad minima es un número menor que la prioridad máxima
	#	-gt significa que la prioridad mínima es mayor que la prioridad máxima
	#	Más información sobre el porqué de estos valores en la cabezera de la función establecerPrioridad()
	
	for ((i=0; i<=tamMemoria; i++)); do
		#Si la prioridad del proceso es mayor a la prioridad más alta encontrada
		if [[ ${memoriaSegunNecesidades[$i,$MEM_INDICE]} -ne $MEM_HUECO_VACIO ]]; then
			if (( ${procesos[${memoriaSegunNecesidades[$i,$MEM_INDICE]},$P_PRIORIDAD]} > $prioridadMasAlta )); then
				if [[ $tipoPrioridad = "-lt" ]]; then
					procesoConPrioridadMasAlta=${memoriaSegunNecesidades[$i,$MEM_INDICE]}
					prioridadMasAlta=${procesos[${memoriaSegunNecesidades[$i,$MEM_INDICE]},$P_PRIORIDAD]} 
				fi
			elif (( ${procesos[${memoriaSegunNecesidades[$i,$MEM_INDICE]},$P_PRIORIDAD]} < $prioridadMasAlta )); then
				if [[ $tipoPrioridad = "-gt" ]]; then
					procesoConPrioridadMasAlta=${memoriaSegunNecesidades[$i,$MEM_INDICE]}
					prioridadMasAlta=${procesos[${memoriaSegunNecesidades[$i,$MEM_INDICE]},$P_PRIORIDAD]} 
				fi
			elif ((${procesos[${memoriaSegunNecesidades[$i,$MEM_INDICE]},$P_PRIORIDAD]} == $prioridadMasAlta)); then
				#Si tienen la misma prioridad ^
				#Si su índice es menor (Significa que entró antes en memoria porque su t.llegada era menor)
				if (( ${memoriaSegunNecesidades[$i,$MEM_INDICE]} < procesoConPrioridadMasAlta)); then
					procesoConPrioridadMasAlta=${memoriaSegunNecesidades[$i,$MEM_INDICE]}
				fi
			fi
		fi
	done

	#Guardamos el índice del proceso y actualizamos su estado
	procesoCPU=$procesoConPrioridadMasAlta
	procesos[$procesoCPU,$P_ESTADO]="$STAT_ENCPU"
	procesos[$procesoCPU,$P_TRETORNO]=$(( tiempoEjecucion - ${procesos[$procesoCPU,$P_TLLEGADA]} ))
	procesos[$procesoCPU,$P_TRESTANTE]=${procesos[$procesoCPU,$P_TEJECUCION]}
}

# Nombre: ejecutarUnCicloDeCPU
# Date: 27/02/2020
# Descripción: Simula el comportamiento repetitivo de algunos momentos del programa
#	-Calcula ciertos valores
#	-Aumenta el tiempo de ejecución
#	-Actualiza la línea de estado de CPU
ejecutarUnCiloDeCPU(){
	#Decrementamos en una unidad el tiempo restante del proceso en ejecución
	procesos[$procesoCPU,$P_TRESTANTE]=$(( ${procesos[$procesoCPU,$P_TRESTANTE]}-1))
	((procesos[$procesoCPU,$P_TRETORNO]++))
	
	lineaEstadoCPU+=("$procesoCPU")
	
	#aumenta el tiempo de espera de los procesoso en memoria y en cola
	for((i=1;i<=numProc;i++)) do
		if [[ ${procesos[$i,$P_ESTADO]} == "$STAT_MEMO" ]] || [[ ${procesos[$i,$P_ESTADO]} == "$STAT_COLA" ]] ; then
			((procesos[$i,$P_TESPERA]++))
		fi
	done

	((tiempoEjecucion++))
}

# Nombre: comprobarSiElProcesoEnCPUHaTerminado
# Date: 29/02/2020
# Descripción: Si un proceso ha termiando en CPU -> Actualiza su línea en la tabla y lo saca de CPU y memoria
comprobarSiElProcesoEnCPUHaTerminado(){

	if [[ ${procesos[$procesoCPU,$P_TRESTANTE]} -eq 0 ]];then
		printf "${L_RED}%s ${procesos[$procesoCPU,$P_COLORLETRA]}%s ${L_RED}%s ${NC}%d ${L_RED}%s\n${NC}" "El proceso" "${procesos[$procesoCPU,$P_NOMBRE]}" "ha terminado de ejecutarse en el instante" $tiempoEjecucion "y está siendo desalojado de memoria y CPU"
		
		((procEjecutados++))

		#Eliminamos el proceso de la CPU
		
		eliminarPosProceso "$procesoCPU"
		eliminarProcesoDeMemoria "$procesoCPU"
		procesos[$procesoCPU,$P_ESTADO]=$STAT_FIN
		procesoCPU=0
	fi
	procesos[$procesoCPU,$P_TRETORNO]=$tiempoEjecucion 
}

# Nombre: truncarBarraCPU
# Date: 09/03/2020
# Descripción: Trunca la barra de CPU, y añade el tiempo de inicio y fin de cada proceso, así como el nombre correspondiente.
# Nota: Tiene un uso similar al truncado de memoria. Los cálculos de las distintas variables aquí referenciadas han sido realizados en dibujarEstadoCPU()
#			ya que es necesario saber de antemano el ancho y alto del array a imprimir y a generar, y puede variar si se calcula 2 veces, una en cada función.
#			Además, aquí no tenemos un vector.length para saber cuanto mide un array, bash-ura de lenguaje. 
#		Podría hacerse en una misma función, pero los parámetros en Bash son un dolor, y paso de perder el tiempo haciendo un código de muy alta calidad.
#			
truncarBarraCPU(){
	declare -a barraTiempoColor #Array que contiene los string a imprimir, generado en: colorearBarraMemoria. En este caso hemos trabajado con 2 arrays y no con uno, porque soy bobo.
									#PD: no es lo más eficiente, ya que se colorea cada vez, quizá debería hacerlo en el momento, como con la memoria? Dunno m8
	local -i i
	local -i j
	local -i ultimaPosMemEmplazada=0
	local    ultimoIndiceEncontrado=-1

	colorearBarraTiempo

	for (( i=1; i<= (altoLineaTiempoTruncada*3); i+=3 )); do
		for ((j=1; j <= anchoTerminalBloques; j++)); do	#La barra de CPU empieza en 0

			#Volcamos la fila intermedia (barras de color)
			lineaTiempoTruncada[$i,$j]=${barraTiempoColor[$ultimaPosMemEmplazada]}

			#Si no coincide con la última posición: Significa que hay otro proceso -> añadimos ref y tiempo en las líneas.
			if [[ ${lineaEstadoCPU[$ultimaPosMemEmplazada]} -ne $ultimoIndiceEncontrado ]];then
				ultimoIndiceEncontrado=${lineaEstadoCPU[$ultimaPosMemEmplazada]}
				
				#Fila de los nombres
				if [[ $ultimoIndiceEncontrado -eq 0 ]]; then #Si el hueco está vacío (al no haber proceso, CPU vacía en ese instante)
					lineaTiempoTruncada[$((i-1)),$j]="   "
				else
					lineaTiempoTruncada[$((i-1)),$j]=${procesos[$ultimoIndiceEncontrado,$P_NOMBRE]}		#ASIGNAMOS EL NOMBRE ARRIBA DE LA BARRA
				fi

				#Fila de las posiciones
				if [[ $ultimaPosMemEmplazada -lt 10 ]]; then
					lineaTiempoTruncada[$((i+1)),$j]="$ultimaPosMemEmplazada  "	#Metemos espacios al final para que no se descuadre, si el tamaño es >=100, se descuadra
				else															#Sería poner un elif con el tamaño del int, pero me da pereza, pd: he tardado más escribiendo esto
					lineaTiempoTruncada[$((i+1)),$j]="$ultimaPosMemEmplazada "		#que haciendolo, un saludo: Jorge (09/03/2020 - 13:17)
				fi
			else
				lineaTiempoTruncada[$((i-1)),$j]="   "		 #No hay cambio de proceso-> Vacío
				lineaTiempoTruncada[$((i+1)),$j]="   "		 #No hay dirección al no haber cambio de proceso -> Vacío
			fi

			((ultimaPosMemEmplazada++))

			if [[ $ultimaPosMemEmplazada -gt $tiempoEjecucion ]];then break; fi	#Se ha emplazado toda la memoria
		done
			ultimoIndiceEncontrado=-1 #reseteo para que se imprima siempre en cada línea la dirección y el proceso
	done
	
	#Añade los elementos al margen izquierdo
	for (( i=1; i<= (altoLineaTiempoTruncada*3); i+=3 )); do
		lineaTiempoTruncada[$((i-1)),0]="   "
		lineaTiempoTruncada[$((i  )),0]="   "
		lineaTiempoTruncada[$((i+1)),0]="   "
	done
	lineaTiempoTruncada[$((1  )),0]="${NC}BT|"
}

colorearBarraTiempo(){
	local colorProceso
	local colorLetraProceso

	for ((i=0; i< tiempoEjecucion; i++)); do
		if [[ ${lineaEstadoCPU[$i]} -ne 0 ]]; then
			colorProceso=${procesos[${lineaEstadoCPU[$i]},$P_COLOR]}
			colorLetraProceso=${procesos[${lineaEstadoCPU[$i]},$P_COLORLETRA]}
		else
			colorProceso=$_WHITE
			colorLetraProceso=$WHITE
		fi
		barraTiempoColor+=("${colorProceso}${colorLetraProceso}[=]${NC}") #3 espacios porque es el ancho del proceso que desea el profesor
	done
	
}

# Nombre: dibujarEstadoCPU
# Date: 09/03/2020
# Descripción: Imprime el estado de la CPU por pantalla 
dibujarEstadoCPU(){
	local -i
	declare -i anchoTerminal=$(tput cols) #En columnas
	declare -i anchoTerminalBloques=$((anchoTerminal/3 - 1)) #Bloques -> bloques de memoria. Un bloque/unidad de memoria se representa con 3 espacios/columnas de un color || restamos 1 unidad para dejar margen para maniobrar
	declare -A lineaTiempoTruncada
	declare -i altoLineaTiempoTruncada
	
	#Calculamos el alto de memoria (el número de filas que ocupará truncada)
	if [[ $((tiempoEjecucion%anchoTerminalBloques)) == 0 ]];then
		if [[ tiempoEjecucion -eq 0 ]]; then #Con tiempo 0 la CPU está vacía, pero queremos mostrarla, por lo que hay que forzar el valor a 1
			altoLineaTiempoTruncada=1
		else
			altoLineaTiempoTruncada=$((tiempoEjecucion/anchoTerminalBloques))
		fi
	else	#Si la memoria ocupa parte de una líena, la asignamos entera
		altoLineaTiempoTruncada=$(( ( tiempoEjecucion/anchoTerminalBloques ) + 1 ))
	fi

	truncarBarraCPU

	for (( i= 0; i<= 3*altoLineaTiempoTruncada; i++ ));do
		for (( j=0; j<=anchoTerminalBloques ; j++));do
			echo -en "${lineaTiempoTruncada[$i,$j]}"
		done
		echo ""
	done
}

# Nombre: ejecucion
# Descripción: Loop central con la ejecución de los procesos
ejecucion(){
	local -i procEjecutados=0
	local -i tiempoEjecucion=0
	local -i i
	local -i haHabidoUnCambio #bool que se usa para ver cuando ha ocurrido un evento. Los eventos suelen imprimir STRINGS especiales!
	local tEjecAcumulado=0
	local tEsperaAcumulado=0
	local tRetornoAcumulado=0
	procesoCPU=0	#int que almacena la fila correspondiente al proceso que está en ejecución 
	#Empieza la ejecucion del programa
	memoriaLibre=$tamMemoria
	vaciarMemoria
	
	medirTiempo "Incio"
	while [[ $procEjecutados -lt $numProc ]]; do # mientras el numero de procesos ejecutados sea menor a procesos total
		
		haHabidoUnCambio=0

		comprobarSiElProcesoEnCPUHaTerminado

		#Si se ha ejecutado el último proceso, paramos el bucle para no tener ejecuciones en blanco
		if [[ $procEjecutados -eq $numProc ]];then
			imprimirLCyan "El último proceso ha sido desalojado con éxito de CPU y Memoria!"
			break
		fi

		
		#Introducimos a la cola los procesos que han llegado a memoria
		for((i=1;i<=numProc;i++)) do
			if [[ ${procesos[$i,$P_TLLEGADA]} -eq "$tiempoEjecucion" ]]; then
				anadirCola $i
				
				printf "${L_MAGENTA}%s ${procesos[$i,$P_COLORLETRA]}%s ${L_MAGENTA}%s ${NC}%d\n" "El proceso" "${procesos[$i,$P_NOMBRE]}" "ha entrado en el sistema en el instante" "$tiempoEjecucion"
				haHabidoUnCambio=1
			fi
		done

		#Volcamos toda la cola en memoria (si cabe)
		while (( tamCola >= 1 )); do
			if [[ ${procesos[${cola[1]},$P_TAMANIO]} -le $memoriaLibre ]]; then
				local -i procesoMem="${cola[1]}" #lo guardamos para poder hacer el printf tras añadir el procesos: Meramente estético (por si hay reubicabilidad, que salga después del mensaje)
				aniadirProcesoAMemoria "$procesoMem"
				printf "${L_GREEN}%s ${procesos[$procesoMem,$P_COLORLETRA]}%s ${L_GREEN}%s ${NC}%d\n" "El proceso" "${procesos[$procesoMem,$P_NOMBRE]}"  "ha sido introducido en memoria en el instante" "$tiempoEjecucion"	
				
				haHabidoUnCambio=1
			else
				break
			fi
		done
		
		#Comprobaciones de CPU
		#Si no hay ningún proceso en CPU, o el proceso ha terminado && hay al menos 1 proc en mem.
		if [[ $procesoCPU -eq 0 ]] && [[ $memoriaLibre -lt $tamMemoria ]]; then
			aniadirSiguienteProcesoACPU
			printf "${L_CYAN}%s ${procesos[$procesoCPU,$P_COLORLETRA]}%s ${L_CYAN}%s${NC} %d ${L_CYAN}%s\n${NC}" "El proceso" "${procesos[$procesoCPU,$P_NOMBRE]}" "ha sido introducido en la CPU en el instante" "$tiempoEjecucion" "y ahora se está ejecutando"
			haHabidoUnCambio=1
		fi

		calcularPosTodosProcesos

		#Si ha habido un cambio/evento en el estado de algún proceso -> Salida por pantalla
		if [[ $haHabidoUnCambio -eq 1 ]] || [[ $tiempoEjecucion -eq 0 ]]; then
			echo "════════════════════════════════════════════════════════════════════════════"
			
			
			imprimirTablaPredeterminada
			echo -e "${B_WHITE}Instante: $tiempoEjecucion | P. más alta: $priorMax | P. más baja: $priorMin ${NC}"
			medirTiempo "dibujando memoria" 
			dibujarMemoria "mostrarStatsMemoria"
			medirTiempo "fin dibujando memoria" "medidas.txt"
			
			dibujarEstadoCPU 
			medirTiempo "fin dibujando CPU" "medidas.txt"
			imprimirLCyan "Número de procesos ejecutados $procEjecutados/$numProc"

			#breakpoint "Fin del loop $tiempoEjecucion del WHILE"
			read -ers -p "Pulse [enter] para continuar "
			echo "════════════════════════════════════════════════════════════════════════════"
			clear
		fi
		ejecutarUnCiloDeCPU
	done

	pantallaFinal(){
		local -i

		for ((i=1; i<=numProc; i++));do
			tEjecAcumulado=$(( tEjecAcumulado + ${procesos[$i,3]}))
			tEsperaAcumulado=$(( tEsperaAcumulado + ${procesos[$i,7]}))
			tRetornoAcumulado=$(( tRetornoAcumulado + ${procesos[$i,8]}))
		done
		echo "════════════════════════════════════════════════════════════════════════════"
		tEjecMedio=$(echo "scale=2;$tEjecAcumulado/$procEjecutados" | bc -l)
		tEsperaMedio=$(echo "scale=2;$tEsperaAcumulado/$procEjecutados" | bc -l)
		tRetornoMedio=$(echo "scale=2;$tRetornoAcumulado/$procEjecutados" | bc -l)

		imprimirTablaPredeterminada
		echo "════════════════════════════════════════════════════════════════════════════"
		echo "Tiempo de ejecución Total: $tiempoEjecucion"
		echo "Prioridad más alta: $priorMax"
		echo "Prioridad más baja: $priorMin"
		imprimirLCyan "Tiempo de ejecución medio: $BOLD$tEjecMedio"
		imprimirLCyan "Tiempo de espera medio: $BOLD$tEsperaMedio"
		imprimirLCyan "Tiempo de retorno medio: $BOLD$tRetornoMedio"
		dibujarMemoria
		dibujarEstadoCPU

		echo -e "\n\n"
	}

	pantallaFinal 
}

# Nombre: abrirInforme
# Descripción: Función con distintas opciones para abrir el informe
# Date: 20/03/2020
abrirInforme(){
	local opcion
	imprimirLCyan "Qué desea visualizar?"
	echo "  1) Informe a color completo (con \$cat)"
	echo "  2) Informe a color con scroll (con \$less, estilo Editor VI)"
	echo "  3) Informe en blanco y negro completo(con \$cat)"
	echo "  4) Informe en blanco y negro con scroll (con \$less, estilo Editor VI)"
	echo "  5) Editar Informe blanco y negro con VIM"
	echo "  6) Editar Informe blanco y negro con NANO"
	echo "  *) Salir"

	read -r opcion

	case $opcion in
	1)
		cat "$INFORME_FILENAME"
	;;
	2)
		less -R "$INFORME_FILENAME"
	;;
	3)
		cat "$INFORMEBN_FILENAME"
	;;
	4)
		less "$INFORMEBN_FILENAME"
	;;
	5)
		vim "$INFORMEBN_FILENAME"
	;;
	6)
		nano "$INFORMEBN_FILENAME"
	;;
	*)
		echo -n ""
	;;
	esac

	
}

# Nombre: renombrarDatosEntrada
# Descripción: Renombra el archivo datos.txt para que los datos no sean borrados en la proxima ejecución
# Date: 19/03/2020
renombrarDatosEntrada(){
	local opcion
	local nombreArchivo
	local -i haFallado=0
	scanfSiNo "¿Desea guardar los datos de entrada con otro nombre? [s/n]:" "opcion"

	if [[ $opcion = s ]]; then
		echo  "Introduzca el nuevo nombre"
		echo  "Recordatorio: Es necesario añadir el formato (.txt) y evitar usar Slashes [ / ], ya que son tomadas como un directorio"
		read -r "nombreArchivo"

		cat "${DATA_DIRECTORY}datos.txt" > "${DATA_DIRECTORY}$nombreArchivo" || haFallado=1 #Se podría hacer con un cp o un move, pero con esto nos ahorramos problemas

		
		if [[ $haFallado -eq 1 ]];then
			renombrarDatosEntrada
		fi
	fi
}
#main
main(){
	
	
	mostrarPantallaInformacion 
	cargaDatos 
	escribeDatos 
	ordenarProcesos
	inicializarArrays
	nularColumna "$P_TRETORNO" "$P_POSINI" "$P_POSFIN" "$P_ESTADO" "$P_TRESTANTE" "$P_TESPERA"
	clear
	imprimirTabla 1 2 3 4 5 
	


	echo -e "
	╔═══════════════════════════════════════╗
	║					║
	║${L_GREEN} Tamaño de Memoria: ${NC}${B_BLUE}$tamMemoria${NC}			║
	║${L_GREEN} Número de Procesos: ${NC}${B_BLUE}$numProc ${NC}		║
	║${L_GREEN} Prioridad Mínima: ${NC}${B_BLUE}$priorMin${NC}			║
	║${L_GREEN} Prioridad Máxima: ${NC}${B_BLUE}$priorMax${NC}			║
	║					║
	╚═══════════════════════════════════════╝"
	
	imprimirLCyan "Pulse [enter] para continuar" -n
	read -ers

	clear
	ejecucion 
}
# Nombre: finMain
# Descripción: Es la función que se ejecuta tras el main (en global)
# 	Todas las salidas de main se ven reflejadas en el archivo $INFORME_FILENAME, pero como no queremos todas, aislamos el final del programa
# Nota:Si haces el | tee sobre algunas funciones de main, se rompe la ejecución, y si el finMain no se ejecuta desde global, se pierden los parámetros globales 
finMain(){
	convertirFicheroColorEnBlancoNegro $INFORME_FILENAME $INFORMEBN_FILENAME "false"
	renombrarDatosEntrada
	abrirInforme
}

comprobacionDirectorio stringDeBúsqueda, no tiene valor alguno
global #Carga las variables globales y ejecuta el main -> Está hecho así para poder minimizar todas las variables de global en el outline de VSCODE
