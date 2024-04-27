#!/bin/bash
#
#                       
#   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos 
#	TUTOR: José Manuel Saiz Diez
#  
#
# Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.
# El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
# La gestión de memoria será paginada y podrá ser Continua y No continua, y Reubicable y no resubicable.
# Y los algoritmos de paginación para la gestión de memoria junto con alguna de sus variantes: FIFO/Reloj/SegOp/Óptimo/MFU/LFU/NFU/MRU/LRU/NRU. 

#
# VARIABLES DE EJECUCIÓN
#
# seleccionMenuAlgoritmoGestionProcesos - Opciones de elección de algoritmo de gestión de Procesos (FCFS/SJF/SRPT/Prioridades/Round-Robin)
# seleccionTipoPrioridad - Opciones del tipo de Prioridad (Mayor/Menor)
# seleccionMenuApropiatividad - Opciones del tipo de Apropiatividad (Apropiativo/No Apropiativo)
# seleccionMenuReubicabilidad - Opciones del tipo de memoria (Reubicable/No Reubicable)
# seleccionMenuContinuidad - Opciones del tipo de memoria (Continua/No Continua)
# seleccionMenuEleccionEntradaDatos - Opciones para la elección de fuente en la introducción de datos (Datos manual/Fichero de datos de última ejecución/Fichero de datos por defecto/Otro fichero de datos...
# .../Rangos manual/Fichero de rangos de última ejecución/Fichero de rangos por defecto/Otro fichero de rangos...
# .../Rangos aleatorios manual/Fichero de rangos aleatorios de última ejecución/Fichero de rangos aleatorios por defecto/Otro fichero de rangos aleatorios)
# seleccionMenuModoTiempoEjecucionAlgormitmo - Opciones para la elección del tipo de ejecución (Por eventos/Automatico/Completo)
# seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
# seleccionMenuPreguntaDondeGuardarRangosManuales - Opciones para la selección del fichero de rangos de salida (rangosDefault, Otros)
# seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación
# seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
# seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
# seleccionAlgoritmoPaginacion_frecuencia_valor - Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
#
# VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
#
# Ancho del terminal en cada Enter de ejecución de volcados
# ancho de columnas estrechas en tabla resumen de procesos en los volcados 
# ancho de columnas anchas en tabla resumen de procesos en los volcados 
# ancho de columnas más anchas en tabla resumen de procesos en los volcados 
# ancho de columnas muy anchas en tabla resumen de procesos en los volcados 
# ancho de columnas estrechas en tabla de rangos 
# ancho de columnas anchas en tabla de rangos 
varhuecos="                                                                                     "
varguiones="------------------------------------------------------------------------------------"
varasteriscos="*********************************************************************************"
varfondos="█████████████████████████████████████████████████████████████████████████████████████"
esc=$(echo -en "\033")
RESET=$esc"[0m"

#
# VARIABLES PARA DESTACAR TEXTO CON COLOR
#
#NORMAL=$esc"[1;m"
#ROJO=$esc"[1;31m"
#VERDE=$esc"[1;32m"
#AMARILLO=$esc"[1;33m"
#AZUL=$esc"[1;34m"
#MORADO=$esc"[1;35m"
#CYAN=$esc"[1;36m"
#Variables de colores 
amarillo="\033[1;33m";
verde='\e[1;32m';
morado='\e[1;35m';
rojo='\e[1;31m';
cian='\e[1;36m';
gris='\e[1;30m';
azul='\e[1;34m';
blanco='\e[1bold;37m';
#reset
#Vector de colores
coloress=();
#
#
#
# foreground magenta
#
#
# foreground blue
# foreground blue
# foreground yellow
#
# foreground red
#
#
#
#
# foreground cyan
#
# foreground green
#
#
#
#INVISIBLE
#Vector de colores con el fondo pintado. 
colorfondo=(); 
# background cyan
#
#
#
#
# background blue
# background yellow
#
# background red
#
# background magenta
# background green
# background white
# ANSI color codes
# hicolor
# underline
# inverse background and foreground
# foreground black
# foreground white
# background black

#
#     Tablas de trabajo (CAMBIAR ARRAYS Y VARIABLES)
#
#     nprocesos - Número total de procesos.
#     proceso() - Nombre del proceso (P01,...).
#     llegada() - Tiempo de llegada de los procesos.
#     ejecucion() - Tiempo de ejecución de los procesos
#     paginasDefinidasTotal(,) - El primer índice recorre los Procesos y el segundo las Páginas de cada Proceso 
#     memoria() - Cuánta memoria necesita cada proceso.
#     temp_wait() - Se acumulan el tiempo de espera.
#     temp_exec() - Se acumulan el tiempo de ejecución. 
#     bloqueados() - Procesos "En espera"
#
#     pos_inicio() - Posición de inicio en memoria.
#     pos_final() - Posición final en memoria. 
#     (Para estos dos arrays (que deberán ser dinámicos) tendrémos los valores de la memoria que están ocupados por un proceso, el valor de inicio en memoria y el valor al final)
#
#     mem_total - Tamaño total de la memoria que se va a usar.
#     mem_libre - Tamaño aún libre de la memoria.
#
#     encola() tendremos qué procesos pueden entrar en memoria. Los valores son:
#       0 : El proceso no ha entrado en la cola (no ha "llegado" - Estado "Fuera del sistema") 
#       1 : El proceso está en la cola (Estado "En espera")
#     enmemoria()  - Procesos que se encuentran en memoria. Los valores son:
#       0 : El proceso no está en memoria
#       1 : El proceso está en memoria esperando a ejecutarse (Estado "En memoria")
#     escrito()  - Procesos que se encuentran en memoria y a los que se les ha encontrado espacio sufiente en la banda de memoria. 
#     ejecucion  - Número de proceso que está ejecutándose (Estado "En ejecución")
#     reloj  - Instante de tiempo que se está tratando en el programa (reloj).
#
#     Estados de los procesos:
#          ${estad[$i]} = 0 - No llegado
#          ${estad[$i]} = 1 - En espera 
#          ${estad[$i]} = 2 - En memoria 
#          ${estad[$i]} = 3 - En ejecución 
#          ${estad[$i]} = 4 - En pausa 
#          ${estad[$i]} = 5 - Terminado

# Declaración de los arrays:
#Contiene el número de unidades de ejecución y será usado para controlar que serán representadas en las bandas.
#Variacble intermedia usada para la creación automática de los nombres de los procesos.
#Nombre de los procesos
#Tiempo de llegada de los procesos
#Tiempo de ejecución de los procesos
#Unidades de memoria asociados a los procesos
#Variable recogida de datos para ordenar el temporal por tiempo de llegada
#Tiempo ya esperado por los procesos
#Tiempo ya ejecutado de los procesos
#Tiempo de retorno de los procesos
#Tiempo restante de ejecución de los procesos
#Posición de inicio de cada hueco de memoria asociado a cada proceso.
#Posición final de cada hueco de memoria asociado a cada proceso.
#Se añade al comentario principal ?????????????????????
#Se añade al comentario principal ?????????????????????
#Estado inicial de los procesos cuando aún no han llegado al sistema.
#Estado de los procesos cuando han llegado al sistema, pero aún no han entrado a la memoria.    
#Estado de los procesos cuando han entrado en memoria, pero aún no han empezado a ejecutarse.
#Estado de los procesos cuando un proceso ya ha empezado a ejecutarse, pero aunque no han terminado de ejecutarse, otro proceso ha comenzado a ejecutarse.
#Estado de los procesos cuando un proceso ya ha empezado a ejecutarse
#Se añade al comentario principal ?????????????????????
#Estado de los procesos cuando ya han terminado de ejecutarse
#Se añade al comentario principal ?????????????????????
#Número asociado a cada estado de los procesos
#Se añade al comentario principal
#Secuencia de los procesos que ocupan cada marco de la memoria completa
#Matriz auxiliar de la memoria no continua (para reubicar)
#bandera para no escibir dos veces un proceso en memoria
#para guardar en cuantos bloques se fragmenta un proceso
#posición inicial de cada bloque en la memoria NO CONTINUA
#posición final de cada bloque en la memoria NO CONTINUA
#posición inicial en la memoria NO CONTINUA para impresiones (cuadrado en tabla)
#posición final en la memoria NO CONTINUA para impresiones (cuadrado en tabla)
#borrar posiciones innecesarias tras la impresión
#borrar posiciones innecesarias tras la impresión
#Para saber si un proceso en la barra de tiempo está nombrado, si se ha introducido en las variables de las diferentes líneas.
#bandera para saber si hay un proceso anterior que finalizar de dibujar
#Contiene el proceso que se esté tratando en la asignación de dígitos en la representación de la banda de tiempo
#Guarda de uno en uno los colores para cada caracter de la barra de memoria (necesario impresión ventana)
#Guarda de uno en uno los colores para cada caracter de la línea del tiempo (necesario impresión ventana)
#Array que va a guardar el orden de la reubicacion
#Array que guarda en orden de reubicación la memoria que ocupan
#Si vale 0 no es reubicable. Si vale 1 es reubicable.
#Si vale 0 es no continua. Si vale 1 es continua.
#En cada casilla (instante actual - reloj) se guarda el número de orden del proceso que se ejecuta en cada instante.
#Usada en gestionProcesosSRPT para determinar la anteriorproceso en ejecución que se compara con el actual tiempo restante de ejecución más corto y que va a ser definida como el actual proceso en ejecución.
#Direcciones definidas de todos los Proceso (Índices:Proceso, Direcciones).
#Páginas definidas de todos los Proceso (Índices:Proceso, Páginas).
#Número de Páginas ya usadas de cada Proceso.
#Secuencia de Páginas ya usadas de cada Proceso.
#Páginas ya usadas del Proceso en ejecución. Sale de forma secuencial de paginasDefinidasTotal.
#Páginas pendientes de ejecutar del Proceso en ejecución. Sale de forma secuencial de paginasDefinidasTotal. 
#Siguiente Página a ejecutar del Proceso en ejecución. Sale de forma secuencial de paginasDefinidasTotal con el delimitador de numeroPaginasUsadasProceso.
#Páginas residentes en memoria del Proceso en ejecución. Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#Páginas residentes en memoria de cada Proceso (Índices:Proceso,número ordinal de marco asociado). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#Contiene el número de Marcos de Memoria con Páginas ya dibujadas de cada Proceso.
#Fallos de página totales de cada proceso.
#Desde 0, es el ordinal del número de marcos en memoria asociados a cada proceso (Índices:Proceso)

#Resumen - Índices: (proceso). Dato: Número de Marcos usados en cada Proceso.
#Resumen - Índices: (tiempo). Dato: Proceso que se ejecuta en cada instante de tiempo real (reloj).
#Resumen - Índices: (proceso, tiempo de ejecución). Dato: Tiempo de reloj en el que se ejecuta un Proceso.
#Resumen - Índices: (proceso, marco, reloj). Dato: Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Resumen - Índices: (proceso, marco, reloj). Dato: Frecuencia de la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Resumen - Índices: (proceso, reloj). Dato: Marco (Puntero) sobre el que se produce el siguiente fallo para todos los Procesos en cada unidad de Tiempo.
#Resumen - Índices: (proceso, tiempo). Dato: Marco usado (Puntero) para cada Proceso en cada unidad de Tiempo.
#Resumen - Índices: (marco, tiempo). Dato: Texto a iprimir en Color con el seguimiento del uso de los Marcos a lo largo del Tiempo (página-frecuencia).
#Resumen - Índices: (marco, tiempo). Dato: Texto a iprimir en Blanco-Negro con el seguimiento del uso de los Marcos a lo largo del Tiempo (página-frecuencia).
#Resumen - Índices: (proceso, tiempo, número ordinal de marco). Dato: Relación de Marcos asignados al Proceso en ejecución en cada unidad de tiempo. El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
#Resumen - Índices: (proceso). Dato: Último instante (reloj) en que cada proceso usó una página para realizar los acumulados de páginas y frecuencias de todos los procesos/marcos.
#Resumen - Índices: (proceso, tiempo). Dato: Páginas que produjeron Fallos de Página del Proceso en ejecución.
#Resumen - Índices: (proceso, tiempo). Dato: Marcos donde se produjeron Fallos de Página del Proceso en ejecución.
#Resumen - Índices: (proceso). Dato: Número de Fallos de Página de cada Proceso.
#Resumen - Índices: (proceso). Dato: Número de Expulsiones Forzadas de cada Proceso.
#Resumen - Índices: (proceso). Dato: Número memor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#Resumen - Índices: (proceso). Dato: Número mayor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#Resumen - Índices: (proceso). Dato: Número de las posiciones con la memor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#Resumen - Índices: (proceso). Dato: Número de las posiciones con la mayor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#Resumen - Índices: (proceso). Dato: Número memor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#Resumen - Índices: (proceso). Dato: Número mayor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#Resumen - Índices: (proceso). Dato: Número de las posiciones con la memor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#Resumen - Índices: (proceso). Dato: Número de las posiciones con la mayor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#Resumen - Índices: (proceso, ordinal de página, reloj (0)). Dato: Se usará para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
#Resumen - Índices: (proceso, marco). Dato: Se usará para determinar si una página ha sido o no referenciada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
#Resumen - Índices: (proceso, tiempo de ejecución). Dato: Página referenciada (1) o no referenciada (0).
#Resumen - Índices: (proceso, ordinal del tiempo de ejecución). Dato: Página modificada (1) o no modificada (0).
#Resumen - Índices: (proceso). Dato: Ordinal del tiempo de ejecución en el que se hizo el último cambio de clase máxima.
#Resumen - Índices: (proceso, marco). Dato: Histórico con el valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Resumen - Índices: (proceso, marco). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
#Resumen - Índices: (proceso, marco). Dato: Histórico con el tiempo con inicialización a 0 cuando se inicializa $ResuTiempoProcesoUnidadEjecucion_MarcoPaginaClase_valor por cambio de la clase, o por inicialización de la frecuencia por llegar a su máximo, para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación	
#Resumen - Índices: (proceso, marco, reloj). Dato: Histórico con la resta de las frecuencias de ambos momentos para ver si supera el valor límite máximo.
#Resumen - Índices: (proceso, marco, tiempo). Dato: Clase de la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el coeficiente M de los algoritmos de Segunda Oportunidad con valor 0 cuando se inicializa o cuando se permite su mantenimiento, aunque le toque para el fallo de paginación, y 1 como premio cuando se reutiliza.	
#Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo que hay hasta la reutilización de la página contenida en el marco.	
#Índice: (proceso). Dato: Contiene el orden de ejecución de Round-Robin (RR). Será "-" mientras no esté en cola, o cuando haya terminado, y si aún no ha terminado contendrá el número ordinal del siguiente quantum. El proceso a ejecutar será, por tanto, el que tenga el número ordinal más bajo. Y el número de quantums realizados (cambios de contexto, será el número ordinal más alto.

#Variables para la impresión de volcados
#Variables para la impresión de volcados
#Variables para la impresión de volcados
#Variables para la impresión de volcados
#Variables para la impresión de volcados
#Variables para la impresión de volcados
#Variables para la impresión de volcados
#Variables para la impresión de volcados
#Variables para la impresión de volcados
#Variables para la impresión de volcados
#Variables para la impresión de volcados
#Variables para la impresión de volcados

#
# Ficheros de salida. 
#
dirFLast="./FLast"
dirFDatos="./FDatos"
dirFRangos="./FRangos"
dirFRangosAleT="./FRangosAleT"
dirInformes="./Informes"
#Informe en blanco/negro de todo lo visto en pantalla.
#Informe a color de todo lo visto en pantalla.

#Datos de particiones y procesos de la ejecución anterior.
#Datos de particiones y procesos de la copia estándar (por defecto).

#Rangos de particiones y procesos de la ejecución anterior.
#Rangos de particiones y procesos de la copia estándar (por defecto).

#Rangos amplios de particiones y procesos de la ejecución anterior para la extracción de subrangos.
#Rangos amplios de particiones y procesos de la copia estándar (por defecto) para la extracción de subrangos.

#Se inicializa la variable de fichero de datos
#Se inicializa la variable de fichero de rangos
#Se inicializa la variable de fichero de rangos amplios  

#
#
#             FUNCIONES
#
# Sinopsis: Al inicio del programa muestra la cabecera por pantalla y la envía a los informes de B/N y COLOR. 
#
function presentacionPantallaInforme {
    clear
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#La opción -a lo crea inicialmente
    DIA=$(date +"%d/%m/%Y")
    HORA=$(date +"%H:%M")
    echo -e $NORMAL" ÚLTIMA EJECUCIÓN: $DIA - $HORA\n" | tee -a $informeConColorTotal

#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#La opción > lo crea inicialmente
    DIA=$(date +"%d/%m/%Y")
    HORA=$(date +"%H:%M")
    echo -e " ÚLTIMA EJECUCIÓN: $DIA - $HORA\n" >> $informeSinColorTotal

	echo -ne $ROJO"\n\n Pulsa ENTER para continuar "$NORMAL
	read enter
}

#
# Sinopsis: Cabecera de inicio 
#
function cabecerainicio {
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n"\
#$NC\n" | tee -a $informeConColorTotal
#\n"\
#\n"\
#\n"\
#\n"\
#\n"\
#\n" >> $informeSinColorTotal
#Fin de cabecerainicio()

#
# Sinopsis: Menú inicial con ayuda y ejecución
#
function menuInicio {
#	clear
	cabecerainicio
	echo -ne "\n MENÚ INICIO\n"\
	"\n  1. Ejecutar el algoritmo - Memoria NO Virtual - Paginación Simple\n"\
	"\n  2. Ejecutar el algoritmo - Memoria Virtual - Paginación - Algoritmos de Reemplazo de Páginas\n"\
    "\n  3. Menú de ayuda (requiere 'evince' para los ficheros PDF, o 'mplayer' para los ficheros de vídeo)\n"\
    "\n  4. Crear informe de código mediante zshelldoc\n"\
	"\n  5. Salir\n\n"\
	"Introduce: " | tee -a $informeConColorTotal $informeSinColorTotal
	read seleccionMenuInicio
	until ([[ $seleccionMenuInicio > 0 && $seleccionMenuInicio < 6 ]]) || [[ $seleccionMenuInicio = 33 ]]; do
        echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
        read seleccionMenuInicio
        echo -e "$seleccionMenuInicio\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuInicio\n\n" >> $informeSinColorTotal
	done
	case "$seleccionMenuInicio" in
		'1')
#Menú de elección de algoritmo de gestión de procesos. 
#Menú de elección de continuidad.
#Menú de elección de reubicabilidad.
			seleccionAlgoritmoPaginacion=0
#Menú de elección de entrada de datos.
			;;
		'2')
#Menú de elección de algoritmo de gestión de procesos. 
#Menú de elección de continuidad.
#Menú de elección de reubicabilidad.
#Menú de elección del algoritmo de paginación.
#Menú de elección de entrada de datos.
			;;
        '3')
#Permite ver los ficheros de ayuda en formato PDF y de vídeo
            ;;
        '4')
            echo $0
            echo " El informe resultante es ./zsdoc/$0.adc junto con el subdirectorio ./zsdoc/data." | tee -a $informeConColorTotal
            echo " El informe resultante es ./zsdoc/$0.adc junto con el subdirectorio ./zsdoc/data." >> $informeSinColorTotal
            echo " Si el formato no es el adecuado o para estandarizar ese formato, se puede imprimir o transformar el documento a fichero pdf." | tee -a $informeConColorTotal
            echo " Si el formato no es el adecuado o para estandarizar ese formato, se puede imprimir o transformar el documento a fichero pdf." >> $informeSinColorTotal
#...O el directorio que se corresponda con la localización de zshelldoc, dependiendo de dónde se haya instalado
            exit 0
            ;;
		'5')
			echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
			exit 0 ;;
		'33')
#Menú de elección de opciones de ensayos de los algoritmos de gestión de procesos y paginación y tomas de datos. 
			;;
#No es necesario. Existe por si se modifica y no se revisa el until anterior.
			echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
			echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal ;;
	esac
#Fin de menuInicio()

#
# Sinopsis: Menú de ayuda con ficheros PDF y de vídeo
#
function menuAyuda {
#	clear
	cabecerainicio
	echo -ne "\n MENÚ DE AYUDA\n"\
    "\n  1. Ver documentos de ayuda del en formato PDF desde el listado de problemas (requiere 'evince')\n"\
    "\n  2. Ver documentos de ayuda en formato PDF desde el listado de ficheros (requiere 'evince')\n"\
    "\n  3. Ver documentos de ayuda en formato Vídeo desde el listado de problemas (requiere 'mplayer')\n"\
    "\n  4. Ver documentos de ayuda en formato Vídeo desde el listado de ficheros (requiere 'mplayer')\n"\
	"\n  5. Salir\n\n"\
	"Introduce: " | tee -a $informeConColorTotal $informeSinColorTotal
	read seleccionMenuInicio
	until [[ $seleccionMenuInicio > 0 && $seleccionMenuInicio < 6 ]]; do
        echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
        read seleccionMenuInicio
        echo -e "$seleccionMenuInicio\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuInicio\n\n" >> $informeSinColorTotal
	done
	case "$seleccionMenuInicio" in
        '1')
            menuDOCPDF
            ;;
#Un fichero a elegir
			echo -e "\n\nFicheros de ayuda existentes en formato PDF:\n$NORMAL" | tee -a $informeConColorTotal
			echo -e "\n\nFicheros de ayuda existentes en formato PDF:\n" >> $informeSinColorTotal 
			files=("./DOCPDF"/*)
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
				echo -e "$i) ${files[$i]}" | tee -a $informeConColorTotal
				echo -e "$i) ${files[$i]}" >> $informeSinColorTotal 
			done
			echo -ne "\n$AMARILLO\n\nIntroduce el número correspondiente al fichero elegido: $NORMAL" | tee -a $informeConColorTotal
			echo -ne "\n\n\nIntroduce el número correspondiente al fichero elegido: " >> $informeSinColorTotal 
			read -r numeroFicheroPDF
#files[@]} ]]; do
				echo -ne "Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
				echo -ne "Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
				read -r numeroFicheroPDF
				echo -e "$numeroFicheroPDF\n\n" >> $informeConColorTotal
				echo -e "$numeroFicheroPDF\n\n" >> $informeSinColorTotal
			done
			echo "$numeroFicheroPDF" >> $informeConColorTotal
			echo "$numeroFicheroPDF" >> $informeSinColorTotal
			ficheroParaLecturaPDF="${files[$numeroFicheroPDF]}"
            evince $ficheroParaLecturaPDF
            menuInicio
            ;;
        '3')
            menuDOCVideo
            ;;
        '4')
			echo -e "\n\nFicheros de ayuda existentes en formato de Vídeo:\n$NORMAL" | tee -a $informeConColorTotal
			echo -e "\n\nFicheros de ayuda existentes en formato de Vídeo:\n" >> $informeSinColorTotal 
			files=("./DOCVideo"/*)
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
				echo -e "$i) ${files[$i]}" | tee -a $informeConColorTotal
				echo -e "$i) ${files[$i]}" >> $informeSinColorTotal 
			done
			echo -ne "\n$AMARILLO\n\nIntroduce el número correspondiente al fichero elegido: $NORMAL" | tee -a $informeConColorTotal
			echo -ne "\n\n\nIntroduce el número correspondiente al fichero elegido: " >> $informeSinColorTotal 
			read -r numeroFicheroVideo
#files[@]} ]]; do
				echo -ne "Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
				echo -ne "Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
				read -r numeroFicheroVideo
				echo -e "$numeroFicheroVideo\n\n" >> $informeConColorTotal
				echo -e "$numeroFicheroVideo\n\n" >> $informeSinColorTotal
			done
			echo "$numeroFicheroVideo" >> $informeConColorTotal
			echo "$numeroFicheroVideo" >> $informeSinColorTotal
			ficheroParaLecturaVideo="${files[$numeroFicheroVideo]}"
            mplayer $ficheroParaLecturaVideo
            menuInicio
            ;;
		'5')
			echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
			exit 0 ;;
#No es necesario. Existe por si se modifica y no se revisa el until anterior.
			echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
			echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal ;;
	esac
#Fin de menuAyuda()

#
# Sinopsis: Menú inicial con ayuda y ejecución
#
function menuEnsayos {
#	clear
	cabecerainicio
	echo -ne "\n ¿Quieres leer el fichero de ayuda, o ejecutar el algoritmo?\n"\
	"\n  1. Ejecución automática de los distintos algoritmos de paginación sobre diferentes conjuntos de datos, para localizar errores en el código\n"\
	"\n  2. Ejecución automática de los distintos algoritmos de paginación sobre iguales conjuntos de datos, para el análisis de resultados\n"\
	"\n  3. Ejecución automática de los distintos algoritmos de paginación sobre iguales conjuntos de datos ya definidos anteriormente, para el análisis de resultados\n"\
	"\n  4. Ejecución automática de los distintos algoritmos de gestión de procesos sobre los distintos algoritmos de paginación sobre iguales conjuntos de datos ya definidos anteriormente, para el análisis de resultados\n"\
	"\n  5. Salir\n\n"\
	"Introduce: " | tee -a $informeConColorTotal $informeSinColorTotal
	read seleccionMenuEnsayos
	until [[ $seleccionMenuEnsayos > 0 && $seleccionMenuEnsayos < 6 ]]; do
        echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
        read seleccionMenuEnsayos
        echo -e "$seleccionMenuEnsayos\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuEnsayos\n\n" >> $informeSinColorTotal
	done
	case "$seleccionMenuEnsayos" in
		'1')
#Menú de elección de algoritmo de gestión de procesos. 
#Menú de elección de continuidad.
#Menú de elección de reubicabilidad.
#Menú de elección del número de ensayos automáticos a realizar de forma continua.
#Se definen y ejecutan los ensayos automáticos y se recogen los datos en ficheros secuenciales.
			;;
		'2')
#Menú de elección de algoritmo de gestión de procesos. 
#Menú de elección de continuidad.
#Menú de elección de reubicabilidad.
#Menú de elección del número de ensayos automáticos a realizar de forma continua.
#Se definen y ejecutan los ensayos automáticos y se recogen los datos en ficheros secuenciales.
			;;
		'3')
#Menú de elección de algoritmo de gestión de procesos. 
#Menú de elección de continuidad.
#Menú de elección de reubicabilidad.
#Menú de elección del número de ensayos automáticos a realizar de forma continua.
#Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos sobre los diferentes algoritmos de paginación y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
			;;
		'4') 
#Menú de elección del número de ensayos automáticos a realizar de forma continua.
#Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos sobre los diferentes algoritmos de gestión de procesos y de paginación y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
#Se vuelve a inicial la aplicación
			;;
		'5')
			echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
			exit 0 ;;
#No es necesario. Existe por si se modifica y no se revisa el until anterior.
			echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
			echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal ;;
	esac
#Fin de menuEnsayos()

#
# Sinopsis: Menú de elección del Algoritmo de Gestión de Procesos; FCFS, SJF, SRPT.
#
function menuDOCPDF { 
#    clear
    cabecerainicio
    echo -ne $AMARILLO"\n MENÚ DE ELECCIÓN DE DOCUMENTOS DE AYUDA (Texto en formato PDF - Necesita 'evince')\n"$NORMAL | tee -a $informeConColorTotal
    echo -ne "\n MENÚ DE ELECCIÓN DE DOCUMENTOS DE AYUDA (Texto en formato PDF - Necesita 'evince')\n" >> $informeSinColorTotal
    echo -ne "\n  1. FCFS-Paginación-FIFO-Continua-Reubicable (Pendiente)"\
    "\n  2. FCFS-Paginación-FIFO-Continua-No Reubicable"\
    "\n  3. FCFS-Paginación-FIFO-No Continua-Reubicable"\
    "\n  4. FCFS-Paginación-FIFO-No Continua-No Reubicable (Pendiente)"\
    "\n  5. FCFS-Paginación-Reloj-Continua-Reubicable"\
    "\n  6. FCFS-Paginación-Reloj-Continua-No Reubicable"\
    "\n  7. FCFS-Paginación-Reloj-No Continua-Reubicable (Pendiente)"\
    "\n  8. FCFS-Paginación-Reloj-No Continua-No Reubicable"\
    "\n  9. FCFS-Paginación-Segunda Oportunidad-Continua-Reubicable (Pendiente)"\
    "\n  10. FCFS-Paginación-Segunda Oportunidad-Continua-No Reubicable"\
    "\n  11. FCFS-Paginación-Segunda Oportunidad-No Continua-Reubicable (Pendiente)"\
    "\n  12. FCFS-Paginación-Segunda Oportunidad-No Continua-No Reubicable (Pendiente)"\
    "\n  13. FCFS-Paginación-Óptimo-Continua-Reubicable"\
    "\n  14. FCFS-Paginación-Óptimo-Continua-No Reubicable (Pendiente)"\
    "\n  15. FCFS-Paginación-Óptimo-No Continua-Reubicable (Pendiente)"\
    "\n  16. FCFS-Paginación-Óptimo-No Continua-No Reubicable (Pendiente)"\
    "\n  17. FCFS-Paginación-MFU-Continua-Reubicable (Pendiente)"\
    "\n  18. FCFS-Paginación-MFU-Continua-No Reubicable"\
    "\n  19. FCFS-Paginación-MFU-No Continua-Reubicable"\
    "\n  20. FCFS-Paginación-MFU-No Continua-No Reubicable"\
    "\n  21. FCFS-Paginación-LFU-Continua-Reubicable (Pendiente)"\
    "\n  22. FCFS-Paginación-LFU-Continua-No Reubicable"\
    "\n  23. FCFS-Paginación-LFU-No Continua-Reubicable (Pendiente)"\
    "\n  24. FCFS-Paginación-LFU-No Continua-No Reubicable"\
    "\n  25. FCFS-Paginación-NFU-Continua-Reubicable (Pendiente)"\
    "\n  26. FCFS-Paginación-NFU-Continua-No Reubicable (Pendiente)"\
    "\n  27. FCFS-Paginación-NFU-No Continua-Reubicable (Pendiente)"\
    "\n  28. FCFS-Paginación-NFU-No Continua-No Reubicable"\
    "\n  29. FCFS-Paginación-MRU-Continua-Reubicable (Pendiente)"\
    "\n  30. FCFS-Paginación-MRU-Continua-No Reubicable (Pendiente)"\
    "\n  31. FCFS-Paginación-MRU-No Continua-Reubicable (Pendiente)"\
    "\n  32. FCFS-Paginación-MRU-No Continua-No Reubicable (Pendiente)"\
    "\n  33. FCFS-Paginación-LRU-Continua-Reubicable (Pendiente)"\
    "\n  34. FCFS-Paginación-LRU-Continua-No Reubicable (Pendiente)"\
    "\n  35. FCFS-Paginación-LRU-No Continua-Reubicable (Pendiente)"\
    "\n  36. FCFS-Paginación-LRU-No Continua-No Reubicable"\
    "\n  37. FCFS-Paginación-NRU-Continua-Reubicable (Pendiente)"\
    "\n  38. FCFS-Paginación-NRU-Continua-No Reubicable (Pendiente)"\
    "\n  39. FCFS-Paginación-NRU-No Continua-Reubicable (Pendiente)"\
    "\n  40. FCFS-Paginación-NRU-No Continua-No Reubicable (Pendiente)"\
    "\n  41. SJF-Paginación-FIFO-Continua-Reubicable (Pendiente)"\
    "\n  42. SJF-Paginación-FIFO-Continua-No Reubicable"\
    "\n  43. SJF-Paginación-FIFO-No Continua-Reubicable"\
    "\n  44. SJF-Paginación-FIFO-No Continua-No Reubicable (Pendiente)"\
    "\n  45. SJF-Paginación-Reloj-Continua-Reubicable (Pendiente)"\
    "\n  46. SJF-Paginación-Reloj-Continua-No Reubicable (Pendiente)"\
    "\n  47. SJF-Paginación-Reloj-No Continua-Reubicable (Pendiente)"\
    "\n  48. SJF-Paginación-Reloj-No Continua-No Reubicable"\
    "\n  49. SJF-Paginación-Segunda Oportunidad-Continua-Reubicable (Pendiente)"\
    "\n  50. SJF-Paginación-Segunda Oportunidad-Continua-No Reubicable"\
    "\n  51. SJF-Paginación-Segunda Oportunidad-No Continua-Reubicable (Pendiente)"\
    "\n  52. SJF-Paginación-Segunda Oportunidad-No Continua-No Reubicable (Pendiente)"\
    "\n  53. SJF-Paginación-Óptimo-Continua-Reubicable"\
    "\n  54. SJF-Paginación-Óptimo-Continua-No Reubicable (Pendiente)"\
    "\n  55. SJF-Paginación-Óptimo-No Continua-Reubicable (Pendiente)"\
    "\n  56. SJF-Paginación-Óptimo-No Continua-No Reubicable (Pendiente)"\
    "\n  57. SJF-Paginación-MFU-Continua-Reubicable (Pendiente)"\
    "\n  58. SJF-Paginación-MFU-Continua-No Reubicable"\
    "\n  59. SJF-Paginación-MFU-No Continua-Reubicable"\
    "\n  60. SJF-Paginación-MFU-No Continua-No Reubicable"\
    "\n  61. SJF-Paginación-LFU-Continua-Reubicable (Pendiente)"\
    "\n  62. SJF-Paginación-LFU-Continua-No Reubicable"\
    "\n  63. SJF-Paginación-LFU-No Continua-Reubicable (Pendiente)"\
    "\n  64. SJF-Paginación-LFU-No Continua-No Reubicable"\
    "\n  65. SJF-Paginación-NFU-Continua-Reubicable (Pendiente)"\
    "\n  66. SJF-Paginación-NFU-Continua-No Reubicable (Pendiente)"\
    "\n  67. SJF-Paginación-NFU-No Continua-Reubicable (Pendiente)"\
    "\n  68. SJF-Paginación-NFU-No Continua-No Reubicable"\
    "\n  69. SJF-Paginación-MRU-Continua-Reubicable (Pendiente)"\
    "\n  70. SJF-Paginación-MRU-Continua-No Reubicable (Pendiente)"\
    "\n  71. SJF-Paginación-MRU-No Continua-Reubicable (Pendiente)"\
    "\n  72. SJF-Paginación-MRU-No Continua-No Reubicable (Pendiente)"\
    "\n  73. SJF-Paginación-LRU-Continua-Reubicable (Pendiente)"\
    "\n  74. SJF-Paginación-LRU-Continua-No Reubicable (Pendiente)"\
    "\n  75. SJF-Paginación-LRU-No Continua-Reubicable (Pendiente)"\
    "\n  76. SJF-Paginación-LRU-No Continua-No Reubicable"\
    "\n  77. SJF-Paginación-NRU-Continua-Reubicable (Pendiente)"\
    "\n  78. SJF-Paginación-NRU-Continua-No Reubicable (Pendiente)"\
    "\n  79. SJF-Paginación-NRU-No Continua-Reubicable (Pendiente)"\
    "\n  80. SJF-Paginación-NRU-No Continua-No Reubicable (Pendiente)"\
    "\n  81. SRPT-Paginación-FIFO-Continua-Reubicable (Pendiente)"\
    "\n  82. SRPT-Paginación-FIFO-Continua-No Reubicable (Pendiente)"\
    "\n  83. SRPT-Paginación-FIFO-No Continua-Reubicable"\
    "\n  84. SRPT-Paginación-FIFO-No Continua-No Reubicable (Pendiente)"\
    "\n  85. SRPT-Paginación-Reloj-Continua-Reubicable (Pendiente)"\
    "\n  86. SRPT-Paginación-Reloj-Continua-No Reubicable (Pendiente)"\
    "\n  87. SRPT-Paginación-Reloj-No Continua-Reubicable (Pendiente)"\
    "\n  88. SRPT-Paginación-Reloj-No Continua-No Reubicable (Pendiente)"\
    "\n  89. SRPT-Paginación-Segunda Oportunidad-Continua-Reubicable (Pendiente)"\
    "\n  90. SRPT-Paginación-Segunda Oportunidad-Continua-No Reubicable (Pendiente)"\
    "\n  91. SRPT-Paginación-Segunda Oportunidad-No Continua-Reubicable"\
    "\n  92. SRPT-Paginación-Segunda Oportunidad-No Continua-No Reubicable"\
    "\n  93. SRPT-Paginación-Óptimo-Continua-Reubicable"\
    "\n  94. SRPT-Paginación-Óptimo-Continua-No Reubicable"\
    "\n  95. SRPT-Paginación-Óptimo-No Continua-Reubicable"\
    "\n  96. SRPT-Paginación-Óptimo-No Continua-No Reubicable"\
    "\n  97. SRPT-Paginación-MFU-Continua-Reubicable"\
    "\n  98. SRPT-Paginación-MFU-Continua-No Reubicable"\
    "\n  99. SRPT-Paginación-MFU-No Continua-Reubicable"\
    "\n  100. SRPT-Paginación-MFU-No Continua-No Reubicable"\
    "\n  101. SRPT-Paginación-LFU-Continua-Reubicable"\
    "\n  102. SRPT-Paginación-LFU-Continua-No Reubicable"\
    "\n  103. SRPT-Paginación-LFU-No Continua-Reubicable"\
    "\n  104. SRPT-Paginación-LFU-No Continua-No Reubicable"\
    "\n  105. SRPT-Paginación-NFU-Continua-Reubicable"\
    "\n  106. SRPT-Paginación-NFU-Continua-No Reubicable"\
    "\n  107. SRPT-Paginación-NFU-No Continua-Reubicable"\
    "\n  108. SRPT-Paginación-NFU-No Continua-No Reubicable"\
    "\n  109. SRPT-Paginación-MRU-Continua-Reubicable"\
    "\n  110. SRPT-Paginación-MRU-Continua-No Reubicable"\
    "\n  111. SRPT-Paginación-MRU-No Continua-Reubicable"\
    "\n  112. SRPT-Paginación-MRU-No Continua-No Reubicable"\
    "\n  113. SRPT-Paginación-LRU-Continua-Reubicable"\
    "\n  114. SRPT-Paginación-LRU-Continua-No Reubicable"\
    "\n  115. SRPT-Paginación-LRU-No Continua-Reubicable"\
    "\n  116. SRPT-Paginación-LRU-No Continua-No Reubicable"\
    "\n  117. SRPT-Paginación-NRU-Continua-Reubicable"\
    "\n  118. SRPT-Paginación-NRU-Continua-No Reubicable"\
    "\n  119. SRPT-Paginación-NRU-No Continua-Reubicable"\
    "\n  120. SRPT-Paginación-NRU-No Continua-No Reubicable"\
    "\n  121. PrioridadMayorMenor-Paginación-FIFO-Continua-Reubicable"\
    "\n  122. PrioridadMayorMenor-Paginación-FIFO-Continua-No Reubicable"\
    "\n  123. PrioridadMayorMenor-Paginación-FIFO-No Continua-Reubicable"\
    "\n  124. PrioridadMayorMenor-Paginación-FIFO-No Continua-No Reubicable"\
    "\n  125. PrioridadMayorMenor-Paginación-Reloj-Continua-Reubicable"\
    "\n  126. PrioridadMayorMenor-Paginación-Reloj-Continua-No Reubicable"\
    "\n  127. PrioridadMayorMenor-Paginación-Reloj-No Continua-Reubicable"\
    "\n  128. PrioridadMayorMenor-Paginación-Reloj-No Continua-No Reubicable"\
    "\n  129. PrioridadMayorMenor-Paginación-Segunda Oportunidad-Continua-Reubicable"\
    "\n  130. PrioridadMayorMenor-Paginación-Segunda Oportunidad-Continua-No Reubicable"\
    "\n  131. PrioridadMayorMenor-Paginación-Segunda Oportunidad-No Continua-Reubicable"\
    "\n  132. PrioridadMayorMenor-Paginación-Segunda Oportunidad-No Continua-No Reubicable"\
    "\n  133. PrioridadMayorMenor-Paginación-Óptimo-Continua-Reubicable"\
    "\n  134. PrioridadMayorMenor-Paginación-Óptimo-Continua-No Reubicable"\
    "\n  135. PrioridadMayorMenor-Paginación-Óptimo-No Continua-Reubicable"\
    "\n  136. PrioridadMayorMenor-Paginación-Óptimo-No Continua-No Reubicable"\
    "\n  137. PrioridadMayorMenor-Paginación-MFU-Continua-Reubicable"\
    "\n  138. PrioridadMayorMenor-Paginación-MFU-Continua-No Reubicable"\
    "\n  139. PrioridadMayorMenor-Paginación-MFU-No Continua-Reubicable"\
    "\n  140. PrioridadMayorMenor-Paginación-MFU-No Continua-No Reubicable"\
    "\n  141. PrioridadMayorMenor-Paginación-LFU-Continua-Reubicable"\
    "\n  142. PrioridadMayorMenor-Paginación-LFU-Continua-No Reubicable"\
    "\n  143. PrioridadMayorMenor-Paginación-LFU-No Continua-Reubicable"\
    "\n  144. PrioridadMayorMenor-Paginación-LFU-No Continua-No Reubicable"\
    "\n  145. PrioridadMayorMenor-Paginación-NFU-Continua-Reubicable"\
    "\n  146. PrioridadMayorMenor-Paginación-NFU-Continua-No Reubicable"\
    "\n  147. PrioridadMayorMenor-Paginación-NFU-No Continua-Reubicable"\
    "\n  148. PrioridadMayorMenor-Paginación-NFU-No Continua-No Reubicable"\
    "\n  149. PrioridadMayorMenor-Paginación-MRU-Continua-Reubicable"\
    "\n  150. PrioridadMayorMenor-Paginación-MRU-Continua-No Reubicable"\
    "\n  151. PrioridadMayorMenor-Paginación-MRU-No Continua-Reubicable"\
    "\n  152. PrioridadMayorMenor-Paginación-MRU-No Continua-No Reubicable"\
    "\n  153. PrioridadMayorMenor-Paginación-LRU-Continua-Reubicable"\
    "\n  154. PrioridadMayorMenor-Paginación-LRU-Continua-No Reubicable"\
    "\n  155. PrioridadMayorMenor-Paginación-LRU-No Continua-Reubicable"\
    "\n  156. PrioridadMayorMenor-Paginación-LRU-No Continua-No Reubicable"\
    "\n  157. PrioridadMayorMenor-Paginación-NRU-Continua-Reubicable"\
    "\n  158. PrioridadMayorMenor-Paginación-NRU-Continua-No Reubicable"\
    "\n  159. PrioridadMayorMenor-Paginación-NRU-No Continua-Reubicable"\
    "\n  160. PrioridadMayorMenor-Paginación-NRU-No Continua-No Reubicable"\
    "\n  161. Round-Robin(RR)-Paginación-FIFO-Continua-Reubicable"\
    "\n  162. Round-Robin(RR)-Paginación-FIFO-Continua-No Reubicable"\
    "\n  163. Round-Robin(RR)-Paginación-FIFO-No Continua-Reubicable"\
    "\n  164. Round-Robin(RR)-Paginación-FIFO-No Continua-No Reubicable"\
    "\n  165. Round-Robin(RR)-Paginación-Reloj-Continua-Reubicable"\
    "\n  166. Round-Robin(RR)-Paginación-Reloj-Continua-No Reubicable"\
    "\n  167. Round-Robin(RR)-Paginación-Reloj-No Continua-Reubicable"\
    "\n  168. Round-Robin(RR)-Paginación-Reloj-No Continua-No Reubicable"\
    "\n  169. Round-Robin(RR)-Paginación-Segunda Oportunidad-Continua-Reubicable"\
    "\n  170. Round-Robin(RR)-Paginación-Segunda Oportunidad-Continua-No Reubicable"\
    "\n  171. Round-Robin(RR)-Paginación-Segunda Oportunidad-No Continua-Reubicable"\
    "\n  172. Round-Robin(RR)-Paginación-Segunda Oportunidad-No Continua-No Reubicable"\
    "\n  173. Round-Robin(RR)-Paginación-Óptimo-Continua-Reubicable"\
    "\n  174. Round-Robin(RR)-Paginación-Óptimo-Continua-No Reubicable"\
    "\n  175. Round-Robin(RR)-Paginación-Óptimo-No Continua-Reubicable"\
    "\n  176. Round-Robin(RR)-Paginación-Óptimo-No Continua-No Reubicable"\
    "\n  177. Round-Robin(RR)-Paginación-MFU-Continua-Reubicable"\
    "\n  178. Round-Robin(RR)-Paginación-MFU-Continua-No Reubicable"\
    "\n  179. Round-Robin(RR)-Paginación-MFU-No Continua-Reubicable"\
    "\n  180. Round-Robin(RR)-Paginación-MFU-No Continua-No Reubicable"\
    "\n  181. Round-Robin(RR)-Paginación-LFU-Continua-Reubicable"\
    "\n  182. Round-Robin(RR)-Paginación-LFU-Continua-No Reubicable"\
    "\n  183. Round-Robin(RR)-Paginación-LFU-No Continua-Reubicable"\
    "\n  184. Round-Robin(RR)-Paginación-LFU-No Continua-No Reubicable"\
    "\n  185. Round-Robin(RR)-Paginación-NFU-Continua-Reubicable"\
    "\n  186. Round-Robin(RR)-Paginación-NFU-Continua-No Reubicable"\
    "\n  187. Round-Robin(RR)-Paginación-NFU-No Continua-Reubicable"\
    "\n  188. Round-Robin(RR)-Paginación-NFU-No Continua-No Reubicable"\
    "\n  189. Round-Robin(RR)-Paginación-MRU-Continua-Reubicable"\
    "\n  190. Round-Robin(RR)-Paginación-MRU-Continua-No Reubicable"\
    "\n  191. Round-Robin(RR)-Paginación-MRU-No Continua-Reubicable"\
    "\n  192. Round-Robin(RR)-Paginación-MRU-No Continua-No Reubicable"\
    "\n  193. Round-Robin(RR)-Paginación-LRU-Continua-Reubicable"\
    "\n  194. Round-Robin(RR)-Paginación-LRU-Continua-No Reubicable"\
    "\n  195. Round-Robin(RR)-Paginación-LRU-No Continua-Reubicable"\
    "\n  196. Round-Robin(RR)-Paginación-LRU-No Continua-No Reubicable"\
    "\n  197. Round-Robin(RR)-Paginación-NRU-Continua-Reubicable"\
    "\n  198. Round-Robin(RR)-Paginación-NRU-Continua-No Reubicable"\
    "\n  199. Round-Robin(RR)-Paginación-NRU-No Continua-Reubicable"\
    "\n  200. Round-Robin(RR)-Paginación-NRU-No Continua-No Reubicable"\
    "\n  201. Salir\n\n  --> " | tee -a $informeConColorTotal $informeSinColorTotal
    read seleccionMenuDOCPDF
    echo -n -e "$seleccionMenuDOCPDF\n\n" >> $informeConColorTotal
    echo -n -e "$seleccionMenuDOCPDF\n\n" >> $informeSinColorTotal

#Comprobación de que el número introducido por el usuario es de 1 a 4
    until [[ "0" -lt $seleccionMenuDOCPDF && $seleccionMenuDOCPDF -lt "202" ]];	do
        echo -ne "\n Error en la elección de una opción válida\n  --> " | tee -a $informeConColorTotal
        echo -ne " Error en la elección de una opción válida\n  --> " >> $informeSinColorTotal
        read seleccionMenuDOCPDF
        echo -e "$seleccionMenuDOCPDF\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuDOCPDF\n\n" >> $informeSinColorTotal
    done

    if [[ $seleccionMenuDOCPDF -ge 1 && $seleccionMenuDOCPDF -le 200 ]]; then
		if [[ $seleccionMenuDOCPDF -eq 1 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 2 ]]; then evince ./DOCPDF/002-FCFS-SJF-Pag-FIFO-C-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 3 ]]; then evince ./DOCPDF/003-FCFS-SJF-Pag-FIFO-NC-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 4 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 5 ]]; then evince ./DOCPDF/005-FCFS-SJF-Pag-Reloj-C-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 6 ]]; then 
			evince ./DOCPDF/006-FCFS-SJF-Pag-Reloj-C-NR-1.pdf
			evince ./DOCPDF/006-FCFS-SJF-Pag-Reloj-C-NR-2.pdf
		elif [[ $seleccionMenuDOCPDF -eq 7 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 8 ]]; then evince ./DOCPDF/008-FCFS-SJF-Pag-Reloj-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 9 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 10 ]]; then evince ./DOCPDF/010-FCFS-SJF-Pag-SegOp-C-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 11 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 12 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 13 ]]; then evince ./DOCPDF/013-FCFS-SJF-Pag-Optimo-C-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 14 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 15 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 16 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 17 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 18 ]]; then evince ./DOCPDF/018-FCFS-SJF-Pag-MFU-LFU-C-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 19 ]]; then evince ./DOCPDF/019-FCFS-SJF-Pag-MFU-C-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 20 ]]; then evince ./DOCPDF/018-FCFS-SJF-Pag-MFU-LFU-C-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 21 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 22 ]]; then evince ./DOCPDF/018-FCFS-SJF-Pag-MFU-LFU-C-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 23 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 24 ]]; then 
			evince ./DOCPDF/024-FCFS-SJF-Pag-LFU-NRU-C-NC-NR-1.pdf
			evince ./DOCPDF/024-FCFS-SJF-Pag-LFU-C-NC-NR-2.pdf
			evince ./DOCPDF/018-FCFS-SJF-Pag-MFU-LFU-C-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 25 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 26 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 27 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 28 ]]; then evince ./DOCPDF/028-FCFS-SJF-Pag-NFU-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 29 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 30 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 31 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 32 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 33 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 34 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 35 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 36 ]]; then evince ./DOCPDF/036-FCFS-SJF-Pag-LRU-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 37 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 38 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 39 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 40 ]]; then evince ./DOCPDF/024-FCFS-SJF-Pag-LFU-NRU-C-NC-NR-1.pdf
		elif [[ $seleccionMenuDOCPDF -eq 41 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 42 ]]; then evince ./DOCPDF/002-FCFS-SJF-Pag-FIFO-C-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 43 ]]; then evince ./DOCPDF/003-FCFS-SJF-Pag-FIFO-NC-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 44 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 45 ]]; then evince ./DOCPDF/005-FCFS-SJF-Pag-Reloj-C-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 46 ]]; then 
			evince ./DOCPDF/006-FCFS-SJF-Pag-Reloj-C-NR-1.pdf
			evince ./DOCPDF/006-FCFS-SJF-Pag-Reloj-C-NR-2.pdf
		elif [[ $seleccionMenuDOCPDF -eq 47 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 48 ]]; then evince ./DOCPDF/008-FCFS-SJF-Pag-Reloj-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 49 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 50 ]]; then evince ./DOCPDF/010-FCFS-SJF-Pag-SegOp-C-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 51 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 52 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 53 ]]; then evince ./DOCPDF/013-FCFS-SJF-Pag-Optimo-C-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 54 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 55 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 56 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 57 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 58 ]]; then evince ./DOCPDF/018-FCFS-SJF-Pag-LRU-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 59 ]]; then evince ./DOCPDF/019-FCFS-SJF-Pag-MFU-C-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 60 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 61 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 62 ]]; then evince ./DOCPDF/022-FCFS-SJF-Pag-LFU-C-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 63 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 64 ]]; then 
			evince ./DOCPDF/024-FCFS-SJF-Pag-LFU-NRU-C-NC-NR-1.pdf
			evince ./DOCPDF/024-FCFS-SJF-Pag-LFU-C-NC-NR-2.pdf
		elif [[ $seleccionMenuDOCPDF -eq 65 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 66 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 67 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 68 ]]; then evince ./DOCPDF/028-FCFS-SJF-Pag-NFU-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 69 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 70 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 71 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 72 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 73 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 74 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 75 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 76 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 77 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 78 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 79 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 80 ]]; then evince ./DOCPDF/024-FCFS-SJF-Pag-LFU-NRU-C-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 81 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 82 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 83 ]]; then evince ./DOCPDF/083-SRPT-Pag-FIFO-NC-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 84 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 85 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 86 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 87 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 88 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 89 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 90 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 91 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 92 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 93 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 94 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 95 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 96 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 97 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 98 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 99 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 100 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 101 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 102 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 103 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 104 ]]; then evince ./DOCPDF/104-SRPT-Pag-LRU-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 105 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 106 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 107 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 108 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 109 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 110 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 111 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 112 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 113 ]]; then evince ./DOCPDF/113-SRPT-Pag-LRU-C-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 114 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 115 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 116 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 117 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 118 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 119 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 120 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 121 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 122 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 123 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 124 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 125 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 126 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 127 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 128 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 129 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 130 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 131 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 132 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 133 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 134 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 135 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 136 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 137 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 138 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 139 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 140 ]]; then evince ./DOCPDF/140-PRIMayorMenor-Pag-MFU-NC-NR.pdf
		elif [[ $seleccionMenuDOCPDF -eq 141 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 142 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 143 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 144 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 145 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 146 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 147 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 148 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 149 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 150 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 151 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 152 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 153 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 154 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 155 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 156 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 157 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 158 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 159 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 160 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 161 ]]; then evince ./DOCPDF/161-RR-Pag-FIFO-C-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 162 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 163 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 164 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 165 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 166 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 167 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 168 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 169 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 170 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 171 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 172 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 173 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 174 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 175 ]]; then evince ./DOCPDF/175-RR-Pag-Optimo-NC-R.pdf
		elif [[ $seleccionMenuDOCPDF -eq 176 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 177 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 178 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 179 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 180 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 181 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 182 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 183 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 184 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 185 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 186 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 187 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 188 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 189 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 190 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 191 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 192 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 193 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 194 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 195 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 196 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 197 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 198 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 199 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCPDF -eq 200 ]]; then evince ./DOCPDF/ManualDeUsuario.pdf
		fi    
		menuInicio
    elif [[ $seleccionMenuDOCPDF -eq 201 ]]; then
		echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
    else
		echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
		echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
    fi
#Fin de menuDOCPDF()

#
# Sinopsis: Menú de elección del Algoritmo de Gestión de Procesos; FCFS, SJF, SRPT.
#
function menuDOCVideo { 
#    clear
    cabecerainicio
    echo -ne $AMARILLO"\n MENÚ DE ELECCIÓN DE DOCUMENTOS DE AYUDA (Vídeos - Necesita 'mplayer')"$NORMAL | tee -a $informeConColorTotal
    echo -ne "\n MENÚ DE ELECCIÓN DE DOCUMENTOS DE AYUDA (Vídeos - Necesita 'mplayer')" >> $informeSinColorTotal
    echo -ne "\n  1. FCFS-Paginación-FIFO-Continua-Reubicable"\
    "\n  2. FCFS-Paginación-FIFO-Continua-No Reubicable"\
    "\n  3. FCFS-Paginación-FIFO-No Continua-Reubicable"\
    "\n  4. FCFS-Paginación-FIFO-No Continua-No Reubicable"\
    "\n  5. FCFS-Paginación-Reloj-Continua-Reubicable"\
    "\n  6. FCFS-Paginación-Reloj-Continua-No Reubicable"\
    "\n  7. FCFS-Paginación-Reloj-No Continua-Reubicable"\
    "\n  8. FCFS-Paginación-Reloj-No Continua-No Reubicable"\
    "\n  9. FCFS-Paginación-Segunda Oportunidad-Continua-Reubicable"\
    "\n  10. FCFS-Paginación-Segunda Oportunidad-Continua-No Reubicable"\
    "\n  11. FCFS-Paginación-Segunda Oportunidad-No Continua-Reubicable"\
    "\n  12. FCFS-Paginación-Segunda Oportunidad-No Continua-No Reubicable"\
    "\n  13. FCFS-Paginación-Óptimo-Continua-Reubicable"\
    "\n  14. FCFS-Paginación-Óptimo-Continua-No Reubicable"\
    "\n  15. FCFS-Paginación-Óptimo-No Continua-Reubicable"\
    "\n  16. FCFS-Paginación-Óptimo-No Continua-No Reubicable"\
    "\n  17. FCFS-Paginación-MFU-Continua-Reubicable"\
    "\n  18. FCFS-Paginación-MFU-Continua-No Reubicable"\
    "\n  19. FCFS-Paginación-MFU-No Continua-Reubicable"\
    "\n  20. FCFS-Paginación-MFU-No Continua-No Reubicable"\
    "\n  21. FCFS-Paginación-LFU-Continua-Reubicable"\
    "\n  22. FCFS-Paginación-LFU-Continua-No Reubicable"\
    "\n  23. FCFS-Paginación-LFU-No Continua-Reubicable"\
    "\n  24. FCFS-Paginación-LFU-No Continua-No Reubicable"\
    "\n  25. FCFS-Paginación-NFU-Continua-Reubicable"\
    "\n  26. FCFS-Paginación-NFU-Continua-No Reubicable"\
    "\n  27. FCFS-Paginación-NFU-No Continua-Reubicable"\
    "\n  28. FCFS-Paginación-NFU-No Continua-No Reubicable"\
    "\n  29. FCFS-Paginación-MRU-Continua-Reubicable"\
    "\n  30. FCFS-Paginación-MRU-Continua-No Reubicable"\
    "\n  31. FCFS-Paginación-MRU-No Continua-Reubicable"\
    "\n  32. FCFS-Paginación-MRU-No Continua-No Reubicable"\
    "\n  33. FCFS-Paginación-LRU-Continua-Reubicable"\
    "\n  34. FCFS-Paginación-LRU-Continua-No Reubicable"\
    "\n  35. FCFS-Paginación-LRU-No Continua-Reubicable"\
    "\n  36. FCFS-Paginación-LRU-No Continua-No Reubicable"\
    "\n  37. FCFS-Paginación-NRU-Continua-Reubicable"\
    "\n  38. FCFS-Paginación-NRU-Continua-No Reubicable"\
    "\n  39. FCFS-Paginación-NRU-No Continua-Reubicable"\
    "\n  40. FCFS-Paginación-NRU-No Continua-No Reubicable"\
    "\n  41. SJF-Paginación-FIFO-Continua-Reubicable"\
    "\n  42. SJF-Paginación-FIFO-Continua-No Reubicable"\
    "\n  43. SJF-Paginación-FIFO-No Continua-Reubicable"\
    "\n  44. SJF-Paginación-FIFO-No Continua-No Reubicable"\
    "\n  45. SJF-Paginación-Reloj-Continua-Reubicable"\
    "\n  46. SJF-Paginación-Reloj-Continua-No Reubicable"\
    "\n  47. SJF-Paginación-Reloj-No Continua-Reubicable"\
    "\n  48. SJF-Paginación-Reloj-No Continua-No Reubicable"\
    "\n  49. SJF-Paginación-Segunda Oportunidad-Continua-Reubicable"\
    "\n  50. SJF-Paginación-Segunda Oportunidad-Continua-No Reubicable"\
    "\n  51. SJF-Paginación-Segunda Oportunidad-No Continua-Reubicable"\
    "\n  52. SJF-Paginación-Segunda Oportunidad-No Continua-No Reubicable"\
    "\n  53. SJF-Paginación-Óptimo-Continua-Reubicable"\
    "\n  54. SJF-Paginación-Óptimo-Continua-No Reubicable"\
    "\n  55. SJF-Paginación-Óptimo-No Continua-Reubicable"\
    "\n  56. SJF-Paginación-Óptimo-No Continua-No Reubicable"\
    "\n  57. SJF-Paginación-MFU-Continua-Reubicable"\
    "\n  58. SJF-Paginación-MFU-Continua-No Reubicable"\
    "\n  59. SJF-Paginación-MFU-No Continua-Reubicable"\
    "\n  60. SJF-Paginación-MFU-No Continua-No Reubicable"\
    "\n  61. SJF-Paginación-LFU-Continua-Reubicable"\
    "\n  62. SJF-Paginación-LFU-Continua-No Reubicable"\
    "\n  63. SJF-Paginación-LFU-No Continua-Reubicable"\
    "\n  64. SJF-Paginación-LFU-No Continua-No Reubicable"\
    "\n  65. SJF-Paginación-NFU-Continua-Reubicable"\
    "\n  66. SJF-Paginación-NFU-Continua-No Reubicable"\
    "\n  67. SJF-Paginación-NFU-No Continua-Reubicable"\
    "\n  68. SJF-Paginación-NFU-No Continua-No Reubicable"\
    "\n  69. SJF-Paginación-MRU-Continua-Reubicable"\
    "\n  70. SJF-Paginación-MRU-Continua-No Reubicable"\
    "\n  71. SJF-Paginación-MRU-No Continua-Reubicable"\
    "\n  72. SJF-Paginación-MRU-No Continua-No Reubicable"\
    "\n  73. SJF-Paginación-LRU-Continua-Reubicable"\
    "\n  74. SJF-Paginación-LRU-Continua-No Reubicable"\
    "\n  75. SJF-Paginación-LRU-No Continua-Reubicable"\
    "\n  76. SJF-Paginación-LRU-No Continua-No Reubicable"\
    "\n  77. SJF-Paginación-NRU-Continua-Reubicable"\
    "\n  78. SJF-Paginación-NRU-Continua-No Reubicable"\
    "\n  79. SJF-Paginación-NRU-No Continua-Reubicable"\
    "\n  80. SJF-Paginación-NRU-No Continua-No Reubicable"\
    "\n  81. SRPT-Paginación-FIFO-Continua-Reubicable"\
    "\n  82. SRPT-Paginación-FIFO-Continua-No Reubicable"\
    "\n  83. SRPT-Paginación-FIFO-No Continua-Reubicable"\
    "\n  84. SRPT-Paginación-FIFO-No Continua-No Reubicable"\
    "\n  85. SRPT-Paginación-Reloj-Continua-Reubicable"\
    "\n  86. SRPT-Paginación-Reloj-Continua-No Reubicable"\
    "\n  87. SRPT-Paginación-Reloj-No Continua-Reubicable"\
    "\n  88. SRPT-Paginación-Reloj-No Continua-No Reubicable"\
    "\n  89. SRPT-Paginación-Segunda Oportunidad-Continua-Reubicable"\
    "\n  90. SRPT-Paginación-Segunda Oportunidad-Continua-No Reubicable"\
    "\n  91. SRPT-Paginación-Segunda Oportunidad-No Continua-Reubicable"\
    "\n  92. SRPT-Paginación-Segunda Oportunidad-No Continua-No Reubicable"\
    "\n  93. SRPT-Paginación-Óptimo-Continua-Reubicable"\
    "\n  94. SRPT-Paginación-Óptimo-Continua-No Reubicable"\
    "\n  95. SRPT-Paginación-Óptimo-No Continua-Reubicable"\
    "\n  96. SRPT-Paginación-Óptimo-No Continua-No Reubicable"\
    "\n  97. SRPT-Paginación-MFU-Continua-Reubicable"\
    "\n  98. SRPT-Paginación-MFU-Continua-No Reubicable"\
    "\n  99. SRPT-Paginación-MFU-No Continua-Reubicable"\
    "\n  100. SRPT-Paginación-MFU-No Continua-No Reubicable"\
    "\n  101. SRPT-Paginación-LFU-Continua-Reubicable"\
    "\n  102. SRPT-Paginación-LFU-Continua-No Reubicable"\
    "\n  103. SRPT-Paginación-LFU-No Continua-Reubicable"\
    "\n  104. SRPT-Paginación-LFU-No Continua-No Reubicable"\
    "\n  105. SRPT-Paginación-NFU-Continua-Reubicable"\
    "\n  106. SRPT-Paginación-NFU-Continua-No Reubicable"\
    "\n  107. SRPT-Paginación-NFU-No Continua-Reubicable"\
    "\n  108. SRPT-Paginación-NFU-No Continua-No Reubicable"\
    "\n  109. SRPT-Paginación-MRU-Continua-Reubicable"\
    "\n  110. SRPT-Paginación-MRU-Continua-No Reubicable"\
    "\n  111. SRPT-Paginación-MRU-No Continua-Reubicable"\
    "\n  112. SRPT-Paginación-MRU-No Continua-No Reubicable"\
    "\n  113. SRPT-Paginación-LRU-Continua-Reubicable"\
    "\n  114. SRPT-Paginación-LRU-Continua-No Reubicable"\
    "\n  115. SRPT-Paginación-LRU-No Continua-Reubicable"\
    "\n  116. SRPT-Paginación-LRU-No Continua-No Reubicable"\
    "\n  117. SRPT-Paginación-NRU-Continua-Reubicable"\
    "\n  118. SRPT-Paginación-NRU-Continua-No Reubicable"\
    "\n  119. SRPT-Paginación-NRU-No Continua-Reubicable"\
    "\n  120. SRPT-Paginación-NRU-No Continua-No Reubicable"\
    "\n  121. PrioridadMayorMenor-Paginación-FIFO-Continua-Reubicable"\
    "\n  122. PrioridadMayorMenor-Paginación-FIFO-Continua-No Reubicable"\
    "\n  123. PrioridadMayorMenor-Paginación-FIFO-No Continua-Reubicable"\
    "\n  124. PrioridadMayorMenor-Paginación-FIFO-No Continua-No Reubicable"\
    "\n  125. PrioridadMayorMenor-Paginación-Reloj-Continua-Reubicable"\
    "\n  126. PrioridadMayorMenor-Paginación-Reloj-Continua-No Reubicable"\
    "\n  127. PrioridadMayorMenor-Paginación-Reloj-No Continua-Reubicable"\
    "\n  128. PrioridadMayorMenor-Paginación-Reloj-No Continua-No Reubicable"\
    "\n  129. PrioridadMayorMenor-Paginación-Segunda Oportunidad-Continua-Reubicable"\
    "\n  130. PrioridadMayorMenor-Paginación-Segunda Oportunidad-Continua-No Reubicable"\
    "\n  131. PrioridadMayorMenor-Paginación-Segunda Oportunidad-No Continua-Reubicable"\
    "\n  132. PrioridadMayorMenor-Paginación-Segunda Oportunidad-No Continua-No Reubicable"\
    "\n  133. PrioridadMayorMenor-Paginación-Óptimo-Continua-Reubicable"\
    "\n  134. PrioridadMayorMenor-Paginación-Óptimo-Continua-No Reubicable"\
    "\n  135. PrioridadMayorMenor-Paginación-Óptimo-No Continua-Reubicable"\
    "\n  136. PrioridadMayorMenor-Paginación-Óptimo-No Continua-No Reubicable"\
    "\n  137. PrioridadMayorMenor-Paginación-MFU-Continua-Reubicable"\
    "\n  138. PrioridadMayorMenor-Paginación-MFU-Continua-No Reubicable"\
    "\n  139. PrioridadMayorMenor-Paginación-MFU-No Continua-Reubicable"\
    "\n  140. PrioridadMayorMenor-Paginación-MFU-No Continua-No Reubicable"\
    "\n  141. PrioridadMayorMenor-Paginación-LFU-Continua-Reubicable"\
    "\n  142. PrioridadMayorMenor-Paginación-LFU-Continua-No Reubicable"\
    "\n  143. PrioridadMayorMenor-Paginación-LFU-No Continua-Reubicable"\
    "\n  144. PrioridadMayorMenor-Paginación-LFU-No Continua-No Reubicable"\
    "\n  145. PrioridadMayorMenor-Paginación-NFU-Continua-Reubicable"\
    "\n  146. PrioridadMayorMenor-Paginación-NFU-Continua-No Reubicable"\
    "\n  147. PrioridadMayorMenor-Paginación-NFU-No Continua-Reubicable"\
    "\n  148. PrioridadMayorMenor-Paginación-NFU-No Continua-No Reubicable"\
    "\n  149. PrioridadMayorMenor-Paginación-MRU-Continua-Reubicable"\
    "\n  150. PrioridadMayorMenor-Paginación-MRU-Continua-No Reubicable"\
    "\n  151. PrioridadMayorMenor-Paginación-MRU-No Continua-Reubicable"\
    "\n  152. PrioridadMayorMenor-Paginación-MRU-No Continua-No Reubicable"\
    "\n  153. PrioridadMayorMenor-Paginación-LRU-Continua-Reubicable"\
    "\n  154. PrioridadMayorMenor-Paginación-LRU-Continua-No Reubicable"\
    "\n  155. PrioridadMayorMenor-Paginación-LRU-No Continua-Reubicable"\
    "\n  156. PrioridadMayorMenor-Paginación-LRU-No Continua-No Reubicable"\
    "\n  157. PrioridadMayorMenor-Paginación-NRU-Continua-Reubicable"\
    "\n  158. PrioridadMayorMenor-Paginación-NRU-Continua-No Reubicable"\
    "\n  159. PrioridadMayorMenor-Paginación-NRU-No Continua-Reubicable"\
    "\n  160. PrioridadMayorMenor-Paginación-NRU-No Continua-No Reubicable"\
    "\n  161. Round-Robin(RR)-Paginación-FIFO-Continua-Reubicable"\
    "\n  162. Round-Robin(RR)-Paginación-FIFO-Continua-No Reubicable"\
    "\n  163. Round-Robin(RR)-Paginación-FIFO-No Continua-Reubicable"\
    "\n  164. Round-Robin(RR)-Paginación-FIFO-No Continua-No Reubicable"\
    "\n  165. Round-Robin(RR)-Paginación-Reloj-Continua-Reubicable"\
    "\n  166. Round-Robin(RR)-Paginación-Reloj-Continua-No Reubicable"\
    "\n  167. Round-Robin(RR)-Paginación-Reloj-No Continua-Reubicable"\
    "\n  168. Round-Robin(RR)-Paginación-Reloj-No Continua-No Reubicable"\
    "\n  169. Round-Robin(RR)-Paginación-Segunda Oportunidad-Continua-Reubicable"\
    "\n  170. Round-Robin(RR)-Paginación-Segunda Oportunidad-Continua-No Reubicable"\
    "\n  171. Round-Robin(RR)-Paginación-Segunda Oportunidad-No Continua-Reubicable"\
    "\n  172. Round-Robin(RR)-Paginación-Segunda Oportunidad-No Continua-No Reubicable"\
    "\n  173. Round-Robin(RR)-Paginación-Óptimo-Continua-Reubicable"\
    "\n  174. Round-Robin(RR)-Paginación-Óptimo-Continua-No Reubicable"\
    "\n  175. Round-Robin(RR)-Paginación-Óptimo-No Continua-Reubicable"\
    "\n  176. Round-Robin(RR)-Paginación-Óptimo-No Continua-No Reubicable"\
    "\n  177. Round-Robin(RR)-Paginación-MFU-Continua-Reubicable"\
    "\n  178. Round-Robin(RR)-Paginación-MFU-Continua-No Reubicable"\
    "\n  179. Round-Robin(RR)-Paginación-MFU-No Continua-Reubicable"\
    "\n  180. Round-Robin(RR)-Paginación-MFU-No Continua-No Reubicable"\
    "\n  181. Round-Robin(RR)-Paginación-LFU-Continua-Reubicable"\
    "\n  182. Round-Robin(RR)-Paginación-LFU-Continua-No Reubicable"\
    "\n  183. Round-Robin(RR)-Paginación-LFU-No Continua-Reubicable"\
    "\n  184. Round-Robin(RR)-Paginación-LFU-No Continua-No Reubicable"\
    "\n  185. Round-Robin(RR)-Paginación-NFU-Continua-Reubicable"\
    "\n  186. Round-Robin(RR)-Paginación-NFU-Continua-No Reubicable"\
    "\n  187. Round-Robin(RR)-Paginación-NFU-No Continua-Reubicable"\
    "\n  188. Round-Robin(RR)-Paginación-NFU-No Continua-No Reubicable"\
    "\n  189. Round-Robin(RR)-Paginación-MRU-Continua-Reubicable"\
    "\n  190. Round-Robin(RR)-Paginación-MRU-Continua-No Reubicable"\
    "\n  191. Round-Robin(RR)-Paginación-MRU-No Continua-Reubicable"\
    "\n  192. Round-Robin(RR)-Paginación-MRU-No Continua-No Reubicable"\
    "\n  193. Round-Robin(RR)-Paginación-LRU-Continua-Reubicable"\
    "\n  194. Round-Robin(RR)-Paginación-LRU-Continua-No Reubicable"\
    "\n  195. Round-Robin(RR)-Paginación-LRU-No Continua-Reubicable"\
    "\n  196. Round-Robin(RR)-Paginación-LRU-No Continua-No Reubicable"\
    "\n  197. Round-Robin(RR)-Paginación-NRU-Continua-Reubicable"\
    "\n  198. Round-Robin(RR)-Paginación-NRU-Continua-No Reubicable"\
    "\n  199. Round-Robin(RR)-Paginación-NRU-No Continua-Reubicable"\
    "\n  200. Round-Robin(RR)-Paginación-NRU-No Continua-No Reubicable"\
    "\n  201. Salir\n\n  --> " | tee -a $informeConColorTotal $informeSinColorTotal
    read seleccionMenuDOCVideo
    echo -n -e "$seleccionMenuDOCVideo\n\n" >> $informeConColorTotal
    echo -n -e "$seleccionMenuDOCVideo\n\n" >> $informeSinColorTotal

#Comprobación de que el número introducido por el usuario es de 1 a 4
    until [[ "0" -lt $seleccionMenuDOCVideo && $seleccionMenuDOCVideo -lt "202" ]];	do
        echo -ne "\n Error en la elección de una opción válida\n  --> " | tee -a $informeConColorTotal
        echo -ne " Error en la elección de una opción válida\n  --> " >> $informeSinColorTotal
        read seleccionMenuDOCVideo
        echo -e "$seleccionMenuDOCVideo\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuDOCVideo\n\n" >> $informeSinColorTotal
    done

    if [[ $seleccionMenuDOCVideo -ge 1 && $seleccionMenuDOCVideo -le 200 ]]; then
		if [[ $seleccionMenuDOCVideo -eq 1 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 2 ]]; then mplayer ./DOCVideo/002-FCFS-SJF-Pag-FIFO-C-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 3 ]]; then mplayer ./DOCVideo/003-FCFS-SJF-Pag-FIFO-NC-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 4 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 5 ]]; then mplayer ./DOCVideo/005-FCFS-SJF-Pag-Reloj-C-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 6 ]]; then 
			mplayer ./DOCVideo/006-FCFS-SJF-Pag-Reloj-C-NR-1.mkv
			mplayer ./DOCVideo/006-FCFS-SJF-Pag-Reloj-C-NR-2.mp4
		elif [[ $seleccionMenuDOCVideo -eq 7 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 8 ]]; then mplayer ./DOCVideo/048-FCFS-SJF-Pag-Reloj-NC-NR.mkv
		elif [[ $seleccionMenuDOCVideo -eq 9 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 10 ]]; then mplayer ./DOCVideo/010-FCFS-SJF-Pag-SegOp-C-NR.mp4
		elif [[ $seleccionMenuDOCVideo -eq 11 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 12 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 13 ]]; then mplayer ./DOCVideo/013-FCFS-SJF-Pag-Optimo-C-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 14 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 15 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 16 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 17 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 18 ]]; then mplayer ./DOCVideo/018-FCFS-SJF-Pag-MFU-LFU-C-NC-NR.mp4
		elif [[ $seleccionMenuDOCVideo -eq 19 ]]; then mplayer ./DOCVideo/019-FCFS-SJF-Pag-MFU-C-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 20 ]]; then mplayer ./DOCVideo/018-FCFS-SJF-Pag-MFU-LFU-C-NC-NR.mp4
		elif [[ $seleccionMenuDOCVideo -eq 21 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 22 ]]; then mplayer ./DOCVideo/018-FCFS-SJF-Pag-MFU-LFU-C-NC-NR.mp4
		elif [[ $seleccionMenuDOCVideo -eq 23 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 24 ]]; then 
			mplayer ./DOCVideo/024-FCFS-SJF-Pag-LFU-NRU-C-NC-NR-1.mp4
			mplayer ./DOCVideo/024-FCFS-SJF-Pag-LFU-C-NC-NR-2.mp4
			mplayer ./DOCVideo/018-FCFS-SJF-Pag-MFU-LFU-C-NC-NR.mp4
		elif [[ $seleccionMenuDOCVideo -eq 25 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 26 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 27 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 28 ]]; then mplayer ./DOCVideo/028-FCFS-SJF-Pag-NFU-NC-NR.mp4
		elif [[ $seleccionMenuDOCVideo -eq 29 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 30 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 31 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 32 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 33 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 34 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 35 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 36 ]]; then mplayer ./DOCVideo/036-FCFS-SJF-Pag-LRU-NC-NR.mkv
		elif [[ $seleccionMenuDOCVideo -eq 37 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 38 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 39 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 40 ]]; then
			mplayer ./DOCVideo/006-FCFS-SJF-Pag-Reloj-C-NR-1.mkv
			mplayer ./DOCVideo/006-FCFS-SJF-Pag-Reloj-C-NR-2.mp4
		elif [[ $seleccionMenuDOCVideo -eq 41 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 42 ]]; then mplayer ./DOCVideo/002-FCFS-SJF-Pag-FIFO-C-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 43 ]]; then mplayer ./DOCVideo/003-FCFS-SJF-Pag-FIFO-NC-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 44 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 45 ]]; then mplayer ./DOCVideo/005-FCFS-SJF-Pag-Reloj-C-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 46 ]]; then mplayer ./DOCVideo/006-FCFS-SJF-Pag-Reloj-C-NR.mkv
		elif [[ $seleccionMenuDOCVideo -eq 47 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 48 ]]; then mplayer ./DOCVideo/048-FCFS-SJF-Pag-Reloj-NC-NR.mkv
		elif [[ $seleccionMenuDOCVideo -eq 49 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 50 ]]; then mplayer ./DOCVideo/010-FCFS-SJF-Pag-SegOp-C-NR.mp4
		elif [[ $seleccionMenuDOCVideo -eq 51 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 52 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 53 ]]; then mplayer ./DOCVideo/013-FCFS-SJF-Pag-Optimo-C-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 54 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 55 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 56 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 57 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 58 ]]; then mplayer ./DOCVideo/018-FCFS-SJF-Pag-LRU-NC-NR.mkv
		elif [[ $seleccionMenuDOCVideo -eq 59 ]]; then mplayer ./DOCVideo/019-FCFS-SJF-Pag-MFU-C-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 60 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 61 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 62 ]]; then mplayer ./DOCVideo/022-FCFS-SJF-Pag-LFU-C-NR.mp4
		elif [[ $seleccionMenuDOCVideo -eq 63 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 64 ]]; then 
			mplayer ./DOCVideo/024-FCFS-SJF-Pag-LFU-NRU-C-NC-NR-1.mp4
			mplayer ./DOCVideo/024-FCFS-SJF-Pag-LFU-C-NC-NR-2.mp4
		elif [[ $seleccionMenuDOCVideo -eq 65 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 66 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 67 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 68 ]]; then mplayer ./DOCVideo/028-FCFS-SJF-Pag-NFU-NC-NR.mp4
		elif [[ $seleccionMenuDOCVideo -eq 69 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 70 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 71 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 72 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 73 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 74 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 75 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 76 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 77 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 78 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 79 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 80 ]]; then mplayer ./DOCVideo/024-FCFS-SJF-Pag-LFU-NRU-C-NC-NR-1.mp4
		elif [[ $seleccionMenuDOCVideo -eq 81 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 82 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 83 ]]; then mplayer ./DOCVideo/083-SRPT-Pag-FIFO-NC-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 84 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 85 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 86 ]]; then mplayer ./DOCVideo/086-FCFS-SJF-Pag-Reloj-C-NR.mp4
		elif [[ $seleccionMenuDOCVideo -eq 87 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 88 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 89 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 90 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 91 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 92 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 93 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 94 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 95 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 96 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 97 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 98 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 99 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 100 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 101 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 102 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 103 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 104 ]]; then 
			mplayer ./DOCVideo/104-SRPT-Pag-LRU-NC-NR-1.mov
			mplayer ./DOCVideo/104-SRPT-Pag-LRU-NC-NR-2.mov
		elif [[ $seleccionMenuDOCVideo -eq 105 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 106 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 107 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 108 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 109 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 110 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 111 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 112 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 113 ]]; then mplayer ./DOCVideo/113-SRPT-Pag-LRU-C-R.mkv
		elif [[ $seleccionMenuDOCVideo -eq 114 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 115 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 116 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 117 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 118 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 119 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 120 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 121 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 122 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 123 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 124 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 125 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 126 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 127 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 128 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 129 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 130 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 131 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 132 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 133 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 134 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 135 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 136 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 137 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 138 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 139 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 140 ]]; then mplayer ./DOCVideo/140-PRIMayorMenor-Pag-MFU-NC-NR.mp4
		elif [[ $seleccionMenuDOCVideo -eq 141 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 142 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 143 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 144 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 145 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 146 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 147 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 148 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 149 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 150 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 151 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 152 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 153 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 154 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 155 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 156 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 157 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 158 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 159 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 160 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 161 ]]; then mplayer ./DOCVideo/161-RR-Pag-FIFO-C-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 162 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 163 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 164 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 165 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 166 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 167 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 168 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 169 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 170 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 171 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 172 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 173 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 174 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 175 ]]; then mplayer ./DOCVideo/175-RR-Pag-Optimo-NC-R.mp4
		elif [[ $seleccionMenuDOCVideo -eq 176 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 177 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 178 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 179 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 180 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 181 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 182 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 183 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 184 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 185 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 186 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 187 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 188 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 189 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 190 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 191 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 192 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 193 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 194 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 195 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 196 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 197 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 198 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 199 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		elif [[ $seleccionMenuDOCVideo -eq 200 ]]; then evince ./DOCVideo/ManualDeUsuario.pdf
		fi    
		menuInicio
    elif [[ $seleccionMenuDOCVideo -eq 201 ]]; then
		echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
    else
		echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
		echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
    fi
#Fin de menuDOCVideo()

#
# Sinopsis: Menú de elección del Algoritmo de Gestión de Procesos; FCFS, SJF, SRPT, Prioridades.
#
function menuAlgoritmoGestionProcesos {
#	clear
	cabecerainicio
    echo -ne $AMARILLO"\n MENÚ DE ELECCIÓN DE ALGORITMO"$NORMAL\
    "\n\n  1. FCFS"\
    "\n\n  2. SJF"\
    "\n\n  3. SRPT"\
    "\n\n  4. Prioridades"\
    "\n\n  5. Round-Robin"\
    "\n\n  6. Salir\n\n--> " | tee -a $informeConColorTotal
    echo -ne "\n MENÚ DE ELECCIÓN DE ALGORITMO"\
    "\n\n  1. FCFS"\
    "\n\n  2. SJF"\
    "\n\n  3. SRPT"\
    "\n\n  4. Prioridades"\
    "\n\n  5. Round-Robin"\
    "\n\n  6. Salir\n\n\n--> " >> $informeSinColorTotal
    read seleccionMenuAlgoritmoGestionProcesos
    echo -ne "$seleccionMenuAlgoritmoGestionProcesos\n\n" >> $informeConColorTotal
    echo -ne "$seleccionMenuAlgoritmoGestionProcesos\n\n" >> $informeSinColorTotal
#Se comprueba que el número introducido por el usuario es de 1 a 6
    until [[ 0 -lt $seleccionMenuAlgoritmoGestionProcesos && $seleccionMenuAlgoritmoGestionProcesos -lt 7 ]];   do
        echo -ne "\nError en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
        echo -ne "\nError en la elección de una opción válida\n--> " >> $informeSinColorTotal
        read seleccionMenuAlgoritmoGestionProcesos
        echo -e "$seleccionMenuAlgoritmoGestionProcesos\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuAlgoritmoGestionProcesos\n\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuAlgoritmoGestionProcesos" in
        '4')
#Menú de elección del tipo de prioridad (Mayor/Menor).
#Menú de elección de apropiatividad. Cuando se ejecuta con Prioridades. Se hace en menuAlgoritmoGestionProcesos()
			;;
    esac
#Para que se equipare al programa nuevo.
#Fin de menuAlgoritmoGestionProcesos()

#
# Sinopsis: Menú de elección de Tipo de Prioridad (Mayor/Menor). Cuando se ejecuta con Prioridades.
#
function menuTipoPrioridad { 
#	clear
	cabecerainicio
    echo -ne $AMARILLO"\n MENÚ DE ELECCIÓN DEL TIPO DE PRIORIDAD"$NORMAL\
    "\n\n  1. Prioridad Mayor"\
    "\n\n  2. Prioridad Menor"\
    "\n\n  3. Salir\n\n--> " | tee -a $informeConColorTotal
    echo -ne "\n MENÚ DE ELECCIÓN DEL TIPO DE PRIORIDAD"\
    "\n\n  1. Prioridad Mayor"\
    "\n\n  2. Prioridad Menor"\
    "\n\n  3. Salir\n\n--> " >> $informeSinColorTotal
    read seleccionTipoPrioridad
    echo -ne "$seleccionTipoPrioridad\n\n" >> $informeConColorTotal
    echo -ne "$seleccionTipoPrioridad\n\n" >> $informeSinColorTotal
    until [[ 0 -lt $seleccionTipoPrioridad && $seleccionTipoPrioridad -lt 4 ]]; do
        echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
        read seleccionTipoPrioridad
        echo -e "$seleccionTipoPrioridad\n\n" >> $informeConColorTotal
        echo -e "$seleccionTipoPrioridad\n\n" >> $informeSinColorTotal
    done
#Fin de menuApropiatividad()

#
# Sinopsis: Menú de elección de Apropiatividad. Cuando se ejecuta con Prioridades.
# 
function menuApropiatividad { 
#	clear
	cabecerainicio
    echo -ne $AMARILLO"\n MENÚ DE ELECCIÓN DE APROPIATIVIDAD"$NORMAL\
    "\n\n  1. No apropiativo"\
    "\n\n  2. Apropiativo"\
    "\n\n  3. Salir\n\n--> " | tee -a $informeConColorTotal
    echo -ne "\n MENÚ DE ELECCIÓN DE APROPIATIVIDAD"\
    "\n\n  1. No apropiativo"\
    "\n\n  2. Apropiativo"\
    "\n\n  3. Salir\n\n--> " >> $informeSinColorTotal
    read seleccionMenuApropiatividad
    echo -ne "$seleccionMenuApropiatividad\n\n" >> $informeConColorTotal
    echo -ne "$seleccionMenuApropiatividad\n\n" >> $informeSinColorTotal
    until [[ 0 -lt $seleccionMenuApropiatividad && $seleccionMenuApropiatividad -lt 4 ]]; do
        echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
        read seleccionMenuApropiatividad
        echo -e "$seleccionMenuApropiatividad\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuApropiatividad\n\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuApropiatividad" in
        '1')
		    apropiatividadNo0Si1=0 ;;
        '2')
		    apropiatividadNo0Si1=1 ;;
        '3')
            echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
            exit 0 ;;
#No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal ;;
    esac
#Fin de menuApropiatividad()

#
# Sinopsis: Menú de elección de reubicabilidad. 
#
#Si reubicabilidadNo0Si1 vale 0 no es reubicable. Si vale 1 es reubicable.
#	clear
	cabecerainicio
    echo -ne $AMARILLO"\n MENÚ DE ELECCIÓN DE REUBICABILIDAD"$NORMAL\
    $AMARILLO"\n\n La elección será aplicable sólo en caso de introducción de datos de forma manual."$NORMAL\
    $AMARILLO"\n\n En caso de introducción de datos a través de fichero se ejecutará tal y como allí esté definido."$NORMAL\
    "\n\n  1. Memoria No Reubicable"\
    "\n\n  2. Memoria Reubicable"\
    "\n\n  3. Salir\n\n--> " | tee -a $informeConColorTotal
    echo -ne "\n MENÚ DE ELECCIÓN DE REUBICABILIDAD"\
    "\n\n La elección será aplicable sólo en caso de introducción de datos de forma manual."\
    "\n\n En caso de introducción de datos a través de fichero se ejecutará tal y como allí esté definido."\
    "\n\n  1. Memoria No Reubicable"\
    "\n\n  2. Memoria Reubicable"\
    "\n\n  3. Salir\n\n--> " >> $informeSinColorTotal
    read seleccionMenuReubicabilidad
    echo -ne "$seleccionMenuReubicabilidad\n\n" >> $informeConColorTotal
    echo -ne "$seleccionMenuReubicabilidad\n\n" >> $informeSinColorTotal
#Se comprueba que el número introducido por el usuario es de 1 a 3
    until [[ "0" -lt $seleccionMenuReubicabilidad && $seleccionMenuReubicabilidad -lt 4 ]];   do
        echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
        read seleccionMenuReubicabilidad
        echo -e "$seleccionMenuReubicabilidad\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuReubicabilidad\n\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuReubicabilidad" in
        '1')
            reubicabilidadNo0Si1=0 ;;
        '2')
            reubicabilidadNo0Si1=1 ;;
        '3')
            echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
            exit 0 ;;
#No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#Fin de menuReubicabilidad()

#
# Sinopsis: Menú de elección de continuidad. 
#
#Si vale 0 es no continua. Si vale 1 es continua.
#	clear
	cabecerainicio
    echo -ne $AMARILLO"\n\n MENÚ DE ELECCIÓN DE CONTINUIDAD"$NORMAL\
    $AMARILLO"\n\n La elección será aplicable sólo en caso de introducción de datos de forma manual."$NORMAL\
    $AMARILLO"\n\n En caso de introducción de datos a través de fichero se ejecutará tal y como allí esté definido."$NORMAL\
    "\n\n  1. Memoria No Continua"\
    "\n\n  2. Memoria Continua"\
    "\n\n  3. Salir\n\n--> " | tee -a $informeConColorTotal
    echo -ne "\n\n MENÚ DE ELECCIÓN DE CONTINUIDAD"\
    "\n\n La elección será aplicable sólo en caso de introducción de datos de forma manual."\
    "\n\n En caso de introducción de datos a través de fichero se ejecutará tal y como allí esté definido."\
    "\n\n  1. Memoria No Continua"\
    "\n\n  2. Memoria Continua"\
    "\n\n  3. Salir\n\n--> " >> $informeSinColorTotal
    read seleccionMenuContinuidad
    echo -ne "$seleccionMenuContinuidad\n\n" >> $informeConColorTotal
    echo -ne "$seleccionMenuContinuidad\n\n" >> $informeSinColorTotal
#Se comprueba que el número introducido por el usuario es de 1 a 3
    until [[ 0 -lt $seleccionMenuContinuidad && $seleccionMenuContinuidad -lt 4 ]];   do
        echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
        read seleccionMenuContinuidad
        echo -e "$seleccionMenuContinuidad\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuContinuidad\n\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuContinuidad" in
        '1')
            continuidadNo0Si1=0 ;;
        '2')
            continuidadNo0Si1=1 ;;
        '3')
            echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
            exit 0 ;;
#No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#Fin de menuContinuidad()

#
# Sinopsis: Menú de elección de Continuidad. 
#
function menuAlgoritmoPaginacion { 
#	clear
	cabecerainicio
    echo -ne $AMARILLO"\n\n MENÚ DE ELECCIÓN DEL ALGORITMO DE PAGINACIÓN"$NORMAL\
    $AMARILLO"\n\n La elección será aplicable sólo en caso de introducción de datos de forma manual."$NORMAL\
    $AMARILLO"\n En caso de introducción de datos a través de fichero se ejecutará tal y como allí esté definido."$NORMAL\
    "\n  1. First In First Out (FIFO)"\
    "\n  2. FIFO - Segunda Oportunidad"\
    "\n  3. Reloj"\
    "\n  4. Reloj - Segunda Oportunidad"\
    "\n  5. Óptimo"\
    "\n  6. More Frequently Used (MFU)"\
    "\n  7. Lest Frequently Used (LFU)"\
    "\n  8. No Frequently Used (NFU) sobre MFU"\
    "\n  9. No Frequently Used (NFU) sobre LFU"\
    "\n  10. No Frequently Used (NFU) con clases sobre MFU"\
    "\n  11. No Frequently Used (NFU) con clases sobre LFU"\
    "\n  12. More Recently Used (MRU)"\
    "\n  13. Lest Recently Used (LRU)"\
    "\n  14. No Recently Used (NRU) sobre MRU"\
    "\n  15. No Recently Used (NRU) sobre LRU"\
    "\n  16. No Recently Used (NRU) con clases sobre MRU"\
    "\n  17. No Recently Used (NRU) con clases sobre LRU"\
    "\n  18. Salir\n\n--> " | tee -a $informeConColorTotal 
    echo -ne "\n\n MENÚ DE ELECCIÓN DEL ALGORITMO DE PAGINACIÓN"\
    "\n La elección será aplicable sólo en caso de introducción de datos de forma manual."\
    "\n En caso de introducción de datos a través de fichero se ejecutará tal y como allí esté definido."\
    "\n  1. First In First Out (FIFO)"\
    "\n  2. FIFO - Segunda Oportunidad"\
    "\n  3. Reloj"\
    "\n  4. Reloj - Segunda Oportunidad"\
    "\n  5. Óptimo"\
    "\n  6. More Frequently Used (MFU)"\
    "\n  7. Lest Frequently Used (LFU)"\
    "\n  8. No Frequently Used (NFU) sobre MFU con límite de frecuencia"\
    "\n  9. No Frequently Used (NFU) sobre LFU con límite de frecuencia"\
    "\n  10. No Frequently Used (NFU) con clases sobre MFU con límite de frecuencia"\
    "\n  11. No Frequently Used (NFU) con clases sobre LFU con límite de frecuencia"\
    "\n  12. More Recently Used (MRU)"\
    "\n  13. Lest Recently Used (LRU)"\
    "\n  14. No Recently Used (NRU) sobre MRU con límite de tiempo de uso"\
    "\n  15. No Recently Used (NRU) sobre LRU con límite de tiempo de uso"\
    "\n  16. No Recently Used (NRU) con clases sobre MRU con límite de tiempo de uso"\
    "\n  17. No Recently Used (NRU) con clases sobre LRU con límite de tiempo de uso"\
    "\n  18. Salir\n\n--> " >> $informeSinColorTotal
    read seleccionMenuAlgoritmoPaginacion
    echo -ne "$seleccionMenuAlgoritmoPaginacion\n\n" >> $informeConColorTotal
    echo -ne "$seleccionMenuAlgoritmoPaginacion\n\n" >> $informeSinColorTotal
    until [[ 0 -lt $seleccionMenuAlgoritmoPaginacion && $seleccionMenuAlgoritmoPaginacion -lt 19 ]]; do
        echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
        read seleccionMenuAlgoritmoPaginacion
        echo -e "$seleccionMenuAlgoritmoPaginacion\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuAlgoritmoPaginacion\n\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuAlgoritmoPaginacion" in
        '1')
#FIFO
        '2')
#FIFO - Segunda Oportunidad
        '3')
#Reloj
        '4')
#Reloj - Segunda Oportunidad
        '5')
#Óptimo
        '6')
#More Frequently Used (MFU)
        '7')
#Lest Frequently Used (LFU)
        '8')
#No Frequently Used (NFU) sobre MFU con límite de frecuencia
#Se pide el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
			;;
        '9')
#No Frequently Used (NFU) sobre LFU con límite de frecuencia
#Se pide el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
			;;
        '10')
#No Frequently Used (NFU) con clases sobre MFU con límite de frecuencia en un intervalo de tiempo. Se inician los datos en ordenarDatosEntradaFicheros() y ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve().
#Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
			;;
        '11')
#No Frequently Used (NFU) con clases sobre LFU con límite de frecuencia en un intervalo de tiempo. Se inician los datos en ordenarDatosEntradaFicheros() y ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve().
#Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
			;;
        '12')
#More Recently Used (MRU)
        '13')
#Lest Recently Used (LRU)
        '14')
#No Recently Used (NRU) sobre MRU con límite de tiempo de uso
#Se pide el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
			;;
        '15')
#No Recently Used (NRU) sobre LRU con límite de tiempo de uso
#Se pide el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
			;;
        '16')
#No Recently Used (NRU) con clases sobre MRU con límite de tiempo de uso en un intervalo de tiempo. Se inician los datos en ordenarDatosEntradaFicheros() y ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve().
#Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#Se pide el valor máximo del contador de antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.
#Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
			;;
        '17')
#No Recently Used (NRU) con clases sobre LRU con límite de tiempo de uso en un intervalo de tiempo. Se inician los datos en ordenarDatosEntradaFicheros() y ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve().
#Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#Se pide el valor máximo del contador de antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.
#Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
			;;
        '18')
            echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
            exit 0 ;;
#No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal $informeSinColorTotal ;;
    esac
#Fin de menuAlgoritmoPaginacion()

#
# Sinopsis: Se pide el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
#
function menuAlgoritmoPaginacion_frecuencia { 
	seleccionAlgoritmoPaginacion_frecuencia_valor=0
	echo -ne $AMARILLO"\n\n Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
	echo -ne "\n\n Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" >> $informeSinColorTotal
	read seleccionAlgoritmoPaginacion_frecuencia_valor
	echo -ne "$seleccionAlgoritmoPaginacion_frecuencia_valor\n\n" >> $informeConColorTotal
	echo -ne "$seleccionAlgoritmoPaginacion_frecuencia_valor\n\n" >> $informeSinColorTotal
	until [[ seleccionAlgoritmoPaginacion_frecuencia_valor -gt 0 ]]; do
		echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
		echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
		read seleccionAlgoritmoPaginacion_frecuencia_valor
		echo -e "$seleccionAlgoritmoPaginacion_frecuencia_valor\n\n" >> $informeConColorTotal
		echo -e "$seleccionAlgoritmoPaginacion_frecuencia_valor\n\n" >> $informeSinColorTotal
	done
#Fin de menuAlgoritmoPaginacion_frecuencia()

#
# Sinopsis: Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#
function menuAlgoritmoPaginacion_clases_frecuencia { 
	seleccionAlgoritmoPaginacion_clases_frecuencia_valor=0
	echo -ne $AMARILLO"\n\n Introduce el valor máximo de la frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
	echo -ne "\n\n Introduce el valor máximo de la frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.: \n$NORMAL" >> $informeSinColorTotal
	read seleccionAlgoritmoPaginacion_clases_frecuencia_valor
	echo -ne "$seleccionAlgoritmoPaginacion_clases_frecuencia_valor\n\n" >> $informeConColorTotal
	echo -ne "$seleccionAlgoritmoPaginacion_clases_frecuencia_valor\n\n" >> $informeSinColorTotal
	until [[ seleccionAlgoritmoPaginacion_clases_frecuencia_valor -gt 0 ]]; do
		echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
		echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
		read seleccionAlgoritmoPaginacion_clases_frecuencia_valor
		echo -e "$seleccionAlgoritmoPaginacion_clases_frecuencia_valor\n\n" >> $informeConColorTotal
		echo -e "$seleccionAlgoritmoPaginacion_clases_frecuencia_valor\n\n" >> $informeSinColorTotal
	done
#Fin de menuAlgoritmoPaginacion_clases_frecuencia()

#
# Sinopsis: Se pide el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#
function menuAlgoritmoPaginacion_uso_rec { 
	seleccionAlgoritmoPaginacion_uso_rec_valor=0
	echo -ne $AMARILLO"\n\n Introduce el valor máximo de la antigüedad, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
	echo -ne "\n\n Introduce el valor máximo de la antigüedad, a partir de la cual, no será considerada.: \n$NORMAL" >> $informeSinColorTotal
	read seleccionAlgoritmoPaginacion_uso_rec_valor
	echo -ne "$seleccionAlgoritmoPaginacion_uso_rec_valor\n\n" >> $informeConColorTotal
	echo -ne "$seleccionAlgoritmoPaginacion_uso_rec_valor\n\n" >> $informeSinColorTotal
	until [[ seleccionAlgoritmoPaginacion_uso_rec_valor -gt 0 ]]; do
		echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
		echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
		read seleccionAlgoritmoPaginacion_uso_rec_valor
		echo -e "$seleccionAlgoritmoPaginacion_uso_rec_valor\n\n" >> $informeConColorTotal
		echo -e "$seleccionAlgoritmoPaginacion_uso_rec_valor\n\n" >> $informeSinColorTotal
	done
#Fin de menuAlgoritmoPaginacion_uso_rec()

#
# Sinopsis: Se pide el valor máximo del contador de antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.
#
function menuAlgoritmoPaginacion_clases_uso_rec { 
	seleccionAlgoritmoPaginacion_clases_uso_rec_valor=0
	echo -ne $AMARILLO"\n\n Introduce el valor máximo de la antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
	echo -ne "\n\n Introduce el valor máximo de la antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.: \n$NORMAL" >> $informeSinColorTotal
	read seleccionAlgoritmoPaginacion_clases_uso_rec_valor
	echo -ne "$seleccionAlgoritmoPaginacion_clases_uso_rec_valor\n\n" >> $informeConColorTotal
	echo -ne "$seleccionAlgoritmoPaginacion_clases_uso_rec_valor\n\n" >> $informeSinColorTotal
	until [[ seleccionAlgoritmoPaginacion_clases_uso_rec_valor -gt 0 ]]; do
		echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
		echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
		read seleccionAlgoritmoPaginacion_clases_uso_rec_valor
		echo -e "$seleccionAlgoritmoPaginacion_clases_uso_rec_valor\n\n" >> $informeConColorTotal
		echo -e "$seleccionAlgoritmoPaginacion_clases_uso_rec_valor\n\n" >> $informeSinColorTotal
	done
#Fin de menuAlgoritmoPaginacion_clases_uso_rec()

#
# Sinopsis: Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
#
function menuAlgoritmoPaginacion_clases_valor { 
	seleccionAlgoritmoPaginacion_clases_valor=0
	echo -ne $AMARILLO"\n\n Introduce el valor máximo de unidades de tiempo de antigüedad de ejecución de un proceso, a partir de la cual, una página será considerada como NO referenciada: \n$NORMAL" | tee -a $informeConColorTotal
	echo -ne "\n\n Introduce el valor máximo de unidades de tiempo de antigüedad de ejecución de un proceso, a partir de la cual, una página será considerada como NO referenciada: \n$NORMAL" >> $informeSinColorTotal
	read seleccionAlgoritmoPaginacion_clases_valor
	echo -ne "$seleccionAlgoritmoPaginacion_clases_valor\n\n" >> $informeConColorTotal
	echo -ne "$seleccionAlgoritmoPaginacion_clases_valor\n\n" >> $informeSinColorTotal
	until [[ seleccionAlgoritmoPaginacion_clases_valor -gt 0 ]]; do
		echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
		echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
		read seleccionAlgoritmoPaginacion_clases_valor
		echo -e "$seleccionAlgoritmoPaginacion_clases_valor\n\n" >> $informeConColorTotal
		echo -e "$seleccionAlgoritmoPaginacion_clases_valor\n\n" >> $informeSinColorTotal
	done
#Fin de menuAlgoritmoPaginacion_clases_valor()

#
# Sinopsis: Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#
function menuAlgoritmoPaginacion_TiempoConsiderado_valor { 
	seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=0
	echo -ne $AMARILLO"\n\n Introduce el número de unidades de tiempo de ejecución de un proceso, a partir del cual, serán consideradas la frecuencia/tiempo de uso de una página y su clase: \n$NORMAL" | tee -a $informeConColorTotal
	echo -ne "\n\n Introduce el número de unidades de tiempo de ejecución de un proceso, a partir del cual, serán consideradas la frecuencia/tiempo de uso de una página y su clase: \n$NORMAL" >> $informeSinColorTotal
	read seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado
	echo -ne "$seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado\n\n" >> $informeConColorTotal
	echo -ne "$seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado\n\n" >> $informeSinColorTotal
	until [[ seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado -gt 0 ]]; do
		echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
		echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
		read seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado
		echo -e "$seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado\n\n" >> $informeConColorTotal
		echo -e "$seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado\n\n" >> $informeSinColorTotal
	done
#Fin de menuAlgoritmoPaginacion_TiempoConsiderado_valor()

#
# Sinopsis: Menú de elección de opciones de entrada de datos/rangos/rangos amplios del programa:
# Manul, Última ejecución, Otros ficheros.
#
function menuEleccionEntradaDatos {
#	clear
	cabecerainicio
    echo -ne $AMARILLO"\n MENÚ INICIO"$NORMAL\
    "\n\n  1. Introducción de datos manual"\
    "\n\n  2. Fichero de datos de última ejecución (./FLast/DatosLast.txt)"\
    "\n\n  3. Otros ficheros de datos"\
    "\n\n  4. Introducción de rangos manual (modo aleatorio)"\
    "\n\n  5. Fichero de rangos de última ejecución (./FLast/RangosLast.txt)"\
    "\n\n  6. Otros ficheros de rangos"\
    "\n\n  7. Introducción de rangos amplios manual (modo aleatorio total)"\
    "\n\n  8. Fichero de rangos amplios de última ejecución (./FLast/RangosAleTotalLast.txt)"\
    "\n\n  9. Otros ficheros de rangos amplios"\
    "\n\n  10. Salir\n\n--> "| tee -a $informeConColorTotal
    echo -ne "\n MENÚ INICIO"\
    "\n\n  1. Introducción de datos manual"\
    "\n\n  2. Fichero de datos de última ejecución (./FLast/DatosLast.txt)"\
    "\n\n  3. Otros ficheros de datos"\
    "\n\n  4. Introducción de rangos manual (modo aleatorio)"\
    "\n\n  5. Fichero de rangos de última ejecución (./FLast/RangosLast.txt)"\
    "\n\n  6. Otros ficheros de rangos"\
    "\n\n  7. Introducción de rangos amplios manual (modo aleatorio total)"\
    "\n\n  8. Fichero de rangos amplios de última ejecución (./FLast/RangosAleTotalLast.txt)"\
    "\n\n  9. Otros ficheros de rangos amplios"\
    "\n\n  10. Salir\n\n--> " >> $informeSinColorTotal
    read seleccionMenuEleccionEntradaDatos
    echo -ne "$seleccionMenuEleccionEntradaDatos\n\n" >> $informeConColorTotal
    echo -ne "$seleccionMenuEleccionEntradaDatos\n\n" >> $informeSinColorTotal

#Se comprueba que el número introducido por el usuario es de 1 a 10
    until [[ 0 -lt $seleccionMenuEleccionEntradaDatos && $seleccionMenuEleccionEntradaDatos -lt 11 ]];  do
        echo -ne "\n Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read seleccionMenuEleccionEntradaDatos
        echo -ne "$seleccionMenuEleccionEntradaDatos\n\n" >> $informeConColorTotal
        echo -ne "$seleccionMenuEleccionEntradaDatos\n\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuEleccionEntradaDatos" in
#1. Introducción de datos manual 
            nuevaEjecucion
            preguntaDondeGuardarDatosManuales
            entradaMemoriaTeclado
            entradaProcesosTeclado
            menuModoTiempoEjecucionAlgormitmo
            ;;
#2. Fichero de datos de última ejecución (./FLast/DatosLast.txt).
#Elección del algoritmo de gestión de procesos y la fuente de datos.
            leer_datos_desde_fichero $ficheroDatosAnteriorEjecucion
#Ordenar los datos sacados desde $ficheroDatosAnteriorEjecucion por el tiempo de llegada.
            ;;
#3. Otros ficheros de datos $ficheroDatosAnteriorEjecucion
#Elegir el fichero para la entrada de datos $ficheroParaLectura.
#Elección del algoritmo de gestión de procesos y la fuente de datos.
#Leer los datos desde el fichero elegido $ficheroParaLectura
#Ordenar los datos sacados desde $ficheroParaLectura por el tiempo de llegada.
            ;;
#4. Introducción de rangos manual (modo aleatorio)
#Resuelve los nombres de los ficheros de rangos
#Resuelve los nombres de los ficheros de datos
            nuevaEjecucion 
            entradaMemoriaRangosFichero_op_cuatro
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#5. Fichero de rangos de última ejecución (./FLast/RangosLast.txt)
            entradaMemoriaRangosFichero_op_cinco_Previo
#Leer los datos desde el fichero elegido $ficheroParaLectura
            entradaMemoriaRangosFichero_op_cinco_seis
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#6. Otros ficheros de rangos
            nuevaEjecucion 
            entradaMemoriaRangosFichero_op_seis_Previo 
#Leer los datos desde el fichero elegido $ficheroParaLectura
            entradaMemoriaRangosFichero_op_cinco_seis
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#7. Introducción de rangos amplios manual (modo aleatorio total)
            nuevaEjecucion 
            entradaMemoriaRangosFichero_op_siete_Previo
            entradaMemoriaRangosFichero_op_siete_ocho_nueve
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#8. Fichero de rangos amplios de última ejecución
#Pregunta en qué fichero guardar los rangos para la opción 8.
#Leer los datos desde el fichero elegido $ficheroRangosAleTotalAnteriorEjecucion
            entradaMemoriaRangosFichero_op_siete_ocho_nueve
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#9. Otros ficheros de rangos amplios
            nuevaEjecucion 
            entradaMemoriaRangosFichero_op_nueve_Previo
#Leer los datos desde el fichero elegido $ficheroParaLectura
            entradaMemoriaRangosFichero_op_siete_ocho_nueve
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#10. Salir  
            echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
            exit 0 ;;
#No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#Fin de menuEleccionEntradaDatos()

#
# Sinopsis: Se decide el modo de ejecución: Por eventos, Automática, Completa, Unidad de tiempo a unidad de tiempo  
#
function menuModoTiempoEjecucionAlgormitmo {
#	clear
	cabecerainicio
    echo -ne $AMARILLO"\n\n Introduce una opción: \n$NORMAL"\
    "\n\n  1. Ejecución por eventos (Presionando Enter en cada evento)."\
    "\n\n  2. Ejecución automática (Por eventos y sin pausas)."\
    "\n\n  3. Ejecución completa (Por eventos con pausas de cierto número de segundos)."\
    "\n\n  4. Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo)."\
    "\n\n  5. Ejecución completa (Sin representación de resultados intermedios).\n\n\n--> $NC" | tee -a $informeConColorTotal
	echo -ne $NC$NORMAL
    echo -ne "\n\n Introduce una opción: \n"\
    "\n\n  1. Ejecución por eventos (Presionando Enter en cada evento)."\
    "\n\n  2. Ejecución automática (Por eventos y sin pausas)."\
    "\n\n  3. Ejecución completa (Por eventos con pausas de cierto número de segundos)."\
    "\n\n  4. Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo)."\
    "\n\n  5. Ejecución completa (Sin representación de resultados intermedios).\n\n\n--> " >> $informeSinColorTotal
    read seleccionMenuModoTiempoEjecucionAlgormitmo
    echo -e "$seleccionMenuModoTiempoEjecucionAlgormitmo" >> $informeConColorTotal
    echo -e "$seleccionMenuModoTiempoEjecucionAlgormitmo" >> $informeSinColorTotal
# Se comprueba que el número introducido por el usuario esta entre 1 y 5
    until [[ "0" -lt $seleccionMenuModoTiempoEjecucionAlgormitmo && $seleccionMenuModoTiempoEjecucionAlgormitmo -lt "6" ]]; do
        echo -ne "\n Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne " Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read seleccionMenuModoTiempoEjecucionAlgormitmo
        echo -e "$seleccionMenuModoTiempoEjecucionAlgormitmo\n" >> $informeConColorTotal
        echo -e "$seleccionMenuModoTiempoEjecucionAlgormitmo\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuModoTiempoEjecucionAlgormitmo" in
# Por eventos
            optejecucion=1
            ;;
# Automática
            tiempoejecucion=0
            optejecucion=2
            ;;
# Completa
            echo -ne " Introduce el tiempo entre actualizaciones de datos (segundos): " | tee -a $informeConColorTotal
            echo -ne " Introduce el tiempo entre actualizaciones de datos (segundos): " >> $informeSinColorTotal
            read tiempoejecucion
            until [[ "0" -le $tiempoejecucion ]];   do
                echo -ne "\n Error en la elección de una opción válida. Debe ser mayor o igual a 0.\n\n--> " | tee -a $informeConColorTotal
                echo -ne " Error en la elección de una opción válida. Debe ser mayor o igual a 0.\n\n--> " >> $informeSinColorTotal
                read tiempoejecucion
                echo -e "$tiempoejecucion\n" >> $informeConColorTotal
                echo -e "$tiempoejecucion\n" >> $informeSinColorTotal
            done
            optejecucion=3
            ;;
# De unidad de tiempo en unidad de tiempo
            optejecucion=4
            ;;
# Sólo muestra el resumen final
            optejecucion=5
            ;;
#No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#    clear
#Fin de menuModoTiempoEjecucionAlgormitmo()

#
# Sinopsis: Comprobar si existe el árbol de directorios utilizados en el programa
#
#Regenera el árbol de directorios si no se encuentra. 
#    clear
#Se regenera la estructura de directorios en caso de no existir
    if [[ ! -d $dirFLast ]]; then
        mkdir $dirFLast   
    fi
    if [[ ! -d $dirFDatos ]]; then
        mkdir $dirFDatos   
    fi
    if [[ ! -d $dirFRangos ]]; then
        mkdir $dirFRangos   
    fi
    if [[ ! -d $dirFRangos ]]; then
        mkdir $dirFRangos   
    fi
    if [[ ! -d $dirInformes ]]; then
        mkdir $dirInformes   
    fi
#Informes y temporales 
    if [[ -f $informeConColorTotal ]]; then
#Se borran los ficheros de informes COLOR
    fi
    if [[ -f $informeSinColorTotal ]]; then
#Se borran los ficheros de informes BN
    fi
#Fin de revisarArbolDirectorios()

#
# Sinopsis: Se pregunta por las opciones de guardar lo datos de particiones y procesos.
# Se pregunta si se quiere guardar los datos en el fichero estándar (Default) o en otro.
# Si es en otro, pide el nombre del archivo.
#
function preguntaDondeGuardarDatosManuales {
#Pregunta para los datos por teclado  
    echo -e $AMARILLO"\n¿Dónde quiere guardar los datos resultantes?\n"$NORMAL | tee -a $informeConColorTotal
    echo -e " 1- En el fichero estándar ($ficheroDatosDefault)" | tee -a $informeConColorTotal
    echo -ne " 2- En otro fichero\n\n\n--> " | tee -a $informeConColorTotal
    echo -e "¿Dónde quiere guardar los datos resultantes?\n\n" >> $informeSinColorTotal
    echo -e " 1- En el fichero estándar ($ficheroDatosDefault)" >> $informeSinColorTotal
    echo -ne " 2- En otro fichero\n\n\n--> " >> $informeSinColorTotal
    read seleccionMenuPreguntaDondeGuardarDatosManuales
    echo -e " $seleccionMenuPreguntaDondeGuardarDatosManuales\n\n" >> $informeConColorTotal
    echo -e " $seleccionMenuPreguntaDondeGuardarDatosManuales\n\n" >> $informeSinColorTotal
# Se comprueba que el número introducido por el usuario esta entre 1 y 2
    until [[ "0" -lt $seleccionMenuPreguntaDondeGuardarDatosManuales && $seleccionMenuPreguntaDondeGuardarDatosManuales -lt "3" ]]; do
        echo -ne "\n Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read seleccionMenuPreguntaDondeGuardarDatosManuales
        echo -e " $seleccionMenuPreguntaDondeGuardarDatosManuales\n\n" >> $informeConColorTotal
        echo -e " $seleccionMenuPreguntaDondeGuardarDatosManuales\n\n" >> $informeSinColorTotal
    done
    case "${seleccionMenuPreguntaDondeGuardarDatosManuales}" in
#En el fichero estándar
#Se borran los datos del fichero por defecto de la anterior ejecución
            nomFicheroDatos="$ficheroDatosDefault"
            ;;
#En otro fichero
            echo -e $ROJO"\n Ficheros de datos ya existentes en './FDatos/': "$NORMAL | tee -a $informeConColorTotal
            echo -e "\n Ficheros de datos ya existentes en './FDatos/': " >> $informeSinColorTotal
            files=($(ls -l ./FDatos/ | awk '{print $9}'))
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
                echo -e "   ${files[$i]}"
            done
            echo -e $AMARILLO" Introduce el nombre que le quieres dar al fichero de datos (sin '.txt'):\n"$NORMAL | tee -a $informeConColorTotal
            echo -e " Introduce el nombre que le quieres dar al fichero de datos (sin '.txt'):\n" >> $informeSinColorTotal
            read seleccionNombreFicheroDatos
            nomFicheroDatos="./FDatos/$seleccionNombreFicheroDatos.txt"
            echo -e " $seleccionNombreFicheroDatos" >> $informeConColorTotal
            echo -e " $seleccionNombreFicheroDatos" >> $informeSinColorTotal
            echo -e " $nomFicheroDatos\n\n" >> $informeConColorTotal
            echo -e " $nomFicheroDatos\n\n" >> $informeSinColorTotal
            until [[ ! -z "$seleccionNombreFicheroDatos" && ! -f "$nomFicheroDatos" && "$seleccionNombreFicheroDatos" != "" ]];do  
                echo -e " Ya existe un archivo con el nombre introducido, o es nulo." | tee -a $informeConColorTotal
                echo -e " Ya existe un archivo con el nombre introducido, o es nulo."  >> $informeSinColorTotal
                echo -e " ¿Sobreescribirlo (S/N)?" | tee -a $informeConColorTotal  
                echo -e " ¿Sobreescribirlo (S/N)?" >> $informeSinColorTotal
                read sobrescri
                echo $sobrescri >> $informeConColorTotal
                echo $sobrescri >> $informeSinColorTotal
                until [[ "$sobrescri" == "S" || "$sobrescri" == "s" || "$sobrescri" == "N" || "$sobrescri" == "n" ]]; do
                    echo -e " Respuesta no válida, debe ser una de las opciones." | tee -a $informeConColorTotal  
                    echo -e " ¿Sobreescribirlo (S/N)?" | tee -a $informeConColorTotal  
                    echo -e " Respuesta no válida, debe ser S o N." >> $informeSinColorTotal
                    echo -e " ¿Sobreescribirlo (S/N)?" >> $informeSinColorTotal
                    read sobrescri
                    echo $sobrescri >> $informeConColorTotal
                    echo $sobrescri >> $informeSinColorTotal
                done
                if [[ $sobrescri == "S" || $sobrescri == "s" ]]; then
                    echo -e " Los datos se guardaran en el archivo $nomFicheroDatos" | tee -a $informeConColorTotal  
                    echo -e " Los datos se guardaran en el archivo $nomFicheroDatos" >> $informeSinColorTotal
                    rm $nomFicheroDatos 
                fi
                if [[ $sobrescri == "N" || $sobrescri == "n" ]]; then
                    echo -e " Introduzca un nombre correcto: \n" | tee -a $informeConColorTotal
                    echo -e " Introduzca un nombre correcto: \n" >> $informeSinColorTotal
                    read seleccionNombreFicheroDatos
                    nomFicheroDatos="./FDatos/""$seleccionNombreFicheroDatos.txt"
                    echo -e " $seleccionNombreFicheroDatos" >> $informeConColorTotal
                    echo -e " $seleccionNombreFicheroDatos" >> $informeSinColorTotal
                    echo -e " $nomFicheroDatos\n" >> $informeConColorTotal
                    echo -e " $nomFicheroDatos\n" >> $informeSinColorTotal
#cierre el sobreescribir NO
            done
            ;;
#No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#    clear
#Fin de preguntaDondeGuardarDatosManuales()
        
#
# Sinopsis: Se pregunta por las opciones de guardar lo rangos de particiones y procesos.
# Se pregunta si se quiere guardar los rangos en el fichero estándar (Default) o en otro.
# Si es en otro, pide el nombre del archivo.
#
function preguntaDondeGuardarRangosManuales {
    echo -e $AMARILLO"¿Dónde quiere guardar los rangos?"$NORMAL | tee -a  $informeConColorTotal
    echo -e "\n 1- En el fichero de rangos estándar ($ficheroRangosDefault)" | tee -a  $informeConColorTotal
    echo -e " 2- En otro fichero\n" | tee -a  $informeConColorTotal
    echo -ne "\n--> " | tee -a  $informeConColorTotal
    echo -e "¿Dónde quiere guardar los rangos?" >> $informeSinColorTotal
    echo -e "\n 1- En el fichero de rangos estándar ($ficheroRangosDefault)" >> $informeSinColorTotal
    echo -e " 2- En otro fichero\n" >> $informeSinColorTotal
    echo -ne "\n--> " >> $informeSinColorTotal
    read seleccionMenuPreguntaDondeGuardarRangosManuales
    echo -e "$seleccionMenuPreguntaDondeGuardarRangosManuales\n\n" >> $informeConColorTotal
    echo -e "$seleccionMenuPreguntaDondeGuardarRangosManuales\n\n" >> $informeSinColorTotal

# Se comprueba que el número introducido por el usuario esta entre 1 y 2
    until [[ "0" -lt $seleccionMenuPreguntaDondeGuardarRangosManuales && $seleccionMenuPreguntaDondeGuardarRangosManuales -lt "3" ]];   do
        echo -e "\nError en la elección de una opción válida" | tee -a $informeConColorTotal
        echo -e "\nError en la elección de una opción válida" >> $informeSinColorTotal
        echo -ne "\n--> " | tee -a  $informeConColorTotal
        echo -ne "\n--> " >> $informeSinColorTotal
        read seleccionMenuPreguntaDondeGuardarRangosManuales
        echo -e "$seleccionMenuPreguntaDondeGuardarRangosManuales\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuPreguntaDondeGuardarRangosManuales\n\n" >> $informeSinColorTotal
    done
    case "${seleccionMenuPreguntaDondeGuardarRangosManuales}" in
#En el fichero estándar
#Se borran los rangos del fichero por defecto de la anterior ejecución
            nomFicheroRangos="$ficheroRangosDefault"
            ;;
#En otro fichero
            echo -e $AMARILLO"Introduce el nombre que le quieres dar al fichero de datos (sin '.txt'):\n"$NORMAL | tee -a $informeConColorTotal
            echo -e "Introduce el nombre que le quieres dar al fichero de datos (sin '.txt'):\n" >> $informeSinColorTotal
            read seleccionNombreFicheroRangos
            nomFicheroRangos="./FRangos/""$seleccionNombreFicheroRangos.txt"
            echo -e "$seleccionNombreFicheroRangos" >> $informeConColorTotal
            echo -e "$seleccionNombreFicheroRangos" >> $informeSinColorTotal
            echo -e "$nomFicheroRangos\n" >> $informeConColorTotal
            echo -e "$nomFicheroRangos\n" >> $informeSinColorTotal
            until [[ ! -z "$seleccionNombreFicheroRangos" && ! -f "$nomFicheroRangos" && "$seleccionNombreFicheroRangos" != "" ]];do  
                echo -e " Ya existe un archivo con el nombre introducido, o es nulo." | tee -a $informeConColorTotal
                echo -e " Ya existe un archivo con el nombre introducido, o es nulo."  >> $informeSinColorTotal
                echo -e " ¿Sobreescribirlo (S/N)?" | tee -a $informeConColorTotal  
                echo -e " ¿Sobreescribirlo (S/N)?" >> $informeSinColorTotal
                read sobrescri
                echo $sobrescri >> $informeConColorTotal
                echo $sobrescri >> $informeSinColorTotal
                until [[ "$sobrescri" == "S" || "$sobrescri" == "s" || "$sobrescri" == "N" || "$sobrescri" == "n" ]]; do
                    echo -e " Respuesta no válida, debe ser una de las opciones." | tee -a $informeConColorTotal  
                    echo -e " ¿Sobreescribirlo (S/N)?" | tee -a $informeConColorTotal  
                    echo -e " Respuesta no válida, debe ser S o N." >> $informeSinColorTotal
                    echo -e " ¿Sobreescribirlo (S/N)?" >> $informeSinColorTotal
                    read sobrescri
                    echo $sobrescri >> $informeConColorTotal
                    echo $sobrescri >> $informeSinColorTotal
                done
                if [[ $sobrescri == "S" || $sobrescri == "s" ]]; then
                    echo -e " Los datos se guardaran en el archivo $nomFicheroRangos" | tee -a $informeConColorTotal  
                    echo -e " Los datos se guardaran en el archivo $nomFicheroRangos" >> $informeSinColorTotal
                    rm $nomFicheroRangos 
                fi
                if [[ $sobrescri == "N" || $sobrescri == "n" ]]; then
                    echo -e " Introduzca un nombre correcto: \n" | tee -a $informeConColorTotal
                    echo -e " Introduzca un nombre correcto: \n" >> $informeSinColorTotal
                    read seleccionNombreFicheroRangos
                    nomFicheroRangos="./FRangos/""$seleccionNombreFicheroRangos.txt"
                    echo -e " $seleccionNombreFicheroRangos" >> $informeConColorTotal
                    echo -e " $seleccionNombreFicheroRangos" >> $informeSinColorTotal
                    echo -e " $nomFicheroRangos\n" >> $informeConColorTotal
                    echo -e " $nomFicheroRangos\n" >> $informeSinColorTotal
#cierre el sobreescribir NO
            done
            ;;
#No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e "Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e "Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#Fin de preguntaDondeGuardarRangosManuales()

#
# Sinopsis: Se pregunta por las opciones de guardar los mínimos y máximos de los rangos amplios.
# Se pregunta si se quiere guardar los rangos en el fichero estándar (Default) o en otro.
# Si es en otro, pide el nombre del archivo.
#
function preguntaDondeGuardarRangosAleTManuales {
    echo -e $AMARILLO"¿Dónde quiere guardar los mínimos y máximos de los rangos amplios?"$NORMAL | tee -a  $informeConColorTotal
    echo -e "\n 1- En el fichero de rangos amplios estándar ($ficheroRangosAleTotalDefault)" | tee -a  $informeConColorTotal
    echo -e " 2- En otro fichero\n" | tee -a  $informeConColorTotal
    echo -ne "\n--> " | tee -a  $informeConColorTotal
    echo -e "¿Dónde quiere guardar los mínimos y máximos de los rangos amplios?" >> $informeSinColorTotal
    echo -e "\n 1- En el fichero de rangos amplios estándar ($ficheroRangosAleTotalDefault)" >> $informeSinColorTotal
    echo -e " 2- En otro fichero\n" >> $informeSinColorTotal
    echo -ne "\n--> " >> $informeSinColorTotal
    read seleccionMenuPreguntaDondeGuardarRangosAleTManuales
    echo -e "$seleccionMenuPreguntaDondeGuardarRangosAleTManuales\n\n" >> $informeConColorTotal
    echo -e "$seleccionMenuPreguntaDondeGuardarRangosAleTManuales\n\n" >> $informeSinColorTotal
# Se comprueba que el número introducido por el usuario esta entre 1 y 2
    until [[ "0" -lt $seleccionMenuPreguntaDondeGuardarRangosAleTManuales && $seleccionMenuPreguntaDondeGuardarRangosAleTManuales -lt "3" ]];   do
        echo -e "\nError en la elección de una opción válida" | tee -a $informeConColorTotal
        echo -e "\nError en la elección de una opción válida" >> $informeSinColorTotal
        echo -ne "\n--> " | tee -a  $informeConColorTotal
        echo -ne "\n--> " >> $informeSinColorTotal
        read seleccionMenuPreguntaDondeGuardarRangosAleTManuales
        echo -e "$seleccionMenuPreguntaDondeGuardarRangosAleTManuales\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuPreguntaDondeGuardarRangosAleTManuales\n\n" >> $informeSinColorTotal
    done
    case "${seleccionMenuPreguntaDondeGuardarRangosAleTManuales}" in
#En el fichero estándar
#Se borran los rangos del fichero por defecto de la anterior ejecución
            nomFicheroRangosAleT="$ficheroRangosAleTotalDefault"
            ;;
#En otro fichero
            echo -e $AMARILLO"Introduce el nombre que le quieres dar al fichero de rangos amplios (sin '.txt'):\n"$NORMAL | tee -a $informeConColorTotal
            echo -e "Introduce el nombre que le quieres dar al fichero de rangos amplios (sin '.txt'):\n" >> $informeSinColorTotal
            read seleccionNombreFicheroRangosAleT
            nomFicheroRangosAleT="./FRangosAleT/""$seleccionNombreFicheroRangosAleT.txt"
            echo -e "$seleccionNombreFicheroRangosAleT" >> $informeConColorTotal
            echo -e "$seleccionNombreFicheroRangosAleT" >> $informeSinColorTotal
            echo -e "$nomFicheroRangosAleT\n\n" >> $informeConColorTotal
            echo -e "$nomFicheroRangosAleT\n\n" >> $informeSinColorTotal
            until [[ ! -z "$seleccionNombreFicheroRangosAleT" && ! -f "$nomFicheroRangosAleT" && "$seleccionNombreFicheroRangosAleT" != "" ]];do  
                echo -e " Ya existe un archivo con el nombre introducido, o es nulo." | tee -a $informeConColorTotal
                echo -e " Ya existe un archivo con el nombre introducido, o es nulo."  >> $informeSinColorTotal
                echo -e " ¿Sobreescribirlo (S/N)?" | tee -a $informeConColorTotal  
                echo -e " ¿Sobreescribirlo (S/N)?" >> $informeSinColorTotal
                read sobrescri
                echo $sobrescri >> $informeConColorTotal
                echo $sobrescri >> $informeSinColorTotal
                until [[ "$sobrescri" == "S" || "$sobrescri" == "s" || "$sobrescri" == "N" || "$sobrescri" == "n" ]]; do
                    echo -e " Respuesta no válida, debe ser una de las opciones." | tee -a $informeConColorTotal  
                    echo -e " ¿Sobreescribirlo (S/N)?" | tee -a $informeConColorTotal  
                    echo -e " Respuesta no válida, debe ser S o N." >> $informeSinColorTotal
                    echo -e " ¿Sobreescribirlo (S/N)?" >> $informeSinColorTotal
                    read sobrescri
                    echo $sobrescri >> $informeConColorTotal
                    echo $sobrescri >> $informeSinColorTotal
                done
                if [[ $sobrescri == "S" || $sobrescri == "s" ]]; then
                    echo -e " Los datos se guardaran en el archivo $nomFicheroRangosAleT" | tee -a $informeConColorTotal  
                    echo -e " Los datos se guardaran en el archivo $nomFicheroRangosAleT" >> $informeSinColorTotal
                    rm $nomFicheroRangosAleT 
                fi
                if [[ $sobrescri == "N" || $sobrescri == "n" ]]; then
                    echo -e " Introduzca un nombre correcto: \n" | tee -a $informeConColorTotal
                    echo -e " Introduzca un nombre correcto: \n" >> $informeSinColorTotal
                    read seleccionNombreFicheroRangosAleT
                    nomFicheroRangosAleT="./FRangosAleT/""$seleccionNombreFicheroRangosAleT.txt"
                    echo -e " $seleccionNombreFicheroRangosAleT" >> $informeConColorTotal
                    echo -e " $seleccionNombreFicheroRangosAleT" >> $informeSinColorTotal
                    echo -e " $nomFicheroRangosAleT\n" >> $informeConColorTotal
                    echo -e " $nomFicheroRangosAleT\n" >> $informeSinColorTotal
#cierre el sobreescribir NO
            done
            ;;
#No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e "Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e "Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#Fin de preguntaDondeGuardarRangosAleTManuales()

#
# Sinopsis: Menú de elección del número de ensayos automáticos a ejecutar de forma continua.
#
function menuNumEnsayos { 
	seleccionNumEnsayos=0
	echo -ne $AMARILLO"\n\n Introduce el número de Ensayos a realizar de forma continua: \n$NORMAL" | tee -a $informeConColorTotal
	echo -ne "\n\n Introduce el número de Ensayos a realizar de forma continua: \n$NORMAL" >> $informeSinColorTotal
	read seleccionNumEnsayos
	echo -ne "$seleccionNumEnsayos\n\n" >> $informeConColorTotal
	echo -ne "$seleccionNumEnsayos\n\n" >> $informeSinColorTotal
	until [[ seleccionNumEnsayos -gt 0 ]]; do
		echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
		echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
		read seleccionNumEnsayos
		echo -e "$seleccionNumEnsayos\n\n" >> $informeConColorTotal
		echo -e "$seleccionNumEnsayos\n\n" >> $informeSinColorTotal
	done
#Fin de menuAlgoritmoPaginacion_TiempoConsiderado_valor()

#
#
#    Funciones de recogida de datos con ejecución cíclica automatizada
#
#
#
#Se definen y ejecutan los ensayos automáticos y se recogen los datos en ficheros secuenciales. Se usan datos diferentes en cada aloritmo de paginación y ensayo para buscar errores.
#
function ejecutarEnsayosDatosDiferentes { 
#Número de algoritmos de paginación que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#Número de algoritmos de paginación que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#Rango desde el que se extraen subrangos, desde los que se extraen datos, que se ejecutan con las diferentes opciones.
#Se pueden definir los diferentes modos de ejecución (1-Ejecución por eventos // 2-Ejecución automática (Por eventos y sin pausas) // 3-Ejecución completa (Por eventos con pausas de cierto número de segundos) // 4-Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo) // 5-Ejecución completa (Sin representación de resultados intermedios)) 
#Sólo se guardan los datos de las medias de los tiempos de espera y retorno, el número de fallos de página totales y el número de expulsiones de procesos forzadas en RR totales. Viene de la variable $seleccionMenuModoTiempoEjecucionAlgormitmo en el menú de selección de modo de ejecución MenuModoTiempoEjecucionAlgormitmo()			
	dirInformes="./Informes/RecogerDatosAutomDiferentes"
	if [[ ! -d $dirInformes ]]; then
		mkdir $dirInformes   
	fi
#Se inicializa la variable de fichero de datos dond se recogen todos los datos finales.
	if [[ -f $nomFicheroDatosEjecucionAutomatica ]]; then
#Se borran los ficheros anteriores
	fi
#Origen de los datos sobre los que se desarrollan los subrangos, sobre lso que se extraen los datos, sobre los que se ejecuta el programa.
	for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
		for (( indEnsayos = 1; indEnsayos <= $seleccionNumEnsayos; indEnsayos++ )); do 
#Se define el fichero sobre el que se guarda el rango amplio.
			if [[ -f $ficheroRangosAleTotalDefault ]]; then
#Se borran los ficheros anteriores
			fi
#Se define el fichero sobre el que se guardan los subrangos.
			if [[ -f $nomFicheroRangos ]]; then
#Se borran los ficheros anteriores
			fi
#Se define el fichero sobre el que se guardan los datos que se extraen de los subrangos.
			if [[ -f $nomFicheroDatos ]]; then
#Se borran los ficheros anteriores
			fi
#Se define el fichero sobre el que se guardan los volcados en COLOR.
			if [[ -f $informeSinColorTotal ]]; then
#Se borran los ficheros anteriores
			fi
#Se define el fichero sobre el que se guardan los volcados en BN.
			if [[ -f $informeConColorTotal ]]; then
#Se borran los ficheros anteriores
			fi
#Leer los datos desde el fichero elegido $ficheroRangosAleTotalAnteriorEjecucion
#Se piden y tratan los mínimos y máximos de los rangos. El cálculo de los datos aleatorios con los que se trabajará se hace en entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun. 
#Ordena los datos para ser mostrados y considerados por orden de llegada.
			echo -e "Algoritmo de paginación: $seleccionAlgoritmoPaginacion\n" >> $informeConColorTotal
			echo -e "Número de Ensayo: $indEnsayos\n" >> $informeConColorTotal
#Cuando se han definido todas las opciones se inicia la ejecución del programa
#Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
			echo -e "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado AlgPag $seleccionAlgoritmoPaginacion NumEnsayo $indEnsayos Tesperamedio $promedio_espera T.retornomedio $promedio_retorno TotalFallosPagina $suma_contadorAlgPagFallosProcesoAcumulado TotalExpulsionesForzadasRR $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
		done
	done
#Fin de ejecutarEnsayosDatosDiferentes()

#
#Se definen y ejecutan los ensayos automáticos y se recogen los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
#
function ejecutarEnsayosDatosIguales { 
#Número de algoritmos de paginación que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#Rango desde el que se extraen subrangos, desde los que se extraen datos, que se ejecutan con las diferentes opciones.
#Se pueden definir los diferentes modos de ejecución (1-Ejecución por eventos // 2-Ejecución automática (Por eventos y sin pausas) // 3-Ejecución completa (Por eventos con pausas de cierto número de segundos) // 4-Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo) // 5-Ejecución completa (Sin representación de resultados intermedios)) 
#Sólo se guardan los datos de las medias de los tiempos de espera y retorno, el número de fallos de página totales y el número de expulsiones de procesos forzadas en RR totales. Viene de la variable $seleccionMenuModoTiempoEjecucionAlgormitmo en el menú de selección de modo de ejecución MenuModoTiempoEjecucionAlgormitmo()			
	dirInformes="./Informes/RecogerDatosAutomIguales"
#Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
	if [[ ! -d $dirInformes ]]; then
		mkdir $dirInformes   
	fi
#Se inicializa la variable de fichero de datos dond se recogen todos los datos finales.
	if [[ -f $nomFicheroDatosEjecucionAutomatica ]]; then
#Se borran los ficheros anteriores
	fi
			echo -ne "Título AlgPag NumEnsayo T.esperamedio T.retornomedio TotalFallosPagina TotalExpulsionesForzadasRR" >> $nomFicheroDatosEjecucionAutomatica
			echo -ne " MáxFrec TiempoConsiderado FrecValor Clase" >> $nomFicheroDatosEjecucionAutomatica
			echo -e " MáxUsoRec TiempoConsiderado UsoRecValor Clase" >> $nomFicheroDatosEjecucionAutomatica
#Origen de los datos sobre los que se desarrollan los subrangos, sobre lso que se extraen los datos, sobre los que se ejecuta el programa.
#Primero se inicializan los ficheros con los datos a tratar.
#Se define el fichero sobre el que se guarda el rango amplio.
		if [[ -f $ficheroRangosAleTotalDefault ]]; then
#Se borran los ficheros anteriores
		fi
#Se define el fichero sobre el que se guardan los subrangos.
		if [[ -f $nomFicheroRangos ]]; then
#Se borran los ficheros anteriores
		fi
#Se define el fichero sobre el que se guardan los datos que se extraen de los subrangos.
		if [[ -f $nomFicheroDatos ]]; then
#Se borran los ficheros anteriores
		fi
#Leer los datos desde el fichero elegido $ficheroRangosAleTotalAnteriorEjecucion
#Se piden y tratan los mínimos y máximos de los rangos. El cálculo de los datos aleatorios con los que se trabajará se hace en entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun. 
	done
#Ahora se leen los datos ya guardados en los ficheros de datos y se tratan.
#Se define el fichero desde el que se leen los datos que se extraen de los subrangos.
		maxDatoCierre=0
		leer_datos_desde_fichero $nomFicheroDatos
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
			maxDato=0
			maxDatoCierre=1
#Se calcula el mayor de lso tiempos de ejecución para calcular un valor aleatorio entre 1 y ese máximo. Podría usarse cualquier rango, pero este dato puede estar relacionado con lso datos del problema.
				if [[ ${ejecucion[$i]} -gt $maxDato ]]; then 
					maxDato=${ejecucion[$i]} 
				fi
			done
		fi
		for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
#Se define el fichero sobre el que se guardan los volcados en COLOR.
			if [[ -f $informeSinColorTotal ]]; then
#Se borran los ficheros anteriores
			fi
#Se define el fichero sobre el que se guardan los volcados en BN.
			if [[ -f $informeConColorTotal ]]; then
#Se borran los ficheros anteriores
			fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#8-9-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_frecuencia_valor=$datoAleatorioGeneral
			fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#10-11-Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#10-11-Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_frecuencia_valor=$datoAleatorioGeneral
#10-11-Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
			fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#14-15-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_uso_rec_valor=$datoAleatorioGeneral
			fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#16-17-Se pide el número de unidades de tiempo de ejecución de un proceso, a partir del cual, serán consideradas la frecuencia/tiempo de uso de una página y su clase: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de la antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_uso_rec_valor=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de unidades de tiempo de antigüedad de ejecución de un proceso, a partir de la cual, una página será considerada como NO referenciada: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
			fi
#Ordena los datos para ser mostrados y considerados por orden de llegada.
			echo -ne "$NORMAL\nAlgoritmo de paginación:$seleccionAlgoritmoPaginacion" | tee -a $informeConColorTotal
			echo -ne "$NORMAL\nNúmero de Ensayo:$indEnsayos\n" | tee -a $informeConColorTotal
			echo -e "Algoritmo de paginación: $seleccionAlgoritmoPaginacion" >> $informeSinColorTotal
			echo -e "Número de Ensayo: $indEnsayos" >> $informeSinColorTotal
#Cuando se han definido todas las opciones se inicia la ejecución del programa
#Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
			echo -ne "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado $seleccionAlgoritmoPaginacion $indEnsayos $promedio_espera $promedio_retorno $suma_contadorAlgPagFallosProcesoAcumulado $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
			echo -ne " $seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
			echo -e " $seleccionAlgoritmoPaginacion_uso_rec_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
		done
	done	
#Fin de ejecutarEnsayosDatosIguales()

#
#Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
#
function ejecutarEnsayosDatosIgualesAnteriores { 
#Número de algoritmos de paginación que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#Datos, que se ejecutan con las diferentes opciones.
#Se pueden definir los diferentes modos de ejecución (1-Ejecución por eventos // 2-Ejecución automática (Por eventos y sin pausas) // 3-Ejecución completa (Por eventos con pausas de cierto número de segundos) // 4-Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo) // 5-Ejecución completa (Sin representación de resultados intermedios)) 
#Sólo se guardan los datos de las medias de los tiempos de espera y retorno, el número de fallos de página totales y el número de expulsiones de procesos forzadas en RR totales. Viene de la variable $seleccionMenuModoTiempoEjecucionAlgormitmo en el menú de selección de modo de ejecución MenuModoTiempoEjecucionAlgormitmo()			
	dirInformes="./Informes/RecogerDatosAutomIguales"
	dirInformesAnteriores="./Informes/RecogerDatosAutomIgualesAnteriores"
#Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
	if [[ ! -d $dirInformesAnteriores ]]; then
		mkdir $dirInformesAnteriores   
	fi
#Primero se inicializan los ficheros con los datos a tratar.
#Se define el fichero sobre el que se guardan los datos que se extraen de los subrangos.
		if [[ -f $nomFicheroDatos ]]; then
#Se borran los ficheros anteriores
		fi
	done
    files=($dirInformes"/DatosDefault"*".txt")
    echo -e "\n\nFicheros existentes:\n$NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\nFicheros existentes:\n" >> $informeSinColorTotal 
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
        echo -e ${files[$i]} 
        cp ${files[$i]} "$dirInformesAnteriores/"
    done
#Se inicializa la variable de fichero de datos dond se recogen todos los datos finales.
	if [[ -f $nomFicheroDatosEjecucionAutomatica ]]; then
#Se borran los ficheros anteriores
	fi
	echo -ne "Título AlgPag NumEnsayo T.esperamedio T.retornomedio TotalFallosPagina TotalExpulsionesForzadasRR" >> $nomFicheroDatosEjecucionAutomatica
	echo -ne " MáxFrec TiempoConsiderado FrecValor Clase" >> $nomFicheroDatosEjecucionAutomatica
	echo -e " MáxUsoRec TiempoConsiderado UsoRecValor Clase" >> $nomFicheroDatosEjecucionAutomatica
#Ahora se leen los datos ya guardados en los ficheros de datos y se tratan.
#Se define el fichero desde el que se leen los datos que se extraen de los subrangos.
		maxDatoCierre=0
		leer_datos_desde_fichero $nomFicheroDatos
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
			maxDato=0
			maxDatoCierre=1
#Se calcula el mayor de lso tiempos de ejecución para calcular un valor aleatorio entre 1 y ese máximo. Podría usarse cualquier rango, pero este dato puede estar relacionado con lso datos del problema.
				if [[ ${ejecucion[$i]} -gt $maxDato ]]; then 
					maxDato=${ejecucion[$i]} 
				fi
			done
		fi
		for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
#Se define el fichero sobre el que se guardan los volcados en COLOR.
			if [[ -f $informeSinColorTotal ]]; then
#Se borran los ficheros anteriores
			fi
#Se define el fichero sobre el que se guardan los volcados en BN.
			if [[ -f $informeConColorTotal ]]; then
#Se borran los ficheros anteriores
			fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#8-9-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_frecuencia_valor=$datoAleatorioGeneral
			fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#10-11-Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#10-11-Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_frecuencia_valor=$datoAleatorioGeneral
#10-11-Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
			fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#14-15-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_uso_rec_valor=$datoAleatorioGeneral
			fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#16-17-Se pide el número de unidades de tiempo de ejecución de un proceso, a partir del cual, serán consideradas la frecuencia/tiempo de uso de una página y su clase: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de la antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_uso_rec_valor=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de unidades de tiempo de antigüedad de ejecución de un proceso, a partir de la cual, una página será considerada como NO referenciada: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
			fi
#Ordena los datos para ser mostrados y considerados por orden de llegada.
			echo -ne "$NORMAL\nAlgoritmo de paginación:$seleccionAlgoritmoPaginacion" | tee -a $informeConColorTotal
			echo -ne "$NORMAL\nNúmero de Ensayo:$indEnsayos\n" | tee -a $informeConColorTotal
			echo -e "Algoritmo de paginación: $seleccionAlgoritmoPaginacion" >> $informeSinColorTotal
			echo -e "Número de Ensayo: $indEnsayos" >> $informeSinColorTotal
#Cuando se han definido todas las opciones se inicia la ejecución del programa
#Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
			echo -ne "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado $seleccionAlgoritmoPaginacion $indEnsayos $promedio_espera $promedio_retorno $suma_contadorAlgPagFallosProcesoAcumulado $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
			echo -ne " $seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
			echo -e " $seleccionAlgoritmoPaginacion_uso_rec_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
		done
	done	
#Fin de ejecutarEnsayosDatosIgualesAnteriores()

#
#Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
#
function ejecutarEnsayosDatosIgualesAnterioresCompleto { 	
#Se define la fuente de datos utilizada para la obtención de los datos a utilizar en el posterior tratamiento. 
#Datos, que se ejecutan con las diferentes opciones.
#Se definen los diferentes modos de ejecución (1-Ejecución por eventos // 2-Ejecución automática (Por eventos y sin pausas) // 3-Ejecución completa (Por eventos con pausas de cierto número de segundos) // 4-Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo) // 5-Ejecución completa (Sin representación de resultados intermedios)) 
#Sólo se guardan los datos de las medias de los tiempos de espera y retorno, el número de fallos de página totales y el número de expulsiones de procesos forzadas en RR totales. Viene de la variable $seleccionMenuModoTiempoEjecucionAlgormitmo en el menú de selección de modo de ejecución MenuModoTiempoEjecucionAlgormitmo()			
#Se definen los diferentes directorios utilizados para guardar los datos obtenidos
	dirInformes="./Informes/RecogerDatosAutomIguales"
	dirInformesAnterioresCompleto="./Informes/RecogerDatosAutomIgualesAnterioresCompleto"
#Se definen las variables necesarias para ejecutar los diferentes algoritmos y opciones.
#Define el título de la cabecera de los volcados
#Define el número de ensayo tratado 
#Define el algoritmo usado para resolver la gestión de Procesos (FCFS/SJF/SRPT/Prioridades/Round-Robin)
#Máximo número de algoritmos de gestión de procesos (FCFS (1), SJF (2), SRPT (3), Prioridades (4), Round-Robin (5)) que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#Máximo número de opciones del tipo de memoria (No Continua (1)/Continua (2)) 
#Máximo número de opciones del tipo de memoria (No Continua (0)/Continua (1)) 
#Máximo número de opciones del tipo de memoria (No Reubicable (1)/Reubicable (2)) 
#Máximo número de opciones del tipo de reubicabilidad (No Reubicable (0)/Reubicable (1)) 
#Define el algoritmo usado para resolver los fallos de página.
#Máximo número de algoritmos de paginación (FIFO, Reloj, SegOp, Óptimo, MFU, LFU, NFU, MRU, LRU, NRU,...) que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#Máximo número de opciones del tipo de prioridad (Mayor (1)/Menor (2)) 
#Máximo número de opciones del tipo de apropiatividad (No Apropiativo (1)/Apropiativo (2)) 
#Máximo número de opciones del tipo de apropiatividad (No Apropiativo (0)/Apropiativo (1)) 
#Define el tiempo de espera medio de los procesos 
#Define el tiempo de retorno medio de los procesos
#Define el número de fallos de página producidos
#Define el número de expulsiones forzadas por Round-Robin (RR)
#Define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
#Define el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#Define el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#Define el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada en algoritmos basados en la "frecuencia/tiempo de antigüedad" de uso
#Define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#Define el valor máximo del contador de antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.
	
	if [[ ! -d $dirInformesAnterioresCompleto ]]; then
		mkdir $dirInformesAnterioresCompleto   
	fi
#Primero se inicializan los ficheros con los datos a tratar.
#Se define el fichero sobre el que se guardan los datos que se extraen de los subrangos.
		if [[ -f $nomFicheroDatos ]]; then
#Se borran los ficheros anteriores
		fi
	done
    files=($dirInformes"/DatosDefault"*".txt")
    echo -e "\n\nFicheros existentes:\n$NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\nFicheros existentes:\n" >> $informeSinColorTotal 
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
        echo -e ${files[$i]} 
        cp ${files[$i]} "$dirInformesAnterioresCompleto/"
    done
#Se inicializa la variable de fichero de datos dond se recogen todos los datos finales.
	if [[ -f $nomFicheroDatosEjecucionAutomatica ]]; then
#Se borran los ficheros anteriores
	fi
	echo -ne "Título NumEnsayo AlgGestProc Contin Reubic AlgPag TipoPrio Apropia Quantum" >> $nomFicheroDatosEjecucionAutomatica
	echo -ne " T.esperamedio T.retornomedio TotalFallosPagina TotalExpulsionesForzadasRR" >> $nomFicheroDatosEjecucionAutomatica
	echo -ne " MáxFrec TiempoConsiderado FrecValor FrecClase" >> $nomFicheroDatosEjecucionAutomatica
	echo -e " MáxUsoRec TiempoConsiderado UsoRecValor UsoRecClase" >> $nomFicheroDatosEjecucionAutomatica
#Ahora se leen los datos ya guardados en los ficheros de datos y se tratan.
#Se define el fichero desde el que se leen los datos que se extraen de los subrangos.
#Si no se encuentra un archivo de datos por no haber creado previamente el conjunto de datos necesario, se muestra un mensaje de error y se para el bucle.
		echo -ne "Error: No se encuentra el fichero de datos "$nomFicheroDatos | tee -a $informeConColorTotal
		echo -ne "Error: No se encuentra el fichero de datos "$nomFicheroDatos >> $informeSinColorTotal 
		break
	fi		
		maxDatoCierre=0
		leer_datos_desde_fichero $nomFicheroDatos
#Define el quantum utilizado en Round-Robin (RR). Se usa para salvar el dato hasta que se necesite y que no se repita en los listados.
#Define el quantum utilizado en Round-Robin (RR)
#Define el tipo de apropiatividad utilizado en Prioridad. Se usa para salvar el dato hasta que se necesite y que no se repita en los listados.
#Define el Tipo de Prioridad (Mayor (1)/Menor (2)).
#Define el modo de apropiatividad utilizado en Prioridad. Se usa para salvar el dato hasta que se necesite y que no se repita en los listados.
#Define el Tipo de Apropiatividad (No Apropiativo (1)/Apropiativo (2)).
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
			maxDato=0
			maxDatoCierre=1
#Se calcula el mayor de lso tiempos de ejecución para calcular un valor aleatorio entre 1 y ese máximo. Podría usarse cualquier rango, pero este dato puede estar relacionado con lso datos del problema.
				if [[ ${ejecucion[$i]} -gt $maxDato ]]; then 
					maxDato=${ejecucion[$i]} 
				fi
			done
		fi
		for (( seleccionMenuAlgoritmoGestionProcesos=1 ; seleccionMenuAlgoritmoGestionProcesos<=$numAlgoritmosGestionProcesos ; seleccionMenuAlgoritmoGestionProcesos++ )); do
			if ([[ $seleccionMenuAlgoritmoGestionProcesos -ge 1 && $seleccionMenuAlgoritmoGestionProcesos -le 3 ]]) || [[ $seleccionMenuAlgoritmoGestionProcesos -eq 5 ]]; then
#Para que se equipare al programa nuevo. Se aconseja quitar la variable $alg y estandarizar las variables a usar ??????????. También se define en menuAlgoritmoGestionProcesos, pero resulta necesario cuando no se pregunta por el algoritmo de gestión de procesos porque se ejecutan todos. 
#Define el quantum utilizado en Round-Robin (RR). Se usa para recuperar el dato cuando se necesite y que no se repita en los listados.
#Se hace para eliminar el espacio que contiene la variable, y por el que la exportación a fichero da problemas porque el resto de datos se desplazan hacia la derecha.
				fi
#Define el número de opciones del tipo de memoria (Continua/No Continua)
				for (( seleccionMenuContinuidad=1 ; seleccionMenuContinuidad<=$numAlgoritmosContinuidad ; seleccionMenuContinuidad++ )); do
#Define el número de opciones del tipo de memoria (Reubicable/No Reubicable)
					for (( seleccionMenuReubicabilidad=1 ; seleccionMenuReubicabilidad<=$numAlgoritmosReubicabilidad ; seleccionMenuReubicabilidad++ )); do		
						for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
#Se define el fichero sobre el que se guardan los volcados en COLOR.
							if [[ -f $informeSinColorTotal ]]; then
#Se borran los ficheros anteriores
							fi
#Se define el fichero sobre el que se guardan los volcados en BN.
							if [[ -f $informeConColorTotal ]]; then
#Se borran los ficheros anteriores
							fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#8-9-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_frecuencia_valor=$datoAleatorioGeneral
							fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#10-11-Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
# Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#10-11-Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
# Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_clases_frecuencia_valor=$datoAleatorioGeneral
#10-11-Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
# Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
							fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#14-15-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_uso_rec_valor=$datoAleatorioGeneral
							fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#16-17-Se pide el número de unidades de tiempo de ejecución de un proceso, a partir del cual, serán consideradas la frecuencia/tiempo de uso de una página y su clase: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de la antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_clases_uso_rec_valor=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de unidades de tiempo de antigüedad de ejecución de un proceso, a partir de la cual, una página será considerada como NO referenciada: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
							fi
#Ordena los datos para ser mostrados y considerados por orden de llegada.
#Cuando se han definido todas las opciones se inicia la ejecución del programa
#Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
							echo -e "$NORMAL\n Número de Ensayo:$indEnsayos" | tee -a $informeConColorTotal
							echo -e "$NORMAL Algoritmo:$algoritmoPaginacionContinuidadReubicabilidadSeleccionado" | tee -a $informeConColorTotal
							echo -e " Número de Ensayo: $indEnsayos" >> $informeSinColorTotal
							echo -e " Algoritmo: $algoritmoPaginacionContinuidadReubicabilidadSeleccionado" >> $informeSinColorTotal
							echo -ne "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado $indEnsayos $seleccionMenuAlgoritmoGestionProcesos $seleccionMenuContinuidad $seleccionMenuReubicabilidad $seleccionAlgoritmoPaginacion" >> $nomFicheroDatosEjecucionAutomatica
							echo -ne " $seleccionTipoPrioridad $seleccionMenuApropiatividad $quantum $promedio_espera $promedio_retorno $suma_contadorAlgPagFallosProcesoAcumulado $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
							echo -ne " $seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
							echo -e " $seleccionAlgoritmoPaginacion_uso_rec_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
							
#Se inicializan a "" para empezar el siguiente ciclo.
							seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=""
							seleccionAlgoritmoPaginacion_clases_frecuencia_valor=""
							seleccionAlgoritmoPaginacion_clases_valor=""
							seleccionAlgoritmoPaginacion_uso_rec_valor=""
							seleccionAlgoritmoPaginacion_clases_uso_rec_valor=""

#$seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_uso_rec_valor
					done
				done
#Define el quantum utilizado en Round-Robin (RR). Se vuelve a anular hasta que se necesite.
			fi
			if [[ $seleccionMenuAlgoritmoGestionProcesos -eq 4 ]]; then
#Para que se equipare al programa nuevo. Se aconseja quitar la variable $alg y estandarizar las variables a usar ??????????.
#Define el Tipo de Prioridad (Mayor (1)/Menor (2)).
				for (( seleccionTipoPrioridad=1 ; seleccionTipoPrioridad<=$numAlgoritmosTipoPrioridad ; seleccionTipoPrioridad++ )); do
#Define el Tipo de Apropiatividad (No Apropiativo (1)/Apropiativo (2)).
					for (( seleccionMenuApropiatividad=1 ; seleccionMenuApropiatividad<=numAlgoritmosApropiatividad ; seleccionMenuApropiatividad++ )); do
#Define el número de opciones del tipo de memoria (Continua/No Continua)
						for (( seleccionMenuContinuidad=1 ; seleccionMenuContinuidad<=$numAlgoritmosContinuidad ; seleccionMenuContinuidad++ )); do
#Define el número de opciones del tipo de memoria (Reubicable/No Reubicable)
							for (( seleccionMenuReubicabilidad=1 ; seleccionMenuReubicabilidad<=$numAlgoritmosReubicabilidad ; seleccionMenuReubicabilidad++ )); do		
								for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
#Se define el fichero sobre el que se guardan los volcados en COLOR.
									if [[ -f $informeSinColorTotal ]]; then
#Se borran los ficheros anteriores
									fi
#Se define el fichero sobre el que se guardan los volcados en BN.
									if [[ -f $informeConColorTotal ]]; then
#Se borran los ficheros anteriores
									fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#8-9-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_frecuencia_valor=$datoAleatorioGeneral
									fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#10-11-Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
# Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#10-11-Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
# Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_clases_frecuencia_valor=$datoAleatorioGeneral
#10-11-Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
# Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
									fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#14-15-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_uso_rec_valor=$datoAleatorioGeneral
									fi
#Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#16-17-Se pide el número de unidades de tiempo de ejecución de un proceso, a partir del cual, serán consideradas la frecuencia/tiempo de uso de una página y su clase: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de la antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_clases_uso_rec_valor=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de unidades de tiempo de antigüedad de ejecución de un proceso, a partir de la cual, una página será considerada como NO referenciada: \n$NORMAL" | tee -a $informeConColorTotal
# Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
									fi
#Ordena los datos para ser mostrados y considerados por orden de llegada.
#Cuando se han definido todas las opciones se inicia la ejecución del programa
#Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
									echo -e "$NORMAL\n Número de Ensayo: $indEnsayos" | tee -a $informeConColorTotal
									echo -e "$NORMAL Algoritmo: $algoritmoPaginacionContinuidadReubicabilidadSeleccionado" | tee -a $informeConColorTotal
									echo -e " Número de Ensayo: $indEnsayos" >> $informeSinColorTotal
									echo -e " Algoritmo: $algoritmoPaginacionContinuidadReubicabilidadSeleccionado" >> $informeSinColorTotal
									echo -ne "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado $indEnsayos $seleccionMenuAlgoritmoGestionProcesos $seleccionMenuContinuidad $seleccionMenuReubicabilidad $seleccionAlgoritmoPaginacion" >> $nomFicheroDatosEjecucionAutomatica
									echo -ne " $seleccionTipoPrioridad $seleccionMenuApropiatividad $quantum $promedio_espera $promedio_retorno $suma_contadorAlgPagFallosProcesoAcumulado $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
									echo -ne " $seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
									echo -e " $seleccionAlgoritmoPaginacion_uso_rec_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
								
#Se inicializan a "" para empezar el siguiente ciclo.
									seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=""
									seleccionAlgoritmoPaginacion_clases_frecuencia_valor=""
									seleccionAlgoritmoPaginacion_clases_valor=""
									seleccionAlgoritmoPaginacion_uso_rec_valor=""
									seleccionAlgoritmoPaginacion_clases_uso_rec_valor=""
#$seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_uso_rec_valor 
							done
						done
					done
#Define el Tipo de Apropiatividad (No Apropiativo (1)/Apropiativo (2)). Se vuelve a anular hasta que se vuelva a necesitar.
				done
#Define el Tipo de Prioridad (Mayor (1)/Menor (2)). Se vuelve a anular hasta que se vuelva a necesitar.
			fi
		done
	done	
	
#Fin de ejecutarEnsayosDatosIgualesAnterioresCompleto()

#
#
#    Funciones
#
#
#
# Sinopsis: Para colorear lo impreso en pantalla.
#
function cecho {
	local default_msg="No message passed."                     
    message=${1:-$default_msg}   
    color=${2:-$FWHT}           
    echo -en "$color"
    echo "$message"
    tput sgr0                    
    return
#Fin de cecho()

#
# Sinopsis: Genera los números de página a partir de las direcciones del proceso. 
#
function transformapag {
    let pagTransformadas[$2]=`expr $1/$mem_direcciones`
#Fin de transformapag()

#
# Sinopsis: Calcula el número de direcciones por cada proceso y lo guarda en npagprocesos y el mayor número de páginas entre todos los procesos.
#
function vermaxpagsfichero {
#Empieza en 14 por ser la primera línea del fichero con procesos.
	for (( npagp = 0; npagp <= $p; npagp++ )); do
		npagprocesos[$p]=`awk "NR==$i" $1 | wc -w `
		(( i++ ))	
	done
#No se usa para nada
#Calcula el mayor número de páginas de entre todos los procesos.
		if (( $verlas > $maxpags )); then
			maxpags=$verlas
		fi
	done
#Fin de vermaxpagsfichero()

#
# Sinopsis: Se leen datos desde fichero 
#
function leer_datos_desde_fichero {
#Lee los datos del fichero 
#Primer dato -> Tamaño en memoria
#Quinto dato -> Tamaño de pagina
	numDireccionesTotales=$(($mem_total * $mem_direcciones))
#Segundo dato -> Prioridad menor
#Tercero dato -> Prioridad mayor
#Cuarto dato -> Tipo de prioridad - Realmente no se usa porque se introduce por teclado al seleccionar el algoritmo de gestión de procesos mediante la variable de selección $seleccionTipoPrioridad. 
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#Sexto dato -> Variable para la reubicabilidad - Realmente no se usa porque se introduce por teclado tras seleccionar la posibilidad de reubicar procesos. 
#Séptimo dato -> Quantum de Round Robin (RR)
	maxfilas=`wc -l < $1`
#Número de marcos totales de la memoria
#Número de marcos vacíos
#Tamaño de memoria total en direcciones
#Número de procesos definidos en el problema
#Índice local que recorre cada proceso definido en el problema
#Índice que recorre cada dirección de cada proceso definido en el problema
#Define el número de dígitos de pantalla usados para controlar los saltos de línea. Deja 1 de margen izquierdo y varios más para controlar el comienzo del espacio usado para los datos en la tabla resumen.
#Se inicia con 16 por ser la primera línea del fichero que contiene procesos. 
		llegada[$p]=`awk "NR==$fila" $1 |  cut -d ' ' -f 1`
		memoria[$p]=`awk "NR==$fila" $1 |  cut -d ' ' -f 2`
		prioProc[$p]=`awk "NR==$fila" $1 |  cut -d ' ' -f 3`
#(Usa el número de línea donde empiezan a definirse los procesos.) Calcula el número de direcciones por cada proceso y lo guarda en npagprocesos[] y el mayor número de páginas entre todos los procesos (maxpags).
		ejecucion[$p]=$(expr $[npagprocesos[$p]] - 3)
#Para ser equivalente al nuevo programa
#Contendrá el número de páginas ya usadas en la ejecución de cada proceso
#El nombre de los procesos está predefinido: P01, P02, ...
		numOrdinalPagTeclado=0
#maxpags es el mayor número de páginas entre todos los procesos. Se inicia con 4 por ser el primer campo que contiene direcciones en cada fila.
			directionsYModificado=`awk "NR==$fila" $1 | cut -d ' ' -f $i` 
			directions[$p,$numOrdinalPagTeclado]=`echo $directionsYModificado | cut -d '-' -f 1`
			directions_AlgPagFrecUsoRec_pagina_modificada[$p,$numOrdinalPagTeclado,0]=`echo $directionsYModificado | cut -d '-' -f 2`
			if [[ $seleccionAlgoritmoPaginacion -eq 0 && ${directions[$p,$numOrdinalPagTeclado]} -gt $(($numDireccionesTotales - 1)) ]]; then
				echo -e "\n***Error en la lectura de datos. La dirección de memoria utilizada está fuera del rango definido por el número de marcos de página.\n"
				exit 1
			fi
#let pagTransformadas[$2]=`expr $1/$mem_direcciones`
			paginasDefinidasTotal[$p,$numOrdinalPagTeclado]=${pagTransformadas[$numOrdinalPagTeclado]} 
#Posición en la que se define cada dirección dentro de un proceso.
			((one++))
		done
#Se elimina para poder hacer una segunda lectura sin datos anteriores.
		p=$((p+1))
	done 
#	clear
#Se almacena el cálculo aleatorio de si una página es o no modificada al ser ejecutada.


#
# Sinopsis: Extrae los límites de los rangos del fichero de rangos de última ejecución. 
#
function leer_rangos_desde_fichero {
    memoria_min=($(cat $1 | grep "RangoMarcosMemoria" | cut -f 2 -d " "))
    memoria_max=($(cat $1 | grep "RangoMarcosMemoria" | cut -f 3 -d " "))
    direcciones_min=($(cat $1 | grep "RangoDireccionesMarco" | cut -f 2 -d " "))
    direcciones_max=($(cat $1 | grep "RangoDireccionesMarco" | cut -f 3 -d " "))
    prio_menor_min=($(cat $1 | grep "RangoPrioMenor" | cut -f 2 -d " "))
    prio_menor_max=($(cat $1 | grep "RangoPrioMenor" | cut -f 3 -d " "))
    prio_mayor_min=($(cat $1 | grep "RangoPrioMayor" | cut -f 2 -d " "))
    prio_mayor_max=($(cat $1 | grep "RangoPrioMayor" | cut -f 3 -d " "))
    programas_min=($(cat $1 | grep "RangoNumProc" | cut -f 2 -d " "))
    programas_max=($(cat $1 | grep "RangoNumProc" | cut -f 3 -d " "))
    reubicacion_min=($(cat $1 | grep "RangoReubicar" | cut -f 2 -d " "))
    reubicacion_max=($(cat $1 | grep "RangoReubicar" | cut -f 3 -d " "))
    llegada_min=($(cat $1 | grep "RangoLlegada" | cut -f 2 -d " "))
    llegada_max=($(cat $1 | grep "RangoLlegada" | cut -f 3 -d " "))
    tiempo_ejec_min=($(cat $1 | grep "RangoTEjecucion" | cut -f 2 -d " "))
    tiempo_ejec_max=($(cat $1 | grep "RangoTEjecucion" | cut -f 3 -d " "))
    tamano_marcos_proc_min=($(cat $1 | grep "RangoTamanoMarcosProc" | cut -f 2 -d " "))
    tamano_marcos_proc_max=($(cat $1 | grep "RangoTamanoMarcosProc" | cut -f 3 -d " "))
    prio_proc_min=($(cat $1 | grep "RangoPrioProc" | cut -f 2 -d " "))
    prio_proc_max=($(cat $1 | grep "RangoPrioProc" | cut -f 3 -d " "))
    quantum_min=($(cat $1 | grep "RangoQuantum" | cut -f 2 -d " "))
    quantum_max=($(cat $1 | grep "RangoQuantum" | cut -f 3 -d " "))
    tamano_direcciones_proc_min=($(cat $1 | grep "RangoTamanoDireccionesProc" | cut -f 2 -d " "))
    tamano_direcciones_proc_max=($(cat $1 | grep "RangoTamanoDireccionesProc" | cut -f 3 -d " "))
    memoria_minInicial=$memoria_min
    memoria_maxInicial=$memoria_max
    direcciones_minInicial=$direcciones_min
    direcciones_maxInicial=$direcciones_max
#Se invierten los rangos para calcular el mínimo, pero no para su representación, en la que se verán los datos originales *Inicial.
#*Inicial - Datos a representar
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	prio_menor_min=$PriomFinal
	prio_menor_max=$PrioMFinal
#Se invierten los rangos para calcular el mínimo, pero no para su representación, en la que se verán los datos originales *Inicial.
#*Inicial - Datos a representar
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	prio_mayor_min=$PriomFinal
	prio_mayor_max=$PrioMFinal
    programas_minInicial=$programas_min
    programas_maxInicial=$programas_max
    reubicacion_minInicial=$reubicacion_min
    reubicacion_maxInicial=$reubicacion_max
    llegada_minInicial=$llegada_min
    llegada_maxInicial=$llegada_max
    tiempo_ejec_minInicial=$tiempo_ejec_min
    tiempo_ejec_maxInicial=$tiempo_ejec_max
    tamano_marcos_proc_minInicial=$tamano_marcos_proc_min
    tamano_marcos_proc_maxInicial=$tamano_marcos_proc_max
    prio_proc_minInicial=$prio_proc_min
    prio_proc_maxInicial=$prio_proc_max
    quantum_minInicial=$quantum_min
    quantum_maxInicial=$quantum_max
    tamano_direcciones_proc_minInicial=$tamano_direcciones_proc_min
    tamano_direcciones_proc_maxInicial=$tamano_direcciones_proc_max
#Si el mayor es menor que el menor, se invierten los rangos 
        invertirRangos $memoria_min $memoria_max
        memoria_min=$min
        memoria_max=$max
    fi 
#Si ambos son negativos se desplazan a positivos
        desplazarRangos $memoria_min $memoria_max
        memoria_min=$min
        memoria_max=$max
    fi 
    if [[ $direcciones_min -gt $direcciones_max ]]; then 
        invertirRangos $direcciones_min $direcciones_max
        direcciones_min=$min
        direcciones_max=$max
    fi 
    if [[ $direcciones_min -lt 0 ]]; then 
        desplazarRangos $direcciones_min $direcciones_max
        direcciones_min=$min
        direcciones_max=$max
    fi 
    if [[ $programas_min -gt $programas_max ]]; then
        invertirRangos $programas_min $programas_max
        programas_min=$min
        programas_max=$max
    fi
    if [[ $programas_min -lt 0 ]]; then 
        desplazarRangos $programas_min $programas_max
        programas_min=$min
        programas_max=$max
    fi 
    if [[ $reubicacion_min -gt $reubicacion_max ]]; then
        invertirRangos $reubicacion_min $reubicacion_max
        reubicacion_min=$min
        reubicacion_max=$max
    fi
    if [[ $reubicacion_min -lt 0 ]]; then 
        desplazarRangos $reubicacion_min $reubicacion_max
        reubicacion_min=$min
        reubicacion_max=$max
    fi 
    if [[ $llegada_min -gt $llegada_max ]]; then
        invertirRangos $llegada_min $llegada_max
        llegada_min=$min
        llegada_max=$max
    fi
    if [[ $llegada_min -lt 0 ]]; then 
        desplazarRangos $llegada_min $llegada_max
#Este valor podría ser 0 
        llegada_max=$(($max - 1))
    fi 
    if [[ $tiempo_ejec_min -gt $tiempo_ejec_max ]]; then
        invertirRangos $tiempo_ejec_min $tiempo_ejec_max
        tiempo_ejec_min=$min
        tiempo_ejec_max=$max
    fi
    if [[ $tiempo_ejec_min -lt 0 ]]; then 
        desplazarRangos $tiempo_ejec_min $tiempo_ejec_max
#Este valor podría ser 0 
        tiempo_ejec_max=$(($max - 1))
    fi 
    if [[ $tamano_marcos_proc_min -gt $tamano_marcos_proc_max ]]; then
        invertirRangos $tamano_marcos_proc_min $tamano_marcos_proc_max
        tamano_marcos_proc_min=$min
        tamano_marcos_proc_max=$max
    fi
    if [[ $tamano_marcos_proc_min -lt 0 ]]; then 
        desplazarRangos $tamano_marcos_proc_min $tamano_marcos_proc_max
        tamano_marcos_proc_min=$min
        tamano_marcos_proc_max=$max
    fi 
#?????????????????
        invertirRangos $prio_proc_min $prio_proc_max
#Los valroes de las prioridades podrían ser 0 o negativos. 
        prio_proc_max=$max
    fi
#?????????????????
        desplazarRangos $prio_proc_min $prio_proc_max
        prio_proc_min=$min
        prio_proc_max=$max
    fi 
    if [[ $tamano_direcciones_proc_min -gt $tamano_direcciones_proc_max ]]; then
        invertirRangos $tamano_direcciones_proc_min $tamano_direcciones_proc_max
        tamano_direcciones_proc_min=$min
        tamano_direcciones_proc_max=$max
    fi
    if [[ $tamano_direcciones_proc_min -lt 0 ]]; then 
        desplazarRangos $tamano_direcciones_proc_min $tamano_direcciones_proc_max
        tamano_direcciones_proc_min=$min
        tamano_direcciones_proc_max=$max
    fi 
	if [[ $seleccionAlgoritmoPaginacion -eq 0 ]]; then
#Se comparará este valor con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.
	fi
	
    if [[ $quantum_min -gt $quantum_max ]]; then
        invertirRangos $quantum_min $quantum_max
        quantum_min=$min
        quantum_max=$max
    fi
    if [[ $quantum_min -lt 0 ]]; then 
        desplazarRangos $quantum_min $quantum_max
        quantum_min=$min
        quantum_max=$max
    fi 
#Fin de leer_rangos_desde_fichero()

#
# Sinopsis: Compara variables con enteros
#
function es_entero {
# En caso de error, sentencia falsa
# Retorna si la sentencia anterior fue verdadera
#Fin de es_entero()

#
# Sinopsis: Permite ordenar los datos sacados desde fichero y de entrada por teclado. 
#
function ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve {
#llegada[@]} - 1)); j >= 0; j--)); do
        for ((i = 0; i <= $j; i++)); do
            if [[ ${llegada[$i]} -gt ${llegada[$(($i + 1))]} ]]; then
                aux=${proceso[$(($i + 1))]}
                proceso[$(($i + 1))]=${proceso[$i]} 
                proceso[$i]=$aux
                aux=${llegada[$(($i + 1))]}
                llegada[$(($i + 1))]=${llegada[$i]}
                llegada[$i]=$aux
#Se permutan las páginas
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${paginasDefinidasTotal[$(($i + 1)),$counter2]}
				done
#Se borran para que no pueda haber valores anteriores residuales.
					unset paginasDefinidasTotal[$(($i + 1)),$counter2]
				done
				for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
					paginasDefinidasTotal[$(($i + 1)),$counter2]=${paginasDefinidasTotal[$i,$counter2]}
				done
				for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
					unset paginasDefinidasTotal[$i,$counter2]
				done
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					paginasDefinidasTotal[$i,$counter2]=${aux2[$counter2]}
				done
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					unset aux2[$counter2]
				done
#Se permutan las direcciones
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${directions[$(($i + 1)),$counter2]}
				done
#Se borran para que no pueda haber valores anteriores residuales.
					unset directions[$(($i + 1)),$counter2]
				done
				for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
					directions[$(($i + 1)),$counter2]=${directions[$i,$counter2]}
				done
				for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
					unset directions[$i,$counter2]
				done
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					directions[$i,$counter2]=${aux2[$counter2]}
				done
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					unset aux2[$counter2]
				done
                aux=${ejecucion[$(($i + 1))]}
                ejecucion[$(($i + 1))]=${ejecucion[$i]} 
                ejecucion[$i]=$aux
                aux=${tiempoEjecucion[$(($i + 1))]}
#Se permutan los valores de esta variable auxiliar porque se definió en leer_datos_desde_fichero().
                tiempoEjecucion[$i]=$aux
                aux=${memoria[$(($i + 1))]}
                memoria[$(($i + 1))]=${memoria[$i]} 
                memoria[$i]=$aux
                aux=${prioProc[$(($i + 1))]}
#En caso de usar el algoritmo basado en Prioridades...
                prioProc[$i]=$aux
#No se permutan los nombres de los procesos, como en ordenarDatosEntradaFicheros(), porque se definirán más tarde.
            fi
        done
    done
#Fin de ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve()

#
# Sinopsis: Se ordenan por t.llegada únicamente los datos que se meten en la introducción de procesos
# (posteriormente se ordenará todo ya que se añaden el resto de arrays con todos los datos de cada proceso).
#
#En este caso se intercambian todos los datos al ordenar por tiempo de llegada.
#llegada[@]}; i++ )); do
#llegada[@]}; j++ )); do
            a=${llegada[$i]};
#Asignamos variables (tiempos de llegada)
            if [[ $a -gt $b ]];      then
                aux=${proceso[$i]};
#Ordenar los nombres
                proceso[$j]=$aux;
                aux=${llegada[$i]};        
#Ordenar por menor tiempo de llegada
                llegada[$j]=$aux
                aux=${ejecucion[$i]};
#Ordenar tiempos de ejecución 
                ejecucion[$j]=$aux;
                aux=${memoria[$i]};
#Ordenar los tamaños
                memoria[$j]=$aux;
                aux=${numeroproceso[$i]};
#Ordenar los números de proceso
                numeroproceso[$j]=$aux;
            fi
#Si el orden de entrada coincide se arreglan dependiendo de cuál se ha metido primero
                c=${numeroproceso[$i]};
                d=${numeroproceso[$j]};
                if [[ $c -gt $d ]]; then
                    aux=${proceso[$i]};
#Ordenar los nombres 
                    proceso[$j]=$aux
                    aux=${llegada[$i]};       
#Ordenar los tiempo de llegada
                    llegada[$j]=$aux
                    aux=${ejecucion[$i]};
#Ordenar tiempos de ejecución 
                    ejecucion[$j]=$aux;
                    aux=${memoria[$i]};
#Ordenar los tamaños
                    memoria[$j]=$aux;
                    aux=${numeroproceso[$i]};
#Ordenar los números de proceso
                    numeroproceso[$j]=$aux;
                fi
            fi
        done
    done
#Fin de ordenSJF()

#
#
# Establecimiento de funciones para rangos                
#
#
# Sinopsis: Presenta una tabla con los rangos y valores calculados 
#
function datos_memoria_tabla {
#    clear
    if [[ $seleccionMenuEleccionEntradaDatos -eq 4 ]]; then 
        echo -e "$amarillo Por favor establezca los rangos para datos"                  
    elif [[ $seleccionMenuEleccionEntradaDatos -eq 5 || $seleccionMenuEleccionEntradaDatos -eq 6 ]]; then 
        echo -e "$amarillo Resultados actuales:"                  
    fi
    echo -e "$azul┌────────────────────────────────────────────────────────────┐" | tee -a $informeConColorTotal
    printf  "$azul│$NC""${varhuecos:1:$((36))}""Min-Max rango     Valor""$azul │\n" | tee -a $informeConColorTotal
#MIN_RANGE_MARCOS}))}""$MIN_RANGE_MARCOS"" - " | tee -a $informeConColorTotal 
#mem_total}))}""$mem_total""$azul │\n" | tee -a $informeConColorTotal
#MIN_RANGE_DIRECCIONES}))}""$MIN_RANGE_DIRECCIONES"" - " | tee -a $informeConColorTotal
#mem_direcciones}))}""$mem_direcciones""$azul │\n" | tee -a $informeConColorTotal
#prio_menor_minInicial}))}""$prio_menor_minInicial"" - " | tee -a $informeConColorTotal
#prio_menorInicial}))}""$prio_menorInicial""$azul │\n" | tee -a $informeConColorTotal
#prio_menorInicial}))}""$prio_menorInicial""$azul │\n" | tee -a $informeConColorTotal
#prio_mayor_minInicial}))}""$prio_mayor_minInicial"" - " | tee -a $informeConColorTotal
#prio_mayorInicial}))}""$prio_mayorInicial""$azul │\n" | tee -a $informeConColorTotal
#prio_mayorInicial}))}""$prio_mayorInicial""$azul │\n" | tee -a $informeConColorTotal
#MIN_RANGE_REUB}))}""$MIN_RANGE_REUB"" - " | tee -a $informeConColorTotal
#reub}))}""$reub""$azul │\n" | tee -a $informeConColorTotal
#MIN_RANGE_NPROC}))}""$MIN_RANGE_NPROC"" - " | tee -a $informeConColorTotal
#n_prog}))}""$n_prog""$azul │\n" | tee -a $informeConColorTotal
#MIN_RANGE_llegada}))}""$MIN_RANGE_llegada"" - " | tee -a $informeConColorTotal
#MAX_RANGE_llegada}))}""$azul   │\n" | tee -a $informeConColorTotal
#MIN_RANGE_tiempo_ejec}))}""$MIN_RANGE_tiempo_ejec"" - " | tee -a $informeConColorTotal
#MAX_RANGE_tiempo_ejec}))}""$azul   │\n" | tee -a $informeConColorTotal
#MIN_RANGE_tamano_marcos_proc}))}""$MIN_RANGE_tamano_marcos_proc"" - " | tee -a $informeConColorTotal
#MAX_RANGE_tamano_marcos_proc}))}""$azul   │\n" | tee -a $informeConColorTotal
#MIN_RANGE_prio_proc}))}""$MIN_RANGE_prio_proc"" - " | tee -a $informeConColorTotal
#MAX_RANGE_prio_proc}))}""$azul   │\n" | tee -a $informeConColorTotal
#prio_menorInicial}))}""$prio_menorInicial"" - " | tee -a $informeConColorTotal
#prio_mayorInicial}))}""$azul   │\n" | tee -a $informeConColorTotal
#MIN_RANGE_quantum}))}""$MIN_RANGE_quantum"" - " | tee -a $informeConColorTotal
#MAX_RANGE_quantum}))}""$azul│\n" | tee -a $informeConColorTotal
#MIN_RANGE_tamano_direcciones_proc}))}""$MIN_RANGE_tamano_direcciones_proc"" - " | tee -a $informeConColorTotal
#MAX_RANGE_tamano_direcciones_proc}))}""$azul│\n" | tee -a $informeConColorTotal
    echo -e "$azul└────────────────────────────────────────────────────────────┘"  | tee -a $informeConColorTotal
    echo -e "┌────────────────────────────────────────────────────────────┐" >> $informeSinColorTotal
    printf  "│$NC""${varhuecos:1:$((36))}""Min-Max rango     Valor"" │\n" >> $informeSinColorTotal
#MIN_RANGE_MARCOS}))}""$MIN_RANGE_MARCOS"" - " >> $informeSinColorTotal
#mem_total}))}""$mem_total"" │\n" >> $informeSinColorTotal
#MIN_RANGE_DIRECCIONES}))}""$MIN_RANGE_DIRECCIONES"" - " >> $informeSinColorTotal
#mem_direcciones}))}""$mem_direcciones"" │\n" >> $informeSinColorTotal
#prio_menor_minInicial}))}""$prio_menor_minInicial"" - " >> $informeSinColorTotal
#prio_menorInicial}))}""$prio_menorInicial"" │\n" >> $informeSinColorTotal
#prio_menorInicial}))}""$prio_menorInicial"" │\n" >> $informeSinColorTotal
#prio_mayor_minInicial}))}""$prio_mayor_minInicial"" - " >> $informeSinColorTotal
#prio_mayorInicial}))}""$prio_mayorInicial"" │\n" >> $informeSinColorTotal
#prio_mayorInicial}))}""$prio_mayorInicial"" │\n" >> $informeSinColorTotal
#MIN_RANGE_REUB}))}""$MIN_RANGE_REUB"" - " >> $informeSinColorTotal
#reub}))}""$reub"" │\n" >> $informeSinColorTotal
#MIN_RANGE_NPROC}))}""$MIN_RANGE_NPROC"" - " >> $informeSinColorTotal
#n_prog}))}""$n_prog"" │\n" >> $informeSinColorTotal
#MIN_RANGE_llegada}))}""$MIN_RANGE_llegada"" - " >> $informeSinColorTotal
#MAX_RANGE_llegada}))}""   │\n" >> $informeSinColorTotal
#MIN_RANGE_tiempo_ejec}))}""$MIN_RANGE_tiempo_ejec"" - " >> $informeSinColorTotal
#MAX_RANGE_tiempo_ejec}))}""   │\n" >> $informeSinColorTotal
#MIN_RANGE_tamano_marcos_proc}))}""$MIN_RANGE_tamano_marcos_proc"" - " >> $informeSinColorTotal
#MAX_RANGE_tamano_marcos_proc}))}""   │\n" >> $informeSinColorTotal
#MIN_RANGE_prio_proc}))}""$MIN_RANGE_prio_proc"" - " >> $informeSinColorTotal
#MAX_RANGE_prio_proc}))}""   │\n" >> $informeSinColorTotal
#prio_menorInicial}))}""$prio_menorInicial"" - " >> $informeSinColorTotal
#prio_mayorInicial}))}""   │\n" >> $informeSinColorTotal
#MIN_RANGE_quantum}))}""$MIN_RANGE_quantum"" - " >> $informeSinColorTotal
#MAX_RANGE_quantum}))}""│\n" >> $informeSinColorTotal
#MIN_RANGE_tamano_direcciones_proc}))}""$MIN_RANGE_tamano_direcciones_proc"" - " >> $informeSinColorTotal
#MAX_RANGE_tamano_direcciones_proc}))}""│\n" >> $informeSinColorTotal
    echo -e "└────────────────────────────────────────────────────────────┘" >> $informeSinColorTotal
#Fin de datos_memoria_tabla()

#
# Sinopsis: Presenta una tabla con los datos de los rangos introducidos, y los subrangos y los valores calculables.
#
function datos_amplio_memoria_tabla {
#    clear
    if [[ $seleccionMenuEleccionEntradaDatos -eq 4 ]]; then 
        echo -e "$amarillo Por favor establezca los rangos para datos"                  
    elif [[ $seleccionMenuEleccionEntradaDatos -eq 5 || $seleccionMenuEleccionEntradaDatos -eq 6 ]]; then 
        echo -e "$amarillo Resultados actuales:"                  
    fi
    echo -e "$azul┌────────────────────────────────────────────────────────────────────────┐" | tee -a $informeConColorTotal
    printf  "$azul│$NC""${varhuecos:1:$((33))}""Min-Max_amplio   Min-Max_rango   Valor""$azul │\n" | tee -a $informeConColorTotal
#memoria_maxInicial}))}""  " | tee -a $informeConColorTotal
#mem_total}))}""$mem_total""$azul │\n" | tee -a $informeConColorTotal
#direcciones_maxInicial}))}""  " | tee -a $informeConColorTotal
#mem_direcciones}))}""$mem_direcciones""$azul │\n" | tee -a $informeConColorTotal
#prio_menor_maxInicial}))}""  " | tee -a $informeConColorTotal
#prio_menorInicial}))}""$prio_menorInicial""$azul │\n" | tee -a $informeConColorTotal
#prio_mayor_maxInicial}))}""  " | tee -a $informeConColorTotal
#prio_mayorInicial}))}""$prio_mayorInicial""$azul │\n" | tee -a $informeConColorTotal
#reubicacion_maxInicial}))}""  " | tee -a $informeConColorTotal
#reub}))}""$reub""$azul │\n" | tee -a $informeConColorTotal
#programas_maxInicial}))}""  " | tee -a $informeConColorTotal
#n_prog}))}""$n_prog""$azul │\n" | tee -a $informeConColorTotal
#llegada_maxInicial}))}""  " | tee -a $informeConColorTotal
#MAX_RANGE_llegada}))}""$azul │\n" | tee -a $informeConColorTotal
#tiempo_ejec_maxInicial}))}""  " | tee -a $informeConColorTotal
#MAX_RANGE_tiempo_ejec}))}""$azul │\n" | tee -a $informeConColorTotal
#tamano_marcos_proc_maxInicial}))}""  " | tee -a $informeConColorTotal
#MAX_RANGE_tamano_marcos_proc}))}""$azul │\n" | tee -a $informeConColorTotal
#prio_proc_max}))}""  " | tee -a $informeConColorTotal
#MAX_RANGE_prio_proc}))}""$azul │\n" | tee -a $informeConColorTotal
#prio_mayor}))}""  " | tee -a $informeConColorTotal
#prio_mayor}))}""$azul │\n" | tee -a $informeConColorTotal
#quantum_maxInicial}))}""  " | tee -a $informeConColorTotal
#MAX_RANGE_quantum}))}""$azul │\n" | tee -a $informeConColorTotal
#tamano_direcciones_proc_maxInicial}))}""  " | tee -a $informeConColorTotal
#MAX_RANGE_tamano_direcciones_proc}))}""$azul │\n" | tee -a $informeConColorTotal
    echo -e "$azul└────────────────────────────────────────────────────────────────────────┘" | tee -a $informeConColorTotal  
    
    echo -e "┌────────────────────────────────────────────────────────────────────────┐" >> $informeSinColorTotal
    printf "│$NC""${varhuecos:1:$((33))}""Min-Max_amplio Min-Max_rango Valor"" │\n" >> $informeSinColorTotal
#memoria_maxInicial}))}""  " >> $informeSinColorTotal
#mem_total}))}""$mem_total"" │\n" >> $informeSinColorTotal
#direcciones_maxInicial}))}""  " >> $informeSinColorTotal
#mem_direcciones}))}""$mem_direcciones"" │\n" >> $informeSinColorTotal
#prio_menor_maxInicial}))}""  " >> $informeSinColorTotal
#prio_menorInicial}))}""$prio_menorInicial"" │\n" >> $informeSinColorTotal
#prio_mayor_maxInicial}))}""  " >> $informeSinColorTotal
#prio_mayorInicial}))}""$prio_mayorInicial"" │\n" >> $informeSinColorTotal
#reubicacion_maxInicial}))}""  " >> $informeSinColorTotal
#reub}))}""$reub"" │\n" >> $informeSinColorTotal
#programas_maxInicial}))}""  " >> $informeSinColorTotal
#n_prog}))}""$n_prog"" │\n" >> $informeSinColorTotal
#llegada_maxInicial}))}""  " >> $informeSinColorTotal
#MAX_RANGE_llegada}))}"" │\n" >> $informeSinColorTotal
#tiempo_ejec_maxInicial}))}""  " >> $informeSinColorTotal
#MAX_RANGE_tiempo_ejec}))}"" │\n" >> $informeSinColorTotal
#tamano_marcos_proc_maxInicial}))}""  " >> $informeSinColorTotal
#MAX_RANGE_tamano_marcos_proc}))}"" │\n" >> $informeSinColorTotal
#prio_mayor}))}""  " >> $informeSinColorTotal
#prio_mayor}))}"" │\n" >> $informeSinColorTotal
#quantum_maxInicial}))}""  " >> $informeSinColorTotal
#MAX_RANGE_quantum}))}"" │\n" >> $informeSinColorTotal
#tamano_direcciones_proc_maxInicial}))}""  " >> $informeSinColorTotal
#MAX_RANGE_tamano_direcciones_proc}))}"" │\n" >> $informeSinColorTotal
    echo -e "└────────────────────────────────────────────────────────────────────────┘" >> $informeSinColorTotal 
#Fin de datos_amplio_memoria_tabla()

#---------Funciones para el pedir por pantalla los mínimos y máximos de los rangos - Opción 4--------------                
#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango de la memoria total 
#
function datos_numero_marcos_memoria {
	datos_memoria_tabla 
    until [[ $MAX_RANGE_MARCOS -ge $MIN_RANGE_MARCOS && $MIN_RANGE_MARCOS -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de marcos de memoria$cian:$NC" 
#Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de marcos de memoria$cian:$NC"
#Rango maximo para la memoria
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS
            MIN_RANGE_MARCOS=$min
            MAX_RANGE_MARCOS=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS
            MIN_RANGE_MARCOS=$min
            MAX_RANGE_MARCOS=$max
        fi  
    done
#Fin de datos_numero_marcos_memoria()               

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango de la memoria total 
#
function datos_numero_marcos_memoria_amplio {
	datos_amplio_memoria_tabla
    until [[ $memoria_maxInicial -ge $memoria_minInicial && $memoria_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de marcos de memoria$cian:$NC" 
#Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de marcos de memoria$cian:$NC"
#Rango maximo para la memoria
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $memoria_minInicial $memoria_maxInicial
            memoria_minInicial=$min
            memoria_maxInicial=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $memoria_minInicial $memoria_maxInicial
            memoria_minInicial=$min
            memoria_maxInicial=$max
        fi  
    done
#Se definen nuevas variables para redefinir los límites de los subrangos sacados de los rangos amplios. 
	memoria_max=$memoria_maxInicial
#Fin de datos_numero_marcos_memoria_amplio()               

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del número de procesos 
#
function datos_numero_direcciones_marco {
	datos_memoria_tabla 
    until [[ $MAX_RANGE_DIRECCIONES -ge $MIN_RANGE_DIRECCIONES && $MIN_RANGE_DIRECCIONES -gt 0 ]]; do                 
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de direcciones por marco$cian:$NC" 
#Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de direcciones por marco$cian:$NC"
#Rango maximo para la memoria
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
            MIN_RANGE_DIRECCIONES=$min
            MAX_RANGE_DIRECCIONES=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
            MIN_RANGE_DIRECCIONES=$min
            MAX_RANGE_DIRECCIONES=$max
        fi  
    done                    
#Fin de datos_numero_direcciones_marco() 

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del número de procesos 
#
function datos_numero_direcciones_marco_amplio {
	datos_amplio_memoria_tabla
    until [[ $direcciones_maxInicial -ge $direcciones_minInicial && $direcciones_minInicial -gt 0 ]]; do                 
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de direcciones por marco$cian:$NC" 
#Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de direcciones por marco$cian:$NC"
#Rango maximo para la memoria
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $direcciones_minInicial $direcciones_maxInicial
            direcciones_minInicial=$min
            direcciones_maxInicial=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $direcciones_minInicial $direcciones_maxInicial
            direcciones_minInicial=$min
            direcciones_maxInicial=$max
        fi  
    done                    
	direcciones_min=$direcciones_minInicial
	direcciones_max=$direcciones_maxInicial
#Fin de datos_numero_direcciones_marco_amplio() 
                        
#
# Sinopsis: Se piden por pantalla el mínimo y máximo para el mínimo del rango de la prioridad
#
function datos_prio_menor {
	datos_memoria_tabla 
	echo -e "$cian Por favor, establezca el mínimo del rango para la prioridad menor$cian:$NC" 
#Rango minimo para la variable prioridad
	echo -e "$cian Por favor, establezca el máximo del rango para la prioridad menor$cian:$NC"
#Rango maximo para la variable prioridad
	prio_menor_min=$prio_menor_minInicial
	prio_menor_max=$prio_menor_maxInicial
#Fin de datos_prio_menor()                               
                        
#
# Sinopsis: Se piden por pantalla el mínimo y máximo para el mínimo del rango de la prioridad
#
function datos_prio_menor_amplio {
	datos_amplio_memoria_tabla
	echo -e "$cian Por favor, establezca el mínimo del rango para la prioridad menor$cian:$NC" 
#Rango minimo para la variable prioridad
	echo -e "$cian Por favor, establezca el máximo del rango para la prioridad menor$cian:$NC"
#Rango maximo para la variable prioridad
	prio_menor_min=$prio_menor_minInicial
	prio_menor_max=$prio_menor_maxInicial
#Fin de datos_prio_menor_amplio()                               
                        
#
# Sinopsis: Se piden por pantalla el mínimo y máximo para el máximo del rango de la prioridad
#
function datos_prio_mayor {
	datos_memoria_tabla 
	echo -e "$cian Por favor, establezca el mínimo del rango para la prioridad mayor$cian:$NC" 
#Rango minimo para la variable prioridad
	echo -e "$cian Por favor, establezca el máximo del rango para la prioridad mayor$cian:$NC"
#Rango maximo para la variable prioridad
	prio_mayor_min=$prio_mayor_minInicial
	prio_mayor_max=$prio_mayor_maxInicial
#Fin de datos_prio_mayor()                               
                        
#
# Sinopsis: Se piden por pantalla el mínimo y máximo para el máximo del rango de la prioridad
#
function datos_prio_mayor_amplio {
	datos_amplio_memoria_tabla
	echo -e "$cian Por favor, establezca el mínimo del rango para la prioridad mayor$cian:$NC" 
#Rango minimo para la variable prioridad
	echo -e "$cian Por favor, establezca el máximo del rango para la prioridad mayor$cian:$NC"
#Rango maximo para la variable prioridad
	prio_mayor_min=$prio_mayor_minInicial
	prio_mayor_max=$prio_mayor_maxInicial
#Fin de datos_prio_mayor_amplio()                               

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del número de procesos 
#
function datos_numero_programas {
	datos_memoria_tabla 
    until [[ $MAX_RANGE_NPROC -ge $MIN_RANGE_NPROC && $MIN_RANGE_NPROC -gt 0 ]]; do                 
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de procesos$cian:$NC" 
#Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de procesos$cian:$NC"
#Rango maximo para la memoria
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_NPROC $MAX_RANGE_NPROC
            MIN_RANGE_NPROC=$min
            MAX_RANGE_NPROC=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_NPROC $MAX_RANGE_NPROC
            MIN_RANGE_NPROC=$min
            MAX_RANGE_NPROC=$max
        fi  
    done                    
#Fin de datos_numero_programas() 

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del número de procesos 
#
function datos_numero_programas_amplio {
	datos_amplio_memoria_tabla
    until [[ $programas_maxInicial -ge $programas_minInicial && $programas_minInicial -gt 0 ]]; do                 
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de procesos$cian:$NC" 
#Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de procesos$cian:$NC"
#Rango maximo para la memoria
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $programas_minInicial $programas_maxInicial
            programas_minInicial=$min
            programas_maxInicial=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $programas_minInicial $programas_maxInicial
            programas_minInicial=$min
            programas_maxInicial=$max
        fi  
    done                    
		programas_min=$programas_minInicial
		programas_max=$programas_maxInicial
#Fin de datos_numero_programas_amplio() 

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del máximo de unidades de memoria admisible para la reubicabilidad
#
function datos_tamano_reubicacion { 
	datos_memoria_tabla 
#Si el mayor es menor que el menor, se invierten los rangos
        echo -e "$cian Por favor, establezca el mínimo del rango para la variable de reubicacion$cian:$NC" 
#Rango minimo para la variable reubicacion
        echo -e "$cian Por favor, establezca el máximo del rango para la variable de reubicacion$cian:$NC" 
#Rango maximo para la variable reubicacion
#Si límite mínimo mayor que límite máximo
            invertirRangos $MIN_RANGE_REUB $MAX_RANGE_REUB
            MIN_RANGE_REUB=$min
            MAX_RANGE_REUB=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_REUB $MAX_RANGE_REUB
            MIN_RANGE_REUB=$min
            MAX_RANGE_REUB=$max
        fi  
    done                        
#Fin de datos_tamano_reubicacion()

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del máximo de unidades de memoria admisible para la reubicabilidad
#
function datos_tamano_reubicacion_amplio { 
	datos_amplio_memoria_tabla
#Si el mayor es menor que el menor, se invierten los rangos
        echo -e "$cian Por favor, establezca el mínimo del rango para la variable de reubicacion$cian:$NC" 
#Rango minimo para la variable reubicacion
        echo -e "$cian Por favor, establezca el máximo del rango para la variable de reubicacion$cian:$NC" 
#Rango maximo para la variable reubicacion
#Si límite mínimo mayor que límite máximo
            invertirRangos $reubicacion_minInicial $reubicacion_maxInicial
            reubicacion_minInicial=$min
            reubicacion_maxInicial=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $reubicacion_minInicial $reubicacion_maxInicial
            reubicacion_minInicial=$min
            reubicacion_maxInicial=$max
        fi  
		reubicacion_min=$reubicacion_minInicial
		reubicacion_max=$reubicacion_maxInicial
    done                        
#Fin de datos_tamano_reubicacion_amplio()
                
#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tiempo de llegada de los procesos
#
function datos_tiempo_llegada {
	datos_memoria_tabla 
    MIN_RANGE_llegada=-1 
    until [[ $MAX_RANGE_llegada -ge $MIN_RANGE_llegada && $(($MIN_RANGE_llegada + 1)) -gt 0 ]]; do  
        echo -e "$cian Por favor, establezca el mínimo del rango para el tiempo de llegada$cian:$NC" 
#Rango minimo para la variable tiempo de llegada
        echo -e "$cian Por favor, establezca el máximo del rango para el tiempo de llegada$cian:$NC" 
#Rango maximo para la variable tiempo de llegada
        if [[ $MIN_RANGE_llegada -gt $MAX_RANGE_llegada ]]; then
            invertirRangos $MIN_RANGE_llegada $MAX_RANGE_llegada
            MIN_RANGE_llegada=$min
            MAX_RANGE_llegada=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_llegada $MAX_RANGE_llegada
#Este valor es el único que puede ser 0
            MAX_RANGE_llegada=$(($max - 1))
        fi  
    done
#Fin de datos_tiempo_llegada()                       
                
#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tiempo de llegada de los procesos
#
function datos_tiempo_llegada_amplio {
	datos_amplio_memoria_tabla
    llegada_minInicial=-1 
    until [[ $llegada_maxInicial -ge $llegada_minInicial && $(($llegada_minInicial + 1)) -gt 0 ]]; do  
        echo -e "$cian Por favor, establezca el mínimo del rango para el tiempo de llegada$cian:$NC" 
#Rango minimo para la variable tiempo de llegada
        echo -e "$cian Por favor, establezca el máximo del rango para el tiempo de llegada$cian:$NC" 
#Rango maximo para la variable tiempo de llegada
        if [[ $llegada_minInicial -gt $llegada_maxInicial ]]; then
            invertirRangos $llegada_minInicial $llegada_maxInicial
            llegada_minInicial=$min
            llegada_maxInicial=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $llegada_minInicial $llegada_maxInicial
#Este valor es el único que puede ser 0
            llegada_maxInicial=$(($max - 1))
        fi  
		llegada_min=$llegada_minInicial
		llegada_max=$llegada_maxInicial
    done
#Fin de datos_tiempo_llegada_amplio()                       
                        
#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tiempo de ejecución de los procesos
#
function datos_tiempo_ejecucion {
	datos_memoria_tabla 
    until [[ $MAX_RANGE_tiempo_ejec -ge $MIN_RANGE_tiempo_ejec && $MIN_RANGE_tiempo_ejec -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el tiempo de ejecución$cian:$NC" 
#Rango minimo para la variable tiempo de ejecución
        echo -e "$cian Por favor, establezca el máximo del rango para el tiempo de ejecución$cian:$NC"
#Rango maximo para la variable tiempo de ejecución
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_tiempo_ejec $MAX_RANGE_tiempo_ejec
            MIN_RANGE_tiempo_ejec=$min
            MAX_RANGE_tiempo_ejec=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_tiempo_ejec $MAX_RANGE_tiempo_ejec
            MIN_RANGE_tiempo_ejec=$min
            MAX_RANGE_tiempo_ejec=$max
        fi  
    done
#Fin de datos_tiempo_ejecucion()                               
                        
#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tiempo de ejecución de los procesos
#
function datos_tiempo_ejecucion_amplio {
	datos_amplio_memoria_tabla
    until [[ $tiempo_ejec_maxInicial -ge $tiempo_ejec_minInicial && $tiempo_ejec_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el tiempo de ejecución$cian:$NC" 
#Rango minimo para la variable tiempo de ejecución
        echo -e "$cian Por favor, establezca el máximo del rango para el tiempo de ejecución$cian:$NC"
#Rango maximo para la variable tiempo de ejecución
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $tiempo_ejec_minInicial $tiempo_ejec_maxInicial
            tiempo_ejec_minInicial=$min
            tiempo_ejec_maxInicial=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $tiempo_ejec_minInicial $tiempo_ejec_maxInicial
            tiempo_ejec_minInicial=$min
            tiempo_ejec_maxInicial=$max
        fi  
		tiempo_ejec_min=$tiempo_ejec_minInicial
		tiempo_ejec_max=$tiempo_ejec_maxInicial
    done
#Fin de datos_tiempo_ejecucion_amplio()                               
                        
#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango de la prioridad de los procesos
#
function datos_prio_proc {
	datos_memoria_tabla 
#Fin de datos_prio_proc()                               
                        
#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango de la prioridad de los procesos
#
function datos_prio_proc_amplio {
	datos_amplio_memoria_tabla
#Fin de datos_prio_proc_amplio()                               

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tamaño en memoria de los procesos
#
function datos_tamano_marcos_procesos {                
	datos_memoria_tabla 
    until [[ $MAX_RANGE_tamano_marcos_proc -ge $MIN_RANGE_tamano_marcos_proc && $MIN_RANGE_tamano_marcos_proc -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de marcos asociados a cada proceso$cian:$NC" 
#Rango minimo para la variable tamaño del proceso en marcos
        echo -e "$cian Por favor, establezca el máximo del rango para el número de marcos asociados a cada proceso:$NC" 
#Rango maximo para la variable tamaño del proceso en marcos
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_tamano_marcos_proc $MAX_RANGE_tamano_marcos_proc
            MIN_RANGE_tamano_marcos_proc=$min
            MAX_RANGE_tamano_marcos_proc=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_tamano_marcos_proc $MAX_RANGE_tamano_marcos_proc
            MIN_RANGE_tamano_marcos_proc=$min
            MAX_RANGE_tamano_marcos_proc=$max
        fi  
    done
#Fin de datos_tamano_marcos_procesos()

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tamaño en memoria de los procesos
#
function datos_tamano_marcos_procesos_amplio {                
	datos_amplio_memoria_tabla
    until [[ $tamano_marcos_proc_maxInicial -ge $tamano_marcos_proc_minInicial && $tamano_marcos_proc_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de marcos asociados a cada proceso$cian:$NC" 
#Rango minimo para la variable tamaño del proceso en marcos
        echo -e "$cian Por favor, establezca el máximo del rango para el número de marcos asociados a cada proceso:$NC" 
#Rango maximo para la variable tamaño del proceso en marcos
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $tamano_marcos_proc_minInicial $tamano_marcos_proc_maxInicial
            tamano_marcos_proc_minInicial=$min
            tamano_marcos_proc_maxInicial=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $tamano_marcos_proc_minInicial $tamano_marcos_proc_maxInicial
            tamano_marcos_proc_minInicial=$min
            tamano_marcos_proc_maxInicial=$max
        fi  
		tamano_marcos_proc_min=$tamano_marcos_proc_minInicial
		tamano_marcos_proc_max=$tamano_marcos_proc_maxInicial
    done
#Fin de datos_tamano_marcos_procesos_amplio()

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tamaño en memoria de los procesos
#
function datos_tamano_direcciones_procesos {                
	datos_memoria_tabla 
    until [[ $MAX_RANGE_tamano_direcciones_proc -ge $MIN_RANGE_tamano_direcciones_proc && $MIN_RANGE_tamano_direcciones_proc -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el tamaño del proceso en direcciones$cian:$NC" 
#Rango minimo para la variable tamaño del proceso en direcciones
        echo -e "$cian Por favor, establezca el máximo del rango para el tamaño del proceso en direcciones$cian:$NC" 
#Rango maximo para la variable tamaño del proceso en direcciones
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_tamano_direcciones_proc $MAX_RANGE_tamano_direcciones_proc
            MIN_RANGE_tamano_direcciones_proc=$min
            MAX_RANGE_tamano_direcciones_proc=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_tamano_direcciones_proc $MAX_RANGE_tamano_direcciones_proc
            MIN_RANGE_tamano_direcciones_proc=$min
            MAX_RANGE_tamano_direcciones_proc=$max
        fi  
    done
#Fin de datos_tamano_direcciones_procesos()

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tamaño en memoria de los procesos
#
function datos_tamano_direcciones_procesos_amplio {                
	datos_amplio_memoria_tabla
    until [[ $tamano_direcciones_proc_maxInicial -ge $tamano_direcciones_proc_minInicial && $tamano_direcciones_proc_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el tamaño del proceso en direcciones$cian:$NC" 
#Rango minimo para la variable tamaño del proceso en direcciones
        echo -e "$cian Por favor, establezca el máximo del rango para el tamaño del proceso en direcciones$cian:$NC" 
#Rango maximo para la variable tamaño del proceso en direcciones
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $tamano_direcciones_proc_minInicial $tamano_direcciones_proc_maxInicial
            tamano_direcciones_proc_minInicial=$min
            tamano_direcciones_proc_maxInicial=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $tamano_direcciones_proc_minInicial $tamano_direcciones_proc_maxInicial
            tamano_direcciones_proc_minInicial=$min
            tamano_direcciones_proc_maxInicial=$max
        fi  
		tamano_direcciones_proc_min=$tamano_direcciones_proc_minInicial
		tamano_direcciones_proc_max=$tamano_direcciones_proc_maxInicial
    done
#Fin de datos_tamano_direcciones_procesos_amplio()

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tamaño en memoria de los procesos
#
function datos_quantum {                
	datos_memoria_tabla 
    until [[ $MAX_RANGE_quantum -ge $MIN_RANGE_quantum && $MIN_RANGE_quantum -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el quantum$cian:$NC" 
#Rango minimo para la variable tamaño del proceso en direcciones
        echo -e "$cian Por favor, establezca el máximo del rango para el quantum$cian:$NC" 
#Rango maximo para la variable tamaño del proceso en direcciones
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_quantum $MAX_RANGE_quantum
            MIN_RANGE_quantum=$min
            MAX_RANGE_quantum=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_quantum $MAX_RANGE_quantum
            MIN_RANGE_quantum=$min
            MAX_RANGE_quantum=$max 
        fi  
    done
#Fin de datos_quantum()

#
# Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tamaño en memoria de los procesos
#
function datos_quantum_amplio {                
	datos_amplio_memoria_tabla
    until [[ $quantum_maxInicial -ge $quantum_minInicial && $quantum_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el quantum:$NC" 
#Rango minimo para la variable tamaño del proceso en direcciones
        echo -e "$cian Por favor, establezca el máximo del rango para el quantum$cian:$NC" 
#Rango maximo para la variable tamaño del proceso en direcciones
#Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $quantum_minInicial $quantum_maxInicial
            quantum_minInicial=$min
            quantum_maxInicial=$max
        fi
#Si ambos son negativos se desplazan a positivos 
            desplazarRangos $quantum_minInicial $quantum_maxInicial
            quantum_minInicial=$min
            quantum_maxInicial=$max
        fi  
		quantum_min=$quantum_minInicial
		quantum_max=$quantum_maxInicial
    done
#Fin de datos_quantum_amplio()

#---------Funciones para el cálculo de los datos desde los rangos--------------                
#
# Sinopsis: Dato calculado de forma aleatoria desde su subrango. Puede usarse para calcular el Mínimo y Máximo del subrango, calculado desde el rango amplio.
#
function calcDatoAleatorioGeneral {
#Variable devuelta: mem=$((RANDOM % ($max - $min + 1) + $min))
#min=$MIN_RANGE_MARCOS
#max=$MAX_RANGE_MARCOS
# Generar un número aleatorio dentro del rango
#Fin de calcDatoAleatorioGeneral()

#
#Si los mínimos son mayores que los invierten los rangos. 
#
function invertirRangos {
    aux=$1
    min=$2
    max=$aux
#Fin de invertirRangos()

#
#Si mínimo y máximo son negativos se desplaza el mínimo hasta ser 0. 
#
function desplazarRangos {
#La condición es estrictamente mayor para que si sólo hay una unidad de diferencia se quedan iguales.
#Todos los valores mínimos tienen que ser 1 como mínimo, salvo el tiempo de llegada que podría ser 0
#Fin de desplazarRangos()

#
# Sinopsis: Define el color de cada dígito de cada unidad a representar - Color por defecto
#
function colorDefaultInicio {
    for (( j=0; j<5; j++)); do
        coloresPartesTiempo=("${coloresPartesTiempo[@]}" "${coloress[97]}")
    done
#Fin de colorDefaultInicio()

#
# Sinopsis: Define el color de cada dígito de cada unidad a representar - Color del proceso anterior
#
function colorAnterior {
    for (( j=0; j<$digitosUnidad; j++)); do
        coloresPartesTiempo=("${coloresPartesTiempo[@]}" "${coloress[$proanterior]}")
    done
#Fin de datos_numero_marcos_memoria_amplio()

#
# Sinopsis: Establece los colores de cada proceso
#
function  Establecimiento_colores_proces {
    col=1
    aux=0
    for (( i=0,j=0; i<$nprocesos; i++,j++)); do
#coloress[@]} - 2 ]
        indice[$i]=$j
        while [[ ${indice[$i]} -ge $auxiliar ]]; do
            indice[$i]=$[ ${indice[$i]} - $auxiliar ]
        done
        colores[$i]=${coloress[${indice[$i]}]}
        colorfondo[$i]=${colorfondos[${indice[$i]}]}
#Para que se reinicien los colores
            j=$((j-16))
#Cierre para que se reinicien los colores
    done
#Fin de Establecimiento_colores_proces()

#
# Sinopsis: Define el color de cada dígito de cada unidad a representar - Color de otras unidades del proceso actual
#
function colorunidMemOcupadas { 
    for (( j=0; j<$digitosUnidad; j++)); do
        coloresPartesMemoria=("${coloresPartesMemoria[@]}" "${coloress[${unidMemOcupadas[$ra]}]}")
    done
#Fin de colorunidMemOcupadas()

#
# Sinopsis: Define el color de cada dígito de cada unidad de la memoria y tiempo a representar - Color por defecto
#
function colorDefaultBMBT { 
    for (( j=0; j<$digitosUnidad; j++)); do
        coloresPartesMemoria=("${coloresPartesMemoria[@]}" "${coloress[97]}")
    done
#Fin de colorDefaultBMBT()

#
# Sinopsis: Dada una unidad de 3 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#3 - ancho de columnas estrechas en tabla resumen de procesos en los volcados 
#No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC"
#Fin de imprimirEspaciosEstrechos()

#3 - ancho de columnas estrechas en tabla resumen de procesos en los volcados 
#No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal"
#Fin de imprimirEspaciosEstrechosBN()

#
# Sinopsis: Dada una unidad de 4 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#4 - ancho de columnas anchas en tabla resumen de procesos en los volcados
#No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC" 
#Fin de imprimirEspaciosAnchos()

#4 - ancho de columnas anchas en tabla resumen de procesos en los volcados
#No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal" 
#Fin de imprimirEspaciosAnchosBN()

#
# Sinopsis: Dada una unidad de 5 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#5 - ancho de columnas más anchas en tabla resumen de procesos en los volcados
#No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC"
#Fin de imprimirEspaciosMasAnchos()

#5 - ancho de columnas más anchas en tabla resumen de procesos en los volcados
#No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal"
#Fin de imprimirEspaciosMasAnchosBN()

#
# Sinopsis: Dada una unidad de 17 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#17 - ancho de columnas muy anchas en tabla resumen de procesos en los volcados 
#No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC"
#Fin de imprimirEspaciosMuyAnchos()

#17 - ancho de columnas muy anchas en tabla resumen de procesos en los volcados 
#No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal"
#Fin de imprimirEspaciosMuyAnchosBN()

#
# Sinopsis: Dada una unidad de 9 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#9 - ancho de columnas anchas en tabla de rangos 
#No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC"
#Fin de imprimirEspaciosRangosLargos()

#9 - ancho de columnas anchas en tabla de rangos 
#No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal"
#Fin de imprimirEspaciosRangosLargos()

#
# Sinopsis: Se eliminan los archivos de última ejecución que había anteriormente creados y 
# nos direcciona a la entrada de particiones y procesos
#
function nuevaEjecucion {
#    clear
    if [[ -f $ficheroDatosAnteriorEjecucion ]]; then
        rm $ficheroDatosAnteriorEjecucion   
    fi
    if [[ -f $ficherosRangosAnteriorEjecucion && ($seleccionMenuEleccionEntradaDatos -eq 4 || $seleccionMenuEleccionEntradaDatos -eq 6 || $seleccionMenuEleccionEntradaDatos -eq 7 || $seleccionMenuEleccionEntradaDatos -eq 8 || $seleccionMenuEleccionEntradaDatos -eq 9) ]]; then
        rm $ficherosRangosAnteriorEjecucion     
    fi
    if [[ -f $ficheroRangosAleTotalAnteriorEjecucion && ($seleccionMenuEleccionEntradaDatos -eq 7 || $seleccionMenuEleccionEntradaDatos -eq 9) ]]; then
        rm $ficheroRangosAleTotalAnteriorEjecucion     
    fi
#Fin de nuevaEjecucion()

#
# Sinopsis: Se calcula el tamaño máximo de la unidad para contener todos los datos que se generen sin modificar el ancho de la columna necesaria
#
function calcularUnidad {
    sumatorio=0
    sumatorio1=0
    sumatorio2=0
    for (( i=0; i<$nprocesos; i++ )); do
        sumatorio1=$(( sumatorio1 + ${llegada[$i]} + ${tejecucion[$i]} ))
    done
    for (( i=0; i<$nprocesos; i++ )); do
		for (( ii=0; ii<${tejecucion[$i]}; ii++ )); do
			if [[ $sumatorio2 -lt ${paginasDefinidasTotal[$i,$ii]} ]]; then
				sumatorio2=${paginasDefinidasTotal[$i,$ii]}
			fi
		done
    done
	if [[ $sumatorio2 -lt $sumatorio1 ]]; then
		sumatorio=$sumatorio1
	else
		sumatorio=$sumatorio2
	fi
    espacios=$(echo -n "$sumatorio" | wc -c)
    if [[ $espacios -le 2 ]]; then
        digitosUnidad=3
    else
        digitosUnidad=$espacios
        digitosUnidad=$(( $digitosUnidad + 1 ))
    fi
#Fin de calcularUnidad()

#
# Sinopsis: Permite introducir las particiones y datos desde otro fichero (predefinido).
#
function entradaMemoriaDatosFichero {
#    clear
    echo -e $ROJO"\nFicheros de datos a elegir en './FDatos/': "$NORMAL | tee -a $informeConColorTotal
    echo -e "\nFicheros de datos a elegir en './FDatos/': " >> $informeSinColorTotal
    files=($(ls -l ./FDatos/ | awk '{print $9}'))
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
        echo -e "$i) ${files[$i]}"
    done
    echo -ne "$AMARILLO\n\n\nIntroduce el número correspondiente al fichero a analizar: $NORMAL" | tee -a $informeConColorTotal
    echo -ne "\n\n\nIntroduce el número correspondiente al fichero a analizar: " >> $informeSinColorTotal
    read -r numeroFichero
#files[@]} ]]; do
        echo -ne "Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read -r numeroFichero
        echo -e "$numeroFichero\n\n" >> $informeConColorTotal
        echo -e "$numeroFichero\n\n" >> $informeSinColorTotal
    done
    ficheroParaLectura="./FDatos/${files[$numeroFichero]}"
#Fin de entradaMemoriaDatosFichero()

#
# Sinopsis: Permite introducir las particiones y datos desde otro fichero (predefinido).
#
function entradaMemoriaRangosFichero {
#    clear
    echo -e $ROJO"\nFicheros de datos a elegir en './FDatos/': "$NORMAL | tee -a $informeConColorTotal
    echo -e "\nFicheros de datos a elegir en './FDatos/': " >> $informeSinColorTotal
    files=($(ls -l ./FDatos/ | awk '{print $9}'))
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
        echo -e "$i) ${files[$i]}"
    done
    echo -ne "$AMARILLO\n\n\nIntroduce el número correspondiente al fichero a analizar: $NORMAL" | tee -a $informeConColorTotal
    echo -ne "\n\n\nIntroduce el número correspondiente al fichero a analizar: " >> $informeSinColorTotal
    read -r numeroFichero
#files[@]} ]]; do
        echo -ne "Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read -r numeroFichero
        echo -e "$numeroFichero\n\n" >> $informeConColorTotal
        echo -e "$numeroFichero\n\n" >> $informeSinColorTotal
    done
    ficheroParaLectura="./FDatos/${files[$numeroFichero]}"
#Fin de datos_numero_marcos_memoria_amplio()

#
# Sinopsis: Se inicilizan diferentes tablas y variables
#
function inicializaVectoresVariables { 
# -----------------------------------------------------------------------------
# Se inicilizan las tablas indicadoras de la MEMORIA NO CONTINUA
#Se crea el array para determinar qué unidades de memoria están ocupadas y se inicializan con _
    for (( ca=0; ca<(mem_total); ca++)); do
        unidMemOcupadas[$ca]="_"
#Se crea un array auxiliar para realizar la reubicación
    done
#Se crea variables para determinar si hay que reubicar (en un primer momento no)
#En caso de ser memoria no continua, si hay un hueco demasiado pequeño, y se va a usar como parte de la memoria a usar.
    reubicarReubicabilidad=0 
#En caso de ser memoria continua, si no hay un hueco suficientemente grande en el que quepa pero sí en la suma de todos ellos.
    reubicarContinuidad=0 
# -----------------------------------------------------------------------------
# Se inicilizan las tablas indicadoras de la situación del proceso
#Copia algunas listas para luego ponerlas en orden
        entradaAuxiliar[$i]=${llegada[$i]} 
        temp_rej[$i]="-"
#Para ser equivalente al nuevo programa
        memoriaAuxiliar[$i]=${memoria[$i]}
        encola[$i]=0
        enmemoria[$i]=0
        enejecucion[$i]=0
        bloqueados[$i]=0
        enpausa[$i]=0 
#Determina qué procesos han terminado (1).
#Determina qué procesos han terminado cuyo resumen de fallos de página ha sido imprimido (1).
        nollegado[$i]=0
        estad[$i]=0 
        estado[$i]=0
        temp_wait[$i]="-"
        temp_resp[$i]="-"
        temp_ret[$i]="-"
        pos_inicio[$i]="-"
        pos_final[$i]="-"
#Guarda si un proceso está escrito o no EN EL ARRAY.
#Almacena el valor de en cuantos bloques se fragmenta un proceso
#Controla qué procesos están presentes en la banda de tiempo. Se van poniendo a 1 a medida que se van metiendo en las variables de las líneas de la banda de tiempos.
#Número de Marcos ya usadas de cada Proceso.
#Número de Páginas ya usadas de cada Proceso.
#Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
#Número de Páginas ya dibujadas de cada Proceso para el resumen de Banda.		
#Fallos de página totales de cada proceso.
#Mayor "frecuencia/uso de página".
		max_AlgPagFrecRec_Position[$i]=0
#Menor "frecuencia/uso de página".
		min_AlgPagFrecRec_Position[$i]=0
		indiceResuPaginaProceso[$i]="_"
		indiceResuPaginaAcumulado[$i]="_"
#Número de Fallos de Página de cada Proceso.
#Número de expulsiones forzadas en Round-Robin (RR) 
#Controlan el ordinal del tiempo de ejecución que hace que se cambió un valor de las clases y la frecuencia de uso de cada página en cada ordinal de tiempo de ejecución.
			primerTiempoEntradaPagina[$i,$indMarco]=0 
			restaFrecUsoRec[$i,$indMarco,0]=0
			directions_AlgPagFrecUsoRec_marco_pagina_clase[$i,$indMarco,0]=0
			directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$i,$indMarco]=0
		done
#Contiene el orden de ejecución de Round-Robin (RR). Será "-" mientras no esté en cola, o cuando haya terminado, y si aún no ha terminado contendrá el número ordinal del siguiente quantum. El proceso a ejecutar será, por tanto, el que tenga el número ordinal más bajo. Y el número de quantums realizados (cambios de contexto, será el número ordinal más alto.
	done
	ResuFrecuenciaAcumulado=();
	ResuTiempoOptimoAcumulado=();
	ResuUsoRecienteAcumulado=();
	max_AlgPagRec_rec=();
	max_AlgPagRec_rec=();
	min_AlgPagRec_position=();
	min_AlgPagRec_position=();
	max_AlgFrecuencia_frec=();
	max_AlgFrecuencia_frec=();
	min_AlgFrecuencia_position=();
	min_AlgFrecuencia_position=();
#Establece el color de cada proceso
    blanco="\e[37m"
#Para ser equivalente al nuevo programa
#Para ser equivalente al nuevo programa
# Se calcula el valor máximo del número de unidades de tiempo. Como mucho, los tiempos de llegada más los tiempos de ejecución. Ese será el número de elementos máximo del array procPorUnidadTiempoBT 
#proceso[@]}; j++)); do
        maxProcPorUnidadTiempoBT=$(expr $maxProcPorUnidadTiempoBT + ${llegada[$j]} + ${ejecucion[$j]})  
    done  
# Se pone un valor que nunca se probará (tope dinámico). Osea, el mismo que maxProcPorUnidadTiempoBT.
#Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
	ejecutandoinst=-1
#Determina el mayor número que podría ser representado por Tllegada y Tejecucion
#Timpo ejecutado de un proceso que se comparará con el quantum para ser sacado de CPU.
#Índice con el primer ordinal libre a repartir en Round-Robin (RR). Irá creciendo con cada puesto de quantum repartido y marca el futuro orden de ejecución. 
#Índice con el actual ordinal en ejecución para Round-Robin (RR). Irá creciendo con cada quantum ejecutado y marca el actual número ordinal de uantum en ejecución. 
#    clear
#Fin de inicializaVectoresVariables()

#
# Sinopsis: Se inicializan las variables con diferentes acumulados en cada instante de reloj. Algunos acumulados sólo serían necesarios cuando se produzcan eventos, pero se podrían generalizar haciendo acumulados en cada instante. 
#
#Se ejecuta en cada instante mientra que otras funciones sólo si se producen ciertas condiciones. Sería mejor inicializar aquí los acumulados.
#Se arrastran los datos del siguiente fallo de página para cada proceso en cada unidad de tiempo.
		if [[ $reloj -ne 0 ]]; then
#Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
		fi
	done
#Fin de inicializarAcumulados()

#
# Sinopsis: Gestión de procesos - FCFS
#
function gestionProcesosFCFS {
    if [[ $cpu_ocupada == "NO" ]]; then
        if [[ $realizadoAntes -eq 0 ]]; then  
            indice_aux=-1
#Establecemos qué proceso es el siguiente que llega a memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
#El siguiente proceso que llega a memoria
                    temp_aux=${temp_rej[$i]}
                    break
                fi
            done
#Hemos encontrado el siguiente proceso en memoria
#Marco el proceso para ejecutarse
#Quitamos el estado pausado si el proceso lo estaba anteriormente
#Marcamos el proceso como en memoria
#La CPU está ocupada por un proceso
#Se activa el aviso de entrada en CPU del volcado
            fi
        fi
    fi
#Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
        done
#Si no hay proceso en ejecución se pone -1, para que pueda ser comparado.  
#Resumen - Proceso en ejecución en cada instante de tiempo. 
		else
			ResuTiempoProceso[$reloj]=-1
		fi 
	fi
#Si se trabaja NFU/NRU con clases.
#Se traspasan todos los datos al siguiente instante para ser modificados, si se produce nmodificaciones al analizar los fallos y usos de las páginas. 
# 
# 
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.
#Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#Se lanza la gestión sin algoritmo de paginación, dado que en memoria no virtual los procesos entran en memoria de forma completa y no por páginas como en memoria virtual.
#Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi 

#ESTADO DE CADA PROCESO
#Se modifican los valores de los arrays, restando de lo que quede
#ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizaran tras imprimir.)
    for (( i=0; i<$nprocesos; i++ )); do
        if [[ ${nollegado[$i]} -eq 1 ]] ; then
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
        if [[ ${encola[$i]} -eq 1 && ${bloqueados[$i]} -eq 1 && ${temp_wait[$i]} == "-" && ${temp_ret[$i]} == "-" ]] ; then
#Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#Aunque no entre en memoria ya tiene datos a considerar.
        fi
        if [[ ${encola[$i]} -eq 1 && ${bloqueados[$i]} -eq 1 ]] ; then
            estado[$i]="En espera"
            estad[$i]=1
        fi
        if [[ ${enmemoria[$i]} -eq 1 && ${temp_wait[$i]} == "-" && ${temp_ret[$i]} == "-" ]] ; then
#Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
        if [[ ${enmemoria[$i]} -eq 1 && ${enejecucion[$i]} -eq 1 ]] ; then
            estado[$i]="En ejecucion"
            estad[$i]=3
#Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
        elif [[ ${enmemoria[$i]} -eq 1 && ${enpausa[$i]} -eq 1 ]] ; then
            estado[$i]="En pausa"
        elif [[ ${enmemoria[$i]} -eq 1 ]] ; then
            estado[$i]="En memoria"
            estad[$i]=2
        fi
#Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
            estado[$i]="Finalizado"
            estad[$i]=5
#Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
        elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
            estado[$i]="Finalizado"
            estad[$i]=5
        fi
    done

#Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
#Siempre se imprimie el volcado en T=0. y también cuando se escoja la impresión unidad de tiempo a unidad de tiempo (seleccionMenuModoTiempoEjecucionAlgormitmo = optejecucion = 4).
        evento=1
    fi
#Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#Fin de gestionProcesosFCFS()

#
# Sinopsis: Gestión de procesos - SJF
#
function gestionProcesosSJF {
#ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizarán tras lanzar el volcado.)
#Se modifican los valores de los arrays.
#No ha llegado por tiempo de llegada.
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
#Se encola pero no ha llegado por tiempo de llegada.
#Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#Aunque no entre en memoria ya tiene datos a considerar.
            estado[$i]="En espera"
            estad[$i]=1
        fi
#Se mete en memoria.
#Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
    done
 
#Se establece el proceso con menor tiempo de ejecución de los que están en memoria.
        if [[ $realizadoAntes -eq 0 ]]; then  
#Contendrá un tiempo de ejecución de referencia (el primero encontrado) para su comparación con el de otros procesos.
            temp_aux=0
#Se busca el primer tiempo de ejecución de todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
                    if [[ ${temp_rej[$i]} -gt $temp_aux ]]; then
#Proceso de referencia
#Tiempo de ejecución de referencia
                    fi
                fi
#Una vez encontrado el primero, se van a comparar todos los procesos hasta encontrar el de tiempo restante de ejecución más pequeño.
            min_indice_aux=-1  
#Contendrá el menor tiempo de ejecución para su comparación con el de otros procesos.
#Se establece qué proceso tiene menor tiempo de ejecución de todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${terminados[$i]} -ne 1 ]]; then
                    if [[ ${temp_rej[$i]} -lt $min_temp_aux ]]; then
#Proceso de ejecución más corta hasta ahora
#Tiempo de ejecución menor hasta ahora
                    fi
                fi
            done
#Una vez encontrado el proceso más corto, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#Marco el proceso para ejecutarse.
#Quitamos el estado pausado si el proceso lo estaba anteriormente.
#La CPU está ocupada por un proceso.
#Se activa el aviso de entrada en CPU del volcado
            fi
        fi
    fi
#Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
            if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enejecucion[$i]} -eq 1 ]] ; then 
                estado[$i]="En ejecucion"
                estad[$i]=3
#Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enpausa[$i]} -eq 1 ]] ; then
                estado[$i]="En pausa"
                estad[$i]=4
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  ]] ; then
                estado[$i]="En memoria"
                estad[$i]=2
            fi
#Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
                estado[$i]="Finalizado"
                estad[$i]=5
#Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
            elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
                estado[$i]="Finalizado"
                estad[$i]=5
            fi
        done
    fi
#Si no hay proceso en ejecución se pone -1, para que pueda ser comparado.  
#Resumen - Proceso en ejecución en cada instante de tiempo. 
	else
		ResuTiempoProceso[$reloj]=-1
	fi 

#Si se trabaja NFU/NRU con clases.
#Se traspasan todos los datos al siguiente instante para ser modificados, si se produce nmodificaciones al analizar los fallos y usos de las páginas. 
# 
# 
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.

#Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#Se lanza la gestión sin algoritmo de paginación, dado que en memoria no virtual los procesos entran en memoria de forma completa y no por páginas como en memoria virtual.
#Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi

#Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
    if [[ $reloj -eq 0 || $optejecucion = "4" ]]; then 
        evento=1
    fi
#Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#Fin de gestionProcesosSJF()

#
# Sinopsis: Gestión de procesos - SRPT
#
function gestionProcesosSRPT {
#ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizarán tras lanzar el volcado.)
#Se modifican los valores de los arrays.
#No ha llegado por tiempo de llegada.
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
#Se encola pero no ha llegado por tiempo de llegada.
#Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#Aunque no entre en memoria ya tiene datos a considerar.
            estado[$i]="En espera"
            estad[$i]=1
        fi
#Se mete en memoria.
#Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
    done
 
#Se establece el proceso con mayor y menor tiempo de ejecución de los que están en memoria.
        if [[ $realizadoAntes -eq 0 ]]; then  
#Contendrá un tiempo de ejecución de referencia (el mayor tiempo de ejecución encontrado) para su comparación con el de otros procesos. Se busca el mayor para poder encontrar el primero de los de tiempo de ejecución más bajo.
            temp_aux=0
#Se busca el mayor tiempo de ejecución de todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
                    if [[ ${temp_rej[$i]} -gt $temp_aux ]]; then
#Proceso con el mayor tiempo de ejecución.
#Tiempo de ejecución de referencia.
                    fi
                fi
#Una vez encontrado el mayor, se van a comparar todos los procesos hasta encontrar el de menor tiempo restante de ejecución.
            min_indice_aux=-1  
#Contendrá el menor tiempo de ejecución para su comparación con el de otros procesos.
#Se establece qué proceso tiene menor tiempo de ejecución de todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${terminados[$i]} -ne 1 ]]; then
                    if [[ ${temp_rej[$i]} -lt $min_temp_aux ]]; then
#Proceso de tiempo de ejecución más bajo hasta ahora.
#Tiempo de ejecución menor hasta ahora.
                    fi
                fi
            done
#Una vez encontrado el proceso más corto, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#Marcamos el proceso como no ejecutándose si lo estaba anteriormente.
#Ponemos el estado pausado si el proceso anteriormente en ejecución.
#Marco el proceso para ejecutarse.
#Quitamos el estado pausado si el proceso lo estaba anteriormente.
#La CPU está ocupada por un proceso.
#Si había otro proceso en ejecución con anterioridad se avisa que se pone en pausa.
					avisoPausa[$anteriorProcesoEjecucion]=1 
                fi
#Se activa el aviso de entrada en CPU del volcado
                anteriorProcesoEjecucion=$min_indice_aux
            fi
        fi
    fi
#Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
            if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enejecucion[$i]} -eq 1 ]] ; then 
                estado[$i]="En ejecucion"
                estad[$i]=3
#Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enpausa[$i]} -eq 1 ]] ; then
                estado[$i]="En pausa"
                estad[$i]=4
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  ]] ; then
                estado[$i]="En memoria"
                estad[$i]=2
            fi
#Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
                estado[$i]="Finalizado"
                estad[$i]=5
#Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
            elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
                estado[$i]="Finalizado"
                estad[$i]=5
            fi
        done
    fi
#Si no hay proceso en ejecución se pone -1, para que pueda ser comparado. 
#Resumen - Proceso en ejecución en cada instante de tiempo. 
	else
		ResuTiempoProceso[$reloj]=-1
	fi 

#Si se trabaja NFU/NRU con clases.
#Se traspasan todos los datos al siguiente instante para ser modificados, si se producen modificaciones al analizar los fallos y usos de las páginas.   
# 
# 
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.

#Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#Se lanza la gestión sin algoritmo de paginación, dado que en memoria no virtual los procesos entran en memoria de forma completa y no por páginas como en memoria virtual.
#Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi
    
#Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
    if [[ $reloj -eq 0 || $optejecucion = "4" ]]; then 
        evento=1
    fi
#Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#Fin de gestionProcesosSRPT()

#
# Sinopsis: Gestión de procesos - Prioridades (Mayor/Menor)
#
function gestionProcesosPrioridades {
#ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizarán tras lanzar el volcado.)
#Se modifican los valores de los arrays.
#No ha llegado por tiempo de llegada.
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
#Se encola pero no ha llegado por tiempo de llegada.
#Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#Aunque no entre en memoria ya tiene datos a considerar.
#Aunque no entre en memoria ya tiene datos a considerar.
            estado[$i]="En espera"
            estad[$i]=1
        fi
#Se mete en memoria.
#Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
#Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
    done
	if [[ $realizadoAntes -eq 0 ]]; then  
        cerrojo_aux=0
#Variable de cierre
#Se busca la mayor prioridad de todas las que se encuentran en memoria.
			if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
#Se inicializan las variables para determinar el mayor valor de la priridad de los procesos en memoria.
#Se inicializa la variable con el primer proceso para la menor prioridad.
#Prioridad de referencia.
					cerrojo_aux=1
				fi
				if [[ ${temp_prio[$i]} -gt $prio_aux && $cerrojo_aux -eq 1 ]]; then
#Proceso con la menor prioridad.
#Prioridad de referencia.
				fi
			fi
#Una vez encontrada la mayor prioridad, se van a comparar todos los procesos hasta encontrar el de prioridad más baja.
#Prioridad mayor de los procesos en memoria.
#Proceso con la mayor prioridad.
#Variable de cierre  
#Contendrá la menor prioridad para su comparación con la de otros procesos. Se le pone un valor superior al máximo porque se busca el primero de los que tengan el menor valor.
#Se establece qué proceso tiene menor prioridad de todos los que se encuentran en memoria.
			if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${terminados[$i]} -ne 1 ]]; then
				if [[ ${temp_prio[$i]} -lt $min_prio_aux ]]; then
#Proceso de prioridad más baja hasta ahora
#Prioridad menor hasta ahora
				fi
			fi
		done
	fi
#Si es Prioridad Mayor y se invierte el rango, se calcula la Prioridad Menor, y viveversa. 
		if [[ $seleccionTipoPrioridad -eq 1 ]]; then 
			seleccionTipoPrioridad_2=2
		elif [[ $seleccionTipoPrioridad -eq 2 ]]; then 
			seleccionTipoPrioridad_2=1
		fi
#Si el rango de Prioridades no se invierte, se deja sin modificar la elección Mayor/Menor.
		seleccionTipoPrioridad_2=$seleccionTipoPrioridad
	fi
#Se establece el proceso con menor prioridad de los que están en memoria.
#seleccionMenuApropiatividad - 1-No apropiativo - 2-Apropiativo
#Prioridad Mayor/Apropiativo - Se roba la CPU por ser Apropiativo.
#Una vez encontrado el proceso de menor prioridad, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#Marcamos el proceso como no ejecutándose si lo estaba anteriormente.
#Ponemos el estado pausado si el proceso anteriormente en ejecución.
#Marco el proceso para ejecutarse.
#Quitamos el estado pausado si el proceso lo estaba anteriormente.
#La CPU está ocupada por un proceso.
#Una vez encontrado el proceso con más baja prioridad, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#Se activa el aviso de entrada en CPU del volcado
				fi
#Se activa el aviso de entrada en CPU del volcado
				anteriorProcesoEjecucion=$max_indice_aux
			fi
#Prioridad Menor/Apropiativo - Se roba la CPU por ser Apropiativo.
#Una vez encontrado el proceso de menor prioridad, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#Marcamos el proceso como no ejecutándose si lo estaba anteriormente.
#Ponemos el estado pausado si el proceso anteriormente en ejecución.
#Marco el proceso para ejecutarse.
#Quitamos el estado pausado si el proceso lo estaba anteriormente.
#La CPU está ocupada por un proceso.
#Si había otro proceso en ejecución con anterioridad se avisa que se pone en pausa.
					avisoPausa[$anteriorProcesoEjecucion]=1 
				fi
#Se activa el aviso de entrada en CPU del volcado
				anteriorProcesoEjecucion=$min_indice_aux
			fi
		fi
	fi

#Se establece el proceso con menor prioridad de los que están en memoria.
#seleccionMenuApropiatividad - 1-No apropiativo - 2-Apropiativo
#1 Prioridad Mayor/No Apropiativo - No se roba la CPU por ser NO Apropiativo.
#Una vez encontrado el proceso más corto, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#Marco el proceso para ejecutarse.
#Quitamos el estado pausado si el proceso lo estaba anteriormente.
#La CPU está ocupada por un proceso.
#Se activa el aviso de entrada en CPU del volcado
			fi
#2 Prioridad Menor/No Apropiativo - No se roba la CPU por ser NO Apropiativo.
#Una vez encontrado el proceso más corto, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#Marco el proceso para ejecutarse.
#Quitamos el estado pausado si el proceso lo estaba anteriormente.
#La CPU está ocupada por un proceso.
#Se activa el aviso de entrada en CPU del volcado
			fi
		fi
    fi

#Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
            if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enejecucion[$i]} -eq 1 ]] ; then 
                estado[$i]="En ejecucion"
                estad[$i]=3
#Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enpausa[$i]} -eq 1 ]] ; then
                estado[$i]="En pausa"
                estad[$i]=4
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  ]] ; then
                estado[$i]="En memoria"
                estad[$i]=2
            fi
#Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
                estado[$i]="Finalizado"
                estad[$i]=5
#Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
            elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
                estado[$i]="Finalizado"
                estad[$i]=5
            fi
        done
    fi
#Si no hay proceso en ejecución se pone -1, para que pueda ser comparado. 
#Resumen - Proceso en ejecución en cada instante de tiempo. 
	else
		ResuTiempoProceso[$reloj]=-1
	fi 

#Si se trabaja NFU/NRU con clases.
#Se traspasan todos los datos al siguiente instante para ser modificados, si se producen modificaciones al analizar los fallos y usos de las páginas.   
# 
# 
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.

#Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#Se lanza la gestión sin algoritmo de paginación, dado que en memoria no virtual los procesos entran en memoria de forma completa y no por páginas como en memoria virtual.
#Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi
    
#Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
    if [[ $reloj -eq 0 || $optejecucion = "4" ]]; then 
        evento=1
    fi
#Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#Fin de gestionProcesosPrioridades()

#
# Sinopsis: Gestión de procesos - Round Robin
#
function gestionProcesosRoundRobin {
#ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizarán tras lanzar el volcado.)
#Se modifican los valores de los arrays. Primero se trabaja con los estados y tiempos de las estadísticas.
#No ha llegado por tiempo de llegada.
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
#Se encola pero no ha llegado por tiempo de llegada.
#Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#Aunque no entre en memoria ya tiene datos a considerar.
            estado[$i]="En espera"
            estad[$i]=1
        fi
#Se mete en memoria.
#Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
    done
#Se modifican los valores de los arrays, pero ahora se trabaja con el proceso que pueda haber terminado.
#Si termina el proceso, su referencias en la cola RR se actualiza a "_", y el contador $contadorTiempoRR a 0.
			colaTiempoRR[$i]=-1 
#Marcamos el proceso como no ejecutándose si lo estaba anteriormente.
#Índice con el actual ordinal en ejecución para Round-Robin (RR).
			anteriorProcesoEjecucion=$i
#Para que el proceso que se vaya a ejecutar empiece a usar su quantum desde 0.
		fi 
    done
#Se modifican los valores de los arrays. Y ahora se trabaja con el resto de variables para trabajar sobre los tiempos ya establecidos ya que dependen de ellos en algunos casos.
#Si termina el quantum de un proceso, su referencias en la cola RR se actualiza al último valor del $contadorTiempoRR.
#Se marca el proceso par no ser ejecutado ya que comenzará a ejecutarse otro proceso.
#Se marca el proceso como "en pausa".
#Número de expulsiones forzadas en Round-Robin (RR) 
			anteriorProcesoEjecucion=$i
			contadorTiempoRR=0
			colaTiempoRR[$i]=$indiceColaTiempoRRLibre  
#Índice con el primer ordinal libre a repartir en Round-Robin (RR).
#Índice con el actual ordinal en ejecución para Round-Robin (RR).
#Provoca un volcado en cada final de quantum
#Se marca que la CPU no está ocupada por un proceso.
		fi 
    done
#En primer lugar se establece el primer proceso que haya entrado en memoria por tiempo de llegada, o por estricto orden de llegada en memoria.
        if [[ $realizadoAntes -eq 0 ]]; then  
#Se busca el primer proceso de entre todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
#Si hay nuevos procesos en memoria se les encola.
						colaTiempoRR[$i]=$indiceColaTiempoRRLibre  
						indiceColaTiempoRRLibre=$(($indiceColaTiempoRRLibre + 1))
					fi 
                fi
#Una vez encolados, se determina si se sigue ejecutando el mismo que ya lo estaba en el instante anterior, o se determina cuál se ejecutará en el instante actual, si el proceso anterior o su quantum han terminado.
#Se busca el primer proceso de entre todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
#Si es nuevo, empieza a ejecutarse. Si el proceso está marcado como en ejecución, el contador $contadorTiempoRR aumenta en una unidad.
						contadorTiempoRR=$(($contadorTiempoRR + 1))
#Se marca el proceso para ejecutarse o se refuerza si ya lo estaba.
#Se quita el estado pausado si el proceso lo estaba anteriormente.
#Se marca que la CPU está ocupada por un proceso o se refuerza si ya lo estaba.
#Si había otro proceso en ejecución con anterioridad se avisa que se pone en pausa.
							avisoPausa[$anteriorProcesoEjecucion]=1 
						fi
#Se activa el aviso de entrada en CPU del volcado
					fi 
				fi
            done 
        fi
    fi
#Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
            if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enejecucion[$i]} -eq 1 ]] ; then 
                estado[$i]="En ejecucion"
                estad[$i]=3
#Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enpausa[$i]} -eq 1 ]] ; then
                estado[$i]="En pausa"
                estad[$i]=4
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  ]] ; then
                estado[$i]="En memoria"
                estad[$i]=2
            fi
#Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
                estado[$i]="Finalizado"
                estad[$i]=5
#Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
            elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
                estado[$i]="Finalizado"
                estad[$i]=5
            fi
        done
    fi
#Si no hay proceso en ejecución se pone -1, para que pueda ser comparado. 
#Resumen - Proceso en ejecución en cada instante de tiempo. 
	else
		ResuTiempoProceso[$reloj]=-1
	fi 

#Si se trabaja NFU/NRU con clases.
#Se traspasan todos los datos al siguiente instante para ser modificados, si se producen modificaciones al analizar los fallos y usos de las páginas.   
# 
# 
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.

#Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#Se lanza la gestión sin algoritmo de paginación, dado que en memoria no virtual los procesos entran en memoria de forma completa y no por páginas como en memoria virtual.
#Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi
    
#Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
    if [[ $reloj -eq 0 || $optejecucion = "4" ]]; then 
        evento=1
    fi
#Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#Fin de gestionProcesosRoundRobin()

#
# Sinopsis: Algoritmo PagNoVirtual
#
function gestionAlgoritmoPagNoVirtual { 
#Si no hay proceso en ejecución se pone -1, para que pueda ser comparado. 
#Resumen - Proceso en ejecución en cada instante de tiempo. 
	else
		ResuTiempoProceso[$reloj]=-1
	fi
#Se inicializan los arrays que se van a usar temporalmente para cada proceso en ejecución.
#Contiene el ordinal del número de marco de cada proceso.
#Se van a determinar los marcos reales que usa cada proceso.
		ordinal[$counter]=0
	done
#El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
# Se buscan los marcos ocupados por cada proceso
			relacionMarcosUsados[${unidMemOcupadas[$ii]},$reloj,${ordinal[${unidMemOcupadas[$ii]}]}]=$ii
			ordinal[${unidMemOcupadas[$ii]}]=$((${ordinal[${unidMemOcupadas[$ii]}]} + 1))
        fi
	done
#Se crea la secuencia de páginas en memoria de cada proceso.
		paginasEnMemoriaProceso[$v]=${paginasEnMemoriaTotal[$ejecutandoinst,$v]}
	done 
#Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#Se crea la secuencia de páginas de cada proceso pendientes de ejecutar.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasPendientesUsarTotal[$ejecutandoinst,$v]=$pagina
	done
#Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#Se crea la secuencia de páginas de cada proceso ya ejecutadas.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasUsadasTotal[$ejecutandoinst,$v]=$pagina
#No es necesario ya que paginasUsadasTotal[] se genera en cada ejecución de la función.
	done 
#Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#Como no cambian las páginas de memoria en el modelo paginado y no virtual, se inicializan a 0 para que se imprima este valor desde el principio-
			done
		fi
	done
#En No Virtual se usan todos los marcos asociados al proceso desde el primer momento porque se cargan en memoria todas las páginas del proceso.
#Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
			done
		fi
	done
		
#Se inicializan las variables si no ha sido considerado el proceso con anterioridad.
#Se meten las páginas del proceso en ejecución en los marcos de memoria.
			paginasEnMemoriaProceso[$counterMarco]=${counterMarco}
			paginasEnMemoriaTotal[$ejecutandoinst,$counterMarco]=$counterMarco
#Índices: (proceso, marco, tiempo reloj). Dato de la página contenida en el marco
		done
#El número de fallos de página del proceso es el número de marcos asociados a cada proceso.
#El número de fallos de página totales es la suma de los números de marcos asociados a cada proceso.
	fi 

#Si aún quedan páginas por ejecutar de ese proceso
#Se determina la primera página de la secuencia de páginas pendientes
#Número de páginas usadas en el proceso en ejecución. Aumenta en todas las unidades de ejecución del proceso. 
#Siguiente página, pendiente de ejecutar.
#Localiza en qué posición encuentra la página (da la posición pero no la variable en el array)
#Localiza la página, no la posición de la página
#Si la página está en memoria define x=1
#Si la página está en memoria define x=1
#Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#Localiza en qué posición encuentra la página (da la posición pero no la variable en el array)
#Localiza la página, no la posición de la página
					if [[ ${paginasEnMemoriaProceso[$indMarcoMem]} -eq $primera_pagina ]]; then
#Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
#Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Se mantiene el mismo mientras no se produzca un fallo de página. 
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
					fi
				done
			fi 
		done
#Y si no quedan más páginas pendientes de ejecutar. No es tiempoEjecucion sino temp_rej.
		for (( counter=0; counter<$nprocesos; counter++ )); do
#Para ser equivalente al nuevo programa. Se aconseja quitar la variable $ord y estandarizar las variables a usar ??????????.
			if [[ " ${llegados[*]} " == *" $ejecutandoinst "* ]]; then 
#Como temp_ret()
#Como temp_ret()
				if [[ ! " ${ejecutando[*]} " == *" $ejecutandoinst "* ]]; then
#Como temp_wait()
					if [[ " ${haestadopausado[*]} " == *" $ejecutandoinst "* ]]; then
#Esa resta debería ser alrevés, el de ejecución menos lo ya ejecutado...
#Tampoco es (reloj - llegada[$ejecutandoinst])
					fi
#Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
				fi
			fi
		done
#Actualización de variables y cambios de estado. Algunos ya se hacen en ajusteFinalTiemposEsperaEjecucionRestante().
		ejecutando="" 
		finalizados+=("$finalizado")
		finalizadonuevo+=("$finalizado")
		hanestadomem=$paginasEnMemoriaProceso
#De momento se cambia ordenados por llegada.
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#Define el dato, pero no en qué posición se encuentra.
				if [[ "${enmemoria[$i]}" == "$finalizado" ]]; then
					posicion_finalizado=$i
					unset 'enmemoria[$posicion_finalizado]'
					unset 'llegados[$posicion_finalizado]'
					unset 'enpausa[$posicion_finalizado]'
					unset 'prioridades[$posicion_finalizado]'
					memvacia=$((memvacia + ${memoria[$finalizado]}))
				fi
			done
		fi
	fi
#Fin de gestionAlgoritmoPagNoVirtual()

#
# Sinopsis: Algoritmo AlgPagFrecFIFORelojSegOp
#
function gestionAlgoritmoPagAlgPagFrecFIFORelojSegOp { 
#Si no hay proceso en ejecución se pone -1, para que pueda ser comparado. 
#Resumen - Proceso en ejecución en cada instante de tiempo. 
	else
		ResuTiempoProceso[$reloj]=-1
	fi
#Se inicializan los arrays que se van a usar temporalmente para cada proceso en ejecución.
#Contiene el ordinal del número de marco de cada proceso.
#Se van a determinar los marcos reales que usa cada proceso.
		ordinal[$counter]=0
	done
#El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
# Se buscan los marcos ocupados por cada proceso
			relacionMarcosUsados[${unidMemOcupadas[$ii]},$reloj,${ordinal[${unidMemOcupadas[$ii]}]}]=$ii
			ordinal[${unidMemOcupadas[$ii]}]=$((${ordinal[${unidMemOcupadas[$ii]}]} + 1))
        fi
	done
#Se crea la secuencia de páginas en memoria de cada proceso.
		paginasEnMemoriaProceso[$v]=${paginasEnMemoriaTotal[$ejecutandoinst,$v]}
	done 
#Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#Se crea la secuencia de páginas de cada proceso pendientes de ejecutar.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasPendientesUsarTotal[$ejecutandoinst,$v]=$pagina
	done
#Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#Se crea la secuencia de páginas de cada proceso ya ejecutadas.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasUsadasTotal[$ejecutandoinst,$v]=$pagina
#No es necesario ya que paginasUsadasTotal[] se genera en cada ejecución de la función.
	done 
#Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
			done
		fi
	done

#Con Segunda Oportunidad. Se determina el primer marco con coeficiente M=0. Y si encuentra marcos con M=1, les define M=0 y busca el siguiente. El coeficiente de la página intercambiada también se define a 0 por lo que se deja tal y como estaba, a 0.
#Se arrastran los datos de los coeficientes en anteriores tiempos ordinales de ejecución para cada proceso en cada unidad de tiempo.
			if ([[ ${estad[$counterProc]} -eq 2 || ${estad[$counterProc]} -eq 3 || ${estad[$counterProc]} -eq 4 ]]) && [[ ${numeroPaginasUsadasProceso[$counterProc]} -gt 0 ]]; then
				for (( jj=0; jj<${numeroMarcosUsados[$counterProc]}; jj++ )); do 
					coeficienteSegOp[$counterProc,$jj,$((${numeroPaginasUsadasProceso[$counterProc]}))]=${coeficienteSegOp[$counterProc,$jj,$((${numeroPaginasUsadasProceso[$counterProc]} - 1))]}
				done 
			elif ([[ ${estad[$counterProc]} -eq 2 || ${estad[$counterProc]} -eq 3 || ${estad[$counterProc]} -eq 4 ]]) && [[ ${numeroPaginasUsadasProceso[$counterProc]} -eq 0 ]]; then
				for (( jj=0; jj<${numeroMarcosUsados[$counterProc]}; jj++ )); do 
					coeficienteSegOp[$counterProc,$jj,$((${numeroPaginasUsadasProceso[$counterProc]}))]=0
				done 
			fi
		done
	fi
		
#Si aún quedan páginas por ejecutar de ese proceso
#Se determina la primera página de la secuencia de páginas pendientes
#Número de páginas usadas en el proceso en ejecución. Aumenta en todas las unidades de ejecución del proceso. 
#Siguiente página, pendiente de ejecutar.

#Si el número de marcos usados es menor que el tamaño de la memoria asociada al proceso.

#Define si encuentra o no la página en paginasEnMemoriaProceso
#Localiza en qué posición encuentra la página en paginasEnMemoriaProceso (da la posición, pero no la variable en el array)
#Busca la página en paginasEnMemoriaProceso, pero no la posición.
#Esta línea es para cuando usamos el valor del dato y no su posición. Si la página está en memoria define x=1
#Esta línea es para cuando usamos la posición del dato y no su valor. Si la página está en memoria define x=1
					x=1
# Se guarda el marco en el que se encuentra la página.
				fi 
			done
#USO DE PÁGINA - Si la página está en memoria, y si no es la primera página a usar para evitar la inicialización de la variable paginasEnMemoriaTotal[$ejecutandoinst,ordinal}] a 0.
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#Define el dato, pero no en qué posición se encuentra.
#Localiza en qué posición encuentra la página (j). 
#Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
						for (( jj=0; jj<${memoria[$ejecutandoinst]}; jj++ )); do
#Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
						done 
#Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.  
#Con Segunda Oportunidad
#En caso de reusar una página se pone a 1 aunque pueda ser redundante si ya era 1.
						fi
					fi
				done
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se ejecuta este proceso. También se usa para las frecuencias.
#Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0. 
				else
#Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0. 
				fi
#Si NO está en memoria... FALLO DE PÁGINA
#... la página se añade a la secuencia de páginas del proceso en ejecución en memoria.
#... y la página se añade a la secuencia de páginas de ese proceso junto con el resto de páginas del resto de procesos residentes en memoria (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#Contador de fallos de página totales de cada proceso
#Contador de fallos totales de cada proceso
#Si no es el primer instante de ejecución de este proceso.  Primero se copian y luego se modifican si es necesario.
#Se recuperan los datos de las páginas que ocupan todos los marcos en el instante anterior en el que se ejecutó este proceso.
#Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
					done
				fi 
#Se añade el dato de la página que acaba de ser incluida en un marco.
# Se añade el dato de la frecuencia de la página que acaba de ser incluida en un marco.
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
#Y se añade la página a la secuencia de fallos. 
#Y se añade el marco a la secuencia de fallos. 
#Aumenta en 1 el número de marcos usados. Sólo aumenta cuando se usa un nuevo marco y no en todas las unidades de ejecución del proceso. Debe ser la última línea dentro del if paradejarlo preparado para su siguiente uso como variable.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). Sería -1 porque numeroMarcosUsados empieza a contar en 1.
#Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados ya ha aumentado 1. 
				else
					ResuPunteroMarcoSiguienteFalloPagAcumulado[$ejecutandoinst,$reloj]=0
				fi
#Con Segunda Oportunidad. Redundante porque ya se inicializa a 0...
					coeficienteSegOp[$ejecutandoinst,${ResuPunteroMarcoUsado[$ejecutandoinst,$reloj]},$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))]=0
				fi
			fi
#Si el número de marcos usados es mayor o igual que el tamaño de la memoria asociada al proceso.
#Define si encuentra o no la página en paginasEnMemoriaProceso
#Localiza en qué posición encuentra la página (da la posición pero no la variable en el array)
#Localiza la página, no la posición de la página
#Si la página está en memoria define x=1
#Si la página está en memoria define x=1
					x=1
				fi 
			done
#Si la página está en memoria...USO DE PÁGINA
#Localiza en qué posición encuentra la página (da la posición pero no la variable en el array)
#Localiza la página, no la posición de la página
					if [[ ${paginasEnMemoriaProceso[$indMarcoMem]} -eq $primera_pagina ]]; then
						for (( jj=0; jj<${memoria[$ejecutandoinst]}; jj++ )); do
#Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.							
#Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
						done
#Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
#Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Con Segunda Oportunidad
#En caso de reusar una página se pone a 1 aunque pueda ser redundante si ya era 1.
						fi
#Se mantiene el mismo mientras no se produzca un fallo de página. 
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
					fi
				done
#Y si NO está en la memoria...FALLO DE PÁGINA. se localiza el que tenga el primer valor del mayor contador de frecuencia por ser AlgPagFrecMFU.
#Con Segunda Oportunidad. Se determina el primer marco con coeficiente M=0. Y si encuentra marcos con M=1, les define M=0 y busca el siguiente. El coeficiente de la página intercambiada también se define a 0 por lo que se deja tal y como estaba, a 0.
					varCoeficienteSegOp=0
					varCoefMarco=""
#Se usa el mismo tiempo ordinal de ejecución del proceso para todos los marcos porque es el siguiente tiempo ordinal el que interesa. La variable ResuPaginaOrdinalAcumulado[] se cambiará después, pero ya se tiene en cuenta ahora.
					until [[ $varCoeficienteSegOp -eq 1 ]]; do 
						varCoefMarco=${ResuPunteroMarcoSiguienteFalloPagAcumulado[$ejecutandoinst,$reloj]}
#Si M de Segunda Oportunidad vale 0, se pone a 1. Y si ya vale 1, se deja como está. 
#Se define a 0 para que en la segunda vuelta se pueda producir el fallo sobre el primer M=0 que encuentre.
#Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0. 
							else
								ResuPunteroMarcoSiguienteFalloPagAcumulado[$ejecutandoinst,$reloj]=0
							fi
						else 
#Se define a 0 para que en la segunda vuelta se pueda producir el fallo sobre el primer M=0 que encuentre.
							varCoeficienteSegOp=1
						fi
					done
				fi
#Se hace el fallo de página sobre el primer marco con la mayor frecuencia, sustituyendo la página.
#Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#Aumenta en una unidad el número de fallos de página del proceso.
#Contador de fallos totales de cada proceso
				for (( jj=0; jj<${memoria[$ejecutandoinst]}; jj++ )); do
#Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.								
#Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
				done
# Se añade el dato de la página que acaba de ser incluida en un marco.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página. 
#Y se añade la página a la secuencia de fallos. 
#Y se añade el marco a la secuencia de fallos. 
#Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0. 
				else
					ResuPunteroMarcoSiguienteFalloPagAcumulado[$ejecutandoinst,$reloj]=0
				fi
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
			fi
		fi          
#Y si no quedan más páginas pendientes de ejecutar. No es tiempoEjecucion sino temp_rej.
		for (( counter=0; counter<$nprocesos; counter++ )); do
#Para ser equivalente al nuevo programa. Se aconseja quitar la variable $ord y estandarizar las variables a usar ??????????.
			if [[ " ${llegados[*]} " == *" $ejecutandoinst "* ]]; then 
#Como temp_ret()
#Como temp_ret()
				if [[ ! " ${ejecutando[*]} " == *" $ejecutandoinst "* ]]; then
#Como temp_wait()
					if [[ " ${haestadopausado[*]} " == *" $ejecutandoinst "* ]]; then
#Esa resta debería ser alrevés, el de ejecución menos lo ya ejecutado...
#Tampoco es (reloj - llegada[$ejecutandoinst])
					fi
#Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
				fi
			fi
		done
#Actualización de variables y cambios de estado. Algunos ya se hacen en ajusteFinalTiemposEsperaEjecucionRestante().
		ejecutando="" 
		finalizados+=("$finalizado")
		finalizadonuevo+=("$finalizado")
		hanestadomem=$paginasEnMemoriaProceso
#De momento se cambia ordenados por llegada.
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#Define el dato, pero no en qué posición se encuentra.
				if [[ "${enmemoria[$i]}" == "$finalizado" ]]; then
					posicion_finalizado=$i
					unset 'enmemoria[$posicion_finalizado]'
					unset 'llegados[$posicion_finalizado]'
					unset 'enpausa[$posicion_finalizado]'
					unset 'prioridades[$posicion_finalizado]'
					memvacia=$((memvacia + ${memoria[$finalizado]}))
				fi
			done
		fi
	fi
#Fin de gestionAlgoritmoPagAlgPagFrecFIFORelojSegOp()

#
# Sinopsis: Algoritmo AlgPagFrecMFULFUNFU - NFU usará un límite máximo de la frecuencia de uso de las páginas (seleccionAlgoritmoPaginacion_clases_frecuencia_valor) y el límite de tiempo de permanencia en las clases 2 y 3 (seleccionAlgoritmoPaginacion_clases_valor) en un intervalo de tiempo (seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado)
#
#ResuFrecuenciaAcumulado
#Se inicializan los arrays que se van a usar temporalmente para cada proceso en ejecución.
#Contiene el ordinal del número de marco de cada proceso.
#Se van a determinar los marcos reales que usa cada proceso.
		ordinal[$counter]=0
	done
#El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
# Se buscan los marcos ocupados por cada proceso
			relacionMarcosUsados[${unidMemOcupadas[$ii]},$reloj,${ordinal[${unidMemOcupadas[$ii]}]}]=$ii
			ordinal[${unidMemOcupadas[$ii]}]=$((${ordinal[${unidMemOcupadas[$ii]}]} + 1))
        fi
	done
#Se crea la secuencia de páginas en memoria de cada proceso.
		paginasEnMemoriaProceso[$v]=${paginasEnMemoriaTotal[$ejecutandoinst,$v]}
	done 
#Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#Se crea la secuencia de páginas de cada proceso pendientes de ejecutar.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasPendientesUsarTotal[$ejecutandoinst,$v]=$pagina
	done
#Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#Se crea la secuencia de páginas de cada proceso ya ejecutadas.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasUsadasTotal[$ejecutandoinst,$v]=$pagina
#No es necesario ya que paginasUsadasTotal[] se genera en cada ejecución de la función.
	done 
#Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#NFU con clases sobre MFU/LFU
#Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				fi
			done
		fi
	done
	
#Se crea la secuencia de páginas en memoria de cada proceso.
		indPagIni=$((${numeroPaginasUsadasProceso[$ejecutandoinst]}))
		if [[ $indPagIni -eq 0 ]]; then
#Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		else
#Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		fi
	done 
#Se crea la secuencia de páginas en memoria de cada proceso.
#Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3, o al máximo de frecuencia de uso.
	done 

#Si aún quedan páginas por ejecutar de ese proceso.
#Se determina la primera página de la secuencia de páginas pendientes.
#Número de páginas usadas en el proceso en ejecución. Aumenta en todas las unidades de ejecución del proceso. 
#Siguiente página, pendiente de ejecutar.
#Si el número de marcos usados es menor que el tamaño de la memoria asociada al proceso.
#Define si encuentra o no la página en paginasEnMemoriaProceso
#Localiza en qué posición encuentra la página en paginasEnMemoriaProceso (da la posición, pero no la variable en el array).
#Esta línea es para cuando usamos la posición del dato y no su valor. Si la página está en memoria define x=1.
					x=1
				fi 
			done
#USO DE PÁGINA - Si la página está en memoria, y si no es la primera página a usar para evitar la inicialización de la variable paginasEnMemoriaTotal[$ejecutandoinst,ordinal}] a 0.
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array).
#Localiza en qué posición encuentra la página (j). 
#Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#NFU-MFU/NFU-LFU
							if [[ ${ResuFrecuenciaAcumulado[$ejecutandoinst,$indMarcoMem,${indiceResuPaginaAcumulado[$ejecutandoinst]}]} -lt $seleccionAlgoritmoPaginacion_frecuencia_valor ]]; then 
#Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.  
							else
#Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
							fi
#MFU/LFU
#Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.  
#NFU-MFU/NFU-LFU con clases
#Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.  
							directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarcoMem]=1
#Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#Si las páginas tienen una frecuencia de uso mayor que la frecuencia máxima $seleccionAlgoritmoPaginacion_clases_frecuencia_valor
# se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor. Si lo supera se comprueba que no sea en la misma clase 2 o 3.
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoMem]=$seleccionAlgoritmoPaginacion_clases_frecuencia_valor
							fi
						fi
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se ejecuta este proceso. También se usa para las frecuencias.
#Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0. 
						fi
#NFU con clases sobre MFU/LFU
#Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
						fi
					fi
				done
#Si NO está en memoria... FALLO DE PÁGINA
#Aumenta en 1 el número de marcos usados. Sólo aumenta cuando se usa un nuevo marco y no en todas las unidades de ejecución del proceso. Debe ser la última línea dentro del if paradejarlo preparado para su siguiente uso como variable.
#Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). Sería -1 porque numeroMarcosUsados empieza a contar en 1.
#... la página se añade a la secuencia de páginas del proceso en ejecución en memoria.
#... y la página se añade a la secuencia de páginas de ese proceso junto con el resto de páginas del resto de procesos residentes en memoria (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#Contador de fallos de página totales de cada proceso.
#Contador de fallos totales de cada proceso
#Se añade el dato de la página que acaba de ser incluida en un marco.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
# Se añade el dato de la frecuencia de la página que acaba de ser incluida en un marco.
#Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Y se añade la página a la secuencia de fallos. 
#Y se añade el marco a la secuencia de fallos. 
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
				directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))]=0
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 ]]; then
#Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
				fi
#Sólo es necesario si se llenan todos los marcos asociados al proceso. 
#MFU
#Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#Localiza en qué posición encuentra la página. 
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
							fi
#Y sobre esa localización se hace el fallo de página
#NFU con clases sobre MFU
#Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
#QUEDA PENDIENTE USARLO PARA RESTAR LA FRECUENCIA ACTUAL DE LA QUE TENÍA EN AQUEL MOMENTO.
						else
							limite_j=0
						fi
#Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#LFU
#Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#Localiza en qué posición encuentra la página. 
#Menor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
							fi
#Y sobre esa localización se hace el fallo de página
					
#NFU con clases sobre MFU
#Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					fi
				fi
#Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#Suma 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres. 
				else
#MFU
#El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#LFU
#El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
					fi
				fi
			fi
#Si el número de marcos usados es mayor o igual que el tamaño de la memoria asociada al proceso.
#Define si encuentra o no la página en paginasEnMemoriaProceso.
#Localiza en qué posición encuentra la página (da la posición pero no la variable en el array).
#Si la página está en memoria define x=1.
					x=1
				fi 
			done
#Si la página está en memoria...USO DE PÁGINA
#Localiza en qué posición encuentra la página (da la posición pero no la variable en el array).
					if [[ ${paginasEnMemoriaProceso[$indMarcoMem]} -eq $primera_pagina ]]; then
#Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#NFU-MFU/NFU-LFU
							if [[ ${ResuFrecuenciaAcumulado[$ejecutandoinst,$indMarcoMem,${indiceResuPaginaAcumulado[$ejecutandoinst]}]} -lt $seleccionAlgoritmoPaginacion_frecuencia_valor ]]; then 
#Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
							else
#Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
							fi
#MFU/LFU
#Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
#NFU-MFU/NFU-LFU con clases
#Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.  
							directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarcoMem]=1
#Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#Si las páginas tienen una frecuencia de uso mayor que la frecuencia máxima $seleccionAlgoritmoPaginacion_clases_frecuencia_valor
# se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor. Si lo supera se comprueba que no sea en la misma clase 2 o 3.
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoMem]=$seleccionAlgoritmoPaginacion_clases_frecuencia_valor
							fi
#Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
						fi
#MFU
#Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
								fi
#Y sobre esa localización se hace el fallo de página
#El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
				
#NFU con clases sobre MFU
#Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
							paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
								limite_j=$ultimasPaginasAConsiderar
							else
								limite_j=0
							fi
#Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#LFU
#Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
							min_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#Localiza en qué posición encuentra la página.
#Menor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
								fi
#Y sobre esa localización se hace el fallo de página
#El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
				
#NFU con clases sobre MFU
#Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
							min_AlgPagFrecRec_Position[$ejecutandoinst]=0
							ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
							paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
								limite_j=$ultimasPaginasAConsiderar
							else
								limite_j=0
							fi
#Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
						fi
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
					fi
				done
#Y si NO está en la memoria...FALLO DE PÁGINA. Se localiza el que tenga el primer valor del mayor contador de frecuencia por ser AlgPagFrecMFU.
#MFU
#Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#Se hace el fallo de página sobre el primer marco con la mayor frecuencia, sustituyendo la página.
#Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.

#NFU con clases sobre MFU
#Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#Se hace el fallo de página sobre el primer marco con la mayor frecuencia, sustituyendo la página.
#Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,${max_AlgPagFrecRec_Position[$ejecutandoinst]}]=0
#LFU
#Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#Se hace el fallo de página sobre el primer marco con la menor frecuencia, sustituyendo la página.
#Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
				
#NFU con clases sobre MFU
#Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#Se hace el fallo de página sobre el primer marco con la menor frecuencia, sustituyendo la página.
#Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,${min_AlgPagFrecRec_Position[$ejecutandoinst]}]=0
				fi
#Aumenta en una unidad el número de fallos de página del proceso.
#Contador de fallos totales de cada proceso
#MFU
# Se añade el dato de la página que acaba de ser incluida en un marco.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página. 
#Y se añade la página a la secuencia de fallos. 
#Y se añade el marco a la secuencia de fallos. 
#NFU-MFU con clases					
#Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
#Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					else
#Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
							fi
#Y sobre esa localización se hace el fallo de página.
					fi
#El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#LFU
# Se añade el dato de la página que acaba de ser incluida en un marco.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página. 
#Y se añade la página a la secuencia de fallos. 
#Y se añade el marco a la secuencia de fallos. 
#NFU-LFU con clases
#Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
#Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					else
#Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
							fi
#Y sobre esa localización se hace el fallo de página.
					fi
#El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
				fi
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
			fi
		fi          
	
#Y si no quedan más páginas pendientes de ejecutar. No es tiempoEjecucion sino temp_rej.
		for (( counter=0; counter<$nprocesos; counter++ )); do
#Para ser equivalente al nuevo programa. ?????? QUITAR ord ??????????
			if [[ " ${llegados[*]} " == *" $ejecutandoinst "* ]]; then 
#Como temp_ret(). Se aconseja quitar la variable $retorno y estandarizar las variables a usar ??????????.
#Como temp_ret(). Se aconseja quitar la variable $retorno y estandarizar las variables a usar ??????????.
				if [[ ! " ${ejecutando[*]} " == *" $ejecutandoinst "* ]]; then
#Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
					if [[ " ${haestadopausado[*]} " == *" $ejecutandoinst "* ]]; then
#Esa resta debería ser alrevés, el de ejecución menos lo ya ejecutado...
#Tampoco es (reloj - llegada[$ejecutandoinst]).
					fi
#Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
				fi
			fi
		done
#Actualización de variables y cambios de estado. Algunos ya se hacen en ajusteFinalTiemposEsperaEjecucionRestante().
		ejecutando="" 
		finalizados+=("$finalizado")
		finalizadonuevo+=("$finalizado")
		hanestadomem=$paginasEnMemoriaProceso
#De momento se cambia ordenados por llegada.
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array).
				if [[ "${enmemoria[$i]}" == "$finalizado" ]]; then
					posicion_finalizado=$i
					unset 'enmemoria[$posicion_finalizado]'
					unset 'llegados[$posicion_finalizado]'
					unset 'enpausa[$posicion_finalizado]'
					unset 'prioridades[$posicion_finalizado]'
					memvacia=$((memvacia + ${memoria[$finalizado]}))
				fi
			done
		fi
	fi
#Fin de gestionAlgoritmoPagAlgPagFrecMFULFUNFU()

#
# Sinopsis: Algoritmo AlgPagFrecMRULRUNRU - NRU usará un límite máximo del tiempo que hace que se usaron las páginas por última vez (seleccionAlgoritmoPaginacion_uso_rec_valor)
#
#ResuUsoRecienteAcumulado 
#Se inicializan los arrays que se van a usar temporalmente para cada proceso en ejecución.
#Contiene el ordinal del número de marco de cada proceso.
#Se van a determinar los marcos reales que usa cada proceso.
		ordinal[$counter]=0
	done
echo "444444444444 - 1"
#El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
# Se buscan los marcos ocupados por cada proceso
			relacionMarcosUsados[${unidMemOcupadas[$ii]},$reloj,${ordinal[${unidMemOcupadas[$ii]}]}]=$ii
			ordinal[${unidMemOcupadas[$ii]}]=$((${ordinal[${unidMemOcupadas[$ii]}]} + 1))
        fi
	done
echo "444444444444 - 2"
#Se crea la secuencia de páginas en memoria de cada proceso.
		paginasEnMemoriaProceso[$v]=${paginasEnMemoriaTotal[$ejecutandoinst,$v]}
	done 
#Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
echo "444444444444 - 3"
#Se crea la secuencia de páginas de cada proceso pendientes de ejecutar.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasPendientesUsarTotal[$ejecutandoinst,$v]=$pagina
	done
#Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
echo "444444444444 - 4"
#Se crea la secuencia de páginas de cada proceso ya ejecutadas.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasUsadasTotal[$ejecutandoinst,$v]=$pagina
#No es necesario ya que paginasUsadasTotal[] se genera en cada ejecución de la función.
	done 
echo "444444444444 - 5"
#Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Óptimo
#Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				fi
#NFU con clases sobre MFU/LFU
#Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				fi
			done
		fi
	done
	
echo "444444444444 - 6"
#Se crea la secuencia de páginas en memoria de cada proceso.
		indPagIni=$((${numeroPaginasUsadasProceso[$ejecutandoinst]}))
		if [[ $indPagIni -eq 0 ]]; then
#Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_uso_rec_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		else
#Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_uso_rec_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		fi
	done 
echo "444444444444 - 7"
#Se actualizan los valores del tiempo que falta para ejecutarse una página de cada proceso, salvo si es 0, ya que en ese caso, no se volverá a encontrar en la sucesión de páginas pendientes del proceso.
		if [[ ${primerTiempoEntradaPagina[$ejecutandoinst,$indMarco]} -gt 0 ]]; then
#Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3, o al máximo de frecuencia de uso.
		fi
	done 

echo "3333333333333 - 8"
#Si aún quedan páginas por ejecutar de ese proceso.
#Se determina la primera página de la secuencia de páginas pendientes.
#Número de páginas usadas en el proceso en ejecución. Aumenta en todas las unidades de ejecución del proceso. 
#Siguiente página, pendiente de ejecutar.
#Si el número de marcos usados es menor que el tamaño de la memoria asociada al proceso.
#Define si encuentra o no la página en paginasEnMemoriaProceso
#Localiza en qué posición encuentra la página en paginasEnMemoriaProceso (da la posición, pero no la variable en el array).
#Esta línea es para cuando usamos la posición del dato y no su valor. Si la página está en memoria define x=1.
					x=1
# Se guarda el marco en el que se encuentra la página.
				fi 
			done
#USO DE PÁGINA - Si la página está en memoria, y si no es la primera página a usar para evitar la inicialización de la variable paginasEnMemoriaTotal[$ejecutandoinst,ordinal}] a 0.
echo "3333333333333 - 2"
#Se van a tratar las variables que no se corresponden con el marco usado.
#El tiempo desde que se usó una página en memoria aumenta en cada unidad de tiempo de ejecución del proceso, siempre que no sea la que se usa, o sobre la que se produce el fallo de paginación. 
					if [[ $indMarcoRec -ne $indMarcoMem ]]; then
#Óptimo 
#Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#MFU/LFU. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#NFU-MFU/NFU-LFU
#Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							else
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$seleccionAlgoritmoPaginacion_uso_rec_valor
							fi
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#NFU-MFU/NFU-LFU con clases. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
#Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
							else
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$seleccionAlgoritmoPaginacion_clases_uso_rec_valor
							fi 
						fi
					fi
					if [[ $indMarcoRec -eq $indMarcoMem ]]; then
#Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#Óptimo
#Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
#Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Resumen - Índices: (proceso, marco). Dato: Histórico con el valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
						fi
					fi
				done
#Ahora se definirán las variables que se corresponden con el marco usado. 
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#0 por haber sido usado.
#NFU-MFU/NFU-LFU con clases
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarcoMem]=1
					ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoMem]=0
#Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#Si las páginas tienen una frecuencia de uso mayor que la frecuencia máxima $seleccionAlgoritmoPaginacion_clases_uso_rec_valor
				fi
									
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se ejecuta este proceso. También se usa para las frecuencias.
#Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0. 
				fi
#NFU con clases sobre MFU/LFU
#Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
				fi
			
#Si NO está en memoria... FALLO DE PÁGINA
echo "3333333333333 - 3"
#Aumenta en 1 el número de marcos usados. Sólo aumenta cuando se usa un nuevo marco y no en todas las unidades de ejecución del proceso. Debe ser la última línea dentro del if paradejarlo preparado para su siguiente uso como variable.
#Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). Sería -1 porque numeroMarcosUsados empieza a contar en 1.
#Se van a tratar las variables que no se corresponden con el marco usado.
#El tiempo desde que se usó una página en memoria aumenta en cada unidad de tiempo de ejecución del proceso, siempre que no sea la que se usa, o sobre la que se produce el fallo de paginación. 
					if [[ $indMarcoRec -ne ResuPunteroMarcoUsado[$ejecutandoinst,$reloj] ]]; then
#Óptimo
#Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#MFU/LFU. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#NFU-MFU/NFU-LFU
#Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							else
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$seleccionAlgoritmoPaginacion_uso_rec_valor
							fi
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#NFU-MFU/NFU-LFU con clases. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
#Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
							else
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$seleccionAlgoritmoPaginacion_clases_uso_rec_valor
							fi
						fi
					fi
					if [[ $indMarcoRec -eq ${ResuPunteroMarcoUsado[$ejecutandoinst,$reloj]} ]]; then
#Óptimo
#Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
							
#Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Resumen - Índices: (proceso, marco). Dato: Histórico con el valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
						fi
					fi
				done
#Ahora se definirán el resto de variables que se corresponden con el marco usado. 
#... la página se añade a la secuencia de páginas del proceso en ejecución en memoria.
#... y la página se añade a la secuencia de páginas de ese proceso junto con el resto de páginas del resto de procesos residentes en memoria (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#Contador de fallos de página totales de cada proceso.
#Contador de fallos totales de cada proceso
#Se añade el dato de la página que acaba de ser incluida en un marco.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
# Se añade el dato de la frecuencia de la página que acaba de ser incluida en un marco.
#Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Y se añade la página a la secuencia de fallos. 
#Y se añade el marco a la secuencia de fallos. 
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
				directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))]=0
#Sólo es necesario si se llenan todos los marcos asociados al proceso. 
#MFU
#Se recalcula el siguiente uso de la página utilizada más alejado en el tiempo.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
							fi
#Y sobre esa localización se hace el fallo de página
#MFU
#Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
							fi
#Y sobre esa localización se hace el fallo de página
#NFU con clases sobre MFU
#Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
#QUEDA PENDIENTE USARLO PARA RESTAR LA FRECUENCIA ACTUAL DE LA QUE TENÍA EN AQUEL MOMENTO.
						else
							limite_j=0
						fi
#Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#LFU
#Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#Localiza en qué posición encuentra la página.
#Menor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
							fi
#Y sobre esa localización se hace el fallo de página					
#NFU con clases sobre MFU
#Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					fi
				fi
#Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#Suma 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres. 
				else
#MFU
#El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#LFU
#El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
					fi
				fi
			fi

#Si el número de marcos usados es mayor o igual que el tamaño de la memoria asociada al proceso.
#Define si encuentra o no la página en paginasEnMemoriaProceso.
#Localiza en qué posición encuentra la página (da la posición pero no la variable en el array).
#Si la página está en memoria define x=1.
					x=1
				fi 
			done
#Si la página está en memoria...USO DE PÁGINA
echo "3333333333333 - 4"
#Localiza en qué posición encuentra la página (da la posición pero no la variable en el array).
					if [[ ${paginasEnMemoriaProceso[$indMarcoMem]} -eq $primera_pagina ]]; then
#Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#Se van a tratar las variables que no se corresponden con el marco usado.
#El tiempo desde que se usó una página en memoria aumenta en cada unidad de tiempo de ejecución del proceso, siempre que no sea la que se usa, o sobre la que se produce el fallo de paginación. 
							if [[ $indMarcoRec -ne ResuPunteroMarcoUsado[$ejecutandoinst,$reloj] ]]; then
#Óptimo
#Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.

#Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Resumen - Índices: (proceso, marco). Dato: Histórico con el valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación

#MFU/LFU. Sin máximo de tiempo desde que se usó por última vez.
									ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
									ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#NFU-MFU/NFU-LFU
#Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
										ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
									else
										ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$seleccionAlgoritmoPaginacion_uso_rec_valor
									fi
									ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#NFU-MFU/NFU-LFU con clases. Sin máximo de tiempo desde que se usó por última vez.
									ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
#Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
										ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
									else
										ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$seleccionAlgoritmoPaginacion_clases_uso_rec_valor
									fi
								fi
							fi
							if [[ $indMarcoRec -eq ResuPunteroMarcoUsado[$ejecutandoinst,$reloj] ]]; then
#Óptimo
#Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.

									ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
								fi
							fi							
						done
#Ahora se definirán las variables que se corresponden con el marco usado. 
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#MFU/LFU
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
#NFU-MFU/NFU-LFU
							if [[ ${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,${indiceResuPaginaAcumulado[$ejecutandoinst]}]} -lt $seleccionAlgoritmoPaginacion_uso_rec_valor ]]; then 
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
							else
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
							fi
#NFU-MFU/NFU-LFU con clases
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
							directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarcoMem]=1
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoMem]=0
#Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#Si las páginas tienen una frecuencia de uso mayor que la frecuencia máxima $seleccionAlgoritmoPaginacion_clases_uso_rec_valor
#Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
						fi
#MFU
#Se recalcula el siguiente uso de la página utilizada más alejado en el tiempo.
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
								fi
#Y sobre esa localización se hace el fallo de página
#El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#MFU
#Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
								fi
#Y sobre esa localización se hace el fallo de página
#El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
				
#NFU con clases sobre MFU
#Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
							paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
								limite_j=$ultimasPaginasAConsiderar
							else
								limite_j=0
							fi
#Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#LFU
#Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
							min_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#Localiza en qué posición encuentra la página.
#Menor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
								fi
#Y sobre esa localización se hace el fallo de página
#El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
#NFU con clases sobre MFU
#Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
							min_AlgPagFrecRec_Position[$ejecutandoinst]=0
							ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
							paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
								limite_j=$ultimasPaginasAConsiderar
							else
								limite_j=0
							fi
#Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
						fi
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
					fi
				done

#Y si NO está en la memoria...FALLO DE PÁGINA. Se localiza el que tenga el primer valor del mayor contador de frecuencia por ser AlgPagFrecMFU.
echo "3333333333333 - 5"
#MFU
#Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#Se hace el fallo de página sobre el primer marco con la mayor frecuencia, sustituyendo la página.
#Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#LFU
#Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#Se hace el fallo de página sobre el primer marco con la menor frecuencia, sustituyendo la página.
#Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#NFU con clases sobre MFU
#Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#Se hace el fallo de página sobre el primer marco con la mayor frecuencia, sustituyendo la página.
#Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,${max_AlgPagFrecRec_Position[$ejecutandoinst]}]=0
				
#NFU con clases sobre MFU
#Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#Se hace el fallo de página sobre el primer marco con la menor frecuencia, sustituyendo la página.
#Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,${min_AlgPagFrecRec_Position[$ejecutandoinst]}]=0
				fi
#Se van a tratar las variables que no se corresponden con el marco usado.
#El tiempo desde que se usó una página en memoria aumenta en cada unidad de tiempo de ejecución del proceso, siempre que no sea la que se usa, o sobre la que se produce el fallo de paginación. 
					if [[ $indMarcoRec -ne ${ResuPunteroMarcoUsado[$ejecutandoinst,$reloj]} ]]; then
#Óptimo
#Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))

#MFU/LFU. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#NFU-MFU/NFU-LFU
#Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							else
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$seleccionAlgoritmoPaginacion_uso_rec_valor
							fi
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#NFU-MFU/NFU-LFU con clases. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
#Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
							else
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$seleccionAlgoritmoPaginacion_clases_uso_rec_valor
							fi
						fi
					fi
					if [[ $indMarcoRec -eq ${ResuPunteroMarcoUsado[$ejecutandoinst,$reloj]}  ]]; then
#Óptimo
#Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.

#Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Resumen - Índices: (proceso, marco). Dato: Histórico con el valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
# Se añade el dato de la página que acaba de ser incluida en un marco.
						fi
					fi					
				done
#Ahora se definirán las variables que se corresponden con el marco usado. 
#Aumenta en una unidad el número de fallos de página del proceso.
#Contador de fallos totales de cada proceso
#MFU
# Se añade el dato de la página que acaba de ser incluida en un marco.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página. 
#Y se añade la página a la secuencia de fallos. 
#Y se añade el marco a la secuencia de fallos. 
#NFU-MFU con clases					
#Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
#Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					else
#Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
							fi
#Y sobre esa localización se hace el fallo de página.
					fi
#El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#LFU
# Se añade el dato de la página que acaba de ser incluida en un marco.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página. 
#Y se añade la página a la secuencia de fallos. 
#Y se añade el marco a la secuencia de fallos. 
#NFU-LFU con clases
#Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
#Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					else
#Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
							fi
#Y sobre esa localización se hace el fallo de página.
					fi
#El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
				fi
#Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
			fi
		fi          
	
#Y si no quedan más páginas pendientes de ejecutar. No es tiempoEjecucion sino temp_rej.
echo "3333333333333 - 6"
		for (( counter=0; counter<$nprocesos; counter++ )); do
#Para ser equivalente al nuevo programa. Se aconseja quitar la variable $ord y estandarizar las variables a usar ??????????.
#??????????? NO PUEDE ESTAR BIEN...Ni el timpo de retorno, porque puede llegar pero no entrar en memoria,  ni el tiempo de espera por la misma razón, ni resta[$ejecutandoinst]=$((tiempo[$ejecutandoinst].... porque tiempo[] no existe
#Como temp_ret(). Se aconseja quitar la variable $retorno y estandarizar las variables a usar ??????????.
#Como temp_ret(). Se aconseja quitar la variable $retorno y estandarizar las variables a usar ??????????.
				if [[ ! " ${ejecutando[*]} " == *" $ejecutandoinst "* ]]; then
#Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
					if [[ " ${haestadopausado[*]} " == *" $ejecutandoinst "* ]]; then
#Esa resta debería ser alrevés, el de ejecución menos lo ya ejecutado...
#Tampoco es (reloj - llegada[$ejecutandoinst]).
					fi
#Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
				fi
			fi
		done
#Actualización de variables y cambios de estado. Algunos ya se hacen en ajusteFinalTiemposEsperaEjecucionRestante().
#Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
		ejecutando="" 
		finalizados+=("$finalizado")
		finalizadonuevo+=("$finalizado")
		hanestadomem=$paginasEnMemoriaProceso
#De momento se cambia ordenados por llegada.
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array).
				if [[ "${enmemoria[$i]}" == "$finalizado" ]]; then
					posicion_finalizado=$i
					unset 'enmemoria[$posicion_finalizado]'
					unset 'llegados[$posicion_finalizado]'
					unset 'enpausa[$posicion_finalizado]'
					unset 'prioridades[$posicion_finalizado]'
					memvacia=$((memvacia + ${memoria[$finalizado]}))
				fi
			done
		fi
echo "3333333333333 - 7"
	fi
#Fin de gestionAlgoritmoPagAlgPagRecMRULRUNRU()

#
# Sinopsis: Se calculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas.
#
function calcularResuTiempoOptimoAcumulado_PaginaEjecutada { 
	varCierreOptimo=0
	indOptimo=$((${numeroPaginasUsadasProceso[$ejecutandoinst]}))
	until [[ $varCierreOptimo -eq 1 ]]; do 
#Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
			if [[ ${paginasDefinidasTotal[$ejecutandoinst,$indOptimo]} -eq $primera_pagina ]]; then
#Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				varCierreOptimo=1
			fi
		else
#Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
			varCierreOptimo=1
		fi
		indOptimo=$(($indOptimo + 1)) 
	done
}

#
# Sinopsis: Se calculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas.
#
function calcularResuTiempoOptimoAcumulado_PaginaNoEjecutada { 
	varCierreOptimo=0
#	indOptimo=$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))
	indOptimo=$((${numeroPaginasUsadasProceso[$ejecutandoinst]}))
	until [[ $varCierreOptimo -eq 1 ]]; do 
#Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
			if [[ ${paginasDefinidasTotal[$ejecutandoinst,$indOptimo]} -eq ${paginasEnMemoriaProceso[$indMarcoRec]} ]]; then
#Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				varCierreOptimo=1
			fi
		else
#Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
			varCierreOptimo=1
		fi
		indOptimo=$(($indOptimo + 1)) 
	done
}

#
# Sinopsis: Se calculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas.
#
function gestionAlgoritmoPagAlgPagRecNRU_Referenciado_Modificado { 
#Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_clases_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		tiempoPag=$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))
#Con cambio de página por fallo de página ($usoMismaPagina=1) y, por tanto, sólo para esa página. El fallo sobre un marco sólo puede producir clases 0 o 1.
#Se define como página usada o modificada	
#Se reinicia la clase a NO referenciada-NO modificada para recalcular después la clase correcta.
#Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#NO referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
			fi
		fi

#Con cambio de página por fallo de página ($usoMismaPagina=1), pero sin actuar sobre la página tratada, ya que se deben actualizar las clases de todas las páginas. El fallo sobre otro marco sólo puede producir un aumento en el tiempo ordinal que hace que se cambió la clase, por lo que podría pasar de clase 2 a 0, o de 3 a 1.
#Se define como página no usada ni modificada	
			if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#Si lleva mucho tiempo como clase 3, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			fi
		fi

#Con uso de página, pero sin cambio por fallo de página ($usoMismaPagina=0), ya que se deben actualizar las clases de todas las páginas.
#Se define como página usada o modificada	
			if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#Referencia a una página ya ejecutada en una unidad de reloj anterior, dato copiado en todas las páginas de una unidad de tiempo a la siguiente, antes de analizar lo que ocurrirá en el tiempo actual. 
#NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				fi
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
				if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$1,$(($tiempoPag - 1))]} -eq 0 ]]; then 
#NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				fi
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#Referencia a una página ya ejecutada en una unidad de reloj anterior, dato copiado en todas las páginas de una unidad de tiempo a la siguiente, antes de analizar lo que ocurrirá en el tiempo actual. 
#NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$1,$(($tiempoPag - 1))]} -eq 1 ]]; then 
#NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				fi
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
				if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$1,$(($tiempoPag - 1))]} -eq 0 ]]; then 
#SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$1,$(($tiempoPag - 1))]} -eq 1 ]]; then 
#SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#Si ya era de clase 3 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#Si lleva mucho tiempo como clase 3, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				fi
			fi 
		fi
		
#Con uso, pero sin cambio de página ($usoMismaPagina=1), ya que se deben actualizar las clases de todas las páginas.
#Se define como página no usada ni modificada	
			if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#Si lleva mucho tiempo como clase 3, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			fi
		fi
#Si el tiempo ordinal de una página en una clase 2 o 3 en los últimos instantes (intervalo de tiempo) es superior al límite ($seleccionAlgoritmoPaginacion_clases_valor) se modifica a "no referenciado" y luego se calcula la nueva clase.
# se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor. Si lo supera se comprueba que no sea en la misma clase 2 o 3.
#Si ya era de clase 2 se pasa a clase 0.
#Si lleva mucho tiempo como clase 2, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			fi
#Si ya era de clase 3 se pasa a clase 1.
#Si lleva mucho tiempo como clase 2, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			fi
		fi
#		echo ""
    done
#Fin de gestionAlgoritmoPagAlgPagRecNRU_Referenciado_Modificado()

#
# Sinopsis: Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#
function gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Max_Prueba { 
	for (( indMaxPrueba=0; indMaxPrueba<${memoria[$ejecutandoinst]}; indMaxPrueba++ )); do
#Localiza en qué posición encuentra la página.
#Mayor antigüedad de uso encontrada.
#Posición del marco con la mayor antigüedad de uso.
		fi
#Y sobre esa localización se hace el fallo de página.
}

#
# Sinopsis: Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#
function gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Max {  
#Para determinar si hay alguna página de clase 0, y de no ser así, de clase 1,...
	xxx_1=0
	xxx_2=0
	xxx_3=0
#Mayor frecuencia encontrada en las páginas de clase 0.
#Mayor frecuencia encontrada en las páginas de clase 1.
#Mayor frecuencia encontrada en las páginas de clase 2.
#Mayor frecuencia encontrada en las páginas de clase 3.
#Posición del marco con la mayor frecuencia en las páginas de clase 0.
#Posición del marco con la mayor frecuencia en las páginas de clase 1.
#Posición del marco con la mayor frecuencia en las páginas de clase 2.
#Posición del marco con la mayor frecuencia en las páginas de clase 3.

#Se calculan los max para las 4 clases
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
		if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMax,$punteroPagMarco]} -eq 0 ]]; then
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
#Sólo se marca en caso de que haya cambio de max. De no ser así, no se marca y tampoco se cambia la variable max_AlgPagFrecRec_FrecRec ni max_AlgPagFrecRec_Position
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMax,$punteroPagMarco]} -eq 1 ]]; then
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
				xxx_1=1
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMax,$punteroPagMarco]} -eq 2 ]]; then
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
				xxx_2=1
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMax,$punteroPagMarco]} -eq 3 ]]; then
#Localiza en qué posición encuentra la página.
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
				xxx_3=1
			fi
		fi
#Y sobre esa localización se hace el fallo de página
	if [[ $xxx_0 -eq 1 && $xxx_1 -eq 0 && $xxx_2 -eq 0 && $xxx_3 -eq 0 ]]; then
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
	elif [[ $xxx_1 -eq 1 && $xxx_2 -eq 0 && $xxx_3 -eq 0 ]]; then
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
	elif [[ $xxx_2 -eq 1 && $xxx_3 -eq 0 ]]; then
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
	elif [[ $xxx_3 -eq 1 ]]; then
#Mayor frecuencia encontrada.
#Posición del marco con la mayor frecuencia.
	fi
#Fin de gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Max() 

#
# Sinopsis: Se calcula el mínimo de las frecuencias de las páginas de cada proceso en NFU (min_AlgPagFrecRec_FrecRec y min_AlgPagFrecRec_Position), por clases empezando por 0.
#
function gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Min_Prueba { 
	for (( indMinPrueba=0; indMinPrueba<${memoria[$ejecutandoinst]}; indMinPrueba++ )); do
#Localiza en qué posición encuentra la página.
#Mayor antigüedad de uso encontrada.
#Posición del marco con la menor antigüedad de uso.
		fi
	done
}

#
# Sinopsis: Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#
function gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Min {  
#Para determinar si hay alguna página de clase 0, y de no ser así, de clase 1,...
	xxx_1=0
	xxx_2=0
	xxx_3=0
#Menor frecuencia encontrada en las páginas de clase 0.
#Menor frecuencia encontrada en las páginas de clase 1.
#Menor frecuencia encontrada en las páginas de clase 2.
#Menor frecuencia encontrada en las páginas de clase 3.
#Posición del marco con la menor frecuencia en las páginas de clase 0.
#Posición del marco con la menor frecuencia en las páginas de clase 1.
#Posición del marco con la menor frecuencia en las páginas de clase 2.
#Posición del marco con la menor frecuencia en las páginas de clase 3.

#Se calculan los min para las 4 clases
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
		if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMin,$punteroPagMarco]} -eq 0 ]]; then
			if [[ $min_AlgPagFrecRec_FrecRec_0 -eq -1 ]]; then
				min_AlgPagFrecRec_FrecRec_0=${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMin]}
				min_AlgPagFrecRec_Position_0=$indMin
#Sólo se marca en caso de que haya cambio de min. De no ser así, no se marca y tampoco se cambia la variable min_AlgPagFrecRec_FrecRec ni min_AlgPagFrecRec_Position
			fi
#Localiza en qué posición encuentra la página.
#Menor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMin,$punteroPagMarco]} -eq 1 ]]; then
			if [[ $min_AlgPagFrecRec_FrecRec_1 -eq -1 ]]; then
				min_AlgPagFrecRec_FrecRec_1=${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMin]}
				min_AlgPagFrecRec_Position_1=$indMin
				xxx_1=1
			fi
#Localiza en qué posición encuentra la página.
#Menor frecuencia encontrada.
#Posición del menor con la mayor frecuencia.
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMin,$punteroPagMarco]} -eq 2 ]]; then
			if [[ $min_AlgPagFrecRec_FrecRec_2 -eq -1 ]]; then
				min_AlgPagFrecRec_FrecRec_2=${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMin]}
				min_AlgPagFrecRec_Position_2=$indMin
				xxx_2=1
			fi
#Localiza en qué posición encuentra la página.
#Menor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMin,$punteroPagMarco]} -eq 3 ]]; then
			if [[ $min_AlgPagFrecRec_FrecRec_3 -eq -1 ]]; then
				min_AlgPagFrecRec_FrecRec_3=${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMin]}
				min_AlgPagFrecRec_Position_3=$indMin
				xxx_3=1
			fi
#Localiza en qué posición encuentra la página.
#Menor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
			fi
		fi
#Y sobre esa localización se hace el fallo de página
	if [[ $xxx_0 -eq 1 && $xxx_1 -eq 0 && $xxx_2 -eq 0 && $xxx_3 -eq 0 ]]; then
#Menor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
	elif [[ $xxx_1 -eq 1 && $xxx_2 -eq 0 && $xxx_3 -eq 0 ]]; then
#Menor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
	elif [[ $xxx_2 -eq 1 && $xxx_3 -eq 0 ]]; then
#Menor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
	elif [[ $xxx_3 -eq 1 ]]; then
#Menor frecuencia encontrada.
#Posición del marco con la menor frecuencia.
	fi

#Fin de gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Min() 

#
# Sinopsis: Impresión pantalla tras la solicitud de datos/introducción desde fichero
#
function dibujaDatosPantallaFCFS_SJF_SRPT_RR {
#...color
    echo -e " ┌───────────────┬───────────────┬───────────────┬───────────────┐" | tee -a $informeConColorTotal 
    echo -e " │    Proceso$NC    │  T.Llegada$NC    │  T.Ejecución$NC  │    Tamaño$NC     │" | tee -a $informeConColorTotal 
    echo -e " └───────────────┴───────────────┴───────────────┴───────────────┘" | tee -a $informeConColorTotal 
    for (( i=0; i<$nprocesos; i++)); do
        echo -e "${coloress[$i % 6]} \t${proceso[$i]}\t \t${entradaAuxiliar[$i]}\t \t${ejecucion[$i]}\t \t${memoriaAuxiliar[$i]}\t  $NC" | tee -a $informeConColorTotal
    done 
    echo -e "\n\n Memoria total: $mem_libre uds." | tee -a $informeConColorTotal
#Se ejecuta cuando la selección inicial es por ejecución automática repetitiva. Se guardan todos los datos, aún cuando no es por Round-Robin.
		echo " Tamaño a partir del cual se reubica: $variableReubicar uds." | tee -a $informeConColorTotal 
	fi
#Se ejecuta cuando la selección inicial es por ejecución automática repetitiva. Se guardan todos los datos, aún cuando no es por Round-Robin.
		echo " Quantum de tiempo para Round-Robin (RR): $quantum" | tee -a $informeConColorTotal 
	fi
    echo " ---------------------------------------------" | tee -a $informeConColorTotal 
   
#...b/n
    echo -e " ┌───────────────┬───────────────┬───────────────┬───────────────┐" >> $informeSinColorTotal
    echo -e " │    Proceso    │  T.Llegada    │  T.Ejecución  │    Tamaño     │" >> $informeSinColorTotal
    echo -e " └───────────────┴───────────────┴───────────────┴───────────────┘" >> $informeSinColorTotal
    for (( i=0; i<$nprocesos; i++)); do
        echo -e " \t${proceso[$i]}\t \t${entradaAuxiliar[$i]}\t \t${ejecucion[$i]}\t \t${memoriaAuxiliar[$i]}\t  " >> $informeSinColorTotal
    done
    echo -e "\n\n Memoria total: $mem_libre uds." >> $informeSinColorTotal
#Se ejecuta cuando la selección inicial es por ejecución automática repetitiva. Se guardan todos los datos, aún cuando no es por Round-Robin.
		echo -e " Tamaño a partir del cual se reubica: $variableReubicar uds." >> $informeSinColorTotal
	fi
#Se ejecuta cuando la selección inicial es por ejecución automática repetitiva. Se guardan todos los datos, aún cuando no es por Round-Robin.
		echo -e " Quantum de tiempo para Round-Robin (RR): $quantum uds." >> $informeSinColorTotal
	fi
    echo -e  " ---------------------------------------------" >> $informeSinColorTotal
#No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -e "\n$NC Pulse enter para continuar..." | tee -a $informeConColorTotal
		echo -e "\n Pulse enter para continuar..." >> $informeSinColorTotal
		read enter
		echo -e $enter "\n" >> $informeConColorTotal
		echo -e $enter "\n" >> $informeSinColorTotal
	fi
#    clear
}

#
# Sinopsis: Muestra un resumen inicial ordenado por tiempo de llegada de todos los procesos introducidos.
#
function dibujaDatosPantallaPrioridad {
#	ordenacion
#Se ordenan los datos sacados desde $ficheroParaLectura o a medida que se van itroduciendo, por tiempo de llegada. 
#...color
    echo -e " ┌───────────────┬───────────────┬───────────────┬───────────────┬───────────────┐" | tee -a $informeConColorTotal 
    echo -e " │    Proceso$NC    │  T.Llegada$NC    │  T.Ejecución$NC  │    Tamaño$NC     │   Prioridad$NC   │" | tee -a $informeConColorTotal 
    echo -e " └───────────────┴───────────────┴───────────────┴───────────────┴───────────────┘" | tee -a $informeConColorTotal 
    for (( i=0; i<$nprocesos; i++)); do
        echo -e "${coloress[$i % 6]} \t${proceso[$i]}\t \t${entradaAuxiliar[$i]}\t \t${ejecucion[$i]}\t \t${memoriaAuxiliar[$i]}\t \t${prioProc[$i]}\t  $NC" | tee -a $informeConColorTotal
    done
    echo -e "\n\n Memoria total: $mem_libre uds." | tee -a $informeConColorTotal
    echo " Tamaño a partir del cual se reubica: $variableReubicar uds." | tee -a $informeConColorTotal 
    echo " ---------------------------------------------" | tee -a $informeConColorTotal 
   
#...b/n
    echo -e " ┌───────────────┬───────────────┬───────────────┬───────────────┬───────────────┐" >> $informeSinColorTotal
    echo -e " │    Proceso    │  T.Llegada    │  T.Ejecución  │    Tamaño     │   Prioridad   │" >> $informeSinColorTotal
    echo -e " └───────────────┴───────────────┴───────────────┴───────────────┴───────────────┘" >> $informeSinColorTotal
    for (( i=0; i<$nprocesos; i++)); do
        echo -e " \t${proceso[$i]}\t \t${entradaAuxiliar[$i]}\t \t${ejecucion[$i]}\t \t${memoriaAuxiliar[$i]}\t \t${prioProc[$i]}\t  " >> $informeSinColorTotal
    done
    echo -e "\n\n Memoria total: $mem_libre uds." >> $informeSinColorTotal
    echo -e " Tamaño a partir del cual se reubica: $variableReubicar uds." >> $informeSinColorTotal
    echo -e  " ---------------------------------------------" >> $informeSinColorTotal
#No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -e "\n$NC Pulse enter para continuar..." | tee -a $informeConColorTotal
		echo -e "\n Pulse enter para continuar..." >> $informeSinColorTotal
		read enter
		echo -e $enter "\n" >> $informeConColorTotal
		echo -e $enter "\n" >> $informeSinColorTotal
	fi
#    clear
#Fin de imprimeprocesosresumen

#
# Sinopsis: Genera la Banda de Memoria y la muestra en pantalla/informe 
#
function dibujaResumenBandaMemoriaMarcosPagina { 
#Ancho del terminal para adecuar el ancho de líneas a cada volcado
#Para poder incluir -clase en la página. Se restan 3 porque previamente se ha añadido la logitud $digitosUnidad, y ya venía incluido.
#Desde 0, es el ordinal del número de marcos en memoria asociados a cada proceso (Índices:Proceso)
		ordinalMarcosProcesoDibujados[$indProc]=-1	
	done
    echo ""
#Se inicializan las variables.
	AlgPagFrecUsoRecNotas1=();
	AlgPagFrecUsoRecNotas2=();
	filaAlgPagFrecUsoRecTituloColor=""
	filaAlgPagFrecUsoRecTituloBN=""
	filaAlgPagFrecUsoRecNotas1Color=""
	filaAlgPagFrecUsoRecNotas1BN=""
	
#Si hay algún proceso en memoria. ResuUsoRecienteAcumulado
		AlgPagFrecUsoRecTitulo=" Resumen de los Marcos/Páginas-Clase/Estadísticas de Frecuencia de Uso/Estadísticas de Antigüedad de Uso de todos los procesos en memoria en la unidad de tiempo actual (reloj:"$reloj")."
		filaAlgPagFrecUsoRecTituloColor=`echo -e "$NORMAL$AlgPagFrecUsoRecTitulo$NORMAL "`
		filaAlgPagFrecUsoRecTituloBN=`echo -e "$AlgPagFrecUsoRecTitulo "`
		if [[ $seleccionAlgoritmoPaginacion -eq 0 ]]; then
			AlgPagFrecUsoRecNotas1=" Se muestra: Pág.: página ; Frec.:Frecuencia de uso total registrada."
			AlgPagFrecUsoRecNotas2=" Interpretación: Fondo de color-Uso del marco."
		elif [[ $seleccionAlgoritmoPaginacion -eq 1 || $seleccionAlgoritmoPaginacion -eq 3 ]]; then
			AlgPagFrecUsoRecNotas1=" Se muestra: Pág.: página ; Frec.:Frecuencia de uso total registrada."
			AlgPagFrecUsoRecNotas2=" Interpretación: Subrayado-Siguiente fallo ; Fondo de color-Uso del marco ; Negrita-Fallo de Paginación (Marco-F)."
		elif [[ $seleccionAlgoritmoPaginacion -eq 2 || $seleccionAlgoritmoPaginacion -eq 4 ]]; then
			AlgPagFrecUsoRecNotas1=" Se muestra: Pág.: página-Coeficiente M ; Frec.:Frecuencia de uso total registrada."
			AlgPagFrecUsoRecNotas2=" Interpretación: Subrayado-Siguiente fallo ; Fondo de color-Uso del marco ; Negrita-Fallo de Paginación (Marco-F)."
		elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
			AlgPagFrecUsoRecNotas1=" Se muestra: Pág.: página-Tiempo hasta un nuevo uso ; UsoRec:Antigüedad de uso total registrada."
			AlgPagFrecUsoRecNotas2=" Interpretación: Subrayado-Siguiente fallo ; Fondo de color-Uso del marco ; Negrita-Fallo de Paginación (Marco-F)."
		elif ([[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 9 ]]) || ([[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -eq 15 ]]); then
			AlgPagFrecUsoRecNotas1=" Se muestra: Pág.: página ; Frec.:Frecuencia/Antigüedad de uso total registrada."
			AlgPagFrecUsoRecNotas2=" Interpretación: Subrayado-Siguiente fallo ; Fondo de color-Uso del marco ; Negrita-Fallo de Paginación (Marco-F)."
		elif [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then
			AlgPagFrecUsoRecNotas1=" Se muestra: Pág.: página-clase ; Frec./UsoRec:Frecuencia/Antigüedad de uso total registrada-Frecuencia/Antigüedad de uso en el intervalo-Antigüedad de la clase 2 o 3 en el intervalo."
			AlgPagFrecUsoRecNotas2=" Interpretación: Subrayado-Siguiente fallo ; Fondo de color-Uso del marco ; Negrita-Fallo de Paginación (Marco-F)."
		fi
		filaAlgPagFrecUsoRecNotas1Color=`echo -e "$NORMAL$AlgPagFrecUsoRecNotas1$NORMAL "`
		filaAlgPagFrecUsoRecNotas1BN=`echo -e "$AlgPagFrecUsoRecNotas1 "`
		filaAlgPagFrecUsoRecNotas2Color=`echo -e "$NORMAL$AlgPagFrecUsoRecNotas2$NORMAL "`
		filaAlgPagFrecUsoRecNotas2BN=`echo -e "$AlgPagFrecUsoRecNotas2 "`
	fi

# GENERACIÓN STRING DE PROCESOS (Línea 1 del Resumen de la Banda de Memoria) 
#Define el número de saltos a realizar.
#Contiene el texto a escribir de las diferentes filas antes de hacer cada salto.
	filamarcosColor[$aux]="$NC Marco  "
	filapagColor[$aux]="$NC Pág.   "
	if ([[ $seleccionAlgoritmoPaginacion -ge 0 && $seleccionAlgoritmoPaginacion -le 4 ]]) || ([[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]); then
		filaAlgPagFrecUsoRecColor[$aux]="$NC Frec.  "
	elif ([[ $seleccionAlgoritmoPaginacion -eq 5 ]]) || ([[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]); then
		filaAlgPagFrecUsoRecColor[$aux]="$NC UsoRec "
	fi
	filaprocesosBN[$aux]=" Proc.  "
	filamarcosBN[$aux]=" Marco  "
	filapagBN[$aux]=" Pág.   "
	if ([[ $seleccionAlgoritmoPaginacion -ge 0 && $seleccionAlgoritmoPaginacion -le 4 ]]) || ([[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]); then
		filaAlgPagFrecUsoRecBN[$aux]="$NC Frec.  "
	elif ([[ $seleccionAlgoritmoPaginacion -eq 5 ]]) || ([[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]); then
		filaAlgPagFrecUsoRecBN[$aux]="$NC UsoRec "
	fi
#Determina el número de procesos al contar el número de datos en la variable memoria.	
#Índice que recorre los procesos del problema
#Determina qué procesos están en memoria.
#Páginas residentes en memoria del Proceso en ejecución. Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#Deja 1 de margen izquierdo y 7 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.

# Variable que indica si se ha añadido un proceso al Resumen de la Banda de Memoria. ${memoria[$procFinalizado]}
    for ((indMem=0;indMem<$mem_total;indMem++)); do
# El proceso se puede imprimir en memoria
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
				filaprocesosColor[$aux]="        "
				filaprocesosBN[$aux]="        "
#Espacio por la izquierda para cuadrar líneas
            fi
# El texto no cabe en la terminal
                xx=0
            fi
# Se añade el proceso a la banda
#proceso[$((${unidMemOcupadas[$indMem]}))]}))}
				filaprocesosBN[$aux]+=`echo -e "${proceso[$((${unidMemOcupadas[$indMem]}))]}""$espaciosfinal "`
				filaprocesosColor[$aux]+=`echo -e "${coloress[${unidMemOcupadas[$indMem]} % 6]}${proceso[$((${unidMemOcupadas[$indMem]}))]}""$NORMAL$espaciosfinal "`
                numCaracteres2=$(($numCaracteres2 + $anchoColumna))
                xx=1
            else
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
                    filaprocesosBN[$aux]="        "
                    filaprocesosColor[$aux]="        "
                    numCaracteres2=8
                fi
                espaciosasteriscofinal="*"${varhuecos:1:$(($anchoColumna - 2))}
                filaprocesosBN[$aux]+=`echo -e "$espaciosasteriscofinal "`
                filaprocesosColor[$aux]+=`echo -e "${coloress[${unidMemOcupadas[$indMem]} % 6]}$espaciosasteriscofinal$NORMAL "`
                numCaracteres2=$(($numCaracteres2 + $anchoColumna))
                if [[ $indMem -ne 0 ]]; then
                    if [[ ${unidMemOcupadas[$((indMem - 1))]} !=  "_" ]]; then
                        if [[ $xx -eq 1 && ${proceso[$((${unidMemOcupadas[$indMem]}))]} != ${proceso[$((${unidMemOcupadas[$((indMem - 1))]}))]} ]]; then
                            xx=0
                        fi
                    fi
                fi
            fi
        else
            xx=0
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
                filaprocesosBN[$aux]="        "
                filaprocesosColor[$aux]="        "
                numCaracteres2=8
            fi
            espaciosguionfinal="-"${varhuecos:1:$(($anchoColumna - 2))}
            filaprocesosBN[$aux]+=`echo -e "$espaciosguionfinal "`
            filaprocesosColor[$aux]+=`echo -e "$NORMAL$espaciosguionfinal "`
            numCaracteres2=$(($numCaracteres2 + $anchoColumna))
		fi
    done

# GENERACIÓN STRING DE MARCOS (Línea 2 del Resumen de Memoria)  
#Define el número de saltos a realizar.
#Deja 1 de margen izquierdo y 7 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
	textoFallo1="M"
	textoFallo2="-F"
	for ((indMem=0;indMem<$mem_total;indMem++)); do
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
			filamarcosColor[$aux]="        "
			filamarcosBN[$aux]="        "
#Espacio por la izquierda para cuadrar líneas
		fi
		if [[ ${unidMemOcupadas[$indMem]} != "_" ]]; then	
#Contendrá el código de subrayado con para subrayar la referencia del marco sobre el que se produciría el siguiente fallo de página.
#Contendrá el código de negrita para la referencia del marco sobre el que se habría producido el fallo de página.
#Ordinal del marco usado (Puntero - De 0 a n) para el Proceso en ejecución en una unidad de Tiempo.
#Negrita - Marcos donde se produjeron Fallos de Página del Proceso en ejecución.
#Marco real correspondiente al ordinal de un marco.
#Marco real correspondiente al ordinal de un marco.
#Si coincide el marco real al ordinal del marco usado, se define el color del fondo. 
				varImprimirSiguiente="\e[4m"
			fi
#Si coincide el marco real al ordinal del marco con fallo, se define el código de negrita. 
				varImprimirFallo="\e[1m"
			fi
#Si ese marco NO será sobre el que se produzca el siguiente fallo de página
#Espacios por defecto. Se quita 1 por la M. 
				filamarcosColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}$varImprimirSiguiente$textoFallo1$indMem$NC$espaciosfinal "`
				filamarcosBN[$aux]+=`echo -e "M$indMem$espaciosfinal "`
#Si el marco será sobre el que se produzca el siguiente fallo de página
#Se quita 1 por la M, y 2 por "-F".
				filamarcosColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}$varImprimirSiguiente$varImprimirFallo$textoFallo1$indMem$textoFallo2$NC$espaciosfinal "`
				filamarcosBN[$aux]+=`echo -e "M$indMem$textoFallo$espaciosfinal "`
			fi 
		else
#Espacios por defecto. Se quita 1 por la M. 
			filamarcosColor[$aux]+=`echo -e $NORMAL"$textoFallo1$indMem$espaciosfinal "`
			filamarcosBN[$aux]+=`echo -e "$textoFallo1$indMem$espaciosfinal "`
		fi 
		numCaracteres2=$(($numCaracteres2 + $anchoColumna))
	done

# GENERACIÓN STRING DE PÁGINAS (Línea 3 del Resumen de la Banda de Memoria)
# Línea de la banda
    numCaracteres2=10
    guionesAMeter=${varguiones:1:$(($anchoColumna - 2))}
    asteriscosAMeter=${varasteriscos:1:$(($anchoColumna - 2))}
    sumaTotalMemoria=0
#Contador que recorrerá el número de marcos asociados a un proceso y determinar el ordinal que le corresponde.
# Variable que indica si se ha añadido un proceso a la banda
    for (( i=0; i<$nprocesos; i++)); do 
#Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
	done
#unidMemOcupadas[$indMem] da el Proceso que ocupa el marco indMem
#Contendrá el ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo.
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
			filapagBN[$aux]="        "
			filapagColor[$aux]="        "
			numCaracteres2=8
		fi
#Contendrá la clase de la página en NFU/NRU con clases.
#Contendrá el coeficiente M de los algoritmos de Segunda Oportunidad.
		espaciosadicionales=0
# El proceso se puede imprimir en memoria
#paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}))}
#Contendrá el color asociado al proceso en ejecución. Con él se establece el color del fondo de la página usada.
#Sólo puede estar siendo usada una página en toda la memmoria y para el proceso en ejecución, y no las páginas de otros procesos en pausa. 
#Ordinal del marco usado (Puntero - De 0 a n) para el Proceso en ejecución en una unidad de Tiempo.
#Marco real correspondiente al ordinal de un marco ($varUsado).
			fi
#Si coincide el marco real al puntero al ordinal del marco usado se define el color del fondo. 
				varImprimirUsado=${colorfondo[${unidMemOcupadas[$indMem]} % 6]}
			fi
#Si no hay página se mete asterisco en BN.
#paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}))}
				filapagBN[$aux]+=`echo -e "${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$espaciosasteriscofinal "`
				filapagColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$espaciosasteriscofinal$NC "`
#Y si hay página se mete espacios y el número.
#FIFO y Reloj con Segunda oportunidad
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso. Se busca el ordinal usado en ese instante porque sería el utilizado para la búsqueda de los coeficientes M en todos los marcos al ser el mayor número.
					datoM="-"${coeficienteSegOp[$ejecutandoinst,${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$punteroPagMarco]}	
#datoM}				

#Óptimo
#Índices: (proceso, marco, reloj).
#dato4}
#Contendrá la clase de la página en NFU/NRU con clases.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Índices: (proceso, marco, número ordinal de la dirección a ejecutar(número de páginas usadas del proceso)).
#dato4}
				fi
#2 por el tamaño de $datos4
#Si el marco NO ha sido usado en el instante actual
					filapagBN[$aux]+=`echo -e "${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$dato4$datoM$espaciosfinal "`
					filapagColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$dato4$datoM$espaciosfinal$NC "`
#Si el marco ha sido usado en el instante actual
					filapagBN[$aux]+=`echo -e "${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$dato4$datoM$espaciosfinal "`
					filapagColor[$aux]+=`echo -e "$NC$varImprimirUsado${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$dato4$datoM$espaciosfinal$NC "`
				fi
			fi
#Número de Marcos con Páginas ya dibujadas de cada Proceso.
            numCaracteres2=$(($numCaracteres2 + $anchoColumna))
            if [[ $indMem -ne 0 ]]; then
                if [[ ${unidMemOcupadas[$((indMem - 1))]} !=  "_" ]]; then 
                    if [[ $xx -eq 1 && ${proceso[$((${unidMemOcupadas[$indMem]}))]} != ${proceso[$((${unidMemOcupadas[$((indMem - 1))]}))]} ]]; then
                        xx=0
                    fi
                fi
            fi
#Sin proceso asignado al marco 
            xx=0
#paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}))}
            filapagBN[$aux]+=`echo -e "$espaciosguionfinal "`
            filapagColor[$aux]+=`echo -e "$NC$espaciosguionfinal$NC "`
            numCaracteres2=$(($numCaracteres2 + $anchoColumna))
        fi
#Aumenta el contador de marcos (ordinal de marcos distinto para cada proceso=
    done

# GENERACIÓN STRING DE FRECUENCIA/USO RECIENTE DE USO DE LAS PÁGINAS (Línea 4 del Resumen de la Banda de Memoria)  
# Línea de la frecuencia
    numCaracteres2=10
    guionesAMeter=${varguiones:1:$(($anchoColumna - 2))}
    asteriscosAMeter=${varasteriscos:1:$(($anchoColumna - 2))}
    sumaTotalMemoria=0
# Variable que indica si se ha añadido un proceso a la banda
    for (( i=0; i<$nprocesos; i++)); do 
#Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
	done			
    for ((indMem=0;indMem<$mem_total;indMem++)); do
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
			filaAlgPagFrecUsoRecBN[$aux]="        "
			filaAlgPagFrecUsoRecColor[$aux]="        "
			numCaracteres2=8
		fi
# El proceso se puede imprimir en memoria
#Si no hay página se mete asterisco por ser frecuencia 0.
				espaciosasteriscofinal="*"${varhuecos:1:$(($anchoColumna - 2))}
				filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "$espaciosasteriscofinal "`
				filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}$espaciosasteriscofinal$NC "`
#Y si hay página se mete espacios y el número.
				dato5=""
				dato6=""
				espaciosadicionales1=0
				espaciosadicionales2=0
#Contendrá la clase de la página en NFU/NRU con clases.
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Índices: (proceso, marco)).
#dato5}
#Índices: (proceso, número ordinal del marco usado para ese proceso comenzando por 0).
#dato6}
				fi 
#Desde 0, es el ordinal del número de marcos en memoria asociados a cada proceso (Índices:Proceso)
#ResuFrecuenciaAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]} - $espaciosadicionales1 - $espaciosadicionales2))}
				if [[ $seleccionAlgoritmoPaginacion -ge 0 && $seleccionAlgoritmoPaginacion -le 4 ]]; then
					filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "${ResuFrecuenciaAcumulado[${unidMemOcupadas[$indMem]},${ordinalMarcosProcesoDibujados[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal "`
					filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${ResuFrecuenciaAcumulado[${unidMemOcupadas[$indMem]},${ordinalMarcosProcesoDibujados[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal$NC "`
				elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#ResuUsoRecienteAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]} - $espaciosadicionales1 - $espaciosadicionales2))}
					filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "${ResuUsoRecienteAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal "`
					filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${ResuUsoRecienteAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal$NC "`
				elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
					filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "${ResuFrecuenciaAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal "`
					filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${ResuFrecuenciaAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal$NC "`
				elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#ResuUsoRecienteAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]} - $espaciosadicionales1 - $espaciosadicionales2))}
					filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "${ResuUsoRecienteAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal "`
					filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${ResuUsoRecienteAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal$NC "`
				fi
			fi 
#Número de Marcos con Páginas ya dibujadas de cada Proceso.
            numCaracteres2=$(($numCaracteres2 + $anchoColumna))
            if [[ $indMem -ne 0 ]]; then
                if [[ ${unidMemOcupadas[$((indMem - 1))]} !=  "_" ]]; then 
                    if [[ $xx -eq 1 && ${proceso[$((${unidMemOcupadas[$indMem]}))]} != ${proceso[$((${unidMemOcupadas[$((indMem - 1))]}))]} ]]; then
                        xx=0
                    fi
                fi
            fi
        else
            xx=0
#paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}))}
            filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "$espaciosguionfinal "`
            filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC$espaciosguionfinal$NC "`
            numCaracteres2=$(($numCaracteres2 + $anchoColumna))
        fi
    done

# GENERACIÓN STRING DE FALLOS TOTALES POR PROCESO   
#Total de Fallos de Página del Proceso en el instante actual 

# IMPRIMIR LAS 4 LÍNEAS DE LA BANDA DE MEMORIA (COLOR y BN a pantalla y ficheros)
#Si hay algún proceso en memoria.
		echo -e "\n$filaAlgPagFrecUsoRecTituloColor" | tee -a $informeConColorTotal
		echo -e "$filaAlgPagFrecUsoRecNotas1Color" | tee -a $informeConColorTotal
		echo -e "$filaAlgPagFrecUsoRecNotas2Color" | tee -a $informeConColorTotal
		echo -e "\n$filaAlgPagFrecUsoRecTituloBN" >> $informeSinColorTotal
		echo -e "$filaAlgPagFrecUsoRecNotas1BN" >> $informeSinColorTotal
		echo -e "$filaAlgPagFrecUsoRecNotas2BN" >> $informeSinColorTotal
	fi
	for (( jj = 0; jj <= $aux; jj++ )); do
        echo -e "${filaprocesosColor[$jj]}" | tee -a $informeConColorTotal
        echo -e "${filamarcosColor[$jj]}" | tee -a $informeConColorTotal
        echo -e "${filapagColor[$jj]}" | tee -a $informeConColorTotal
        echo -e "${filaAlgPagFrecUsoRecColor[$jj]}\n" | tee -a $informeConColorTotal
        echo -e "${filaprocesosBN[$jj]}" >> $informeSinColorTotal
        echo -e "${filamarcosBN[$jj]}" >> $informeSinColorTotal
        echo -e "${filapagBN[$jj]}" >> $informeSinColorTotal
        echo -e "${filaAlgPagFrecUsoRecBN[$jj]}\n" >> $informeSinColorTotal
    done

#Se vacía el auxiliar que reubica la memoria.
#Borramos los datos de la auxiliar
        unidMemOcupadasAux[$ca]="_"
    done
#Se vacían bloques
#Borramos los datos de la auxiliar
         bloques[$ca]=0
    done
#Se vacían las posiciones
    nposiciones=0
#Se vacían posiciones iniciales y finales para borrar elementos innecesarios
    for (( i=0; i<$nposiciones; i++ )) ; do
         inicialNCmodelo[$i]=0
    done
    for (( i=0; i<$nposiciones; i++ )) ; do 
         finalNCmodelo[$i]=0
    done
#Fin de la nueva versión de dibujaResumenBandaMemoriaMarcosPagina

#
# Sinopsis: Muestra los fallos de paginación por AlgPagFrecUsoRec al acabar un proceso.  ${coloress[${unidMemOcupadas[$ii]} % 6]}
#
#  proceso[$po]  ${unidMemOcupadas[$ii]}  nproceso ejecutandoinst numeroproceso
    numCaracteres2Inicial=12
    Terminal=$((`tput cols`)) 
	if [[ $seleccionAlgoritmoPaginacion -eq 2 || $seleccionAlgoritmoPaginacion -eq 4 || $seleccionAlgoritmoPaginacion -eq 7 || $seleccionAlgoritmoPaginacion -eq 8 || $seleccionAlgoritmoPaginacion -eq 14 || $seleccionAlgoritmoPaginacion -eq 15 ]]; then 
#Para poder incluir -clase en la página. Se restan 3 porque previamente se ha añadido la logitud $digitosUnidad, y ya venía incluido.
#MFU/LFU con clases 
#Para poder incluir -clase en la página. Se restan 3 porque previamente se ha añadido la logitud $digitosUnidad, y ya venía incluido.
    else
		anchoColumna=$((8 + $digitosUnidad - 3))
    fi
#Se inicializan las variables.
	filaAlgPagFrecUsoRecTituloBN=();
	filaAlgPagFrecUsoRecNotas1Color=();
	filaAlgPagFrecUsoRecNotas1BN=();
	filaAlgPagFrecUsoRecNotas2Color=();
	filaAlgPagFrecUsoRecNotas2BN=();
	filatiempoColor=();
	filapagColor=();
	filatiempoBN=();
	filapagBN=();
	filaAlgPagFrecUsoRecColor=();
	filaAlgPagFrecUsoRecBN=();
	filaFallosColor=();
	filaFallosBN=();

	AlgPagFrecUsoRecMFUTituloColor="\nResumen de los fallos de página del proceso finalizado ${coloress[$procFinalizado % 6]}${proceso[$procFinalizado]}$NORMAL a lo largo del tiempo."
	AlgPagFrecUsoRecMFUTituloBN="\nResumen de los fallos de página del proceso finalizado ${coloress[$procFinalizado % 6]}${proceso[$procFinalizado]}$NORMAL a lo largo del tiempo."
	filaAlgPagFrecUsoRecTituloColor=`echo -e "$NORMAL$AlgPagFrecUsoRecMFUTituloColor$NORMAL "`
	filaAlgPagFrecUsoRecTituloBN=`echo -e "$AlgPagFrecUsoRecMFUTituloBN "`
    if [[ $seleccionAlgoritmoPaginacion -eq 0 || $seleccionAlgoritmoPaginacion -eq 1 || $seleccionAlgoritmoPaginacion -eq 3 ]]; then
		AlgPagFrecUsoRecMFUNotas1="Se muestra: Número de Marco Real-Página del Proceso-Su Frecuencia de Uso"
	elif [[ $seleccionAlgoritmoPaginacion -eq 2 || $seleccionAlgoritmoPaginacion -eq 4 ]]; then
		AlgPagFrecUsoRecMFUNotas1="Se muestra: Número de Marco Real-Página del Proceso-Su Frecuencia de Uso-Coeficiente M."
	elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
		AlgPagFrecUsoRecMFUNotas1="Se muestra: Número de Marco Real-Página del Proceso-Su Tiempo hasta un nuevo uso"
	elif ([[ $seleccionAlgoritmoPaginacion -gt 6 && $seleccionAlgoritmoPaginacion -le 9 ]]) || ([[ $seleccionAlgoritmoPaginacion -gt 12 && $seleccionAlgoritmoPaginacion -eq 15 ]]); then
		AlgPagFrecUsoRecMFUNotas1="Se muestra: Número de Marco Real-Página del Proceso-Su Frecuencia/Antigüedad de Uso."
	elif [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then
		AlgPagFrecUsoRecMFUNotas1="Se muestra: Número de Marco Real-Página del Proceso-Su Frecuencia/Antigüedad de Uso-Página Modificada-Clase."
	fi
	filaAlgPagFrecUsoRecNotas1Color=`echo -e "$NORMAL$AlgPagFrecUsoRecMFUNotas1$NORMAL "`
	filaAlgPagFrecUsoRecNotas1BN=`echo -e "$AlgPagFrecUsoRecMFUNotas1 "`
	if [[ $seleccionAlgoritmoPaginacion -ne 0 ]]; then
		AlgPagFrecUsoRecMFUNotas2="Interpretación: Subrayado-Siguiente fallo ; Fondo de color-Uso del marco ; Negrita-Fallo de Paginación."
	else
		AlgPagFrecUsoRecMFUNotas2="Interpretación: Fondo de color-Uso del marco."
	fi
	filaAlgPagFrecUsoRecNotas2Color=`echo -e "$NORMAL$AlgPagFrecUsoRecMFUNotas2$NORMAL "`
	filaAlgPagFrecUsoRecNotas2BN=`echo -e "$AlgPagFrecUsoRecMFUNotas2 "`

# GENERACIÓN STRING DE RELOJ (Línea 1 del Resumen de Fallos de Paginación)  
#Define el número de saltos a realizar.
	filatiempoColor[$aux]="\n$NC Tiempo     "
	filatiempoBN[$aux]="\n Tiempo     "
#Deja 1 de margen izquierdo y 11 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
#Índice 
	iiSiguiente=0
	for ((counter=0;counter<${ejecucion[$procFinalizado]};counter++)); do
		for ((ii=$iiSiguiente;ii<$reloj;ii++)); do
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
				filatiempoColor[$aux]="\n            "
				filatiempoBN[$aux]="\n            "
#Espacio por la izquierda para cuadrar líneas
			fi
			if [[ ${ResuTiempoProceso[$ii]} -eq $procFinalizado ]]; then
#ii}))}
				filatiempoColor[$aux]+=`echo -e "$NORMAL""$ii$espaciosfinal$NORMAL "`
				filatiempoBN[$aux]+=`echo -e "$ii$espaciosfinal "`
#Para que no se repitan los datos en cada ciclo al no empezar desde 0.
				numCaracteres2=$(($numCaracteres2 + $anchoColumna + 1))
			fi
		done
	done

# GENERACIÓN STRING DE PÁGINAS (Línea 2 del Resumen de Fallos de Paginación)  
#Define el número de saltos a realizar. paginasDefinidasTotal  (Índices:Proceso, Páginas).
	filapagColor[$aux]="$NC Página     "
	filapagBN[$aux]=" Página     "
#Deja 1 de margen izquierdo y 11 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
	iiSiguiente=0
	varCierre=0
	for ((counter=0;counter<${ejecucion[$procFinalizado]};counter++)); do
		for ((ii=$iiSiguiente;ii<$reloj;ii++)); do
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
				filapagColor[$aux]="            "
				filapagBN[$aux]="            "
#Espacio por la izquierda para cuadrar líneas
			fi
#Evita qe queden elementos definidos de ejecuciones anteriores por las que sake un número al final de la línea en una nueva columna que, teóricamente no existe.
				varCierre=$(($varCierre + 1))
#paginasDefinidasTotal[$procFinalizado,$ii]}))}
				filapagColor[$aux]+=`echo -e "$NORMAL""${paginasDefinidasTotal[$procFinalizado,$ii]}$espaciosfinal$NORMAL "`
				filapagBN[$aux]+=`echo -e "${paginasDefinidasTotal[$procFinalizado,$ii]}$espaciosfinal "`
				numCaracteres2=$(($numCaracteres2 + $anchoColumna + 1))
#Para que no se repitan los datos en cada ciclo al no empezar desde 0.
			fi
		done
	done

# GENERACIÓN STRING DE Página-Frecuencia-Uso Reciente-Clase (Líneas de Marcos del Resumen de Fallos de Paginación)  
#Bucle que recorre la ejecución del proceso finalizado a lo largo del tiempo para generar las variables con los datos a usar en la impresión del resumen. 	
#Define el número de saltos a realizar.
#Se considera que los números de marcos, páginas y frecuencias no superarán los tres dígitos.
#"$NC Marco-Pág-Frec/UsoRec "
#" Marco-Pág-Frec/UsoRec "
#Deja 1 de margen izquierdo y 12 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
		iiSiguiente=0
		for ((counter=0;counter<${ejecucion[$procFinalizado]};counter++)); do
			for ((ii=$iiSiguiente;ii<$reloj;ii++)); do
#Si el proceso que se ejecuta en un instante es el finalizado...
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
						filaAlgPagFrecUsoRecColor[$k,$aux]="            "
						filaAlgPagFrecUsoRecBN[$k,$aux]="            "
#Espacio por la izquierda para cuadrar líneas
					fi
#Índices: (proceso, tiempo, número ordinal de marco). Dato del marco real que corresponde al ordinal
#Índices: (proceso, marco, tiempo). Dato de la página contenida en el marco
					if ([[ $seleccionAlgoritmoPaginacion -ge 0 && $seleccionAlgoritmoPaginacion -le 4 ]]) || ([[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 9 ]]); then
#Índices: (proceso, marco, tiempo). Dato de la frecuencia de uso de la página contenida en el marco
					elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#Índices: (proceso, marco, tiempo). Dato del Tiempo que hace que se usó la página contenida en el marco
					elif [[ $seleccionAlgoritmoPaginacion -ge 10 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
						dato3=${ResuFrecuenciaAcumulado[$procFinalizado,$k,$ii]}
						if [[ $dato3 -ge $seleccionAlgoritmoPaginacion_clases_frecuencia_valor ]]; then
#Índices: (proceso, marco, tiempo). Dato del Tiempo que hace que se usó la página contenida en el marco
						fi
					elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 15 ]]; then
#Índices: (proceso, marco, tiempo). Dato del Tiempo que hace que se usó la página contenida en el marco
					elif [[ $seleccionAlgoritmoPaginacion -ge 16 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
						dato3=${ResuUsoRecienteAcumulado[$procFinalizado,$k,$ii]}
						if [[ $dato3 -ge $seleccionAlgoritmoPaginacion_clases_uso_rec_valor ]]; then
#Índices: (proceso, marco, tiempo). Dato del Tiempo que hace que se usó la página contenida en el marco
						fi
					fi
#Contendrá la clase de la página en NFU/NRU con clases.
#Contendrá el coeficiente M en algoritmos de Segunda Oportunidad.
					if [[ $seleccionAlgoritmoPaginacion -eq 2 || $seleccionAlgoritmoPaginacion -eq 4 ]]; then
#Si no hay página, tampoco habrá coeficiente M
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso. Se busca el ordinal usado en ese instante porque sería el utilizado para la búsqueda de los coeficientes M en todos los marcos al ser el mayor número.
#Se usa el ordinal de la página desde ResuPaginaOrdinalAcumulado() que da el ordinal de la página en un marco en cada instante de reloj.				
							datostot="$dato1-$dato2-$dato3-$datoM"
#Si no hay página asociada sólo se muestra el número de marco real.
							datostot="$dato1"						
						fi
					elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#Si no hay página, tampoco habrá tiempo hasta una nueva ejecución. 
							datostot="$dato1-$dato2-$dato3"
						else
							datostot="$dato1"						
						fi
					elif [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then
#Si no hay página, tampoco habrá clase
#Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#Resumen - Índices: (proceso, ordinal del tiempo de ejecución). Dato: Página modificada (1) o no modificada (0).
#Índices: (proceso, marco, número ordinal de la dirección a ejecutar).
						fi
						datostot="$dato1-$dato2-$dato3-$dato4"
					elif [[ $seleccionAlgoritmoPaginacion -eq 0 ]] || [[ $seleccionAlgoritmoPaginacion -eq 1 ]] || [[ $seleccionAlgoritmoPaginacion -eq 3 ]] || ([[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 9 ]]) || ([[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 15 ]]); then
						datostot="$dato1-$dato2-$dato3"
					fi
#datostot}))}  
#En lugar de generar diferentes opciones y comparativas, se generará una serie de variables con las modificaciones de formato. 
#Fondo de color - Marco usado (Puntero) para cada Proceso en cada unidad de Tiempo.
					if [[ $seleccionAlgoritmoPaginacion -ne 0 ]]; then
#Subrayado - Marco (Puntero) sobre el que se produce el siguiente fallo para cada Proceso en cada unidad de Tiempo.
					fi
#Negrita - Marcos donde se produjeron Fallos de Página del Proceso en ejecución.
					varImprimirUsado=""
					varImprimirSiguiente=""
					varImprimirFallo=""
#Contendría el marco sobre el que se produce un fallo.
					if [[ ${varUsado} -eq $k ]]; then
						varImprimirUsado=${colorfondo[$procFinalizado % 6]}
					elif [[ ${varSiguiente} -eq $k && $seleccionAlgoritmoPaginacion -ne 0 ]]; then
						varImprimirSiguiente="\e[4m"
#Si contiene algún dato (marco) es porque hay un fallo.
						varImprimirFallo="\e[1m"
					fi
					if [[ $varImprimirUsado == "" ]]; then
						filaAlgPagFrecUsoRecColor[$k,$aux]+=`echo -e "$NC${coloress[$procFinalizado % 6]}$varImprimirSiguiente$varImprimirFallo$datostot$NC$espaciosfinal "`
						filaAlgPagFrecUsoRecBN[$k,$aux]+=`echo -e "$datostot$espaciosfinal "`
					else
						filaAlgPagFrecUsoRecColor[$k,$aux]+=`echo -e "$NC$varImprimirUsado$varImprimirSiguiente$varImprimirFallo$datostot$NC$espaciosfinal "`
						filaAlgPagFrecUsoRecBN[$k,$aux]+=`echo -e "$datostot$espaciosfinal "`
					fi
					numCaracteres2=$(($numCaracteres2 + $anchoColumna + 1))
				fi
#Para que no se repitan los datos en cada ciclo al no empezar desde 0.
			done
		done
	done

# GENERACIÓN STRING DE FALLOS (Líneas de Fallos del Resumen de Fallos de Paginación)  
#Define el número de saltos a realizar.
#Es fijo porque sólo se va a escribir "F" o "-".
#"$NC Marco-Pág-Frec/UsoRec "
#" Marco-Pág-Frec/UsoRec "
#Deja 1 de margen izquierdo y 12 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
	iiSiguiente=0
	for ((counter=0;counter<${ejecucion[$procFinalizado]};counter++)); do
		for ((ii=$iiSiguiente;ii<=$reloj;ii++)); do
#Si el proceso que se ejecuta en un instante es el finalizado...
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
					filaFallosColor[$aux]="            "
					filaFallosBN[$aux]="            "
#Espacio por la izquierda para cuadrar líneas
				fi
#Contendría el marco sobre el que se produce un fallo.
#Si contiene algún dato (marco) es porque hay un fallo.
					filaFallosColor[$aux]+=`echo -e "${coloress[$procFinalizado % 6]}""F""$NC$espaciosfinal "`
					filaFallosBN[$aux]+=`echo -e "F""$espaciosfinal "`
				else
					filaFallosColor[$aux]+=`echo -e "-""$NC$espaciosfinal "`
					filaFallosBN[$aux]+=`echo -e "-""$espaciosfinal "`
				fi
				numCaracteres2=$(($numCaracteres2 + $anchoColumna + 1))
			fi
#Para que no se repitan los datos en cada ciclo al no empezar desde 0.
		done
	done

# GENERACIÓN STRING DE FALLOS TOTALES POR PROCESO  
#Total de Fallos de Página del Proceso 

# IMPRIMIR LAS LÍNEAS DE LOS MARCOS DE MEMORIA POR PROCESO (COLOR y BN a pantalla y ficheros)
	echo -e "$filaAlgPagFrecUsoRecTituloColor" | tee -a $informeConColorTotal
	echo -e "$filaAlgPagFrecUsoRecNotas1Color" | tee -a $informeConColorTotal
	echo -ne "$filaAlgPagFrecUsoRecNotas2Color" | tee -a $informeConColorTotal
	echo -e "$filaAlgPagFrecUsoRecTituloBN" >> $informeSinColorTotal
	echo -e "$filaMF$filaAlgPagFrecUsoRecNotas1BN" >> $informeSinColorTotal
	echo -ne "$filaAlgPagFrecUsoRecNotas2BN" >> $informeSinColorTotal
#Para cada salto de línea por no caber en la pantalla
		echo -e "${filatiempoColor[$jj]}" | tee -a $informeConColorTotal
		echo -e "${filapagColor[$jj]}" | tee -a $informeConColorTotal
		echo -e "${filatiempoBN[$jj]}" >> $informeSinColorTotal
		echo -e "${filapagBN[$jj]}" >> $informeSinColorTotal
#Para cada marco asociado al proceso
			echo -e "${filaAlgPagFrecUsoRecColor[$k,$jj]}" | tee -a $informeConColorTotal
			echo -e "${filaAlgPagFrecUsoRecBN[$k,$jj]}" >> $informeSinColorTotal
		done
		echo -e "${filaFallosColor[$jj]}" | tee -a $informeConColorTotal
		echo -e "${filaFallosBN[$jj]}" >> $informeSinColorTotal
    done
	echo -e " Total de Fallos de Página del Proceso "${coloress[$procFinalizado % 6]}${proceso[$procFinalizado]}": $NORMAL"$fallosProceso | tee -a $informeConColorTotal
	echo -e " Total de Fallos de Página del Proceso "${proceso[$procFinalizado]}": "$fallosProceso >> $informeSinColorTotal
	if [[ $seleccionMenuAlgoritmoGestionProcesos -eq 5 ]]; then
		echo -e " Número de expulsiones forzadas en Round-Robin (RR) del Proceso "${coloress[$procFinalizado % 6]}${proceso[$procFinalizado]}": $NORMAL"${contadorAlgPagExpulsionesForzadasProcesoAcumulado[$procFinalizado]} | tee -a $informeConColorTotal
		echo -e " Número de expulsiones forzadas en Round-Robin (RR) del Proceso "${proceso[$procFinalizado]}": "${contadorAlgPagExpulsionesForzadasProcesoAcumulado[$procFinalizado]} >> $informeSinColorTotal
	fi
#Se define a "-1" para que no vuelva a imprimirse en caso de producirse algún otro evento.
#Fin de dibujaResumenAlgPagFrecUsoRec()

#
# Sinopsis: Permite introducir las opciones generales de la memoria por teclado
#
function entradaMemoriaTeclado {
#Pedir el número de marcos de memoria del sistema
    echo -ne "$cian Introduzca el número de marcos de memoria del sistema:  $NC" | tee -a $informeConColorTotal  
    echo " Introduzca el número de marcos de memoria del sistema:"  >> $informeSinColorTotal
    read mem_marcos
    echo $mem_marcos >> $informeConColorTotal
    echo $mem_marcos >> $informeSinColorTotal
    until [[ $mem_marcos -gt 0 ]] ; do 
        echo -e "$rojo Entrada no válida, el número de marcos de memoria no puede ser menor o igual a 0.$NC" | tee -a $informeConColorTotal 
        echo -ne " Introduzca un$verde número de marcos de memoria correcto:  $NC" | tee -a $informeConColorTotal 
        echo -e " Entrada no válida, el número de marcos de memoria no puede ser menor o igual a 0." >> $informeSinColorTotal
        echo -e " Introduzca un número de marcos de memoria correcto:  " >> $informeSinColorTotal
        read mem_marcos
        echo $mem_marcos >> $informeConColorTotal
        echo $mem_marcos >> $informeSinColorTotal
    done
    while ! es_entero $mem_marcos ; do
        echo -e "$rojo Entrada no válida, el número de marcos de memoria no puede ser menor o igual a 0.$NC" | tee -a $informeConColorTotal 
        echo -ne " Introduzca un$verde número de marcos de memoria correcto:  $NC" | tee -a $informeConColorTotal 
        echo -e " Entrada no válida, el número de marcos de memoria no puede ser menor o igual a 0." >> $informeSinColorTotal
        echo -e " Introduzca un número de marcos de memoria correcto:  " >> $informeSinColorTotal
        read mem_marcos
        echo $mem_marcos >> $informeConColorTotal
        echo $mem_marcos >> $informeSinColorTotal
    done
#Pedir el número de direcciones de cada marco de memoria del sistema
    echo -ne "$cian Introduzca el número de direcciones de cada marco de memoria del sistema:  $NC" | tee -a $informeConColorTotal  
    echo " Introduzca el número de direcciones de cada marco de memoria del sistema:"  >> $informeSinColorTotal
    read mem_direcciones
    echo $mem_direcciones >> $informeConColorTotal
    echo $mem_direcciones >> $informeSinColorTotal
    until [[ $mem_direcciones -gt 0 ]] ; do 
        echo -e "$rojo Entrada no válida, el número de direcciones de cada marco de memoria no puede ser menor o igual a 0.$NC" | tee -a $informeConColorTotal 
        echo -ne " Introduzca un$verde número de direcciones de cada marco de memoria correcto:  $NC" | tee -a $informeConColorTotal 
        echo -e " Entrada no válida, el número de direcciones de cada marco de memoria no puede ser menor o igual a 0." >> $informeSinColorTotal
        echo -e " Introduzca un número de direcciones de cada marco de memoria correcto:  " >> $informeSinColorTotal
        read mem_direcciones
        echo $mem_direcciones >> $informeConColorTotal
        echo $mem_direcciones >> $informeSinColorTotal
    done
    while ! es_entero $mem_direcciones ; do
        echo -e "$rojo Entrada no válida, el número de direcciones de cada marco de memoria no puede ser menor o igual a 0.$NC" | tee -a $informeConColorTotal 
        echo -ne " Introduzca un$verde número de direcciones de cada marco de memoria correcto:  $NC" | tee -a $informeConColorTotal 
        echo -e " Entrada no válida, el número de direcciones de cada marco de memoria no puede ser menor o igual a 0." >> $informeSinColorTotal
        echo -e " Introduzca un número de direcciones de cada marco de memoria correcto:  " >> $informeSinColorTotal
        read mem_direcciones
        echo $mem_direcciones >> $informeConColorTotal
        echo $mem_direcciones >> $informeSinColorTotal
    done

#Se inicializa para que no se considere la reubicabilidad si no está definida en la elección inicial.
#R/NR
#Pedir el tamaño de la variable de reubicación $reubicabilidadNo0Si1 -eq 0
        echo -ne "$cian Introduzca el tamaño maximo de memoria para que haya reubicacion:  $NC" | tee -a $informeConColorTotal  
        echo " Introduzca el tamaño maximo de memoria para que haya reubicacion:"  >> $informeSinColorTotal
        read reub
        echo $reub >> $informeConColorTotal
        echo $reub >> $informeSinColorTotal
        until [[ $reub -gt 0 && $reub -lt $mem_marcos ]] ; do 
            echo -e "$rojo Entrada no válida, el tamaño mínimo de reubicación no puede ser 0.$NC" | tee -a $informeConColorTotal 
            echo -ne " Introduzca un$verde tamaño correcto:  $NC" | tee -a $informeConColorTotal 
            echo -e " Entrada no válida, el tamaño mínimo de reubicación no puede ser 0." >> $informeSinColorTotal
            echo -e " Introduzca un tamaño correcto:  " >> $informeSinColorTotal
            read reub
            echo $reub >> $informeConColorTotal
            echo $reub >> $informeSinColorTotal
        done

        while ! es_entero $reub ; do
            echo -e "$rojo Entrada no válida, el tamaño mínimo de reubicación no puede ser negativo.$NC" | tee -a $informeConColorTotal 
            echo -ne " Introduzca un$verde tamaño correcto:  $NC" | tee -a $informeConColorTotal 
            echo -e " Entrada no válida, el tamaño mínimo de reubicación no puede ser negativo." >> $informeSinColorTotal
            echo -e " Introduzca un tamaño correcto:  " >> $informeSinColorTotal
            read reub
            echo $reub >> $informeConColorTotal
            echo $reub >> $informeSinColorTotal
        done
    else
        reub=0
        echo $reub >> $informeConColorTotal
        echo $reub >> $informeSinColorTotal
    fi
    
#Direcciones totales de memoria.
#Número de marcos totales de memoria.
    variableReubicar=$reub

# salida de datos introducidos sobre la memoria para que el usuario pueda ver lo que esta introducciendo y volcado de los mismos en ficheros auxiliares
    echo ""
#Se meten los datos de las particiones en otro fichero escogido
#Se meten los datos de las particiones en otro fichero escogido
#Se meten los datos de las particiones en otro fichero escogido
#    clear
#Fin de entradaMemoriaTeclado()                

#
# Sinopsis: Permite introducir los procesos por teclado.
#
function entradaProcesosTeclado {
#Número ordinal de proceso
    masprocesos="s"
#Se meten los textos correspondientes a los datos en el fichero escogido
    while [[ $masprocesos == "s" ]]; do 
#        clear
#Para ser equivalente al nuevo programa. Se aconseja quitar la variable $p y estandarizar las variables a usar ??????????.
#Bloque para introducción del resto de datos del proceso
#Se introduce el tiempo de llegada asociado a cada proceso.
        echo -ne $NORMAL"\n Tiempo de llegada del proceso $p: " >> $informeSinColorTotal
        read llegada[$p]
        until [[ ${llegada[$p]} -ge 0 ]]; do
            echo $NORMAL" No se pueden introducir tiempos de llegada negativos" | tee -a $informeConColorTotal
            echo $NORMAL" No se pueden introducir tiempos de llegada negativos" >>$informeSinColorTotal
            echo -ne $NORMAL" Introduce un nuevo tiempo de llegada\n" | tee -a $informeConColorTotal
            echo -ne $NORMAL" Introduce un nuevo tiempo de llegada\n" >> $informeSinColorTotal
            read llegada[$p]
        done
                
#Se introduce la memoria asociada a cada proceso.
        echo -ne $NORMAL"\n Número de marcos de memoria asociados al proceso $p: " >>$informeSinColorTotal
        read memoria[$p]
        while [[ ${memoria[$p]} -le 0 || ${memoria[$p]} -gt $mem_total ]]; do
            echo $NORMAL" No se pueden introducir memoria negativa o superior a la memoria total" | tee -a $informeConColorTotal
            echo $NORMAL" No se pueden introducir memoria negativa o superior a la memoria total" >>$informeSinColorTotal
            echo -ne $NORMAL" Introduce un nuevo número de marcos de memoria\n" | tee -a $informeConColorTotal
            echo -ne $NORMAL" Introduce un nuevo número de marcos de memoria\n" >>$informeSinColorTotal
            read memoria[$p] 
        done

        if [[ $alg -eq 4 ]]; then
#Se introduce la prioridad asociada a cada proceso.
			echo -ne $NORMAL"\n Prioridad asociada asociados al proceso $p: " >>$informeSinColorTotal
			read prioProc[$p]
			while [[ ${prioProc[$p]} -le $PriomFinal || ${prioProc[$p]} -gt $PrioMFinal ]]; do
				echo $NORMAL" No se pueden introducir una prioridad fuera de los límites inferior y superior de la Prioridad del problema" | tee -a $informeConColorTotal
				echo $NORMAL" No se pueden introducir una prioridad fuera de los límites inferior y superior de la Prioridad del problema" >>$informeSinColorTotal
				echo -ne $NORMAL" Introduce una nueva prioridad\n" | tee -a $informeConColorTotal
				echo -ne $NORMAL" Introduce una nueva prioridad\n" >>$informeSinColorTotal
				read prioProc[$p] 
			done
        fi

		ejecucion[$p]=0
#Número ordinal de dirección/página definidas
		paginasTeclado=""
#Se introducen las direcciones asociadas a cada proceso.
			echo -e "\n Escribe la dirección $numOrdinalPagTeclado (si introduces una n acabará la introducción de direcciones)" | tee -a $informeConColorTotal $informeSinColorTotal
			echo -ne " Introduce: " | tee -a $informeConColorTotal $informeSinColorTotal
			read paginasTeclado
			if [[ $paginasTeclado != "n" ]]; then
				directions[$p,$numOrdinalPagTeclado]=$paginasTeclado
				if [[ $seleccionAlgoritmoPaginacion -eq 0 ]]; then
					numDireccionesTotales=$(($mem_total * $mem_direcciones))
					until [[ ${directions[$p,$numOrdinalPagTeclado]} =~ [0-9] && ${directions[$p,$numOrdinalPagTeclado]} -ge 0 && ${directions[$p,$numOrdinalPagTeclado]} -le $(($numDireccionesTotales - 1)) ]]; do
						echo -e "\n$ROJO Debes introducir un número de direccion igual o superior a 0 e inferior al número total de dorecciones definibles: $NC"$(($numDireccionesTotales - 1))
						read -p " Introduce de nuevo la direccion $numOrdinalPagTeclado: " directions[$p,$numOrdinalPagTeclado]
					done
				else
					until [[ ${directions[$p,$numOrdinalPagTeclado]} =~ [0-9] && ${directions[$p,$numOrdinalPagTeclado]} -ge 0 ]]; do
						echo -e "\n$ROJO Debes introducir un número de direccion igual o superior a 0$NC"
						read -p " Introduce de nuevo la direccion $numOrdinalPagTeclado: " directions[$p,$numOrdinalPagTeclado]
					done
				fi
#				directions[$p,$numOrdinalPagTeclado]=$paginasTeclado
#let pagTransformadas[$2]=`expr $1/$mem_direcciones`
				varPaginasTeclado=$varPaginasTeclado"$paginasTeclado "
				paginasDefinidasTotal[$p,$numOrdinalPagTeclado]=${pagTransformadas[$numOrdinalPagTeclado]} 
				ejecucion[$p]=$(expr ${ejecucion[$p]} + 1)
#Para ser equivalente al nuevo programa
				numOrdinalPagTeclado=$(expr $numOrdinalPagTeclado + 1)
			fi
		done

#Salida de datos introducidos sobre procesos para que el usuario pueda ver lo que esta introducciendo y volcado de los mismos en ficheros auxiliares
        echo ""
#Se meten los datos de las particiones en otro fichero escogido
#        clear 
#Se ordenan los datos por tiempo de llegada a medida que se van itroduciendo. También crea los bit de Modificados para cuando se utilicen los algoritmos basados en clases.

        echo -e $NORMAL"\n\n Ref Tll Tej nMar Dir-Pag" | tee -a $informeConColorTotal
        echo -e "\n\n Ref Tll Tej nMar Dir-Pag" >> $informeSinColorTotal
#Función para mostrar los datos   
        echo -e "\n" | tee -a $informeConColorTotal
        echo -e "\n" >> $informeSinColorTotal
        echo -ne $NORMAL"\n ¿Quieres más procesos? s/n " | tee -a $informeConColorTotal
        echo -ne "\n ¿Quieres más procesos? s/n " >>$informeSinColorTotal
        read masprocesos
        echo "$masprocesos" >>$informeConColorTotal
        echo "$masprocesos" >>$informeSinColorTotal
        until [[ $masprocesos == "s" || $masprocesos == "n" ]]; do
            echo -ne "\n Escribe 's' o 'n', por favor: " | tee -a $informeConColorTotal
            echo -ne "\n Escribe 's' o 'n', por favor: " >>$informeSinColorTotal
            read masprocesos
            echo "$masprocesos" >>$informeConColorTotal
            echo "$masprocesos" >>$informeSinColorTotal
        done
#incremento el contador
    done
#Se guardan los datos introducidos en el fichero de última ejecución
        cp $ficheroDatosDefault $ficheroDatosAnteriorEjecucion
    else
        cp $nomFicheroDatos $ficheroDatosAnteriorEjecucion
    fi
#Fin de entradaProcesosTeclado()

#
# Sinopsis: Impresión de los procesos una vez introducidos por teclado o fichero 
#
function imprimeprocesos {
#Se ordenan los procesos por tiempo de llegada a medida que se van introduciendo.
	for (( counter = 0; counter <= numprocesos; counter++ )); do
		if [[ $counter -gt 8 ]]; then
			let colorjastag[counter]=counter-8;
		else
			let colorjastag[counter]=counter+1;
		fi
	done
	echo -e "\n Ref Tll Tej nMar Dirección-Página ------ imprimeprocesos\n" | tee -a $informeConColorTotal $informeSinColorTotal
#Resumen inicial de la taba de procesos.
	echo "" | tee -a $informeConColorTotal $informeSinColorTotal > /dev/null
	echo "|—————————————————————————————————————————————————————————————————————————|" | tee -a $informeConColorTotal $informeSinColorTotal > /dev/null
	echo "" | tee -a $informeConColorTotal $informeSinColorTotal > /dev/null
	echo "" | tee -a $informeConColorTotal $informeSinColorTotal > /dev/null
#Fin de imprimeprocesos()

#
# Sinopsis: Permite visualizar los datos de la memoria/procesos introducidos por teclado.
#
function entradaProcesosTecladoDatosPantalla { 
	multiplicador=0
	counter2=0
	counter3=0	
#Define los colores de los procesos de forma cíclica. 
#Faltaría ajustar los valores de las variables a los colores posibles (6, 8, 9). Pero no es una buena idea porque los colores del texto y fondos no coinciden como se ve en las variables $coloress y $colorfondos...
			multiplicador=$multiplicador+1
#Para calcular la diferencia ente contadores para determinar cuándo es superior al número de colores usados.
		fi
		counter2=$counter-$counter3;
		let colorjastag[counter]=$counter2+1;
	done
#llegada[@]}; t++)); do
        echo -ne " ${coloress[$t % 6]}${proceso[$t]}" | tee -a $informeConColorTotal
        echo -n " ${proceso[$t]}" >>$informeSinColorTotal
#llegada[$t]})) 
        echo -ne "${varhuecos:1:$longitudLlegada}""${coloress[$t % 6]}${llegada[$t]}" | tee -a $informeConColorTotal 
        echo -n "${varhuecos:1:$longitudLlegada}""${llegada[$t]}" >>$informeSinColorTotal
#ejecucion[$t]})) 
        echo -ne "${varhuecos:1:$longitudTiempo}""${coloress[$t % 6]}${ejecucion[$t]}" | tee -a $informeConColorTotal 
        echo -n "${varhuecos:1:$longitudTiempo}""${ejecucion[$t]}" >>$informeSinColorTotal            
#memoria[$t]})) 
        echo -ne "${varhuecos:1:$longitudMemoria}""${coloress[$t % 6]}${memoria[$t]}" | tee -a $informeConColorTotal 
        echo -ne "${varhuecos:1:$longitudMemoria}""${memoria[$t]}" >>$informeSinColorTotal
 		DireccionesPaginasPorProceso=""
 		for ((counter2=0;counter2<${ejecucion[$t]};counter2++)); do
			DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$t]}${directions[$t,$counter2]}-${paginasDefinidasTotal[$t,$counter2]}"
		done
		echo -e "$DireccionesPaginasPorProceso" | tee -a $informeConColorTotal
    done
#Fin de entradaProcesosTecladoDatosPantalla()

#
# Sinopsis: Permite ordenar los datos sacados desde fichero y de entrada por teclado. 
#
function ordenarDatosEntradaFicheros {
#llegada[@]}; j++)); do
#Se guarda su número de orden de introducción o lectura en un vector para la función que lo ordena   
    done
#llegada[@]}; j++)); do
        if [[ $j -ge 9 ]]; then
            proceso[$j]=$(echo P$(($j + 1)))
        else
            proceso[$j]=$(echo P0$(($j + 1)))
        fi
    done
#llegada[@]} - 1)); j >= 0; j-- )); do 
        for (( i = 0; i < $j; i++ )); do
            if [[ $((llegada[$i])) -gt $((llegada[$(($i + 1))])) ]]; then
#No hace falta borrar aux porque sólo hay un valor, y su valor se machaca en cada redefinición. 
                proceso[$(($i + 1))]=${proceso[$i]} 
                proceso[$i]=$aux
                aux=${llegada[$(($i + 1))]}
                llegada[$(($i + 1))]=${llegada[$i]}
                llegada[$i]=$aux
#Se permutan las páginas
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${paginasDefinidasTotal[$(($i + 1)),$counter2]}
				done
#Se borran para que no pueda haber valores anteriores residuales.
					unset paginasDefinidasTotal[$(($i + 1)),$counter2]
				done
				for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
					paginasDefinidasTotal[$(($i + 1)),$counter2]=${paginasDefinidasTotal[$i,$counter2]}
				done
				for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
					unset paginasDefinidasTotal[$i,$counter2]
				done
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					paginasDefinidasTotal[$i,$counter2]=${aux2[$counter2]}
				done
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					unset aux2[$counter2]
				done

#Se permutan las direcciones los valores de "Página Modificada", cuando se trabaja con algoritmos basados en Clases, porque se definió en leer_datos_desde_fichero().
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${directions[$(($i + 1)),$counter2]}
				done
#Se borran para que no pueda haber valores anteriores residuales.
					unset directions[$(($i + 1)),$counter2]
				done
				for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
					directions[$(($i + 1)),$counter2]=${directions[$i,$counter2]}
				done
				for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
					unset directions[$i,$counter2]
				done
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					directions[$i,$counter2]=${aux2[$counter2]}
				done
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					unset aux2[$counter2]
				done

#Se permutan las direcciones los valores de "Página Modificada", cuando se trabaja con algoritmos basados en Clases, porque se definió en leer_datos_desde_fichero().
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${directions_AlgPagFrecUsoRec_pagina_modificada[$(($i + 1)),$counter2,0]}
				done
#Se borran para que no pueda haber valores anteriores residuales.
					unset directions_AlgPagFrecUsoRec_pagina_modificada[$(($i + 1)),$counter2,0]
				done
				for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
					directions_AlgPagFrecUsoRec_pagina_modificada[$(($i + 1)),$counter2,0]=${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				done
				for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
					unset directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]
				done
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]=${aux2[$counter2,0]}
				done
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					unset aux2[$counter2]
				done

                aux=${ejecucion[$(($i + 1))]}
                ejecucion[$(($i + 1))]=${ejecucion[$i]} 
                ejecucion[$i]=$aux
                aux=${tiempoEjecucion[$(($i + 1))]}
#Se permutan los valores de esta variable auxiliar porque se definió en leer_datos_desde_fichero().
                tiempoEjecucion[$i]=$aux
                aux=${memoria[$(($i + 1))]}
                memoria[$(($i + 1))]=${memoria[$i]} 
                memoria[$i]=$aux
                aux=${prioProc[$(($i + 1))]}
#En caso de usar el algoritmo basado en Prioridades...
                prioProc[$i]=$aux
            fi
        done
    done
#llegada[@]}; j++)); do
#Se guarda su número de orden de introducción o lectura en un vector para la función que lo ordena   
    done
#Fin de ordenarDatosEntradaFicheros()

#
# Sinopsis: Pregunta en qué fichero guardar los rangos para la opción 8.
#
function entradaMemoriaRangosFichero_op_cuatro_Previo {
#    clear
#Resuelve los nombres de los ficheros de rangos
#Resuelve los nombres de los ficheros de datos
#Fin de entradaMemoriaRangosFichero_op_cuatro_Previo()

#
# Sinopsis: Se piden y tratan los mínimos y máximos de los rangos, calculando los valores aleatorios y los datos 
# con los que se trabajará para la opción 4. 
#
function entradaMemoriaRangosFichero_op_cuatro { 
#---Llamada a funciones para rangos-------------
#Se asigna la memoria aleatoriamente       
    calcDatoAleatorioGeneral $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS
	mem_total=$datoAleatorioGeneral
#Se asigna la memoria aleatoriamente       
    calcDatoAleatorioGeneral $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
	mem_direcciones=$datoAleatorioGeneral
#Se comparará este valor con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.

#Se asigna el mínimo del rango de prioridad aleatoriamente       
	MIN_RANGE_prio_menorInicial=${prio_menor_min}
	MAX_RANGE_prio_menorInicial=${prio_menor_max}
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_prio_menor=$PriomFinal
	MAX_RANGE_prio_menor=$PrioMFinal
	calcDatoAleatorioGeneral $MIN_RANGE_prio_menor $MAX_RANGE_prio_menor
	prio_menorInicial=$datoAleatorioGeneral
#Se asigna el máximo del rango de prioridad aleatoriamente       
	MIN_RANGE_prio_mayorInicial=${prio_mayor_min}
	MAX_RANGE_prio_mayorInicial=${prio_mayor_max}
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_prio_mayor=$PriomFinal
	MAX_RANGE_prio_mayor=$PrioMFinal
	calcDatoAleatorioGeneral $MIN_RANGE_prio_mayor $MAX_RANGE_prio_mayor
	prio_mayorInicial=$datoAleatorioGeneral
	prio_menor_min=$prio_menor_minInicial
	prio_menor_max=$prio_menor_maxInicial
#Se invierten los valores si el mayor es menor que el mayor.
	prio_menor=$PriomFinal
	prio_mayor=$PrioMFinal
#Se asigna la reubicaciónaleatoriamente     
    calcDatoAleatorioGeneral $MIN_RANGE_REUB $MAX_RANGE_REUB
	reub=$datoAleatorioGeneral
#Se asigna el número de procesos aleatoriamente 
    calcDatoAleatorioGeneral $MIN_RANGE_NPROC $MAX_RANGE_NPROC
	n_prog=$datoAleatorioGeneral
#--------------------------------------------- En algunos casos no hace falta calcularlo porque se calculará por cada proceso. 
    datos_tiempo_llegada    
    datos_tiempo_ejecucion 
    datos_tamano_marcos_procesos 
    datos_prio_proc
#---------------------------------------------
	datos_quantum         
	calcDatoAleatorioGeneral $MIN_RANGE_quantum $MAX_RANGE_quantum
	quantum=$datoAleatorioGeneral
#--------------------------------------------- El resto no hace falta calcularlo porque se calculará por cada proceso. 
    datos_tamano_direcciones_procesos          
#---------------------------------------------
#    clear   
	for (( p=0; p<$n_prog; p++)); do     
#Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 4, 5 y 6. 
#Guarda los datos en los ficheros que correspondan
#cierre del until
#Copia los ficheros Default/Último
#Fin de entradaMemoriaRangosFichero_op_cuatro()

#
# Sinopsis: Se guardarán los datos en los ficheros que corresponda para la opción 4
# 
function entradaMemoriaRangosFichero_op_cuatro_Post_1 {
#Para imprimir los rangos en el fichero dependiendo si es el fichero anterior o otro
        echo -e "RangoMarcosMemoria $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS" > $nomFicheroRangos 
        echo -e "RangoDireccionesMarco $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES" >> $nomFicheroRangos 
        echo -e "RangoPrioMenor $MIN_RANGE_prio_menor $MAX_RANGE_prio_menor" >> $nomFicheroRangos 
        echo -e "RangoPrioMayor $MIN_RANGE_prio_mayor $MAX_RANGE_prio_mayor" >> $nomFicheroRangos 
        echo -e "RangoNumProc $MIN_RANGE_NPROC $MAX_RANGE_NPROC" >> $nomFicheroRangos 
        echo -e "RangoReubicar $MIN_RANGE_REUB $MAX_RANGE_REUB" >> $nomFicheroRangos 
        echo -e "RangoLlegada $MIN_RANGE_llegada $MAX_RANGE_llegada" >> $nomFicheroRangos 
        echo -e "RangoTEjecucion $MIN_RANGE_tiempo_ejec $MAX_RANGE_tiempo_ejec" >> $nomFicheroRangos 
        echo -e "RangoTamanoMarcosProc $MIN_RANGE_tamano_marcos_proc $MAX_RANGE_tamano_marcos_proc" >> $nomFicheroRangos
        echo -e "RangoPrioProc $MIN_RANGE_prio_proc $MAX_RANGE_prio_proc" >> $nomFicheroRangos
        echo -e "RangoTamanoDireccionesProc $MIN_RANGE_tamano_direcciones_proc $MAX_RANGE_tamano_direcciones_proc" >> $nomFicheroRangos
        echo -ne "RangoQuantum $MIN_RANGE_quantum $MAX_RANGE_quantum" >> $nomFicheroRangos
#Cierre if $p -eq 1
#No se establece desde fichero sino que se decide en el momento de la ejecución mediante la variable de selección de tipo $seleccionTipoPrioridad.
#M/m
		PrioR="Mayor"
	else    
		PrioR="Menor"                
	fi              
#Escribe los datos en el fichero selecionado
		echo -ne "Marcos totales\n"$mem_total"\nTamano de pagina\n"$mem_direcciones"\nPrioridad menor\n"$prio_menorInicial\
		"\nPrioridad mayor\n"$prio_mayorInicial"\nTipo de prioridad\n"$PrioR"\nMinimo para reubicabilidad\n"$reub"\nQuantum\n"$quantum\
		"\nTll nMar Prio Direcciones/Modificado:\n" > $nomFicheroDatos
	fi                  

#Se usarán para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
	MAX_RANGE_PAGINA_MODIFICADA=1
#Hace que las direcciones sean diferentes en cada proceso.
#Muestra las direcciones del proceso calculadas de forma aleatoria.
#Se almacena el cálculo aleatorio de si una página es o no modificada al ser ejecutada.
#Se calcula de forma aleatoria si una página es o no modificada al ser ejecutada.
		direccionesAcumuladas+=`echo -ne " ${directions[$p,$numdir]}-${directions_AlgPagFrecUsoRec_pagina_modificada[$p,$numdir,0]}"`
	done
	echo -e ${llegada[$p]} ${memoria[$p]} ${prioProc[$p]} $direccionesAcumuladas >> $nomFicheroDatos
#    clear
#Fin de entradaMemoriaRangosFichero_op_cuatro_Post_1()

#
# Sinopsis: Se copian los ficheros que correspondan para la opción 4
#
function entradaMemoriaRangosFichero_op_cuatro_Post_2 {
#Borra el fichero de datos ultimo y escribe los datos en el fichero
        rm $ficheroDatosAnteriorEjecucion
    fi
#Borra el fichero de datos ultimo y escribe los rangos en el fichero
        rm $ficheroRangosAnteriorEjecucion
    fi
#Copia los ficheros Default/Último       
#Copia los ficheros Default/Último       
#Fin de entradaMemoriaRangosFichero_op_cuatro_Post_2()

#
# Sinopsis: Pregunta en qué fichero guardar los rangos amplios para la opción 5.
#
function entradaMemoriaRangosFichero_op_cinco_Previo {
#    clear
#Resuelve los nombres de los ficheros de datos
#Fin de entradaMemoriaRangosFichero_op_cinco_Previo()

#
# Sinopsis: Pregunta en qué fichero guardar los rangos amplios para la opción 6.
#
function entradaMemoriaRangosFichero_op_seis_Previo {
#    clear
#Resuelve los nombres de los ficheros de datos
    echo -e "\n\nFicheros existentes:\n$NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\nFicheros existentes:\n" >> $informeSinColorTotal 
    files=("./FRangos"/*)
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
        echo -e "$i) ${files[$i]}" | tee -a $informeConColorTotal
        echo -e "$i) ${files[$i]}" >> $informeSinColorTotal 
    done
    echo -ne "\n$AMARILLO\n\nIntroduce el número correspondiente al fichero elegido: $NORMAL" | tee -a $informeConColorTotal
    echo -ne "\n\n\nIntroduce el número correspondiente al fichero elegido: " >> $informeSinColorTotal 
    read -r numeroFichero
#files[@]} ]]; do
        echo -ne "Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read -r numeroFichero
        echo -e "$numeroFichero\n\n" >> $informeConColorTotal
        echo -e "$numeroFichero\n\n" >> $informeSinColorTotal
    done
    echo "$numeroFichero" >> $informeConColorTotal
    echo "$numeroFichero" >> $informeSinColorTotal
    ficheroParaLectura="${files[$numeroFichero]}"
#    clear
#Fin de entradaMemoriaRangosFichero_op_seis_Previo()

#
# Sinopsis: Se tratan los mínimos y máximos de los rangos, calculando los valores aleatorios y los datos 
# con los que se trabajará para las opciones 5 y 6. 
#
function entradaMemoriaRangosFichero_op_cinco_seis {
#    datos_memoria_tabla
#-----------Llamada a funciones para calcular los datos aleatorios dentro de los rangos definidos-------------
    MIN_RANGE_MARCOS=${memoria_min}
    MAX_RANGE_MARCOS=${memoria_max}
    calcDatoAleatorioGeneral $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS
	mem_total=$datoAleatorioGeneral
    MIN_RANGE_DIRECCIONES=${direcciones_min}
    MAX_RANGE_DIRECCIONES=${direcciones_max}
    calcDatoAleatorioGeneral $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
	mem_direcciones=$datoAleatorioGeneral
#Se comparará este valor con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.

    MIN_RANGE_prio_menor=${prio_menor_min}
    MAX_RANGE_prio_menor=${prio_menor_max}
    calcDatoAleatorioGeneral $MIN_RANGE_prio_menor $MAX_RANGE_prio_menor
#*Inicial - Datos a representar
    MIN_RANGE_prio_mayor=${prio_mayor_min}
    MAX_RANGE_prio_mayor=${prio_mayor_max}
    calcDatoAleatorioGeneral $MIN_RANGE_prio_mayor $MAX_RANGE_prio_mayor
#*Inicial - Datos a representar
#Variables con los datos originales usadas en la cabecera de la representación de la tabla
	PrioMInicial=$prio_mayorInicial
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#Sobre este rango se calculan los datos de las prioridades de los procesos, prioridades que no deberían pedirse al usuario.
	prio_mayor=$PrioMFinal
      
    MIN_RANGE_REUB=${reubicacion_min}
    MAX_RANGE_REUB=${reubicacion_max}
    calcDatoAleatorioGeneral $MIN_RANGE_REUB $MAX_RANGE_REUB
	reub=$datoAleatorioGeneral
    MIN_RANGE_NPROC=${programas_min}
    MAX_RANGE_NPROC=${programas_max}
    calcDatoAleatorioGeneral $MIN_RANGE_NPROC $MAX_RANGE_NPROC
	n_prog=$datoAleatorioGeneral
    MIN_RANGE_quantum=${quantum_min}
    MAX_RANGE_quantum=${quantum_max}
    calcDatoAleatorioGeneral $MIN_RANGE_quantum $MAX_RANGE_quantum
	quantum=$datoAleatorioGeneral
#El resto no se recalcula porque son datos de cada proceso, como tiempo_llegada, tamano_procesos,...
    MIN_RANGE_llegada=${llegada_min}
    MAX_RANGE_llegada=${llegada_max}
    MIN_RANGE_tiempo_ejec=${tiempo_ejec_min}
    MAX_RANGE_tiempo_ejec=${tiempo_ejec_max}
    MIN_RANGE_tamano_marcos_proc=${tamano_marcos_proc_min}
    MAX_RANGE_tamano_marcos_proc=${tamano_marcos_proc_max}
    MIN_RANGE_prio_proc=${prio_proc_min}
    MAX_RANGE_prio_proc=${prio_proc_max}
    MIN_RANGE_tamano_direcciones_proc=${tamano_direcciones_proc_min}
    MAX_RANGE_tamano_direcciones_proc=${tamano_direcciones_proc_max}
 
    datos_memoria_tabla
#No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -e "\n$NC Pulse enter para continuar..." | tee -a $informeConColorTotal
		echo -e "\nPulse enter para continuar..." >> $informeSinColorTotal
		read enter
		echo -e $enter "\n" >> $informeConColorTotal
		echo -e $enter "\n" >> $informeSinColorTotal
	fi
#    clear   
	for (( p=0; p<$n_prog; p++)); do     
#Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 4, 5 y 6. 
#Guarda los datos en los ficheros que correspondan        
#cierre del for   
#Copia los ficheros Default/Último    
#Fin de entradaMemoriaRangosFichero_op_cinco_seis()

#
# Sinopsis: Se guardarán los datos en los ficheros que corresponda para las opciones 5 y 6 
#
function entradaMemoriaRangosFichero_op_cinco_seis_Post_1 {
#No se establece desde fichero sino que se decide en el momento de la ejecución mediante la variable de selección de tipo $seleccionTipoPrioridad.
#M/m
		PrioR="Mayor"
	else    
		PrioR="Menor"                
	fi              
	if [[ $p -eq 0 ]]; then
		echo -ne "Marcos totales\n"$mem_total"\nTamano de pagina\n"$mem_direcciones"\nPrioridad menor\n"$prio_menorInicial\
		"\nPrioridad mayor\n"$prio_mayorInicial"\nTipo de prioridad\n"$PrioR "\nMinimo para reubicabilidad\n"$reub"\nQuantum\n"$quantum\
		"\nTll nMar Prio Direcciones:\n" > $nomFicheroDatos
	fi                  

#Hace que las direcciones sean diferentes en cada proceso.
#Se usarán para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
	MAX_RANGE_PAGINA_MODIFICADA=1
#Muestra las direcciones del proceso calculadas de forma aleatoria.
#Se calcula de forma aleatoria si una página es o no modificada al ser ejecutada.
#Se almacena el cálculo aleatorio de si una página es o no modificada al ser ejecutada.
		direccionesAcumuladas+=`echo -ne " ${directions[$p,$numdir]}-${directions_AlgPagFrecUsoRec_pagina_modificada[$p,$numdir,0]}"`
	done
	echo -e ${llegada[$p]} ${memoria[$p]} ${prioProc[$p]} $direccionesAcumuladas >> $nomFicheroDatos
#Fin de entradaMemoriaRangosFichero_op_cinco_seis()

#
# Sinopsis: Se copian los ficheros que correspondan para las opciones 5 y 6
#
function entradaMemoriaRangosFichero_op_cinco_seis_Post_2 {
#Borra el fichero de datos ultimo y escribe los datos en el fichero
    if [[ -f "$ficheroDatosAnteriorEjecucion" ]]; then
        rm $ficheroDatosAnteriorEjecucion
    fi
    if [[ -f "$ficheroRangosAnteriorEjecucion" && $seleccionMenuEleccionEntradaDatos -ne 5 ]]; then
        rm $ficheroRangosAnteriorEjecucion
    fi
#Copia los ficheros Default/Último       
    if [[ $seleccionMenuEleccionEntradaDatos -ne 5 ]]; then
#Copia los ficheros Default/Último       
    fi
#Fin de entradaMemoriaRangosFichero_op_cinco_seis_Post_2()

#
# Sinopsis: Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 7, 8 y 9. 
#
function entradaMemoriaRangosFichero_op_cuatro_cinco_seis_Comun {                          
#    clear   
    variableReubicar=$reub
#----------------Empieza a introducir procesos------------         
    proc=$(($p-1))
    if [[ $((p + 1)) -ge 10 ]]; then
        nombre="P$((p + 1))"
    else
        nombre="P0$((p + 1))" 
    fi
#Se añade el nombre del proceso al vector
#Se guarda su número en un vector para la función que lo ordena
    calcDatoAleatorioGeneral $MIN_RANGE_llegada $MAX_RANGE_llegada
#Se añade el tiempo de llegada al vector
    calcDatoAleatorioGeneral $MIN_RANGE_tiempo_ejec $MAX_RANGE_tiempo_ejec
#Se añade el tiempo de ejecución al vector
    calcDatoAleatorioGeneral $MIN_RANGE_tamano_marcos_proc $MAX_RANGE_tamano_marcos_proc
#Se añade el tamaño de ejecución al vector
    calcDatoAleatorioGeneral $prio_menor $prio_mayor
#Se añade la prioridad del proceso al vector
#Se crea otra variable para hacer compatible este código con otro código anterior.
    
#Se definen las Direcciones de cada Proceso
#Para ser equivalente al nuevo programa 
#Primero se calcula el tamaño en direcciones del proceso.
	tamano_direcciones_proc=$datoAleatorioGeneral
	for (( numdir = 0; numdir <= ${ejecucion[$p]}; numdir++ )); do
#Luego se calculan las direcciones aplicando la búsqueda aleatoria hasta el tamaño en direcciones dle proceso precalculado.
		directions[$p,$numdir]=$datoAleatorioGeneral
#$numDireccionesTotales_max viene de leer_rangos_desde_fichero() y se comparará con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.
			echo -e "\n***Error en la lectura de rangos. La dirección de memoria utilizada ("${directions[$p,$numdir]}") está fuera del rango máximo definido por el número de marcos de página ("$(($numDireccionesTotales_max - 1))")."
			exit 1 
		fi
#let pagTransformadas[$2]=`expr $1/$mem_direcciones`
		paginasDefinidasTotal[$p,$numdir]=${pagTransformadas[$numdir]} 
	done
#Fin de entradaMemoriaRangosFichero_op_cuatro_cinco_seis_Comun()
            
# 
# Sinopsis: Pregunta en qué fichero guardar los rangos para la opción 8.
#
function entradaMemoriaRangosFichero_op_siete_Previo {
#    clear 
#Resuelve los nombres de los ficheros de rangos amplios
#Resuelve los nombres de los ficheros de rangos
#Resuelve los nombres de los ficheros de datos
#Fin de entradaMemoriaRangosFichero_op_siete_Previo()

#
# Sinopsis: Se piden y tratan los mínimos y máximos de los rangos para las opciones 7, 8 y 9. El cálculo de los datos 
# aleatorios con los que se trabajará se hace en entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun.  
#
function entradaMemoriaRangosFichero_op_siete_ocho_nueve { 
    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
#Llamada a funciones para definir las variables con los límites de los rangos amplios.
    fi                     
#Se definen nuevas variables para redefinir los límites de los subrangos sacados de los rangos amplios. 
	MIN_RANGE_MARCOSInicial=$datoAleatorioGeneral	
    calcDatoAleatorioGeneral $memoria_minInicial $memoria_maxInicial 
    MAX_RANGE_MARCOSInicial=$datoAleatorioGeneral
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_MARCOS=$PriomFinal
	MAX_RANGE_MARCOS=$PrioMFinal
#Se calculan los valores que no dependen de los procesos desde los subrangos ya calculados. 
	mem_total=$datoAleatorioGeneral

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_numero_direcciones_marco_amplio 
    fi                     
    calcDatoAleatorioGeneral $direcciones_minInicial $direcciones_maxInicial 
	MIN_RANGE_DIRECCIONESInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $direcciones_minInicial $direcciones_maxInicial 
    MAX_RANGE_DIRECCIONESInicial=$datoAleatorioGeneral
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_DIRECCIONES=$PriomFinal
	MAX_RANGE_DIRECCIONES=$PrioMFinal
    calcDatoAleatorioGeneral $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
	mem_direcciones=$datoAleatorioGeneral
#Dato usado para compararlo con la mayor dirección a ejecutar para saber si cabe en memoria No Virtual.

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_prio_menor_amplio 
    fi                     
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#Variables con los originales usadas para calcular subrangos y datos finales 
	prio_menor_max=$PrioMFinal
#Prioridades asociadas a los procesos.
#Desde este rango amplio se calculan los subrangos desde los que calcular el rango desde el que calcular los datos.
#calcMaxPrioPro 
    MAX_RANGE_prio_menorInicial=$datoAleatorioGeneral          
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_prio_menor=$PriomFinal
	MAX_RANGE_prio_menor=$PrioMFinal
#Datos generales
#Desde este subrango se calcula el rango desde el que calcular los datos.

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_prio_mayor_amplio 
    fi                     
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	prio_mayor_min=$PriomFinal
	prio_mayor_max=$PrioMFinal
#Prioridades asociadas a los procesos.
	MIN_RANGE_prio_mayorInicial=$datoAleatorioGeneral
#calcMaxPrioPro 
    MAX_RANGE_prio_mayorInicial=$datoAleatorioGeneral          
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_prio_mayor=$PriomFinal
	MAX_RANGE_prio_mayor=$PrioMFinal
#Datos generales
	prio_mayorInicial=$datoAleatorioGeneral

#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#Desde este rango se calculan los datos.
	prio_mayor=$PrioMFinal

#Variables con los datos originales usadas en la cabecera de la representación de la tabla
	PrioMInicial=$prio_mayorInicial

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_tamano_reubicacion_amplio 
    fi                     
    calcDatoAleatorioGeneral $reubicacion_minInicial $reubicacion_maxInicial 
	MIN_RANGE_REUBInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $reubicacion_minInicial $reubicacion_maxInicial 
    MAX_RANGE_REUBInicial=$datoAleatorioGeneral
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_REUB=$PriomFinal
	MAX_RANGE_REUB=$PrioMFinal
    calcDatoAleatorioGeneral $MIN_RANGE_REUB $MAX_RANGE_REUB
	reub=$datoAleatorioGeneral

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_numero_programas_amplio 
    fi                     
    calcDatoAleatorioGeneral $programas_minInicial $programas_maxInicial 
	MIN_RANGE_NPROCInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $programas_minInicial $programas_maxInicial 
    MAX_RANGE_NPROCInicial=$datoAleatorioGeneral
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_NPROC=$PriomFinal
	MAX_RANGE_NPROC=$PrioMFinal
    calcDatoAleatorioGeneral $MIN_RANGE_NPROC $MAX_RANGE_NPROC
	n_prog=$datoAleatorioGeneral

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_tiempo_llegada_amplio 
    fi                     
    calcDatoAleatorioGeneral $llegada_minInicial $llegada_maxInicial 
	MIN_RANGE_llegadaInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $llegada_minInicial $llegada_maxInicial 
    MAX_RANGE_llegadaInicial=$datoAleatorioGeneral
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_llegada=$PriomFinal
	MAX_RANGE_llegada=$PrioMFinal

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_tiempo_ejecucion_amplio 
    fi                     
    calcDatoAleatorioGeneral $tiempo_ejec_minInicial $tiempo_ejec_maxInicial 
	MIN_RANGE_tiempo_ejecInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $tiempo_ejec_minInicial $tiempo_ejec_maxInicial 
    MAX_RANGE_tiempo_ejecInicial=$datoAleatorioGeneral
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_tiempo_ejec=$PriomFinal
	MAX_RANGE_tiempo_ejec=$PrioMFinal
    
    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_tamano_marcos_procesos_amplio 
    fi                     
    calcDatoAleatorioGeneral $tamano_marcos_proc_minInicial $tamano_marcos_proc_maxInicial 
	MIN_RANGE_tamano_marcos_procInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $tamano_marcos_proc_minInicial $tamano_marcos_proc_maxInicial 
    MAX_RANGE_tamano_marcos_procInicial=$datoAleatorioGeneral
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_tamano_marcos_proc=$PriomFinal
	MAX_RANGE_tamano_marcos_proc=$PrioMFinal

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_quantum_amplio 
    fi                     
    calcDatoAleatorioGeneral $quantum_minInicial $quantum_maxInicial 
	MIN_RANGE_quantumInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $quantum_minInicial $quantum_maxInicial 
    MAX_RANGE_quantumInicial=$datoAleatorioGeneral
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_quantum=$PriomFinal
	MAX_RANGE_quantum=$PrioMFinal
    calcDatoAleatorioGeneral $MIN_RANGE_quantum $MAX_RANGE_quantum
	quantum=$datoAleatorioGeneral

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_tamano_direcciones_procesos_amplio 
    fi                     
    calcDatoAleatorioGeneral $tamano_direcciones_proc_minInicial $tamano_direcciones_proc_maxInicial 
	MIN_RANGE_tamano_direcciones_procInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $tamano_direcciones_proc_minInicial $tamano_direcciones_proc_maxInicial 
    MAX_RANGE_tamano_direcciones_procInicial=$datoAleatorioGeneral
#Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_tamano_direcciones_proc=$PriomFinal
	MAX_RANGE_tamano_direcciones_proc=$PrioMFinal    
#------------------------------------------------------ 
#Se imprime una tabla con los datos de los rangos introducidos, los subrangos y los valores calculables.

#    clear
    p=0
    until [[ $p -eq $n_prog ]]; do  
#Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 7, 8 y 9. 
#Guarda los datos en los ficheros que correspondan
#        clear
#Se incrementa el contador
#cierre del do del while $pro=="S"
#Copia los ficheros Default/Último
#Fin de entradaMemoriaRangosFichero_op_siete_ocho_nueve()

#
# Sinopsis: Se guardarán los datos en los ficheros que corresponda para la opción 4
#
function entradaMemoriaRangosFichero_op_siete_ocho_nueve_Post_1 { 
#No se establece desde fichero sino que se decide en el momento de la ejecución mediante la variable de selección de tipo $seleccionTipoPrioridad.
#M/m
		PrioR="Mayor"
	else    
		PrioR="Menor"                
	fi              
	if [[ $p -eq 0 ]]; then
		echo -ne "Marcos totales\n"$mem_total"\nTamano de pagina\n"$mem_direcciones"\nPrioridad menor\n"$prio_menorInicial\
		"\nPrioridad mayor\n"$prio_mayorInicial"\nTipo de prioridad\n"$PrioR "\nMinimo para reubicabilidad\n"$reub"\nQuantum\n"$quantum\
		"\nTll nMar Prio Direcciones:\n" > $nomFicheroDatos
	fi                  

#Hace que las direcciones sean diferentes en cada proceso.
#Se usarán para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
	MAX_RANGE_PAGINA_MODIFICADA=1
#Muestra las direcciones del proceso calculadas de forma aleatoria.
#Se calcula de forma aleatoria si una página es o no modificada al ser ejecutada.
#Se almacena el cálculo aleatorio de si una página es o no modificada al ser ejecutada.
		direccionesAcumuladas+=`echo -ne " ${directions[$p,$numdir]}-${directions_AlgPagFrecUsoRec_pagina_modificada[$p,$numdir,0]}"`
	done
	echo -e ${llegada[$p]} ${memoria[$p]} ${prioProc[$p]} $direccionesAcumuladas >> $nomFicheroDatos

#Escribe los rangos en el fichero de rangos selecionado (RangosAleTotalDefault.txt, o el elegido por el usuario). 
        if [[ -f "$nomFicheroRangos" ]]; then
            rm $nomFicheroRangos
        fi 
        echo -e "RangoMarcosMemoria $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS" > $nomFicheroRangos 
        echo -e "RangoDireccionesMarco $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES" >> $nomFicheroRangos 
        echo -e "RangoPrioMenor $MIN_RANGE_prio_menorInicial $MAX_RANGE_prio_menorInicial" >> $nomFicheroRangos 
        echo -e "RangoPrioMayor $MIN_RANGE_prio_mayorInicial $MAX_RANGE_prio_mayorInicial" >> $nomFicheroRangos 
        echo -e "RangoNumProc $MIN_RANGE_NPROC $MAX_RANGE_NPROC" >> $nomFicheroRangos 
        echo -e "RangoReubicar $MIN_RANGE_REUB $MAX_RANGE_REUB" >> $nomFicheroRangos 
        echo -e "RangoLlegada $MIN_RANGE_llegada $MAX_RANGE_llegada" >> $nomFicheroRangos 
        echo -e "RangoTEjecucion $MIN_RANGE_tiempo_ejec $MAX_RANGE_tiempo_ejec" >> $nomFicheroRangos 
        echo -e "RangoTamanoMarcosProc $MIN_RANGE_tamano_marcos_proc $MAX_RANGE_tamano_marcos_proc" >> $nomFicheroRangos
        echo -e "RangoPrioProc $prio_menorInicial $prio_mayorInicial" >> $nomFicheroRangos
        echo -e "RangoTamanoDireccionesProc $MIN_RANGE_tamano_direcciones_proc $MAX_RANGE_tamano_direcciones_proc" >> $nomFicheroRangos
        echo -ne "RangoQuantum $MIN_RANGE_quantum $MAX_RANGE_quantum" >> $nomFicheroRangos
#Cierre if $p -eq 1 
#Escribe los rangos en el fichero de rangos amplios selecionado 
        if [[ -f "$nomFicheroRangosAleT" ]]; then 
            rm $nomFicheroRangosAleT
        fi
        echo -e "RangoMarcosMemoria $memoria_min $memoria_max" > $nomFicheroRangosAleT  
        echo -e "RangoDireccionesMarco $direcciones_min $direcciones_max" >> $nomFicheroRangosAleT 
        echo -e "RangoPrioMenor $prio_menor_minInicial $prio_menor_maxInicial" >> $nomFicheroRangosAleT 
        echo -e "RangoPrioMayor $prio_mayor_minInicial $prio_mayor_maxInicial" >> $nomFicheroRangosAleT 
        echo -e "RangoNumProc $programas_min $programas_max" >> $nomFicheroRangosAleT 
        echo -e "RangoReubicar $reubicacion_min $reubicacion_max" >> $nomFicheroRangosAleT 
        echo -e "RangoLlegada $llegada_min $llegada_max" >> $nomFicheroRangosAleT 
        echo -e "RangoTEjecucion $tiempo_ejec_min $tiempo_ejec_max" >> $nomFicheroRangosAleT 
        echo -e "RangoTamanoMarcosProc $tamano_marcos_proc_min $tamano_marcos_proc_max" >> $nomFicheroRangosAleT
        echo -e "RangoPrioProc $prio_menorInicial $prio_mayorInicial" >> $nomFicheroRangosAleT
        echo -e "RangoTamanoDireccionesProc $tamano_direcciones_proc_min $tamano_direcciones_proc_max" >> $nomFicheroRangosAleT
        echo -ne "RangoQuantum $quantum_min $quantum_max" >> $nomFicheroRangosAleT
#Cierre if $p -eq 1
#Fin de entradaMemoriaRangosFichero_op_siete_Post_1()

#
# Sinopsis: Se copian los ficheros que correspondan para la opción 4
#
function entradaMemoriaRangosFichero_op_siete_ocho_nueve_Post_2 { 
#Borra el fichero de datos ultimo y escribe los datos en el fichero
        rm $ficheroDatosAnteriorEjecucion
    fi
#Borra el fichero de datos ultimo y escribe los rangos en el fichero
        rm $ficheroRangosAnteriorEjecucion
    fi
    cp $nomFicheroDatos $ficheroDatosAnteriorEjecucion
    cp $nomFicheroRangos $ficheroRangosAnteriorEjecucion
#Actualiza el fichero de rangos amplios de última ejecución (RangosAleTotalLast.txt) como copia del fichero utilizado para los rangos amplios (RangosAleTotalDefault.txt, o el elegido por el usuario).
#Borra el fichero de datos ultimo y escribe los rangos amplios en el fichero
			rm $ficheroRangosAleTotalAnteriorEjecucion
		fi
		cp $nomFicheroRangosAleT $ficheroRangosAleTotalAnteriorEjecucion        
    fi
#Fin de entradaMemoriaRangosFichero_op_siete_Post_2()
           
#
# Sinopsis: Pregunta en qué fichero guardar los rangos para la opción 8.
#
function entradaMemoriaRangosFichero_op_ocho_Previo {
#    clear
#Resuelve los nombres de los ficheros de rangos
#Resuelve los nombres de los ficheros de datos
#Fin de entradaMemoriaRangosFichero_op_ocho_Previo()

#
# Sinopsis: Pregunta en qué fichero guardar los rangos amplios para la opción 9.
#
function entradaMemoriaRangosFichero_op_nueve_Previo {
#    clear
#Resuelve los nombres de los ficheros de rangos
#Resuelve los nombres de los ficheros de datos
    echo -e "\n\nFicheros existentes:\n$NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\nFicheros existentes:\n" >> $informeSinColorTotal  
    files=("./FRangosAleT"/*)
#Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#Define el dato, pero no en qué posción se encuentra.
        echo -e "$i) ${files[$i]}" | tee -a $informeConColorTotal
        echo -e "$i) ${files[$i]}" >> $informeSinColorTotal  
    done
    echo -e "\n$AMARILLO\n\nIntroduce el número correspondiente al fichero elegido: $NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\n\nIntroduce el número correspondiente al fichero elegido: " >> $informeSinColorTotal 
    read -r numeroFichero
#files[@]} ]]; do
        echo -ne "Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read -r numeroFichero
        echo -e "$numeroFichero\n\n" >> $informeConColorTotal
        echo -e "$numeroFichero\n\n" >> $informeSinColorTotal
    done
    echo "$numeroFichero" >> $informeConColorTotal
    echo "$numeroFichero" >> $informeSinColorTotal
    ficheroParaLectura="${files[$numeroFichero]}"
#    clear
#Fin de entradaMemoriaRangosFichero_op_nueve_Previo()

#
# Sinopsis: Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 7, 8 y 9. 
#
function entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun {                          
#    clear   
    variableReubicar=$reub
#------------------------------Empieza a introducir procesos--------------------            
    if [[ $p -eq 0 ]] ; then
        if [[ -f $informeConColorTotal ]] ; then
            if [[ $seleccionMenuPreguntaDondeGuardarDatosManuales == "1" ]] ; then
                rm $ficheroDatosDefault
            fi
        fi
    fi
    if [[ $p -eq 0 ]] ; then
        if [[ -f $informeConColorTotal ]] ; then
            if [[ $seleccionMenuPreguntaDondeGuardarRangosManuales == "1" ]] ; then
                rm $ficheroRangosDefault
            fi
        fi
    fi
    proc=$(($p-1))
    if [[ $((p + 1)) -ge 10 ]]; then
        nombre="P$((p + 1))"
    else
        nombre="P0$((p + 1))" 
    fi
#Se añade a el vector ese nombre
#Se guarda su número en un vector para la función que lo ordena
# Generar un número aleatorio dentro del rango
# Generar un número aleatorio dentro del rango
# Generar un número aleatorio dentro del rango

    calcDatoAleatorioGeneral $prio_menor $prio_mayor
#Sobra uno
#Se añade el tamaño de ejecución al vector

#Se definen las Direcciones de cada Proceso
#Para ser equivalente al nuevo programa
#Primero se calcula el tamaño en direcciones del proceso.
	tamano_direcciones_proc=$datoAleatorioGeneral
	for (( numdir = 0; numdir <= ${ejecucion[$p]}; numdir++ )); do
#Luego se calculan las direcciones aplicando la búsqueda aleatoria hasta el tamaño en direcciones dle proceso precalculado.
		directions[$p,$numdir]=$datoAleatorioGeneral
#$numDireccionesTotales_max viene de leer_rangos_desde_fichero() y se comparará con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.
			echo -e "\n***Error en la lectura de rangos amplios. La dirección de memoria utilizada ("${directions[$p,$numdir]}") está fuera del rango máximo definido por el número de marcos de página ("$(($numDireccionesTotales_max - 1))")."
			exit 1
		fi
#let pagTransformadas[$2]=`expr $1/$mem_direcciones`
		paginasDefinidasTotal[$p,$numdir]=${pagTransformadas[$numdir]} 
	done
#Fin de entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun()

#
# Sinopsis: Calcula los datos de la tabla resumen de procesos en cada volcado
#
#ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAR LAS VARIABLES.
#Modificamos los valores de los arrays, restando de lo que quede
        if [[ ${enejecucion[$i]} -eq 1 ]]; then  
            temp_rej[$i]=`expr ${temp_rej[$i]} - 1`
#Se suman para evitar que en el último segundo de ejecución no se sume el segundo de retorno
        fi
#estado[$i]="Bloqueado" - En espera
            temp_wait[$i]=`expr ${temp_wait[$i]} + 1`
            temp_ret[$i]=`expr ${temp_ret[$i]} + 1`
        fi
#estado[$i]="En ejecucion"
            temp_wait[$i]=`expr ${temp_wait[$i]} + 0`
#estado[$i]="En pausa" - En pausa
            temp_wait[$i]=`expr ${temp_wait[$i]} + 1`
            temp_ret[$i]=`expr ${temp_ret[$i]} + 1`
#estado[$i]="En memoria"
            temp_wait[$i]=`expr ${temp_wait[$i]} + 1`
            temp_ret[$i]=`expr ${temp_ret[$i]} + 1`
        fi
#Si ha terminado, no se hace nada. Y si no ha llegado, su tiempo de espera es "-"
#Se ponen todas las posiciones del vector enejecucion a 0, se establecerá qué proceso está a 1 en cada ciclo del programa.
#Se desbloquean todos y se establecerán los procesos bloqueados en cada ciclo.
    done
# Se incrementa el reloj
#Final de los cálculos para dibujar la banda de tiempos - ajusteFinalTiemposEsperaEjecucionRestante

#
# Sinopsis: Se muestran los eventos sucedidos, sobre la tabla resumen.
#
function mostrarEventos {
#    clear
#Inicializo evento
#Se muestran los datos sobre las indicaciones del evento que ha sucedido
    Dato1=""
    Dato2=""
    Dato3=""
#Paginado pero No Virtual
        algoritmoSeleccionado="FCFS-PaginaciónNoVirtual-"
#FCFS/SJF/SRPT
        algoritmoSeleccionado="FCFS-Paginación-"
    elif [[ $seleccionMenuAlgoritmoGestionProcesos -eq 2 ]]; then    
        algoritmoSeleccionado="SJF-Paginación-"
    elif [[ $seleccionMenuAlgoritmoGestionProcesos -eq 3 ]]; then    
        algoritmoSeleccionado="SRPT-Paginación-" 
    elif [[ $seleccionMenuAlgoritmoGestionProcesos -eq 4 ]]; then    
        algoritmoSeleccionado="Prioridades-"    
#M/m
			algoritmoSeleccionado+="Mayor-"
		else    
			algoritmoSeleccionado+="Menor-"                
		fi              
#M/m
			algoritmoSeleccionado+="NoApropiativo-Paginación-"
		else    
			algoritmoSeleccionado+="Apropiativo-Paginación-"                
		fi  
		Dato2=" Prio.Mínima="$PriomInicial" Prio.Máxima="$PrioMInicial            
    elif [[ $seleccionMenuAlgoritmoGestionProcesos -eq 5 ]]; then    
        algoritmoSeleccionado="RoundRobin(RR)-Paginación-" 
        Dato3=" Quantum="$quantum
    fi
    if [[ $seleccionAlgoritmoPaginacion -eq 1 ]]; then    
        algoritmoPaginacionSeleccionado="FIFO-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 2 ]]; then    
        algoritmoPaginacionSeleccionado="FIFOSegOp-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 3 ]]; then    
        algoritmoPaginacionSeleccionado="Reloj-"             
    elif [[ $seleccionAlgoritmoPaginacion -eq 4 ]]; then    
        algoritmoPaginacionSeleccionado="RelojSegOp-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then    
        algoritmoPaginacionSeleccionado="Óptimo-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 6 ]]; then 
        algoritmoPaginacionSeleccionado="MFU-" 
    elif [[ $seleccionAlgoritmoPaginacion -eq 7 ]]; then    
        algoritmoPaginacionSeleccionado="LFU-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 8 ]]; then    
        algoritmoPaginacionSeleccionado="NFU/MFU-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 9 ]]; then    
        algoritmoPaginacionSeleccionado="NFU/LFU-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 10 ]]; then    
        algoritmoPaginacionSeleccionado="NFU/Clases/MFU-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 11 ]]; then    
        algoritmoPaginacionSeleccionado="NFU/Clases/LFU-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 12 ]]; then    
        algoritmoPaginacionSeleccionado="MRU-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 13 ]]; then    
        algoritmoPaginacionSeleccionado="LRU-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 14 ]]; then    
        algoritmoPaginacionSeleccionado="NRU/MRU-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 15 ]]; then    
        algoritmoPaginacionSeleccionado="NRU/LRU-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 16 ]]; then    
        algoritmoPaginacionSeleccionado="NRU/Clases/MRU-"                
    elif [[ $seleccionAlgoritmoPaginacion -eq 17 ]]; then    
        algoritmoPaginacionSeleccionado="NRU/Clases/LRU-"                
    fi
#C/NC
        continuidadSeleccionado="NC-"
    else    
        continuidadSeleccionado="C-"                
    fi
#R/NR
        reubicabilidadSeleccionado="NR"
    else    
        reubicabilidadSeleccionado="R" 
        Dato1=" Máx.Reubicación="$variableReubicar             
    fi
    
    algoritmoPaginacionContinuidadReubicabilidadSeleccionado="$algoritmoSeleccionado""$algoritmoPaginacionSeleccionado""$continuidadSeleccionado""$reubicabilidadSeleccionado"
    echo " $algoritmoPaginacionContinuidadReubicabilidadSeleccionado" | tee -a $informeConColorTotal
    echo " $algoritmoPaginacionContinuidadReubicabilidadSeleccionado" >> ./$informeSinColorTotal
    echo -e $NC" Reloj="$reloj" Mem.Total="$mem_total" Mem.Libre="$mem_libre$Dato1$Dato2$Dato3 | tee -a $informeConColorTotal
    echo -e " Reloj="$reloj" Mem.Total="$mem_total" Mem.Libre="$mem_libre$Dato1$Dato2$Dato3 >> $informeSinColorTotal
#Se muestra el evento que ha sucedido       
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisosalida[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha salido de memoria." | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha salido de memoria." >> $informeSinColorTotal
#Se borra el uno para que no se vuelva a imprimir 
        fi
    done
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisollegada[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha llegado al sistema." | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha llegado al sitema." >> $informeSinColorTotal
#Se borra el uno para que no se vuelva a imprimir 
        fi
    done
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisoentrada[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha entrado de memoria. " | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha entrado en memoria." >> $informeSinColorTotal
#Se borra el uno para que no se vuelva a imprimir 
        fi
    done
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisoEntradaCPU[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha entrado en CPU. " | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha entrado en CPU." >> $informeSinColorTotal
#Se borra el uno para que no se vuelva a imprimir 
        fi
    done
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisoPausa[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha quedado en pausa. " | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha quedado en pausa." >> $informeSinColorTotal
#Se borra el uno para que no se vuelva a imprimir 
        fi
    done
#Fin de mostrarEventos() - Final de mostrar los eventos sucedidos - mostrarEventos

#
# Sinopsis: Prepara e imprime la tabla resumen de procesos en cada volcado - SIN CUADRO
#
function dibujarTablaDatos {
    mem_aux=$[ $mem_total -1 ]
    j=0
    k=0
    for (( i=0; i<$nprocesos; i++ )); do
        if [[ ${enmemoria[$i]} -eq 1 ]]; then
#Se guardan en cada posición el número del proceso correspondiente 
            coloresAux[$k]=${coloress[$i % 6]} 
            j=`expr $j + 1`
        fi
        k=`expr $k + 1`
    done
    j=0
    k=0
#CALCULAR LOS DATOS A REPRESENTAR.
    cont=0
    for (( i=0; i<$nprocesos; i++ )); do
        if [[ ${enmemoria[$i]} -eq 1 ]]; then
            enmemoriavec[$cont]=$i
            cont=$[ $cont + 1 ]
            if [[ ${guardados[0]} -eq $i ]]; then  
                pos_inicio[$i]=0 
                pos_final[$i]=$[ ${memoriaAuxiliar[$i]} -1 ]
                mem_aux=`expr $mem_aux - ${memoriaAuxiliar[$i]}`
                pos_aux=${pos_final[$i]}
            else
                pos_inicio[$i]=$pos_aux 
                pos_final[$i]=`expr ${pos_inicio[$i]} + ${memoriaAuxiliar[$i]}`
                mem_aux=`expr $mem_aux - ${memoriaAuxiliar[$i]}`
                pos_aux=${pos_final[$i]}
            fi
        fi
#No llegado
            inicio2[$i]="-"
            final2[$i]="-" 
            temp_wait[$i]="-"
            temp_ret[$i]="-"
            temp_rej[$i]="-"
            estado[$i]="Fuera del Sistema"
#En espera
            inicio2[$i]="-"
            final2[$i]="-"
            estado[$i]="En espera"
#En memoria
            estado[$i]="En memoria"
#En ejecucion
            estado[$i]="En ejecución"
#En ejecucion
            estado[$i]="En pausa"
#Finalizado
            inicio2[$i]="-"
            final2[$i]="-" 
            temp_rej[$i]="-"
            estado[$i]="Finalizado"
        fi
            varC[$i]=${coloress[$i % 6]}
    done

#REPRESENTAR LOS DATOS
#Se ajusta a parte el vector de memoria inicial y final NO CONTINUA para CUADRAR (he comentado lo que cuadraba lo de antes)(modificación 2020)
#Ajuste para la memoria no continua en un auxiliar (se imprime el auxiliar)
#Se copia los normales al auxiliar
    inicialNCaux=("${inicialNC[@]}")
    finalNCaux=("${finalNC[@]}")
 	datos4=""
#Si han sido usadas, se subrayan
		datos4="-Modificación"
	fi

#Para Prioridades
		echo -e " Ref Tll Tej Mem Pri TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " | tee -a $informeConColorTotal   
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────────" | tee -a $informeConColorTotal
		echo -e " Ref Tll Tej Mem Pri TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " >> $informeSinColorTotal
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────────" >> $informeSinColorTotal
#Se aplica el $m a memoria inicial y memoria final (los auxiliares que son los que se imprimen en el volcado)
#Se usa m porque i recorre los procesos y m controla las unidades usadas por cada proceso, normalmente 0 o 1, y también las unidades de los n trozos de memoria asociados a cada proceso. 
			echo -ne " ${varC[$i]}${proceso[$i]}$NC"\
#ejecucion[$i]})${varC[$i]}${ejecucion[$i]}$NC"\
#prioProc[$i]})${varC[$i]}${prioProc[$i]}$NC"\
#temp_ret[$i]})${varC[$i]}${temp_ret[$i]}$NC"\
#inicialNCaux[$m]})${varC[$i]}${inicialNCaux[$m]}$NC"\
#estado[$i]})$NC " | tee -a $informeConColorTotal
			DireccionesPaginasPorProceso=""
#Subrayado
			datos4=""
			for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then 
					datos4="-"${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				fi
#Si han sido usadas, se subrayan
					kk=" $varImprimirPaginaUsada${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4$NC"
					DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$i]}$varImprimirPaginaUsada${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4$NC"
				else
					DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$i]}${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4"
				fi
			done
			echo -e $DireccionesPaginasPorProceso | tee -a $informeConColorTotal
			echo -ne " ${proceso[$i]}"\
#ejecucion[$i]})${ejecucion[$i]}"\
#prioProc[$i]})${prioProc[$i]}}"\
#temp_ret[$i]})${temp_ret[$i]}"\
#inicialNCaux[$m]})${inicialNCaux[$m]}"\
#estado[$i]}) " >> $informeSinColorTotal
			DireccionesPaginasPorProceso=""
			datos4=""
			for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then 
					datos4="-"${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				fi
				DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4"
			done
			echo -e $DireccionesPaginasPorProceso >> $informeSinColorTotal
			
			m=$((m+1))
			for (( b=1; b<${bloques[$i]}; b++ )) ; do
#inicialNCaux[$m]})${varC[$i]}${inicialNCaux[$m]}$NC " | tee -a $informeConColorTotal
#finalNCaux[$m]})${varC[$i]}${finalNCaux[$m]}$NC                  " | tee -a $informeConColorTotal
#inicialNCaux[$m]})${inicialNCaux[$m]} " >> $informeSinColorTotal
#finalNCaux[$m]})${finalNCaux[$m]}                   " >> $informeSinColorTotal
				m=$((m+1))
			done
		done
#Para Round-Robin 
		echo -e " Ref Tll Tej Mem TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " | tee -a $informeConColorTotal   
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────" | tee -a $informeConColorTotal
		echo -e " Ref Tll Tej Mem TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " >> $informeSinColorTotal
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────" >> $informeSinColorTotal
#Se aplica el $m a memoria inicial y memoria final (los auxiliares que son los que se imprimen en el volcado)
#Se usa m porque i recorre los procesos y m controla las unidades usadas por cada proceso, normalmente 0 o 1, y también las unidades de los n trozos de memoria asociados a cada proceso. 
			echo -ne " ${varC[$i]}${proceso[$i]}$NC"\
#ejecucion[$i]})${varC[$i]}${ejecucion[$i]}$NC"\
#temp_wait[$i]})${varC[$i]}${temp_wait[$i]}$NC"\
#temp_rej[$i]})${varC[$i]}${temp_rej[$i]}$NC"\
#finalNCaux[$m]})${varC[$i]}${finalNCaux[$m]}$NC"\
#estado[$i]})$NC " | tee -a $informeConColorTotal
			DireccionesPaginasPorProceso=""
#Subrayado
			datos4=""
			for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then 
					datos4="-"${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				fi
#Si han sido usadas, se subrayan
					kk=" $varImprimirPaginaUsada${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4$NC"
					DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$i]}$varImprimirPaginaUsada${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4$NC"
				else
					DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$i]}${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4"
				fi
			done
			echo -e $DireccionesPaginasPorProceso | tee -a $informeConColorTotal
		   
			echo -ne " ${proceso[$i]}"\
#ejecucion[$i]})${ejecucion[$i]}"\
#temp_wait[$i]})${temp_wait[$i]}"\
#temp_rej[$i]})${temp_rej[$i]}"\
#finalNCaux[$m]})${finalNCaux[$m]}"\
#estado[$i]}) " >> $informeSinColorTotal
			DireccionesPaginasPorProceso=""
			datos4=""
			for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then 
					datos4="-"${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				fi
				DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4"
			done
			echo -e $DireccionesPaginasPorProceso >> $informeSinColorTotal
			
			m=$((m+1))
			for (( b=1; b<${bloques[$i]}; b++ )) ; do
#inicialNCaux[$m]})${varC[$i]}${inicialNCaux[$m]}$NC " | tee -a $informeConColorTotal
#finalNCaux[$m]})${varC[$i]}${finalNCaux[$m]}$NC                  " | tee -a $informeConColorTotal
#inicialNCaux[$m]})${inicialNCaux[$m]} " >> $informeSinColorTotal
#finalNCaux[$m]})${finalNCaux[$m]}                   " >> $informeSinColorTotal
				m=$((m+1))
			done
		done
#Para FCFS/SJF/SRPT 
		echo -e " Ref Tll Tej Mem TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " | tee -a $informeConColorTotal   
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────" | tee -a $informeConColorTotal
		echo -e " Ref Tll Tej Mem TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " >> $informeSinColorTotal
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────" >> $informeSinColorTotal
#Se aplica el $m a memoria inicial y memoria final (los auxiliares que son los que se imprimen en el volcado)
#Se usa m porque i recorre los procesos y m controla las unidades usadas por cada proceso, normalmente 0 o 1, y también las unidades de los n trozos de memoria asociados a cada proceso. 
			echo -ne " ${varC[$i]}${proceso[$i]}$NC"\
#ejecucion[$i]})${varC[$i]}${ejecucion[$i]}$NC"\
#temp_wait[$i]})${varC[$i]}${temp_wait[$i]}$NC"\
#temp_rej[$i]})${varC[$i]}${temp_rej[$i]}$NC"\
#finalNCaux[$m]})${varC[$i]}${finalNCaux[$m]}$NC"\
#estado[$i]})$NC " | tee -a $informeConColorTotal
			DireccionesPaginasPorProceso=""
#Subrayado
			datos4=""
			for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then 
					datos4="-"${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				fi
#Si han sido usadas, se subrayan
					kk=" $varImprimirPaginaUsada${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4$NC"
					DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$i]}$varImprimirPaginaUsada${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4$NC"
				else
					DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$i]}${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4"
				fi
			done
			echo -e $DireccionesPaginasPorProceso | tee -a $informeConColorTotal
		   
			echo -ne " ${proceso[$i]}"\
#ejecucion[$i]})${ejecucion[$i]}"\
#temp_wait[$i]})${temp_wait[$i]}"\
#temp_rej[$i]})${temp_rej[$i]}"\
#finalNCaux[$m]})${finalNCaux[$m]}"\
#estado[$i]}) " >> $informeSinColorTotal
			DireccionesPaginasPorProceso=""
			datos4=""
			for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then 
					datos4="-"${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				fi
				DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4"
			done
			echo -e $DireccionesPaginasPorProceso >> $informeSinColorTotal
			
			m=$((m+1))
			for (( b=1; b<${bloques[$i]}; b++ )) ; do
#inicialNCaux[$m]})${varC[$i]}${inicialNCaux[$m]}$NC " | tee -a $informeConColorTotal
#finalNCaux[$m]})${varC[$i]}${finalNCaux[$m]}$NC                  " | tee -a $informeConColorTotal
#inicialNCaux[$m]})${inicialNCaux[$m]} " >> $informeSinColorTotal
#finalNCaux[$m]})${finalNCaux[$m]}                   " >> $informeSinColorTotal
				m=$((m+1))
			done
		done
	fi

#CALCULAR Y REPRESENTAR LOS PROMEDIOS
    dividir=0
    for (( i=0; i<nprocesos; i++ )) ; do
        if [[ ${estad[$i]} -ne 0 ]] ; then 
            dividir=$((dividir+1))
        fi
    done
    promedio_espera=0.0
    promedio_retorno=0.0
    suma_espera=0
    suma_retorno=0

    for (( i=0; i<nprocesos; i++ )); do
        tam=${memoria[$i]};
#Si el tamaño del proceso es menor o igual que el de memoria
#suma para sacar su promedio
#promedio
#suma para sacar su promedio
#promedio
        fi
    done
    var_uno=1
    echo -e "$NC T. espera medio: $promedio_espera\t      T. retorno medio: $promedio_retorno$NC" | tee -a $informeConColorTotal 
    echo -e " T. espera medio: $promedio_espera\t       T. retorno medio: $promedio_retorno" >> ./$informeSinColorTotal
#Fin de dibujarTablaDatos() - Final de dibujar la banda de tiempos - dibujarTablaDatos

#
# Sinopsis: Sacar procesos terminados de memoria y actualizar variables de la Banda de Memoria.
#
function calculosActualizarVariablesBandaMemoria {
#Sucesión: sacar procesos, actualizar variables de memoria guardadoMemoria y tamanoGuardadoMemoria
#Se libera espacio en memoria de los procesos recien terminados. 
        if [[ ${enmemoria[$po]} == 0 && ${escrito[$po]} == 1 ]]; then 
            for (( ra=0; ra<$mem_total; ra++ )); do
                if [[ ${unidMemOcupadas[$ra]} == $po ]]; then
                    unidMemOcupadas[$ra]="_" 
                fi
            done
            escrito[$po]=0
        fi
    done
#Si los procesos ya no están en memoria se eliminan de la variable guardadoMemoria.
        if [[ ${enmemoria[$po]} -ne 1 ]]; then 
#guardadoMemoria[@]} ; i++ )); do 
                if [[ ${guardadoMemoria[$i]} -eq $po ]]; then
                    unset guardadoMemoria[$i]
                    unset tamanoGuardadoMemoria[$i]
                fi
            done
        fi
    done
#Se eliminan los huecos vacíos que genera el unset
#Se eliminan los huecos vacíos que genera el unset
#Fin de calculosActualizarVariablesBandaMemoria()

#
# Sinopsis: Se realizan los cálculos necesarios para la impresión de la banda de memoria en los volcados.
#
function calculosReubicarYMeterProcesosBandaMemoria {
#Sucesión: Se genera una lista secuencial de procesos en guardadoMemoria y tamanoGuardadoMemoria, se comprueba si hay espacio suficiente en la memoria dependiendo de la continuidad y reubicabilidad definidas, y si lo hay, se mete el proceso.
    if [[ $mem_libre -gt 0 ]]; then 
#Si hay que reubicar, se hace.
#Se reubican los procesos existentes en la memoria en el mismo orden.
#ud contador que guarda las unidades que se van guardando (ud < total)
                ra=0
#Se reescriben todos los números de proceso en unidMemOcupadasAux (menor y no menor o igual, ya que se empieza en 0) 
#Se marca con el proceso que ocupa la posición de memoria.
                        unidMemOcupadasAux[$ra]=${guardadoMemoria[$gm]}  
                        ud=$((ud+1))
                    fi
#Se marca que ya se ha escrito en memoria.
                    ra=$((ra+1))
	             done
            done
#Se copia la memoria auxiliar a la original para que se después se escriba en memoria.
#Notificamos que se ha reubicado.
            echo -e " La memoria ha sido reubicada." $NC | tee -a $informeConColorTotal
            echo -e " La memoria ha sido reubicada." >> $informeSinColorTotal
        fi
    fi
#Fin de calculosReubicarYMeterProcesosBandaMemoria()

#
# Sinopsis: Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#
function tratarRangoPrioridadesDirecta {
#Será 1 cuando se determine un rango de prioridades cuyo mínimo sea mayor que su máximo.
    if [[ $1 -gt $2 ]]; then 
		aux=$1
		PriomFinal=$2
		PrioMFinal=$aux
#Será 1 cuando se determine un rango de prioridades cuyo mínimo sea mayor que su máximo.
    else
		PriomFinal=$1
		PrioMFinal=$2
    fi
#Fin de calculosReubicarYMeterProcesosBandaMemoria()

#
# Sinopsis: Guardar los procesos que van entrando en memoria de forma secuencial en la variable guardadoMemoria 
# y sus tamaños en tamanoGuardadoMemoria   
#
function crearListaSecuencialProcesosAlEntrarMemoria {
#Vaciamos el array anterior
#Vaciamos el array anterior
#Determinará qué procesos están en memoria.
        if [[ ${unidMemOcupadas[$ra]} != "_" ]]; then
            numeroProbar=${unidMemOcupadas[$ra]}
            permiso=1
#Si el proceso ya está en memoria, no hace falta meterlo.
                if [[ ${guardadoMemoria[$i]} -eq $numeroProbar ]]; then
                    permiso=0
                fi
            done
#Permiso es la variable que permite meter un proceso en memoria porque haya espacio suficiente.
#Guarda el número de proceso que va a meter en memoria.
#Guarda el tamaño del proceso que va a meter en memoria.
                permiso=0
            fi
        fi
    done
#Fin de crearListaSecuencialProcesosAlEntrarMemoria()

#
# Sinopsis: Comprueba que cada hueco en memoria no es mayor que la variable definida, para decidir si se reubica. 
#
function comprobacionSiguienteProcesoParaReubicar {
#Sucesión: Se determina qué proceso es el siguiente en entrar en memoria, y dependiendo de la continuidad y reubicabilidad definidas, se establece si hay espacio en memoria. 
#Variable para no permitir meter procesos en memoria bajo ciertas condiciones relacionadas con la continuidad. 
    encontradoHuecoMuyReducido=0
    primeraUnidadFuturoProcesoSinreubicar=-1
    raInicioProceso=-1
#En caso de ser memoria no continua, si hay un hueco demasiado pequeño, y se va a usar como parte de la memoria a usar.
#En caso de ser memoria continua, si no hay un hueco suficientemente grande en el que quepa pero sí en la suma de todos ellos.
    contadorReubicar=-1
    contadorReubicarTotal=0
    siguienteProcesoAMeter=-1
#Metemos un proceso y comprobamos si hay que reubicar 
#Si está para entrar en memoria y no está dentro se mete, y si ya está dentro se ignora.
            siguienteProcesoAMeter=$po
            break
        fi 
    done
    if [[ $siguienteProcesoAMeter -eq -1 ]]; then
#Metemos un proceso y comprobamos si hay que reubicar 
#Si está para entrar en memoria y no está dentro se mete, y si ya está dentro se ignora.
                siguienteProcesoAMeter=$po
                break
            fi 
        done
    fi 
    if [[ $mem_libre -gt 0 ]]; then
        for (( ra=0; ra<$mem_total; ra++ )); do
            if [[ ${unidMemOcupadas[$ra]} == "_" && siguienteProcesoAMeter -gt -1 ]]; then
#Se designa la primera unidad sobre la que meter el proceso si entrara en memoria continua.
                    contadorReubicar=0
                    raInicioProceso=$ra
                fi
                contadorReubicar=$((contadorReubicar + 1))
                contadorReubicarTotal=$((contadorReubicarTotal + 1))
                if [[ $contadorReubicar -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $primeraUnidadFuturoProcesoSinreubicar -eq -1 ]]; then 
#8 - Si cabe en un único hueco en memoria continua.
                    primeraUnidadFuturoProcesoSinreubicar=$raInicioProceso               
                    break
                fi
            elif [[ ${unidMemOcupadas[$ra]} != "_" && siguienteProcesoAMeter -ne -1 ]]; then
                if [[ $contadorReubicar -ne -1 && $contadorReubicar -le $variableReubicar && $reubicabilidadNo0Si1 -eq 1 ]]; then 
#Si encuentra un hueco demasiado pequeño mientras busca hueco suficiente y puede caber en la totalidad de los huecos, en memoria no continua.
                    encontradoHuecoMuyReducido=1
                fi
                contadorReubicar=-1
            fi
        done
#No necesario 
#1 - 3 - 6 - 9 - No cabe - Ya se considera cuando se resta el tamaño de memoria del proceso a introducir (memoriaAuxiliar[$siguienteProcesoAMeter]) de la memoria libre (mem_libre) y comprueba >=0 en comprobacionSiguienteProcesoParaMeterMemoria()
#            noCabe0Cabe1=0 
#            reubicarContinuidad=0
#            reubicarReubicabilidad=0
#        fi
#No necesario
#2 - Lo meterá en memoria a trozos.
#            noCabe0Cabe1=1
#            reubicarContinuidad=0
#            reubicarReubicabilidad=0
#        fi
#No necesario
#4 - 
#            noCabe0Cabe1=1
#            reubicarContinuidad=0
#            reubicarReubicabilidad=0
#        fi
#No necesario
#7 - 
#            noCabe0Cabe1=0 - No cabe - Ya se considera cuando se resta el tamaño de memoria del proceso a introducir (memoriaAuxiliar[$siguienteProcesoAMeter]) de la memoria libre (mem_libre) y comprueba >=0 en comprobacionSiguienteProcesoParaMeterMemoria()
#            reubicarContinuidad=0
#            reubicarReubicabilidad=0
#        fi
#No necesario
#8 - 
#            noCabe0Cabe1=1
#            reubicarContinuidad=0
#            reubicarReubicabilidad=0
#        fi
#No necesario
#10 - 
#            noCabe0Cabe1=1
#            reubicarContinuidad=0
#            reubicarReubicabilidad=0
#        fi
        if [[ $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorReubicarTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $encontradoHuecoMuyReducido -eq 1 && $continuidadNo0Si1 -eq 0 && $reubicabilidadNo0Si1 -eq 1 ]]; then 
#5 - Si encuentra un hueco demasiado pequeño mientras busca hueco suficiente y puede caber en un hueco, en memoria no continua.
        fi
        if [[ $primeraUnidadFuturoProcesoSinreubicar -gt -1 && $encontradoHuecoMuyReducido -eq 1 && $reubicabilidadNo0Si1 -eq 1 ]]; then 
#11 - Si encuentra un hueco demasiado pequeño mientras busca hueco suficiente y puede caber en un hueco, en memoria no continua.
#No haría falta, porque se metería, pero se considera. Y en caso de encontradoHuecoMuyReducido=0 ta,bién lo metería.
#
            if [[ $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorReubicarTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 1 ]] ; then
#12 - Si no cabe en un único hueco, pero sí en la suma de ellos, en memoria continua.
            fi
        fi
#
            if [[ $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorReubicarTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 0 ]] ; then
#8 - Si no cabe en un único hueco, pero sí en la suma de ellos, en memoria continua.
            fi
        fi
    else
        noCabe0Cabe1=0
    fi
#Memoria No Continua
#Memoria No Reubicable
#1 - Si no cabe entre todos los huecos, no lo meterá en memoria.
#2 - OK - Si cabe entre todos los huecos, lo meterá en memoria a trozos.
#Memoria Reubicable
#3 - Si no cabe entre todos los huecos, no reubica, ni lo meterá en memoria.
#4 - OK - Si cabe entre todos los huecos, y mientras busca no encuentra un hueco demasiado pequeño, no reubica y lo meterá en memoria a trozos.
#5 - Hecho - Si cabe entre todos los huecos, y mientras busca encuentra un hueco demasiado pequeño, reubica y lo meterá en memoria.
#Memoria Continua
#Memoria No Reubicable
#6 - Si no cabe entre todos los huecos, no lo meterá en memoria.
#7 - OK - Si cabe entre todos los huecos, pero no cabe en un único hueco, no lo meterá en memoria.
#8 - Hecho - Si cabe en un único hueco, lo meterá en memoria.
#Memoria Reubicable
#9 - Si no cabe entre todos los huecos, no reubica, ni lo meterá en memoria.
#10 - OK - Si cabe en un único hueco, y mientras busca no encuentra un hueco demasiado pequeño, no reubica y lo meterá en memoria.
#11 - Hecho - Si cabe en un único hueco, y mientras busca encuentra un hueco demasiado pequeño, reubica y lo meterá en memoria.
#12 - Hecho - Si cabe entre todos los huecos, pero no en un único hueco, reubica y lo meterá en memoria.
#Fin de comprobacionSiguienteProcesoParaReubicar()

#
# Sinopsis: Comprueba que cada hueco en memoria es suficiente para meter un proceso en memoria. 
#
function comprobacionSiguienteProcesoParaMeterMemoria {
    if [[ $mem_libre -gt 0 && reubicarReubicabilidad -ne 1 && reubicarContinuidad -ne 1 ]]; then
        mem_libreTemp=$mem_libre
#No se debería definir porque es un valor arrastrado desde la comprobación en comprobacionSiguienteProcesoParaReubicar()
#El for se resuelve con i=$po de la línea anterior a la llamada de la función. 
#Si están en cola pero no en memoria (en espera)
#Variable para no permitir meter procesos en memoria bajo ciertas condiciones relacionadas con la continuidad. 
            encontradoHuecoMuyReducido=0
            raInicioProceso=-1
            contadorMeterMemoria=-1
            contadorMeterMemoriaTotal=0
            siguienteProcesoAMeter=$i
            if [[ $((mem_libreTemp - ${memoriaAuxiliar[$i]})) -ge 0 ]]; then
                noCabe0Cabe1=1
                for (( ra=0; ra<$mem_total; ra++ )); do
                    if [[ ${unidMemOcupadas[$ra]} == "_" && siguienteProcesoAMeter -gt -1 ]]; then
#Se designa la primera unidad sobre la que meter el proceso si entrara en memoria continua.
                            contadorMeterMemoria=0
                            raInicioProceso=$ra
                        fi
                        contadorMeterMemoria=$((contadorMeterMemoria + 1))
                        contadorMeterMemoriaTotal=$((contadorMeterMemoriaTotal + 1))
                        if [[ $contadorMeterMemoria -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $primeraUnidadFuturoProcesoSinreubicar -eq -1 ]]; then 
#8 - Si cabe en un único hueco en memoria continua.
                            primeraUnidadFuturoProcesoSinreubicar=$raInicioProceso               
                        fi
                    elif [[ ${unidMemOcupadas[$ra]} != "_" && siguienteProcesoAMeter -ne -1 ]]; then
                        if [[ $contadorMeterMemoria -ne -1 && $contadorMeterMemoria -le $variableReubicar && $reubicabilidadNo0Si1 -eq 1 ]]; then 
#Si encuentra un hueco demasiado pequeño mientras busca hueco suficiente y puede caber en la totalidad de los huecos, en memoria no continua.
                            encontradoHuecoMuyReducido=1
                        fi
                        contadorMeterMemoria=-1
                    fi
                done
#
                    if [[ $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorMeterMemoriaTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 0 ]] ; then
#8 - Si no cabe en un único hueco, pero sí en la suma de ellos, en memoria continua.
                    fi
                    if [[ $siguienteProcesoAMeter != -1 && $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorMeterMemoriaTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 0 ]] ; then
#8 - Si no cabe en un único hueco, pero sí en la suma de ellos, en memoria continua.
                    fi
                fi
#Este if es fundamental para generar las excepciones sobres si se reubica o no, y sobre la unidad de memoria donde empezar a meter el proceso.
                if [[ $primeraUnidadFuturoProcesoSinreubicar -ne -1 ||
                $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorMeterMemoriaTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $encontradoHuecoMuyReducido -eq 1 && $continuidadNo0Si1 -eq 0 && $reubicabilidadNo0Si1 -eq 1 ||
                $primeraUnidadFuturoProcesoSinreubicar -gt -1 && $encontradoHuecoMuyReducido -eq 1 && $reubicabilidadNo0Si1 -eq 1 ||
                $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorMeterMemoriaTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 1 || 
                $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorMeterMemoriaTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 0 && $reubicabilidadNo0Si1 -eq 0 || 
                $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorMeterMemoriaTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 0 && $reubicabilidadNo0Si1 -eq 1 ]]; then 
                    if [[ $((mem_libreTemp - ${memoriaAuxiliar[$i]})) -ge 0 ]]; then
                        mem_libreTemp=`expr $mem_libreTemp - ${memoriaAuxiliar[$i]}` 
                        avisoentrada[$i]=1
                        evento=1
                        enmemoria[$i]=1 
                        realizadoAntes=0
                        noCabe0Cabe1=1
                    else 
                        noCabe0Cabe1=0
                    fi
                fi
            else 
                noCabe0Cabe1=0
            fi
        fi
    else 
        noCabe0Cabe1=0
    fi
#Bucle para bloquear los procesos
        bloqueados[$j]=1
    done
#Memoria No Continua
#Memoria No Reubicable
#1 - Si no cabe entre todos los huecos, no lo meterá en memoria.
#2 - OK - Si cabe entre todos los huecos, lo meterá en memoria a trozos.
#Memoria Reubicable
#3 - Si no cabe entre todos los huecos, no reubica, ni lo meterá en memoria.
#4 - OK - Si cabe entre todos los huecos, y mientras busca no encuentra un hueco demasiado pequeño, no reubica y lo meterá en memoria a trozos.
#5 - Hecho - Si cabe entre todos los huecos, y mientras busca encuentra un hueco demasiado pequeño, reubica y lo meterá en memoria.
#Memoria Continua
#Memoria No Reubicable
#6 - Si no cabe entre todos los huecos, no lo meterá en memoria.
#7 - OK - Si cabe entre todos los huecos, pero no cabe en un único hueco, no lo meterá en memoria.
#8 - Hecho - Si cabe en un único hueco, lo meterá en memoria.
#Memoria Reubicable
#9 - Si no cabe entre todos los huecos, no reubica, ni lo meterá en memoria.
#10 - OK - Si cabe en un único hueco, y mientras busca no encuentra un hueco demasiado pequeño, no reubica y lo meterá en memoria.
#11 - Hecho - Si cabe en un único hueco, y mientras busca encuentra un hueco demasiado pequeño, reubica y lo meterá en memoria.
#12 - Hecho - Si cabe entre todos los huecos, pero no en un único hueco, reubica y lo meterá en memoria.
#Fin de comprobacionSiguienteProcesoParaMeterMemoria()

#
# Sinopsis: Se realizan los cálculos necesarios para la impresión de la banda de memoria en los volcados.
#
function meterProcesosBandaMemoria {
#Si está para entrar en memoria, y no está dentro se mete, y si ya está dentro se ignora.
        ud=0
        ra=0
#Esto permite la continuidad en memoria al necesitar un tramo continuo de memoria y haberlo conseguido.
            ra=$primeraUnidadFuturoProcesoSinreubicar
        fi
#Esto permite la no continuidad en memoria al no necesitar un tramo continuo de memoria.
            if [[ ${unidMemOcupadas[$ra]} == "_" ]]; then
                unidMemOcupadas[$ra]=$po
                ud=$((ud+1))
                mem_libre=$((mem_libre - 1))
            fi
#Este proceso ya sólo estará en memoria, ejecutandose o habrá acabado
#Se marca que ya está en memoria.
#El ordinal del marco sobre el que se hará el primer fallo de página cuando se introduce un proceso en memoria, siempre será 0 por ser su primer marco libre.
#Se define el primer instante a contemplar en cada proceso como el $reloj ya que será el instante en el que entra en memoria, y por tanto, el primer instante a referenciar para cada proceso.
            ra=$((ra+1))
        done
    fi
#Fin de meterProcesosBandaMemoria()

#
# Sinopsis: Se preparan las líneas para la impresión de la banda de memoria en los volcados - NO Continua y Reubicabilidad.
#
function calculosPrepararLineasImpresionBandaMemoria {
#Sucesión: Crear las tres líneas de la banda de memoria y se generan los bloques que componen la memoria usada por cada proceso en memoria.
#Se calcula la línea de nombres - Línea 1
    arribaMemoriaNC="   |"
    arribaMemoriaNCb="   |"
#Si el proceso está en la barra y no está nombrado se escribe. Si está nombrado se llena de _ para que el siguiente coincida con la línea de memoria.
    for (( ra=0; ra<$mem_total; ra++ )); do
#Si la posición de memoria no está escrita, añades dígitos para completar los caracteres de la unidad, y la escribes.
        for (( po=0; po<$nprocesos; po++ )); do
            if [[ $ra -eq 0 && ${unidMemOcupadas[$ra]} == $po ]]; then 
#proceso[$po]}))}"$NC
#proceso[$po]}))}"
            fi
#Si en una posición hay un proceso y antes algo distinto lo nombras
#proceso[$po]}))}"$NC
#proceso[$po]}))}"
#Si es un proceso pero no es inicio pones barras bajas
                arribaMemoriaNC=$arribaMemoriaNC${coloress[$po % 6]}"${varhuecos:1:$digitosUnidad}"$NC
                arribaMemoriaNCb=$arribaMemoriaNCb"${varhuecos:1:$digitosUnidad}"
            fi
        done
#Si es una barra baja (blanco) se llena de _ para seguir alineando.
        if [[ ${unidMemOcupadas[$ra]} == '_' ]]; then 
            arribaMemoriaNC=$arribaMemoriaNC"${varhuecos:1:$digitosUnidad}"$NC
            arribaMemoriaNCb=$arribaMemoriaNCb"${varhuecos:1:$digitosUnidad}"
        fi
    done

#Se calcula la línea de banda - Línea 2
#Lo vaciamos ya que cada volcado es diferente. Añadimos valores cada vez que se imprima un bloque
    barraMemoriaNC="BM |"
#Para el color se usa esta variable ya que se cuentan los caracteres por línea y no se puede hacer con las secuencias de escape. Además se hace con "█" negros cuando no están siendo usados.
#Para el fichero de blanco y negro se usa esta variable ya que se cuentan los caracteres por línea y no se puede hacer con las secuencias de escape. Además se hace con "-" cuando no están siendo usados. 
    coloresPartesMemoria=(" ${coloresPartesMemoria[@]}" "${coloress[97]}" "${coloress[97]}" "${coloress[97]}")
#En $ra (recorre array) siempre va a haber o un proceso o una barra baja
#Entonces hay guardado el número del 0-x de un proceso
            barraMemoriaNC=$barraMemoriaNC${coloress[${unidMemOcupadas[$ra]} % 6]}"${varfondos:1:$digitosUnidad}"$NC
            barraMemoriaNCbPantalla=$barraMemoriaNCbPantalla"${varfondos:1:$digitosUnidad}"
            colorunidMemOcupadas
        fi
#Imprimir 3 blancos si hay una _
            barraMemoriaNC=$barraMemoriaNC" "${coloress[97]}"${varfondos:1:$digitosUnidad}"$NC
            barraMemoriaNCbPantalla=$barraMemoriaNCbPantalla"${varfondos:1:$digitosUnidad}"
            colorDefaultBMBT
        fi
    done

#Se calcula la línea que escriba la posición de memoria - Línea 3
    abajoMemoriaNC="   |"
    abajoMemoriaNCb="   |"
    for (( ra=0; ra<$mem_total; ra++ )); do
#Al final se escriben las unidades de comienzo de los procesos:
#Si la posición de memoria está o no escrita, se escribe el 0 y se añaden dígitos para completar los caracteres de la unidad.
        if [[ $ra -eq 0 ]] ; then 
#ra}))}"${coloress[$po % 6]}"$ra"$NC
#ra}))}""$ra"
        fi
        for (( po=0; po<$nprocesos; po++ )); do
#Si la posición de memoria no está escrita, añades dígitos para completar los caracteres de la unidad, y la escribes.
            if [[ $ra -ne 0 && ${unidMemOcupadas[$((ra-1))]} != $po  && ${unidMemOcupadas[$ra]} == $po ]] ; then 
#ra}))}"${coloress[$po % 6]}"$ra"$NC
#ra}))}""$ra"
#Si la posición ya está escrita se añaden huecos para las siguientes unidades
            elif [[ $ra -ne 0 && ${unidMemOcupadas[$((ra-1))]} == $po  && ${unidMemOcupadas[$ra]} == $po ]] ; then 
                abajoMemoriaNC=$abajoMemoriaNC"${varhuecos:1:$digitosUnidad}"$NC
                abajoMemoriaNCb=$abajoMemoriaNCb"${varhuecos:1:$digitosUnidad}"
            fi
        done
#Se escribe la posición de los primeros blancos de la misma manera salvo el 0 que ya está escrito.
#Si la posición de memoria no está escrita se escribe y se añaden dos dígitos en blanco (completar 3 caract).
        if [[ $ra -ne 0 && ${unidMemOcupadas[$((ra-1))]} != "_" && ${unidMemOcupadas[$ra]} == "_" ]] ; then 
#ra}))}"${coloress[97]}"$ra"$NC
#ra}))}""$ra"
#Posición ya escrita huecos SALVO en caso de que sea la posición 0 (que se escribe siempre si está vacía aunque el último hueco tenga algo).
#Si es un proceso pero no es inicio pones barras bajas
            abajoMemoriaNC=$abajoMemoriaNC"${varhuecos:1:$digitosUnidad}"$NC
            abajoMemoriaNCb=$abajoMemoriaNCb"${varhuecos:1:$digitosUnidad}"
        fi
    done
    
#Se calcula el número de bloques en los que se fragmentan los procesos.
#Se determina is hay un proceso en la primera unidad de memoria y qué proceso es, y se define como primer bloque.
        bloques[$((unidMemOcupadas[0]))]=1
    fi
    for (( ra=1; ra<$mem_total; ra++ )); do
#menor
            bloques[$((unidMemOcupadas[$ra]))]=$((bloques[$((unidMemOcupadas[$ra]))] + 1)) 
        fi
    done
#Se cuenta el número de datos que tienen que tener los arrays posición inicial/final. Si bloques de algo equivale a 0 o 1, se suma 1. Si no, se suma el número de bloques.
#El array de bloques tiene el mismo número de posiciones que el de procesos.
#Una por proceso, est´´e o no en memoria, y una más por cada bloque añadido más allá del primero
#Número de procesos
        else 
#Número de bloques por proceso cuando tenga bloques
        fi
    done
#Se inicializan a 0 (Sin bloques)
        inicialNC[$i]=0
        finalNC[$i]=0
    done
#Se rellena
    main=0
    mafi=0
    for (( po=0 ; po<$nprocesos; po++ )); do
        if [[ ${bloques[$po]} -eq 0 ]]; then
            inicialNC[$main]="-"
            main=$((main+1))
            finalNC[$mafi]="-"
            mafi=$((mafi+1))
        elif [[ ${bloques[$po]} -ne 0 ]]; then
            contadori=0
            contadorf=0
            while [[ $contadori -lt ${bloques[($po)]} &&  $contadorf -lt ${bloques[($po)]} ]]; do
                for (( ra=0; ra<$mem_total ; ra++ )) ; do
#El primero es un caso especial
#Si el proceso entra en memoria, guarda la unidad de inicio    
                        main=$((main+1))
                        contadori=$((contadori+1))
                    fi
                    if [[ $ra -ne 0  &&  ${unidMemOcupadas[$((ra - 1))]} != $po && ${unidMemOcupadas[$ra]} == $po ]] ; then
#Si el proceso entra en memoria, guarda la unidad de inicio    
                        main=$((main+1))
                        contadori=$((contadori+1))
                    fi
                    if [[ $ra -ne 0  &&  $ra -ne $((mem_total-1)) && ${unidMemOcupadas[$ra]} == $po && ${unidMemOcupadas[$((ra + 1))]} != $po ]] ; then
#Si el proceso entra en memoria, guarda la unidad de final
                        mafi=$((mafi+1))
                        contadorf=$((contadorf+1))
                    fi
#El último es un caso especial
#Si el proceso entra en memoria, guarda la unidad de final aunque no haya terminado el proceso. No debería ya que hubiera tenido que empezar en el primer hueco y le habría cabido.
                        mafi=$((mafi+1))
                        contadorf=$((contadorf+1))
                    fi
                done
            done
        fi
    done
#Final de preparar líneas para Banda de Memoria - calculosPrepararLineasImpresionBandaMemoria()

#
# Sinopsis: Genera la Banda de Memoria y la muestra en pantalla/informe 
#
#Nueva versión y más simplificada, pero tiene 100 líneas más que la versión original (dibujarBandaMemoriaORI)
#Ancho del terminal para adecuar el ancho de líneas a cada volcado

# GENERACIÓN STRING DE PROCESOS (Línea 1 de la Banda de Memoria) 
#Número de línea de la banda
    bandaProcesos=("    |")
    bandaProcesosColor=("$NORMAL    |")
    numCaracteres2=5
# Variable que indica si se ha añadido un proceso a la banda (1).
#unidMemOcupadas[@]};ii++)); do
#El proceso está en memoria y se imprimirá
#El texto no cabe en la terminal
# Se pasa a la siguiente línea
                bandaProcesos[$nn]="     "
                bandaProcesosColor[$nn]="     "
                numCaracteres2=5
            fi
# El texto no cabe en la terminal
                xx=0
            fi
#Se añade el proceso a la banda
#proceso[$((${unidMemOcupadas[$ii]}))]}))}
                bandaProcesos[$nn]+=`echo -e "${proceso[$((${unidMemOcupadas[$ii]}))]}""$espaciosfinal"`
                bandaProcesosColor[$nn]+=`echo -e "${coloress[${unidMemOcupadas[$ii]} % 6]}${proceso[$((${unidMemOcupadas[$ii]}))]}""$NORMAL$espaciosfinal"`
                numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
                xx=1
            else
#El texto no cabe en la terminal
#Se pasa a la siguiente línea
                    bandaProcesos[$nn]="     "
                    bandaProcesosColor[$nn]="     "
                    numCaracteres2=5
                fi
                espaciosfinal=${varhuecos:1:$(($digitosUnidad))}
                bandaProcesos[$nn]+=`echo -e "$espaciosfinal"`
                bandaProcesosColor[$nn]+=`echo -e "$NORMAL$espaciosfinal"`
                numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
                if [[ $ii -ne 0 ]]; then
                    if [[ ${unidMemOcupadas[$((ii - 1))]} !=  "_" ]]; then
                        if [[ $xx -eq 1 && ${proceso[$((${unidMemOcupadas[$ii]}))]} != ${proceso[$((${unidMemOcupadas[$((ii - 1))]}))]} ]]; then
                            xx=0
                        fi
                    fi
                fi
            fi
        else
            xx=0
#El texto no cabe en la terminal
#Se pasa a la siguiente línea
                bandaProcesos[$nn]="     "
                bandaProcesosColor[$nn]="     "
                numCaracteres2=5
            fi
            espaciosfinal=${varhuecos:1:$(($digitosUnidad))}
            bandaProcesos[$nn]+=`echo -e "$espaciosfinal"`
            bandaProcesosColor[$nn]+=`echo -e "$NORMAL$espaciosfinal"`
            numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
		fi
    done
#Añadir final de banda
#El texto no cabe en la terminal
#Se pasa a la siguiente línea
        bandaProcesos[$nn]="     "
        bandaProcesosColor[$nn]="     "
        numCaracteres2=5
    fi
    bandaProcesos[$nn]+=`echo -e "|"`
    bandaProcesosColor[$nn]+=`echo -e "$NORMAL|"`

# GENERACIÓN STRING DE MEMORIA (Línea 2 de la Banda de Memoria)
#Línea de la banda
    bandaMemoria=(" BM |")
    bandaMemoriaColor=("$NORMAL BM |")
    numCaracteres2=5
    espaciosAMeter=${varfondos:1:$digitosUnidad}
    guionesAMeter=${varguiones:1:$digitosUnidad}
    asteriscosAMeter=${varasteriscos:1:$digitosUnidad}
    fondosAMeter=${varfondos:1:$digitosUnidad}
    sumaTotalMemoria=0
#Variable que indica si se ha añadido un proceso a la banda
    for (( i=0; i<$nprocesos; i++)); do 
#Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
	done
			
#unidMemOcupadas[@]};ii++)); do
#El proceso está en memoria y se imprimirá
#El texto no cabe en la terminal
#Se pasa a la siguiente línea
                bandaMemoria[$nn]="     "
                bandaMemoriaColor[$nn]="     "
                numCaracteres2=5
            fi
#paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}))}
#Si no hay página se mete asterisco en BN.
#paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}))}"*"
#Y si hay página se mete espacios y el número.
#paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}))}
			fi
            bandaMemoria[$nn]+=`echo -e "$espaciosasteriscofinal${paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}"`
            bandaMemoriaColor[$nn]+=`echo -e "$NC${colorfondo[${unidMemOcupadas[$ii]} % 6]}$espaciosfinal${paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}$NC"`
#Número de Marcos con Páginas ya dibujadas de cada Proceso.
            numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
            if [[ $ii -ne 0 ]]; then
                if [[ ${unidMemOcupadas[$((ii - 1))]} !=  "_" ]]; then 
                    if [[ $xx -eq 1 && ${proceso[$((${unidMemOcupadas[$ii]}))]} != ${proceso[$((${unidMemOcupadas[$((ii - 1))]}))]} ]]; then
                        xx=0
                    fi
                fi
            fi
#El proceso no está en memoria y no puede representarse en la Banda de Memoria.
            xx=0
#El texto no cabe en la terminal
#Se pasa a la siguiente línea
                bandaMemoria[$nn]="     "
                bandaMemoriaColor[$nn]="     "
                numCaracteres2=5
            fi
#paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}))}"-"
            bandaMemoria[$nn]+=`echo -e "$espaciosguionfinal"`
            bandaMemoriaColor[$nn]+=`echo -e "$NC$fondosAMeter$NC"`
            numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
        fi
    done

#Añadir final de banda 
#El texto no cabe en la terminal
#Se pasa a la siguiente línea
        bandaMemoria[$nn]="     "
        bandaMemoriaColor[$nn]=$NORMAL"     "
        numCaracteres2=5
    fi
# TODO: CAMBIAR NÚMERO DE MEMORIA
# TODO: CAMBIAR NÚMERO DE MEMORIA

# GENERACIÓN STRING DE POSICIÓN DE MEMORIA (Línea 3 de la Banda de Memoria)  
# Línea de la banda
    bandaPosicion=("    |")
    bandaPosicionColor=("$NORMAL    |")
    numCaracteres2=5
#Variable que indica si se ha añadido un proceso a la banda
#unidMemOcupadas[@]};ii++)); do
#El proceso está en memoria y se imprimirá
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
                bandaPosicion[$nn]="     "
                bandaPosicionColor[$nn]="     "
                numCaracteres2=5
            fi
# El texto no cabe en la terminal
                xx=0
            fi
#Se añade el proceso a la banda
#ii}))}
                bandaPosicion[$nn]+=`echo -e "$espaciosfinal""$ii"`
                bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal""$ii"`
                numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
                xx=1
            else
#El texto no cabe en la terminal
#Se pasa a la siguiente línea
                    bandaPosicion[$nn]="     "
                    bandaPosicionColor[$nn]="     "
                    numCaracteres2=5
                fi
                espaciosfinal=${varhuecos:1:$(($digitosUnidad))}
                bandaPosicion[$nn]+=`echo -e "$espaciosfinal"`
                bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal"`
                numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
                if [[ $ii -ne 0 ]]; then
                    if [[ ${unidMemOcupadas[$((ii - 1))]} !=  "_" ]]; then
                        if [[ $xx -eq 1 && ${proceso[$((${unidMemOcupadas[$ii]}))]} != ${proceso[$((${unidMemOcupadas[$((ii - 1))]}))]} ]]; then
                            xx=0
                        fi
                    fi
                fi
            fi
        else
            xx=0
#El texto no cabe en la terminal
#Se pasa a la siguiente línea
                bandaPosicion[$nn]="     "
                bandaPosicionColor[$nn]="     "
                numCaracteres2=5
            fi
            if [[ $ii -ne 0 ]]; then
                if [[ ${unidMemOcupadas[$((ii - 1))]} != "_" ]]; then
#ii}))}
                    bandaPosicion[$nn]+=`echo -e "$espaciosfinal""$ii"`
                    bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal""$ii"`
                else
                    espaciosfinal=${varhuecos:1:$(($digitosUnidad))}
                    bandaPosicion[$nn]+=`echo -e "$espaciosfinal"`
                    bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal"`
                fi
            else
#ii}))}
                bandaPosicion[$nn]+=`echo -e "$espaciosfinal""$ii"`
                bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal""$ii"`
            fi
            numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
        fi
    done
#Añadir final de banda
#El texto no cabe en la terminal
# Se pasa a la siguiente línea
        bandaPosicion[$nn]="     "
        bandaPosicionColor[$nn]="$NORMAL     "
        numCaracteres2=5
    fi
    bandaPosicion[$nn]+=`echo -e "|"`
    bandaPosicionColor[$nn]+=`echo -e "$NORMAL|"`

# IMPRIMIR LAS 3 LÍNEAS DE LA BANDA DE MEMORIA (COLOR y BN a pantalla y ficheros)
#bandaProcesos[@]}; jj++ )); do
        echo -e "${bandaProcesosColor[$jj]}" | tee -a $informeConColorTotal
        echo -e "${bandaMemoriaColor[$jj]}" | tee -a $informeConColorTotal
        echo -e "${bandaPosicionColor[$jj]}\n" | tee -a $informeConColorTotal
        echo -e "${bandaProcesos[$jj]}" >> $informeSinColorTotal
        echo -e "${bandaMemoria[$jj]}" >> $informeSinColorTotal
        echo -e "${bandaPosicion[$jj]}\n" >> $informeSinColorTotal
    done
#Se vacía el auxiliar que reubica la memoria.
#Se borran los datos del auxiliar.
        unidMemOcupadasAux[$ca]="_"
    done
#Se vacían bloques
#Se borran los datos del auxiliar.
         bloques[$ca]=0
    done
#Se vacían las posiciones
    nposiciones=0
#Se vacían posiciones iniciales y finales para borrar elementos innecesarios
    for (( i=0; i<$nposiciones; i++ )) ; do
         inicialNCmodelo[$i]=0
    done
    for (( i=0; i<$nposiciones; i++ )) ; do 
         finalNCmodelo[$i]=0
    done
#Fin de la nueva versión de dibujarBandaMemoria()

#
# Sinopsis: Prepara la banda de tiempos de procesos en cada volcado - PRUEBA DE COPIAR LÍNEA A lÍNEA
#
function calculosImpresionBandaTiempos { 
#Sucesión: Crear las tres líneas de la banda de tiempo y se generan los bloques que componen la memoria usada por cada proceso en memoria.
#Nota: Todas las que acaben en "b" (o "baux) significa que es la versión en blanco y negro (también en la memoria).
#Se trabaja simultaneamente con la línea en b/n, en color, y con el array coloresPartesTiempo (o memoria) que guarda el color de cada caracter del terminal.
#dibujasNC es el array que guarda cúantas unidades quedan por dibujar de un proceso
        
#A... Primero. Se trata la entrada por separado hasta que entre el primer proceso
#En T=0 se pone el "rótulo".
#Determina el número de caracteres a inmprimir en cada línea.
    arribatiempoNC_0="    |"
    arribatiempoNCb_0="    |"
    tiempoNC_0=" BT |"
    tiempoNCb_0=" BT |"
    abajotiempoNC_0="    |"
    abajotiempoNCb_0="    |"
#Unidades ya incluidas en las variables tiempoNC_0,...
    colorDefaultInicio
#Primero se meten blancos en tiempoNC_0,... hasta la legada del primer proceso, si lo hay.
#En el caso en que el primer proceso entre más tarde que 0, se introducen blancos iniciales en tiempoNC_0,....
        arribatiempoNC=$arribatiempoNC_0"${varhuecos:1:$(($digitosUnidad))}"$NC 
        arribatiempoNCb=$arribatiempoNCb_0"${varhuecos:1:$(($digitosUnidad))}"
        tiempoNC=$tiempoNC_0"${varhuecos:1:$(($digitosUnidad))}"$NC 
        tiempoNCb=$tiempoNCb_0"${varhuecos:1:$(($digitosUnidad))}"
        abajotiempoNC=$abajotiempoNC_0"${varhuecos:1:$(($digitosUnidad - 1))}0"$NC
        abajotiempoNCb=$abajotiempoNCb_0"${varhuecos:1:$(($digitosUnidad - 1))}0"
        colorDefaultBMBT
    fi
#Hasta que se alcance reloj dibujar blancos en tiempoNC_0,....
        for (( i=0 ; i<$(($reloj)) ; i++ )) ; do
            if [[ $tiempodibujado -eq 0 ]]; then
                arribatiempoNC=$arribatiempoNC_0"${varhuecos:1:$(($digitosUnidad))}""${coloress[$i % 6]}"
                arribatiempoNCb=$arribatiempoNCb_0"${varhuecos:1:$(($digitosUnidad))}"
#Representa los fondos con su color correspondiente
                tiempoNCb=$tiempoNCb_0"${varguiones:1:$(($digitosUnidad))}"
                abajotiempoNC=$abajotiempoNC_0"${varhuecos:1:$(($digitosUnidad - 1))}0"
                abajotiempoNCb=$abajotiempoNCb_0"${varhuecos:1:$(($digitosUnidad - 1))}0"
                tiempodibujado=$(($tiempodibujado + 1))
#En el caso en que el primer proceso entre más tarde que 0 (dibujar blancos iniciales de la barra todos de golpe).
                arribatiempoNC=$arribatiempoNC"${varhuecos:1:$(($digitosUnidad))}""${coloress[$i % 6]}"
                arribatiempoNCb=$arribatiempoNCb"${varhuecos:1:$(($digitosUnidad))}"
#Representa los fondos con su color correspondiente
                tiempoNCb=$tiempoNCb"${varguiones:1:$(($digitosUnidad))}"
                abajotiempoNC=$abajotiempoNC"${varhuecos:1:$(($digitosUnidad))}"
                abajotiempoNCb=$abajotiempoNCb"${varhuecos:1:$(($digitosUnidad))}"
                tiempodibujado=$(($tiempodibujado + 1))
            fi
        done
    fi
    
#B... Segundo: A partir de la representación del primer proceso, si lo hay, se dibuja el resto de procesos de forma normal, añadiendo sus nombres y unidades.
#1.Dibujar los procesos finalizados - Si está nombrado y no se ha empezado a dibujar
#2.Añadir el rótulo del último proceso si hace falta y se marca como nombrado (entra en ejecución pero no hay que dibujar nada).        
#1. Proceso finalizado que NO se ha acabado de dibujar. Hay que dibujar meter nombres (línea 1) y unidades (línea 3). 
#Que haya, que esté acabado (no él mismo) y que quede por dibujar:
#Si se ha nombrado (nomtiempo()=1) y no se ha empezado a dibujar (valor en dibujasNC() como en tejecucion()) 
        if [[ ${nomtiempo[$proanterior]} == 1 && ${dibujasNC[$proanterior]} -eq ${tejecucion[$proanterior]} ]]; then 
#Si se ha marcado como terminado y no se ha empezado a dibujar 
#Ponemos espacios para cuadrar, tantos como unidades de la barra se dibujen, menos 1 (ese 1 es poe empezar a contar desde 0)
            for (( i=0 ; i<$contad; i++ )); do
                arribatiempoNC=$arribatiempoNC"${varhuecos:1:$(($digitosUnidad))}"$NC
                arribatiempoNCb=$arribatiempoNCb"${varhuecos:1:$(($digitosUnidad))}""222"
#Cambiados a varfondos
                tiempoNCb=$tiempoNCb"${varguiones:1:$(($digitosUnidad))}"
                abajotiempoNC=$abajotiempoNC"${varhuecos:1:$(($digitosUnidad))}"$NC
                abajotiempoNCb=$abajotiempoNCb"${varhuecos:1:$(($digitosUnidad))}"
                colorAnterior
                tiempodibujado=$(($tiempodibujado + 1))
            done
            dibujasNC[$proanterior]=0
        fi 
#Fin de los procesos terminados pendientes de imprimir en la banda de tiempo
#2.Se añade el nombre del último proceso que entra en ejecución y se marca como nombrado (entra en ejecución pero no hay que dibujar nada).
    for (( po=0; po<$nprocesos; po++)) ; do
        if ( [[ $tiempodibujado -eq $reloj && ${dibujasNC[$po]} -eq ${tejecucion[$po]} && ${estad[$po]} -eq 3 ]] ) ; then 
            arribatiempoNC=$arribatiempoNC"${coloress[$po % 6]}${proceso[$po]}""${varhuecos:1:$(($digitosUnidad - ${proceso[$po]}))}"$NC
            arribatiempoNCb=$arribatiempoNCb"${proceso[$po]}""${varhuecos:1:$(($digitosUnidad - ${proceso[$po]}))}"
#Propuesto meter varfondos
            tiempoNCb=$tiempoNCb"${varhuecos:1:$(($digitosUnidad))}"
#reloj}))}""$reloj"$NC
#reloj}))}""$reloj"
            tiempodibujado=$(($tiempodibujado + 1))
        fi
#Se marca como nombrado
    done
#Final de los cálculos para la impresión de la banda de memoria de los volcados - calculosImpresionBandaTiempos()

#
# Sinopsis: Imprime las tres líneas de la banda de tiempo. Permite mostrar el orden de ejecución de los 
# procesos y su evolución en el tiempo.
#
function dibujarBandaTiempos {     
# Variable para almacenar la suma total de tiempos de llegada y ejecución
# Número más alto entre la suma los tiempos de llegada y ejecución totales, y la página de mayor número
    local maxCaracteres=0
# Longitud en número de dígitos de cada unidad 
    if [[ $maxCaracteres -eq 2 ]]; then
# El mínimo de caracteres tiene que ser 3 para que entren los nombres de 
    fi
#Ancho del terminal para adecuar el ancho de líneas a cada volcado
#proceso[@]}; s++)); do
        if [[ ${estado[$s]} == "En ejecución" ]]; then
#En cada casilla contiene el número de orden del proceso que se ejecuta en cada instante. Sólo puede haber un proceso en cada instante.
        fi
    done

# GENERACIÓN STRING DE LA BANDA DE TIEMPOS (Línea 1 de la Banda de Tiempos)
    local bandaProcesos=("    |")
    local bandaProcesosColor=($NORMAL"    |")
# Línea de la banda
    local numCaracteres=5
    espaciosAMeter=${varhuecos:1:$maxCaracteres}
    guionesAMeter=${varguiones:1:$maxCaracteres}
    fondosAMeter=${varfondos:1:$maxCaracteres}
    for ((k = 0; k <= $reloj; k++)); do
#Si T=0
#Si hay proceso en ejecución para T=0
#Se imprime el nombre del proceso en ejecución en ese instante definido por la posición almacenada en procPorUnidadTiempoBT
				bandaProcesos[n]+=`printf "%-$(($maxCaracteres))s" $p`
				bandaProcesosColor[n]+=`printf "${coloress[${procPorUnidadTiempoBT[$k]} % 6]}%-$(($maxCaracteres))s$NORMAL" $p`
#Si no hay proceso en ejecución para T=0
                bandaInstantes[n]+=`echo -e $espaciosAMeter`
                bandaInstantesColor[n]+=`echo -e $espaciosAMeter`
            fi
            numCaracteres=$(($numCaracteres + $maxCaracteres))
#Si NO T=0
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
				bandaProcesos[n]="     "
				bandaProcesosColor[n]="     "
				numCaracteres=5
			fi
#Si se mantiene el mismo proceso en ejecución se imprimen espacios
				bandaProcesos[n]+=`printf "%$(($maxCaracteres))s" ""`
				bandaProcesosColor[n]+=`printf "%$(($maxCaracteres))s" ""`
#Si no se mantiene el mismo proceso en ejecución se imprime el nombre del nuevo proceso
#Se imprime el nombre del proceso en ejecución en ese instante definido por la posición almacenada en procPorUnidadTiempoBT
				bandaProcesos[n]+=`printf "%-$(($maxCaracteres))s" $p`
				bandaProcesosColor[n]+=`printf "${coloress[${procPorUnidadTiempoBT[$k]} % 6]}%-$(($maxCaracteres))s$NORMAL" $p`
			fi
			numCaracteres=$(($numCaracteres + $maxCaracteres))
        fi
    done
# Añadir final de banda
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
        bandaProcesos[n]="     "
        bandaProcesosColor[n]="     "
        numCaracteres=5
    fi
    bandaProcesos[n]+=`printf "|    %$(($maxCaracteres))s" ""`
    bandaProcesosColor[n]+=`printf "|    %$(($maxCaracteres))s" ""`

# GENERACIÓN STRING DE LA BANDA DE TIEMPOS (Línea 2 de la Banda de Tiempos)
    local bandaTiempo=(" BT |")
    local bandaTiempoColor=(" BT |")
# Línea de la banda
    local numCaracteres=5
    for (( i=0; i<$nprocesos; i++)); do 
#Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
	done
    for ((k = 0; k <= $reloj; k++)); do
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
            bandaTiempo[n]="     "
            bandaTiempoColor[n]="     "
            numCaracteres=5
        fi
#Si el instante considerado es igual al tiempo actual
#Si no hay proceso en ejecución asociado a ese instante. Vale 0 si no está definido porque la inicialización empieza en posición=1.
				if [[ $k -eq 0 ]]; then
					espaciosguionfinal=${varhuecos:1:$(($digitosUnidad - 1))}"-"
					bandaTiempo[n]+=$espaciosguionfinal
					bandaTiempoColor[n]+=$espaciosguionfinal
            	else
					bandaTiempo[n]+=$espaciosAMeter
					bandaTiempoColor[n]+=$espaciosAMeter
            	fi
#Si hay proceso en ejecución asociado a ese instante.
#paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}))}
				bandaTiempo[n]+=$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}
				bandaTiempoColor[n]+=$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}
			fi
#Si el instante considerado NO es igual al tiempo actual
# Si NO hay proceso en ejecución asociado a ese instante. Vale 0 si no está definido porque la inicialización empieza en posición=1.
                espaciosguionfinal=${varhuecos:1:$(($digitosUnidad - 1))}"-"
                bandaTiempo[n]+=$espaciosguionfinal
                bandaTiempoColor[n]+=$fondosAMeter
# Si hay proceso en ejecución asociado a ese instante  
#paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}))}
                bandaTiempo[n]+=$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}$NC
#Si NO es T=0
                    bandaTiempoColor[n]+=$NC${colorfondo[${procPorUnidadTiempoBT[$k]} % 6]}$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}$NC
#Si es T=0
#Si T=0 no se colorea el fondo 
						bandaTiempoColor[n]+=$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}$NC
#Si T>0 se pintará el fondo del color del proceso en ejecución.
                        bandaTiempoColor[n]+=$NC${colorfondo[${procPorUnidadTiempoBT[$k]} % 6]}$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}$NC                    
                    fi
                fi
#Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
            fi
        fi
        numCaracteres=$(($numCaracteres + $maxCaracteres))
    done

# Añadir final de banda
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
        bandaTiempo[n]="     "
        bandaTiempoColor[n]="     "
        numCaracteres=5
    fi
    bandaTiempo[n]+=`printf "|T= %-${maxCaracteres}d" $reloj`
    bandaTiempoColor[n]+=$NC`printf "|T= %-${maxCaracteres}d" $reloj`

# GENERACIÓN STRING DE LAS UNIDADES DE LOS INSTANES DE TIEMPO (Línea 3 de la Banda de Tiempos)
    local bandaInstantes=("    |")
    local bandaInstantesColor=($NC"    |")
# Línea de la banda
    local numCaracteres=5
    for ((k = 0; k <= $reloj; k++)); do
#Cuando se mantiene el mismo proceso en ejecución
#En T=0 o T=momento actual, aumenta el contenido de las bandas
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
                    bandaInstantes[n]="     "
                    bandaInstantesColor[n]=$NC"     "
                    numCaracteres=5
                fi
                bandaInstantes[n]+=`printf "%${maxCaracteres}d" $k`
                bandaInstantesColor[n]+=`printf "%${maxCaracteres}d" $k`
                numCaracteres=$(($numCaracteres + $maxCaracteres))
#En T distinto de 0 o momento actual, también aumenta el contenido de las bandas
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
                    bandaInstantes[n]="     "
                    bandaInstantesColor[n]=$NC"     "
                    numCaracteres=5
                fi
                bandaInstantes[n]+=`printf "%${maxCaracteres}s" ""`
                bandaInstantesColor[n]+=`printf "%${maxCaracteres}s" ""`
                numCaracteres=$(($numCaracteres + $maxCaracteres))
            fi
#Cuando no se mantiene el mismo proceso en ejecución
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
                bandaInstantes[n]="     "
                bandaInstantesColor[n]=$NC"     "
                numCaracteres=5
            fi
            bandaInstantes[n]+=`printf "%${maxCaracteres}d" $k`
            bandaInstantesColor[n]+=`printf "%${maxCaracteres}d" $k`
            numCaracteres=$(($numCaracteres + $maxCaracteres))
        fi
    done
# Añadir final de banda
# El texto no cabe en la terminal
# Se pasa a la siguiente línea
        bandaInstantes[n]="     "
        bandaInstantesColor[n]=$NC"     "
        numCaracteres=5
    fi
    bandaInstantes[n]+=`printf "|    %$(($maxCaracteres))s" ""`
    bandaInstantesColor[n]+=`printf "|    %$(($maxCaracteres))s" ""`

# IMPRIMIR LAS 3 LÍNEAS DE LA BANDA DE TIEMPOS (COLOR y BN a pantalla y ficheros temporales) - Se meten ahora en los temporales para que la banda de tiempo vaya tras la banda de memoria
#bandaProcesos[@]}; i++ )); do
        echo -e "${bandaProcesos[$i]}" >> $informeSinColorTotal
        echo -e "${bandaTiempo[$i]}" >> $informeSinColorTotal
        echo -e "${bandaInstantes[$i]}\n" >> $informeSinColorTotal
        echo -e "${bandaProcesosColor[$i]}" | tee -a $informeConColorTotal
        echo -e "${bandaTiempoColor[$i]}" | tee -a $informeConColorTotal
        echo -e "${bandaInstantesColor[$i]}\n" | tee -a $informeConColorTotal
    done    

#
#Se determina el modo de ejecución (Enter, sin paradas, con paradas con tiempo predefinido)
#Impresión de forma manual (pulsando enter para pasar)
        echo -e " Pulse ENTER para continuar.$NC" | tee -a $informeConColorTotal
        echo -e " Pulse ENTER para continuar." >> $informeSinColorTotal
        read continuar
        echo -e $continuar "\n" >> $informeConColorTotal
        echo -e $continuar "\n" >> $informeSinColorTotal
#Cierre de fi - optejecucion=1 (seleccionMenuModoTiempoEjecucionAlgormitmo=1)
#Impresión de forma sin parar (pasa sin esperar, de golpe)
        echo -e "───────────────────────────────────────────────────────────────────────$NC" | tee -a $informeConColorTotal
        echo -e "───────────────────────────────────────────────────────────────────────" >> $informeSinColorTotal
#Cierre de fi - optejecucion=2 (seleccionMenuModoTiempoEjecucionAlgormitmo=2)
#Impresión de forma automatica (esperando x segundo para pasar)
        echo -e " Espere para continuar...$NC\n" | tee -a $informeConColorTotal
        echo -e " Espere para continuar...\n" >> $informeSinColorTotal
        sleep $tiempoejecucion 
#Cierre de fi - optejecucion=3 (seleccionMenuModoTiempoEjecucionAlgormitmo=3)
#Fin de dibujarBandaTiempos()

#
# Sinopsis: Muestra en pantalla/informe una tabla con el resultado final tras la ejecución
# de todos los procesos
#
function resultadoFinalDeLaEjecucion {
    echo "$NORMAL Procesos introducidos (ordenados por tiempo de llegada):" | tee -a $informeConColorTotal
    echo -e " ┌─────┬─────┬─────┬─────┬──────┬──────┐" | tee -a $informeConColorTotal
    echo -e " │ Ref │ Tll │ Tej │ Mem │ TEsp │ Tret │" | tee -a $informeConColorTotal   
    echo -e " ├─────┼─────┼─────┼─────┼──────┼──────┤" | tee -a $informeConColorTotal
    echo -e " ┌─────┬─────┬─────┬─────┬──────┬──────┐" >> $informeSinColorTotal
    echo -e " │ Ref │ Tll │ Tej │ Mem │ TEsp │ Tret │" >> $informeSinColorTotal
    echo -e " ├─────┼─────┼─────┼─────┼──────┼──────┤" >> $informeSinColorTotal
    
#Se usa m porque i recorre los procesos y m controla las unidades usadas por cada proceso, normalmente 0 o 1, y también las unidades de los n trozos de memoria asociados a cada proceso. 
        echo -e " │ ${varC[$i]}${proceso[$i]}$NC │"\
#llegada[$i]})${varC[$i]}${llegada[$i]}$NC │"\
#ejecucion[$i]})${varC[$i]}${ejecucion[$i]}$NC │"\
#memoria[$i]})${varC[$i]}${memoria[$i]}$NC │"\
#temp_wait[$i]})${varC[$i]}${temp_wait[$i]}$NC │"\
#temp_ret[$i]})${varC[$i]}${temp_ret[$i]}$NC │" | tee -a $informeConColorTotal
#llegada[$i]})${llegada[$i]} │"\
#ejecucion[$i]})${ejecucion[$i]} │"\
#memoria[$i]})${memoria[$i]} │"\
#temp_wait[$i]})${temp_wait[$i]} │"\
#temp_ret[$i]})${temp_ret[$i]} │" >> $informeSinColorTotal
    done
    echo " └─────┴─────┴─────┴─────┴──────┴──────┘" | tee -a $informeConColorTotal
    echo " └─────┴─────┴─────┴─────┴──────┴──────┘">> $informeSinColorTotal

#Promedios
    dividir=0
    for (( i=0; i<nprocesos; i++ )) ; do
        if [[ ${estad[$i]} -ne 0 ]] ; then 
            dividir=$((dividir+1))
        fi
    done
    suma_espera=0
    suma_retorno=0
    suma_contadorAlgPagFallosProcesoAcumulado=0
    suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado=0
    for (( i=0; i<nprocesos; i++ )); do
        tam=${memoria[$i]};
#Si el tamaño del proceso es menor o igual que el de memoria
#suma para sacar su promedio
#promedio

#suma para sacar su promedio
#promedio
        fi
        suma_contadorAlgPagFallosProcesoAcumulado=$(($suma_contadorAlgPagFallosProcesoAcumulado + ${contadorAlgPagFallosProcesoAcumulado[$i]}))
        suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado=$(($suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado + ${contadorAlgPagExpulsionesForzadasProcesoAcumulado[$i]}))
    done
    echo -e "\n ┌─────────────────────────────┬─────────────────────────────┐" | tee -a $informeConColorTotal 
#promedio_espera})$NC " \
#promedio_retorno})$NC │" | tee -a $informeConColorTotal 
    echo -e " └─────────────────────────────┴─────────────────────────────┘" | tee -a $informeConColorTotal 
    echo -e "\n ┌─────────────────────────────┬─────────────────────────────┐" >> $informeSinColorTotal
#promedio_espera}) " \
#promedio_retorno}) │" >> $informeSinColorTotal
    echo -e " └─────────────────────────────┴─────────────────────────────┘" >> $informeSinColorTotal
	echo -e "\n ┌───────────────────────────────────────────────────────────┐" | tee -a $informeConColorTotal 
#suma_contadorAlgPagFallosProcesoAcumulado})$NC                          │" | tee -a $informeConColorTotal 
    if [[ $seleccionMenuAlgoritmoGestionProcesos -eq 5 ]]; then
#suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado})$NC  │" | tee -a $informeConColorTotal 
    fi
	echo -e " └───────────────────────────────────────────────────────────┘" | tee -a $informeConColorTotal 
	echo -e "\n ┌───────────────────────────────────────────────────────────┐" >> $informeSinColorTotal
#suma_contadorAlgPagFallosProcesoAcumulado})                          │" >> $informeSinColorTotal
    if [[ $seleccionMenuAlgoritmoGestionProcesos -eq 5 ]]; then
#suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado})  │" >> $informeSinColorTotal
    fi
	echo -e " └───────────────────────────────────────────────────────────┘" >> $informeSinColorTotal
#No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -ne $ROJO"\n\n Pulsa ENTER para continuar "$NORMAL
		read enter
	fi
#Fin de resultadoFinalDeLaEjecucion()

#
# Sinopsis: Permite introducir las particiones y datos desde otro fichero (predefinido).
#
function mostrarInforme {
#No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -e "\n Final del proceso, puede consultar la salida en el fichero informeBN.txt" 
		echo -e "\n Pulse enter para las opciones de visualización del fichero informeBN.txt..."
		read enter
	fi
#    clear
    cecho -e " -----------------------------------------------------"  $FRED
    cecho -e "         V I S U A L I Z A C I Ó N " $FYEL
    cecho -e " -----------------------------------------------------"  $FRED
    cecho -e " 1) Leer el fichero informeBN.txt en el terminal" $FYEL
    cecho -e " 2) Leer el fichero informeBN.txt en el editor gedit" $FYEL
    cecho -e " 3) Leer el fichero informeCOLOR.txt en el terminal" $FYEL
    cecho -e " 4) Salir y terminar"  $FYEL
    cecho -e " -----------------------------------------------------\n" $FRED
    cecho -e " Introduce una opcion: " $NC
    num=0 
    continuar="SI"
    while [[ $num -ne 4 && "$continuar" == "SI" ]]; do
        read num
#Se comprueba que el número introducido por el usuario es de 1 a 10
		until [[ 0 -lt $num && $num -lt 5 ]];  do
			echo -ne "\n Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
			echo -ne "\n Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
			read num
			echo -ne "$num\n\n" >> $informeConColorTotal
			echo -ne "$num\n\n" >> $informeSinColorTotal
		done
        case $num in
            '1' )  
#                clear               
                cat $informeSinColorTotal
                exit 0
                ;;
            '2' ) 
#                clear
                gedit $informeSinColorTotal
                exit 0
                ;;
            '3' )
#                clear
                cat $informeConColorTotal
                exit 0
                ;;
            '4' )
#                clear
                exit 0
                ;;
            *) 
                num=0
                cecho "Opción errónea, vuelva a introducir:" $FRED
        esac
    done
#Fin de mostrarInforme()

#
#
# COMIENZO DEL PROGRAMA
#
#
function inicioNuevo {
#Empieza el script
#proceso[@]}
#Inicilizamos diferentes tablas y variables  

# Se inicilizan las variables necesarias para la nueva línea del tiempo
#Se dibuja tanto como tiempo de ejecución tengan
    if [[ seleccionMenuAlgoritmoGestionProcesos -ne 4 ]]; then 
#Volcado de datos en pantalla tras pedir datos/introducción desde fichero.
    elif [[ seleccionMenuAlgoritmoGestionProcesos -eq 4 ]]; then 
#Volcado de datos en pantalla tras pedir datos/introducción desde fichero.
    fi
    
#B U C L E   P R I N C I P A L 
#Tiempo transcurrido desde el inicio del programa.
    contador=1
#Controla la salida del bucle cuando finalicen todos los procesos.
#Controla si hay procesos en ejecución.
#Número de procesos definidos en el problema
    realizadoAntes=0

    while [[ "$parar_proceso" == "NO" ]]; do
#Se inicializa al máximo antes calculado para declarar que no hay proceso en ejecución en ese instante de reloj
        timepoAux=`expr $reloj + 1`

#E N T R A R   E N   C O L A - Si el momento de entrada del proceso coincide con el reloj marcamos el proceso como en espera, en encola()
#Bucle que pone en cola los procesos.
            if [[ ${entradaAuxiliar[$i]} == $reloj ]]; then
                encola[$i]=1
                nollegado[$i]=0
                evento=1
                avisollegada[$i]=1
            elif [[ ${entradaAuxiliar[$i]} -lt $reloj ]] ; then 
                nollegado[$i]=0
            else
                nollegado[$i]=1
            fi
        done

#G U A R D A R   E N    M E M O R I A - Si un proceso está encola(), intento guardarlo en memoria, si cabe. Si lo consigo, lo marco como listo enmemoria().
#Comprueba si el proceso en ejecución ha finalizado, y lo saca de memoria. 
            if [[ ${enejecucion[$i]} -eq 1 && ${temp_rej[$i]} -eq 0 ]]; then 
#Para que deje de estar en ejecución.
#Para que deje de estar en memoria y deje espacio libre.  
#Se libera la memoria que ocupaba el proceso cuando termina.
                avisosalida[$i]=1
                evento=1
#Pasa a estar no ocupada hasta que se vuelva a buscar si hay procesos en memoria que vayan a ser ejecutados.
#Se guarda qué procesos han terminado (1) o no (0)
#Finalizado
				estado[$i]="Finalizado"
#Número de procesos que quedan por ejecutar.                    
                pos_inicio[$i]=""
                procFinalizado=$i
            fi
        done
        
#Se actualiza la variable memoria al terminar los procesos.
        
#Con esta parte se revisa la reubicabilidad, y si hay procesos se intentan cargar antes de usar los gestores de procesos, mientras que con la que hay en la reubicación, tras reubicar y producir un hueco al final de la memoria, se reintenta cargar procesos.
#Se comprueba que haya espacio suficiente en memoria y se meten los procesos que se puedan de la cola para empezar a ejecutar los algoritmos de gestión de procesos.
        if [[ $mem_libre -gt 0 ]]; then  
#Determinará si se debe o no hacer la reubicación de los procesos por condiciones de reubicabilidad. En caso de ser memoria no continua, si hay un hueco demasiado pequeño, y se va a usar como parte de la memoria a usar.
#Determinará si se debe o no hacer la reubicación de los procesos por condiciones de continuidad. En caso de ser memoria continua, si no hay un hueco suficientemente grande en el que quepa pero sí en la suma de todos ellos.
#Contiene los procesos que están en memoria de forma secuencial en la variable guardadoMemoria, y sus tamaños en tamanoGuardadoMemoria.
#Se determina qué proceso es el siguiente en entrar en memoria, y dependiendo de la continuidad y reubicabilidad definidas, se establece si hay espacio en memoria. 
#Si hay que reubicar antes de meter más procesos, se hace.
#Se meten todos los nuevos proceso que quepan y se comprueba si hay que reubicar tras cada uno de ellos. 
#Ajusta el bucle actual a la variable interna de la función.
                    comprobacionSiguienteProcesoParaMeterMemoria
                    meterProcesosBandaMemoria
#Sin este if+break fallaba porque podía meter otro proceso en memoria si tenía el espacio suficiente, incluso colándose a otro proceso anterior.
						break
                    fi
                done
            else
#Se reubica la memoria.
#Se impide un nuevo volcado en pantalla en el que no se vea avance de la aplicación.
#Se modifica restando una unidad para ajustar el reloj y variables temporales al anular un ciclo del bucle, ya que la variable timepoAux se modifica al principio del bucle principal mediante: timepoAux=`expr $reloj + 1` 
            fi
        fi

#Se inicializan las variables con diferentes acumulados en cada instante de reloj. Algunos acumulados sólo serían necesarios cuando se produzcan eventos, pero se podrían generalizar haciendo acumulados en cada instante.
		inicializarAcumulados 
        
# P L A N I F I C A R   P R O C E S O S  
# Si hay procesos listos en memoria(), se ejecuta el que corresponde en función del criterio de planificación que, 
# en este caso, es el que tenga una ejecución más corta de todos los procesos. Se puede expulsar a un proceso de la CPU
# Si acaba un proceso, su tiempo de ejecución se ponemos a 0 en la lista de enejecución y se libera la memoria que estaba ocupando
#Si hay que reubicar antes de meter más procesos, se hace.
#Mientras no haya un proceso en ejecución, se pone a -1. El gestor del algoritmo lo cambiará si procede.
            if [[ $alg == 1 ]]; then
#Algoritmo de gestión de procesos: FCFS
            elif [[ $alg == 2 ]]; then
#Algoritmo de gestión de procesos: SJF
            elif [[ $alg == 3 ]]; then
#Algoritmo de gestión de procesos: SRPT
            elif [[ $alg == 4 ]]; then
#Algoritmo de gestión de procesos: Prioridades
            elif [[ $alg == 5 ]]; then
#Algoritmo de gestión de procesos: Round Robin
            fi
        fi
#I M P R I M I R   E V E N T O S 
#Los eventos los determinan en las funciones gestionProcesosFCFS, gestionProcesosSJF y gestionProcesosSRPT
#Prepara la banda de tiempos de procesos en cada volcado
#Se muestran los eventos sucedidos, sobre la tabla resumen.
# C Á L C U L O   D E   L A   B A N D A   D E   M E M O R I A  
# Habrá un array inicialmente relleno de "_" que se va llenando de las referencias de los procesos (memoria()). Después será usado para formar la banda de memoria.
# $po es el índice usado para los procesos y $ra para las posiciones de la memoria al recorrer el array.
# Hay otros arrays como el que se usa para generar los diferentes bloques que conforman cada proceso, relacionados con la reubicación (bloques()).
            calculosPrepararLineasImpresionBandaMemoria
# D I B U J O   D E   L A   T A B L A   D E   D A T O S   Y   D E   L A S   B A N D A S (Normalmente, por eventos) 
# Los eventos suceden cuando se realiza un cambio en los estados de cualquiera de los procesos.
# Los tiempos T. ESPERA, T. RETORNO y T. RESTANTE sólo se mostrarán en la tabla cuando el estado del proceso sea distinto de "No ha llegado".
# Para ello hacemos un bucle que pase por todos los procesos que compruebe si el estado nollegado() es 0 y para cada uno de los tiempos, si se debe mostrar se guarda el tiempo, si no se mostrará un guión
# Hay una lista de los procesos en memoria en la variable $guardados() 
#Prepara e imprime la tabla resumen de procesos en cada volcado
#Imprime diferentes resúmenes de paginación.
#Muestra el resumen de todos los fallos de paginación del proceso finnalizado
#Para no volver a hacer la impresión del mismo proceso a lescoger procFinalizado en gestionProcesosFCFS, gestionProcesosSJF y gestionProcesosSRPT.
				procFinalizado=-1
			fi          
#Verifica qué proceso está en cada marco y determina si se produce un nuevo fallo de página, y lo muestra.
#Se imprime la banda de memoria. Nueva versión, más fácil de interpretar y adaptar, larga y con iguales resultados.
#Se imprime la banda de tiempo
#Cierre de Impresión Eventos
# Se incrementa el contador de tiempos de ejecución y de espera de los procesos y se decrementa 
# el tiempo de ejecución que tiene el proceso que se encuentra en ejecución.
#Si hay que reubicar antes de meter más procesos, se hace.
#Prepara e imprime la tabla resumen de procesos en cada volcado - AL FINAL AUMENTA $reloj.
        fi
#Fin del while con "$parar_proceso" = "NO"
#    clear
#Para ajustar el tiempo final
    echo -e "$NORMAL\n Tiempo: $tiempofinal  " | tee -a $informeConColorTotal
    echo -e " Ejecución terminada." | tee -a $informeConColorTotal
    echo -e "$NORMAL -----------------------------------------------------------\n" | tee -a $informeConColorTotal
    echo -e "\n Tiempo: $tiempofinal  " >> $informeSinColorTotal
    echo -e " Ejecución terminada." >> $informeSinColorTotal
    echo -e " -----------------------------------------------------------\n" >> $informeSinColorTotal
#Impresión de datos finales
#No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
#Elección de visualización de informes
	fi
#Final del programa principal - inicioNuevo()

#
#
#
#
#Llamada a todas las funciones de forma secuencial
#Regenera el árbol de directorios si no se encuentra. 
#Carátula inicial con autores, versiones y licencias
#Elección de ejecución o ayuda
#Inicio de la ejecución del programa

#????????????????????
#llegada[@]}"z  z"
#echo "z procPorUnidadTiempoBT z"${procPorUnidadTiempoBT[@]}"z  z"
#echo "z estado z"${estado[@]}"z  z"
#for (( counter=0 ; counter<${memoria[$ejecutandoinst]} ; counter++ )); do
#	echo -ne "z ResuFrecuenciaAcumulado ("$counter"):"
#	for (( ii=0 ; ii<=$reloj ; ii++ )); do
#		echo -ne "-"$counter" "$ii" "${ResuFrecuenciaAcumulado[$ejecutandoinst,$counter,$ii]}
#	done
#	echo ""
#done
#echo -ne $ROJO"\n\n Pulsa ENTER para continuar "$NORMAL
#read enterContinuar
#
