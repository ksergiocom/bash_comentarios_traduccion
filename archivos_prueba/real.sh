#!/bin/bash
#
#FR_10
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_40
#
#FR_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.
#FR_60 El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
#FR_70 La gestión de memoria será paginada y podrá ser Continua y No continua, y Reubicable y no resubicable.
#FR_80 Y los algoritmos de paginación para la gestión de memoria junto con alguna de sus variantes: FIFO/Reloj/SegOp/Óptimo/MFU/LFU/NFU/MRU/LRU/NRU. 

#
#FR_90 VARIABLES DE EJECUCIÓN
#
#FR_10
#FR_110 seleccionTipoPrioridad - Opciones del tipo de Prioridad (Mayor/Menor)
#FR_120 seleccionMenuApropiatividad - Opciones del tipo de Apropiatividad (Apropiativo/No Apropiativo)
#FR_130 seleccionMenuReubicabilidad - Opciones del tipo de memoria (Reubicable/No Reubicable)
#FR_140 seleccionMenuContinuidad - Opciones del tipo de memoria (Continua/No Continua)
#FR_150 seleccionMenuEleccionEntradaDatos - Opciones para la elección de fuente en la introducción de datos (Datos manual/Fichero de datos de última ejecución/Fichero de datos por defecto/Otro fichero de datos...
#FR_160 .../Rangos manual/Fichero de rangos de última ejecución/Fichero de rangos por defecto/Otro fichero de rangos...
#FR_170 .../Rangos aleatorios manual/Fichero de rangos aleatorios de última ejecución/Fichero de rangos aleatorios por defecto/Otro fichero de rangos aleatorios)
#FR_180 seleccionMenuModoTiempoEjecucionAlgormitmo - Opciones para la elección del tipo de ejecución (Por eventos/Automatico/Completo)
#FR_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación
#FR_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
#FR_230 seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#FR_240 seleccionAlgoritmoPaginacion_frecuencia_valor - Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
#
#FR_250 VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
#
#FR_260 Ancho del terminal en cada Enter de ejecución de volcados
#FR_270 ancho de columnas estrechas en tabla resumen de procesos en los volcados
#FR_280 ancho de columnas anchas en tabla resumen de procesos en los volcados
#FR_290 ancho de columnas más anchas en tabla resumen de procesos en los volcados
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_310 ancho de columnas estrechas en tabla de rangos
#FR_320 ancho de columnas anchas en tabla de rangos
varhuecos="                                                                                     "
varguiones="------------------------------------------------------------------------------------"
varasteriscos="*********************************************************************************"
varfondos="█████████████████████████████████████████████████████████████████████████████████████"
esc=$(echo -en "\033")
RESET=$esc"[0m"

#
#FR_330 VARIABLES PARA DESTACAR TEXTO CON COLOR
#
#NORMAL=$esc"[1;m"
#ROJO=$esc"[1;31m"
#VERDE=$esc"[1;32m"
#AMARILLO=$esc"[1;33m"
#AZUL=$esc"[1;34m"
#MORADO=$esc"[1;35m"
#CYAN=$esc"[1;36m"
#FR_410Variables de colores
amarillo="\033[1;33m";
verde='\e[1;32m';
morado='\e[1;35m';
rojo='\e[1;31m';
cian='\e[1;36m';
gris='\e[1;30m';
azul='\e[1;34m';
blanco='\e[1bold;37m';
#FR_420reset
#FR_430Vector de colores
coloress=();
#
#
#
#FR_440 foreground magenta
#
#
#FR_450 foreground blue
#FR_460 foreground blue
#FR_470 foreground yellow
#
#FR_480 foreground red
#
#
#
#
#FR_490 foreground cyan
#
#FR_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.
#
#
#
#FR_510INVISIBLE
#FR_520Vector de colores con el fondo pintado.
colorfondo=(); 
#FR_530 background cyan
#
#
#
#
#FR_540 background blue
#FR_550 background yellow
#
#FR_560 background red
#
#FR_570 background magenta
#FR_580 background green
#FR_590 background white
#FR_60 El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
#FR_610 hicolor
#FR_620 underline
#FR_630 inverse background and foreground
#FR_640 foreground black
#FR_650 foreground white
#FR_660 background black

#
#FR_670     Tablas de trabajo (CAMBIAR ARRAYS Y VARIABLES)
#
#FR_680     nprocesos - Número total de procesos.
#FR_690     proceso() - Nombre del proceso (P01,...).
#FR_70 La gestión de memoria será paginada y podrá ser Continua y No continua, y Reubicable y no resubicable.
#FR_710     ejecucion() - Tiempo de ejecución de los procesos
#FR_720     paginasDefinidasTotal(,) - El primer índice recorre los Procesos y el segundo las Páginas de cada Proceso
#FR_730     memoria() - Cuánta memoria necesita cada proceso.
#FR_740     temp_wait() - Se acumulan el tiempo de espera.
#FR_750     temp_exec() - Se acumulan el tiempo de ejecución.
#FR_760     bloqueados() - Procesos "En espera"
#
#FR_770     pos_inicio() - Posición de inicio en memoria.
#FR_780     pos_final() - Posición final en memoria.
#FR_790     (Para estos dos arrays (que deberán ser dinámicos) tendrémos los valores de la memoria que están ocupados por un proceso, el valor de inicio en memoria y el valor al final)
#
#FR_800     mem_total - Tamaño total de la memoria que se va a usar.
#FR_810     mem_libre - Tamaño aún libre de la memoria.
#
#FR_820     encola() tendremos qué procesos pueden entrar en memoria. Los valores son
#FR_830       0 : El proceso no ha entrado en la cola (no ha "llegado" - Estado "Fuera del sistema")
#FR_840       1 : El proceso está en la cola (Estado "En espera")
#FR_850     enmemoria()  - Procesos que se encuentran en memoria. Los valores son
#FR_860       0 : El proceso no está en memoria
#FR_870       1 : El proceso está en memoria esperando a ejecutarse (Estado "En memoria")
#FR_880     escrito()  - Procesos que se encuentran en memoria y a los que se les ha encontrado espacio sufiente en la banda de memoria.
#FR_890     ejecucion  - Número de proceso que está ejecutándose (Estado "En ejecución")
#FR_90 VARIABLES DE EJECUCIÓN
#
#FR_910     Estados de los procesos
#          ${estad[$i]} = 0 - No llegado
#          ${estad[$i]} = 1 - En espera 
#          ${estad[$i]} = 2 - En memoria 
#          ${estad[$i]} = 3 - En ejecución 
#          ${estad[$i]} = 4 - En pausa 
#          ${estad[$i]} = 5 - Terminado

#FR_980 Declaración de los arrays
#FR_990Contiene el número de unidades de ejecución y será usado para controlar que serán representadas en las bandas.
#FR_10
#FR_10
#FR_10
#FR_10
#FR_10
#FR_10
#FR_10
#FR_10
#FR_10
#FR_10
#FR_1100Posición de inicio de cada hueco de memoria asociado a cada proceso.
#FR_1110Posición final de cada hueco de memoria asociado a cada proceso.
#FR_1120Se añade al comentario principal ?????????????????????
#FR_1130Se añade al comentario principal ?????????????????????
#FR_1140Estado inicial de los procesos cuando aún no han llegado al sistema.
#FR_1150Estado de los procesos cuando han llegado al sistema, pero aún no han entrado a la memoria.
#FR_1160Estado de los procesos cuando han entrado en memoria, pero aún no han empezado a ejecutarse.
#FR_1170Estado de los procesos cuando un proceso ya ha empezado a ejecutarse, pero aunque no han terminado de ejecutarse, otro proceso ha comenzado a ejecutarse.
#FR_1180Estado de los procesos cuando un proceso ya ha empezado a ejecutarse
#FR_1190Se añade al comentario principal ?????????????????????
#FR_1200Estado de los procesos cuando ya han terminado de ejecutarse
#FR_1210Se añade al comentario principal ?????????????????????
#FR_1220Número asociado a cada estado de los procesos
#FR_1230Se añade al comentario principal
#FR_1240Secuencia de los procesos que ocupan cada marco de la memoria completa
#FR_1250Matriz auxiliar de la memoria no continua (para reubicar)
#FR_1260bandera para no escibir dos veces un proceso en memoria
#FR_1270para guardar en cuantos bloques se fragmenta un proceso
#FR_1280posición inicial de cada bloque en la memoria NO CONTINUA
#FR_1290posición final de cada bloque en la memoria NO CONTINUA
#FR_1300posición inicial en la memoria NO CONTINUA para impresiones (cuadrado en tabla)
#FR_1310posición final en la memoria NO CONTINUA para impresiones (cuadrado en tabla)
#FR_1320borrar posiciones innecesarias tras la impresión
#FR_1330borrar posiciones innecesarias tras la impresión
#FR_1340Para saber si un proceso en la barra de tiempo está nombrado, si se ha introducido en las variables de las diferentes líneas.
#FR_1350bandera para saber si hay un proceso anterior que finalizar de dibujar
#FR_1360Contiene el proceso que se esté tratando en la asignación de dígitos en la representación de la banda de tiempo
#FR_1370Guarda de uno en uno los colores para cada caracter de la barra de memoria (necesario impresión ventana)
#FR_1380Guarda de uno en uno los colores para cada caracter de la línea del tiempo (necesario impresión ventana)
#FR_1390Array que va a guardar el orden de la reubicacion
#FR_1400Array que guarda en orden de reubicación la memoria que ocupan
#FR_1410Si vale 0 no es reubicable. Si vale 1 es reubicable.
#FR_1420Si vale 0 es no continua. Si vale 1 es continua.
#FR_1430En cada casilla (instante actual - reloj) se guarda el número de orden del proceso que se ejecuta en cada instante.
#FR_1440Usada en gestionProcesosSRPT para determinar la anteriorproceso en ejecución que se compara con el actual tiempo restante de ejecución más corto y que va a ser definida como el actual proceso en ejecución.
#FR_1450Direcciones definidas de todos los Proceso (Índices:Proceso, Direcciones).
#FR_1460Páginas definidas de todos los Proceso (Índices:Proceso, Páginas).
#FR_1470Número de Páginas ya usadas de cada Proceso.
#FR_1480Secuencia de Páginas ya usadas de cada Proceso.
#FR_1490Páginas ya usadas del Proceso en ejecución. Sale de forma secuencial de paginasDefinidasTotal.
#FR_1500Páginas pendientes de ejecutar del Proceso en ejecución. Sale de forma secuencial de paginasDefinidasTotal.
#FR_1510Siguiente Página a ejecutar del Proceso en ejecución. Sale de forma secuencial de paginasDefinidasTotal con el delimitador de numeroPaginasUsadasProceso.
#FR_1520Páginas residentes en memoria del Proceso en ejecución. Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#FR_1530Páginas residentes en memoria de cada Proceso (Índices:Proceso,número ordinal de marco asociado). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#FR_1540Contiene el número de Marcos de Memoria con Páginas ya dibujadas de cada Proceso.
#FR_1550Fallos de página totales de cada proceso.
#FR_1560Desde 0, es el ordinal del número de marcos en memoria asociados a cada proceso (Índices:Proceso)

#FR_1570Resumen - Índices: (proceso). Dato: Número de Marcos usados en cada Proceso.
#FR_1580Resumen - Índices: (tiempo). Dato: Proceso que se ejecuta en cada instante de tiempo real (reloj).
#FR_1590Resumen - Índices: (proceso, tiempo de ejecución). Dato: Tiempo de reloj en el que se ejecuta un Proceso.
#FR_1600Resumen - Índices: (proceso, marco, reloj). Dato: Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_1610Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_1620Resumen - Índices: (proceso, marco, reloj). Dato: Frecuencia de la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_1630Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_1640Resumen - Índices: (proceso, reloj). Dato: Marco (Puntero) sobre el que se produce el siguiente fallo para todos los Procesos en cada unidad de Tiempo.
#FR_1650Resumen - Índices: (proceso, tiempo). Dato: Marco usado (Puntero) para cada Proceso en cada unidad de Tiempo.
#FR_1660Resumen - Índices: (marco, tiempo). Dato: Texto a iprimir en Color con el seguimiento del uso de los Marcos a lo largo del Tiempo (página-frecuencia).
#FR_1670Resumen - Índices: (marco, tiempo). Dato: Texto a iprimir en Blanco-Negro con el seguimiento del uso de los Marcos a lo largo del Tiempo (página-frecuencia).
#Resumen - Índices: (proceso, tiempo, número ordinal de marco). Dato: Relación de Marcos asignados al Proceso en ejecución en cada unidad de tiempo. El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
#FR_1690Resumen - Índices: (proceso). Dato: Último instante (reloj) en que cada proceso usó una página para realizar los acumulados de páginas y frecuencias de todos los procesos/marcos.
#FR_1700Resumen - Índices: (proceso, tiempo). Dato: Páginas que produjeron Fallos de Página del Proceso en ejecución.
#FR_1710Resumen - Índices: (proceso, tiempo). Dato: Marcos donde se produjeron Fallos de Página del Proceso en ejecución.
#FR_1720Resumen - Índices: (proceso). Dato: Número de Fallos de Página de cada Proceso.
#FR_1730Resumen - Índices: (proceso). Dato: Número de Expulsiones Forzadas de cada Proceso.
#FR_1740Resumen - Índices: (proceso). Dato: Número memor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#FR_1750Resumen - Índices: (proceso). Dato: Número mayor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#FR_1760Resumen - Índices: (proceso). Dato: Número de las posiciones con la memor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#FR_1770Resumen - Índices: (proceso). Dato: Número de las posiciones con la mayor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#FR_1780Resumen - Índices: (proceso). Dato: Número memor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#FR_1790Resumen - Índices: (proceso). Dato: Número mayor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#FR_1800Resumen - Índices: (proceso). Dato: Número de las posiciones con la memor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#FR_1810Resumen - Índices: (proceso). Dato: Número de las posiciones con la mayor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#FR_1820Resumen - Índices: (proceso, ordinal de página, reloj (0)). Dato: Se usará para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
#FR_1830Resumen - Índices: (proceso, marco). Dato: Se usará para determinar si una página ha sido o no referenciada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
#FR_1840Resumen - Índices: (proceso, tiempo de ejecución). Dato: Página referenciada (1) o no referenciada (0).
#FR_1850Resumen - Índices: (proceso, ordinal del tiempo de ejecución). Dato: Página modificada (1) o no modificada (0).
#FR_1860Resumen - Índices: (proceso). Dato: Ordinal del tiempo de ejecución en el que se hizo el último cambio de clase máxima.
#FR_1870Resumen - Índices: (proceso, marco). Dato: Histórico con el valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#FR_1880Resumen - Índices: (proceso, marco). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#FR_1890Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
#FR_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
#FR_1910Resumen - Índices: (proceso, marco, reloj). Dato: Histórico con la resta de las frecuencias de ambos momentos para ver si supera el valor límite máximo.
#FR_1920Resumen - Índices: (proceso, marco, tiempo). Dato: Clase de la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_1930Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el coeficiente M de los algoritmos de Segunda Oportunidad con valor 0 cuando se inicializa o cuando se permite su mantenimiento, aunque le toque para el fallo de paginación, y 1 como premio cuando se reutiliza.
#FR_1940Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo que hay hasta la reutilización de la página contenida en el marco.
#FR_1950Índice: (proceso). Dato: Contiene el orden de ejecución de Round-Robin (RR). Será "-" mientras no esté en cola, o cuando haya terminado, y si aún no ha terminado contendrá el número ordinal del siguiente quantum. El proceso a ejecutar será, por tanto, el que tenga el número ordinal más bajo. Y el número de quantums realizados (cambios de contexto, será el número ordinal más alto.

#FR_1960Variables para la impresión de volcados
#FR_1970Variables para la impresión de volcados
#FR_1980Variables para la impresión de volcados
#FR_1990Variables para la impresión de volcados
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos

#
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#
dirFLast="./FLast"
dirFDatos="./FDatos"
dirFRangos="./FRangos"
dirFRangosAleT="./FRangosAleT"
dirInformes="./Informes"
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación

#FR_2110Datos de particiones y procesos de la ejecución anterior.
#FR_2120Datos de particiones y procesos de la copia estándar (por defecto).

#FR_2130Rangos de particiones y procesos de la ejecución anterior.
#FR_2140Rangos de particiones y procesos de la copia estándar (por defecto).

#FR_2150Rangos amplios de particiones y procesos de la ejecución anterior para la extracción de subrangos.
#FR_2160Rangos amplios de particiones y procesos de la copia estándar (por defecto) para la extracción de subrangos.

#FR_2170Se inicializa la variable de fichero de datos
#FR_2180Se inicializa la variable de fichero de rangos
#FR_2190Se inicializa la variable de fichero de rangos amplios

#
#
#FR_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
#
#FR_2210 Sinopsis: Al inicio del programa muestra la cabecera por pantalla y la envía a los informes de B/N y COLOR. 
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
#FR_2490La opción -a lo crea inicialmente
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
#FR_2770La opción > lo crea inicialmente
    DIA=$(date +"%d/%m/%Y")
    HORA=$(date +"%H:%M")
    echo -e " ÚLTIMA EJECUCIÓN: $DIA - $HORA\n" >> $informeSinColorTotal

	echo -ne $ROJO"\n\n Pulsa ENTER para continuar "$NORMAL
	read enter
}

#
#FR_2780 Sinopsis: Cabecera de inicio
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
#FR_2910Fin de cabecerainicio()

#
#FR_2920 Sinopsis: Menú inicial con ayuda y ejecución
#
function menuInicio {
#FR_2930	clear
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
#FR_2940Menú de elección de algoritmo de gestión de procesos.
#FR_2950Menú de elección de continuidad.
#FR_2960Menú de elección de reubicabilidad.
			seleccionAlgoritmoPaginacion=0
#FR_2970Menú de elección de entrada de datos.
			;;
		'2')
#FR_2980Menú de elección de algoritmo de gestión de procesos.
#FR_2990Menú de elección de continuidad.
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
			;;
        '3')
#FR_30	TUTOR: José Manuel Saiz Diez
            ;;
        '4')
            echo $0
            echo " El informe resultante es ./zsdoc/$0.adc junto con el subdirectorio ./zsdoc/data." | tee -a $informeConColorTotal
            echo " El informe resultante es ./zsdoc/$0.adc junto con el subdirectorio ./zsdoc/data." >> $informeSinColorTotal
            echo " Si el formato no es el adecuado o para estandarizar ese formato, se puede imprimir o transformar el documento a fichero pdf." | tee -a $informeConColorTotal
            echo " Si el formato no es el adecuado o para estandarizar ese formato, se puede imprimir o transformar el documento a fichero pdf." >> $informeSinColorTotal
#FR_30	TUTOR: José Manuel Saiz Diez
            exit 0
            ;;
		'5')
			echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
			exit 0 ;;
		'33')
#FR_30	TUTOR: José Manuel Saiz Diez
			;;
#FR_30	TUTOR: José Manuel Saiz Diez
			echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
			echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal ;;
	esac
#FR_30	TUTOR: José Manuel Saiz Diez

#
#FR_30	TUTOR: José Manuel Saiz Diez
#
function menuAyuda {
#FR_30	TUTOR: José Manuel Saiz Diez
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
#FR_310 ancho de columnas estrechas en tabla de rangos
			echo -e "\n\nFicheros de ayuda existentes en formato PDF:\n$NORMAL" | tee -a $informeConColorTotal
			echo -e "\n\nFicheros de ayuda existentes en formato PDF:\n" >> $informeSinColorTotal 
			files=("./DOCPDF"/*)
#FR_3110Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
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
#FR_3130Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
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
#FR_3150No es necesario. Existe por si se modifica y no se revisa el until anterior.
			echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
			echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal ;;
	esac
#FR_3160Fin de menuAyuda()

#
#FR_3170 Sinopsis: Menú inicial con ayuda y ejecución
#
function menuEnsayos {
#FR_3180	clear
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
#FR_3190Menú de elección de algoritmo de gestión de procesos.
#FR_320 ancho de columnas anchas en tabla de rangos
#FR_3210Menú de elección de reubicabilidad.
#FR_3220Menú de elección del número de ensayos automáticos a realizar de forma continua.
#FR_3230Se definen y ejecutan los ensayos automáticos y se recogen los datos en ficheros secuenciales.
			;;
		'2')
#FR_3240Menú de elección de algoritmo de gestión de procesos.
#FR_3250Menú de elección de continuidad.
#FR_3260Menú de elección de reubicabilidad.
#FR_3270Menú de elección del número de ensayos automáticos a realizar de forma continua.
#FR_3280Se definen y ejecutan los ensayos automáticos y se recogen los datos en ficheros secuenciales.
			;;
		'3')
#FR_3290Menú de elección de algoritmo de gestión de procesos.
#FR_330 VARIABLES PARA DESTACAR TEXTO CON COLOR
#FR_3310Menú de elección de reubicabilidad.
#FR_3320Menú de elección del número de ensayos automáticos a realizar de forma continua.
#FR_3330Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos sobre los diferentes algoritmos de paginación y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
			;;
		'4') 
#FR_3340Menú de elección del número de ensayos automáticos a realizar de forma continua.
#FR_3350Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos sobre los diferentes algoritmos de gestión de procesos y de paginación y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
#FR_3360Se vuelve a inicial la aplicación
			;;
		'5')
			echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
			exit 0 ;;
#FR_3370No es necesario. Existe por si se modifica y no se revisa el until anterior.
			echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
			echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal ;;
	esac
#FR_3380Fin de menuEnsayos()

#
#FR_3390 Sinopsis: Menú de elección del Algoritmo de Gestión de Procesos; FCFS, SJF, SRPT.
#
function menuDOCPDF { 
#FR_340NORMAL=$esc"[1;m"
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

#FR_3410Comprobación de que el número introducido por el usuario es de 1 a 4
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
#FR_3420Fin de menuDOCPDF()

#
#FR_3430 Sinopsis: Menú de elección del Algoritmo de Gestión de Procesos; FCFS, SJF, SRPT.
#
function menuDOCVideo { 
#FR_3440    clear
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

#FR_3450Comprobación de que el número introducido por el usuario es de 1 a 4
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
#FR_3460Fin de menuDOCVideo()

#
#FR_3470 Sinopsis: Menú de elección del Algoritmo de Gestión de Procesos; FCFS, SJF, SRPT, Prioridades.
#
function menuAlgoritmoGestionProcesos {
#FR_3480	clear
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
#FR_3490Se comprueba que el número introducido por el usuario es de 1 a 6
    until [[ 0 -lt $seleccionMenuAlgoritmoGestionProcesos && $seleccionMenuAlgoritmoGestionProcesos -lt 7 ]];   do
        echo -ne "\nError en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
        echo -ne "\nError en la elección de una opción válida\n--> " >> $informeSinColorTotal
        read seleccionMenuAlgoritmoGestionProcesos
        echo -e "$seleccionMenuAlgoritmoGestionProcesos\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuAlgoritmoGestionProcesos\n\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuAlgoritmoGestionProcesos" in
        '4')
#FR_350ROJO=$esc"[1;31m"
#FR_3510Menú de elección de apropiatividad. Cuando se ejecuta con Prioridades. Se hace en menuAlgoritmoGestionProcesos()
			;;
    esac
#FR_3520Para que se equipare al programa nuevo.
#FR_3530Fin de menuAlgoritmoGestionProcesos()

#
#FR_3540 Sinopsis: Menú de elección de Tipo de Prioridad (Mayor/Menor). Cuando se ejecuta con Prioridades.
#
function menuTipoPrioridad { 
#FR_3550	clear
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
#FR_3560Fin de menuApropiatividad()

#
#FR_3570 Sinopsis: Menú de elección de Apropiatividad. Cuando se ejecuta con Prioridades.
#FR_3580
function menuApropiatividad { 
#FR_3590	clear
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
#FR_360VERDE=$esc"[1;32m"
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal ;;
    esac
#FR_3610Fin de menuApropiatividad()

#
#FR_3620 Sinopsis: Menú de elección de reubicabilidad.
#
#FR_3630Si reubicabilidadNo0Si1 vale 0 no es reubicable. Si vale 1 es reubicable.
#FR_3640	clear
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
#FR_3650Se comprueba que el número introducido por el usuario es de 1 a 3
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
#FR_3660No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#FR_3670Fin de menuReubicabilidad()

#
#FR_3680 Sinopsis: Menú de elección de continuidad.
#
#FR_3690Si vale 0 es no continua. Si vale 1 es continua.
#FR_370AMARILLO=$esc"[1;33m"
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
#FR_3710Se comprueba que el número introducido por el usuario es de 1 a 3
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
#FR_3720No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#FR_3730Fin de menuContinuidad()

#
#FR_3740 Sinopsis: Menú de elección de Continuidad.
#
function menuAlgoritmoPaginacion { 
#FR_3750	clear
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
#FR_3760FIFO
        '2')
#FR_3770FIFO - Segunda Oportunidad
        '3')
#FR_3780Reloj
        '4')
#FR_3790Reloj - Segunda Oportunidad
        '5')
#FR_380AZUL=$esc"[1;34m"
        '6')
#FR_3810More Frequently Used (MFU)
        '7')
#FR_3820Lest Frequently Used (LFU)
        '8')
#FR_3830No Frequently Used (NFU) sobre MFU con límite de frecuencia
#FR_3840Se pide el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
			;;
        '9')
#FR_3850No Frequently Used (NFU) sobre LFU con límite de frecuencia
#FR_3860Se pide el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
			;;
        '10')
#FR_3870No Frequently Used (NFU) con clases sobre MFU con límite de frecuencia en un intervalo de tiempo. Se inician los datos en ordenarDatosEntradaFicheros() y ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve().
#FR_3880Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#FR_3890Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#FR_390MORADO=$esc"[1;35m"
			;;
        '11')
#FR_3910No Frequently Used (NFU) con clases sobre LFU con límite de frecuencia en un intervalo de tiempo. Se inician los datos en ordenarDatosEntradaFicheros() y ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve().
#FR_3920Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#FR_3930Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#FR_3940Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
			;;
        '12')
#FR_3950More Recently Used (MRU)
        '13')
#FR_3960Lest Recently Used (LRU)
        '14')
#FR_3970No Recently Used (NRU) sobre MRU con límite de tiempo de uso
#FR_3980Se pide el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
			;;
        '15')
#FR_3990No Recently Used (NRU) sobre LRU con límite de tiempo de uso
#FR_40
			;;
        '16')
#FR_40
#FR_40
#FR_40
#FR_40
			;;
        '17')
#FR_40
#FR_40
#FR_40
#FR_40
			;;
        '18')
            echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
            exit 0 ;;
#FR_40
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal $informeSinColorTotal ;;
    esac
#FR_410Variables de colores

#
#FR_4110 Sinopsis: Se pide el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
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
#FR_4120Fin de menuAlgoritmoPaginacion_frecuencia()

#
#FR_4130 Sinopsis: Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
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
#FR_4140Fin de menuAlgoritmoPaginacion_clases_frecuencia()

#
#FR_4150 Sinopsis: Se pide el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
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
#FR_4160Fin de menuAlgoritmoPaginacion_uso_rec()

#
#FR_4170 Sinopsis: Se pide el valor máximo del contador de antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.
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
#FR_4180Fin de menuAlgoritmoPaginacion_clases_uso_rec()

#
#FR_4190 Sinopsis: Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
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
#FR_420reset

#
#FR_4210 Sinopsis: Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
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
#FR_4220Fin de menuAlgoritmoPaginacion_TiempoConsiderado_valor()

#
#FR_4230 Sinopsis: Menú de elección de opciones de entrada de datos/rangos/rangos amplios del programa:
#FR_4240 Manul, Última ejecución, Otros ficheros.
#
function menuEleccionEntradaDatos {
#FR_4250	clear
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

#FR_4260Se comprueba que el número introducido por el usuario es de 1 a 10
    until [[ 0 -lt $seleccionMenuEleccionEntradaDatos && $seleccionMenuEleccionEntradaDatos -lt 11 ]];  do
        echo -ne "\n Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read seleccionMenuEleccionEntradaDatos
        echo -ne "$seleccionMenuEleccionEntradaDatos\n\n" >> $informeConColorTotal
        echo -ne "$seleccionMenuEleccionEntradaDatos\n\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuEleccionEntradaDatos" in
#FR_42701. Introducción de datos manual
            nuevaEjecucion
            preguntaDondeGuardarDatosManuales
            entradaMemoriaTeclado
            entradaProcesosTeclado
            menuModoTiempoEjecucionAlgormitmo
            ;;
#FR_42802. Fichero de datos de última ejecución (./FLast/DatosLast.txt).
#FR_4290Elección del algoritmo de gestión de procesos y la fuente de datos.
            leer_datos_desde_fichero $ficheroDatosAnteriorEjecucion
#FR_430Vector de colores
            ;;
#FR_43103. Otros ficheros de datos $ficheroDatosAnteriorEjecucion
#FR_4320Elegir el fichero para la entrada de datos $ficheroParaLectura.
#FR_4330Elección del algoritmo de gestión de procesos y la fuente de datos.
#FR_4340Leer los datos desde el fichero elegido $ficheroParaLectura
#FR_4350Ordenar los datos sacados desde $ficheroParaLectura por el tiempo de llegada.
            ;;
#FR_43604. Introducción de rangos manual (modo aleatorio)
#FR_4370Resuelve los nombres de los ficheros de rangos
#FR_4380Resuelve los nombres de los ficheros de datos
            nuevaEjecucion 
            entradaMemoriaRangosFichero_op_cuatro
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#FR_43905. Fichero de rangos de última ejecución (./FLast/RangosLast.txt)
            entradaMemoriaRangosFichero_op_cinco_Previo
#FR_440 foreground magenta
            entradaMemoriaRangosFichero_op_cinco_seis
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#FR_44106. Otros ficheros de rangos
            nuevaEjecucion 
            entradaMemoriaRangosFichero_op_seis_Previo 
#FR_4420Leer los datos desde el fichero elegido $ficheroParaLectura
            entradaMemoriaRangosFichero_op_cinco_seis
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#FR_44307. Introducción de rangos amplios manual (modo aleatorio total)
            nuevaEjecucion 
            entradaMemoriaRangosFichero_op_siete_Previo
            entradaMemoriaRangosFichero_op_siete_ocho_nueve
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#FR_44408. Fichero de rangos amplios de última ejecución
#FR_4450Pregunta en qué fichero guardar los rangos para la opción 8.
#FR_4460Leer los datos desde el fichero elegido $ficheroRangosAleTotalAnteriorEjecucion
            entradaMemoriaRangosFichero_op_siete_ocho_nueve
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#FR_44709. Otros ficheros de rangos amplios
            nuevaEjecucion 
            entradaMemoriaRangosFichero_op_nueve_Previo
#FR_4480Leer los datos desde el fichero elegido $ficheroParaLectura
            entradaMemoriaRangosFichero_op_siete_ocho_nueve
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#FR_449010. Salir
            echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
            exit 0 ;;
#FR_450 foreground blue
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#FR_4510Fin de menuEleccionEntradaDatos()

#
#FR_4520 Sinopsis: Se decide el modo de ejecución: Por eventos, Automática, Completa, Unidad de tiempo a unidad de tiempo
#
function menuModoTiempoEjecucionAlgormitmo {
#FR_4530	clear
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
#FR_4540 Se comprueba que el número introducido por el usuario esta entre 1 y 5
    until [[ "0" -lt $seleccionMenuModoTiempoEjecucionAlgormitmo && $seleccionMenuModoTiempoEjecucionAlgormitmo -lt "6" ]]; do
        echo -ne "\n Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne " Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read seleccionMenuModoTiempoEjecucionAlgormitmo
        echo -e "$seleccionMenuModoTiempoEjecucionAlgormitmo\n" >> $informeConColorTotal
        echo -e "$seleccionMenuModoTiempoEjecucionAlgormitmo\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuModoTiempoEjecucionAlgormitmo" in
#FR_4550 Por eventos
            optejecucion=1
            ;;
#FR_4560 Automática
            tiempoejecucion=0
            optejecucion=2
            ;;
#FR_4570 Completa
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
#FR_4580 De unidad de tiempo en unidad de tiempo
            optejecucion=4
            ;;
#FR_4590 Sólo muestra el resumen final
            optejecucion=5
            ;;
#FR_460 foreground blue
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#FR_4610    clear
#FR_4620Fin de menuModoTiempoEjecucionAlgormitmo()

#
#FR_4630 Sinopsis: Comprobar si existe el árbol de directorios utilizados en el programa
#
#FR_4640Regenera el árbol de directorios si no se encuentra.
#FR_4650    clear
#FR_4660Se regenera la estructura de directorios en caso de no existir
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
#FR_4670Informes y temporales
    if [[ -f $informeConColorTotal ]]; then
#FR_4680Se borran los ficheros de informes COLOR
    fi
    if [[ -f $informeSinColorTotal ]]; then
#FR_4690Se borran los ficheros de informes BN
    fi
#FR_470 foreground yellow

#
#FR_4710 Sinopsis: Se pregunta por las opciones de guardar lo datos de particiones y procesos.
#FR_4720 Se pregunta si se quiere guardar los datos en el fichero estándar (Default) o en otro.
#FR_4730 Si es en otro, pide el nombre del archivo.
#
function preguntaDondeGuardarDatosManuales {
#FR_4740Pregunta para los datos por teclado
    echo -e $AMARILLO"\n¿Dónde quiere guardar los datos resultantes?\n"$NORMAL | tee -a $informeConColorTotal
    echo -e " 1- En el fichero estándar ($ficheroDatosDefault)" | tee -a $informeConColorTotal
    echo -ne " 2- En otro fichero\n\n\n--> " | tee -a $informeConColorTotal
    echo -e "¿Dónde quiere guardar los datos resultantes?\n\n" >> $informeSinColorTotal
    echo -e " 1- En el fichero estándar ($ficheroDatosDefault)" >> $informeSinColorTotal
    echo -ne " 2- En otro fichero\n\n\n--> " >> $informeSinColorTotal
    read seleccionMenuPreguntaDondeGuardarDatosManuales
    echo -e " $seleccionMenuPreguntaDondeGuardarDatosManuales\n\n" >> $informeConColorTotal
    echo -e " $seleccionMenuPreguntaDondeGuardarDatosManuales\n\n" >> $informeSinColorTotal
#FR_4750 Se comprueba que el número introducido por el usuario esta entre 1 y 2
    until [[ "0" -lt $seleccionMenuPreguntaDondeGuardarDatosManuales && $seleccionMenuPreguntaDondeGuardarDatosManuales -lt "3" ]]; do
        echo -ne "\n Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read seleccionMenuPreguntaDondeGuardarDatosManuales
        echo -e " $seleccionMenuPreguntaDondeGuardarDatosManuales\n\n" >> $informeConColorTotal
        echo -e " $seleccionMenuPreguntaDondeGuardarDatosManuales\n\n" >> $informeSinColorTotal
    done
    case "${seleccionMenuPreguntaDondeGuardarDatosManuales}" in
#FR_4760En el fichero estándar
#FR_4770Se borran los datos del fichero por defecto de la anterior ejecución
            nomFicheroDatos="$ficheroDatosDefault"
            ;;
#FR_4780En otro fichero
            echo -e $ROJO"\n Ficheros de datos ya existentes en './FDatos/': "$NORMAL | tee -a $informeConColorTotal
            echo -e "\n Ficheros de datos ya existentes en './FDatos/': " >> $informeSinColorTotal
            files=($(ls -l ./FDatos/ | awk '{print $9}'))
#FR_4790Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
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
#FR_480 foreground red
            done
            ;;
#FR_4810No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#FR_4820    clear
#FR_4830Fin de preguntaDondeGuardarDatosManuales()
        
#
#FR_4840 Sinopsis: Se pregunta por las opciones de guardar lo rangos de particiones y procesos.
#FR_4850 Se pregunta si se quiere guardar los rangos en el fichero estándar (Default) o en otro.
#FR_4860 Si es en otro, pide el nombre del archivo.
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

#FR_4870 Se comprueba que el número introducido por el usuario esta entre 1 y 2
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
#FR_4880En el fichero estándar
#FR_4890Se borran los rangos del fichero por defecto de la anterior ejecución
            nomFicheroRangos="$ficheroRangosDefault"
            ;;
#FR_490 foreground cyan
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
#FR_4910cierre el sobreescribir NO
            done
            ;;
#FR_4920No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e "Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e "Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#FR_4930Fin de preguntaDondeGuardarRangosManuales()

#
#FR_4940 Sinopsis: Se pregunta por las opciones de guardar los mínimos y máximos de los rangos amplios.
#FR_4950 Se pregunta si se quiere guardar los rangos en el fichero estándar (Default) o en otro.
#FR_4960 Si es en otro, pide el nombre del archivo.
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
#FR_4970 Se comprueba que el número introducido por el usuario esta entre 1 y 2
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
#FR_4980En el fichero estándar
#FR_4990Se borran los rangos del fichero por defecto de la anterior ejecución
            nomFicheroRangosAleT="$ficheroRangosAleTotalDefault"
            ;;
#FR_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.
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
#FR_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.
            done
            ;;
#FR_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.
            echo -e "Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e "Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#FR_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.

#
#FR_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.
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
#FR_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.

#
#
#FR_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.
#
#
#
#FR_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.
#
function ejecutarEnsayosDatosDiferentes { 
#FR_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.
#FR_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.
#FR_510INVISIBLE
#FR_5110Se pueden definir los diferentes modos de ejecución (1-Ejecución por eventos // 2-Ejecución automática (Por eventos y sin pausas) // 3-Ejecución completa (Por eventos con pausas de cierto número de segundos) // 4-Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo) // 5-Ejecución completa (Sin representación de resultados intermedios)) 
#FR_5120Sólo se guardan los datos de las medias de los tiempos de espera y retorno, el número de fallos de página totales y el número de expulsiones de procesos forzadas en RR totales. Viene de la variable $seleccionMenuModoTiempoEjecucionAlgormitmo en el menú de selección de modo de ejecución MenuModoTiempoEjecucionAlgormitmo()
	dirInformes="./Informes/RecogerDatosAutomDiferentes"
	if [[ ! -d $dirInformes ]]; then
		mkdir $dirInformes   
	fi
#FR_5130Se inicializa la variable de fichero de datos dond se recogen todos los datos finales.
	if [[ -f $nomFicheroDatosEjecucionAutomatica ]]; then
#FR_5140Se borran los ficheros anteriores
	fi
#FR_5150Origen de los datos sobre los que se desarrollan los subrangos, sobre lso que se extraen los datos, sobre los que se ejecuta el programa.
	for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
		for (( indEnsayos = 1; indEnsayos <= $seleccionNumEnsayos; indEnsayos++ )); do 
#FR_5160Se define el fichero sobre el que se guarda el rango amplio.
			if [[ -f $ficheroRangosAleTotalDefault ]]; then
#FR_5170Se borran los ficheros anteriores
			fi
#FR_5180Se define el fichero sobre el que se guardan los subrangos.
			if [[ -f $nomFicheroRangos ]]; then
#FR_5190Se borran los ficheros anteriores
			fi
#FR_520Vector de colores con el fondo pintado.
			if [[ -f $nomFicheroDatos ]]; then
#FR_5210Se borran los ficheros anteriores
			fi
#FR_5220Se define el fichero sobre el que se guardan los volcados en COLOR.
			if [[ -f $informeSinColorTotal ]]; then
#FR_5230Se borran los ficheros anteriores
			fi
#FR_5240Se define el fichero sobre el que se guardan los volcados en BN.
			if [[ -f $informeConColorTotal ]]; then
#FR_5250Se borran los ficheros anteriores
			fi
#FR_5260Leer los datos desde el fichero elegido $ficheroRangosAleTotalAnteriorEjecucion
#FR_5270Se piden y tratan los mínimos y máximos de los rangos. El cálculo de los datos aleatorios con los que se trabajará se hace en entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun.
#FR_5280Ordena los datos para ser mostrados y considerados por orden de llegada.
			echo -e "Algoritmo de paginación: $seleccionAlgoritmoPaginacion\n" >> $informeConColorTotal
			echo -e "Número de Ensayo: $indEnsayos\n" >> $informeConColorTotal
#FR_5290Cuando se han definido todas las opciones se inicia la ejecución del programa
#FR_530 background cyan
			echo -e "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado AlgPag $seleccionAlgoritmoPaginacion NumEnsayo $indEnsayos Tesperamedio $promedio_espera T.retornomedio $promedio_retorno TotalFallosPagina $suma_contadorAlgPagFallosProcesoAcumulado TotalExpulsionesForzadasRR $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
		done
	done
#FR_5310Fin de ejecutarEnsayosDatosDiferentes()

#
#FR_5320Se definen y ejecutan los ensayos automáticos y se recogen los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
#
function ejecutarEnsayosDatosIguales { 
#FR_5330Número de algoritmos de paginación que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#FR_5340Rango desde el que se extraen subrangos, desde los que se extraen datos, que se ejecutan con las diferentes opciones.
#FR_5350Se pueden definir los diferentes modos de ejecución (1-Ejecución por eventos // 2-Ejecución automática (Por eventos y sin pausas) // 3-Ejecución completa (Por eventos con pausas de cierto número de segundos) // 4-Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo) // 5-Ejecución completa (Sin representación de resultados intermedios)) 
#FR_5360Sólo se guardan los datos de las medias de los tiempos de espera y retorno, el número de fallos de página totales y el número de expulsiones de procesos forzadas en RR totales. Viene de la variable $seleccionMenuModoTiempoEjecucionAlgormitmo en el menú de selección de modo de ejecución MenuModoTiempoEjecucionAlgormitmo()
	dirInformes="./Informes/RecogerDatosAutomIguales"
#FR_5370Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#FR_5380Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
	if [[ ! -d $dirInformes ]]; then
		mkdir $dirInformes   
	fi
#FR_5390Se inicializa la variable de fichero de datos dond se recogen todos los datos finales.
	if [[ -f $nomFicheroDatosEjecucionAutomatica ]]; then
#FR_540 background blue
	fi
			echo -ne "Título AlgPag NumEnsayo T.esperamedio T.retornomedio TotalFallosPagina TotalExpulsionesForzadasRR" >> $nomFicheroDatosEjecucionAutomatica
			echo -ne " MáxFrec TiempoConsiderado FrecValor Clase" >> $nomFicheroDatosEjecucionAutomatica
			echo -e " MáxUsoRec TiempoConsiderado UsoRecValor Clase" >> $nomFicheroDatosEjecucionAutomatica
#FR_5410Origen de los datos sobre los que se desarrollan los subrangos, sobre lso que se extraen los datos, sobre los que se ejecuta el programa.
#FR_5420Primero se inicializan los ficheros con los datos a tratar.
#FR_5430Se define el fichero sobre el que se guarda el rango amplio.
		if [[ -f $ficheroRangosAleTotalDefault ]]; then
#FR_5440Se borran los ficheros anteriores
		fi
#FR_5450Se define el fichero sobre el que se guardan los subrangos.
		if [[ -f $nomFicheroRangos ]]; then
#FR_5460Se borran los ficheros anteriores
		fi
#FR_5470Se define el fichero sobre el que se guardan los datos que se extraen de los subrangos.
		if [[ -f $nomFicheroDatos ]]; then
#FR_5480Se borran los ficheros anteriores
		fi
#FR_5490Leer los datos desde el fichero elegido $ficheroRangosAleTotalAnteriorEjecucion
#FR_550 background yellow
	done
#FR_5510Ahora se leen los datos ya guardados en los ficheros de datos y se tratan.
#FR_5520Se define el fichero desde el que se leen los datos que se extraen de los subrangos.
		maxDatoCierre=0
		leer_datos_desde_fichero $nomFicheroDatos
#FR_5530Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
			maxDato=0
			maxDatoCierre=1
#FR_5540Se calcula el mayor de lso tiempos de ejecución para calcular un valor aleatorio entre 1 y ese máximo. Podría usarse cualquier rango, pero este dato puede estar relacionado con lso datos del problema.
				if [[ ${ejecucion[$i]} -gt $maxDato ]]; then 
					maxDato=${ejecucion[$i]} 
				fi
			done
		fi
		for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
#FR_5550Se define el fichero sobre el que se guardan los volcados en COLOR.
			if [[ -f $informeSinColorTotal ]]; then
#FR_5560Se borran los ficheros anteriores
			fi
#FR_5570Se define el fichero sobre el que se guardan los volcados en BN.
			if [[ -f $informeConColorTotal ]]; then
#FR_5580Se borran los ficheros anteriores
			fi
#FR_5590Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#8-9-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
#FR_5610 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_frecuencia_valor=$datoAleatorioGeneral
			fi
#FR_5620Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#FR_563010-11-Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#FR_5640 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#FR_565010-11-Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#FR_5660 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_frecuencia_valor=$datoAleatorioGeneral
#FR_567010-11-Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
#FR_5680 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
			fi
#FR_5690Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#14-15-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
#FR_5710 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_uso_rec_valor=$datoAleatorioGeneral
			fi
#FR_5720Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#16-17-Se pide el número de unidades de tiempo de ejecución de un proceso, a partir del cual, serán consideradas la frecuencia/tiempo de uso de una página y su clase: \n$NORMAL" | tee -a $informeConColorTotal
#FR_5740 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de la antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
#FR_5760 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_uso_rec_valor=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de unidades de tiempo de antigüedad de ejecución de un proceso, a partir de la cual, una página será considerada como NO referenciada: \n$NORMAL" | tee -a $informeConColorTotal
#FR_5780 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
			fi
#FR_5790Ordena los datos para ser mostrados y considerados por orden de llegada.
			echo -ne "$NORMAL\nAlgoritmo de paginación:$seleccionAlgoritmoPaginacion" | tee -a $informeConColorTotal
			echo -ne "$NORMAL\nNúmero de Ensayo:$indEnsayos\n" | tee -a $informeConColorTotal
			echo -e "Algoritmo de paginación: $seleccionAlgoritmoPaginacion" >> $informeSinColorTotal
			echo -e "Número de Ensayo: $indEnsayos" >> $informeSinColorTotal
#FR_580 background green
#FR_5810Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
			echo -ne "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado $seleccionAlgoritmoPaginacion $indEnsayos $promedio_espera $promedio_retorno $suma_contadorAlgPagFallosProcesoAcumulado $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
			echo -ne " $seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
			echo -e " $seleccionAlgoritmoPaginacion_uso_rec_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
		done
	done	
#FR_5820Fin de ejecutarEnsayosDatosIguales()

#
#FR_5830Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
#
function ejecutarEnsayosDatosIgualesAnteriores { 
#FR_5840Número de algoritmos de paginación que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#FR_5850Datos, que se ejecutan con las diferentes opciones.
#FR_5860Se pueden definir los diferentes modos de ejecución (1-Ejecución por eventos // 2-Ejecución automática (Por eventos y sin pausas) // 3-Ejecución completa (Por eventos con pausas de cierto número de segundos) // 4-Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo) // 5-Ejecución completa (Sin representación de resultados intermedios)) 
#FR_5870Sólo se guardan los datos de las medias de los tiempos de espera y retorno, el número de fallos de página totales y el número de expulsiones de procesos forzadas en RR totales. Viene de la variable $seleccionMenuModoTiempoEjecucionAlgormitmo en el menú de selección de modo de ejecución MenuModoTiempoEjecucionAlgormitmo()
	dirInformes="./Informes/RecogerDatosAutomIguales"
	dirInformesAnteriores="./Informes/RecogerDatosAutomIgualesAnteriores"
#FR_5880Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#FR_5890Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
	if [[ ! -d $dirInformesAnteriores ]]; then
		mkdir $dirInformesAnteriores   
	fi
#FR_590 background white
#FR_5910Se define el fichero sobre el que se guardan los datos que se extraen de los subrangos.
		if [[ -f $nomFicheroDatos ]]; then
#FR_5920Se borran los ficheros anteriores
		fi
	done
    files=($dirInformes"/DatosDefault"*".txt")
    echo -e "\n\nFicheros existentes:\n$NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\nFicheros existentes:\n" >> $informeSinColorTotal 
#FR_5930Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
        echo -e ${files[$i]} 
        cp ${files[$i]} "$dirInformesAnteriores/"
    done
#FR_5940Se inicializa la variable de fichero de datos dond se recogen todos los datos finales.
	if [[ -f $nomFicheroDatosEjecucionAutomatica ]]; then
#FR_5950Se borran los ficheros anteriores
	fi
	echo -ne "Título AlgPag NumEnsayo T.esperamedio T.retornomedio TotalFallosPagina TotalExpulsionesForzadasRR" >> $nomFicheroDatosEjecucionAutomatica
	echo -ne " MáxFrec TiempoConsiderado FrecValor Clase" >> $nomFicheroDatosEjecucionAutomatica
	echo -e " MáxUsoRec TiempoConsiderado UsoRecValor Clase" >> $nomFicheroDatosEjecucionAutomatica
#FR_5960Ahora se leen los datos ya guardados en los ficheros de datos y se tratan.
#FR_5970Se define el fichero desde el que se leen los datos que se extraen de los subrangos.
		maxDatoCierre=0
		leer_datos_desde_fichero $nomFicheroDatos
#FR_5980Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
			maxDato=0
			maxDatoCierre=1
#FR_5990Se calcula el mayor de lso tiempos de ejecución para calcular un valor aleatorio entre 1 y ese máximo. Podría usarse cualquier rango, pero este dato puede estar relacionado con lso datos del problema.
				if [[ ${ejecucion[$i]} -gt $maxDato ]]; then 
					maxDato=${ejecucion[$i]} 
				fi
			done
		fi
		for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
#FR_60 El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
			if [[ -f $informeSinColorTotal ]]; then
#FR_60 El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
			fi
#FR_60 El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
			if [[ -f $informeConColorTotal ]]; then
#FR_60 El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
			fi
#FR_60 El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
#8-9-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
#FR_60 El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
				seleccionAlgoritmoPaginacion_frecuencia_valor=$datoAleatorioGeneral
			fi
#FR_60 El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
#FR_60 El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
#FR_60 El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
				seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#FR_610 hicolor
#FR_6110 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_frecuencia_valor=$datoAleatorioGeneral
#FR_612010-11-Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
#FR_6130 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
			fi
#FR_6140Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#14-15-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
#FR_6160 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_uso_rec_valor=$datoAleatorioGeneral
			fi
#FR_6170Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#16-17-Se pide el número de unidades de tiempo de ejecución de un proceso, a partir del cual, serán consideradas la frecuencia/tiempo de uso de una página y su clase: \n$NORMAL" | tee -a $informeConColorTotal
#FR_6190 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de la antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
#FR_6210 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_uso_rec_valor=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de unidades de tiempo de antigüedad de ejecución de un proceso, a partir de la cual, una página será considerada como NO referenciada: \n$NORMAL" | tee -a $informeConColorTotal
#FR_6230 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
			fi
#FR_6240Ordena los datos para ser mostrados y considerados por orden de llegada.
			echo -ne "$NORMAL\nAlgoritmo de paginación:$seleccionAlgoritmoPaginacion" | tee -a $informeConColorTotal
			echo -ne "$NORMAL\nNúmero de Ensayo:$indEnsayos\n" | tee -a $informeConColorTotal
			echo -e "Algoritmo de paginación: $seleccionAlgoritmoPaginacion" >> $informeSinColorTotal
			echo -e "Número de Ensayo: $indEnsayos" >> $informeSinColorTotal
#FR_6250Cuando se han definido todas las opciones se inicia la ejecución del programa
#FR_6260Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
			echo -ne "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado $seleccionAlgoritmoPaginacion $indEnsayos $promedio_espera $promedio_retorno $suma_contadorAlgPagFallosProcesoAcumulado $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
			echo -ne " $seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
			echo -e " $seleccionAlgoritmoPaginacion_uso_rec_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
		done
	done	
#FR_6270Fin de ejecutarEnsayosDatosIgualesAnteriores()

#
#FR_6280Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
#
function ejecutarEnsayosDatosIgualesAnterioresCompleto { 	
#FR_6290Se define la fuente de datos utilizada para la obtención de los datos a utilizar en el posterior tratamiento.
#FR_630 inverse background and foreground
#FR_6310Se definen los diferentes modos de ejecución (1-Ejecución por eventos // 2-Ejecución automática (Por eventos y sin pausas) // 3-Ejecución completa (Por eventos con pausas de cierto número de segundos) // 4-Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo) // 5-Ejecución completa (Sin representación de resultados intermedios)) 
#FR_6320Sólo se guardan los datos de las medias de los tiempos de espera y retorno, el número de fallos de página totales y el número de expulsiones de procesos forzadas en RR totales. Viene de la variable $seleccionMenuModoTiempoEjecucionAlgormitmo en el menú de selección de modo de ejecución MenuModoTiempoEjecucionAlgormitmo()
#FR_6330Se definen los diferentes directorios utilizados para guardar los datos obtenidos
	dirInformes="./Informes/RecogerDatosAutomIguales"
	dirInformesAnterioresCompleto="./Informes/RecogerDatosAutomIgualesAnterioresCompleto"
#FR_6340Se definen las variables necesarias para ejecutar los diferentes algoritmos y opciones.
#FR_6350Define el título de la cabecera de los volcados
#FR_6360Define el número de ensayo tratado
#FR_6370Define el algoritmo usado para resolver la gestión de Procesos (FCFS/SJF/SRPT/Prioridades/Round-Robin)
#FR_6380Máximo número de algoritmos de gestión de procesos (FCFS (1), SJF (2), SRPT (3), Prioridades (4), Round-Robin (5)) que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#FR_6390Máximo número de opciones del tipo de memoria (No Continua (1)/Continua (2)) 
#FR_640 foreground black
#FR_6410Máximo número de opciones del tipo de memoria (No Reubicable (1)/Reubicable (2)) 
#FR_6420Máximo número de opciones del tipo de reubicabilidad (No Reubicable (0)/Reubicable (1)) 
#FR_6430Define el algoritmo usado para resolver los fallos de página.
#FR_6440Máximo número de algoritmos de paginación (FIFO, Reloj, SegOp, Óptimo, MFU, LFU, NFU, MRU, LRU, NRU,...) que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#FR_6450Máximo número de opciones del tipo de prioridad (Mayor (1)/Menor (2)) 
#FR_6460Máximo número de opciones del tipo de apropiatividad (No Apropiativo (1)/Apropiativo (2)) 
#FR_6470Máximo número de opciones del tipo de apropiatividad (No Apropiativo (0)/Apropiativo (1)) 
#FR_6480Define el tiempo de espera medio de los procesos
#FR_6490Define el tiempo de retorno medio de los procesos
#FR_650 foreground white
#FR_6510Define el número de expulsiones forzadas por Round-Robin (RR)
#FR_6520Define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
#FR_6530Define el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#FR_6540Define el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#FR_6550Define el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada en algoritmos basados en la "frecuencia/tiempo de antigüedad" de uso
#FR_6560Define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#FR_6570Define el valor máximo del contador de antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.
	
	if [[ ! -d $dirInformesAnterioresCompleto ]]; then
		mkdir $dirInformesAnterioresCompleto   
	fi
#FR_6580Primero se inicializan los ficheros con los datos a tratar.
#FR_6590Se define el fichero sobre el que se guardan los datos que se extraen de los subrangos.
		if [[ -f $nomFicheroDatos ]]; then
#FR_660 background black
		fi
	done
    files=($dirInformes"/DatosDefault"*".txt")
    echo -e "\n\nFicheros existentes:\n$NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\nFicheros existentes:\n" >> $informeSinColorTotal 
#FR_6610Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
        echo -e ${files[$i]} 
        cp ${files[$i]} "$dirInformesAnterioresCompleto/"
    done
#FR_6620Se inicializa la variable de fichero de datos dond se recogen todos los datos finales.
	if [[ -f $nomFicheroDatosEjecucionAutomatica ]]; then
#FR_6630Se borran los ficheros anteriores
	fi
	echo -ne "Título NumEnsayo AlgGestProc Contin Reubic AlgPag TipoPrio Apropia Quantum" >> $nomFicheroDatosEjecucionAutomatica
	echo -ne " T.esperamedio T.retornomedio TotalFallosPagina TotalExpulsionesForzadasRR" >> $nomFicheroDatosEjecucionAutomatica
	echo -ne " MáxFrec TiempoConsiderado FrecValor FrecClase" >> $nomFicheroDatosEjecucionAutomatica
	echo -e " MáxUsoRec TiempoConsiderado UsoRecValor UsoRecClase" >> $nomFicheroDatosEjecucionAutomatica
#FR_6640Ahora se leen los datos ya guardados en los ficheros de datos y se tratan.
#FR_6650Se define el fichero desde el que se leen los datos que se extraen de los subrangos.
#FR_6660Si no se encuentra un archivo de datos por no haber creado previamente el conjunto de datos necesario, se muestra un mensaje de error y se para el bucle.
		echo -ne "Error: No se encuentra el fichero de datos "$nomFicheroDatos | tee -a $informeConColorTotal
		echo -ne "Error: No se encuentra el fichero de datos "$nomFicheroDatos >> $informeSinColorTotal 
		break
	fi		
		maxDatoCierre=0
		leer_datos_desde_fichero $nomFicheroDatos
#FR_6670Define el quantum utilizado en Round-Robin (RR). Se usa para salvar el dato hasta que se necesite y que no se repita en los listados.
#FR_6680Define el quantum utilizado en Round-Robin (RR)
#FR_6690Define el tipo de apropiatividad utilizado en Prioridad. Se usa para salvar el dato hasta que se necesite y que no se repita en los listados.
#FR_670     Tablas de trabajo (CAMBIAR ARRAYS Y VARIABLES)
#FR_6710Define el modo de apropiatividad utilizado en Prioridad. Se usa para salvar el dato hasta que se necesite y que no se repita en los listados.
#FR_6720Define el Tipo de Apropiatividad (No Apropiativo (1)/Apropiativo (2)).
#FR_6730Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
			maxDato=0
			maxDatoCierre=1
#FR_6740Se calcula el mayor de lso tiempos de ejecución para calcular un valor aleatorio entre 1 y ese máximo. Podría usarse cualquier rango, pero este dato puede estar relacionado con lso datos del problema.
				if [[ ${ejecucion[$i]} -gt $maxDato ]]; then 
					maxDato=${ejecucion[$i]} 
				fi
			done
		fi
		for (( seleccionMenuAlgoritmoGestionProcesos=1 ; seleccionMenuAlgoritmoGestionProcesos<=$numAlgoritmosGestionProcesos ; seleccionMenuAlgoritmoGestionProcesos++ )); do
			if ([[ $seleccionMenuAlgoritmoGestionProcesos -ge 1 && $seleccionMenuAlgoritmoGestionProcesos -le 3 ]]) || [[ $seleccionMenuAlgoritmoGestionProcesos -eq 5 ]]; then
#FR_6750Para que se equipare al programa nuevo. Se aconseja quitar la variable $alg y estandarizar las variables a usar ??????????. También se define en menuAlgoritmoGestionProcesos, pero resulta necesario cuando no se pregunta por el algoritmo de gestión de procesos porque se ejecutan todos.
#FR_6760Define el quantum utilizado en Round-Robin (RR). Se usa para recuperar el dato cuando se necesite y que no se repita en los listados.
#FR_6770Se hace para eliminar el espacio que contiene la variable, y por el que la exportación a fichero da problemas porque el resto de datos se desplazan hacia la derecha.
				fi
#FR_6780Define el número de opciones del tipo de memoria (Continua/No Continua)
				for (( seleccionMenuContinuidad=1 ; seleccionMenuContinuidad<=$numAlgoritmosContinuidad ; seleccionMenuContinuidad++ )); do
#FR_6790Define el número de opciones del tipo de memoria (Reubicable/No Reubicable)
					for (( seleccionMenuReubicabilidad=1 ; seleccionMenuReubicabilidad<=$numAlgoritmosReubicabilidad ; seleccionMenuReubicabilidad++ )); do		
						for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
#FR_680     nprocesos - Número total de procesos.
							if [[ -f $informeSinColorTotal ]]; then
#FR_6810Se borran los ficheros anteriores
							fi
#FR_6820Se define el fichero sobre el que se guardan los volcados en BN.
							if [[ -f $informeConColorTotal ]]; then
#FR_6830Se borran los ficheros anteriores
							fi
#FR_6840Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#8-9-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
#FR_6860 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_frecuencia_valor=$datoAleatorioGeneral
							fi
#FR_6870Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#FR_688010-11-Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#FR_6890 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#FR_690     proceso() - Nombre del proceso (P01,...).
#FR_6910 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_clases_frecuencia_valor=$datoAleatorioGeneral
#FR_692010-11-Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
#FR_6930 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
							fi
#FR_6940Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#14-15-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
#FR_6960 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_uso_rec_valor=$datoAleatorioGeneral
							fi
#FR_6970Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#16-17-Se pide el número de unidades de tiempo de ejecución de un proceso, a partir del cual, serán consideradas la frecuencia/tiempo de uso de una página y su clase: \n$NORMAL" | tee -a $informeConColorTotal
#FR_6990 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de la antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
#FR_70 La gestión de memoria será paginada y podrá ser Continua y No continua, y Reubicable y no resubicable.
								seleccionAlgoritmoPaginacion_clases_uso_rec_valor=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de unidades de tiempo de antigüedad de ejecución de un proceso, a partir de la cual, una página será considerada como NO referenciada: \n$NORMAL" | tee -a $informeConColorTotal
#FR_70 La gestión de memoria será paginada y podrá ser Continua y No continua, y Reubicable y no resubicable.
								seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
							fi
#FR_70 La gestión de memoria será paginada y podrá ser Continua y No continua, y Reubicable y no resubicable.
#FR_70 La gestión de memoria será paginada y podrá ser Continua y No continua, y Reubicable y no resubicable.
#FR_70 La gestión de memoria será paginada y podrá ser Continua y No continua, y Reubicable y no resubicable.
							echo -e "$NORMAL\n Número de Ensayo:$indEnsayos" | tee -a $informeConColorTotal
							echo -e "$NORMAL Algoritmo:$algoritmoPaginacionContinuidadReubicabilidadSeleccionado" | tee -a $informeConColorTotal
							echo -e " Número de Ensayo: $indEnsayos" >> $informeSinColorTotal
							echo -e " Algoritmo: $algoritmoPaginacionContinuidadReubicabilidadSeleccionado" >> $informeSinColorTotal
							echo -ne "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado $indEnsayos $seleccionMenuAlgoritmoGestionProcesos $seleccionMenuContinuidad $seleccionMenuReubicabilidad $seleccionAlgoritmoPaginacion" >> $nomFicheroDatosEjecucionAutomatica
							echo -ne " $seleccionTipoPrioridad $seleccionMenuApropiatividad $quantum $promedio_espera $promedio_retorno $suma_contadorAlgPagFallosProcesoAcumulado $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
							echo -ne " $seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
							echo -e " $seleccionAlgoritmoPaginacion_uso_rec_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
							
#FR_70 La gestión de memoria será paginada y podrá ser Continua y No continua, y Reubicable y no resubicable.
							seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=""
							seleccionAlgoritmoPaginacion_clases_frecuencia_valor=""
							seleccionAlgoritmoPaginacion_clases_valor=""
							seleccionAlgoritmoPaginacion_uso_rec_valor=""
							seleccionAlgoritmoPaginacion_clases_uso_rec_valor=""

#FR_70 La gestión de memoria será paginada y podrá ser Continua y No continua, y Reubicable y no resubicable.
					done
				done
#FR_70 La gestión de memoria será paginada y podrá ser Continua y No continua, y Reubicable y no resubicable.
			fi
			if [[ $seleccionMenuAlgoritmoGestionProcesos -eq 4 ]]; then
#FR_710     ejecucion() - Tiempo de ejecución de los procesos
#FR_7110Define el Tipo de Prioridad (Mayor (1)/Menor (2)).
				for (( seleccionTipoPrioridad=1 ; seleccionTipoPrioridad<=$numAlgoritmosTipoPrioridad ; seleccionTipoPrioridad++ )); do
#FR_7120Define el Tipo de Apropiatividad (No Apropiativo (1)/Apropiativo (2)).
					for (( seleccionMenuApropiatividad=1 ; seleccionMenuApropiatividad<=numAlgoritmosApropiatividad ; seleccionMenuApropiatividad++ )); do
#FR_7130Define el número de opciones del tipo de memoria (Continua/No Continua)
						for (( seleccionMenuContinuidad=1 ; seleccionMenuContinuidad<=$numAlgoritmosContinuidad ; seleccionMenuContinuidad++ )); do
#FR_7140Define el número de opciones del tipo de memoria (Reubicable/No Reubicable)
							for (( seleccionMenuReubicabilidad=1 ; seleccionMenuReubicabilidad<=$numAlgoritmosReubicabilidad ; seleccionMenuReubicabilidad++ )); do		
								for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
#FR_7150Se define el fichero sobre el que se guardan los volcados en COLOR.
									if [[ -f $informeSinColorTotal ]]; then
#FR_7160Se borran los ficheros anteriores
									fi
#FR_7170Se define el fichero sobre el que se guardan los volcados en BN.
									if [[ -f $informeConColorTotal ]]; then
#FR_7180Se borran los ficheros anteriores
									fi
#FR_7190Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#8-9-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
#FR_7210 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_frecuencia_valor=$datoAleatorioGeneral
									fi
#FR_7220Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#FR_723010-11-Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#FR_7240 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#FR_725010-11-Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#FR_7260 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_clases_frecuencia_valor=$datoAleatorioGeneral
#FR_727010-11-Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
#FR_7280 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
									fi
#FR_7290Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#14-15-Introduce el valor máximo de la frecuencia, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
#FR_7310 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_uso_rec_valor=$datoAleatorioGeneral
									fi
#FR_7320Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#16-17-Se pide el número de unidades de tiempo de ejecución de un proceso, a partir del cual, serán consideradas la frecuencia/tiempo de uso de una página y su clase: \n$NORMAL" | tee -a $informeConColorTotal
#FR_7340 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de la antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.: \n$NORMAL" | tee -a $informeConColorTotal
#FR_7360 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_clases_uso_rec_valor=$datoAleatorioGeneral
#16-17-Se pide el valor máximo de unidades de tiempo de antigüedad de ejecución de un proceso, a partir de la cual, una página será considerada como NO referenciada: \n$NORMAL" | tee -a $informeConColorTotal
#FR_7380 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
									fi
#FR_7390Ordena los datos para ser mostrados y considerados por orden de llegada.
#FR_740     temp_wait() - Se acumulan el tiempo de espera.
#FR_7410Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
									echo -e "$NORMAL\n Número de Ensayo: $indEnsayos" | tee -a $informeConColorTotal
									echo -e "$NORMAL Algoritmo: $algoritmoPaginacionContinuidadReubicabilidadSeleccionado" | tee -a $informeConColorTotal
									echo -e " Número de Ensayo: $indEnsayos" >> $informeSinColorTotal
									echo -e " Algoritmo: $algoritmoPaginacionContinuidadReubicabilidadSeleccionado" >> $informeSinColorTotal
									echo -ne "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado $indEnsayos $seleccionMenuAlgoritmoGestionProcesos $seleccionMenuContinuidad $seleccionMenuReubicabilidad $seleccionAlgoritmoPaginacion" >> $nomFicheroDatosEjecucionAutomatica
									echo -ne " $seleccionTipoPrioridad $seleccionMenuApropiatividad $quantum $promedio_espera $promedio_retorno $suma_contadorAlgPagFallosProcesoAcumulado $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
									echo -ne " $seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
									echo -e " $seleccionAlgoritmoPaginacion_uso_rec_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
								
#FR_7420Se inicializan a "" para empezar el siguiente ciclo.
									seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=""
									seleccionAlgoritmoPaginacion_clases_frecuencia_valor=""
									seleccionAlgoritmoPaginacion_clases_valor=""
									seleccionAlgoritmoPaginacion_uso_rec_valor=""
									seleccionAlgoritmoPaginacion_clases_uso_rec_valor=""
#FR_7430$seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_uso_rec_valor
							done
						done
					done
#FR_7440Define el Tipo de Apropiatividad (No Apropiativo (1)/Apropiativo (2)). Se vuelve a anular hasta que se vuelva a necesitar.
				done
#FR_7450Define el Tipo de Prioridad (Mayor (1)/Menor (2)). Se vuelve a anular hasta que se vuelva a necesitar.
			fi
		done
	done	
	
#FR_7460Fin de ejecutarEnsayosDatosIgualesAnterioresCompleto()

#
#
#FR_7470    Funciones
#
#
#
#FR_7480 Sinopsis: Para colorear lo impreso en pantalla.
#
function cecho {
	local default_msg="No message passed."                     
    message=${1:-$default_msg}   
    color=${2:-$FWHT}           
    echo -en "$color"
    echo "$message"
    tput sgr0                    
    return
#FR_7490Fin de cecho()

#
#FR_750     temp_exec() - Se acumulan el tiempo de ejecución.
#
function transformapag {
    let pagTransformadas[$2]=`expr $1/$mem_direcciones`
#FR_7510Fin de transformapag()

#
#FR_7520 Sinopsis: Calcula el número de direcciones por cada proceso y lo guarda en npagprocesos y el mayor número de páginas entre todos los procesos.
#
function vermaxpagsfichero {
#FR_7530Empieza en 14 por ser la primera línea del fichero con procesos.
	for (( npagp = 0; npagp <= $p; npagp++ )); do
		npagprocesos[$p]=`awk "NR==$i" $1 | wc -w `
		(( i++ ))	
	done
#FR_7540No se usa para nada
#FR_7550Calcula el mayor número de páginas de entre todos los procesos.
		if (( $verlas > $maxpags )); then
			maxpags=$verlas
		fi
	done
#FR_7560Fin de vermaxpagsfichero()

#
#FR_7570 Sinopsis: Se leen datos desde fichero
#
function leer_datos_desde_fichero {
#FR_7580Lee los datos del fichero
#FR_7590Primer dato -> Tamaño en memoria
#FR_760     bloqueados() - Procesos "En espera"
	numDireccionesTotales=$(($mem_total * $mem_direcciones))
#FR_7610Segundo dato -> Prioridad menor
#FR_7620Tercero dato -> Prioridad mayor
#FR_7630Cuarto dato -> Tipo de prioridad - Realmente no se usa porque se introduce por teclado al seleccionar el algoritmo de gestión de procesos mediante la variable de selección $seleccionTipoPrioridad.
#FR_7640Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#FR_7650Sexto dato -> Variable para la reubicabilidad - Realmente no se usa porque se introduce por teclado tras seleccionar la posibilidad de reubicar procesos.
#FR_7660Séptimo dato -> Quantum de Round Robin (RR)
	maxfilas=`wc -l < $1`
#FR_7670Número de marcos totales de la memoria
#FR_7680Número de marcos vacíos
#FR_7690Tamaño de memoria total en direcciones
#FR_770     pos_inicio() - Posición de inicio en memoria.
#FR_7710Índice local que recorre cada proceso definido en el problema
#FR_7720Índice que recorre cada dirección de cada proceso definido en el problema
#FR_7730Define el número de dígitos de pantalla usados para controlar los saltos de línea. Deja 1 de margen izquierdo y varios más para controlar el comienzo del espacio usado para los datos en la tabla resumen.
#FR_7740Se inicia con 16 por ser la primera línea del fichero que contiene procesos.
		llegada[$p]=`awk "NR==$fila" $1 |  cut -d ' ' -f 1`
		memoria[$p]=`awk "NR==$fila" $1 |  cut -d ' ' -f 2`
		prioProc[$p]=`awk "NR==$fila" $1 |  cut -d ' ' -f 3`
#(Usa el número de línea donde empiezan a definirse los procesos.) Calcula el número de direcciones por cada proceso y lo guarda en npagprocesos[] y el mayor número de páginas entre todos los procesos (maxpags).
		ejecucion[$p]=$(expr $[npagprocesos[$p]] - 3)
#FR_7760Para ser equivalente al nuevo programa
#FR_7770Contendrá el número de páginas ya usadas en la ejecución de cada proceso
#FR_7780El nombre de los procesos está predefinido: P01, P02, ...
		numOrdinalPagTeclado=0
#FR_7790maxpags es el mayor número de páginas entre todos los procesos. Se inicia con 4 por ser el primer campo que contiene direcciones en cada fila.
			directionsYModificado=`awk "NR==$fila" $1 | cut -d ' ' -f $i` 
			directions[$p,$numOrdinalPagTeclado]=`echo $directionsYModificado | cut -d '-' -f 1`
			directions_AlgPagFrecUsoRec_pagina_modificada[$p,$numOrdinalPagTeclado,0]=`echo $directionsYModificado | cut -d '-' -f 2`
			if [[ $seleccionAlgoritmoPaginacion -eq 0 && ${directions[$p,$numOrdinalPagTeclado]} -gt $(($numDireccionesTotales - 1)) ]]; then
				echo -e "\n***Error en la lectura de datos. La dirección de memoria utilizada está fuera del rango definido por el número de marcos de página.\n"
				exit 1
			fi
#let pagTransformadas[$2]=`expr $1/$mem_direcciones`
			paginasDefinidasTotal[$p,$numOrdinalPagTeclado]=${pagTransformadas[$numOrdinalPagTeclado]} 
#FR_7810Posición en la que se define cada dirección dentro de un proceso.
			((one++))
		done
#FR_7820Se elimina para poder hacer una segunda lectura sin datos anteriores.
		p=$((p+1))
	done 
#FR_7830	clear
#FR_7840Se almacena el cálculo aleatorio de si una página es o no modificada al ser ejecutada.


#
#FR_7850 Sinopsis: Extrae los límites de los rangos del fichero de rangos de última ejecución.
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
#*#FR_7870*Inicial - Datos a representar
#FR_7880Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	prio_menor_min=$PriomFinal
	prio_menor_max=$PrioMFinal
#Se invierten los rangos para calcular el mínimo, pero no para su representación, en la que se verán los datos originales *Inicial.
#*#FR_790     (Para estos dos arrays (que deberán ser dinámicos) tendrémos los valores de la memoria que están ocupados por un proceso, el valor de inicio en memoria y el valor al final)
#FR_7910Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
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
#FR_7920Si el mayor es menor que el menor, se invierten los rangos
        invertirRangos $memoria_min $memoria_max
        memoria_min=$min
        memoria_max=$max
    fi 
#FR_7930Si ambos son negativos se desplazan a positivos
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
#FR_7940Este valor podría ser 0
        llegada_max=$(($max - 1))
    fi 
    if [[ $tiempo_ejec_min -gt $tiempo_ejec_max ]]; then
        invertirRangos $tiempo_ejec_min $tiempo_ejec_max
        tiempo_ejec_min=$min
        tiempo_ejec_max=$max
    fi
    if [[ $tiempo_ejec_min -lt 0 ]]; then 
        desplazarRangos $tiempo_ejec_min $tiempo_ejec_max
#FR_7950Este valor podría ser 0
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
#FR_7960?????????????????
        invertirRangos $prio_proc_min $prio_proc_max
#FR_7970Los valroes de las prioridades podrían ser 0 o negativos.
        prio_proc_max=$max
    fi
#FR_7980?????????????????
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
#FR_7990Se comparará este valor con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.
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
#FR_800     mem_total - Tamaño total de la memoria que se va a usar.

#
#FR_8010 Sinopsis: Compara variables con enteros
#
function es_entero {
#FR_8020 En caso de error, sentencia falsa
#FR_8030 Retorna si la sentencia anterior fue verdadera
#FR_8040Fin de es_entero()

#
#FR_8050 Sinopsis: Permite ordenar los datos sacados desde fichero y de entrada por teclado.
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
#FR_8070Se permutan las páginas
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${paginasDefinidasTotal[$(($i + 1)),$counter2]}
				done
#FR_8080Se borran para que no pueda haber valores anteriores residuales.
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
#FR_8090Se permutan las direcciones
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${directions[$(($i + 1)),$counter2]}
				done
#FR_810     mem_libre - Tamaño aún libre de la memoria.
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
#FR_8110Se permutan los valores de esta variable auxiliar porque se definió en leer_datos_desde_fichero().
                tiempoEjecucion[$i]=$aux
                aux=${memoria[$(($i + 1))]}
                memoria[$(($i + 1))]=${memoria[$i]} 
                memoria[$i]=$aux
                aux=${prioProc[$(($i + 1))]}
#FR_8120En caso de usar el algoritmo basado en Prioridades...
                prioProc[$i]=$aux
#FR_8130No se permutan los nombres de los procesos, como en ordenarDatosEntradaFicheros(), porque se definirán más tarde.
            fi
        done
    done
#FR_8140Fin de ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve()

#
#FR_8150 Sinopsis: Se ordenan por t.llegada únicamente los datos que se meten en la introducción de procesos
#FR_8160 (posteriormente se ordenará todo ya que se añaden el resto de arrays con todos los datos de cada proceso).
#
#FR_8170En este caso se intercambian todos los datos al ordenar por tiempo de llegada.
#llegada[@]}; i++ )); do
#llegada[@]}; j++ )); do
            a=${llegada[$i]};
#FR_820     encola() tendremos qué procesos pueden entrar en memoria. Los valores son
            if [[ $a -gt $b ]];      then
                aux=${proceso[$i]};
#FR_8210Ordenar los nombres
                proceso[$j]=$aux;
                aux=${llegada[$i]};        
#FR_8220Ordenar por menor tiempo de llegada
                llegada[$j]=$aux
                aux=${ejecucion[$i]};
#FR_8230Ordenar tiempos de ejecución
                ejecucion[$j]=$aux;
                aux=${memoria[$i]};
#FR_8240Ordenar los tamaños
                memoria[$j]=$aux;
                aux=${numeroproceso[$i]};
#FR_8250Ordenar los números de proceso
                numeroproceso[$j]=$aux;
            fi
#FR_8260Si el orden de entrada coincide se arreglan dependiendo de cuál se ha metido primero
                c=${numeroproceso[$i]};
                d=${numeroproceso[$j]};
                if [[ $c -gt $d ]]; then
                    aux=${proceso[$i]};
#FR_8270Ordenar los nombres
                    proceso[$j]=$aux
                    aux=${llegada[$i]};       
#FR_8280Ordenar los tiempo de llegada
                    llegada[$j]=$aux
                    aux=${ejecucion[$i]};
#FR_8290Ordenar tiempos de ejecución
                    ejecucion[$j]=$aux;
                    aux=${memoria[$i]};
#FR_830       0 : El proceso no ha entrado en la cola (no ha "llegado" - Estado "Fuera del sistema")
                    memoria[$j]=$aux;
                    aux=${numeroproceso[$i]};
#FR_8310Ordenar los números de proceso
                    numeroproceso[$j]=$aux;
                fi
            fi
        done
    done
#FR_8320Fin de ordenSJF()

#
#
#FR_8330 Establecimiento de funciones para rangos
#
#
#FR_8340 Sinopsis: Presenta una tabla con los rangos y valores calculados
#
function datos_memoria_tabla {
#FR_8350    clear
    if [[ $seleccionMenuEleccionEntradaDatos -eq 4 ]]; then 
        echo -e "$amarillo Por favor establezca los rangos para datos"                  
    elif [[ $seleccionMenuEleccionEntradaDatos -eq 5 || $seleccionMenuEleccionEntradaDatos -eq 6 ]]; then 
        echo -e "$amarillo Resultados actuales:"                  
    fi
    echo -e "$azul┌────────────────────────────────────────────────────────────┐" | tee -a $informeConColorTotal
    printf  "$azul│$NC""${varhuecos:1:$((36))}""Min-Max rango     Valor""$azul │\n" | tee -a $informeConColorTotal
#FR_8360MARCOS}))}""$MIN_RANGE_MARCOS"" - " | tee -a $informeConColorTotal
#mem_total}))}""$mem_total""$azul │\n" | tee -a $informeConColorTotal
#FR_8380DIRECCIONES}))}""$MIN_RANGE_DIRECCIONES"" - " | tee -a $informeConColorTotal
#mem_direcciones}))}""$mem_direcciones""$azul │\n" | tee -a $informeConColorTotal
#FR_840       1 : El proceso está en la cola (Estado "En espera")
#prio_menorInicial}))}""$prio_menorInicial""$azul │\n" | tee -a $informeConColorTotal
#prio_menorInicial}))}""$prio_menorInicial""$azul │\n" | tee -a $informeConColorTotal
#FR_8430prio_mayor_minInicial}))}""$prio_mayor_minInicial"" - " | tee -a $informeConColorTotal
#prio_mayorInicial}))}""$prio_mayorInicial""$azul │\n" | tee -a $informeConColorTotal
#prio_mayorInicial}))}""$prio_mayorInicial""$azul │\n" | tee -a $informeConColorTotal
#FR_8460REUB}))}""$MIN_RANGE_REUB"" - " | tee -a $informeConColorTotal
#reub}))}""$reub""$azul │\n" | tee -a $informeConColorTotal
#FR_8480NPROC}))}""$MIN_RANGE_NPROC"" - " | tee -a $informeConColorTotal
#n_prog}))}""$n_prog""$azul │\n" | tee -a $informeConColorTotal
#FR_850     enmemoria()  - Procesos que se encuentran en memoria. Los valores son
#llegada}))}""$azul   │\n" | tee -a $informeConColorTotal
#FR_8520tiempo_ejec}))}""$MIN_RANGE_tiempo_ejec"" - " | tee -a $informeConColorTotal
#tiempo_ejec}))}""$azul   │\n" | tee -a $informeConColorTotal
#FR_8540tamano_marcos_proc}))}""$MIN_RANGE_tamano_marcos_proc"" - " | tee -a $informeConColorTotal
#tamano_marcos_proc}))}""$azul   │\n" | tee -a $informeConColorTotal
#FR_8560prio_proc}))}""$MIN_RANGE_prio_proc"" - " | tee -a $informeConColorTotal
#prio_proc}))}""$azul   │\n" | tee -a $informeConColorTotal
#FR_8580prio_menorInicial}))}""$prio_menorInicial"" - " | tee -a $informeConColorTotal
#prio_mayorInicial}))}""$azul   │\n" | tee -a $informeConColorTotal
#FR_860       0 : El proceso no está en memoria
#quantum}))}""$azul│\n" | tee -a $informeConColorTotal
#FR_8620tamano_direcciones_proc}))}""$MIN_RANGE_tamano_direcciones_proc"" - " | tee -a $informeConColorTotal
#tamano_direcciones_proc}))}""$azul│\n" | tee -a $informeConColorTotal
    echo -e "$azul└────────────────────────────────────────────────────────────┘"  | tee -a $informeConColorTotal
    echo -e "┌────────────────────────────────────────────────────────────┐" >> $informeSinColorTotal
    printf  "│$NC""${varhuecos:1:$((36))}""Min-Max rango     Valor"" │\n" >> $informeSinColorTotal
#FR_8640MARCOS}))}""$MIN_RANGE_MARCOS"" - " >> $informeSinColorTotal
#mem_total}))}""$mem_total"" │\n" >> $informeSinColorTotal
#FR_8660DIRECCIONES}))}""$MIN_RANGE_DIRECCIONES"" - " >> $informeSinColorTotal
#mem_direcciones}))}""$mem_direcciones"" │\n" >> $informeSinColorTotal
#FR_8680prio_menor_minInicial}))}""$prio_menor_minInicial"" - " >> $informeSinColorTotal
#prio_menorInicial}))}""$prio_menorInicial"" │\n" >> $informeSinColorTotal
#prio_menorInicial}))}""$prio_menorInicial"" │\n" >> $informeSinColorTotal
#FR_8710prio_mayor_minInicial}))}""$prio_mayor_minInicial"" - " >> $informeSinColorTotal
#prio_mayorInicial}))}""$prio_mayorInicial"" │\n" >> $informeSinColorTotal
#prio_mayorInicial}))}""$prio_mayorInicial"" │\n" >> $informeSinColorTotal
#FR_8740REUB}))}""$MIN_RANGE_REUB"" - " >> $informeSinColorTotal
#reub}))}""$reub"" │\n" >> $informeSinColorTotal
#FR_8760NPROC}))}""$MIN_RANGE_NPROC"" - " >> $informeSinColorTotal
#n_prog}))}""$n_prog"" │\n" >> $informeSinColorTotal
#FR_8780llegada}))}""$MIN_RANGE_llegada"" - " >> $informeSinColorTotal
#llegada}))}""   │\n" >> $informeSinColorTotal
#FR_880     escrito()  - Procesos que se encuentran en memoria y a los que se les ha encontrado espacio sufiente en la banda de memoria.
#tiempo_ejec}))}""   │\n" >> $informeSinColorTotal
#FR_8820tamano_marcos_proc}))}""$MIN_RANGE_tamano_marcos_proc"" - " >> $informeSinColorTotal
#tamano_marcos_proc}))}""   │\n" >> $informeSinColorTotal
#FR_8840prio_proc}))}""$MIN_RANGE_prio_proc"" - " >> $informeSinColorTotal
#prio_proc}))}""   │\n" >> $informeSinColorTotal
#FR_8860prio_menorInicial}))}""$prio_menorInicial"" - " >> $informeSinColorTotal
#prio_mayorInicial}))}""   │\n" >> $informeSinColorTotal
#FR_8880quantum}))}""$MIN_RANGE_quantum"" - " >> $informeSinColorTotal
#quantum}))}""│\n" >> $informeSinColorTotal
#FR_890     ejecucion  - Número de proceso que está ejecutándose (Estado "En ejecución")
#tamano_direcciones_proc}))}""│\n" >> $informeSinColorTotal
    echo -e "└────────────────────────────────────────────────────────────┘" >> $informeSinColorTotal
#FR_8920Fin de datos_memoria_tabla()

#
#FR_8930 Sinopsis: Presenta una tabla con los datos de los rangos introducidos, y los subrangos y los valores calculables.
#
function datos_amplio_memoria_tabla {
#FR_8940    clear
    if [[ $seleccionMenuEleccionEntradaDatos -eq 4 ]]; then 
        echo -e "$amarillo Por favor establezca los rangos para datos"                  
    elif [[ $seleccionMenuEleccionEntradaDatos -eq 5 || $seleccionMenuEleccionEntradaDatos -eq 6 ]]; then 
        echo -e "$amarillo Resultados actuales:"                  
    fi
    echo -e "$azul┌────────────────────────────────────────────────────────────────────────┐" | tee -a $informeConColorTotal
    printf  "$azul│$NC""${varhuecos:1:$((33))}""Min-Max_amplio   Min-Max_rango   Valor""$azul │\n" | tee -a $informeConColorTotal
#FR_8950memoria_maxInicial}))}""  " | tee -a $informeConColorTotal
#mem_total}))}""$mem_total""$azul │\n" | tee -a $informeConColorTotal
#FR_8970direcciones_maxInicial}))}""  " | tee -a $informeConColorTotal
#mem_direcciones}))}""$mem_direcciones""$azul │\n" | tee -a $informeConColorTotal
#FR_8990prio_menor_maxInicial}))}""  " | tee -a $informeConColorTotal
#prio_menorInicial}))}""$prio_menorInicial""$azul │\n" | tee -a $informeConColorTotal
#FR_90 VARIABLES DE EJECUCIÓN
#prio_mayorInicial}))}""$prio_mayorInicial""$azul │\n" | tee -a $informeConColorTotal
#FR_90 VARIABLES DE EJECUCIÓN
#reub}))}""$reub""$azul │\n" | tee -a $informeConColorTotal
#FR_90 VARIABLES DE EJECUCIÓN
#n_prog}))}""$n_prog""$azul │\n" | tee -a $informeConColorTotal
#FR_90 VARIABLES DE EJECUCIÓN
#llegada}))}""$azul │\n" | tee -a $informeConColorTotal
#FR_90 VARIABLES DE EJECUCIÓN
#tiempo_ejec}))}""$azul │\n" | tee -a $informeConColorTotal
#FR_9110tamano_marcos_proc_maxInicial}))}""  " | tee -a $informeConColorTotal
#tamano_marcos_proc}))}""$azul │\n" | tee -a $informeConColorTotal
#FR_9130prio_proc_max}))}""  " | tee -a $informeConColorTotal
#prio_proc}))}""$azul │\n" | tee -a $informeConColorTotal
#FR_9150prio_mayor}))}""  " | tee -a $informeConColorTotal
#prio_mayor}))}""$azul │\n" | tee -a $informeConColorTotal
#FR_9170quantum_maxInicial}))}""  " | tee -a $informeConColorTotal
#quantum}))}""$azul │\n" | tee -a $informeConColorTotal
#FR_9190tamano_direcciones_proc_maxInicial}))}""  " | tee -a $informeConColorTotal
#tamano_direcciones_proc}))}""$azul │\n" | tee -a $informeConColorTotal
    echo -e "$azul└────────────────────────────────────────────────────────────────────────┘" | tee -a $informeConColorTotal  
    
    echo -e "┌────────────────────────────────────────────────────────────────────────┐" >> $informeSinColorTotal
    printf "│$NC""${varhuecos:1:$((33))}""Min-Max_amplio Min-Max_rango Valor"" │\n" >> $informeSinColorTotal
#FR_9210memoria_maxInicial}))}""  " >> $informeSinColorTotal
#mem_total}))}""$mem_total"" │\n" >> $informeSinColorTotal
#FR_9230direcciones_maxInicial}))}""  " >> $informeSinColorTotal
#mem_direcciones}))}""$mem_direcciones"" │\n" >> $informeSinColorTotal
#FR_9250prio_menor_maxInicial}))}""  " >> $informeSinColorTotal
#prio_menorInicial}))}""$prio_menorInicial"" │\n" >> $informeSinColorTotal
#FR_9270prio_mayor_maxInicial}))}""  " >> $informeSinColorTotal
#prio_mayorInicial}))}""$prio_mayorInicial"" │\n" >> $informeSinColorTotal
#FR_9290reubicacion_maxInicial}))}""  " >> $informeSinColorTotal
#reub}))}""$reub"" │\n" >> $informeSinColorTotal
#FR_9310programas_maxInicial}))}""  " >> $informeSinColorTotal
#n_prog}))}""$n_prog"" │\n" >> $informeSinColorTotal
#FR_9330llegada_maxInicial}))}""  " >> $informeSinColorTotal
#llegada}))}"" │\n" >> $informeSinColorTotal
#FR_9350tiempo_ejec_maxInicial}))}""  " >> $informeSinColorTotal
#tiempo_ejec}))}"" │\n" >> $informeSinColorTotal
#FR_9370tamano_marcos_proc_maxInicial}))}""  " >> $informeSinColorTotal
#tamano_marcos_proc}))}"" │\n" >> $informeSinColorTotal
#FR_9390prio_mayor}))}""  " >> $informeSinColorTotal
#prio_mayor}))}"" │\n" >> $informeSinColorTotal
#FR_9410quantum_maxInicial}))}""  " >> $informeSinColorTotal
#quantum}))}"" │\n" >> $informeSinColorTotal
#FR_9430tamano_direcciones_proc_maxInicial}))}""  " >> $informeSinColorTotal
#tamano_direcciones_proc}))}"" │\n" >> $informeSinColorTotal
    echo -e "└────────────────────────────────────────────────────────────────────────┘" >> $informeSinColorTotal 
#FR_9450Fin de datos_amplio_memoria_tabla()

#FR_9460---------Funciones para el pedir por pantalla los mínimos y máximos de los rangos - Opción 4--------------
#
#FR_9470 Sinopsis: Se piden por pantalla el mínimo y máximo del rango de la memoria total
#
function datos_numero_marcos_memoria {
	datos_memoria_tabla 
    until [[ $MAX_RANGE_MARCOS -ge $MIN_RANGE_MARCOS && $MIN_RANGE_MARCOS -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de marcos de memoria$cian:$NC" 
#FR_9480Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de marcos de memoria$cian:$NC"
#FR_9490Rango maximo para la memoria
#FR_950          ${estad[$i]} = 3 - En ejecución
            invertirRangos $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS
            MIN_RANGE_MARCOS=$min
            MAX_RANGE_MARCOS=$max
        fi
#FR_9510Si ambos son negativos se desplazan a positivos
            desplazarRangos $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS
            MIN_RANGE_MARCOS=$min
            MAX_RANGE_MARCOS=$max
        fi  
    done
#FR_9520Fin de datos_numero_marcos_memoria()

#
#FR_9530 Sinopsis: Se piden por pantalla el mínimo y máximo del rango de la memoria total
#
function datos_numero_marcos_memoria_amplio {
	datos_amplio_memoria_tabla
    until [[ $memoria_maxInicial -ge $memoria_minInicial && $memoria_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de marcos de memoria$cian:$NC" 
#FR_9540Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de marcos de memoria$cian:$NC"
#FR_9550Rango maximo para la memoria
#FR_9560Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $memoria_minInicial $memoria_maxInicial
            memoria_minInicial=$min
            memoria_maxInicial=$max
        fi
#FR_9570Si ambos son negativos se desplazan a positivos
            desplazarRangos $memoria_minInicial $memoria_maxInicial
            memoria_minInicial=$min
            memoria_maxInicial=$max
        fi  
    done
#FR_9580Se definen nuevas variables para redefinir los límites de los subrangos sacados de los rangos amplios.
	memoria_max=$memoria_maxInicial
#FR_9590Fin de datos_numero_marcos_memoria_amplio()

#
#FR_960          ${estad[$i]} = 4 - En pausa
#
function datos_numero_direcciones_marco {
	datos_memoria_tabla 
    until [[ $MAX_RANGE_DIRECCIONES -ge $MIN_RANGE_DIRECCIONES && $MIN_RANGE_DIRECCIONES -gt 0 ]]; do                 
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de direcciones por marco$cian:$NC" 
#FR_9610Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de direcciones por marco$cian:$NC"
#FR_9620Rango maximo para la memoria
#FR_9630Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
            MIN_RANGE_DIRECCIONES=$min
            MAX_RANGE_DIRECCIONES=$max
        fi
#FR_9640Si ambos son negativos se desplazan a positivos
            desplazarRangos $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
            MIN_RANGE_DIRECCIONES=$min
            MAX_RANGE_DIRECCIONES=$max
        fi  
    done                    
#FR_9650Fin de datos_numero_direcciones_marco()

#
#FR_9660 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del número de procesos
#
function datos_numero_direcciones_marco_amplio {
	datos_amplio_memoria_tabla
    until [[ $direcciones_maxInicial -ge $direcciones_minInicial && $direcciones_minInicial -gt 0 ]]; do                 
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de direcciones por marco$cian:$NC" 
#FR_9670Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de direcciones por marco$cian:$NC"
#FR_9680Rango maximo para la memoria
#FR_9690Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $direcciones_minInicial $direcciones_maxInicial
            direcciones_minInicial=$min
            direcciones_maxInicial=$max
        fi
#FR_970          ${estad[$i]} = 5 - Terminado
            desplazarRangos $direcciones_minInicial $direcciones_maxInicial
            direcciones_minInicial=$min
            direcciones_maxInicial=$max
        fi  
    done                    
	direcciones_min=$direcciones_minInicial
	direcciones_max=$direcciones_maxInicial
#FR_9710Fin de datos_numero_direcciones_marco_amplio()
                        
#
#FR_9720 Sinopsis: Se piden por pantalla el mínimo y máximo para el mínimo del rango de la prioridad
#
function datos_prio_menor {
	datos_memoria_tabla 
	echo -e "$cian Por favor, establezca el mínimo del rango para la prioridad menor$cian:$NC" 
#FR_9730Rango minimo para la variable prioridad
	echo -e "$cian Por favor, establezca el máximo del rango para la prioridad menor$cian:$NC"
#FR_9740Rango maximo para la variable prioridad
	prio_menor_min=$prio_menor_minInicial
	prio_menor_max=$prio_menor_maxInicial
#FR_9750Fin de datos_prio_menor()
                        
#
#FR_9760 Sinopsis: Se piden por pantalla el mínimo y máximo para el mínimo del rango de la prioridad
#
function datos_prio_menor_amplio {
	datos_amplio_memoria_tabla
	echo -e "$cian Por favor, establezca el mínimo del rango para la prioridad menor$cian:$NC" 
#FR_9770Rango minimo para la variable prioridad
	echo -e "$cian Por favor, establezca el máximo del rango para la prioridad menor$cian:$NC"
#FR_9780Rango maximo para la variable prioridad
	prio_menor_min=$prio_menor_minInicial
	prio_menor_max=$prio_menor_maxInicial
#FR_9790Fin de datos_prio_menor_amplio()
                        
#
#FR_980 Declaración de los arrays
#
function datos_prio_mayor {
	datos_memoria_tabla 
	echo -e "$cian Por favor, establezca el mínimo del rango para la prioridad mayor$cian:$NC" 
#FR_9810Rango minimo para la variable prioridad
	echo -e "$cian Por favor, establezca el máximo del rango para la prioridad mayor$cian:$NC"
#FR_9820Rango maximo para la variable prioridad
	prio_mayor_min=$prio_mayor_minInicial
	prio_mayor_max=$prio_mayor_maxInicial
#FR_9830Fin de datos_prio_mayor()
                        
#
#FR_9840 Sinopsis: Se piden por pantalla el mínimo y máximo para el máximo del rango de la prioridad
#
function datos_prio_mayor_amplio {
	datos_amplio_memoria_tabla
	echo -e "$cian Por favor, establezca el mínimo del rango para la prioridad mayor$cian:$NC" 
#FR_9850Rango minimo para la variable prioridad
	echo -e "$cian Por favor, establezca el máximo del rango para la prioridad mayor$cian:$NC"
#FR_9860Rango maximo para la variable prioridad
	prio_mayor_min=$prio_mayor_minInicial
	prio_mayor_max=$prio_mayor_maxInicial
#FR_9870Fin de datos_prio_mayor_amplio()

#
#FR_9880 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del número de procesos
#
function datos_numero_programas {
	datos_memoria_tabla 
    until [[ $MAX_RANGE_NPROC -ge $MIN_RANGE_NPROC && $MIN_RANGE_NPROC -gt 0 ]]; do                 
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de procesos$cian:$NC" 
#FR_9890Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de procesos$cian:$NC"
#FR_990Contiene el número de unidades de ejecución y será usado para controlar que serán representadas en las bandas.
#FR_9910Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_NPROC $MAX_RANGE_NPROC
            MIN_RANGE_NPROC=$min
            MAX_RANGE_NPROC=$max
        fi
#FR_9920Si ambos son negativos se desplazan a positivos
            desplazarRangos $MIN_RANGE_NPROC $MAX_RANGE_NPROC
            MIN_RANGE_NPROC=$min
            MAX_RANGE_NPROC=$max
        fi  
    done                    
#FR_9930Fin de datos_numero_programas()

#
#FR_9940 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del número de procesos
#
function datos_numero_programas_amplio {
	datos_amplio_memoria_tabla
    until [[ $programas_maxInicial -ge $programas_minInicial && $programas_minInicial -gt 0 ]]; do                 
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de procesos$cian:$NC" 
#FR_9950Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de procesos$cian:$NC"
#FR_9960Rango maximo para la memoria
#FR_9970Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $programas_minInicial $programas_maxInicial
            programas_minInicial=$min
            programas_maxInicial=$max
        fi
#FR_9980Si ambos son negativos se desplazan a positivos
            desplazarRangos $programas_minInicial $programas_maxInicial
            programas_minInicial=$min
            programas_maxInicial=$max
        fi  
    done                    
		programas_min=$programas_minInicial
		programas_max=$programas_maxInicial
#FR_9990Fin de datos_numero_programas_amplio()

#
#FR_10
#
function datos_tamano_reubicacion { 
	datos_memoria_tabla 
#FR_10
        echo -e "$cian Por favor, establezca el mínimo del rango para la variable de reubicacion$cian:$NC" 
#FR_10
        echo -e "$cian Por favor, establezca el máximo del rango para la variable de reubicacion$cian:$NC" 
#FR_10
#FR_10
            invertirRangos $MIN_RANGE_REUB $MAX_RANGE_REUB
            MIN_RANGE_REUB=$min
            MAX_RANGE_REUB=$max
        fi
#FR_10
            desplazarRangos $MIN_RANGE_REUB $MAX_RANGE_REUB
            MIN_RANGE_REUB=$min
            MAX_RANGE_REUB=$max
        fi  
    done                        
#FR_10

#
#FR_10
#
function datos_tamano_reubicacion_amplio { 
	datos_amplio_memoria_tabla
#FR_10
        echo -e "$cian Por favor, establezca el mínimo del rango para la variable de reubicacion$cian:$NC" 
#FR_10
        echo -e "$cian Por favor, establezca el máximo del rango para la variable de reubicacion$cian:$NC" 
#FR_10
#FR_10
            invertirRangos $reubicacion_minInicial $reubicacion_maxInicial
            reubicacion_minInicial=$min
            reubicacion_maxInicial=$max
        fi
#FR_10
            desplazarRangos $reubicacion_minInicial $reubicacion_maxInicial
            reubicacion_minInicial=$min
            reubicacion_maxInicial=$max
        fi  
		reubicacion_min=$reubicacion_minInicial
		reubicacion_max=$reubicacion_maxInicial
    done                        
#FR_10
                
#
#FR_10
#
function datos_tiempo_llegada {
	datos_memoria_tabla 
    MIN_RANGE_llegada=-1 
    until [[ $MAX_RANGE_llegada -ge $MIN_RANGE_llegada && $(($MIN_RANGE_llegada + 1)) -gt 0 ]]; do  
        echo -e "$cian Por favor, establezca el mínimo del rango para el tiempo de llegada$cian:$NC" 
#FR_10
        echo -e "$cian Por favor, establezca el máximo del rango para el tiempo de llegada$cian:$NC" 
#FR_10
        if [[ $MIN_RANGE_llegada -gt $MAX_RANGE_llegada ]]; then
            invertirRangos $MIN_RANGE_llegada $MAX_RANGE_llegada
            MIN_RANGE_llegada=$min
            MAX_RANGE_llegada=$max
        fi
#FR_10
            desplazarRangos $MIN_RANGE_llegada $MAX_RANGE_llegada
#FR_10
            MAX_RANGE_llegada=$(($max - 1))
        fi  
    done
#FR_10
                
#
#FR_10
#
function datos_tiempo_llegada_amplio {
	datos_amplio_memoria_tabla
    llegada_minInicial=-1 
    until [[ $llegada_maxInicial -ge $llegada_minInicial && $(($llegada_minInicial + 1)) -gt 0 ]]; do  
        echo -e "$cian Por favor, establezca el mínimo del rango para el tiempo de llegada$cian:$NC" 
#FR_10
        echo -e "$cian Por favor, establezca el máximo del rango para el tiempo de llegada$cian:$NC" 
#FR_10
        if [[ $llegada_minInicial -gt $llegada_maxInicial ]]; then
            invertirRangos $llegada_minInicial $llegada_maxInicial
            llegada_minInicial=$min
            llegada_maxInicial=$max
        fi
#FR_10
            desplazarRangos $llegada_minInicial $llegada_maxInicial
#FR_10
            llegada_maxInicial=$(($max - 1))
        fi  
		llegada_min=$llegada_minInicial
		llegada_max=$llegada_maxInicial
    done
#FR_10
                        
#
#FR_10
#
function datos_tiempo_ejecucion {
	datos_memoria_tabla 
    until [[ $MAX_RANGE_tiempo_ejec -ge $MIN_RANGE_tiempo_ejec && $MIN_RANGE_tiempo_ejec -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el tiempo de ejecución$cian:$NC" 
#FR_10
        echo -e "$cian Por favor, establezca el máximo del rango para el tiempo de ejecución$cian:$NC"
#FR_10
#FR_10
            invertirRangos $MIN_RANGE_tiempo_ejec $MAX_RANGE_tiempo_ejec
            MIN_RANGE_tiempo_ejec=$min
            MAX_RANGE_tiempo_ejec=$max
        fi
#FR_10
            desplazarRangos $MIN_RANGE_tiempo_ejec $MAX_RANGE_tiempo_ejec
            MIN_RANGE_tiempo_ejec=$min
            MAX_RANGE_tiempo_ejec=$max
        fi  
    done
#FR_10
                        
#
#FR_10
#
function datos_tiempo_ejecucion_amplio {
	datos_amplio_memoria_tabla
    until [[ $tiempo_ejec_maxInicial -ge $tiempo_ejec_minInicial && $tiempo_ejec_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el tiempo de ejecución$cian:$NC" 
#FR_10
        echo -e "$cian Por favor, establezca el máximo del rango para el tiempo de ejecución$cian:$NC"
#FR_10
#FR_10
            invertirRangos $tiempo_ejec_minInicial $tiempo_ejec_maxInicial
            tiempo_ejec_minInicial=$min
            tiempo_ejec_maxInicial=$max
        fi
#FR_10
            desplazarRangos $tiempo_ejec_minInicial $tiempo_ejec_maxInicial
            tiempo_ejec_minInicial=$min
            tiempo_ejec_maxInicial=$max
        fi  
		tiempo_ejec_min=$tiempo_ejec_minInicial
		tiempo_ejec_max=$tiempo_ejec_maxInicial
    done
#FR_10
                        
#
#FR_10
#
function datos_prio_proc {
	datos_memoria_tabla 
#FR_10
                        
#
#FR_10
#
function datos_prio_proc_amplio {
	datos_amplio_memoria_tabla
#FR_10

#
#FR_10
#
function datos_tamano_marcos_procesos {                
	datos_memoria_tabla 
    until [[ $MAX_RANGE_tamano_marcos_proc -ge $MIN_RANGE_tamano_marcos_proc && $MIN_RANGE_tamano_marcos_proc -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de marcos asociados a cada proceso$cian:$NC" 
#FR_10
        echo -e "$cian Por favor, establezca el máximo del rango para el número de marcos asociados a cada proceso:$NC" 
#FR_10
#FR_10
            invertirRangos $MIN_RANGE_tamano_marcos_proc $MAX_RANGE_tamano_marcos_proc
            MIN_RANGE_tamano_marcos_proc=$min
            MAX_RANGE_tamano_marcos_proc=$max
        fi
#FR_10
            desplazarRangos $MIN_RANGE_tamano_marcos_proc $MAX_RANGE_tamano_marcos_proc
            MIN_RANGE_tamano_marcos_proc=$min
            MAX_RANGE_tamano_marcos_proc=$max
        fi  
    done
#FR_10

#
#FR_10
#
function datos_tamano_marcos_procesos_amplio {                
	datos_amplio_memoria_tabla
    until [[ $tamano_marcos_proc_maxInicial -ge $tamano_marcos_proc_minInicial && $tamano_marcos_proc_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de marcos asociados a cada proceso$cian:$NC" 
#FR_10
        echo -e "$cian Por favor, establezca el máximo del rango para el número de marcos asociados a cada proceso:$NC" 
#FR_10
#FR_10
            invertirRangos $tamano_marcos_proc_minInicial $tamano_marcos_proc_maxInicial
            tamano_marcos_proc_minInicial=$min
            tamano_marcos_proc_maxInicial=$max
        fi
#FR_10
            desplazarRangos $tamano_marcos_proc_minInicial $tamano_marcos_proc_maxInicial
            tamano_marcos_proc_minInicial=$min
            tamano_marcos_proc_maxInicial=$max
        fi  
		tamano_marcos_proc_min=$tamano_marcos_proc_minInicial
		tamano_marcos_proc_max=$tamano_marcos_proc_maxInicial
    done
#FR_10

#
#FR_10
#
function datos_tamano_direcciones_procesos {                
	datos_memoria_tabla 
    until [[ $MAX_RANGE_tamano_direcciones_proc -ge $MIN_RANGE_tamano_direcciones_proc && $MIN_RANGE_tamano_direcciones_proc -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el tamaño del proceso en direcciones$cian:$NC" 
#FR_10
        echo -e "$cian Por favor, establezca el máximo del rango para el tamaño del proceso en direcciones$cian:$NC" 
#FR_10
#FR_10
            invertirRangos $MIN_RANGE_tamano_direcciones_proc $MAX_RANGE_tamano_direcciones_proc
            MIN_RANGE_tamano_direcciones_proc=$min
            MAX_RANGE_tamano_direcciones_proc=$max
        fi
#FR_10
            desplazarRangos $MIN_RANGE_tamano_direcciones_proc $MAX_RANGE_tamano_direcciones_proc
            MIN_RANGE_tamano_direcciones_proc=$min
            MAX_RANGE_tamano_direcciones_proc=$max
        fi  
    done
#FR_10

#
#FR_10
#
function datos_tamano_direcciones_procesos_amplio {                
	datos_amplio_memoria_tabla
    until [[ $tamano_direcciones_proc_maxInicial -ge $tamano_direcciones_proc_minInicial && $tamano_direcciones_proc_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el tamaño del proceso en direcciones$cian:$NC" 
#FR_10
        echo -e "$cian Por favor, establezca el máximo del rango para el tamaño del proceso en direcciones$cian:$NC" 
#FR_10
#FR_10
            invertirRangos $tamano_direcciones_proc_minInicial $tamano_direcciones_proc_maxInicial
            tamano_direcciones_proc_minInicial=$min
            tamano_direcciones_proc_maxInicial=$max
        fi
#FR_10
            desplazarRangos $tamano_direcciones_proc_minInicial $tamano_direcciones_proc_maxInicial
            tamano_direcciones_proc_minInicial=$min
            tamano_direcciones_proc_maxInicial=$max
        fi  
		tamano_direcciones_proc_min=$tamano_direcciones_proc_minInicial
		tamano_direcciones_proc_max=$tamano_direcciones_proc_maxInicial
    done
#FR_10

#
#FR_10
#
function datos_quantum {                
	datos_memoria_tabla 
    until [[ $MAX_RANGE_quantum -ge $MIN_RANGE_quantum && $MIN_RANGE_quantum -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el quantum$cian:$NC" 
#FR_10
        echo -e "$cian Por favor, establezca el máximo del rango para el quantum$cian:$NC" 
#FR_10
#FR_10
            invertirRangos $MIN_RANGE_quantum $MAX_RANGE_quantum
            MIN_RANGE_quantum=$min
            MAX_RANGE_quantum=$max
        fi
#FR_10
            desplazarRangos $MIN_RANGE_quantum $MAX_RANGE_quantum
            MIN_RANGE_quantum=$min
            MAX_RANGE_quantum=$max 
        fi  
    done
#FR_10

#
#FR_10
#
function datos_quantum_amplio {                
	datos_amplio_memoria_tabla
    until [[ $quantum_maxInicial -ge $quantum_minInicial && $quantum_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el quantum:$NC" 
#FR_10
        echo -e "$cian Por favor, establezca el máximo del rango para el quantum$cian:$NC" 
#FR_10
#FR_10
            invertirRangos $quantum_minInicial $quantum_maxInicial
            quantum_minInicial=$min
            quantum_maxInicial=$max
        fi
#FR_10
            desplazarRangos $quantum_minInicial $quantum_maxInicial
            quantum_minInicial=$min
            quantum_maxInicial=$max
        fi  
		quantum_min=$quantum_minInicial
		quantum_max=$quantum_maxInicial
    done
#FR_10

#FR_10
#
#FR_10
#
function calcDatoAleatorioGeneral {
#FR_10
#FR_10
#FR_10
#FR_10
#FR_10

#
#FR_10
#
function invertirRangos {
    aux=$1
    min=$2
    max=$aux
#FR_10

#
#FR_10
#
function desplazarRangos {
#FR_10
#FR_10
#FR_10

#
#FR_10
#
function colorDefaultInicio {
    for (( j=0; j<5; j++)); do
        coloresPartesTiempo=("${coloresPartesTiempo[@]}" "${coloress[97]}")
    done
#FR_10

#
#FR_10
#
function colorAnterior {
    for (( j=0; j<$digitosUnidad; j++)); do
        coloresPartesTiempo=("${coloresPartesTiempo[@]}" "${coloress[$proanterior]}")
    done
#FR_10

#
#FR_10
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
#FR_10
            j=$((j-16))
#FR_10
    done
#FR_10

#
#FR_1100Posición de inicio de cada hueco de memoria asociado a cada proceso.
#
function colorunidMemOcupadas { 
    for (( j=0; j<$digitosUnidad; j++)); do
        coloresPartesMemoria=("${coloresPartesMemoria[@]}" "${coloress[${unidMemOcupadas[$ra]}]}")
    done
#FR_11010Fin de colorunidMemOcupadas()

#
#FR_11020 Sinopsis: Define el color de cada dígito de cada unidad de la memoria y tiempo a representar - Color por defecto
#
function colorDefaultBMBT { 
    for (( j=0; j<$digitosUnidad; j++)); do
        coloresPartesMemoria=("${coloresPartesMemoria[@]}" "${coloress[97]}")
    done
#FR_11030Fin de colorDefaultBMBT()

#
#FR_11040 Sinopsis: Dada una unidad de 3 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#FR_110503 - ancho de columnas estrechas en tabla resumen de procesos en los volcados
#FR_11060No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado.
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC"
#FR_11070Fin de imprimirEspaciosEstrechos()

#FR_110803 - ancho de columnas estrechas en tabla resumen de procesos en los volcados
#FR_11090No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado.
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal"
#FR_1110Posición final de cada hueco de memoria asociado a cada proceso.

#
#FR_11110 Sinopsis: Dada una unidad de 4 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#FR_111204 - ancho de columnas anchas en tabla resumen de procesos en los volcados
#FR_11130No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado.
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC" 
#FR_11140Fin de imprimirEspaciosAnchos()

#FR_111504 - ancho de columnas anchas en tabla resumen de procesos en los volcados
#FR_11160No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado.
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal" 
#FR_11170Fin de imprimirEspaciosAnchosBN()

#
#FR_11180 Sinopsis: Dada una unidad de 5 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#FR_111905 - ancho de columnas más anchas en tabla resumen de procesos en los volcados
#FR_1120Se añade al comentario principal ?????????????????????
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC"
#FR_11210Fin de imprimirEspaciosMasAnchos()

#FR_112205 - ancho de columnas más anchas en tabla resumen de procesos en los volcados
#FR_11230No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado.
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal"
#FR_11240Fin de imprimirEspaciosMasAnchosBN()

#
#FR_11250 Sinopsis: Dada una unidad de 17 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#FR_1126017 - ancho de columnas muy anchas en tabla resumen de procesos en los volcados
#FR_11270No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado.
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC"
#FR_11280Fin de imprimirEspaciosMuyAnchos()

#FR_1129017 - ancho de columnas muy anchas en tabla resumen de procesos en los volcados
#FR_1130Se añade al comentario principal ?????????????????????
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal"
#FR_11310Fin de imprimirEspaciosMuyAnchosBN()

#
#FR_11320 Sinopsis: Dada una unidad de 9 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#FR_113309 - ancho de columnas anchas en tabla de rangos
#FR_11340No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado.
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC"
#FR_11350Fin de imprimirEspaciosRangosLargos()

#FR_113609 - ancho de columnas anchas en tabla de rangos
#FR_11370No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado.
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal"
#FR_11380Fin de imprimirEspaciosRangosLargos()

#
#FR_11390 Sinopsis: Se eliminan los archivos de última ejecución que había anteriormente creados y
#FR_1140Estado inicial de los procesos cuando aún no han llegado al sistema.
#
function nuevaEjecucion {
#FR_11410    clear
    if [[ -f $ficheroDatosAnteriorEjecucion ]]; then
        rm $ficheroDatosAnteriorEjecucion   
    fi
    if [[ -f $ficherosRangosAnteriorEjecucion && ($seleccionMenuEleccionEntradaDatos -eq 4 || $seleccionMenuEleccionEntradaDatos -eq 6 || $seleccionMenuEleccionEntradaDatos -eq 7 || $seleccionMenuEleccionEntradaDatos -eq 8 || $seleccionMenuEleccionEntradaDatos -eq 9) ]]; then
        rm $ficherosRangosAnteriorEjecucion     
    fi
    if [[ -f $ficheroRangosAleTotalAnteriorEjecucion && ($seleccionMenuEleccionEntradaDatos -eq 7 || $seleccionMenuEleccionEntradaDatos -eq 9) ]]; then
        rm $ficheroRangosAleTotalAnteriorEjecucion     
    fi
#FR_11420Fin de nuevaEjecucion()

#
#FR_11430 Sinopsis: Se calcula el tamaño máximo de la unidad para contener todos los datos que se generen sin modificar el ancho de la columna necesaria
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
#FR_11440Fin de calcularUnidad()

#
#FR_11450 Sinopsis: Permite introducir las particiones y datos desde otro fichero (predefinido).
#
function entradaMemoriaDatosFichero {
#FR_11460    clear
    echo -e $ROJO"\nFicheros de datos a elegir en './FDatos/': "$NORMAL | tee -a $informeConColorTotal
    echo -e "\nFicheros de datos a elegir en './FDatos/': " >> $informeSinColorTotal
    files=($(ls -l ./FDatos/ | awk '{print $9}'))
#FR_11470Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
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
#FR_11490Fin de entradaMemoriaDatosFichero()

#
#FR_1150Estado de los procesos cuando han llegado al sistema, pero aún no han entrado a la memoria.
#
function entradaMemoriaRangosFichero {
#FR_11510    clear
    echo -e $ROJO"\nFicheros de datos a elegir en './FDatos/': "$NORMAL | tee -a $informeConColorTotal
    echo -e "\nFicheros de datos a elegir en './FDatos/': " >> $informeSinColorTotal
    files=($(ls -l ./FDatos/ | awk '{print $9}'))
#FR_11520Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
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
#FR_11540Fin de datos_numero_marcos_memoria_amplio()

#
#FR_11550 Sinopsis: Se inicilizan diferentes tablas y variables
#
function inicializaVectoresVariables { 
#FR_11560 -----------------------------------------------------------------------------
#FR_11570 Se inicilizan las tablas indicadoras de la MEMORIA NO CONTINUA
#FR_11580Se crea el array para determinar qué unidades de memoria están ocupadas y se inicializan con _
    for (( ca=0; ca<(mem_total); ca++)); do
        unidMemOcupadas[$ca]="_"
#FR_11590Se crea un array auxiliar para realizar la reubicación
    done
#FR_1160Estado de los procesos cuando han entrado en memoria, pero aún no han empezado a ejecutarse.
#FR_11610En caso de ser memoria no continua, si hay un hueco demasiado pequeño, y se va a usar como parte de la memoria a usar.
    reubicarReubicabilidad=0 
#FR_11620En caso de ser memoria continua, si no hay un hueco suficientemente grande en el que quepa pero sí en la suma de todos ellos.
    reubicarContinuidad=0 
#FR_11630 -----------------------------------------------------------------------------
#FR_11640 Se inicilizan las tablas indicadoras de la situación del proceso
#FR_11650Copia algunas listas para luego ponerlas en orden
        entradaAuxiliar[$i]=${llegada[$i]} 
        temp_rej[$i]="-"
#FR_11660Para ser equivalente al nuevo programa
        memoriaAuxiliar[$i]=${memoria[$i]}
        encola[$i]=0
        enmemoria[$i]=0
        enejecucion[$i]=0
        bloqueados[$i]=0
        enpausa[$i]=0 
#FR_11670Determina qué procesos han terminado (1).
#FR_11680Determina qué procesos han terminado cuyo resumen de fallos de página ha sido imprimido (1).
        nollegado[$i]=0
        estad[$i]=0 
        estado[$i]=0
        temp_wait[$i]="-"
        temp_resp[$i]="-"
        temp_ret[$i]="-"
        pos_inicio[$i]="-"
        pos_final[$i]="-"
#FR_11690Guarda si un proceso está escrito o no EN EL ARRAY.
#FR_1170Estado de los procesos cuando un proceso ya ha empezado a ejecutarse, pero aunque no han terminado de ejecutarse, otro proceso ha comenzado a ejecutarse.
#FR_11710Controla qué procesos están presentes en la banda de tiempo. Se van poniendo a 1 a medida que se van metiendo en las variables de las líneas de la banda de tiempos.
#FR_11720Número de Marcos ya usadas de cada Proceso.
#FR_11730Número de Páginas ya usadas de cada Proceso.
#FR_11740Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
#FR_11750Número de Páginas ya dibujadas de cada Proceso para el resumen de Banda.
#FR_11760Fallos de página totales de cada proceso.
#FR_11770Mayor "frecuencia/uso de página".
		max_AlgPagFrecRec_Position[$i]=0
#FR_11780Menor "frecuencia/uso de página".
		min_AlgPagFrecRec_Position[$i]=0
		indiceResuPaginaProceso[$i]="_"
		indiceResuPaginaAcumulado[$i]="_"
#FR_11790Número de Fallos de Página de cada Proceso.
#FR_1180Estado de los procesos cuando un proceso ya ha empezado a ejecutarse
#FR_11810Controlan el ordinal del tiempo de ejecución que hace que se cambió un valor de las clases y la frecuencia de uso de cada página en cada ordinal de tiempo de ejecución.
			primerTiempoEntradaPagina[$i,$indMarco]=0 
			restaFrecUsoRec[$i,$indMarco,0]=0
			directions_AlgPagFrecUsoRec_marco_pagina_clase[$i,$indMarco,0]=0
			directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$i,$indMarco]=0
		done
#FR_11820Contiene el orden de ejecución de Round-Robin (RR). Será "-" mientras no esté en cola, o cuando haya terminado, y si aún no ha terminado contendrá el número ordinal del siguiente quantum. El proceso a ejecutar será, por tanto, el que tenga el número ordinal más bajo. Y el número de quantums realizados (cambios de contexto, será el número ordinal más alto.
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
#FR_11830Establece el color de cada proceso
    blanco="\e[37m"
#FR_11840Para ser equivalente al nuevo programa
#FR_11850Para ser equivalente al nuevo programa
#FR_11860 Se calcula el valor máximo del número de unidades de tiempo. Como mucho, los tiempos de llegada más los tiempos de ejecución. Ese será el número de elementos máximo del array procPorUnidadTiempoBT
#proceso[@]}; j++)); do
        maxProcPorUnidadTiempoBT=$(expr $maxProcPorUnidadTiempoBT + ${llegada[$j]} + ${ejecucion[$j]})  
    done  
#FR_11880 Se pone un valor que nunca se probará (tope dinámico). Osea, el mismo que maxProcPorUnidadTiempoBT.
#FR_11890Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
	ejecutandoinst=-1
#FR_1190Se añade al comentario principal ?????????????????????
#FR_11910Timpo ejecutado de un proceso que se comparará con el quantum para ser sacado de CPU.
#FR_11920Índice con el primer ordinal libre a repartir en Round-Robin (RR). Irá creciendo con cada puesto de quantum repartido y marca el futuro orden de ejecución.
#FR_11930Índice con el actual ordinal en ejecución para Round-Robin (RR). Irá creciendo con cada quantum ejecutado y marca el actual número ordinal de uantum en ejecución.
#FR_11940    clear
#FR_11950Fin de inicializaVectoresVariables()

#
#FR_11960 Sinopsis: Se inicializan las variables con diferentes acumulados en cada instante de reloj. Algunos acumulados sólo serían necesarios cuando se produzcan eventos, pero se podrían generalizar haciendo acumulados en cada instante.
#
#FR_11970Se ejecuta en cada instante mientra que otras funciones sólo si se producen ciertas condiciones. Sería mejor inicializar aquí los acumulados.
#FR_11980Se arrastran los datos del siguiente fallo de página para cada proceso en cada unidad de tiempo.
		if [[ $reloj -ne 0 ]]; then
#FR_11990Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
		fi
	done
#FR_1200Estado de los procesos cuando ya han terminado de ejecutarse

#
#FR_12010 Sinopsis: Gestión de procesos - FCFS
#
function gestionProcesosFCFS {
    if [[ $cpu_ocupada == "NO" ]]; then
        if [[ $realizadoAntes -eq 0 ]]; then  
            indice_aux=-1
#FR_12020Establecemos qué proceso es el siguiente que llega a memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
#FR_12030El siguiente proceso que llega a memoria
                    temp_aux=${temp_rej[$i]}
                    break
                fi
            done
#FR_12040Hemos encontrado el siguiente proceso en memoria
#FR_12050Marco el proceso para ejecutarse
#FR_12060Quitamos el estado pausado si el proceso lo estaba anteriormente
#FR_12070Marcamos el proceso como en memoria
#FR_12080La CPU está ocupada por un proceso
#FR_12090Se activa el aviso de entrada en CPU del volcado
            fi
        fi
    fi
#FR_1210Se añade al comentario principal ?????????????????????
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
        done
#FR_12110Si no hay proceso en ejecución se pone -1, para que pueda ser comparado.
#FR_12120Resumen - Proceso en ejecución en cada instante de tiempo.
		else
			ResuTiempoProceso[$reloj]=-1
		fi 
	fi
#FR_12130Si se trabaja NFU/NRU con clases.
#FR_12140Se traspasan todos los datos al siguiente instante para ser modificados, si se produce nmodificaciones al analizar los fallos y usos de las páginas.
#FR_12150
#FR_12160
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#FR_12170Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.
#FR_12180Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#FR_12190Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#FR_1220Número asociado a cada estado de los procesos
#FR_12210Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#FR_12220Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#FR_12230Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#FR_12240Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#FR_12250Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi 

#FR_12260ESTADO DE CADA PROCESO
#FR_12270Se modifican los valores de los arrays, restando de lo que quede
#FR_12280ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizaran tras imprimir.)
    for (( i=0; i<$nprocesos; i++ )); do
        if [[ ${nollegado[$i]} -eq 1 ]] ; then
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
        if [[ ${encola[$i]} -eq 1 && ${bloqueados[$i]} -eq 1 && ${temp_wait[$i]} == "-" && ${temp_ret[$i]} == "-" ]] ; then
#FR_12290Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#FR_1230Se añade al comentario principal
        fi
        if [[ ${encola[$i]} -eq 1 && ${bloqueados[$i]} -eq 1 ]] ; then
            estado[$i]="En espera"
            estad[$i]=1
        fi
        if [[ ${enmemoria[$i]} -eq 1 && ${temp_wait[$i]} == "-" && ${temp_ret[$i]} == "-" ]] ; then
#FR_12310Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#FR_12320Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
        if [[ ${enmemoria[$i]} -eq 1 && ${enejecucion[$i]} -eq 1 ]] ; then
            estado[$i]="En ejecucion"
            estad[$i]=3
#FR_12330Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
        elif [[ ${enmemoria[$i]} -eq 1 && ${enpausa[$i]} -eq 1 ]] ; then
            estado[$i]="En pausa"
        elif [[ ${enmemoria[$i]} -eq 1 ]] ; then
            estado[$i]="En memoria"
            estad[$i]=2
        fi
#FR_12340Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
            estado[$i]="Finalizado"
            estad[$i]=5
#FR_12350Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
        elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
            estado[$i]="Finalizado"
            estad[$i]=5
        fi
    done

#FR_12360Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#FR_12370SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#FR_12380En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
#FR_12390Siempre se imprimie el volcado en T=0. y también cuando se escoja la impresión unidad de tiempo a unidad de tiempo (seleccionMenuModoTiempoEjecucionAlgormitmo = optejecucion = 4).
        evento=1
    fi
#FR_1240Secuencia de los procesos que ocupan cada marco de la memoria completa
        evento=0
    fi
#FR_12410Fin de gestionProcesosFCFS()

#
#FR_12420 Sinopsis: Gestión de procesos - SJF
#
function gestionProcesosSJF {
#FR_12430ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizarán tras lanzar el volcado.)
#FR_12440Se modifican los valores de los arrays.
#FR_12450No ha llegado por tiempo de llegada.
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
#FR_12460Se encola pero no ha llegado por tiempo de llegada.
#FR_12470Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#FR_12480Aunque no entre en memoria ya tiene datos a considerar.
            estado[$i]="En espera"
            estad[$i]=1
        fi
#FR_12490Se mete en memoria.
#FR_1250Matriz auxiliar de la memoria no continua (para reubicar)
            temp_ret[$i]=0
#FR_12510Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
    done
 
#FR_12520Se establece el proceso con menor tiempo de ejecución de los que están en memoria.
        if [[ $realizadoAntes -eq 0 ]]; then  
#FR_12530Contendrá un tiempo de ejecución de referencia (el primero encontrado) para su comparación con el de otros procesos.
            temp_aux=0
#FR_12540Se busca el primer tiempo de ejecución de todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
                    if [[ ${temp_rej[$i]} -gt $temp_aux ]]; then
#FR_12550Proceso de referencia
#FR_12560Tiempo de ejecución de referencia
                    fi
                fi
#FR_12570Una vez encontrado el primero, se van a comparar todos los procesos hasta encontrar el de tiempo restante de ejecución más pequeño.
            min_indice_aux=-1  
#FR_12580Contendrá el menor tiempo de ejecución para su comparación con el de otros procesos.
#FR_12590Se establece qué proceso tiene menor tiempo de ejecución de todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${terminados[$i]} -ne 1 ]]; then
                    if [[ ${temp_rej[$i]} -lt $min_temp_aux ]]; then
#FR_1260bandera para no escibir dos veces un proceso en memoria
#FR_12610Tiempo de ejecución menor hasta ahora
                    fi
                fi
            done
#FR_12620Una vez encontrado el proceso más corto, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#FR_12630Marco el proceso para ejecutarse.
#FR_12640Quitamos el estado pausado si el proceso lo estaba anteriormente.
#FR_12650La CPU está ocupada por un proceso.
#FR_12660Se activa el aviso de entrada en CPU del volcado
            fi
        fi
    fi
#FR_12670Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
            if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enejecucion[$i]} -eq 1 ]] ; then 
                estado[$i]="En ejecucion"
                estad[$i]=3
#FR_12680Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enpausa[$i]} -eq 1 ]] ; then
                estado[$i]="En pausa"
                estad[$i]=4
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  ]] ; then
                estado[$i]="En memoria"
                estad[$i]=2
            fi
#FR_12690Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
                estado[$i]="Finalizado"
                estad[$i]=5
#FR_1270para guardar en cuantos bloques se fragmenta un proceso
            elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
                estado[$i]="Finalizado"
                estad[$i]=5
            fi
        done
    fi
#FR_12710Si no hay proceso en ejecución se pone -1, para que pueda ser comparado.
#FR_12720Resumen - Proceso en ejecución en cada instante de tiempo.
	else
		ResuTiempoProceso[$reloj]=-1
	fi 

#FR_12730Si se trabaja NFU/NRU con clases.
#FR_12740Se traspasan todos los datos al siguiente instante para ser modificados, si se produce nmodificaciones al analizar los fallos y usos de las páginas.
#FR_12750
#FR_12760
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#FR_12770Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.

#FR_12780Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#FR_12790Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#FR_1280posición inicial de cada bloque en la memoria NO CONTINUA
#FR_12810Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#FR_12820Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#FR_12830Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#FR_12840Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#FR_12850Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi

#FR_12860Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#FR_12870SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#FR_12880En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
    if [[ $reloj -eq 0 || $optejecucion = "4" ]]; then 
        evento=1
    fi
#FR_12890Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#FR_1290posición final de cada bloque en la memoria NO CONTINUA

#
#FR_12910 Sinopsis: Gestión de procesos - SRPT
#
function gestionProcesosSRPT {
#FR_12920ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizarán tras lanzar el volcado.)
#FR_12930Se modifican los valores de los arrays.
#FR_12940No ha llegado por tiempo de llegada.
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
#FR_12950Se encola pero no ha llegado por tiempo de llegada.
#FR_12960Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#FR_12970Aunque no entre en memoria ya tiene datos a considerar.
            estado[$i]="En espera"
            estad[$i]=1
        fi
#FR_12980Se mete en memoria.
#FR_12990Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#FR_1300posición inicial en la memoria NO CONTINUA para impresiones (cuadrado en tabla)
        fi
    done
 
#FR_13010Se establece el proceso con mayor y menor tiempo de ejecución de los que están en memoria.
        if [[ $realizadoAntes -eq 0 ]]; then  
#FR_13020Contendrá un tiempo de ejecución de referencia (el mayor tiempo de ejecución encontrado) para su comparación con el de otros procesos. Se busca el mayor para poder encontrar el primero de los de tiempo de ejecución más bajo.
            temp_aux=0
#FR_13030Se busca el mayor tiempo de ejecución de todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
                    if [[ ${temp_rej[$i]} -gt $temp_aux ]]; then
#FR_13040Proceso con el mayor tiempo de ejecución.
#FR_13050Tiempo de ejecución de referencia.
                    fi
                fi
#FR_13060Una vez encontrado el mayor, se van a comparar todos los procesos hasta encontrar el de menor tiempo restante de ejecución.
            min_indice_aux=-1  
#FR_13070Contendrá el menor tiempo de ejecución para su comparación con el de otros procesos.
#FR_13080Se establece qué proceso tiene menor tiempo de ejecución de todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${terminados[$i]} -ne 1 ]]; then
                    if [[ ${temp_rej[$i]} -lt $min_temp_aux ]]; then
#FR_13090Proceso de tiempo de ejecución más bajo hasta ahora.
#FR_1310posición final en la memoria NO CONTINUA para impresiones (cuadrado en tabla)
                    fi
                fi
            done
#FR_13110Una vez encontrado el proceso más corto, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#FR_13120Marcamos el proceso como no ejecutándose si lo estaba anteriormente.
#FR_13130Ponemos el estado pausado si el proceso anteriormente en ejecución.
#FR_13140Marco el proceso para ejecutarse.
#FR_13150Quitamos el estado pausado si el proceso lo estaba anteriormente.
#FR_13160La CPU está ocupada por un proceso.
#FR_13170Si había otro proceso en ejecución con anterioridad se avisa que se pone en pausa.
					avisoPausa[$anteriorProcesoEjecucion]=1 
                fi
#FR_13180Se activa el aviso de entrada en CPU del volcado
                anteriorProcesoEjecucion=$min_indice_aux
            fi
        fi
    fi
#FR_13190Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
            if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enejecucion[$i]} -eq 1 ]] ; then 
                estado[$i]="En ejecucion"
                estad[$i]=3
#FR_1320borrar posiciones innecesarias tras la impresión
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enpausa[$i]} -eq 1 ]] ; then
                estado[$i]="En pausa"
                estad[$i]=4
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  ]] ; then
                estado[$i]="En memoria"
                estad[$i]=2
            fi
#FR_13210Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
                estado[$i]="Finalizado"
                estad[$i]=5
#FR_13220Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
            elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
                estado[$i]="Finalizado"
                estad[$i]=5
            fi
        done
    fi
#FR_13230Si no hay proceso en ejecución se pone -1, para que pueda ser comparado.
#FR_13240Resumen - Proceso en ejecución en cada instante de tiempo.
	else
		ResuTiempoProceso[$reloj]=-1
	fi 

#FR_13250Si se trabaja NFU/NRU con clases.
#FR_13260Se traspasan todos los datos al siguiente instante para ser modificados, si se producen modificaciones al analizar los fallos y usos de las páginas.
#FR_13270
#FR_13280
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#FR_13290Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.

#FR_1330borrar posiciones innecesarias tras la impresión
#FR_13310Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#FR_13320Se lanza la gestión sin algoritmo de paginación, dado que en memoria no virtual los procesos entran en memoria de forma completa y no por páginas como en memoria virtual.
#FR_13330Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#FR_13340Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#FR_13350Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#FR_13360Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#FR_13370Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi
    
#FR_13380Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#FR_13390SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#FR_1340Para saber si un proceso en la barra de tiempo está nombrado, si se ha introducido en las variables de las diferentes líneas.
        parar_proceso=SI
        evento=1
    fi
    if [[ $reloj -eq 0 || $optejecucion = "4" ]]; then 
        evento=1
    fi
#FR_13410Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#FR_13420Fin de gestionProcesosSRPT()

#
#FR_13430 Sinopsis: Gestión de procesos - Prioridades (Mayor/Menor)
#
function gestionProcesosPrioridades {
#FR_13440ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizarán tras lanzar el volcado.)
#FR_13450Se modifican los valores de los arrays.
#FR_13460No ha llegado por tiempo de llegada.
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
#FR_13470Se encola pero no ha llegado por tiempo de llegada.
#FR_13480Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#FR_13490Aunque no entre en memoria ya tiene datos a considerar.
#FR_1350bandera para saber si hay un proceso anterior que finalizar de dibujar
            estado[$i]="En espera"
            estad[$i]=1
        fi
#FR_13510Se mete en memoria.
#FR_13520Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#FR_13530Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
#FR_13540Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
    done
	if [[ $realizadoAntes -eq 0 ]]; then  
        cerrojo_aux=0
#FR_13550Variable de cierre
#FR_13560Se busca la mayor prioridad de todas las que se encuentran en memoria.
			if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
#FR_13570Se inicializan las variables para determinar el mayor valor de la priridad de los procesos en memoria.
#FR_13580Se inicializa la variable con el primer proceso para la menor prioridad.
#FR_13590Prioridad de referencia.
					cerrojo_aux=1
				fi
				if [[ ${temp_prio[$i]} -gt $prio_aux && $cerrojo_aux -eq 1 ]]; then
#FR_1360Contiene el proceso que se esté tratando en la asignación de dígitos en la representación de la banda de tiempo
#FR_13610Prioridad de referencia.
				fi
			fi
#FR_13620Una vez encontrada la mayor prioridad, se van a comparar todos los procesos hasta encontrar el de prioridad más baja.
#FR_13630Prioridad mayor de los procesos en memoria.
#FR_13640Proceso con la mayor prioridad.
#FR_13650Variable de cierre
#FR_13660Contendrá la menor prioridad para su comparación con la de otros procesos. Se le pone un valor superior al máximo porque se busca el primero de los que tengan el menor valor.
#FR_13670Se establece qué proceso tiene menor prioridad de todos los que se encuentran en memoria.
			if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${terminados[$i]} -ne 1 ]]; then
				if [[ ${temp_prio[$i]} -lt $min_prio_aux ]]; then
#FR_13680Proceso de prioridad más baja hasta ahora
#FR_13690Prioridad menor hasta ahora
				fi
			fi
		done
	fi
#FR_1370Guarda de uno en uno los colores para cada caracter de la barra de memoria (necesario impresión ventana)
		if [[ $seleccionTipoPrioridad -eq 1 ]]; then 
			seleccionTipoPrioridad_2=2
		elif [[ $seleccionTipoPrioridad -eq 2 ]]; then 
			seleccionTipoPrioridad_2=1
		fi
#FR_13710Si el rango de Prioridades no se invierte, se deja sin modificar la elección Mayor/Menor.
		seleccionTipoPrioridad_2=$seleccionTipoPrioridad
	fi
#FR_13720Se establece el proceso con menor prioridad de los que están en memoria.
#FR_13730seleccionMenuApropiatividad - 1-No apropiativo - 2-Apropiativo
#FR_13740Prioridad Mayor/Apropiativo - Se roba la CPU por ser Apropiativo.
#FR_13750Una vez encontrado el proceso de menor prioridad, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#FR_13760Marcamos el proceso como no ejecutándose si lo estaba anteriormente.
#FR_13770Ponemos el estado pausado si el proceso anteriormente en ejecución.
#FR_13780Marco el proceso para ejecutarse.
#FR_13790Quitamos el estado pausado si el proceso lo estaba anteriormente.
#FR_1380Guarda de uno en uno los colores para cada caracter de la línea del tiempo (necesario impresión ventana)
#FR_13810Una vez encontrado el proceso con más baja prioridad, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#FR_13820Se activa el aviso de entrada en CPU del volcado
				fi
#FR_13830Se activa el aviso de entrada en CPU del volcado
				anteriorProcesoEjecucion=$max_indice_aux
			fi
#FR_13840Prioridad Menor/Apropiativo - Se roba la CPU por ser Apropiativo.
#FR_13850Una vez encontrado el proceso de menor prioridad, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#FR_13860Marcamos el proceso como no ejecutándose si lo estaba anteriormente.
#FR_13870Ponemos el estado pausado si el proceso anteriormente en ejecución.
#FR_13880Marco el proceso para ejecutarse.
#FR_13890Quitamos el estado pausado si el proceso lo estaba anteriormente.
#FR_1390Array que va a guardar el orden de la reubicacion
#FR_13910Si había otro proceso en ejecución con anterioridad se avisa que se pone en pausa.
					avisoPausa[$anteriorProcesoEjecucion]=1 
				fi
#FR_13920Se activa el aviso de entrada en CPU del volcado
				anteriorProcesoEjecucion=$min_indice_aux
			fi
		fi
	fi

#FR_13930Se establece el proceso con menor prioridad de los que están en memoria.
#FR_13940seleccionMenuApropiatividad - 1-No apropiativo - 2-Apropiativo
#FR_139501 Prioridad Mayor/No Apropiativo - No se roba la CPU por ser NO Apropiativo.
#FR_13960Una vez encontrado el proceso más corto, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#FR_13970Marco el proceso para ejecutarse.
#FR_13980Quitamos el estado pausado si el proceso lo estaba anteriormente.
#FR_13990La CPU está ocupada por un proceso.
#FR_1400Array que guarda en orden de reubicación la memoria que ocupan
			fi
#FR_140102 Prioridad Menor/No Apropiativo - No se roba la CPU por ser NO Apropiativo.
#FR_14020Una vez encontrado el proceso más corto, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#FR_14030Marco el proceso para ejecutarse.
#FR_14040Quitamos el estado pausado si el proceso lo estaba anteriormente.
#FR_14050La CPU está ocupada por un proceso.
#FR_14060Se activa el aviso de entrada en CPU del volcado
			fi
		fi
    fi

#FR_14070Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
            if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enejecucion[$i]} -eq 1 ]] ; then 
                estado[$i]="En ejecucion"
                estad[$i]=3
#FR_14080Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enpausa[$i]} -eq 1 ]] ; then
                estado[$i]="En pausa"
                estad[$i]=4
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  ]] ; then
                estado[$i]="En memoria"
                estad[$i]=2
            fi
#FR_14090Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
                estado[$i]="Finalizado"
                estad[$i]=5
#FR_1410Si vale 0 no es reubicable. Si vale 1 es reubicable.
            elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
                estado[$i]="Finalizado"
                estad[$i]=5
            fi
        done
    fi
#FR_14110Si no hay proceso en ejecución se pone -1, para que pueda ser comparado.
#FR_14120Resumen - Proceso en ejecución en cada instante de tiempo.
	else
		ResuTiempoProceso[$reloj]=-1
	fi 

#FR_14130Si se trabaja NFU/NRU con clases.
#FR_14140Se traspasan todos los datos al siguiente instante para ser modificados, si se producen modificaciones al analizar los fallos y usos de las páginas.
#FR_14150
#FR_14160
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#FR_14170Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.

#FR_14180Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#FR_14190Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#FR_1420Si vale 0 es no continua. Si vale 1 es continua.
#FR_14210Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#FR_14220Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#FR_14230Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#FR_14240Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#FR_14250Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi
    
#FR_14260Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#FR_14270SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#FR_14280En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
    if [[ $reloj -eq 0 || $optejecucion = "4" ]]; then 
        evento=1
    fi
#FR_14290Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#FR_1430En cada casilla (instante actual - reloj) se guarda el número de orden del proceso que se ejecuta en cada instante.

#
#FR_14310 Sinopsis: Gestión de procesos - Round Robin
#
function gestionProcesosRoundRobin {
#FR_14320ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizarán tras lanzar el volcado.)
#FR_14330Se modifican los valores de los arrays. Primero se trabaja con los estados y tiempos de las estadísticas.
#FR_14340No ha llegado por tiempo de llegada.
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
#FR_14350Se encola pero no ha llegado por tiempo de llegada.
#FR_14360Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#FR_14370Aunque no entre en memoria ya tiene datos a considerar.
            estado[$i]="En espera"
            estad[$i]=1
        fi
#FR_14380Se mete en memoria.
#FR_14390Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#FR_1440Usada en gestionProcesosSRPT para determinar la anteriorproceso en ejecución que se compara con el actual tiempo restante de ejecución más corto y que va a ser definida como el actual proceso en ejecución.
        fi
    done
#FR_14410Se modifican los valores de los arrays, pero ahora se trabaja con el proceso que pueda haber terminado.
#FR_14420Si termina el proceso, su referencias en la cola RR se actualiza a "_", y el contador $contadorTiempoRR a 0.
			colaTiempoRR[$i]=-1 
#FR_14430Marcamos el proceso como no ejecutándose si lo estaba anteriormente.
#FR_14440Índice con el actual ordinal en ejecución para Round-Robin (RR).
			anteriorProcesoEjecucion=$i
#FR_14450Para que el proceso que se vaya a ejecutar empiece a usar su quantum desde 0.
		fi 
    done
#FR_14460Se modifican los valores de los arrays. Y ahora se trabaja con el resto de variables para trabajar sobre los tiempos ya establecidos ya que dependen de ellos en algunos casos.
#FR_14470Si termina el quantum de un proceso, su referencias en la cola RR se actualiza al último valor del $contadorTiempoRR.
#FR_14480Se marca el proceso par no ser ejecutado ya que comenzará a ejecutarse otro proceso.
#FR_14490Se marca el proceso como "en pausa".
#FR_1450Direcciones definidas de todos los Proceso (Índices:Proceso, Direcciones).
			anteriorProcesoEjecucion=$i
			contadorTiempoRR=0
			colaTiempoRR[$i]=$indiceColaTiempoRRLibre  
#FR_14510Índice con el primer ordinal libre a repartir en Round-Robin (RR).
#FR_14520Índice con el actual ordinal en ejecución para Round-Robin (RR).
#FR_14530Provoca un volcado en cada final de quantum
#FR_14540Se marca que la CPU no está ocupada por un proceso.
		fi 
    done
#FR_14550En primer lugar se establece el primer proceso que haya entrado en memoria por tiempo de llegada, o por estricto orden de llegada en memoria.
        if [[ $realizadoAntes -eq 0 ]]; then  
#FR_14560Se busca el primer proceso de entre todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
#FR_14570Si hay nuevos procesos en memoria se les encola.
						colaTiempoRR[$i]=$indiceColaTiempoRRLibre  
						indiceColaTiempoRRLibre=$(($indiceColaTiempoRRLibre + 1))
					fi 
                fi
#FR_14580Una vez encolados, se determina si se sigue ejecutando el mismo que ya lo estaba en el instante anterior, o se determina cuál se ejecutará en el instante actual, si el proceso anterior o su quantum han terminado.
#FR_14590Se busca el primer proceso de entre todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
#FR_1460Páginas definidas de todos los Proceso (Índices:Proceso, Páginas).
						contadorTiempoRR=$(($contadorTiempoRR + 1))
#FR_14610Se marca el proceso para ejecutarse o se refuerza si ya lo estaba.
#FR_14620Se quita el estado pausado si el proceso lo estaba anteriormente.
#FR_14630Se marca que la CPU está ocupada por un proceso o se refuerza si ya lo estaba.
#FR_14640Si había otro proceso en ejecución con anterioridad se avisa que se pone en pausa.
							avisoPausa[$anteriorProcesoEjecucion]=1 
						fi
#FR_14650Se activa el aviso de entrada en CPU del volcado
					fi 
				fi
            done 
        fi
    fi
#FR_14660Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
            if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enejecucion[$i]} -eq 1 ]] ; then 
                estado[$i]="En ejecucion"
                estad[$i]=3
#FR_14670Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enpausa[$i]} -eq 1 ]] ; then
                estado[$i]="En pausa"
                estad[$i]=4
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  ]] ; then
                estado[$i]="En memoria"
                estad[$i]=2
            fi
#FR_14680Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
                estado[$i]="Finalizado"
                estad[$i]=5
#FR_14690Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
            elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
                estado[$i]="Finalizado"
                estad[$i]=5
            fi
        done
    fi
#FR_1470Número de Páginas ya usadas de cada Proceso.
#FR_14710Resumen - Proceso en ejecución en cada instante de tiempo.
	else
		ResuTiempoProceso[$reloj]=-1
	fi 

#FR_14720Si se trabaja NFU/NRU con clases.
#FR_14730Se traspasan todos los datos al siguiente instante para ser modificados, si se producen modificaciones al analizar los fallos y usos de las páginas.
#FR_14740
#FR_14750
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#FR_14760Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.

#FR_14770Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#FR_14780Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#FR_14790Se lanza la gestión sin algoritmo de paginación, dado que en memoria no virtual los procesos entran en memoria de forma completa y no por páginas como en memoria virtual.
#FR_1480Secuencia de Páginas ya usadas de cada Proceso.
#FR_14810Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#FR_14820Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#FR_14830Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#FR_14840Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi
    
#FR_14850Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#FR_14860SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#FR_14870En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
    if [[ $reloj -eq 0 || $optejecucion = "4" ]]; then 
        evento=1
    fi
#FR_14880Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#FR_14890Fin de gestionProcesosRoundRobin()

#
#FR_1490Páginas ya usadas del Proceso en ejecución. Sale de forma secuencial de paginasDefinidasTotal.
#
function gestionAlgoritmoPagNoVirtual { 
#FR_14910Si no hay proceso en ejecución se pone -1, para que pueda ser comparado.
#FR_14920Resumen - Proceso en ejecución en cada instante de tiempo.
	else
		ResuTiempoProceso[$reloj]=-1
	fi
#FR_14930Se inicializan los arrays que se van a usar temporalmente para cada proceso en ejecución.
#FR_14940Contiene el ordinal del número de marco de cada proceso.
#FR_14950Se van a determinar los marcos reales que usa cada proceso.
		ordinal[$counter]=0
	done
#El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
#FR_14970 Se buscan los marcos ocupados por cada proceso
			relacionMarcosUsados[${unidMemOcupadas[$ii]},$reloj,${ordinal[${unidMemOcupadas[$ii]}]}]=$ii
			ordinal[${unidMemOcupadas[$ii]}]=$((${ordinal[${unidMemOcupadas[$ii]}]} + 1))
        fi
	done
#FR_14980Se crea la secuencia de páginas en memoria de cada proceso.
		paginasEnMemoriaProceso[$v]=${paginasEnMemoriaTotal[$ejecutandoinst,$v]}
	done 
#FR_14990Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#FR_1500Páginas pendientes de ejecutar del Proceso en ejecución. Sale de forma secuencial de paginasDefinidasTotal.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasPendientesUsarTotal[$ejecutandoinst,$v]=$pagina
	done
#FR_15010Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#FR_15020Se crea la secuencia de páginas de cada proceso ya ejecutadas.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasUsadasTotal[$ejecutandoinst,$v]=$pagina
#No es necesario ya que paginasUsadasTotal[] se genera en cada ejecución de la función.
	done 
#FR_15040Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#FR_15050Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#FR_15060Como no cambian las páginas de memoria en el modelo paginado y no virtual, se inicializan a 0 para que se imprima este valor desde el principio-
			done
		fi
	done
#FR_15070En No Virtual se usan todos los marcos asociados al proceso desde el primer momento porque se cargan en memoria todas las páginas del proceso.
#FR_15080Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#FR_15090Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#FR_1510Siguiente Página a ejecutar del Proceso en ejecución. Sale de forma secuencial de paginasDefinidasTotal con el delimitador de numeroPaginasUsadasProceso.
#FR_15110Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#FR_15120Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
			done
		fi
	done
		
#FR_15130Se inicializan las variables si no ha sido considerado el proceso con anterioridad.
#FR_15140Se meten las páginas del proceso en ejecución en los marcos de memoria.
			paginasEnMemoriaProceso[$counterMarco]=${counterMarco}
			paginasEnMemoriaTotal[$ejecutandoinst,$counterMarco]=$counterMarco
#FR_15150Índices: (proceso, marco, tiempo reloj). Dato de la página contenida en el marco
		done
#FR_15160El número de fallos de página del proceso es el número de marcos asociados a cada proceso.
#FR_15170El número de fallos de página totales es la suma de los números de marcos asociados a cada proceso.
	fi 

#FR_15180Si aún quedan páginas por ejecutar de ese proceso
#FR_15190Se determina la primera página de la secuencia de páginas pendientes
#FR_1520Páginas residentes en memoria del Proceso en ejecución. Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#FR_15210Siguiente página, pendiente de ejecutar.
#FR_15220Localiza en qué posición encuentra la página (da la posición pero no la variable en el array)
#FR_15230Localiza la página, no la posición de la página
#FR_15240Si la página está en memoria define x=1
#FR_15250Si la página está en memoria define x=1
#FR_15260Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#FR_15270Localiza en qué posición encuentra la página (da la posición pero no la variable en el array)
#FR_15280Localiza la página, no la posición de la página
					if [[ ${paginasEnMemoriaProceso[$indMarcoMem]} -eq $primera_pagina ]]; then
#FR_15290Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
#FR_1530Páginas residentes en memoria de cada Proceso (Índices:Proceso,número ordinal de marco asociado). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#FR_15310Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_15320Se mantiene el mismo mientras no se produzca un fallo de página.
#FR_15330Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
					fi
				done
			fi 
		done
#FR_15340Y si no quedan más páginas pendientes de ejecutar. No es tiempoEjecucion sino temp_rej.
		for (( counter=0; counter<$nprocesos; counter++ )); do
#FR_15350Para ser equivalente al nuevo programa. Se aconseja quitar la variable $ord y estandarizar las variables a usar ??????????.
			if [[ " ${llegados[*]} " == *" $ejecutandoinst "* ]]; then 
#FR_15360Como temp_ret()
#FR_15370Como temp_ret()
				if [[ ! " ${ejecutando[*]} " == *" $ejecutandoinst "* ]]; then
#FR_15380Como temp_wait()
					if [[ " ${haestadopausado[*]} " == *" $ejecutandoinst "* ]]; then
#FR_15390Esa resta debería ser alrevés, el de ejecución menos lo ya ejecutado...
#Tampoco es (reloj - llegada[$ejecutandoinst])
					fi
#FR_15410Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
				fi
			fi
		done
#FR_15420Actualización de variables y cambios de estado. Algunos ya se hacen en ajusteFinalTiemposEsperaEjecucionRestante().
		ejecutando="" 
		finalizados+=("$finalizado")
		finalizadonuevo+=("$finalizado")
		hanestadomem=$paginasEnMemoriaProceso
#FR_15430De momento se cambia ordenados por llegada.
#FR_15440Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#FR_15450Define el dato, pero no en qué posición se encuentra.
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
#FR_15460Fin de gestionAlgoritmoPagNoVirtual()

#
#FR_15470 Sinopsis: Algoritmo AlgPagFrecFIFORelojSegOp
#
function gestionAlgoritmoPagAlgPagFrecFIFORelojSegOp { 
#FR_15480Si no hay proceso en ejecución se pone -1, para que pueda ser comparado.
#FR_15490Resumen - Proceso en ejecución en cada instante de tiempo.
	else
		ResuTiempoProceso[$reloj]=-1
	fi
#FR_1550Fallos de página totales de cada proceso.
#FR_15510Contiene el ordinal del número de marco de cada proceso.
#FR_15520Se van a determinar los marcos reales que usa cada proceso.
		ordinal[$counter]=0
	done
#El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
#FR_15540 Se buscan los marcos ocupados por cada proceso
			relacionMarcosUsados[${unidMemOcupadas[$ii]},$reloj,${ordinal[${unidMemOcupadas[$ii]}]}]=$ii
			ordinal[${unidMemOcupadas[$ii]}]=$((${ordinal[${unidMemOcupadas[$ii]}]} + 1))
        fi
	done
#FR_15550Se crea la secuencia de páginas en memoria de cada proceso.
		paginasEnMemoriaProceso[$v]=${paginasEnMemoriaTotal[$ejecutandoinst,$v]}
	done 
#FR_15560Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#FR_15570Se crea la secuencia de páginas de cada proceso pendientes de ejecutar.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasPendientesUsarTotal[$ejecutandoinst,$v]=$pagina
	done
#FR_15580Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#FR_15590Se crea la secuencia de páginas de cada proceso ya ejecutadas.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasUsadasTotal[$ejecutandoinst,$v]=$pagina
#No es necesario ya que paginasUsadasTotal[] se genera en cada ejecución de la función.
	done 
#FR_15610Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#FR_15620Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#FR_15630Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#FR_15640Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#FR_15650Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
			done
		fi
	done

#FR_15660Con Segunda Oportunidad. Se determina el primer marco con coeficiente M=0. Y si encuentra marcos con M=1, les define M=0 y busca el siguiente. El coeficiente de la página intercambiada también se define a 0 por lo que se deja tal y como estaba, a 0.
#FR_15670Se arrastran los datos de los coeficientes en anteriores tiempos ordinales de ejecución para cada proceso en cada unidad de tiempo.
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
		
#FR_15680Si aún quedan páginas por ejecutar de ese proceso
#FR_15690Se determina la primera página de la secuencia de páginas pendientes
#FR_1570Resumen - Índices: (proceso). Dato: Número de Marcos usados en cada Proceso.
#FR_15710Siguiente página, pendiente de ejecutar.

#FR_15720Si el número de marcos usados es menor que el tamaño de la memoria asociada al proceso.

#FR_15730Define si encuentra o no la página en paginasEnMemoriaProceso
#FR_15740Localiza en qué posición encuentra la página en paginasEnMemoriaProceso (da la posición, pero no la variable en el array)
#FR_15750Busca la página en paginasEnMemoriaProceso, pero no la posición.
#FR_15760Esta línea es para cuando usamos el valor del dato y no su posición. Si la página está en memoria define x=1
#FR_15770Esta línea es para cuando usamos la posición del dato y no su valor. Si la página está en memoria define x=1
					x=1
#FR_15780 Se guarda el marco en el que se encuentra la página.
				fi 
			done
#USO DE PÁGINA - Si la página está en memoria, y si no es la primera página a usar para evitar la inicialización de la variable paginasEnMemoriaTotal[$ejecutandoinst,ordinal}] a 0.
#FR_1580Resumen - Índices: (tiempo). Dato: Proceso que se ejecuta en cada instante de tiempo real (reloj).
#FR_15810Define el dato, pero no en qué posición se encuentra.
#FR_15820Localiza en qué posición encuentra la página (j).
#FR_15830Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente).
#FR_15840Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
						for (( jj=0; jj<${memoria[$ejecutandoinst]}; jj++ )); do
#FR_15850Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#FR_15860Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
						done 
#FR_15870Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
#FR_15880Con Segunda Oportunidad
#FR_15890En caso de reusar una página se pone a 1 aunque pueda ser redundante si ya era 1.
						fi
					fi
				done
#FR_1590Resumen - Índices: (proceso, tiempo de ejecución). Dato: Tiempo de reloj en el que se ejecuta un Proceso.
#FR_15910Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso.
#FR_15920Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0.
				else
#FR_15930Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0.
				fi
#FR_15940Si NO está en memoria... FALLO DE PÁGINA
#FR_15950... la página se añade a la secuencia de páginas del proceso en ejecución en memoria.
#FR_15960... y la página se añade a la secuencia de páginas de ese proceso junto con el resto de páginas del resto de procesos residentes en memoria (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#FR_15970Contador de fallos de página totales de cada proceso
#FR_15980Contador de fallos totales de cada proceso
#FR_15990Si no es el primer instante de ejecución de este proceso.  Primero se copian y luego se modifican si es necesario.
#FR_1600Resumen - Índices: (proceso, marco, reloj). Dato: Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_16010Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#FR_16020Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
					done
				fi 
#FR_16030Se añade el dato de la página que acaba de ser incluida en un marco.
#FR_16040 Se añade el dato de la frecuencia de la página que acaba de ser incluida en un marco.
#FR_16050Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
#FR_16060Y se añade la página a la secuencia de fallos.
#FR_16070Y se añade el marco a la secuencia de fallos.
#FR_16080Aumenta en 1 el número de marcos usados. Sólo aumenta cuando se usa un nuevo marco y no en todas las unidades de ejecución del proceso. Debe ser la última línea dentro del if paradejarlo preparado para su siguiente uso como variable.
#FR_16090Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_1610Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_16110Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso.
#FR_16120Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados ya ha aumentado 1.
				else
					ResuPunteroMarcoSiguienteFalloPagAcumulado[$ejecutandoinst,$reloj]=0
				fi
#FR_16130Con Segunda Oportunidad. Redundante porque ya se inicializa a 0...
					coeficienteSegOp[$ejecutandoinst,${ResuPunteroMarcoUsado[$ejecutandoinst,$reloj]},$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))]=0
				fi
			fi
#FR_16140Si el número de marcos usados es mayor o igual que el tamaño de la memoria asociada al proceso.
#FR_16150Define si encuentra o no la página en paginasEnMemoriaProceso
#FR_16160Localiza en qué posición encuentra la página (da la posición pero no la variable en el array)
#FR_16170Localiza la página, no la posición de la página
#FR_16180Si la página está en memoria define x=1
#FR_16190Si la página está en memoria define x=1
					x=1
				fi 
			done
#FR_1620Resumen - Índices: (proceso, marco, reloj). Dato: Frecuencia de la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_16210Localiza en qué posición encuentra la página (da la posición pero no la variable en el array)
#FR_16220Localiza la página, no la posición de la página
					if [[ ${paginasEnMemoriaProceso[$indMarcoMem]} -eq $primera_pagina ]]; then
						for (( jj=0; jj<${memoria[$ejecutandoinst]}; jj++ )); do
#FR_16230Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#FR_16240Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
						done
#FR_16250Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
#FR_16260Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente).
#FR_16270Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_16280Con Segunda Oportunidad
#FR_16290En caso de reusar una página se pone a 1 aunque pueda ser redundante si ya era 1.
						fi
#FR_1630Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_16310Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
					fi
				done
#FR_16320Y si NO está en la memoria...FALLO DE PÁGINA. se localiza el que tenga el primer valor del mayor contador de frecuencia por ser AlgPagFrecMFU.
#FR_16330Con Segunda Oportunidad. Se determina el primer marco con coeficiente M=0. Y si encuentra marcos con M=1, les define M=0 y busca el siguiente. El coeficiente de la página intercambiada también se define a 0 por lo que se deja tal y como estaba, a 0.
					varCoeficienteSegOp=0
					varCoefMarco=""
#Se usa el mismo tiempo ordinal de ejecución del proceso para todos los marcos porque es el siguiente tiempo ordinal el que interesa. La variable ResuPaginaOrdinalAcumulado[] se cambiará después, pero ya se tiene en cuenta ahora.
					until [[ $varCoeficienteSegOp -eq 1 ]]; do 
						varCoefMarco=${ResuPunteroMarcoSiguienteFalloPagAcumulado[$ejecutandoinst,$reloj]}
#FR_16350Si M de Segunda Oportunidad vale 0, se pone a 1. Y si ya vale 1, se deja como está.
#FR_16360Se define a 0 para que en la segunda vuelta se pueda producir el fallo sobre el primer M=0 que encuentre.
#FR_16370Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso.
#FR_16380Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0.
							else
								ResuPunteroMarcoSiguienteFalloPagAcumulado[$ejecutandoinst,$reloj]=0
							fi
						else 
#FR_16390Se define a 0 para que en la segunda vuelta se pueda producir el fallo sobre el primer M=0 que encuentre.
							varCoeficienteSegOp=1
						fi
					done
				fi
#FR_1640Resumen - Índices: (proceso, reloj). Dato: Marco (Puntero) sobre el que se produce el siguiente fallo para todos los Procesos en cada unidad de Tiempo.
#FR_16410Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#FR_16420Aumenta en una unidad el número de fallos de página del proceso.
#FR_16430Contador de fallos totales de cada proceso
				for (( jj=0; jj<${memoria[$ejecutandoinst]}; jj++ )); do
#FR_16440Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#FR_16450Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
				done
#FR_16460 Se añade el dato de la página que acaba de ser incluida en un marco.
#FR_16470Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_16480Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página.
#FR_16490Y se añade la página a la secuencia de fallos.
#FR_1650Resumen - Índices: (proceso, tiempo). Dato: Marco usado (Puntero) para cada Proceso en cada unidad de Tiempo.
#FR_16510Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página).
#FR_16520Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso.
#FR_16530Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0.
				else
					ResuPunteroMarcoSiguienteFalloPagAcumulado[$ejecutandoinst,$reloj]=0
				fi
#FR_16540Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
			fi
		fi          
#FR_16550Y si no quedan más páginas pendientes de ejecutar. No es tiempoEjecucion sino temp_rej.
		for (( counter=0; counter<$nprocesos; counter++ )); do
#FR_16560Para ser equivalente al nuevo programa. Se aconseja quitar la variable $ord y estandarizar las variables a usar ??????????.
			if [[ " ${llegados[*]} " == *" $ejecutandoinst "* ]]; then 
#FR_16570Como temp_ret()
#FR_16580Como temp_ret()
				if [[ ! " ${ejecutando[*]} " == *" $ejecutandoinst "* ]]; then
#FR_16590Como temp_wait()
					if [[ " ${haestadopausado[*]} " == *" $ejecutandoinst "* ]]; then
#FR_1660Resumen - Índices: (marco, tiempo). Dato: Texto a iprimir en Color con el seguimiento del uso de los Marcos a lo largo del Tiempo (página-frecuencia).
#Tampoco es (reloj - llegada[$ejecutandoinst])
					fi
#FR_16620Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
				fi
			fi
		done
#FR_16630Actualización de variables y cambios de estado. Algunos ya se hacen en ajusteFinalTiemposEsperaEjecucionRestante().
		ejecutando="" 
		finalizados+=("$finalizado")
		finalizadonuevo+=("$finalizado")
		hanestadomem=$paginasEnMemoriaProceso
#FR_16640De momento se cambia ordenados por llegada.
#FR_16650Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#FR_16660Define el dato, pero no en qué posición se encuentra.
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
#FR_16670Fin de gestionAlgoritmoPagAlgPagFrecFIFORelojSegOp()

#
#FR_16680 Sinopsis: Algoritmo AlgPagFrecMFULFUNFU - NFU usará un límite máximo de la frecuencia de uso de las páginas (seleccionAlgoritmoPaginacion_clases_frecuencia_valor) y el límite de tiempo de permanencia en las clases 2 y 3 (seleccionAlgoritmoPaginacion_clases_valor) en un intervalo de tiempo (seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado)
#
#FR_16690ResuFrecuenciaAcumulado
#FR_1670Resumen - Índices: (marco, tiempo). Dato: Texto a iprimir en Blanco-Negro con el seguimiento del uso de los Marcos a lo largo del Tiempo (página-frecuencia).
#FR_16710Contiene el ordinal del número de marco de cada proceso.
#FR_16720Se van a determinar los marcos reales que usa cada proceso.
		ordinal[$counter]=0
	done
#El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
#FR_16740 Se buscan los marcos ocupados por cada proceso
			relacionMarcosUsados[${unidMemOcupadas[$ii]},$reloj,${ordinal[${unidMemOcupadas[$ii]}]}]=$ii
			ordinal[${unidMemOcupadas[$ii]}]=$((${ordinal[${unidMemOcupadas[$ii]}]} + 1))
        fi
	done
#FR_16750Se crea la secuencia de páginas en memoria de cada proceso.
		paginasEnMemoriaProceso[$v]=${paginasEnMemoriaTotal[$ejecutandoinst,$v]}
	done 
#FR_16760Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#FR_16770Se crea la secuencia de páginas de cada proceso pendientes de ejecutar.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasPendientesUsarTotal[$ejecutandoinst,$v]=$pagina
	done
#FR_16780Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#FR_16790Se crea la secuencia de páginas de cada proceso ya ejecutadas.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasUsadasTotal[$ejecutandoinst,$v]=$pagina
#No es necesario ya que paginasUsadasTotal[] se genera en cada ejecución de la función.
	done 
#FR_16810Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#FR_16820Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#FR_16830Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#FR_16840Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#FR_16850Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_16860NFU con clases sobre MFU/LFU
#FR_16870Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				fi
			done
		fi
	done
	
#FR_16880Se crea la secuencia de páginas en memoria de cada proceso.
		indPagIni=$((${numeroPaginasUsadasProceso[$ejecutandoinst]}))
		if [[ $indPagIni -eq 0 ]]; then
#FR_16890Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#FR_16900Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#FR_16910Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		else
#FR_16920Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		fi
	done 
#FR_16930Se crea la secuencia de páginas en memoria de cada proceso.
#FR_16940Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3, o al máximo de frecuencia de uso.
	done 

#FR_16950Si aún quedan páginas por ejecutar de ese proceso.
#FR_16960Se determina la primera página de la secuencia de páginas pendientes.
#FR_16970Número de páginas usadas en el proceso en ejecución. Aumenta en todas las unidades de ejecución del proceso.
#FR_16980Siguiente página, pendiente de ejecutar.
#FR_16990Si el número de marcos usados es menor que el tamaño de la memoria asociada al proceso.
#FR_1700Resumen - Índices: (proceso, tiempo). Dato: Páginas que produjeron Fallos de Página del Proceso en ejecución.
#FR_17010Localiza en qué posición encuentra la página en paginasEnMemoriaProceso (da la posición, pero no la variable en el array).
#FR_17020Esta línea es para cuando usamos la posición del dato y no su valor. Si la página está en memoria define x=1.
					x=1
				fi 
			done
#USO DE PÁGINA - Si la página está en memoria, y si no es la primera página a usar para evitar la inicialización de la variable paginasEnMemoriaTotal[$ejecutandoinst,ordinal}] a 0.
#FR_17040Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array).
#FR_17050Localiza en qué posición encuentra la página (j).
#FR_17060Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente).
#FR_17070Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_17080NFU-MFU/NFU-LFU
							if [[ ${ResuFrecuenciaAcumulado[$ejecutandoinst,$indMarcoMem,${indiceResuPaginaAcumulado[$ejecutandoinst]}]} -lt $seleccionAlgoritmoPaginacion_frecuencia_valor ]]; then 
#FR_17090Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
							else
#FR_1710Resumen - Índices: (proceso, tiempo). Dato: Marcos donde se produjeron Fallos de Página del Proceso en ejecución.
							fi
#FR_17110MFU/LFU
#FR_17120Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
#FR_17130NFU-MFU/NFU-LFU con clases
#FR_17140Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
							directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarcoMem]=1
#FR_17150Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#FR_17160Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#FR_17170Si las páginas tienen una frecuencia de uso mayor que la frecuencia máxima $seleccionAlgoritmoPaginacion_clases_frecuencia_valor
#FR_17180 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor. Si lo supera se comprueba que no sea en la misma clase 2 o 3.
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoMem]=$seleccionAlgoritmoPaginacion_clases_frecuencia_valor
							fi
						fi
#FR_17190Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se ejecuta este proceso. También se usa para las frecuencias.
#FR_1720Resumen - Índices: (proceso). Dato: Número de Fallos de Página de cada Proceso.
#FR_17210Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0.
						fi
#FR_17220NFU con clases sobre MFU/LFU
#FR_17230Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
						fi
					fi
				done
#FR_17240Si NO está en memoria... FALLO DE PÁGINA
#FR_17250Aumenta en 1 el número de marcos usados. Sólo aumenta cuando se usa un nuevo marco y no en todas las unidades de ejecución del proceso. Debe ser la última línea dentro del if paradejarlo preparado para su siguiente uso como variable.
#FR_17260Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). Sería -1 porque numeroMarcosUsados empieza a contar en 1.
#FR_17270... la página se añade a la secuencia de páginas del proceso en ejecución en memoria.
#FR_17280... y la página se añade a la secuencia de páginas de ese proceso junto con el resto de páginas del resto de procesos residentes en memoria (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#FR_17290Contador de fallos de página totales de cada proceso.
#FR_1730Resumen - Índices: (proceso). Dato: Número de Expulsiones Forzadas de cada Proceso.
#FR_17310Se añade el dato de la página que acaba de ser incluida en un marco.
#FR_17320Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_17330 Se añade el dato de la frecuencia de la página que acaba de ser incluida en un marco.
#FR_17340Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#FR_17350Y se añade la página a la secuencia de fallos.
#FR_17360Y se añade el marco a la secuencia de fallos.
#FR_17370Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
				directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))]=0
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 ]]; then
#FR_17380Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#FR_17390Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#FR_1740Resumen - Índices: (proceso). Dato: Número memor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
				fi
#FR_17410Sólo es necesario si se llenan todos los marcos asociados al proceso.
#FR_17420MFU
#FR_17430Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#FR_17440Localiza en qué posición encuentra la página.
#FR_17450Mayor frecuencia encontrada.
#FR_17460Posición del marco con la mayor frecuencia.
							fi
#FR_17470Y sobre esa localización se hace el fallo de página
#FR_17480NFU con clases sobre MFU
#FR_17490Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#FR_1750Resumen - Índices: (proceso). Dato: Número mayor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#FR_17510QUEDA PENDIENTE USARLO PARA RESTAR LA FRECUENCIA ACTUAL DE LA QUE TENÍA EN AQUEL MOMENTO.
						else
							limite_j=0
						fi
#FR_17520Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#FR_17530LFU
#FR_17540Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#FR_17550Localiza en qué posición encuentra la página.
#FR_17560Menor frecuencia encontrada.
#FR_17570Posición del marco con la menor frecuencia.
							fi
#FR_17580Y sobre esa localización se hace el fallo de página
					
#FR_17590NFU con clases sobre MFU
#FR_1760Resumen - Índices: (proceso). Dato: Número de las posiciones con la memor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#FR_17610Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#FR_17620Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					fi
				fi
#FR_17630Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso.
#FR_17640Suma 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres.
				else
#FR_17650MFU
#FR_17660El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.
#FR_17670LFU
#FR_17680El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.
					fi
				fi
			fi
#FR_17690Si el número de marcos usados es mayor o igual que el tamaño de la memoria asociada al proceso.
#FR_1770Resumen - Índices: (proceso). Dato: Número de las posiciones con la mayor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#FR_17710Localiza en qué posición encuentra la página (da la posición pero no la variable en el array).
#FR_17720Si la página está en memoria define x=1.
					x=1
				fi 
			done
#FR_17730Si la página está en memoria...USO DE PÁGINA
#FR_17740Localiza en qué posición encuentra la página (da la posición pero no la variable en el array).
					if [[ ${paginasEnMemoriaProceso[$indMarcoMem]} -eq $primera_pagina ]]; then
#FR_17750Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente).
#FR_17760Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_17770NFU-MFU/NFU-LFU
							if [[ ${ResuFrecuenciaAcumulado[$ejecutandoinst,$indMarcoMem,${indiceResuPaginaAcumulado[$ejecutandoinst]}]} -lt $seleccionAlgoritmoPaginacion_frecuencia_valor ]]; then 
#FR_17780Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
							else
#FR_17790Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
							fi
#FR_1780Resumen - Índices: (proceso). Dato: Número memor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#FR_17810Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
#FR_17820NFU-MFU/NFU-LFU con clases
#FR_17830Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
							directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarcoMem]=1
#FR_17840Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#FR_17850Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#FR_17860Si las páginas tienen una frecuencia de uso mayor que la frecuencia máxima $seleccionAlgoritmoPaginacion_clases_frecuencia_valor
#FR_17870 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor. Si lo supera se comprueba que no sea en la misma clase 2 o 3.
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoMem]=$seleccionAlgoritmoPaginacion_clases_frecuencia_valor
							fi
#FR_17880Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
						fi
#FR_17890MFU
#FR_1790Resumen - Índices: (proceso). Dato: Número mayor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#FR_17910Localiza en qué posición encuentra la página.
#FR_17920Mayor frecuencia encontrada.
#FR_17930Posición del marco con la mayor frecuencia.
								fi
#FR_17940Y sobre esa localización se hace el fallo de página
#FR_17950El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.
				
#FR_17960NFU con clases sobre MFU
#FR_17970Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
							paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#FR_17980Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
								limite_j=$ultimasPaginasAConsiderar
							else
								limite_j=0
							fi
#FR_17990Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#FR_1800Resumen - Índices: (proceso). Dato: Número de las posiciones con la memor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#FR_18010LFU
#FR_18020Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
							min_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#FR_18030Localiza en qué posición encuentra la página.
#FR_18040Menor frecuencia encontrada.
#FR_18050Posición del marco con la menor frecuencia.
								fi
#FR_18060Y sobre esa localización se hace el fallo de página
#FR_18070El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.
				
#FR_18080NFU con clases sobre MFU
#FR_18090Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
							min_AlgPagFrecRec_Position[$ejecutandoinst]=0
							ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
							paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#FR_1810Resumen - Índices: (proceso). Dato: Número de las posiciones con la mayor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
								limite_j=$ultimasPaginasAConsiderar
							else
								limite_j=0
							fi
#FR_18110Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#FR_18120El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.
						fi
#FR_18130Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
					fi
				done
#FR_18140Y si NO está en la memoria...FALLO DE PÁGINA. Se localiza el que tenga el primer valor del mayor contador de frecuencia por ser AlgPagFrecMFU.
#FR_18150MFU
#FR_18160Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página).
#FR_18170Se hace el fallo de página sobre el primer marco con la mayor frecuencia, sustituyendo la página.
#FR_18180Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.

#FR_18190NFU con clases sobre MFU
#FR_1820Resumen - Índices: (proceso, ordinal de página, reloj (0)). Dato: Se usará para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
#FR_18210Se hace el fallo de página sobre el primer marco con la mayor frecuencia, sustituyendo la página.
#FR_18220Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,${max_AlgPagFrecRec_Position[$ejecutandoinst]}]=0
#FR_18230LFU
#FR_18240Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página).
#FR_18250Se hace el fallo de página sobre el primer marco con la menor frecuencia, sustituyendo la página.
#FR_18260Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
				
#FR_18270NFU con clases sobre MFU
#FR_18280Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página).
#FR_18290Se hace el fallo de página sobre el primer marco con la menor frecuencia, sustituyendo la página.
#FR_1830Resumen - Índices: (proceso, marco). Dato: Se usará para determinar si una página ha sido o no referenciada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,${min_AlgPagFrecRec_Position[$ejecutandoinst]}]=0
				fi
#FR_18310Aumenta en una unidad el número de fallos de página del proceso.
#FR_18320Contador de fallos totales de cada proceso
#FR_18330MFU
#FR_18340 Se añade el dato de la página que acaba de ser incluida en un marco.
#FR_18350Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_18360Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página.
#FR_18370Y se añade la página a la secuencia de fallos.
#FR_18380Y se añade el marco a la secuencia de fallos.
#FR_18390NFU-MFU con clases
#FR_1840Resumen - Índices: (proceso, tiempo de ejecución). Dato: Página referenciada (1) o no referenciada (0).
#FR_18410Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#FR_18420Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#FR_18430Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
#FR_18440Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#FR_18450Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#FR_18460Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					else
#FR_18470Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#FR_18480Localiza en qué posición encuentra la página.
#FR_18490Mayor frecuencia encontrada.
#FR_1850Resumen - Índices: (proceso, ordinal del tiempo de ejecución). Dato: Página modificada (1) o no modificada (0).
							fi
#FR_18510Y sobre esa localización se hace el fallo de página.
					fi
#FR_18520El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.
#FR_18530LFU
#FR_18540 Se añade el dato de la página que acaba de ser incluida en un marco.
#FR_18550Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_18560Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página.
#FR_18570Y se añade la página a la secuencia de fallos.
#FR_18580Y se añade el marco a la secuencia de fallos.
#FR_18590NFU-LFU con clases
#FR_1860Resumen - Índices: (proceso). Dato: Ordinal del tiempo de ejecución en el que se hizo el último cambio de clase máxima.
#FR_18610Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#FR_18620Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#FR_18630Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
#FR_18640Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#FR_18650Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#FR_18660Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					else
#FR_18670Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#FR_18680Localiza en qué posición encuentra la página.
#FR_18690Mayor frecuencia encontrada.
#FR_18700Posición del marco con la menor frecuencia.
							fi
#FR_18710Y sobre esa localización se hace el fallo de página.
					fi
#FR_18720El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.
				fi
#FR_18730Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
			fi
		fi          
	
#FR_18740Y si no quedan más páginas pendientes de ejecutar. No es tiempoEjecucion sino temp_rej.
		for (( counter=0; counter<$nprocesos; counter++ )); do
#FR_18750Para ser equivalente al nuevo programa. ?????? QUITAR ord ??????????
			if [[ " ${llegados[*]} " == *" $ejecutandoinst "* ]]; then 
#FR_18760Como temp_ret(). Se aconseja quitar la variable $retorno y estandarizar las variables a usar ??????????.
#FR_18770Como temp_ret(). Se aconseja quitar la variable $retorno y estandarizar las variables a usar ??????????.
				if [[ ! " ${ejecutando[*]} " == *" $ejecutandoinst "* ]]; then
#FR_18780Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
					if [[ " ${haestadopausado[*]} " == *" $ejecutandoinst "* ]]; then
#FR_18790Esa resta debería ser alrevés, el de ejecución menos lo ya ejecutado...
#Tampoco es (reloj - llegada[$ejecutandoinst]).
					fi
#FR_18810Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
				fi
			fi
		done
#FR_18820Actualización de variables y cambios de estado. Algunos ya se hacen en ajusteFinalTiemposEsperaEjecucionRestante().
		ejecutando="" 
		finalizados+=("$finalizado")
		finalizadonuevo+=("$finalizado")
		hanestadomem=$paginasEnMemoriaProceso
#FR_18830De momento se cambia ordenados por llegada.
#FR_18840Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array).
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
#FR_18850Fin de gestionAlgoritmoPagAlgPagFrecMFULFUNFU()

#
#FR_18860 Sinopsis: Algoritmo AlgPagFrecMRULRUNRU - NRU usará un límite máximo del tiempo que hace que se usaron las páginas por última vez (seleccionAlgoritmoPaginacion_uso_rec_valor)
#
#FR_18870ResuUsoRecienteAcumulado
#FR_18880Se inicializan los arrays que se van a usar temporalmente para cada proceso en ejecución.
#FR_18890Contiene el ordinal del número de marco de cada proceso.
#FR_1890Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		ordinal[$counter]=0
	done
echo "444444444444 - 1"
#El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
#FR_18920 Se buscan los marcos ocupados por cada proceso
			relacionMarcosUsados[${unidMemOcupadas[$ii]},$reloj,${ordinal[${unidMemOcupadas[$ii]}]}]=$ii
			ordinal[${unidMemOcupadas[$ii]}]=$((${ordinal[${unidMemOcupadas[$ii]}]} + 1))
        fi
	done
echo "444444444444 - 2"
#FR_18930Se crea la secuencia de páginas en memoria de cada proceso.
		paginasEnMemoriaProceso[$v]=${paginasEnMemoriaTotal[$ejecutandoinst,$v]}
	done 
#FR_18940Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
echo "444444444444 - 3"
#FR_18950Se crea la secuencia de páginas de cada proceso pendientes de ejecutar.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasPendientesUsarTotal[$ejecutandoinst,$v]=$pagina
	done
#FR_18960Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
echo "444444444444 - 4"
#FR_18970Se crea la secuencia de páginas de cada proceso ya ejecutadas.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasUsadasTotal[$ejecutandoinst,$v]=$pagina
#No es necesario ya que paginasUsadasTotal[] se genera en cada ejecución de la función.
	done 
echo "444444444444 - 5"
#FR_18990Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#FR_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#FR_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
#FR_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
#FR_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
#FR_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
#FR_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
#FR_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
				elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#FR_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
				fi
#FR_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
#FR_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
				fi
			done
		fi
	done
	
echo "444444444444 - 6"
#FR_1910Resumen - Índices: (proceso, marco, reloj). Dato: Histórico con la resta de las frecuencias de ambos momentos para ver si supera el valor límite máximo.
		indPagIni=$((${numeroPaginasUsadasProceso[$ejecutandoinst]}))
		if [[ $indPagIni -eq 0 ]]; then
#FR_19110Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#FR_19120Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#FR_19130Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_uso_rec_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		else
#FR_19140Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_uso_rec_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		fi
	done 
echo "444444444444 - 7"
#FR_19150Se actualizan los valores del tiempo que falta para ejecutarse una página de cada proceso, salvo si es 0, ya que en ese caso, no se volverá a encontrar en la sucesión de páginas pendientes del proceso.
		if [[ ${primerTiempoEntradaPagina[$ejecutandoinst,$indMarco]} -gt 0 ]]; then
#FR_19160Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3, o al máximo de frecuencia de uso.
		fi
	done 

echo "3333333333333 - 8"
#FR_19170Si aún quedan páginas por ejecutar de ese proceso.
#FR_19180Se determina la primera página de la secuencia de páginas pendientes.
#FR_19190Número de páginas usadas en el proceso en ejecución. Aumenta en todas las unidades de ejecución del proceso.
#FR_1920Resumen - Índices: (proceso, marco, tiempo). Dato: Clase de la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_19210Si el número de marcos usados es menor que el tamaño de la memoria asociada al proceso.
#FR_19220Define si encuentra o no la página en paginasEnMemoriaProceso
#FR_19230Localiza en qué posición encuentra la página en paginasEnMemoriaProceso (da la posición, pero no la variable en el array).
#FR_19240Esta línea es para cuando usamos la posición del dato y no su valor. Si la página está en memoria define x=1.
					x=1
#FR_19250 Se guarda el marco en el que se encuentra la página.
				fi 
			done
#USO DE PÁGINA - Si la página está en memoria, y si no es la primera página a usar para evitar la inicialización de la variable paginasEnMemoriaTotal[$ejecutandoinst,ordinal}] a 0.
echo "3333333333333 - 2"
#FR_19270Se van a tratar las variables que no se corresponden con el marco usado.
#FR_19280El tiempo desde que se usó una página en memoria aumenta en cada unidad de tiempo de ejecución del proceso, siempre que no sea la que se usa, o sobre la que se produce el fallo de paginación.
					if [[ $indMarcoRec -ne $indMarcoMem ]]; then
#FR_19290Óptimo
#FR_1930Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el coeficiente M de los algoritmos de Segunda Oportunidad con valor 0 cuando se inicializa o cuando se permite su mantenimiento, aunque le toque para el fallo de paginación, y 1 como premio cuando se reutiliza.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#FR_19310MFU/LFU. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#FR_19320NFU-MFU/NFU-LFU
#FR_19330Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							else
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$seleccionAlgoritmoPaginacion_uso_rec_valor
							fi
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#FR_19340NFU-MFU/NFU-LFU con clases. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
#FR_19350Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
							else
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$seleccionAlgoritmoPaginacion_clases_uso_rec_valor
							fi 
						fi
					fi
					if [[ $indMarcoRec -eq $indMarcoMem ]]; then
#FR_19360Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente).
#FR_19370Óptimo
#FR_19380Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
#FR_19390Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_1940Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo que hay hasta la reutilización de la página contenida en el marco.
						fi
					fi
				done
#FR_19410Ahora se definirán las variables que se corresponden con el marco usado.
#FR_19420Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_194300 por haber sido usado.
#FR_19440NFU-MFU/NFU-LFU con clases
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarcoMem]=1
					ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoMem]=0
#FR_19450Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#FR_19460Si las páginas tienen una frecuencia de uso mayor que la frecuencia máxima $seleccionAlgoritmoPaginacion_clases_uso_rec_valor
				fi
									
#FR_19470Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se ejecuta este proceso. También se usa para las frecuencias.
#FR_19480Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso.
#FR_19490Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0.
				fi
#FR_1950Índice: (proceso). Dato: Contiene el orden de ejecución de Round-Robin (RR). Será "-" mientras no esté en cola, o cuando haya terminado, y si aún no ha terminado contendrá el número ordinal del siguiente quantum. El proceso a ejecutar será, por tanto, el que tenga el número ordinal más bajo. Y el número de quantums realizados (cambios de contexto, será el número ordinal más alto.
#FR_19510Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
				fi
			
#FR_19520Si NO está en memoria... FALLO DE PÁGINA
echo "3333333333333 - 3"
#FR_19530Aumenta en 1 el número de marcos usados. Sólo aumenta cuando se usa un nuevo marco y no en todas las unidades de ejecución del proceso. Debe ser la última línea dentro del if paradejarlo preparado para su siguiente uso como variable.
#FR_19540Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). Sería -1 porque numeroMarcosUsados empieza a contar en 1.
#FR_19550Se van a tratar las variables que no se corresponden con el marco usado.
#FR_19560El tiempo desde que se usó una página en memoria aumenta en cada unidad de tiempo de ejecución del proceso, siempre que no sea la que se usa, o sobre la que se produce el fallo de paginación.
					if [[ $indMarcoRec -ne ResuPunteroMarcoUsado[$ejecutandoinst,$reloj] ]]; then
#FR_19570Óptimo
#FR_19580Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#FR_19590MFU/LFU. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#FR_1960Variables para la impresión de volcados
#FR_19610Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							else
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$seleccionAlgoritmoPaginacion_uso_rec_valor
							fi
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#FR_19620NFU-MFU/NFU-LFU con clases. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
#FR_19630Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
							else
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$seleccionAlgoritmoPaginacion_clases_uso_rec_valor
							fi
						fi
					fi
					if [[ $indMarcoRec -eq ${ResuPunteroMarcoUsado[$ejecutandoinst,$reloj]} ]]; then
#FR_19640Óptimo
#FR_19650Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
							
#FR_19660Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_19670Resumen - Índices: (proceso, marco). Dato: Histórico con el valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
						fi
					fi
				done
#FR_19680Ahora se definirán el resto de variables que se corresponden con el marco usado.
#FR_19690... la página se añade a la secuencia de páginas del proceso en ejecución en memoria.
#FR_1970Variables para la impresión de volcados
#FR_19710Contador de fallos de página totales de cada proceso.
#FR_19720Contador de fallos totales de cada proceso
#FR_19730Se añade el dato de la página que acaba de ser incluida en un marco.
#FR_19740Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_19750 Se añade el dato de la frecuencia de la página que acaba de ser incluida en un marco.
#FR_19760Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#FR_19770Y se añade la página a la secuencia de fallos.
#FR_19780Y se añade el marco a la secuencia de fallos.
#FR_19790Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
				directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))]=0
#FR_1980Variables para la impresión de volcados
#FR_19810MFU
#FR_19820Se recalcula el siguiente uso de la página utilizada más alejado en el tiempo.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#FR_19830Localiza en qué posición encuentra la página.
#FR_19840Mayor frecuencia encontrada.
#FR_19850Posición del marco con la mayor frecuencia.
							fi
#FR_19860Y sobre esa localización se hace el fallo de página
#FR_19870MFU
#FR_19880Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#FR_19890Localiza en qué posición encuentra la página.
#FR_1990Variables para la impresión de volcados
#FR_19910Posición del marco con la mayor frecuencia.
							fi
#FR_19920Y sobre esa localización se hace el fallo de página
#FR_19930NFU con clases sobre MFU
#FR_19940Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#FR_19950Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
#FR_19960QUEDA PENDIENTE USARLO PARA RESTAR LA FRECUENCIA ACTUAL DE LA QUE TENÍA EN AQUEL MOMENTO.
						else
							limite_j=0
						fi
#FR_19970Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#FR_19980LFU
#FR_19990Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							fi
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
					fi
				fi
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
				else
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
					fi
				fi
			fi

#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
					x=1
				fi 
			done
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
echo "3333333333333 - 4"
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
					if [[ ${paginasEnMemoriaProceso[$indMarcoMem]} -eq $primera_pagina ]]; then
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							if [[ $indMarcoRec -ne ResuPunteroMarcoUsado[$ejecutandoinst,$reloj] ]]; then
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos

#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos

#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
									ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
									ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
										ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
									else
										ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$seleccionAlgoritmoPaginacion_uso_rec_valor
									fi
									ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
									ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
										ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
									else
										ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$seleccionAlgoritmoPaginacion_clases_uso_rec_valor
									fi
								fi
							fi
							if [[ $indMarcoRec -eq ResuPunteroMarcoUsado[$ejecutandoinst,$reloj] ]]; then
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos

									ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
								fi
							fi							
						done
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							if [[ ${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,${indiceResuPaginaAcumulado[$ejecutandoinst]}]} -lt $seleccionAlgoritmoPaginacion_uso_rec_valor ]]; then 
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
							else
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
							fi
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
							directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarcoMem]=1
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoMem]=0
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
						fi
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
								fi
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
								fi
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
				
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
							paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
								limite_j=$ultimasPaginasAConsiderar
							else
								limite_j=0
							fi
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							min_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
								fi
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							min_AlgPagFrecRec_Position[$ejecutandoinst]=0
							ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
							paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
								limite_j=$ultimasPaginasAConsiderar
							else
								limite_j=0
							fi
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
						fi
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
					fi
				done

#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
echo "3333333333333 - 5"
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,${max_AlgPagFrecRec_Position[$ejecutandoinst]}]=0
				
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,${min_AlgPagFrecRec_Position[$ejecutandoinst]}]=0
				fi
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
					if [[ $indMarcoRec -ne ${ResuPunteroMarcoUsado[$ejecutandoinst,$reloj]} ]]; then
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))

#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							else
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$seleccionAlgoritmoPaginacion_uso_rec_valor
							fi
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
#FR_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
							else
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$seleccionAlgoritmoPaginacion_clases_uso_rec_valor
							fi
						fi
					fi
					if [[ $indMarcoRec -eq ${ResuPunteroMarcoUsado[$ejecutandoinst,$reloj]}  ]]; then
#FR_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación
#FR_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación

#FR_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación
#FR_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación
#FR_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación
						fi
					fi					
				done
#FR_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación
#FR_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación
#FR_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación
#FR_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación
#FR_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación
#FR_2110Datos de particiones y procesos de la ejecución anterior.
#FR_21110Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página.
#FR_21120Y se añade la página a la secuencia de fallos.
#FR_21130Y se añade el marco a la secuencia de fallos.
#FR_21140NFU-MFU con clases
#FR_21150Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#FR_21160Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#FR_21170Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#FR_21180Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
#FR_21190Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#FR_2120Datos de particiones y procesos de la copia estándar (por defecto).
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#FR_21210Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					else
#FR_21220Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#FR_21230Localiza en qué posición encuentra la página.
#FR_21240Mayor frecuencia encontrada.
#FR_21250Posición del marco con la mayor frecuencia.
							fi
#FR_21260Y sobre esa localización se hace el fallo de página.
					fi
#FR_21270El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.
#FR_21280LFU
#FR_21290 Se añade el dato de la página que acaba de ser incluida en un marco.
#FR_2130Rangos de particiones y procesos de la ejecución anterior.
#FR_21310Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página.
#FR_21320Y se añade la página a la secuencia de fallos.
#FR_21330Y se añade el marco a la secuencia de fallos.
#FR_21340NFU-LFU con clases
#FR_21350Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#FR_21360Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#FR_21370Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#FR_21380Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
#FR_21390Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#FR_2140Rangos de particiones y procesos de la copia estándar (por defecto).
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#FR_21410Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					else
#FR_21420Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#FR_21430Localiza en qué posición encuentra la página.
#FR_21440Mayor frecuencia encontrada.
#FR_21450Posición del marco con la menor frecuencia.
							fi
#FR_21460Y sobre esa localización se hace el fallo de página.
					fi
#FR_21470El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.
				fi
#FR_21480Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
			fi
		fi          
	
#FR_21490Y si no quedan más páginas pendientes de ejecutar. No es tiempoEjecucion sino temp_rej.
echo "3333333333333 - 6"
		for (( counter=0; counter<$nprocesos; counter++ )); do
#FR_2150Rangos amplios de particiones y procesos de la ejecución anterior para la extracción de subrangos.
#??????????? NO PUEDE ESTAR BIEN...Ni el timpo de retorno, porque puede llegar pero no entrar en memoria,  ni el tiempo de espera por la misma razón, ni resta[$ejecutandoinst]=$((tiempo[$ejecutandoinst].... porque tiempo[] no existe
#FR_21520Como temp_ret(). Se aconseja quitar la variable $retorno y estandarizar las variables a usar ??????????.
#FR_21530Como temp_ret(). Se aconseja quitar la variable $retorno y estandarizar las variables a usar ??????????.
				if [[ ! " ${ejecutando[*]} " == *" $ejecutandoinst "* ]]; then
#FR_21540Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
					if [[ " ${haestadopausado[*]} " == *" $ejecutandoinst "* ]]; then
#FR_21550Esa resta debería ser alrevés, el de ejecución menos lo ya ejecutado...
#Tampoco es (reloj - llegada[$ejecutandoinst]).
					fi
#FR_21570Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
				fi
			fi
		done
#FR_21580Actualización de variables y cambios de estado. Algunos ya se hacen en ajusteFinalTiemposEsperaEjecucionRestante().
#FR_21590Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
		ejecutando="" 
		finalizados+=("$finalizado")
		finalizadonuevo+=("$finalizado")
		hanestadomem=$paginasEnMemoriaProceso
#FR_2160Rangos amplios de particiones y procesos de la copia estándar (por defecto) para la extracción de subrangos.
#FR_21610Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array).
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
#FR_21620Fin de gestionAlgoritmoPagAlgPagRecMRULRUNRU()

#
#FR_21630 Sinopsis: Se calculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas.
#
function calcularResuTiempoOptimoAcumulado_PaginaEjecutada { 
	varCierreOptimo=0
	indOptimo=$((${numeroPaginasUsadasProceso[$ejecutandoinst]}))
	until [[ $varCierreOptimo -eq 1 ]]; do 
#FR_21640Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
			if [[ ${paginasDefinidasTotal[$ejecutandoinst,$indOptimo]} -eq $primera_pagina ]]; then
#FR_21650Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				varCierreOptimo=1
			fi
		else
#FR_21660Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
			varCierreOptimo=1
		fi
		indOptimo=$(($indOptimo + 1)) 
	done
}

#
#FR_21670 Sinopsis: Se calculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas.
#
function calcularResuTiempoOptimoAcumulado_PaginaNoEjecutada { 
	varCierreOptimo=0
#	indOptimo=$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))
	indOptimo=$((${numeroPaginasUsadasProceso[$ejecutandoinst]}))
	until [[ $varCierreOptimo -eq 1 ]]; do 
#FR_21690Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
			if [[ ${paginasDefinidasTotal[$ejecutandoinst,$indOptimo]} -eq ${paginasEnMemoriaProceso[$indMarcoRec]} ]]; then
#FR_2170Se inicializa la variable de fichero de datos
				varCierreOptimo=1
			fi
		else
#FR_21710Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
			varCierreOptimo=1
		fi
		indOptimo=$(($indOptimo + 1)) 
	done
}

#
#FR_21720 Sinopsis: Se calculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas.
#
function gestionAlgoritmoPagAlgPagRecNRU_Referenciado_Modificado { 
#FR_21730Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_clases_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		tiempoPag=$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))
#FR_21740Con cambio de página por fallo de página ($usoMismaPagina=1) y, por tanto, sólo para esa página. El fallo sobre un marco sólo puede producir clases 0 o 1.
#FR_21750Se define como página usada o modificada
#FR_21760Se reinicia la clase a NO referenciada-NO modificada para recalcular después la clase correcta.
#FR_21770Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#FR_21780NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#FR_21790NO referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
			fi
		fi

#FR_2180Se inicializa la variable de fichero de rangos
#FR_21810Se define como página no usada ni modificada
			if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#FR_21820NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_21830Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#FR_21840SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_21850Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#FR_21860SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_21870Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#FR_21880Si lleva mucho tiempo como clase 3, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#FR_21890SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_2190Se inicializa la variable de fichero de rangos amplios
			fi
		fi

#FR_21910Con uso de página, pero sin cambio por fallo de página ($usoMismaPagina=0), ya que se deben actualizar las clases de todas las páginas.
#FR_21920Se define como página usada o modificada
			if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#FR_21930Referencia a una página ya ejecutada en una unidad de reloj anterior, dato copiado en todas las páginas de una unidad de tiempo a la siguiente, antes de analizar lo que ocurrirá en el tiempo actual.
#FR_21940NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_21950Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#FR_21960Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#FR_21970SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_21980Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				fi
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
				if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$1,$(($tiempoPag - 1))]} -eq 0 ]]; then 
#FR_21990NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
#FR_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
#FR_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
#FR_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
				fi
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#FR_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
#FR_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
#FR_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
				elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$1,$(($tiempoPag - 1))]} -eq 1 ]]; then 
#FR_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
#FR_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
#FR_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
#FR_22100SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_22110Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#FR_22120Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#FR_22130NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_22140Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				fi
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
				if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$1,$(($tiempoPag - 1))]} -eq 0 ]]; then 
#FR_22150SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_22160Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$1,$(($tiempoPag - 1))]} -eq 1 ]]; then 
#FR_22170SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_22180Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#FR_22190Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#FR_22200SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_22210Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#FR_22220Si ya era de clase 3 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#FR_22230Si lleva mucho tiempo como clase 3, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#FR_22240SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_22250Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				fi
			fi 
		fi
		
#FR_22260Con uso, pero sin cambio de página ($usoMismaPagina=1), ya que se deben actualizar las clases de todas las páginas.
#FR_22270Se define como página no usada ni modificada
			if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#FR_22280NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_22290Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#FR_22300SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_22310Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#FR_22320SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_22330Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#FR_22340Si lleva mucho tiempo como clase 3, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#FR_22350SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_22360Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			fi
		fi
#FR_22370Si el tiempo ordinal de una página en una clase 2 o 3 en los últimos instantes (intervalo de tiempo) es superior al límite ($seleccionAlgoritmoPaginacion_clases_valor) se modifica a "no referenciado" y luego se calcula la nueva clase.
#FR_22380 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor. Si lo supera se comprueba que no sea en la misma clase 2 o 3.
#FR_22390Si ya era de clase 2 se pasa a clase 0.
#FR_22400Si lleva mucho tiempo como clase 2, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#FR_22410SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_22420Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			fi
#FR_22430Si ya era de clase 3 se pasa a clase 1.
#FR_22440Si lleva mucho tiempo como clase 2, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#FR_22450SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#FR_22460Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			fi
		fi
#FR_22470		echo ""
    done
#FR_22480Fin de gestionAlgoritmoPagAlgPagRecNRU_Referenciado_Modificado()

#
#FR_22490 Sinopsis: Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#
function gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Max_Prueba { 
	for (( indMaxPrueba=0; indMaxPrueba<${memoria[$ejecutandoinst]}; indMaxPrueba++ )); do
#FR_22500Localiza en qué posición encuentra la página.
#FR_22510Mayor antigüedad de uso encontrada.
#FR_22520Posición del marco con la mayor antigüedad de uso.
		fi
#FR_22530Y sobre esa localización se hace el fallo de página.
}

#
#FR_22540 Sinopsis: Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#
function gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Max {  
#FR_22550Para determinar si hay alguna página de clase 0, y de no ser así, de clase 1,...
	xxx_1=0
	xxx_2=0
	xxx_3=0
#FR_22560Mayor frecuencia encontrada en las páginas de clase 0.
#FR_22570Mayor frecuencia encontrada en las páginas de clase 1.
#FR_22580Mayor frecuencia encontrada en las páginas de clase 2.
#FR_22590Mayor frecuencia encontrada en las páginas de clase 3.
#FR_22600Posición del marco con la mayor frecuencia en las páginas de clase 0.
#FR_22610Posición del marco con la mayor frecuencia en las páginas de clase 1.
#FR_22620Posición del marco con la mayor frecuencia en las páginas de clase 2.
#FR_22630Posición del marco con la mayor frecuencia en las páginas de clase 3.

#FR_22640Se calculan los max para las 4 clases
#FR_22650Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
		if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMax,$punteroPagMarco]} -eq 0 ]]; then
#FR_22660Localiza en qué posición encuentra la página.
#FR_22670Mayor frecuencia encontrada.
#FR_22680Posición del marco con la mayor frecuencia.
#FR_22690Sólo se marca en caso de que haya cambio de max. De no ser así, no se marca y tampoco se cambia la variable max_AlgPagFrecRec_FrecRec ni max_AlgPagFrecRec_Position
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMax,$punteroPagMarco]} -eq 1 ]]; then
#FR_22700Localiza en qué posición encuentra la página.
#FR_22710Mayor frecuencia encontrada.
#FR_22720Posición del marco con la mayor frecuencia.
				xxx_1=1
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMax,$punteroPagMarco]} -eq 2 ]]; then
#FR_22730Localiza en qué posición encuentra la página.
#FR_22740Mayor frecuencia encontrada.
#FR_22750Posición del marco con la mayor frecuencia.
				xxx_2=1
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMax,$punteroPagMarco]} -eq 3 ]]; then
#FR_22760Localiza en qué posición encuentra la página.
#FR_22770Mayor frecuencia encontrada.
#FR_22780Posición del marco con la mayor frecuencia.
				xxx_3=1
			fi
		fi
#FR_22790Y sobre esa localización se hace el fallo de página
	if [[ $xxx_0 -eq 1 && $xxx_1 -eq 0 && $xxx_2 -eq 0 && $xxx_3 -eq 0 ]]; then
#FR_22800Mayor frecuencia encontrada.
#FR_22810Posición del marco con la mayor frecuencia.
	elif [[ $xxx_1 -eq 1 && $xxx_2 -eq 0 && $xxx_3 -eq 0 ]]; then
#FR_22820Mayor frecuencia encontrada.
#FR_22830Posición del marco con la mayor frecuencia.
	elif [[ $xxx_2 -eq 1 && $xxx_3 -eq 0 ]]; then
#FR_22840Mayor frecuencia encontrada.
#FR_22850Posición del marco con la mayor frecuencia.
	elif [[ $xxx_3 -eq 1 ]]; then
#FR_22860Mayor frecuencia encontrada.
#FR_22870Posición del marco con la mayor frecuencia.
	fi
#FR_22880Fin de gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Max()

#
#FR_22890 Sinopsis: Se calcula el mínimo de las frecuencias de las páginas de cada proceso en NFU (min_AlgPagFrecRec_FrecRec y min_AlgPagFrecRec_Position), por clases empezando por 0.
#
function gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Min_Prueba { 
	for (( indMinPrueba=0; indMinPrueba<${memoria[$ejecutandoinst]}; indMinPrueba++ )); do
#FR_22900Localiza en qué posición encuentra la página.
#FR_22910Mayor antigüedad de uso encontrada.
#FR_22920Posición del marco con la menor antigüedad de uso.
		fi
	done
}

#
#FR_22930 Sinopsis: Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#
function gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Min {  
#FR_22940Para determinar si hay alguna página de clase 0, y de no ser así, de clase 1,...
	xxx_1=0
	xxx_2=0
	xxx_3=0
#FR_22950Menor frecuencia encontrada en las páginas de clase 0.
#FR_22960Menor frecuencia encontrada en las páginas de clase 1.
#FR_22970Menor frecuencia encontrada en las páginas de clase 2.
#FR_22980Menor frecuencia encontrada en las páginas de clase 3.
#FR_22990Posición del marco con la menor frecuencia en las páginas de clase 0.
#FR_230 seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#FR_230 seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#FR_230 seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.

#FR_230 seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#FR_230 seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
		if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMin,$punteroPagMarco]} -eq 0 ]]; then
			if [[ $min_AlgPagFrecRec_FrecRec_0 -eq -1 ]]; then
				min_AlgPagFrecRec_FrecRec_0=${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMin]}
				min_AlgPagFrecRec_Position_0=$indMin
#FR_230 seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
			fi
#FR_230 seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#FR_230 seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#FR_230 seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMin,$punteroPagMarco]} -eq 1 ]]; then
			if [[ $min_AlgPagFrecRec_FrecRec_1 -eq -1 ]]; then
				min_AlgPagFrecRec_FrecRec_1=${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMin]}
				min_AlgPagFrecRec_Position_1=$indMin
				xxx_1=1
			fi
#FR_230 seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#FR_23100Menor frecuencia encontrada.
#FR_23110Posición del menor con la mayor frecuencia.
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMin,$punteroPagMarco]} -eq 2 ]]; then
			if [[ $min_AlgPagFrecRec_FrecRec_2 -eq -1 ]]; then
				min_AlgPagFrecRec_FrecRec_2=${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMin]}
				min_AlgPagFrecRec_Position_2=$indMin
				xxx_2=1
			fi
#FR_23120Localiza en qué posición encuentra la página.
#FR_23130Menor frecuencia encontrada.
#FR_23140Posición del marco con la menor frecuencia.
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMin,$punteroPagMarco]} -eq 3 ]]; then
			if [[ $min_AlgPagFrecRec_FrecRec_3 -eq -1 ]]; then
				min_AlgPagFrecRec_FrecRec_3=${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMin]}
				min_AlgPagFrecRec_Position_3=$indMin
				xxx_3=1
			fi
#FR_23150Localiza en qué posición encuentra la página.
#FR_23160Menor frecuencia encontrada.
#FR_23170Posición del marco con la menor frecuencia.
			fi
		fi
#FR_23180Y sobre esa localización se hace el fallo de página
	if [[ $xxx_0 -eq 1 && $xxx_1 -eq 0 && $xxx_2 -eq 0 && $xxx_3 -eq 0 ]]; then
#FR_23190Menor frecuencia encontrada.
#FR_23200Posición del marco con la menor frecuencia.
	elif [[ $xxx_1 -eq 1 && $xxx_2 -eq 0 && $xxx_3 -eq 0 ]]; then
#FR_23210Menor frecuencia encontrada.
#FR_23220Posición del marco con la menor frecuencia.
	elif [[ $xxx_2 -eq 1 && $xxx_3 -eq 0 ]]; then
#FR_23230Menor frecuencia encontrada.
#FR_23240Posición del marco con la menor frecuencia.
	elif [[ $xxx_3 -eq 1 ]]; then
#FR_23250Menor frecuencia encontrada.
#FR_23260Posición del marco con la menor frecuencia.
	fi

#FR_23270Fin de gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Min()

#
#FR_23280 Sinopsis: Impresión pantalla tras la solicitud de datos/introducción desde fichero
#
function dibujaDatosPantallaFCFS_SJF_SRPT_RR {
#FR_23290...color
    echo -e " ┌───────────────┬───────────────┬───────────────┬───────────────┐" | tee -a $informeConColorTotal 
    echo -e " │    Proceso$NC    │  T.Llegada$NC    │  T.Ejecución$NC  │    Tamaño$NC     │" | tee -a $informeConColorTotal 
    echo -e " └───────────────┴───────────────┴───────────────┴───────────────┘" | tee -a $informeConColorTotal 
    for (( i=0; i<$nprocesos; i++)); do
        echo -e "${coloress[$i % 6]} \t${proceso[$i]}\t \t${entradaAuxiliar[$i]}\t \t${ejecucion[$i]}\t \t${memoriaAuxiliar[$i]}\t  $NC" | tee -a $informeConColorTotal
    done 
    echo -e "\n\n Memoria total: $mem_libre uds." | tee -a $informeConColorTotal
#FR_23300Se ejecuta cuando la selección inicial es por ejecución automática repetitiva. Se guardan todos los datos, aún cuando no es por Round-Robin.
		echo " Tamaño a partir del cual se reubica: $variableReubicar uds." | tee -a $informeConColorTotal 
	fi
#FR_23310Se ejecuta cuando la selección inicial es por ejecución automática repetitiva. Se guardan todos los datos, aún cuando no es por Round-Robin.
		echo " Quantum de tiempo para Round-Robin (RR): $quantum" | tee -a $informeConColorTotal 
	fi
    echo " ---------------------------------------------" | tee -a $informeConColorTotal 
   
#FR_23320...b/n
    echo -e " ┌───────────────┬───────────────┬───────────────┬───────────────┐" >> $informeSinColorTotal
    echo -e " │    Proceso    │  T.Llegada    │  T.Ejecución  │    Tamaño     │" >> $informeSinColorTotal
    echo -e " └───────────────┴───────────────┴───────────────┴───────────────┘" >> $informeSinColorTotal
    for (( i=0; i<$nprocesos; i++)); do
        echo -e " \t${proceso[$i]}\t \t${entradaAuxiliar[$i]}\t \t${ejecucion[$i]}\t \t${memoriaAuxiliar[$i]}\t  " >> $informeSinColorTotal
    done
    echo -e "\n\n Memoria total: $mem_libre uds." >> $informeSinColorTotal
#FR_23330Se ejecuta cuando la selección inicial es por ejecución automática repetitiva. Se guardan todos los datos, aún cuando no es por Round-Robin.
		echo -e " Tamaño a partir del cual se reubica: $variableReubicar uds." >> $informeSinColorTotal
	fi
#FR_23340Se ejecuta cuando la selección inicial es por ejecución automática repetitiva. Se guardan todos los datos, aún cuando no es por Round-Robin.
		echo -e " Quantum de tiempo para Round-Robin (RR): $quantum uds." >> $informeSinColorTotal
	fi
    echo -e  " ---------------------------------------------" >> $informeSinColorTotal
#FR_23350No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -e "\n$NC Pulse enter para continuar..." | tee -a $informeConColorTotal
		echo -e "\n Pulse enter para continuar..." >> $informeSinColorTotal
		read enter
		echo -e $enter "\n" >> $informeConColorTotal
		echo -e $enter "\n" >> $informeSinColorTotal
	fi
#FR_23360    clear
}

#
#FR_23370 Sinopsis: Muestra un resumen inicial ordenado por tiempo de llegada de todos los procesos introducidos.
#
function dibujaDatosPantallaPrioridad {
#FR_23380	ordenacion
#FR_23390Se ordenan los datos sacados desde $ficheroParaLectura o a medida que se van itroduciendo, por tiempo de llegada.
#FR_23400...color
    echo -e " ┌───────────────┬───────────────┬───────────────┬───────────────┬───────────────┐" | tee -a $informeConColorTotal 
    echo -e " │    Proceso$NC    │  T.Llegada$NC    │  T.Ejecución$NC  │    Tamaño$NC     │   Prioridad$NC   │" | tee -a $informeConColorTotal 
    echo -e " └───────────────┴───────────────┴───────────────┴───────────────┴───────────────┘" | tee -a $informeConColorTotal 
    for (( i=0; i<$nprocesos; i++)); do
        echo -e "${coloress[$i % 6]} \t${proceso[$i]}\t \t${entradaAuxiliar[$i]}\t \t${ejecucion[$i]}\t \t${memoriaAuxiliar[$i]}\t \t${prioProc[$i]}\t  $NC" | tee -a $informeConColorTotal
    done
    echo -e "\n\n Memoria total: $mem_libre uds." | tee -a $informeConColorTotal
    echo " Tamaño a partir del cual se reubica: $variableReubicar uds." | tee -a $informeConColorTotal 
    echo " ---------------------------------------------" | tee -a $informeConColorTotal 
   
#FR_23410...b/n
    echo -e " ┌───────────────┬───────────────┬───────────────┬───────────────┬───────────────┐" >> $informeSinColorTotal
    echo -e " │    Proceso    │  T.Llegada    │  T.Ejecución  │    Tamaño     │   Prioridad   │" >> $informeSinColorTotal
    echo -e " └───────────────┴───────────────┴───────────────┴───────────────┴───────────────┘" >> $informeSinColorTotal
    for (( i=0; i<$nprocesos; i++)); do
        echo -e " \t${proceso[$i]}\t \t${entradaAuxiliar[$i]}\t \t${ejecucion[$i]}\t \t${memoriaAuxiliar[$i]}\t \t${prioProc[$i]}\t  " >> $informeSinColorTotal
    done
    echo -e "\n\n Memoria total: $mem_libre uds." >> $informeSinColorTotal
    echo -e " Tamaño a partir del cual se reubica: $variableReubicar uds." >> $informeSinColorTotal
    echo -e  " ---------------------------------------------" >> $informeSinColorTotal
#FR_23420No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -e "\n$NC Pulse enter para continuar..." | tee -a $informeConColorTotal
		echo -e "\n Pulse enter para continuar..." >> $informeSinColorTotal
		read enter
		echo -e $enter "\n" >> $informeConColorTotal
		echo -e $enter "\n" >> $informeSinColorTotal
	fi
#FR_23430    clear
#FR_23440Fin de imprimeprocesosresumen

#
#FR_23450 Sinopsis: Genera la Banda de Memoria y la muestra en pantalla/informe 
#
function dibujaResumenBandaMemoriaMarcosPagina { 
#FR_23460Ancho del terminal para adecuar el ancho de líneas a cada volcado
#FR_23470Para poder incluir -clase en la página. Se restan 3 porque previamente se ha añadido la logitud $digitosUnidad, y ya venía incluido.
#FR_23480Desde 0, es el ordinal del número de marcos en memoria asociados a cada proceso (Índices:Proceso)
		ordinalMarcosProcesoDibujados[$indProc]=-1	
	done
    echo ""
#FR_23490Se inicializan las variables.
	AlgPagFrecUsoRecNotas1=();
	AlgPagFrecUsoRecNotas2=();
	filaAlgPagFrecUsoRecTituloColor=""
	filaAlgPagFrecUsoRecTituloBN=""
	filaAlgPagFrecUsoRecNotas1Color=""
	filaAlgPagFrecUsoRecNotas1BN=""
	
#FR_23500Si hay algún proceso en memoria. ResuUsoRecienteAcumulado
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

#FR_23510 GENERACIÓN STRING DE PROCESOS (Línea 1 del Resumen de la Banda de Memoria)
#FR_23520Define el número de saltos a realizar.
#FR_23530Contiene el texto a escribir de las diferentes filas antes de hacer cada salto.
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
#FR_23540Determina el número de procesos al contar el número de datos en la variable memoria.
#FR_23550Índice que recorre los procesos del problema
#FR_23560Determina qué procesos están en memoria.
#FR_23570Páginas residentes en memoria del Proceso en ejecución. Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#FR_23580Deja 1 de margen izquierdo y 7 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.

# Variable que indica si se ha añadido un proceso al Resumen de la Banda de Memoria. ${memoria[$procFinalizado]}
    for ((indMem=0;indMem<$mem_total;indMem++)); do
#FR_23600 El proceso se puede imprimir en memoria
#FR_23610 El texto no cabe en la terminal
#FR_23620 Se pasa a la siguiente línea
				filaprocesosColor[$aux]="        "
				filaprocesosBN[$aux]="        "
#FR_23630Espacio por la izquierda para cuadrar líneas
            fi
#FR_23640 El texto no cabe en la terminal
                xx=0
            fi
#FR_23650 Se añade el proceso a la banda
#proceso[$((${unidMemOcupadas[$indMem]}))]}))}
				filaprocesosBN[$aux]+=`echo -e "${proceso[$((${unidMemOcupadas[$indMem]}))]}""$espaciosfinal "`
				filaprocesosColor[$aux]+=`echo -e "${coloress[${unidMemOcupadas[$indMem]} % 6]}${proceso[$((${unidMemOcupadas[$indMem]}))]}""$NORMAL$espaciosfinal "`
                numCaracteres2=$(($numCaracteres2 + $anchoColumna))
                xx=1
            else
#FR_23670 El texto no cabe en la terminal
#FR_23680 Se pasa a la siguiente línea
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
#FR_23690 El texto no cabe en la terminal
#FR_23700 Se pasa a la siguiente línea
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

#FR_23710 GENERACIÓN STRING DE MARCOS (Línea 2 del Resumen de Memoria)
#FR_23720Define el número de saltos a realizar.
#FR_23730Deja 1 de margen izquierdo y 7 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
	textoFallo1="M"
	textoFallo2="-F"
	for ((indMem=0;indMem<$mem_total;indMem++)); do
#FR_23740 El texto no cabe en la terminal
#FR_23750 Se pasa a la siguiente línea
			filamarcosColor[$aux]="        "
			filamarcosBN[$aux]="        "
#FR_23760Espacio por la izquierda para cuadrar líneas
		fi
		if [[ ${unidMemOcupadas[$indMem]} != "_" ]]; then	
#FR_23770Contendrá el código de subrayado con para subrayar la referencia del marco sobre el que se produciría el siguiente fallo de página.
#FR_23780Contendrá el código de negrita para la referencia del marco sobre el que se habría producido el fallo de página.
#FR_23790Ordinal del marco usado (Puntero - De 0 a n) para el Proceso en ejecución en una unidad de Tiempo.
#FR_23800Negrita - Marcos donde se produjeron Fallos de Página del Proceso en ejecución.
#FR_23810Marco real correspondiente al ordinal de un marco.
#FR_23820Marco real correspondiente al ordinal de un marco.
#FR_23830Si coincide el marco real al ordinal del marco usado, se define el color del fondo.
				varImprimirSiguiente="\e[4m"
			fi
#FR_23840Si coincide el marco real al ordinal del marco con fallo, se define el código de negrita.
				varImprimirFallo="\e[1m"
			fi
#FR_23850Si ese marco NO será sobre el que se produzca el siguiente fallo de página
#FR_23860Espacios por defecto. Se quita 1 por la M.
				filamarcosColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}$varImprimirSiguiente$textoFallo1$indMem$NC$espaciosfinal "`
				filamarcosBN[$aux]+=`echo -e "M$indMem$espaciosfinal "`
#FR_23870Si el marco será sobre el que se produzca el siguiente fallo de página
#FR_23880Se quita 1 por la M, y 2 por "-F".
				filamarcosColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}$varImprimirSiguiente$varImprimirFallo$textoFallo1$indMem$textoFallo2$NC$espaciosfinal "`
				filamarcosBN[$aux]+=`echo -e "M$indMem$textoFallo$espaciosfinal "`
			fi 
		else
#FR_23890Espacios por defecto. Se quita 1 por la M.
			filamarcosColor[$aux]+=`echo -e $NORMAL"$textoFallo1$indMem$espaciosfinal "`
			filamarcosBN[$aux]+=`echo -e "$textoFallo1$indMem$espaciosfinal "`
		fi 
		numCaracteres2=$(($numCaracteres2 + $anchoColumna))
	done

#FR_23900 GENERACIÓN STRING DE PÁGINAS (Línea 3 del Resumen de la Banda de Memoria)
#FR_23910 Línea de la banda
    numCaracteres2=10
    guionesAMeter=${varguiones:1:$(($anchoColumna - 2))}
    asteriscosAMeter=${varasteriscos:1:$(($anchoColumna - 2))}
    sumaTotalMemoria=0
#FR_23920Contador que recorrerá el número de marcos asociados a un proceso y determinar el ordinal que le corresponde.
#FR_23930 Variable que indica si se ha añadido un proceso a la banda
    for (( i=0; i<$nprocesos; i++)); do 
#FR_23940Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
	done
#unidMemOcupadas[$indMem] da el Proceso que ocupa el marco indMem
#FR_23960Contendrá el ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo.
#FR_23970 El texto no cabe en la terminal
#FR_23980 Se pasa a la siguiente línea
			filapagBN[$aux]="        "
			filapagColor[$aux]="        "
			numCaracteres2=8
		fi
#FR_23990Contendrá la clase de la página en NFU/NRU con clases.
#FR_240 seleccionAlgoritmoPaginacion_frecuencia_valor - Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
		espaciosadicionales=0
#FR_240 seleccionAlgoritmoPaginacion_frecuencia_valor - Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
#paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}))}
#FR_240 seleccionAlgoritmoPaginacion_frecuencia_valor - Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
#FR_240 seleccionAlgoritmoPaginacion_frecuencia_valor - Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
#FR_240 seleccionAlgoritmoPaginacion_frecuencia_valor - Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
#FR_240 seleccionAlgoritmoPaginacion_frecuencia_valor - Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
			fi
#FR_240 seleccionAlgoritmoPaginacion_frecuencia_valor - Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
				varImprimirUsado=${colorfondo[${unidMemOcupadas[$indMem]} % 6]}
			fi
#FR_240 seleccionAlgoritmoPaginacion_frecuencia_valor - Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
#paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}))}
				filapagBN[$aux]+=`echo -e "${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$espaciosasteriscofinal "`
				filapagColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$espaciosasteriscofinal$NC "`
#FR_24100Y si hay página se mete espacios y el número.
#FR_24110FIFO y Reloj con Segunda oportunidad
#FR_24120Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso. Se busca el ordinal usado en ese instante porque sería el utilizado para la búsqueda de los coeficientes M en todos los marcos al ser el mayor número.
					datoM="-"${coeficienteSegOp[$ejecutandoinst,${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$punteroPagMarco]}	
#FR_24130datoM}

#FR_24140Óptimo
#FR_24150Índices: (proceso, marco, reloj).
#FR_24160dato4}
#FR_24170Contendrá la clase de la página en NFU/NRU con clases.
#FR_24180Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_24190Índices: (proceso, marco, número ordinal de la dirección a ejecutar(número de páginas usadas del proceso)).
#FR_24200dato4}
				fi
#FR_242102 por el tamaño de $datos4
#FR_24220Si el marco NO ha sido usado en el instante actual
					filapagBN[$aux]+=`echo -e "${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$dato4$datoM$espaciosfinal "`
					filapagColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$dato4$datoM$espaciosfinal$NC "`
#FR_24230Si el marco ha sido usado en el instante actual
					filapagBN[$aux]+=`echo -e "${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$dato4$datoM$espaciosfinal "`
					filapagColor[$aux]+=`echo -e "$NC$varImprimirUsado${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$dato4$datoM$espaciosfinal$NC "`
				fi
			fi
#FR_24240Número de Marcos con Páginas ya dibujadas de cada Proceso.
            numCaracteres2=$(($numCaracteres2 + $anchoColumna))
            if [[ $indMem -ne 0 ]]; then
                if [[ ${unidMemOcupadas[$((indMem - 1))]} !=  "_" ]]; then 
                    if [[ $xx -eq 1 && ${proceso[$((${unidMemOcupadas[$indMem]}))]} != ${proceso[$((${unidMemOcupadas[$((indMem - 1))]}))]} ]]; then
                        xx=0
                    fi
                fi
            fi
#FR_24250Sin proceso asignado al marco
            xx=0
#paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}))}
            filapagBN[$aux]+=`echo -e "$espaciosguionfinal "`
            filapagColor[$aux]+=`echo -e "$NC$espaciosguionfinal$NC "`
            numCaracteres2=$(($numCaracteres2 + $anchoColumna))
        fi
#FR_24270Aumenta el contador de marcos (ordinal de marcos distinto para cada proceso=
    done

#FR_24280 GENERACIÓN STRING DE FRECUENCIA/USO RECIENTE DE USO DE LAS PÁGINAS (Línea 4 del Resumen de la Banda de Memoria)  
#FR_24290 Línea de la frecuencia
    numCaracteres2=10
    guionesAMeter=${varguiones:1:$(($anchoColumna - 2))}
    asteriscosAMeter=${varasteriscos:1:$(($anchoColumna - 2))}
    sumaTotalMemoria=0
#FR_24300 Variable que indica si se ha añadido un proceso a la banda
    for (( i=0; i<$nprocesos; i++)); do 
#FR_24310Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
	done			
    for ((indMem=0;indMem<$mem_total;indMem++)); do
#FR_24320 El texto no cabe en la terminal
#FR_24330 Se pasa a la siguiente línea
			filaAlgPagFrecUsoRecBN[$aux]="        "
			filaAlgPagFrecUsoRecColor[$aux]="        "
			numCaracteres2=8
		fi
#FR_24340 El proceso se puede imprimir en memoria
#FR_24350Si no hay página se mete asterisco por ser frecuencia 0.
				espaciosasteriscofinal="*"${varhuecos:1:$(($anchoColumna - 2))}
				filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "$espaciosasteriscofinal "`
				filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}$espaciosasteriscofinal$NC "`
#FR_24360Y si hay página se mete espacios y el número.
				dato5=""
				dato6=""
				espaciosadicionales1=0
				espaciosadicionales2=0
#FR_24370Contendrá la clase de la página en NFU/NRU con clases.
#FR_24380Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_24390Índices: (proceso, marco)).
#FR_24400dato5}
#FR_24410Índices: (proceso, número ordinal del marco usado para ese proceso comenzando por 0).
#FR_24420dato6}
				fi 
#FR_24430Desde 0, es el ordinal del número de marcos en memoria asociados a cada proceso (Índices:Proceso)
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
#FR_24470Número de Marcos con Páginas ya dibujadas de cada Proceso.
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

#FR_24490 GENERACIÓN STRING DE FALLOS TOTALES POR PROCESO
#FR_24500Total de Fallos de Página del Proceso en el instante actual

#FR_24510 IMPRIMIR LAS 4 LÍNEAS DE LA BANDA DE MEMORIA (COLOR y BN a pantalla y ficheros)
#FR_24520Si hay algún proceso en memoria.
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

#FR_24530Se vacía el auxiliar que reubica la memoria.
#FR_24540Borramos los datos de la auxiliar
        unidMemOcupadasAux[$ca]="_"
    done
#FR_24550Se vacían bloques
#FR_24560Borramos los datos de la auxiliar
         bloques[$ca]=0
    done
#FR_24570Se vacían las posiciones
    nposiciones=0
#FR_24580Se vacían posiciones iniciales y finales para borrar elementos innecesarios
    for (( i=0; i<$nposiciones; i++ )) ; do
         inicialNCmodelo[$i]=0
    done
    for (( i=0; i<$nposiciones; i++ )) ; do 
         finalNCmodelo[$i]=0
    done
#FR_24590Fin de la nueva versión de dibujaResumenBandaMemoriaMarcosPagina

#
# Sinopsis: Muestra los fallos de paginación por AlgPagFrecUsoRec al acabar un proceso.  ${coloress[${unidMemOcupadas[$ii]} % 6]}
#
#  proceso[$po]  ${unidMemOcupadas[$ii]}  nproceso ejecutandoinst numeroproceso
    numCaracteres2Inicial=12
    Terminal=$((`tput cols`)) 
	if [[ $seleccionAlgoritmoPaginacion -eq 2 || $seleccionAlgoritmoPaginacion -eq 4 || $seleccionAlgoritmoPaginacion -eq 7 || $seleccionAlgoritmoPaginacion -eq 8 || $seleccionAlgoritmoPaginacion -eq 14 || $seleccionAlgoritmoPaginacion -eq 15 ]]; then 
#FR_24620Para poder incluir -clase en la página. Se restan 3 porque previamente se ha añadido la logitud $digitosUnidad, y ya venía incluido.
#FR_24630MFU/LFU con clases 
#FR_24640Para poder incluir -clase en la página. Se restan 3 porque previamente se ha añadido la logitud $digitosUnidad, y ya venía incluido.
    else
		anchoColumna=$((8 + $digitosUnidad - 3))
    fi
#FR_24650Se inicializan las variables.
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

#FR_24660 GENERACIÓN STRING DE RELOJ (Línea 1 del Resumen de Fallos de Paginación)
#FR_24670Define el número de saltos a realizar.
	filatiempoColor[$aux]="\n$NC Tiempo     "
	filatiempoBN[$aux]="\n Tiempo     "
#FR_24680Deja 1 de margen izquierdo y 11 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
#FR_24690Índice
	iiSiguiente=0
	for ((counter=0;counter<${ejecucion[$procFinalizado]};counter++)); do
		for ((ii=$iiSiguiente;ii<$reloj;ii++)); do
#FR_24700 El texto no cabe en la terminal
#FR_24710 Se pasa a la siguiente línea
				filatiempoColor[$aux]="\n            "
				filatiempoBN[$aux]="\n            "
#FR_24720Espacio por la izquierda para cuadrar líneas
			fi
			if [[ ${ResuTiempoProceso[$ii]} -eq $procFinalizado ]]; then
#FR_24730ii}))}
				filatiempoColor[$aux]+=`echo -e "$NORMAL""$ii$espaciosfinal$NORMAL "`
				filatiempoBN[$aux]+=`echo -e "$ii$espaciosfinal "`
#FR_24740Para que no se repitan los datos en cada ciclo al no empezar desde 0.
				numCaracteres2=$(($numCaracteres2 + $anchoColumna + 1))
			fi
		done
	done

#FR_24750 GENERACIÓN STRING DE PÁGINAS (Línea 2 del Resumen de Fallos de Paginación)
#FR_24760Define el número de saltos a realizar. paginasDefinidasTotal  (Índices:Proceso, Páginas).
	filapagColor[$aux]="$NC Página     "
	filapagBN[$aux]=" Página     "
#FR_24770Deja 1 de margen izquierdo y 11 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
	iiSiguiente=0
	varCierre=0
	for ((counter=0;counter<${ejecucion[$procFinalizado]};counter++)); do
		for ((ii=$iiSiguiente;ii<$reloj;ii++)); do
#FR_24780 El texto no cabe en la terminal
#FR_24790 Se pasa a la siguiente línea
				filapagColor[$aux]="            "
				filapagBN[$aux]="            "
#FR_24800Espacio por la izquierda para cuadrar líneas
			fi
#FR_24810Evita qe queden elementos definidos de ejecuciones anteriores por las que sake un número al final de la línea en una nueva columna que, teóricamente no existe.
				varCierre=$(($varCierre + 1))
#paginasDefinidasTotal[$procFinalizado,$ii]}))}
				filapagColor[$aux]+=`echo -e "$NORMAL""${paginasDefinidasTotal[$procFinalizado,$ii]}$espaciosfinal$NORMAL "`
				filapagBN[$aux]+=`echo -e "${paginasDefinidasTotal[$procFinalizado,$ii]}$espaciosfinal "`
				numCaracteres2=$(($numCaracteres2 + $anchoColumna + 1))
#FR_24830Para que no se repitan los datos en cada ciclo al no empezar desde 0.
			fi
		done
	done

#FR_24840 GENERACIÓN STRING DE Página-Frecuencia-Uso Reciente-Clase (Líneas de Marcos del Resumen de Fallos de Paginación)
#FR_24850Bucle que recorre la ejecución del proceso finalizado a lo largo del tiempo para generar las variables con los datos a usar en la impresión del resumen.
#FR_24860Define el número de saltos a realizar.
#FR_24870Se considera que los números de marcos, páginas y frecuencias no superarán los tres dígitos.
#FR_24880"$NC Marco-Pág-Frec/UsoRec "
#FR_24890" Marco-Pág-Frec/UsoRec "
#FR_2490La opción -a lo crea inicialmente
		iiSiguiente=0
		for ((counter=0;counter<${ejecucion[$procFinalizado]};counter++)); do
			for ((ii=$iiSiguiente;ii<$reloj;ii++)); do
#FR_24910Si el proceso que se ejecuta en un instante es el finalizado...
#FR_24920 El texto no cabe en la terminal
#FR_24930 Se pasa a la siguiente línea
						filaAlgPagFrecUsoRecColor[$k,$aux]="            "
						filaAlgPagFrecUsoRecBN[$k,$aux]="            "
#FR_24940Espacio por la izquierda para cuadrar líneas
					fi
#FR_24950Índices: (proceso, tiempo, número ordinal de marco). Dato del marco real que corresponde al ordinal
#FR_24960Índices: (proceso, marco, tiempo). Dato de la página contenida en el marco
					if ([[ $seleccionAlgoritmoPaginacion -ge 0 && $seleccionAlgoritmoPaginacion -le 4 ]]) || ([[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 9 ]]); then
#FR_24970Índices: (proceso, marco, tiempo). Dato de la frecuencia de uso de la página contenida en el marco
					elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#FR_24980Índices: (proceso, marco, tiempo). Dato del Tiempo que hace que se usó la página contenida en el marco
					elif [[ $seleccionAlgoritmoPaginacion -ge 10 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
						dato3=${ResuFrecuenciaAcumulado[$procFinalizado,$k,$ii]}
						if [[ $dato3 -ge $seleccionAlgoritmoPaginacion_clases_frecuencia_valor ]]; then
#FR_24990Índices: (proceso, marco, tiempo). Dato del Tiempo que hace que se usó la página contenida en el marco
						fi
					elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 15 ]]; then
#FR_250 VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
					elif [[ $seleccionAlgoritmoPaginacion -ge 16 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
						dato3=${ResuUsoRecienteAcumulado[$procFinalizado,$k,$ii]}
						if [[ $dato3 -ge $seleccionAlgoritmoPaginacion_clases_uso_rec_valor ]]; then
#FR_250 VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
						fi
					fi
#FR_250 VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
#FR_250 VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
					if [[ $seleccionAlgoritmoPaginacion -eq 2 || $seleccionAlgoritmoPaginacion -eq 4 ]]; then
#FR_250 VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
#FR_250 VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
#FR_250 VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
							datostot="$dato1-$dato2-$dato3-$datoM"
#FR_250 VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
							datostot="$dato1"						
						fi
					elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#FR_250 VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
							datostot="$dato1-$dato2-$dato3"
						else
							datostot="$dato1"						
						fi
					elif [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then
#FR_250 VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
#FR_25100Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#FR_25110Resumen - Índices: (proceso, ordinal del tiempo de ejecución). Dato: Página modificada (1) o no modificada (0).
#FR_25120Índices: (proceso, marco, número ordinal de la dirección a ejecutar).
						fi
						datostot="$dato1-$dato2-$dato3-$dato4"
					elif [[ $seleccionAlgoritmoPaginacion -eq 0 ]] || [[ $seleccionAlgoritmoPaginacion -eq 1 ]] || [[ $seleccionAlgoritmoPaginacion -eq 3 ]] || ([[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 9 ]]) || ([[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 15 ]]); then
						datostot="$dato1-$dato2-$dato3"
					fi
#FR_25130datostot}))}
#FR_25140En lugar de generar diferentes opciones y comparativas, se generará una serie de variables con las modificaciones de formato.
#FR_25150Fondo de color - Marco usado (Puntero) para cada Proceso en cada unidad de Tiempo.
					if [[ $seleccionAlgoritmoPaginacion -ne 0 ]]; then
#FR_25160Subrayado - Marco (Puntero) sobre el que se produce el siguiente fallo para cada Proceso en cada unidad de Tiempo.
					fi
#FR_25170Negrita - Marcos donde se produjeron Fallos de Página del Proceso en ejecución.
					varImprimirUsado=""
					varImprimirSiguiente=""
					varImprimirFallo=""
#FR_25180Contendría el marco sobre el que se produce un fallo.
					if [[ ${varUsado} -eq $k ]]; then
						varImprimirUsado=${colorfondo[$procFinalizado % 6]}
					elif [[ ${varSiguiente} -eq $k && $seleccionAlgoritmoPaginacion -ne 0 ]]; then
						varImprimirSiguiente="\e[4m"
#FR_25190Si contiene algún dato (marco) es porque hay un fallo.
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
#FR_25200Para que no se repitan los datos en cada ciclo al no empezar desde 0.
			done
		done
	done

#FR_25210 GENERACIÓN STRING DE FALLOS (Líneas de Fallos del Resumen de Fallos de Paginación)
#FR_25220Define el número de saltos a realizar.
#FR_25230Es fijo porque sólo se va a escribir "F" o "-".
#FR_25240"$NC Marco-Pág-Frec/UsoRec "
#FR_25250" Marco-Pág-Frec/UsoRec "
#FR_25260Deja 1 de margen izquierdo y 12 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
	iiSiguiente=0
	for ((counter=0;counter<${ejecucion[$procFinalizado]};counter++)); do
		for ((ii=$iiSiguiente;ii<=$reloj;ii++)); do
#FR_25270Si el proceso que se ejecuta en un instante es el finalizado...
#FR_25280 El texto no cabe en la terminal
#FR_25290 Se pasa a la siguiente línea
					filaFallosColor[$aux]="            "
					filaFallosBN[$aux]="            "
#FR_25300Espacio por la izquierda para cuadrar líneas
				fi
#FR_25310Contendría el marco sobre el que se produce un fallo.
#FR_25320Si contiene algún dato (marco) es porque hay un fallo.
					filaFallosColor[$aux]+=`echo -e "${coloress[$procFinalizado % 6]}""F""$NC$espaciosfinal "`
					filaFallosBN[$aux]+=`echo -e "F""$espaciosfinal "`
				else
					filaFallosColor[$aux]+=`echo -e "-""$NC$espaciosfinal "`
					filaFallosBN[$aux]+=`echo -e "-""$espaciosfinal "`
				fi
				numCaracteres2=$(($numCaracteres2 + $anchoColumna + 1))
			fi
#FR_25330Para que no se repitan los datos en cada ciclo al no empezar desde 0.
		done
	done

#FR_25340 GENERACIÓN STRING DE FALLOS TOTALES POR PROCESO
#FR_25350Total de Fallos de Página del Proceso

#FR_25360 IMPRIMIR LAS LÍNEAS DE LOS MARCOS DE MEMORIA POR PROCESO (COLOR y BN a pantalla y ficheros)
	echo -e "$filaAlgPagFrecUsoRecTituloColor" | tee -a $informeConColorTotal
	echo -e "$filaAlgPagFrecUsoRecNotas1Color" | tee -a $informeConColorTotal
	echo -ne "$filaAlgPagFrecUsoRecNotas2Color" | tee -a $informeConColorTotal
	echo -e "$filaAlgPagFrecUsoRecTituloBN" >> $informeSinColorTotal
	echo -e "$filaMF$filaAlgPagFrecUsoRecNotas1BN" >> $informeSinColorTotal
	echo -ne "$filaAlgPagFrecUsoRecNotas2BN" >> $informeSinColorTotal
#FR_25370Para cada salto de línea por no caber en la pantalla
		echo -e "${filatiempoColor[$jj]}" | tee -a $informeConColorTotal
		echo -e "${filapagColor[$jj]}" | tee -a $informeConColorTotal
		echo -e "${filatiempoBN[$jj]}" >> $informeSinColorTotal
		echo -e "${filapagBN[$jj]}" >> $informeSinColorTotal
#FR_25380Para cada marco asociado al proceso
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
#FR_25390Se define a "-1" para que no vuelva a imprimirse en caso de producirse algún otro evento.
#FR_25400Fin de dibujaResumenAlgPagFrecUsoRec()

#
#FR_25410 Sinopsis: Permite introducir las opciones generales de la memoria por teclado
#
function entradaMemoriaTeclado {
#FR_25420Pedir el número de marcos de memoria del sistema
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
#FR_25430Pedir el número de direcciones de cada marco de memoria del sistema
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

#FR_25440Se inicializa para que no se considere la reubicabilidad si no está definida en la elección inicial.
#FR_25450R/NR
#FR_25460Pedir el tamaño de la variable de reubicación $reubicabilidadNo0Si1 -eq 0
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
    
#FR_25470Direcciones totales de memoria.
#FR_25480Número de marcos totales de memoria.
    variableReubicar=$reub

#FR_25490 salida de datos introducidos sobre la memoria para que el usuario pueda ver lo que esta introducciendo y volcado de los mismos en ficheros auxiliares
    echo ""
#FR_25500Se meten los datos de las particiones en otro fichero escogido
#FR_25510Se meten los datos de las particiones en otro fichero escogido
#FR_25520Se meten los datos de las particiones en otro fichero escogido
#FR_25530    clear
#FR_25540Fin de entradaMemoriaTeclado()

#
#FR_25550 Sinopsis: Permite introducir los procesos por teclado.
#
function entradaProcesosTeclado {
#FR_25560Número ordinal de proceso
    masprocesos="s"
#FR_25570Se meten los textos correspondientes a los datos en el fichero escogido
    while [[ $masprocesos == "s" ]]; do 
#FR_25580        clear
#FR_25590Para ser equivalente al nuevo programa. Se aconseja quitar la variable $p y estandarizar las variables a usar ??????????.
#FR_25600Bloque para introducción del resto de datos del proceso
#FR_25610Se introduce el tiempo de llegada asociado a cada proceso.
        echo -ne $NORMAL"\n Tiempo de llegada del proceso $p: " >> $informeSinColorTotal
        read llegada[$p]
        until [[ ${llegada[$p]} -ge 0 ]]; do
            echo $NORMAL" No se pueden introducir tiempos de llegada negativos" | tee -a $informeConColorTotal
            echo $NORMAL" No se pueden introducir tiempos de llegada negativos" >>$informeSinColorTotal
            echo -ne $NORMAL" Introduce un nuevo tiempo de llegada\n" | tee -a $informeConColorTotal
            echo -ne $NORMAL" Introduce un nuevo tiempo de llegada\n" >> $informeSinColorTotal
            read llegada[$p]
        done
                
#FR_25620Se introduce la memoria asociada a cada proceso.
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
#FR_25630Se introduce la prioridad asociada a cada proceso.
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
#FR_25640Número ordinal de dirección/página definidas
		paginasTeclado=""
#FR_25650Se introducen las direcciones asociadas a cada proceso.
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
#FR_25680Para ser equivalente al nuevo programa
				numOrdinalPagTeclado=$(expr $numOrdinalPagTeclado + 1)
			fi
		done

#FR_25690Salida de datos introducidos sobre procesos para que el usuario pueda ver lo que esta introducciendo y volcado de los mismos en ficheros auxiliares
        echo ""
#FR_25700Se meten los datos de las particiones en otro fichero escogido
#FR_25710        clear
#FR_25720Se ordenan los datos por tiempo de llegada a medida que se van itroduciendo. También crea los bit de Modificados para cuando se utilicen los algoritmos basados en clases.

        echo -e $NORMAL"\n\n Ref Tll Tej nMar Dir-Pag" | tee -a $informeConColorTotal
        echo -e "\n\n Ref Tll Tej nMar Dir-Pag" >> $informeSinColorTotal
#FR_25730Función para mostrar los datos
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
#FR_25740incremento el contador
    done
#FR_25750Se guardan los datos introducidos en el fichero de última ejecución
        cp $ficheroDatosDefault $ficheroDatosAnteriorEjecucion
    else
        cp $nomFicheroDatos $ficheroDatosAnteriorEjecucion
    fi
#FR_25760Fin de entradaProcesosTeclado()

#
#FR_25770 Sinopsis: Impresión de los procesos una vez introducidos por teclado o fichero
#
function imprimeprocesos {
#FR_25780Se ordenan los procesos por tiempo de llegada a medida que se van introduciendo.
	for (( counter = 0; counter <= numprocesos; counter++ )); do
		if [[ $counter -gt 8 ]]; then
			let colorjastag[counter]=counter-8;
		else
			let colorjastag[counter]=counter+1;
		fi
	done
	echo -e "\n Ref Tll Tej nMar Dirección-Página ------ imprimeprocesos\n" | tee -a $informeConColorTotal $informeSinColorTotal
#FR_25790Resumen inicial de la taba de procesos.
	echo "" | tee -a $informeConColorTotal $informeSinColorTotal > /dev/null
	echo "|—————————————————————————————————————————————————————————————————————————|" | tee -a $informeConColorTotal $informeSinColorTotal > /dev/null
	echo "" | tee -a $informeConColorTotal $informeSinColorTotal > /dev/null
	echo "" | tee -a $informeConColorTotal $informeSinColorTotal > /dev/null
#FR_25800Fin de imprimeprocesos()

#
#FR_25810 Sinopsis: Permite visualizar los datos de la memoria/procesos introducidos por teclado.
#
function entradaProcesosTecladoDatosPantalla { 
	multiplicador=0
	counter2=0
	counter3=0	
#FR_25820Define los colores de los procesos de forma cíclica.
#FR_25830Faltaría ajustar los valores de las variables a los colores posibles (6, 8, 9). Pero no es una buena idea porque los colores del texto y fondos no coinciden como se ve en las variables $coloress y $colorfondos...
			multiplicador=$multiplicador+1
#FR_25840Para calcular la diferencia ente contadores para determinar cuándo es superior al número de colores usados.
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
#FR_25890Fin de entradaProcesosTecladoDatosPantalla()

#
#FR_25900 Sinopsis: Permite ordenar los datos sacados desde fichero y de entrada por teclado.
#
function ordenarDatosEntradaFicheros {
#llegada[@]}; j++)); do
#FR_25920Se guarda su número de orden de introducción o lectura en un vector para la función que lo ordena
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
#FR_25950No hace falta borrar aux porque sólo hay un valor, y su valor se machaca en cada redefinición.
                proceso[$(($i + 1))]=${proceso[$i]} 
                proceso[$i]=$aux
                aux=${llegada[$(($i + 1))]}
                llegada[$(($i + 1))]=${llegada[$i]}
                llegada[$i]=$aux
#FR_25960Se permutan las páginas
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${paginasDefinidasTotal[$(($i + 1)),$counter2]}
				done
#FR_25970Se borran para que no pueda haber valores anteriores residuales.
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

#FR_25980Se permutan las direcciones los valores de "Página Modificada", cuando se trabaja con algoritmos basados en Clases, porque se definió en leer_datos_desde_fichero().
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${directions[$(($i + 1)),$counter2]}
				done
#FR_25990Se borran para que no pueda haber valores anteriores residuales.
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

#FR_260 Ancho del terminal en cada Enter de ejecución de volcados
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${directions_AlgPagFrecUsoRec_pagina_modificada[$(($i + 1)),$counter2,0]}
				done
#FR_260 Ancho del terminal en cada Enter de ejecución de volcados
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
#FR_260 Ancho del terminal en cada Enter de ejecución de volcados
                tiempoEjecucion[$i]=$aux
                aux=${memoria[$(($i + 1))]}
                memoria[$(($i + 1))]=${memoria[$i]} 
                memoria[$i]=$aux
                aux=${prioProc[$(($i + 1))]}
#FR_260 Ancho del terminal en cada Enter de ejecución de volcados
                prioProc[$i]=$aux
            fi
        done
    done
#llegada[@]}; j++)); do
#FR_260 Ancho del terminal en cada Enter de ejecución de volcados
    done
#FR_260 Ancho del terminal en cada Enter de ejecución de volcados

#
#FR_260 Ancho del terminal en cada Enter de ejecución de volcados
#
function entradaMemoriaRangosFichero_op_cuatro_Previo {
#FR_260 Ancho del terminal en cada Enter de ejecución de volcados
#FR_260 Ancho del terminal en cada Enter de ejecución de volcados
#FR_26100Resuelve los nombres de los ficheros de datos
#FR_26110Fin de entradaMemoriaRangosFichero_op_cuatro_Previo()

#
#FR_26120 Sinopsis: Se piden y tratan los mínimos y máximos de los rangos, calculando los valores aleatorios y los datos
#FR_26130 con los que se trabajará para la opción 4.
#
function entradaMemoriaRangosFichero_op_cuatro { 
#FR_26140---Llamada a funciones para rangos-------------
#FR_26150Se asigna la memoria aleatoriamente
    calcDatoAleatorioGeneral $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS
	mem_total=$datoAleatorioGeneral
#FR_26160Se asigna la memoria aleatoriamente
    calcDatoAleatorioGeneral $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
	mem_direcciones=$datoAleatorioGeneral
#FR_26170Se comparará este valor con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.

#FR_26180Se asigna el mínimo del rango de prioridad aleatoriamente
	MIN_RANGE_prio_menorInicial=${prio_menor_min}
	MAX_RANGE_prio_menorInicial=${prio_menor_max}
#FR_26190Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_prio_menor=$PriomFinal
	MAX_RANGE_prio_menor=$PrioMFinal
	calcDatoAleatorioGeneral $MIN_RANGE_prio_menor $MAX_RANGE_prio_menor
	prio_menorInicial=$datoAleatorioGeneral
#FR_26200Se asigna el máximo del rango de prioridad aleatoriamente
	MIN_RANGE_prio_mayorInicial=${prio_mayor_min}
	MAX_RANGE_prio_mayorInicial=${prio_mayor_max}
#FR_26210Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_prio_mayor=$PriomFinal
	MAX_RANGE_prio_mayor=$PrioMFinal
	calcDatoAleatorioGeneral $MIN_RANGE_prio_mayor $MAX_RANGE_prio_mayor
	prio_mayorInicial=$datoAleatorioGeneral
	prio_menor_min=$prio_menor_minInicial
	prio_menor_max=$prio_menor_maxInicial
#FR_26220Se invierten los valores si el mayor es menor que el mayor.
	prio_menor=$PriomFinal
	prio_mayor=$PrioMFinal
#FR_26230Se asigna la reubicaciónaleatoriamente
    calcDatoAleatorioGeneral $MIN_RANGE_REUB $MAX_RANGE_REUB
	reub=$datoAleatorioGeneral
#FR_26240Se asigna el número de procesos aleatoriamente
    calcDatoAleatorioGeneral $MIN_RANGE_NPROC $MAX_RANGE_NPROC
	n_prog=$datoAleatorioGeneral
#FR_26250--------------------------------------------- En algunos casos no hace falta calcularlo porque se calculará por cada proceso.
    datos_tiempo_llegada    
    datos_tiempo_ejecucion 
    datos_tamano_marcos_procesos 
    datos_prio_proc
#FR_26260---------------------------------------------
	datos_quantum         
	calcDatoAleatorioGeneral $MIN_RANGE_quantum $MAX_RANGE_quantum
	quantum=$datoAleatorioGeneral
#FR_26270--------------------------------------------- El resto no hace falta calcularlo porque se calculará por cada proceso.
    datos_tamano_direcciones_procesos          
#FR_26280---------------------------------------------
#FR_26290    clear
	for (( p=0; p<$n_prog; p++)); do     
#FR_26300Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 4, 5 y 6.
#FR_26310Guarda los datos en los ficheros que correspondan
#FR_26320cierre del until
#FR_26330Copia los ficheros Default/Último
#FR_26340Fin de entradaMemoriaRangosFichero_op_cuatro()

#
#FR_26350 Sinopsis: Se guardarán los datos en los ficheros que corresponda para la opción 4
#FR_26360
function entradaMemoriaRangosFichero_op_cuatro_Post_1 {
#FR_26370Para imprimir los rangos en el fichero dependiendo si es el fichero anterior o otro
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
#FR_26380Cierre if $p -eq 1
#FR_26390No se establece desde fichero sino que se decide en el momento de la ejecución mediante la variable de selección de tipo $seleccionTipoPrioridad.
#FR_26400M/m
		PrioR="Mayor"
	else    
		PrioR="Menor"                
	fi              
#FR_26410Escribe los datos en el fichero selecionado
		echo -ne "Marcos totales\n"$mem_total"\nTamano de pagina\n"$mem_direcciones"\nPrioridad menor\n"$prio_menorInicial\
		"\nPrioridad mayor\n"$prio_mayorInicial"\nTipo de prioridad\n"$PrioR"\nMinimo para reubicabilidad\n"$reub"\nQuantum\n"$quantum\
		"\nTll nMar Prio Direcciones/Modificado:\n" > $nomFicheroDatos
	fi                  

#FR_26420Se usarán para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
	MAX_RANGE_PAGINA_MODIFICADA=1
#FR_26430Hace que las direcciones sean diferentes en cada proceso.
#FR_26440Muestra las direcciones del proceso calculadas de forma aleatoria.
#FR_26450Se almacena el cálculo aleatorio de si una página es o no modificada al ser ejecutada.
#FR_26460Se calcula de forma aleatoria si una página es o no modificada al ser ejecutada.
		direccionesAcumuladas+=`echo -ne " ${directions[$p,$numdir]}-${directions_AlgPagFrecUsoRec_pagina_modificada[$p,$numdir,0]}"`
	done
	echo -e ${llegada[$p]} ${memoria[$p]} ${prioProc[$p]} $direccionesAcumuladas >> $nomFicheroDatos
#FR_26470    clear
#FR_26480Fin de entradaMemoriaRangosFichero_op_cuatro_Post_1()

#
#FR_26490 Sinopsis: Se copian los ficheros que correspondan para la opción 4
#
function entradaMemoriaRangosFichero_op_cuatro_Post_2 {
#FR_26500Borra el fichero de datos ultimo y escribe los datos en el fichero
        rm $ficheroDatosAnteriorEjecucion
    fi
#FR_26510Borra el fichero de datos ultimo y escribe los rangos en el fichero
        rm $ficheroRangosAnteriorEjecucion
    fi
#FR_26520Copia los ficheros Default/Último       
#FR_26530Copia los ficheros Default/Último       
#FR_26540Fin de entradaMemoriaRangosFichero_op_cuatro_Post_2()

#
#FR_26550 Sinopsis: Pregunta en qué fichero guardar los rangos amplios para la opción 5.
#
function entradaMemoriaRangosFichero_op_cinco_Previo {
#FR_26560    clear
#FR_26570Resuelve los nombres de los ficheros de datos
#FR_26580Fin de entradaMemoriaRangosFichero_op_cinco_Previo()

#
#FR_26590 Sinopsis: Pregunta en qué fichero guardar los rangos amplios para la opción 6.
#
function entradaMemoriaRangosFichero_op_seis_Previo {
#FR_26600    clear
#FR_26610Resuelve los nombres de los ficheros de datos
    echo -e "\n\nFicheros existentes:\n$NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\nFicheros existentes:\n" >> $informeSinColorTotal 
    files=("./FRangos"/*)
#FR_26620Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
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
#FR_26640    clear
#FR_26650Fin de entradaMemoriaRangosFichero_op_seis_Previo()

#
#FR_26660 Sinopsis: Se tratan los mínimos y máximos de los rangos, calculando los valores aleatorios y los datos
#FR_26670 con los que se trabajará para las opciones 5 y 6.
#
function entradaMemoriaRangosFichero_op_cinco_seis {
#FR_26680    datos_memoria_tabla
#FR_26690-----------Llamada a funciones para calcular los datos aleatorios dentro de los rangos definidos-------------
    MIN_RANGE_MARCOS=${memoria_min}
    MAX_RANGE_MARCOS=${memoria_max}
    calcDatoAleatorioGeneral $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS
	mem_total=$datoAleatorioGeneral
    MIN_RANGE_DIRECCIONES=${direcciones_min}
    MAX_RANGE_DIRECCIONES=${direcciones_max}
    calcDatoAleatorioGeneral $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
	mem_direcciones=$datoAleatorioGeneral
#FR_26700Se comparará este valor con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.

    MIN_RANGE_prio_menor=${prio_menor_min}
    MAX_RANGE_prio_menor=${prio_menor_max}
    calcDatoAleatorioGeneral $MIN_RANGE_prio_menor $MAX_RANGE_prio_menor
#*#FR_26710*Inicial - Datos a representar
    MIN_RANGE_prio_mayor=${prio_mayor_min}
    MAX_RANGE_prio_mayor=${prio_mayor_max}
    calcDatoAleatorioGeneral $MIN_RANGE_prio_mayor $MAX_RANGE_prio_mayor
#*#FR_26720*Inicial - Datos a representar
#FR_26730Variables con los datos originales usadas en la cabecera de la representación de la tabla
	PrioMInicial=$prio_mayorInicial
#FR_26740Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#FR_26750Sobre este rango se calculan los datos de las prioridades de los procesos, prioridades que no deberían pedirse al usuario.
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
#FR_26760El resto no se recalcula porque son datos de cada proceso, como tiempo_llegada, tamano_procesos,...
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
#FR_26770No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -e "\n$NC Pulse enter para continuar..." | tee -a $informeConColorTotal
		echo -e "\nPulse enter para continuar..." >> $informeSinColorTotal
		read enter
		echo -e $enter "\n" >> $informeConColorTotal
		echo -e $enter "\n" >> $informeSinColorTotal
	fi
#FR_26780    clear
	for (( p=0; p<$n_prog; p++)); do     
#FR_26790Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 4, 5 y 6.
#FR_26800Guarda los datos en los ficheros que correspondan
#FR_26810cierre del for
#FR_26820Copia los ficheros Default/Último    
#FR_26830Fin de entradaMemoriaRangosFichero_op_cinco_seis()

#
#FR_26840 Sinopsis: Se guardarán los datos en los ficheros que corresponda para las opciones 5 y 6
#
function entradaMemoriaRangosFichero_op_cinco_seis_Post_1 {
#FR_26850No se establece desde fichero sino que se decide en el momento de la ejecución mediante la variable de selección de tipo $seleccionTipoPrioridad.
#FR_26860M/m
		PrioR="Mayor"
	else    
		PrioR="Menor"                
	fi              
	if [[ $p -eq 0 ]]; then
		echo -ne "Marcos totales\n"$mem_total"\nTamano de pagina\n"$mem_direcciones"\nPrioridad menor\n"$prio_menorInicial\
		"\nPrioridad mayor\n"$prio_mayorInicial"\nTipo de prioridad\n"$PrioR "\nMinimo para reubicabilidad\n"$reub"\nQuantum\n"$quantum\
		"\nTll nMar Prio Direcciones:\n" > $nomFicheroDatos
	fi                  

#FR_26870Hace que las direcciones sean diferentes en cada proceso.
#FR_26880Se usarán para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
	MAX_RANGE_PAGINA_MODIFICADA=1
#FR_26890Muestra las direcciones del proceso calculadas de forma aleatoria.
#FR_26900Se calcula de forma aleatoria si una página es o no modificada al ser ejecutada.
#FR_26910Se almacena el cálculo aleatorio de si una página es o no modificada al ser ejecutada.
		direccionesAcumuladas+=`echo -ne " ${directions[$p,$numdir]}-${directions_AlgPagFrecUsoRec_pagina_modificada[$p,$numdir,0]}"`
	done
	echo -e ${llegada[$p]} ${memoria[$p]} ${prioProc[$p]} $direccionesAcumuladas >> $nomFicheroDatos
#FR_26920Fin de entradaMemoriaRangosFichero_op_cinco_seis()

#
#FR_26930 Sinopsis: Se copian los ficheros que correspondan para las opciones 5 y 6
#
function entradaMemoriaRangosFichero_op_cinco_seis_Post_2 {
#FR_26940Borra el fichero de datos ultimo y escribe los datos en el fichero
    if [[ -f "$ficheroDatosAnteriorEjecucion" ]]; then
        rm $ficheroDatosAnteriorEjecucion
    fi
    if [[ -f "$ficheroRangosAnteriorEjecucion" && $seleccionMenuEleccionEntradaDatos -ne 5 ]]; then
        rm $ficheroRangosAnteriorEjecucion
    fi
#FR_26950Copia los ficheros Default/Último       
    if [[ $seleccionMenuEleccionEntradaDatos -ne 5 ]]; then
#FR_26960Copia los ficheros Default/Último       
    fi
#FR_26970Fin de entradaMemoriaRangosFichero_op_cinco_seis_Post_2()

#
#FR_26980 Sinopsis: Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 7, 8 y 9.
#
function entradaMemoriaRangosFichero_op_cuatro_cinco_seis_Comun {                          
#FR_26990    clear
    variableReubicar=$reub
#FR_270 ancho de columnas estrechas en tabla resumen de procesos en los volcados
    proc=$(($p-1))
    if [[ $((p + 1)) -ge 10 ]]; then
        nombre="P$((p + 1))"
    else
        nombre="P0$((p + 1))" 
    fi
#FR_270 ancho de columnas estrechas en tabla resumen de procesos en los volcados
#FR_270 ancho de columnas estrechas en tabla resumen de procesos en los volcados
    calcDatoAleatorioGeneral $MIN_RANGE_llegada $MAX_RANGE_llegada
#FR_270 ancho de columnas estrechas en tabla resumen de procesos en los volcados
    calcDatoAleatorioGeneral $MIN_RANGE_tiempo_ejec $MAX_RANGE_tiempo_ejec
#FR_270 ancho de columnas estrechas en tabla resumen de procesos en los volcados
    calcDatoAleatorioGeneral $MIN_RANGE_tamano_marcos_proc $MAX_RANGE_tamano_marcos_proc
#FR_270 ancho de columnas estrechas en tabla resumen de procesos en los volcados
    calcDatoAleatorioGeneral $prio_menor $prio_mayor
#FR_270 ancho de columnas estrechas en tabla resumen de procesos en los volcados
#FR_270 ancho de columnas estrechas en tabla resumen de procesos en los volcados
    
#FR_270 ancho de columnas estrechas en tabla resumen de procesos en los volcados
#FR_270 ancho de columnas estrechas en tabla resumen de procesos en los volcados
#FR_27100Primero se calcula el tamaño en direcciones del proceso.
	tamano_direcciones_proc=$datoAleatorioGeneral
	for (( numdir = 0; numdir <= ${ejecucion[$p]}; numdir++ )); do
#FR_27110Luego se calculan las direcciones aplicando la búsqueda aleatoria hasta el tamaño en direcciones dle proceso precalculado.
		directions[$p,$numdir]=$datoAleatorioGeneral
#FR_27120$numDireccionesTotales_max viene de leer_rangos_desde_fichero() y se comparará con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.
			echo -e "\n***Error en la lectura de rangos. La dirección de memoria utilizada ("${directions[$p,$numdir]}") está fuera del rango máximo definido por el número de marcos de página ("$(($numDireccionesTotales_max - 1))")."
			exit 1 
		fi
#let pagTransformadas[$2]=`expr $1/$mem_direcciones`
		paginasDefinidasTotal[$p,$numdir]=${pagTransformadas[$numdir]} 
	done
#FR_27140Fin de entradaMemoriaRangosFichero_op_cuatro_cinco_seis_Comun()
            
#FR_27150
#FR_27160 Sinopsis: Pregunta en qué fichero guardar los rangos para la opción 8.
#
function entradaMemoriaRangosFichero_op_siete_Previo {
#FR_27170    clear
#FR_27180Resuelve los nombres de los ficheros de rangos amplios
#FR_27190Resuelve los nombres de los ficheros de rangos
#FR_27200Resuelve los nombres de los ficheros de datos
#FR_27210Fin de entradaMemoriaRangosFichero_op_siete_Previo()

#
#FR_27220 Sinopsis: Se piden y tratan los mínimos y máximos de los rangos para las opciones 7, 8 y 9. El cálculo de los datos
#FR_27230 aleatorios con los que se trabajará se hace en entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun.
#
function entradaMemoriaRangosFichero_op_siete_ocho_nueve { 
    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
#FR_27240Llamada a funciones para definir las variables con los límites de los rangos amplios.
    fi                     
#FR_27250Se definen nuevas variables para redefinir los límites de los subrangos sacados de los rangos amplios.
	MIN_RANGE_MARCOSInicial=$datoAleatorioGeneral	
    calcDatoAleatorioGeneral $memoria_minInicial $memoria_maxInicial 
    MAX_RANGE_MARCOSInicial=$datoAleatorioGeneral
#FR_27260Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_MARCOS=$PriomFinal
	MAX_RANGE_MARCOS=$PrioMFinal
#FR_27270Se calculan los valores que no dependen de los procesos desde los subrangos ya calculados.
	mem_total=$datoAleatorioGeneral

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_numero_direcciones_marco_amplio 
    fi                     
    calcDatoAleatorioGeneral $direcciones_minInicial $direcciones_maxInicial 
	MIN_RANGE_DIRECCIONESInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $direcciones_minInicial $direcciones_maxInicial 
    MAX_RANGE_DIRECCIONESInicial=$datoAleatorioGeneral
#FR_27280Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_DIRECCIONES=$PriomFinal
	MAX_RANGE_DIRECCIONES=$PrioMFinal
    calcDatoAleatorioGeneral $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
	mem_direcciones=$datoAleatorioGeneral
#FR_27290Dato usado para compararlo con la mayor dirección a ejecutar para saber si cabe en memoria No Virtual.

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_prio_menor_amplio 
    fi                     
#FR_27300Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#FR_27310Variables con los originales usadas para calcular subrangos y datos finales
	prio_menor_max=$PrioMFinal
#FR_27320Prioridades asociadas a los procesos.
#FR_27330Desde este rango amplio se calculan los subrangos desde los que calcular el rango desde el que calcular los datos.
#FR_27340calcMaxPrioPro
    MAX_RANGE_prio_menorInicial=$datoAleatorioGeneral          
#FR_27350Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_prio_menor=$PriomFinal
	MAX_RANGE_prio_menor=$PrioMFinal
#FR_27360Datos generales
#FR_27370Desde este subrango se calcula el rango desde el que calcular los datos.

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_prio_mayor_amplio 
    fi                     
#FR_27380Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	prio_mayor_min=$PriomFinal
	prio_mayor_max=$PrioMFinal
#FR_27390Prioridades asociadas a los procesos.
	MIN_RANGE_prio_mayorInicial=$datoAleatorioGeneral
#FR_27400calcMaxPrioPro
    MAX_RANGE_prio_mayorInicial=$datoAleatorioGeneral          
#FR_27410Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_prio_mayor=$PriomFinal
	MAX_RANGE_prio_mayor=$PrioMFinal
#FR_27420Datos generales
	prio_mayorInicial=$datoAleatorioGeneral

#FR_27430Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#FR_27440Desde este rango se calculan los datos.
	prio_mayor=$PrioMFinal

#FR_27450Variables con los datos originales usadas en la cabecera de la representación de la tabla
	PrioMInicial=$prio_mayorInicial

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_tamano_reubicacion_amplio 
    fi                     
    calcDatoAleatorioGeneral $reubicacion_minInicial $reubicacion_maxInicial 
	MIN_RANGE_REUBInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $reubicacion_minInicial $reubicacion_maxInicial 
    MAX_RANGE_REUBInicial=$datoAleatorioGeneral
#FR_27460Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
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
#FR_27470Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
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
#FR_27480Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_llegada=$PriomFinal
	MAX_RANGE_llegada=$PrioMFinal

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_tiempo_ejecucion_amplio 
    fi                     
    calcDatoAleatorioGeneral $tiempo_ejec_minInicial $tiempo_ejec_maxInicial 
	MIN_RANGE_tiempo_ejecInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $tiempo_ejec_minInicial $tiempo_ejec_maxInicial 
    MAX_RANGE_tiempo_ejecInicial=$datoAleatorioGeneral
#FR_27490Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_tiempo_ejec=$PriomFinal
	MAX_RANGE_tiempo_ejec=$PrioMFinal
    
    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_tamano_marcos_procesos_amplio 
    fi                     
    calcDatoAleatorioGeneral $tamano_marcos_proc_minInicial $tamano_marcos_proc_maxInicial 
	MIN_RANGE_tamano_marcos_procInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $tamano_marcos_proc_minInicial $tamano_marcos_proc_maxInicial 
    MAX_RANGE_tamano_marcos_procInicial=$datoAleatorioGeneral
#FR_27500Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_tamano_marcos_proc=$PriomFinal
	MAX_RANGE_tamano_marcos_proc=$PrioMFinal

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_quantum_amplio 
    fi                     
    calcDatoAleatorioGeneral $quantum_minInicial $quantum_maxInicial 
	MIN_RANGE_quantumInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $quantum_minInicial $quantum_maxInicial 
    MAX_RANGE_quantumInicial=$datoAleatorioGeneral
#FR_27510Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
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
#FR_27520Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_tamano_direcciones_proc=$PriomFinal
	MAX_RANGE_tamano_direcciones_proc=$PrioMFinal    
#FR_27530------------------------------------------------------
#FR_27540Se imprime una tabla con los datos de los rangos introducidos, los subrangos y los valores calculables.

#FR_27550    clear
    p=0
    until [[ $p -eq $n_prog ]]; do  
#FR_27560Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 7, 8 y 9.
#FR_27570Guarda los datos en los ficheros que correspondan
#FR_27580        clear
#FR_27590Se incrementa el contador
#FR_27600cierre del do del while $pro=="S"
#FR_27610Copia los ficheros Default/Último
#FR_27620Fin de entradaMemoriaRangosFichero_op_siete_ocho_nueve()

#
#FR_27630 Sinopsis: Se guardarán los datos en los ficheros que corresponda para la opción 4
#
function entradaMemoriaRangosFichero_op_siete_ocho_nueve_Post_1 { 
#FR_27640No se establece desde fichero sino que se decide en el momento de la ejecución mediante la variable de selección de tipo $seleccionTipoPrioridad.
#FR_27650M/m
		PrioR="Mayor"
	else    
		PrioR="Menor"                
	fi              
	if [[ $p -eq 0 ]]; then
		echo -ne "Marcos totales\n"$mem_total"\nTamano de pagina\n"$mem_direcciones"\nPrioridad menor\n"$prio_menorInicial\
		"\nPrioridad mayor\n"$prio_mayorInicial"\nTipo de prioridad\n"$PrioR "\nMinimo para reubicabilidad\n"$reub"\nQuantum\n"$quantum\
		"\nTll nMar Prio Direcciones:\n" > $nomFicheroDatos
	fi                  

#FR_27660Hace que las direcciones sean diferentes en cada proceso.
#FR_27670Se usarán para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
	MAX_RANGE_PAGINA_MODIFICADA=1
#FR_27680Muestra las direcciones del proceso calculadas de forma aleatoria.
#FR_27690Se calcula de forma aleatoria si una página es o no modificada al ser ejecutada.
#FR_2770La opción > lo crea inicialmente
		direccionesAcumuladas+=`echo -ne " ${directions[$p,$numdir]}-${directions_AlgPagFrecUsoRec_pagina_modificada[$p,$numdir,0]}"`
	done
	echo -e ${llegada[$p]} ${memoria[$p]} ${prioProc[$p]} $direccionesAcumuladas >> $nomFicheroDatos

#FR_27710Escribe los rangos en el fichero de rangos selecionado (RangosAleTotalDefault.txt, o el elegido por el usuario).
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
#FR_27720Cierre if $p -eq 1
#FR_27730Escribe los rangos en el fichero de rangos amplios selecionado
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
#FR_27740Cierre if $p -eq 1
#FR_27750Fin de entradaMemoriaRangosFichero_op_siete_Post_1()

#
#FR_27760 Sinopsis: Se copian los ficheros que correspondan para la opción 4
#
function entradaMemoriaRangosFichero_op_siete_ocho_nueve_Post_2 { 
#FR_27770Borra el fichero de datos ultimo y escribe los datos en el fichero
        rm $ficheroDatosAnteriorEjecucion
    fi
#FR_27780Borra el fichero de datos ultimo y escribe los rangos en el fichero
        rm $ficheroRangosAnteriorEjecucion
    fi
    cp $nomFicheroDatos $ficheroDatosAnteriorEjecucion
    cp $nomFicheroRangos $ficheroRangosAnteriorEjecucion
#FR_27790Actualiza el fichero de rangos amplios de última ejecución (RangosAleTotalLast.txt) como copia del fichero utilizado para los rangos amplios (RangosAleTotalDefault.txt, o el elegido por el usuario).
#FR_2780 Sinopsis: Cabecera de inicio
			rm $ficheroRangosAleTotalAnteriorEjecucion
		fi
		cp $nomFicheroRangosAleT $ficheroRangosAleTotalAnteriorEjecucion        
    fi
#FR_27810Fin de entradaMemoriaRangosFichero_op_siete_Post_2()
           
#
#FR_27820 Sinopsis: Pregunta en qué fichero guardar los rangos para la opción 8.
#
function entradaMemoriaRangosFichero_op_ocho_Previo {
#FR_27830    clear
#FR_27840Resuelve los nombres de los ficheros de rangos
#FR_27850Resuelve los nombres de los ficheros de datos
#FR_27860Fin de entradaMemoriaRangosFichero_op_ocho_Previo()

#
#FR_27870 Sinopsis: Pregunta en qué fichero guardar los rangos amplios para la opción 9.
#
function entradaMemoriaRangosFichero_op_nueve_Previo {
#FR_27880    clear
#FR_27890Resuelve los nombres de los ficheros de rangos
#FR_27900Resuelve los nombres de los ficheros de datos
    echo -e "\n\nFicheros existentes:\n$NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\nFicheros existentes:\n" >> $informeSinColorTotal  
    files=("./FRangosAleT"/*)
#FR_27910Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#FR_27920Define el dato, pero no en qué posción se encuentra.
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
#FR_27940    clear
#FR_27950Fin de entradaMemoriaRangosFichero_op_nueve_Previo()

#
#FR_27960 Sinopsis: Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 7, 8 y 9.
#
function entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun {                          
#FR_27970    clear
    variableReubicar=$reub
#FR_27980------------------------------Empieza a introducir procesos--------------------
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
#FR_27990Se añade a el vector ese nombre
#FR_280 ancho de columnas anchas en tabla resumen de procesos en los volcados
#FR_280 ancho de columnas anchas en tabla resumen de procesos en los volcados
#FR_280 ancho de columnas anchas en tabla resumen de procesos en los volcados
#FR_280 ancho de columnas anchas en tabla resumen de procesos en los volcados

    calcDatoAleatorioGeneral $prio_menor $prio_mayor
#FR_280 ancho de columnas anchas en tabla resumen de procesos en los volcados
#FR_280 ancho de columnas anchas en tabla resumen de procesos en los volcados

#FR_280 ancho de columnas anchas en tabla resumen de procesos en los volcados
#FR_280 ancho de columnas anchas en tabla resumen de procesos en los volcados
#FR_280 ancho de columnas anchas en tabla resumen de procesos en los volcados
	tamano_direcciones_proc=$datoAleatorioGeneral
	for (( numdir = 0; numdir <= ${ejecucion[$p]}; numdir++ )); do
#FR_280 ancho de columnas anchas en tabla resumen de procesos en los volcados
		directions[$p,$numdir]=$datoAleatorioGeneral
#FR_28100$numDireccionesTotales_max viene de leer_rangos_desde_fichero() y se comparará con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.
			echo -e "\n***Error en la lectura de rangos amplios. La dirección de memoria utilizada ("${directions[$p,$numdir]}") está fuera del rango máximo definido por el número de marcos de página ("$(($numDireccionesTotales_max - 1))")."
			exit 1
		fi
#let pagTransformadas[$2]=`expr $1/$mem_direcciones`
		paginasDefinidasTotal[$p,$numdir]=${pagTransformadas[$numdir]} 
	done
#FR_28120Fin de entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun()

#
#FR_28130 Sinopsis: Calcula los datos de la tabla resumen de procesos en cada volcado
#
#FR_28140ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAR LAS VARIABLES.
#FR_28150Modificamos los valores de los arrays, restando de lo que quede
        if [[ ${enejecucion[$i]} -eq 1 ]]; then  
            temp_rej[$i]=`expr ${temp_rej[$i]} - 1`
#FR_28160Se suman para evitar que en el último segundo de ejecución no se sume el segundo de retorno
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
#FR_28210Si ha terminado, no se hace nada. Y si no ha llegado, su tiempo de espera es "-"
#FR_28220Se ponen todas las posiciones del vector enejecucion a 0, se establecerá qué proceso está a 1 en cada ciclo del programa.
#FR_28230Se desbloquean todos y se establecerán los procesos bloqueados en cada ciclo.
    done
#FR_28240 Se incrementa el reloj
#FR_28250Final de los cálculos para dibujar la banda de tiempos - ajusteFinalTiemposEsperaEjecucionRestante

#
#FR_28260 Sinopsis: Se muestran los eventos sucedidos, sobre la tabla resumen.
#
function mostrarEventos {
#FR_28270    clear
#FR_28280Inicializo evento
#FR_28290Se muestran los datos sobre las indicaciones del evento que ha sucedido
    Dato1=""
    Dato2=""
    Dato3=""
#FR_28300Paginado pero No Virtual
        algoritmoSeleccionado="FCFS-PaginaciónNoVirtual-"
#FR_28310FCFS/SJF/SRPT
        algoritmoSeleccionado="FCFS-Paginación-"
    elif [[ $seleccionMenuAlgoritmoGestionProcesos -eq 2 ]]; then    
        algoritmoSeleccionado="SJF-Paginación-"
    elif [[ $seleccionMenuAlgoritmoGestionProcesos -eq 3 ]]; then    
        algoritmoSeleccionado="SRPT-Paginación-" 
    elif [[ $seleccionMenuAlgoritmoGestionProcesos -eq 4 ]]; then    
        algoritmoSeleccionado="Prioridades-"    
#FR_28320M/m
			algoritmoSeleccionado+="Mayor-"
		else    
			algoritmoSeleccionado+="Menor-"                
		fi              
#FR_28330M/m
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
#FR_28340C/NC
        continuidadSeleccionado="NC-"
    else    
        continuidadSeleccionado="C-"                
    fi
#FR_28350R/NR
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
#FR_28360Se muestra el evento que ha sucedido
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisosalida[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha salido de memoria." | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha salido de memoria." >> $informeSinColorTotal
#FR_28370Se borra el uno para que no se vuelva a imprimir
        fi
    done
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisollegada[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha llegado al sistema." | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha llegado al sitema." >> $informeSinColorTotal
#FR_28380Se borra el uno para que no se vuelva a imprimir
        fi
    done
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisoentrada[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha entrado de memoria. " | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha entrado en memoria." >> $informeSinColorTotal
#FR_28390Se borra el uno para que no se vuelva a imprimir
        fi
    done
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisoEntradaCPU[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha entrado en CPU. " | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha entrado en CPU." >> $informeSinColorTotal
#FR_2840$NC
" | tee -a $informeConColorTotal
        fi
    done
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisoPausa[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha quedado en pausa. " | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha quedado en pausa." >> $informeSinColorTotal
#FR_28410Se borra el uno para que no se vuelva a imprimir
        fi
    done
#FR_28420Fin de mostrarEventos() - Final de mostrar los eventos sucedidos - mostrarEventos

#
#FR_28430 Sinopsis: Prepara e imprime la tabla resumen de procesos en cada volcado - SIN CUADRO
#
function dibujarTablaDatos {
    mem_aux=$[ $mem_total -1 ]
    j=0
    k=0
    for (( i=0; i<$nprocesos; i++ )); do
        if [[ ${enmemoria[$i]} -eq 1 ]]; then
#FR_28440Se guardan en cada posición el número del proceso correspondiente
            coloresAux[$k]=${coloress[$i % 6]} 
            j=`expr $j + 1`
        fi
        k=`expr $k + 1`
    done
    j=0
    k=0
#FR_28450CALCULAR LOS DATOS A REPRESENTAR.
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
#FR_28460No llegado
            inicio2[$i]="-"
            final2[$i]="-" 
            temp_wait[$i]="-"
            temp_ret[$i]="-"
            temp_rej[$i]="-"
            estado[$i]="Fuera del Sistema"
#FR_28470En espera
            inicio2[$i]="-"
            final2[$i]="-"
            estado[$i]="En espera"
#FR_28480En memoria
            estado[$i]="En memoria"
#FR_28490En ejecucion
            estado[$i]="En ejecución"
#FR_28500En ejecucion
            estado[$i]="En pausa"
#FR_28510Finalizado
            inicio2[$i]="-"
            final2[$i]="-" 
            temp_rej[$i]="-"
            estado[$i]="Finalizado"
        fi
            varC[$i]=${coloress[$i % 6]}
    done

#FR_28520REPRESENTAR LOS DATOS
#FR_28530Se ajusta a parte el vector de memoria inicial y final NO CONTINUA para CUADRAR (he comentado lo que cuadraba lo de antes)(modificación 2020)
#FR_28540Ajuste para la memoria no continua en un auxiliar (se imprime el auxiliar)
#FR_28550Se copia los normales al auxiliar
    inicialNCaux=("${inicialNC[@]}")
    finalNCaux=("${finalNC[@]}")
 	datos4=""
#FR_28560Si han sido usadas, se subrayan
		datos4="-Modificación"
	fi

#FR_28570Para Prioridades
		echo -e " Ref Tll Tej Mem Pri TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " | tee -a $informeConColorTotal   
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────────" | tee -a $informeConColorTotal
		echo -e " Ref Tll Tej Mem Pri TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " >> $informeSinColorTotal
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────────" >> $informeSinColorTotal
#FR_28580Se aplica el $m a memoria inicial y memoria final (los auxiliares que son los que se imprimen en el volcado)
#FR_28590Se usa m porque i recorre los procesos y m controla las unidades usadas por cada proceso, normalmente 0 o 1, y también las unidades de los n trozos de memoria asociados a cada proceso.
			echo -ne " ${varC[$i]}${proceso[$i]}$NC"\
#ejecucion[$i]})${varC[$i]}${ejecucion[$i]}$NC"\
#prioProc[$i]})${varC[$i]}${prioProc[$i]}$NC"\
#temp_ret[$i]})${varC[$i]}${temp_ret[$i]}$NC"\
#inicialNCaux[$m]})${varC[$i]}${inicialNCaux[$m]}$NC"\
#estado[$i]})$NC " | tee -a $informeConColorTotal
			DireccionesPaginasPorProceso=""
#FR_28650Subrayado
			datos4=""
			for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then 
					datos4="-"${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				fi
#FR_28660Si han sido usadas, se subrayan
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
#FR_28760Para Round-Robin
		echo -e " Ref Tll Tej Mem TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " | tee -a $informeConColorTotal   
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────" | tee -a $informeConColorTotal
		echo -e " Ref Tll Tej Mem TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " >> $informeSinColorTotal
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────" >> $informeSinColorTotal
#FR_28770Se aplica el $m a memoria inicial y memoria final (los auxiliares que son los que se imprimen en el volcado)
#FR_28780Se usa m porque i recorre los procesos y m controla las unidades usadas por cada proceso, normalmente 0 o 1, y también las unidades de los n trozos de memoria asociados a cada proceso.
			echo -ne " ${varC[$i]}${proceso[$i]}$NC"\
#ejecucion[$i]})${varC[$i]}${ejecucion[$i]}$NC"\
#temp_wait[$i]})${varC[$i]}${temp_wait[$i]}$NC"\
#temp_rej[$i]})${varC[$i]}${temp_rej[$i]}$NC"\
#finalNCaux[$m]})${varC[$i]}${finalNCaux[$m]}$NC"\
#estado[$i]})$NC " | tee -a $informeConColorTotal
			DireccionesPaginasPorProceso=""
#FR_28840Subrayado
			datos4=""
			for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then 
					datos4="-"${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				fi
#FR_28850Si han sido usadas, se subrayan
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
#FR_28950Para FCFS/SJF/SRPT 
		echo -e " Ref Tll Tej Mem TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " | tee -a $informeConColorTotal   
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────" | tee -a $informeConColorTotal
		echo -e " Ref Tll Tej Mem TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " >> $informeSinColorTotal
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────" >> $informeSinColorTotal
#FR_28960Se aplica el $m a memoria inicial y memoria final (los auxiliares que son los que se imprimen en el volcado)
#FR_28970Se usa m porque i recorre los procesos y m controla las unidades usadas por cada proceso, normalmente 0 o 1, y también las unidades de los n trozos de memoria asociados a cada proceso.
			echo -ne " ${varC[$i]}${proceso[$i]}$NC"\
#ejecucion[$i]})${varC[$i]}${ejecucion[$i]}$NC"\
#temp_wait[$i]})${varC[$i]}${temp_wait[$i]}$NC"\
#temp_rej[$i]})${varC[$i]}${temp_rej[$i]}$NC"\
#finalNCaux[$m]})${varC[$i]}${finalNCaux[$m]}$NC"\
#estado[$i]})$NC " | tee -a $informeConColorTotal
			DireccionesPaginasPorProceso=""
#FR_290 ancho de columnas más anchas en tabla resumen de procesos en los volcados
			datos4=""
			for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then 
					datos4="-"${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				fi
#FR_290 ancho de columnas más anchas en tabla resumen de procesos en los volcados
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

#FR_29140CALCULAR Y REPRESENTAR LOS PROMEDIOS
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
#FR_29150Si el tamaño del proceso es menor o igual que el de memoria
#FR_29160suma para sacar su promedio
#FR_29170promedio
#FR_29180suma para sacar su promedio
#FR_29190promedio
        fi
    done
    var_uno=1
    echo -e "$NC T. espera medio: $promedio_espera\t      T. retorno medio: $promedio_retorno$NC" | tee -a $informeConColorTotal 
    echo -e " T. espera medio: $promedio_espera\t       T. retorno medio: $promedio_retorno" >> ./$informeSinColorTotal
#FR_2920 Sinopsis: Menú inicial con ayuda y ejecución

#
#FR_29210 Sinopsis: Sacar procesos terminados de memoria y actualizar variables de la Banda de Memoria.
#
function calculosActualizarVariablesBandaMemoria {
#FR_29220Sucesión: sacar procesos, actualizar variables de memoria guardadoMemoria y tamanoGuardadoMemoria
#FR_29230Se libera espacio en memoria de los procesos recien terminados.
        if [[ ${enmemoria[$po]} == 0 && ${escrito[$po]} == 1 ]]; then 
            for (( ra=0; ra<$mem_total; ra++ )); do
                if [[ ${unidMemOcupadas[$ra]} == $po ]]; then
                    unidMemOcupadas[$ra]="_" 
                fi
            done
            escrito[$po]=0
        fi
    done
#FR_29240Si los procesos ya no están en memoria se eliminan de la variable guardadoMemoria.
        if [[ ${enmemoria[$po]} -ne 1 ]]; then 
#guardadoMemoria[@]} ; i++ )); do 
                if [[ ${guardadoMemoria[$i]} -eq $po ]]; then
                    unset guardadoMemoria[$i]
                    unset tamanoGuardadoMemoria[$i]
                fi
            done
        fi
    done
#FR_29260Se eliminan los huecos vacíos que genera el unset
#FR_29270Se eliminan los huecos vacíos que genera el unset
#FR_29280Fin de calculosActualizarVariablesBandaMemoria()

#
#FR_29290 Sinopsis: Se realizan los cálculos necesarios para la impresión de la banda de memoria en los volcados.
#
function calculosReubicarYMeterProcesosBandaMemoria {
#FR_2930	clear
    if [[ $mem_libre -gt 0 ]]; then 
#FR_29310Si hay que reubicar, se hace.
#FR_29320Se reubican los procesos existentes en la memoria en el mismo orden.
#FR_29330ud contador que guarda las unidades que se van guardando (ud < total)
                ra=0
#FR_29340Se reescriben todos los números de proceso en unidMemOcupadasAux (menor y no menor o igual, ya que se empieza en 0)
#FR_29350Se marca con el proceso que ocupa la posición de memoria.
                        unidMemOcupadasAux[$ra]=${guardadoMemoria[$gm]}  
                        ud=$((ud+1))
                    fi
#FR_29360Se marca que ya se ha escrito en memoria.
                    ra=$((ra+1))
	             done
            done
#FR_29370Se copia la memoria auxiliar a la original para que se después se escriba en memoria.
#FR_29380Notificamos que se ha reubicado.
            echo -e " La memoria ha sido reubicada." $NC | tee -a $informeConColorTotal
            echo -e " La memoria ha sido reubicada." >> $informeSinColorTotal
        fi
    fi
#FR_29390Fin de calculosReubicarYMeterProcesosBandaMemoria()

#
#FR_2940Menú de elección de algoritmo de gestión de procesos.
#
function tratarRangoPrioridadesDirecta {
#FR_29410Será 1 cuando se determine un rango de prioridades cuyo mínimo sea mayor que su máximo.
    if [[ $1 -gt $2 ]]; then 
		aux=$1
		PriomFinal=$2
		PrioMFinal=$aux
#FR_29420Será 1 cuando se determine un rango de prioridades cuyo mínimo sea mayor que su máximo.
    else
		PriomFinal=$1
		PrioMFinal=$2
    fi
#FR_29430Fin de calculosReubicarYMeterProcesosBandaMemoria()

#
#FR_29440 Sinopsis: Guardar los procesos que van entrando en memoria de forma secuencial en la variable guardadoMemoria
#FR_29450 y sus tamaños en tamanoGuardadoMemoria
#
function crearListaSecuencialProcesosAlEntrarMemoria {
#FR_29460Vaciamos el array anterior
#FR_29470Vaciamos el array anterior
#FR_29480Determinará qué procesos están en memoria.
        if [[ ${unidMemOcupadas[$ra]} != "_" ]]; then
            numeroProbar=${unidMemOcupadas[$ra]}
            permiso=1
#FR_29490Si el proceso ya está en memoria, no hace falta meterlo.
                if [[ ${guardadoMemoria[$i]} -eq $numeroProbar ]]; then
                    permiso=0
                fi
            done
#FR_2950Menú de elección de continuidad.
#FR_29510Guarda el número de proceso que va a meter en memoria.
#FR_29520Guarda el tamaño del proceso que va a meter en memoria.
                permiso=0
            fi
        fi
    done
#FR_29530Fin de crearListaSecuencialProcesosAlEntrarMemoria()

#
#FR_29540 Sinopsis: Comprueba que cada hueco en memoria no es mayor que la variable definida, para decidir si se reubica.
#
function comprobacionSiguienteProcesoParaReubicar {
#FR_29550Sucesión: Se determina qué proceso es el siguiente en entrar en memoria, y dependiendo de la continuidad y reubicabilidad definidas, se establece si hay espacio en memoria.
#FR_29560Variable para no permitir meter procesos en memoria bajo ciertas condiciones relacionadas con la continuidad.
    encontradoHuecoMuyReducido=0
    primeraUnidadFuturoProcesoSinreubicar=-1
    raInicioProceso=-1
#FR_29570En caso de ser memoria no continua, si hay un hueco demasiado pequeño, y se va a usar como parte de la memoria a usar.
#FR_29580En caso de ser memoria continua, si no hay un hueco suficientemente grande en el que quepa pero sí en la suma de todos ellos.
    contadorReubicar=-1
    contadorReubicarTotal=0
    siguienteProcesoAMeter=-1
#FR_29590Metemos un proceso y comprobamos si hay que reubicar
#FR_2960Menú de elección de reubicabilidad.
            siguienteProcesoAMeter=$po
            break
        fi 
    done
    if [[ $siguienteProcesoAMeter -eq -1 ]]; then
#FR_29610Metemos un proceso y comprobamos si hay que reubicar
#FR_29620Si está para entrar en memoria y no está dentro se mete, y si ya está dentro se ignora.
                siguienteProcesoAMeter=$po
                break
            fi 
        done
    fi 
    if [[ $mem_libre -gt 0 ]]; then
        for (( ra=0; ra<$mem_total; ra++ )); do
            if [[ ${unidMemOcupadas[$ra]} == "_" && siguienteProcesoAMeter -gt -1 ]]; then
#FR_29630Se designa la primera unidad sobre la que meter el proceso si entrara en memoria continua.
                    contadorReubicar=0
                    raInicioProceso=$ra
                fi
                contadorReubicar=$((contadorReubicar + 1))
                contadorReubicarTotal=$((contadorReubicarTotal + 1))
                if [[ $contadorReubicar -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $primeraUnidadFuturoProcesoSinreubicar -eq -1 ]]; then 
#FR_296408 - Si cabe en un único hueco en memoria continua.
                    primeraUnidadFuturoProcesoSinreubicar=$raInicioProceso               
                    break
                fi
            elif [[ ${unidMemOcupadas[$ra]} != "_" && siguienteProcesoAMeter -ne -1 ]]; then
                if [[ $contadorReubicar -ne -1 && $contadorReubicar -le $variableReubicar && $reubicabilidadNo0Si1 -eq 1 ]]; then 
#FR_29650Si encuentra un hueco demasiado pequeño mientras busca hueco suficiente y puede caber en la totalidad de los huecos, en memoria no continua.
                    encontradoHuecoMuyReducido=1
                fi
                contadorReubicar=-1
            fi
        done
#FR_29660No necesario
#1 - 3 - 6 - 9 - No cabe - Ya se considera cuando se resta el tamaño de memoria del proceso a introducir (memoriaAuxiliar[$siguienteProcesoAMeter]) de la memoria libre (mem_libre) y comprueba >=0 en comprobacionSiguienteProcesoParaMeterMemoria()
#FR_29680            noCabe0Cabe1=0
#FR_29690            reubicarContinuidad=0
#FR_2970Menú de elección de entrada de datos.
#FR_29710        fi
#FR_29720No necesario
#FR_297302 - Lo meterá en memoria a trozos.
#FR_29740            noCabe0Cabe1=1
#FR_29750            reubicarContinuidad=0
#FR_29760            reubicarReubicabilidad=0
#FR_29770        fi
#FR_29780No necesario
#FR_297904 -
#FR_2980Menú de elección de algoritmo de gestión de procesos.
#FR_29810            reubicarContinuidad=0
#FR_29820            reubicarReubicabilidad=0
#FR_29830        fi
#FR_29840No necesario
#FR_298507 -
#            noCabe0Cabe1=0 - No cabe - Ya se considera cuando se resta el tamaño de memoria del proceso a introducir (memoriaAuxiliar[$siguienteProcesoAMeter]) de la memoria libre (mem_libre) y comprueba >=0 en comprobacionSiguienteProcesoParaMeterMemoria()
#FR_29870            reubicarContinuidad=0
#FR_29880            reubicarReubicabilidad=0
#FR_29890        fi
#FR_2990Menú de elección de continuidad.
#FR_299108 -
#FR_29920            noCabe0Cabe1=1
#FR_29930            reubicarContinuidad=0
#FR_29940            reubicarReubicabilidad=0
#FR_29950        fi
#FR_29960No necesario
#FR_2997010 -
#FR_29980            noCabe0Cabe1=1
#FR_29990            reubicarContinuidad=0
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
        if [[ $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorReubicarTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $encontradoHuecoMuyReducido -eq 1 && $continuidadNo0Si1 -eq 0 && $reubicabilidadNo0Si1 -eq 1 ]]; then 
#FR_30	TUTOR: José Manuel Saiz Diez
        fi
        if [[ $primeraUnidadFuturoProcesoSinreubicar -gt -1 && $encontradoHuecoMuyReducido -eq 1 && $reubicabilidadNo0Si1 -eq 1 ]]; then 
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#
            if [[ $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorReubicarTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 1 ]] ; then
#FR_30	TUTOR: José Manuel Saiz Diez
            fi
        fi
#
            if [[ $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorReubicarTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 0 ]] ; then
#FR_30	TUTOR: José Manuel Saiz Diez
            fi
        fi
    else
        noCabe0Cabe1=0
    fi
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez

#
#FR_30	TUTOR: José Manuel Saiz Diez
#
function comprobacionSiguienteProcesoParaMeterMemoria {
    if [[ $mem_libre -gt 0 && reubicarReubicabilidad -ne 1 && reubicarContinuidad -ne 1 ]]; then
        mem_libreTemp=$mem_libre
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
            encontradoHuecoMuyReducido=0
            raInicioProceso=-1
            contadorMeterMemoria=-1
            contadorMeterMemoriaTotal=0
            siguienteProcesoAMeter=$i
            if [[ $((mem_libreTemp - ${memoriaAuxiliar[$i]})) -ge 0 ]]; then
                noCabe0Cabe1=1
                for (( ra=0; ra<$mem_total; ra++ )); do
                    if [[ ${unidMemOcupadas[$ra]} == "_" && siguienteProcesoAMeter -gt -1 ]]; then
#FR_30	TUTOR: José Manuel Saiz Diez
                            contadorMeterMemoria=0
                            raInicioProceso=$ra
                        fi
                        contadorMeterMemoria=$((contadorMeterMemoria + 1))
                        contadorMeterMemoriaTotal=$((contadorMeterMemoriaTotal + 1))
                        if [[ $contadorMeterMemoria -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $primeraUnidadFuturoProcesoSinreubicar -eq -1 ]]; then 
#FR_30	TUTOR: José Manuel Saiz Diez
                            primeraUnidadFuturoProcesoSinreubicar=$raInicioProceso               
                        fi
                    elif [[ ${unidMemOcupadas[$ra]} != "_" && siguienteProcesoAMeter -ne -1 ]]; then
                        if [[ $contadorMeterMemoria -ne -1 && $contadorMeterMemoria -le $variableReubicar && $reubicabilidadNo0Si1 -eq 1 ]]; then 
#FR_30	TUTOR: José Manuel Saiz Diez
                            encontradoHuecoMuyReducido=1
                        fi
                        contadorMeterMemoria=-1
                    fi
                done
#
                    if [[ $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorMeterMemoriaTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 0 ]] ; then
#FR_30	TUTOR: José Manuel Saiz Diez
                    fi
                    if [[ $siguienteProcesoAMeter != -1 && $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorMeterMemoriaTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 0 ]] ; then
#FR_30	TUTOR: José Manuel Saiz Diez
                    fi
                fi
#FR_30	TUTOR: José Manuel Saiz Diez
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
#FR_30	TUTOR: José Manuel Saiz Diez
        bloqueados[$j]=1
    done
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez

#
#FR_30	TUTOR: José Manuel Saiz Diez
#
function meterProcesosBandaMemoria {
#FR_30	TUTOR: José Manuel Saiz Diez
        ud=0
        ra=0
#FR_30	TUTOR: José Manuel Saiz Diez
            ra=$primeraUnidadFuturoProcesoSinreubicar
        fi
#FR_30	TUTOR: José Manuel Saiz Diez
            if [[ ${unidMemOcupadas[$ra]} == "_" ]]; then
                unidMemOcupadas[$ra]=$po
                ud=$((ud+1))
                mem_libre=$((mem_libre - 1))
            fi
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
            ra=$((ra+1))
        done
    fi
#FR_30	TUTOR: José Manuel Saiz Diez

#
#FR_30	TUTOR: José Manuel Saiz Diez
#
function calculosPrepararLineasImpresionBandaMemoria {
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
    arribaMemoriaNC="   |"
    arribaMemoriaNCb="   |"
#FR_30	TUTOR: José Manuel Saiz Diez
    for (( ra=0; ra<$mem_total; ra++ )); do
#FR_30	TUTOR: José Manuel Saiz Diez
        for (( po=0; po<$nprocesos; po++ )); do
            if [[ $ra -eq 0 && ${unidMemOcupadas[$ra]} == $po ]]; then 
#proceso[$po]}))}"$NC
#proceso[$po]}))}"
            fi
#FR_30	TUTOR: José Manuel Saiz Diez
#proceso[$po]}))}"$NC
#proceso[$po]}))}"
#FR_30	TUTOR: José Manuel Saiz Diez
                arribaMemoriaNC=$arribaMemoriaNC${coloress[$po % 6]}"${varhuecos:1:$digitosUnidad}"$NC
                arribaMemoriaNCb=$arribaMemoriaNCb"${varhuecos:1:$digitosUnidad}"
            fi
        done
#FR_30	TUTOR: José Manuel Saiz Diez
        if [[ ${unidMemOcupadas[$ra]} == '_' ]]; then 
            arribaMemoriaNC=$arribaMemoriaNC"${varhuecos:1:$digitosUnidad}"$NC
            arribaMemoriaNCb=$arribaMemoriaNCb"${varhuecos:1:$digitosUnidad}"
        fi
    done

#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
    barraMemoriaNC="BM |"
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
    coloresPartesMemoria=(" ${coloresPartesMemoria[@]}" "${coloress[97]}" "${coloress[97]}" "${coloress[97]}")
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
            barraMemoriaNC=$barraMemoriaNC${coloress[${unidMemOcupadas[$ra]} % 6]}"${varfondos:1:$digitosUnidad}"$NC
            barraMemoriaNCbPantalla=$barraMemoriaNCbPantalla"${varfondos:1:$digitosUnidad}"
            colorunidMemOcupadas
        fi
#FR_30	TUTOR: José Manuel Saiz Diez
            barraMemoriaNC=$barraMemoriaNC" "${coloress[97]}"${varfondos:1:$digitosUnidad}"$NC
            barraMemoriaNCbPantalla=$barraMemoriaNCbPantalla"${varfondos:1:$digitosUnidad}"
            colorDefaultBMBT
        fi
    done

#FR_30	TUTOR: José Manuel Saiz Diez
    abajoMemoriaNC="   |"
    abajoMemoriaNCb="   |"
    for (( ra=0; ra<$mem_total; ra++ )); do
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
        if [[ $ra -eq 0 ]] ; then 
#ra}))}"${coloress[$po % 6]}"$ra"$NC
#FR_30	TUTOR: José Manuel Saiz Diez
        fi
        for (( po=0; po<$nprocesos; po++ )); do
#FR_30	TUTOR: José Manuel Saiz Diez
            if [[ $ra -ne 0 && ${unidMemOcupadas[$((ra-1))]} != $po  && ${unidMemOcupadas[$ra]} == $po ]] ; then 
#ra}))}"${coloress[$po % 6]}"$ra"$NC
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
            elif [[ $ra -ne 0 && ${unidMemOcupadas[$((ra-1))]} == $po  && ${unidMemOcupadas[$ra]} == $po ]] ; then 
                abajoMemoriaNC=$abajoMemoriaNC"${varhuecos:1:$digitosUnidad}"$NC
                abajoMemoriaNCb=$abajoMemoriaNCb"${varhuecos:1:$digitosUnidad}"
            fi
        done
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
        if [[ $ra -ne 0 && ${unidMemOcupadas[$((ra-1))]} != "_" && ${unidMemOcupadas[$ra]} == "_" ]] ; then 
#ra}))}"${coloress[97]}"$ra"$NC
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
#FR_30	TUTOR: José Manuel Saiz Diez
            abajoMemoriaNC=$abajoMemoriaNC"${varhuecos:1:$digitosUnidad}"$NC
            abajoMemoriaNCb=$abajoMemoriaNCb"${varhuecos:1:$digitosUnidad}"
        fi
    done
    
#FR_310 ancho de columnas estrechas en tabla de rangos
#FR_310 ancho de columnas estrechas en tabla de rangos
        bloques[$((unidMemOcupadas[0]))]=1
    fi
    for (( ra=1; ra<$mem_total; ra++ )); do
#FR_310 ancho de columnas estrechas en tabla de rangos
            bloques[$((unidMemOcupadas[$ra]))]=$((bloques[$((unidMemOcupadas[$ra]))] + 1)) 
        fi
    done
#FR_310 ancho de columnas estrechas en tabla de rangos
#FR_310 ancho de columnas estrechas en tabla de rangos
#FR_310 ancho de columnas estrechas en tabla de rangos
#FR_310 ancho de columnas estrechas en tabla de rangos
        else 
#FR_310 ancho de columnas estrechas en tabla de rangos
        fi
    done
#FR_310 ancho de columnas estrechas en tabla de rangos
        inicialNC[$i]=0
        finalNC[$i]=0
    done
#FR_310 ancho de columnas estrechas en tabla de rangos
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
#FR_3110Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#FR_31110Si el proceso entra en memoria, guarda la unidad de inicio
                        main=$((main+1))
                        contadori=$((contadori+1))
                    fi
                    if [[ $ra -ne 0  &&  ${unidMemOcupadas[$((ra - 1))]} != $po && ${unidMemOcupadas[$ra]} == $po ]] ; then
#FR_31120Si el proceso entra en memoria, guarda la unidad de inicio
                        main=$((main+1))
                        contadori=$((contadori+1))
                    fi
                    if [[ $ra -ne 0  &&  $ra -ne $((mem_total-1)) && ${unidMemOcupadas[$ra]} == $po && ${unidMemOcupadas[$((ra + 1))]} != $po ]] ; then
#FR_31130Si el proceso entra en memoria, guarda la unidad de final
                        mafi=$((mafi+1))
                        contadorf=$((contadorf+1))
                    fi
#FR_31140El último es un caso especial
#FR_31150Si el proceso entra en memoria, guarda la unidad de final aunque no haya terminado el proceso. No debería ya que hubiera tenido que empezar en el primer hueco y le habría cabido.
                        mafi=$((mafi+1))
                        contadorf=$((contadorf+1))
                    fi
                done
            done
        fi
    done
#FR_31160Final de preparar líneas para Banda de Memoria - calculosPrepararLineasImpresionBandaMemoria()

#
#FR_31170 Sinopsis: Genera la Banda de Memoria y la muestra en pantalla/informe 
#
#FR_31180Nueva versión y más simplificada, pero tiene 100 líneas más que la versión original (dibujarBandaMemoriaORI)
#FR_31190Ancho del terminal para adecuar el ancho de líneas a cada volcado

#FR_3120files[@]} ]]; do
#FR_31210Número de línea de la banda
    bandaProcesos=("    |")
    bandaProcesosColor=("$NORMAL    |")
    numCaracteres2=5
#FR_31220 Variable que indica si se ha añadido un proceso a la banda (1).
#unidMemOcupadas[@]};ii++)); do
#FR_31240El proceso está en memoria y se imprimirá
#FR_31250El texto no cabe en la terminal
#FR_31260 Se pasa a la siguiente línea
                bandaProcesos[$nn]="     "
                bandaProcesosColor[$nn]="     "
                numCaracteres2=5
            fi
#FR_31270 El texto no cabe en la terminal
                xx=0
            fi
#FR_31280Se añade el proceso a la banda
#proceso[$((${unidMemOcupadas[$ii]}))]}))}
                bandaProcesos[$nn]+=`echo -e "${proceso[$((${unidMemOcupadas[$ii]}))]}""$espaciosfinal"`
                bandaProcesosColor[$nn]+=`echo -e "${coloress[${unidMemOcupadas[$ii]} % 6]}${proceso[$((${unidMemOcupadas[$ii]}))]}""$NORMAL$espaciosfinal"`
                numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
                xx=1
            else
#FR_3130Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#FR_31310Se pasa a la siguiente línea
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
#FR_31320El texto no cabe en la terminal
#FR_31330Se pasa a la siguiente línea
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
#FR_31340Añadir final de banda
#FR_31350El texto no cabe en la terminal
#FR_31360Se pasa a la siguiente línea
        bandaProcesos[$nn]="     "
        bandaProcesosColor[$nn]="     "
        numCaracteres2=5
    fi
    bandaProcesos[$nn]+=`echo -e "|"`
    bandaProcesosColor[$nn]+=`echo -e "$NORMAL|"`

#FR_31370 GENERACIÓN STRING DE MEMORIA (Línea 2 de la Banda de Memoria)
#FR_31380Línea de la banda
    bandaMemoria=(" BM |")
    bandaMemoriaColor=("$NORMAL BM |")
    numCaracteres2=5
    espaciosAMeter=${varfondos:1:$digitosUnidad}
    guionesAMeter=${varguiones:1:$digitosUnidad}
    asteriscosAMeter=${varasteriscos:1:$digitosUnidad}
    fondosAMeter=${varfondos:1:$digitosUnidad}
    sumaTotalMemoria=0
#FR_31390Variable que indica si se ha añadido un proceso a la banda
    for (( i=0; i<$nprocesos; i++)); do 
#FR_3140files[@]} ]]; do
	done
			
#unidMemOcupadas[@]};ii++)); do
#FR_31420El proceso está en memoria y se imprimirá
#FR_31430El texto no cabe en la terminal
#FR_31440Se pasa a la siguiente línea
                bandaMemoria[$nn]="     "
                bandaMemoriaColor[$nn]="     "
                numCaracteres2=5
            fi
#paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}))}
#FR_31460Si no hay página se mete asterisco en BN.
#paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}))}"*"
#FR_31480Y si hay página se mete espacios y el número.
#paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}))}
			fi
            bandaMemoria[$nn]+=`echo -e "$espaciosasteriscofinal${paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}"`
            bandaMemoriaColor[$nn]+=`echo -e "$NC${colorfondo[${unidMemOcupadas[$ii]} % 6]}$espaciosfinal${paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}$NC"`
#FR_3150No es necesario. Existe por si se modifica y no se revisa el until anterior.
            numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
            if [[ $ii -ne 0 ]]; then
                if [[ ${unidMemOcupadas[$((ii - 1))]} !=  "_" ]]; then 
                    if [[ $xx -eq 1 && ${proceso[$((${unidMemOcupadas[$ii]}))]} != ${proceso[$((${unidMemOcupadas[$((ii - 1))]}))]} ]]; then
                        xx=0
                    fi
                fi
            fi
#FR_31510El proceso no está en memoria y no puede representarse en la Banda de Memoria.
            xx=0
#FR_31520El texto no cabe en la terminal
#FR_31530Se pasa a la siguiente línea
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

#FR_31550Añadir final de banda
#FR_31560El texto no cabe en la terminal
#FR_31570Se pasa a la siguiente línea
        bandaMemoria[$nn]="     "
        bandaMemoriaColor[$nn]=$NORMAL"     "
        numCaracteres2=5
    fi
#FR_31580 TODO: CAMBIAR NÚMERO DE MEMORIA
#FR_31590 TODO: CAMBIAR NÚMERO DE MEMORIA

#FR_3160Fin de menuAyuda()
#FR_31610 Línea de la banda
    bandaPosicion=("    |")
    bandaPosicionColor=("$NORMAL    |")
    numCaracteres2=5
#FR_31620Variable que indica si se ha añadido un proceso a la banda
#unidMemOcupadas[@]};ii++)); do
#FR_31640El proceso está en memoria y se imprimirá
#FR_31650 El texto no cabe en la terminal
#FR_31660 Se pasa a la siguiente línea
                bandaPosicion[$nn]="     "
                bandaPosicionColor[$nn]="     "
                numCaracteres2=5
            fi
#FR_31670 El texto no cabe en la terminal
                xx=0
            fi
#FR_31680Se añade el proceso a la banda
#FR_31690ii}))}
                bandaPosicion[$nn]+=`echo -e "$espaciosfinal""$ii"`
                bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal""$ii"`
                numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
                xx=1
            else
#FR_3170 Sinopsis: Menú inicial con ayuda y ejecución
#FR_31710Se pasa a la siguiente línea
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
#FR_31720El texto no cabe en la terminal
#FR_31730Se pasa a la siguiente línea
                bandaPosicion[$nn]="     "
                bandaPosicionColor[$nn]="     "
                numCaracteres2=5
            fi
            if [[ $ii -ne 0 ]]; then
                if [[ ${unidMemOcupadas[$((ii - 1))]} != "_" ]]; then
#FR_31740ii}))}
                    bandaPosicion[$nn]+=`echo -e "$espaciosfinal""$ii"`
                    bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal""$ii"`
                else
                    espaciosfinal=${varhuecos:1:$(($digitosUnidad))}
                    bandaPosicion[$nn]+=`echo -e "$espaciosfinal"`
                    bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal"`
                fi
            else
#FR_31750ii}))}
                bandaPosicion[$nn]+=`echo -e "$espaciosfinal""$ii"`
                bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal""$ii"`
            fi
            numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
        fi
    done
#FR_31760Añadir final de banda
#FR_31770El texto no cabe en la terminal
#FR_31780 Se pasa a la siguiente línea
        bandaPosicion[$nn]="     "
        bandaPosicionColor[$nn]="$NORMAL     "
        numCaracteres2=5
    fi
    bandaPosicion[$nn]+=`echo -e "|"`
    bandaPosicionColor[$nn]+=`echo -e "$NORMAL|"`

#FR_31790 IMPRIMIR LAS 3 LÍNEAS DE LA BANDA DE MEMORIA (COLOR y BN a pantalla y ficheros)
#bandaProcesos[@]}; jj++ )); do
        echo -e "${bandaProcesosColor[$jj]}" | tee -a $informeConColorTotal
        echo -e "${bandaMemoriaColor[$jj]}" | tee -a $informeConColorTotal
        echo -e "${bandaPosicionColor[$jj]}\n" | tee -a $informeConColorTotal
        echo -e "${bandaProcesos[$jj]}" >> $informeSinColorTotal
        echo -e "${bandaMemoria[$jj]}" >> $informeSinColorTotal
        echo -e "${bandaPosicion[$jj]}\n" >> $informeSinColorTotal
    done
#FR_31810Se vacía el auxiliar que reubica la memoria.
#FR_31820Se borran los datos del auxiliar.
        unidMemOcupadasAux[$ca]="_"
    done
#FR_31830Se vacían bloques
#FR_31840Se borran los datos del auxiliar.
         bloques[$ca]=0
    done
#FR_31850Se vacían las posiciones
    nposiciones=0
#FR_31860Se vacían posiciones iniciales y finales para borrar elementos innecesarios
    for (( i=0; i<$nposiciones; i++ )) ; do
         inicialNCmodelo[$i]=0
    done
    for (( i=0; i<$nposiciones; i++ )) ; do 
         finalNCmodelo[$i]=0
    done
#FR_31870Fin de la nueva versión de dibujarBandaMemoria()

#
#FR_31880 Sinopsis: Prepara la banda de tiempos de procesos en cada volcado - PRUEBA DE COPIAR LÍNEA A lÍNEA
#
function calculosImpresionBandaTiempos { 
#FR_31890Sucesión: Crear las tres líneas de la banda de tiempo y se generan los bloques que componen la memoria usada por cada proceso en memoria.
#FR_3190Menú de elección de algoritmo de gestión de procesos.
#FR_31910Se trabaja simultaneamente con la línea en b/n, en color, y con el array coloresPartesTiempo (o memoria) que guarda el color de cada caracter del terminal.
#FR_31920dibujasNC es el array que guarda cúantas unidades quedan por dibujar de un proceso
        
#FR_31930A... Primero. Se trata la entrada por separado hasta que entre el primer proceso
#FR_31940En T=0 se pone el "rótulo".
#FR_31950Determina el número de caracteres a inmprimir en cada línea.
    arribatiempoNC_0="    |"
    arribatiempoNCb_0="    |"
    tiempoNC_0=" BT |"
    tiempoNCb_0=" BT |"
    abajotiempoNC_0="    |"
    abajotiempoNCb_0="    |"
#FR_31960Unidades ya incluidas en las variables tiempoNC_0,...
    colorDefaultInicio
#FR_31970Primero se meten blancos en tiempoNC_0,... hasta la legada del primer proceso, si lo hay.
#FR_31980En el caso en que el primer proceso entre más tarde que 0, se introducen blancos iniciales en tiempoNC_0,....
        arribatiempoNC=$arribatiempoNC_0"${varhuecos:1:$(($digitosUnidad))}"$NC 
        arribatiempoNCb=$arribatiempoNCb_0"${varhuecos:1:$(($digitosUnidad))}"
        tiempoNC=$tiempoNC_0"${varhuecos:1:$(($digitosUnidad))}"$NC 
        tiempoNCb=$tiempoNCb_0"${varhuecos:1:$(($digitosUnidad))}"
        abajotiempoNC=$abajotiempoNC_0"${varhuecos:1:$(($digitosUnidad - 1))}0"$NC
        abajotiempoNCb=$abajotiempoNCb_0"${varhuecos:1:$(($digitosUnidad - 1))}0"
        colorDefaultBMBT
    fi
#FR_31990Hasta que se alcance reloj dibujar blancos en tiempoNC_0,....
        for (( i=0 ; i<$(($reloj)) ; i++ )) ; do
            if [[ $tiempodibujado -eq 0 ]]; then
                arribatiempoNC=$arribatiempoNC_0"${varhuecos:1:$(($digitosUnidad))}""${coloress[$i % 6]}"
                arribatiempoNCb=$arribatiempoNCb_0"${varhuecos:1:$(($digitosUnidad))}"
#FR_320 ancho de columnas anchas en tabla de rangos
                tiempoNCb=$tiempoNCb_0"${varguiones:1:$(($digitosUnidad))}"
                abajotiempoNC=$abajotiempoNC_0"${varhuecos:1:$(($digitosUnidad - 1))}0"
                abajotiempoNCb=$abajotiempoNCb_0"${varhuecos:1:$(($digitosUnidad - 1))}0"
                tiempodibujado=$(($tiempodibujado + 1))
#FR_320 ancho de columnas anchas en tabla de rangos
                arribatiempoNC=$arribatiempoNC"${varhuecos:1:$(($digitosUnidad))}""${coloress[$i % 6]}"
                arribatiempoNCb=$arribatiempoNCb"${varhuecos:1:$(($digitosUnidad))}"
#FR_320 ancho de columnas anchas en tabla de rangos
                tiempoNCb=$tiempoNCb"${varguiones:1:$(($digitosUnidad))}"
                abajotiempoNC=$abajotiempoNC"${varhuecos:1:$(($digitosUnidad))}"
                abajotiempoNCb=$abajotiempoNCb"${varhuecos:1:$(($digitosUnidad))}"
                tiempodibujado=$(($tiempodibujado + 1))
            fi
        done
    fi
    
#FR_320 ancho de columnas anchas en tabla de rangos
#FR_320 ancho de columnas anchas en tabla de rangos
#FR_320 ancho de columnas anchas en tabla de rangos
#FR_320 ancho de columnas anchas en tabla de rangos
#FR_320 ancho de columnas anchas en tabla de rangos
#FR_320 ancho de columnas anchas en tabla de rangos
        if [[ ${nomtiempo[$proanterior]} == 1 && ${dibujasNC[$proanterior]} -eq ${tejecucion[$proanterior]} ]]; then 
#FR_320 ancho de columnas anchas en tabla de rangos
#FR_3210Menú de elección de reubicabilidad.
            for (( i=0 ; i<$contad; i++ )); do
                arribatiempoNC=$arribatiempoNC"${varhuecos:1:$(($digitosUnidad))}"$NC
                arribatiempoNCb=$arribatiempoNCb"${varhuecos:1:$(($digitosUnidad))}""222"
#FR_32110Cambiados a varfondos
                tiempoNCb=$tiempoNCb"${varguiones:1:$(($digitosUnidad))}"
                abajotiempoNC=$abajotiempoNC"${varhuecos:1:$(($digitosUnidad))}"$NC
                abajotiempoNCb=$abajotiempoNCb"${varhuecos:1:$(($digitosUnidad))}"
                colorAnterior
                tiempodibujado=$(($tiempodibujado + 1))
            done
            dibujasNC[$proanterior]=0
        fi 
#FR_32120Fin de los procesos terminados pendientes de imprimir en la banda de tiempo
#FR_321302.Se añade el nombre del último proceso que entra en ejecución y se marca como nombrado (entra en ejecución pero no hay que dibujar nada).
    for (( po=0; po<$nprocesos; po++)) ; do
        if ( [[ $tiempodibujado -eq $reloj && ${dibujasNC[$po]} -eq ${tejecucion[$po]} && ${estad[$po]} -eq 3 ]] ) ; then 
            arribatiempoNC=$arribatiempoNC"${coloress[$po % 6]}${proceso[$po]}""${varhuecos:1:$(($digitosUnidad - ${proceso[$po]}))}"$NC
            arribatiempoNCb=$arribatiempoNCb"${proceso[$po]}""${varhuecos:1:$(($digitosUnidad - ${proceso[$po]}))}"
#FR_32140Propuesto meter varfondos
            tiempoNCb=$tiempoNCb"${varhuecos:1:$(($digitosUnidad))}"
#FR_32150reloj}))}""$reloj"$NC
#FR_32160reloj}))}""$reloj"
            tiempodibujado=$(($tiempodibujado + 1))
        fi
#FR_32170Se marca como nombrado
    done
#FR_32180Final de los cálculos para la impresión de la banda de memoria de los volcados - calculosImpresionBandaTiempos()

#
#FR_32190 Sinopsis: Imprime las tres líneas de la banda de tiempo. Permite mostrar el orden de ejecución de los
#FR_3220Menú de elección del número de ensayos automáticos a realizar de forma continua.
#
function dibujarBandaTiempos {     
#FR_32210 Variable para almacenar la suma total de tiempos de llegada y ejecución
#FR_32220 Número más alto entre la suma los tiempos de llegada y ejecución totales, y la página de mayor número
    local maxCaracteres=0
#FR_32230 Longitud en número de dígitos de cada unidad
    if [[ $maxCaracteres -eq 2 ]]; then
#FR_32240 El mínimo de caracteres tiene que ser 3 para que entren los nombres de
    fi
#FR_32250Ancho del terminal para adecuar el ancho de líneas a cada volcado
#proceso[@]}; s++)); do
        if [[ ${estado[$s]} == "En ejecución" ]]; then
#FR_32270En cada casilla contiene el número de orden del proceso que se ejecuta en cada instante. Sólo puede haber un proceso en cada instante.
        fi
    done

#FR_32280 GENERACIÓN STRING DE LA BANDA DE TIEMPOS (Línea 1 de la Banda de Tiempos)
    local bandaProcesos=("    |")
    local bandaProcesosColor=($NORMAL"    |")
#FR_32290 Línea de la banda
    local numCaracteres=5
    espaciosAMeter=${varhuecos:1:$maxCaracteres}
    guionesAMeter=${varguiones:1:$maxCaracteres}
    fondosAMeter=${varfondos:1:$maxCaracteres}
    for ((k = 0; k <= $reloj; k++)); do
#FR_3230Se definen y ejecutan los ensayos automáticos y se recogen los datos en ficheros secuenciales.
#FR_32310Si hay proceso en ejecución para T=0
#FR_32320Se imprime el nombre del proceso en ejecución en ese instante definido por la posición almacenada en procPorUnidadTiempoBT
				bandaProcesos[n]+=`printf "%-$(($maxCaracteres))s" $p`
				bandaProcesosColor[n]+=`printf "${coloress[${procPorUnidadTiempoBT[$k]} % 6]}%-$(($maxCaracteres))s$NORMAL" $p`
#FR_32330Si no hay proceso en ejecución para T=0
                bandaInstantes[n]+=`echo -e $espaciosAMeter`
                bandaInstantesColor[n]+=`echo -e $espaciosAMeter`
            fi
            numCaracteres=$(($numCaracteres + $maxCaracteres))
#FR_32340Si NO T=0
#FR_32350 El texto no cabe en la terminal
#FR_32360 Se pasa a la siguiente línea
				bandaProcesos[n]="     "
				bandaProcesosColor[n]="     "
				numCaracteres=5
			fi
#FR_32370Si se mantiene el mismo proceso en ejecución se imprimen espacios
				bandaProcesos[n]+=`printf "%$(($maxCaracteres))s" ""`
				bandaProcesosColor[n]+=`printf "%$(($maxCaracteres))s" ""`
#FR_32380Si no se mantiene el mismo proceso en ejecución se imprime el nombre del nuevo proceso
#FR_32390Se imprime el nombre del proceso en ejecución en ese instante definido por la posición almacenada en procPorUnidadTiempoBT
				bandaProcesos[n]+=`printf "%-$(($maxCaracteres))s" $p`
				bandaProcesosColor[n]+=`printf "${coloress[${procPorUnidadTiempoBT[$k]} % 6]}%-$(($maxCaracteres))s$NORMAL" $p`
			fi
			numCaracteres=$(($numCaracteres + $maxCaracteres))
        fi
    done
#FR_3240Menú de elección de algoritmo de gestión de procesos.
#FR_32410 El texto no cabe en la terminal
#FR_32420 Se pasa a la siguiente línea
        bandaProcesos[n]="     "
        bandaProcesosColor[n]="     "
        numCaracteres=5
    fi
    bandaProcesos[n]+=`printf "|    %$(($maxCaracteres))s" ""`
    bandaProcesosColor[n]+=`printf "|    %$(($maxCaracteres))s" ""`

#FR_32430 GENERACIÓN STRING DE LA BANDA DE TIEMPOS (Línea 2 de la Banda de Tiempos)
    local bandaTiempo=(" BT |")
    local bandaTiempoColor=(" BT |")
#FR_32440 Línea de la banda
    local numCaracteres=5
    for (( i=0; i<$nprocesos; i++)); do 
#FR_32450Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
	done
    for ((k = 0; k <= $reloj; k++)); do
#FR_32460 El texto no cabe en la terminal
#FR_32470 Se pasa a la siguiente línea
            bandaTiempo[n]="     "
            bandaTiempoColor[n]="     "
            numCaracteres=5
        fi
#FR_32480Si el instante considerado es igual al tiempo actual
#FR_32490Si no hay proceso en ejecución asociado a ese instante. Vale 0 si no está definido porque la inicialización empieza en posición=1.
				if [[ $k -eq 0 ]]; then
					espaciosguionfinal=${varhuecos:1:$(($digitosUnidad - 1))}"-"
					bandaTiempo[n]+=$espaciosguionfinal
					bandaTiempoColor[n]+=$espaciosguionfinal
            	else
					bandaTiempo[n]+=$espaciosAMeter
					bandaTiempoColor[n]+=$espaciosAMeter
            	fi
#FR_3250Menú de elección de continuidad.
#paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}))}
				bandaTiempo[n]+=$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}
				bandaTiempoColor[n]+=$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}
			fi
#FR_32520Si el instante considerado NO es igual al tiempo actual
#FR_32530 Si NO hay proceso en ejecución asociado a ese instante. Vale 0 si no está definido porque la inicialización empieza en posición=1.
                espaciosguionfinal=${varhuecos:1:$(($digitosUnidad - 1))}"-"
                bandaTiempo[n]+=$espaciosguionfinal
                bandaTiempoColor[n]+=$fondosAMeter
#FR_32540 Si hay proceso en ejecución asociado a ese instante
#paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}))}
                bandaTiempo[n]+=$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}$NC
#FR_32560Si NO es T=0
                    bandaTiempoColor[n]+=$NC${colorfondo[${procPorUnidadTiempoBT[$k]} % 6]}$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}$NC
#FR_32570Si es T=0
#FR_32580Si T=0 no se colorea el fondo
						bandaTiempoColor[n]+=$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}$NC
#FR_32590Si T>0 se pintará el fondo del color del proceso en ejecución.
                        bandaTiempoColor[n]+=$NC${colorfondo[${procPorUnidadTiempoBT[$k]} % 6]}$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}$NC                    
                    fi
                fi
#FR_3260Menú de elección de reubicabilidad.
            fi
        fi
        numCaracteres=$(($numCaracteres + $maxCaracteres))
    done

#FR_32610 Añadir final de banda
#FR_32620 El texto no cabe en la terminal
#FR_32630 Se pasa a la siguiente línea
        bandaTiempo[n]="     "
        bandaTiempoColor[n]="     "
        numCaracteres=5
    fi
    bandaTiempo[n]+=`printf "|T= %-${maxCaracteres}d" $reloj`
    bandaTiempoColor[n]+=$NC`printf "|T= %-${maxCaracteres}d" $reloj`

#FR_32640 GENERACIÓN STRING DE LAS UNIDADES DE LOS INSTANES DE TIEMPO (Línea 3 de la Banda de Tiempos)
    local bandaInstantes=("    |")
    local bandaInstantesColor=($NC"    |")
#FR_32650 Línea de la banda
    local numCaracteres=5
    for ((k = 0; k <= $reloj; k++)); do
#FR_32660Cuando se mantiene el mismo proceso en ejecución
#FR_32670En T=0 o T=momento actual, aumenta el contenido de las bandas
#FR_32680 El texto no cabe en la terminal
#FR_32690 Se pasa a la siguiente línea
                    bandaInstantes[n]="     "
                    bandaInstantesColor[n]=$NC"     "
                    numCaracteres=5
                fi
                bandaInstantes[n]+=`printf "%${maxCaracteres}d" $k`
                bandaInstantesColor[n]+=`printf "%${maxCaracteres}d" $k`
                numCaracteres=$(($numCaracteres + $maxCaracteres))
#FR_3270Menú de elección del número de ensayos automáticos a realizar de forma continua.
#FR_32710 El texto no cabe en la terminal
#FR_32720 Se pasa a la siguiente línea
                    bandaInstantes[n]="     "
                    bandaInstantesColor[n]=$NC"     "
                    numCaracteres=5
                fi
                bandaInstantes[n]+=`printf "%${maxCaracteres}s" ""`
                bandaInstantesColor[n]+=`printf "%${maxCaracteres}s" ""`
                numCaracteres=$(($numCaracteres + $maxCaracteres))
            fi
#FR_32730Cuando no se mantiene el mismo proceso en ejecución
#FR_32740 El texto no cabe en la terminal
#FR_32750 Se pasa a la siguiente línea
                bandaInstantes[n]="     "
                bandaInstantesColor[n]=$NC"     "
                numCaracteres=5
            fi
            bandaInstantes[n]+=`printf "%${maxCaracteres}d" $k`
            bandaInstantesColor[n]+=`printf "%${maxCaracteres}d" $k`
            numCaracteres=$(($numCaracteres + $maxCaracteres))
        fi
    done
#FR_32760 Añadir final de banda
#FR_32770 El texto no cabe en la terminal
#FR_32780 Se pasa a la siguiente línea
        bandaInstantes[n]="     "
        bandaInstantesColor[n]=$NC"     "
        numCaracteres=5
    fi
    bandaInstantes[n]+=`printf "|    %$(($maxCaracteres))s" ""`
    bandaInstantesColor[n]+=`printf "|    %$(($maxCaracteres))s" ""`

#FR_32790 IMPRIMIR LAS 3 LÍNEAS DE LA BANDA DE TIEMPOS (COLOR y BN a pantalla y ficheros temporales) - Se meten ahora en los temporales para que la banda de tiempo vaya tras la banda de memoria
#bandaProcesos[@]}; i++ )); do
        echo -e "${bandaProcesos[$i]}" >> $informeSinColorTotal
        echo -e "${bandaTiempo[$i]}" >> $informeSinColorTotal
        echo -e "${bandaInstantes[$i]}\n" >> $informeSinColorTotal
        echo -e "${bandaProcesosColor[$i]}" | tee -a $informeConColorTotal
        echo -e "${bandaTiempoColor[$i]}" | tee -a $informeConColorTotal
        echo -e "${bandaInstantesColor[$i]}\n" | tee -a $informeConColorTotal
    done    

#
#FR_32810Se determina el modo de ejecución (Enter, sin paradas, con paradas con tiempo predefinido)
#FR_32820Impresión de forma manual (pulsando enter para pasar)
        echo -e " Pulse ENTER para continuar.$NC" | tee -a $informeConColorTotal
        echo -e " Pulse ENTER para continuar." >> $informeSinColorTotal
        read continuar
        echo -e $continuar "\n" >> $informeConColorTotal
        echo -e $continuar "\n" >> $informeSinColorTotal
#FR_32830Cierre de fi - optejecucion=1 (seleccionMenuModoTiempoEjecucionAlgormitmo=1)
#FR_32840Impresión de forma sin parar (pasa sin esperar, de golpe)
        echo -e "───────────────────────────────────────────────────────────────────────$NC" | tee -a $informeConColorTotal
        echo -e "───────────────────────────────────────────────────────────────────────" >> $informeSinColorTotal
#FR_32850Cierre de fi - optejecucion=2 (seleccionMenuModoTiempoEjecucionAlgormitmo=2)
#FR_32860Impresión de forma automatica (esperando x segundo para pasar)
        echo -e " Espere para continuar...$NC\n" | tee -a $informeConColorTotal
        echo -e " Espere para continuar...\n" >> $informeSinColorTotal
        sleep $tiempoejecucion 
#FR_32870Cierre de fi - optejecucion=3 (seleccionMenuModoTiempoEjecucionAlgormitmo=3)
#FR_32880Fin de dibujarBandaTiempos()

#
#FR_32890 Sinopsis: Muestra en pantalla/informe una tabla con el resultado final tras la ejecución
#FR_3290Menú de elección de algoritmo de gestión de procesos.
#
function resultadoFinalDeLaEjecucion {
    echo "$NORMAL Procesos introducidos (ordenados por tiempo de llegada):" | tee -a $informeConColorTotal
    echo -e " ┌─────┬─────┬─────┬─────┬──────┬──────┐" | tee -a $informeConColorTotal
    echo -e " │ Ref │ Tll │ Tej │ Mem │ TEsp │ Tret │" | tee -a $informeConColorTotal   
    echo -e " ├─────┼─────┼─────┼─────┼──────┼──────┤" | tee -a $informeConColorTotal
    echo -e " ┌─────┬─────┬─────┬─────┬──────┬──────┐" >> $informeSinColorTotal
    echo -e " │ Ref │ Tll │ Tej │ Mem │ TEsp │ Tret │" >> $informeSinColorTotal
    echo -e " ├─────┼─────┼─────┼─────┼──────┼──────┤" >> $informeSinColorTotal
    
#FR_32910Se usa m porque i recorre los procesos y m controla las unidades usadas por cada proceso, normalmente 0 o 1, y también las unidades de los n trozos de memoria asociados a cada proceso.
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

#FR_330 VARIABLES PARA DESTACAR TEXTO CON COLOR
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
#FR_330 VARIABLES PARA DESTACAR TEXTO CON COLOR
#FR_330 VARIABLES PARA DESTACAR TEXTO CON COLOR
#FR_330 VARIABLES PARA DESTACAR TEXTO CON COLOR

#FR_330 VARIABLES PARA DESTACAR TEXTO CON COLOR
#FR_330 VARIABLES PARA DESTACAR TEXTO CON COLOR
        fi
        suma_contadorAlgPagFallosProcesoAcumulado=$(($suma_contadorAlgPagFallosProcesoAcumulado + ${contadorAlgPagFallosProcesoAcumulado[$i]}))
        suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado=$(($suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado + ${contadorAlgPagExpulsionesForzadasProcesoAcumulado[$i]}))
    done
    echo -e "\n ┌─────────────────────────────┬─────────────────────────────┐" | tee -a $informeConColorTotal 
#promedio_espera})$NC " \
#FR_330 VARIABLES PARA DESTACAR TEXTO CON COLOR
    echo -e " └─────────────────────────────┴─────────────────────────────┘" | tee -a $informeConColorTotal 
    echo -e "\n ┌─────────────────────────────┬─────────────────────────────┐" >> $informeSinColorTotal
#promedio_espera}) " \
#FR_33110promedio_retorno}) │" >> $informeSinColorTotal
    echo -e " └─────────────────────────────┴─────────────────────────────┘" >> $informeSinColorTotal
	echo -e "\n ┌───────────────────────────────────────────────────────────┐" | tee -a $informeConColorTotal 
#FR_33120suma_contadorAlgPagFallosProcesoAcumulado})$NC                          │" | tee -a $informeConColorTotal
    if [[ $seleccionMenuAlgoritmoGestionProcesos -eq 5 ]]; then
#FR_33130suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado})$NC  │" | tee -a $informeConColorTotal
    fi
	echo -e " └───────────────────────────────────────────────────────────┘" | tee -a $informeConColorTotal 
	echo -e "\n ┌───────────────────────────────────────────────────────────┐" >> $informeSinColorTotal
#FR_33140suma_contadorAlgPagFallosProcesoAcumulado})                          │" >> $informeSinColorTotal
    if [[ $seleccionMenuAlgoritmoGestionProcesos -eq 5 ]]; then
#FR_33150suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado})  │" >> $informeSinColorTotal
    fi
	echo -e " └───────────────────────────────────────────────────────────┘" >> $informeSinColorTotal
#FR_33160No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -ne $ROJO"\n\n Pulsa ENTER para continuar "$NORMAL
		read enter
	fi
#FR_33170Fin de resultadoFinalDeLaEjecucion()

#
#FR_33180 Sinopsis: Permite introducir las particiones y datos desde otro fichero (predefinido).
#
function mostrarInforme {
#FR_33190No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -e "\n Final del proceso, puede consultar la salida en el fichero informeBN.txt" 
		echo -e "\n Pulse enter para las opciones de visualización del fichero informeBN.txt..."
		read enter
	fi
#FR_3320Menú de elección del número de ensayos automáticos a realizar de forma continua.
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
#FR_33210Se comprueba que el número introducido por el usuario es de 1 a 10
		until [[ 0 -lt $num && $num -lt 5 ]];  do
			echo -ne "\n Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
			echo -ne "\n Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
			read num
			echo -ne "$num\n\n" >> $informeConColorTotal
			echo -ne "$num\n\n" >> $informeSinColorTotal
		done
        case $num in
            '1' )  
#FR_33220                clear
                cat $informeSinColorTotal
                exit 0
                ;;
            '2' ) 
#FR_33230                clear
                gedit $informeSinColorTotal
                exit 0
                ;;
            '3' )
#FR_33240                clear
                cat $informeConColorTotal
                exit 0
                ;;
            '4' )
#FR_33250                clear
                exit 0
                ;;
            *) 
                num=0
                cecho "Opción errónea, vuelva a introducir:" $FRED
        esac
    done
#FR_33260Fin de mostrarInforme()

#
#
#FR_33270 COMIENZO DEL PROGRAMA
#
#
function inicioNuevo {
#FR_33280Empieza el script
#proceso[@]}
#FR_3330Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos sobre los diferentes algoritmos de paginación y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.

#FR_33310 Se inicilizan las variables necesarias para la nueva línea del tiempo
#FR_33320Se dibuja tanto como tiempo de ejecución tengan
    if [[ seleccionMenuAlgoritmoGestionProcesos -ne 4 ]]; then 
#FR_33330Volcado de datos en pantalla tras pedir datos/introducción desde fichero.
    elif [[ seleccionMenuAlgoritmoGestionProcesos -eq 4 ]]; then 
#FR_33340Volcado de datos en pantalla tras pedir datos/introducción desde fichero.
    fi
    
#FR_33350B U C L E   P R I N C I P A L
#FR_33360Tiempo transcurrido desde el inicio del programa.
    contador=1
#FR_33370Controla la salida del bucle cuando finalicen todos los procesos.
#FR_33380Controla si hay procesos en ejecución.
#FR_33390Número de procesos definidos en el problema
    realizadoAntes=0

    while [[ "$parar_proceso" == "NO" ]]; do
#FR_3340Menú de elección del número de ensayos automáticos a realizar de forma continua.
        timepoAux=`expr $reloj + 1`

#FR_33410E N T R A R   E N   C O L A - Si el momento de entrada del proceso coincide con el reloj marcamos el proceso como en espera, en encola()
#FR_33420Bucle que pone en cola los procesos.
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

#FR_33430G U A R D A R   E N    M E M O R I A - Si un proceso está encola(), intento guardarlo en memoria, si cabe. Si lo consigo, lo marco como listo enmemoria().
#FR_33440Comprueba si el proceso en ejecución ha finalizado, y lo saca de memoria.
            if [[ ${enejecucion[$i]} -eq 1 && ${temp_rej[$i]} -eq 0 ]]; then 
#FR_33450Para que deje de estar en ejecución.
#FR_33460Para que deje de estar en memoria y deje espacio libre.
#FR_33470Se libera la memoria que ocupaba el proceso cuando termina.
                avisosalida[$i]=1
                evento=1
#FR_33480Pasa a estar no ocupada hasta que se vuelva a buscar si hay procesos en memoria que vayan a ser ejecutados.
#FR_33490Se guarda qué procesos han terminado (1) o no (0)
#FR_3350Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos sobre los diferentes algoritmos de gestión de procesos y de paginación y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
				estado[$i]="Finalizado"
#FR_33510Número de procesos que quedan por ejecutar.
                pos_inicio[$i]=""
                procFinalizado=$i
            fi
        done
        
#FR_33520Se actualiza la variable memoria al terminar los procesos.
        
#FR_33530Con esta parte se revisa la reubicabilidad, y si hay procesos se intentan cargar antes de usar los gestores de procesos, mientras que con la que hay en la reubicación, tras reubicar y producir un hueco al final de la memoria, se reintenta cargar procesos.
#FR_33540Se comprueba que haya espacio suficiente en memoria y se meten los procesos que se puedan de la cola para empezar a ejecutar los algoritmos de gestión de procesos.
        if [[ $mem_libre -gt 0 ]]; then  
#FR_33550Determinará si se debe o no hacer la reubicación de los procesos por condiciones de reubicabilidad. En caso de ser memoria no continua, si hay un hueco demasiado pequeño, y se va a usar como parte de la memoria a usar.
#FR_33560Determinará si se debe o no hacer la reubicación de los procesos por condiciones de continuidad. En caso de ser memoria continua, si no hay un hueco suficientemente grande en el que quepa pero sí en la suma de todos ellos.
#FR_33570Contiene los procesos que están en memoria de forma secuencial en la variable guardadoMemoria, y sus tamaños en tamanoGuardadoMemoria.
#FR_33580Se determina qué proceso es el siguiente en entrar en memoria, y dependiendo de la continuidad y reubicabilidad definidas, se establece si hay espacio en memoria.
#FR_33590Si hay que reubicar antes de meter más procesos, se hace.
#FR_3360Se vuelve a inicial la aplicación
#FR_33610Ajusta el bucle actual a la variable interna de la función.
                    comprobacionSiguienteProcesoParaMeterMemoria
                    meterProcesosBandaMemoria
#FR_33620Sin este if+break fallaba porque podía meter otro proceso en memoria si tenía el espacio suficiente, incluso colándose a otro proceso anterior.
						break
                    fi
                done
            else
#FR_33630Se reubica la memoria.
#FR_33640Se impide un nuevo volcado en pantalla en el que no se vea avance de la aplicación.
#FR_33650Se modifica restando una unidad para ajustar el reloj y variables temporales al anular un ciclo del bucle, ya que la variable timepoAux se modifica al principio del bucle principal mediante: timepoAux=`expr $reloj + 1`
            fi
        fi

#FR_33660Se inicializan las variables con diferentes acumulados en cada instante de reloj. Algunos acumulados sólo serían necesarios cuando se produzcan eventos, pero se podrían generalizar haciendo acumulados en cada instante.
		inicializarAcumulados 
        
#FR_33670 P L A N I F I C A R   P R O C E S O S
#FR_33680 Si hay procesos listos en memoria(), se ejecuta el que corresponde en función del criterio de planificación que,
#FR_33690 en este caso, es el que tenga una ejecución más corta de todos los procesos. Se puede expulsar a un proceso de la CPU
#FR_3370No es necesario. Existe por si se modifica y no se revisa el until anterior.
#FR_33710Si hay que reubicar antes de meter más procesos, se hace.
#FR_33720Mientras no haya un proceso en ejecución, se pone a -1. El gestor del algoritmo lo cambiará si procede.
            if [[ $alg == 1 ]]; then
#FR_33730Algoritmo de gestión de procesos: FCFS
            elif [[ $alg == 2 ]]; then
#FR_33740Algoritmo de gestión de procesos: SJF
            elif [[ $alg == 3 ]]; then
#FR_33750Algoritmo de gestión de procesos: SRPT
            elif [[ $alg == 4 ]]; then
#FR_33760Algoritmo de gestión de procesos: Prioridades
            elif [[ $alg == 5 ]]; then
#FR_33770Algoritmo de gestión de procesos: Round Robin
            fi
        fi
#FR_33780I M P R I M I R   E V E N T O S
#FR_33790Los eventos los determinan en las funciones gestionProcesosFCFS, gestionProcesosSJF y gestionProcesosSRPT
#FR_3380Fin de menuEnsayos()
#FR_33810Se muestran los eventos sucedidos, sobre la tabla resumen.
#FR_33820 C Á L C U L O   D E   L A   B A N D A   D E   M E M O R I A
#FR_33830 Habrá un array inicialmente relleno de "_" que se va llenando de las referencias de los procesos (memoria()). Después será usado para formar la banda de memoria.
#FR_33840 $po es el índice usado para los procesos y $ra para las posiciones de la memoria al recorrer el array.
#FR_33850 Hay otros arrays como el que se usa para generar los diferentes bloques que conforman cada proceso, relacionados con la reubicación (bloques()).
            calculosPrepararLineasImpresionBandaMemoria
#FR_33860 D I B U J O   D E   L A   T A B L A   D E   D A T O S   Y   D E   L A S   B A N D A S (Normalmente, por eventos)
#FR_33870 Los eventos suceden cuando se realiza un cambio en los estados de cualquiera de los procesos.
#FR_33880 Los tiempos T. ESPERA, T. RETORNO y T. RESTANTE sólo se mostrarán en la tabla cuando el estado del proceso sea distinto de "No ha llegado".
#FR_33890 Para ello hacemos un bucle que pase por todos los procesos que compruebe si el estado nollegado() es 0 y para cada uno de los tiempos, si se debe mostrar se guarda el tiempo, si no se mostrará un guión
#FR_3390 Sinopsis: Menú de elección del Algoritmo de Gestión de Procesos; FCFS, SJF, SRPT.
#FR_33910Prepara e imprime la tabla resumen de procesos en cada volcado
#FR_33920Imprime diferentes resúmenes de paginación.
#FR_33930Muestra el resumen de todos los fallos de paginación del proceso finnalizado
#FR_33940Para no volver a hacer la impresión del mismo proceso a lescoger procFinalizado en gestionProcesosFCFS, gestionProcesosSJF y gestionProcesosSRPT.
				procFinalizado=-1
			fi          
#FR_33950Verifica qué proceso está en cada marco y determina si se produce un nuevo fallo de página, y lo muestra.
#FR_33960Se imprime la banda de memoria. Nueva versión, más fácil de interpretar y adaptar, larga y con iguales resultados.
#FR_33970Se imprime la banda de tiempo
#FR_33980Cierre de Impresión Eventos
#FR_33990 Se incrementa el contador de tiempos de ejecución y de espera de los procesos y se decrementa
#FR_340NORMAL=$esc"[1;m"
#FR_340NORMAL=$esc"[1;m"
#FR_340NORMAL=$esc"[1;m"
        fi
#FR_340NORMAL=$esc"[1;m"
#FR_340NORMAL=$esc"[1;m"
#FR_340NORMAL=$esc"[1;m"
    echo -e "$NORMAL\n Tiempo: $tiempofinal  " | tee -a $informeConColorTotal
    echo -e " Ejecución terminada." | tee -a $informeConColorTotal
    echo -e "$NORMAL -----------------------------------------------------------\n" | tee -a $informeConColorTotal
    echo -e "\n Tiempo: $tiempofinal  " >> $informeSinColorTotal
    echo -e " Ejecución terminada." >> $informeSinColorTotal
    echo -e " -----------------------------------------------------------\n" >> $informeSinColorTotal
#FR_340NORMAL=$esc"[1;m"
#FR_340NORMAL=$esc"[1;m"
#FR_340NORMAL=$esc"[1;m"
	fi
#FR_340NORMAL=$esc"[1;m"

#
#
#
#
#FR_3410Comprobación de que el número introducido por el usuario es de 1 a 4
#FR_34110Regenera el árbol de directorios si no se encuentra.
#FR_34120Carátula inicial con autores, versiones y licencias
#FR_34130Elección de ejecución o ayuda
#FR_34140Inicio de la ejecución del programa

#FR_34150????????????????????
#llegada[@]}"z  z"
#echo "z procPorUnidadTiempoBT z"${procPorUnidadTiempoBT[@]}"z  z"
#echo "z estado z"${estado[@]}"z  z"
#for (( counter=0 ; counter<${memoria[$ejecutandoinst]} ; counter++ )); do
#FR_3420Fin de menuDOCPDF()
#FR_34210	for (( ii=0 ; ii<=$reloj ; ii++ )); do
#		echo -ne "-"$counter" "$ii" "${ResuFrecuenciaAcumulado[$ejecutandoinst,$counter,$ii]}
#FR_34230	done
#FR_34240	echo ""
#FR_34250done
#echo -ne $ROJO"\n\n Pulsa ENTER para continuar "$NORMAL
#FR_34270read enterContinuar
#
