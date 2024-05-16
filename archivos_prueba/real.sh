#!/bin/bash
#
#ES_10                       
#ES_20   AUTORES: Los alumnos de la asignatura Sistemas Operativos del Grado en Ingeniería Informática (2014-2024) - Universidad de Burgos 
#ES_30	TUTOR: José Manuel Saiz Diez
#ES_40  
#
#ES_50 Script realizado para la simulación de un SO que utilice diferentes modelos de gestión de procesos y memoria con un total de 480 opciones diferentes.
#ES_60 El algoritmo de gestión de procesos se basará en FCFS, SJF, SRPT, Prioridad Mayor y Menor (Apropiativo y No Apropiativo) y Round-Robin.
#ES_70 La gestión de memoria será paginada y podrá ser Continua y No continua, y Reubicable y no resubicable.
#ES_80 Y los algoritmos de paginación para la gestión de memoria junto con alguna de sus variantes: FIFO/Reloj/SegOp/Óptimo/MFU/LFU/NFU/MRU/LRU/NRU. 

#
#ES_90 VARIABLES DE EJECUCIÓN
#
#ES_100 seleccionMenuAlgoritmoGestionProcesos - Opciones de elección de algoritmo de gestión de Procesos (FCFS/SJF/SRPT/Prioridades/Round-Robin)
#ES_110 seleccionTipoPrioridad - Opciones del tipo de Prioridad (Mayor/Menor)
#ES_120 seleccionMenuApropiatividad - Opciones del tipo de Apropiatividad (Apropiativo/No Apropiativo)
#ES_130 seleccionMenuReubicabilidad - Opciones del tipo de memoria (Reubicable/No Reubicable)
#ES_140 seleccionMenuContinuidad - Opciones del tipo de memoria (Continua/No Continua)
#ES_150 seleccionMenuEleccionEntradaDatos - Opciones para la elección de fuente en la introducción de datos (Datos manual/Fichero de datos de última ejecución/Fichero de datos por defecto/Otro fichero de datos...
#ES_160 .../Rangos manual/Fichero de rangos de última ejecución/Fichero de rangos por defecto/Otro fichero de rangos...
#ES_170 .../Rangos aleatorios manual/Fichero de rangos aleatorios de última ejecución/Fichero de rangos aleatorios por defecto/Otro fichero de rangos aleatorios)
#ES_180 seleccionMenuModoTiempoEjecucionAlgormitmo - Opciones para la elección del tipo de ejecución (Por eventos/Automatico/Completo)
#ES_190 seleccionMenuPreguntaDondeGuardarDatosManuales - Opciones para la selección del fichero de datos de salida (datosDefault, Otros)
#ES_200 seleccionMenuPreguntaDondeGuardarRangosManuales - Opciones para la selección del fichero de rangos de salida (rangosDefault, Otros)
#ES_210 seleccionAlgoritmoPaginacion - Opciones para la selección del algoritmo de gestión fallos de paginación
#ES_220 seleccionNumEnsayos - Se define el número de ensayos a realizar para la recogida de las medias.
#ES_230 seleccionAlgoritmoPaginacion_uso_rec_valor - Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#ES_240 seleccionAlgoritmoPaginacion_frecuencia_valor - Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
#
#ES_250 VARIABLES DE REPRESENTACIÓN DEL MAPA DE MEMORIA
#
#ES_260 Ancho del terminal en cada Enter de ejecución de volcados
#ES_270 ancho de columnas estrechas en tabla resumen de procesos en los volcados 
#ES_280 ancho de columnas anchas en tabla resumen de procesos en los volcados 
#ES_290 ancho de columnas más anchas en tabla resumen de procesos en los volcados 
#ES_300 ancho de columnas muy anchas en tabla resumen de procesos en los volcados 
#ES_310 ancho de columnas estrechas en tabla de rangos 
#ES_320 ancho de columnas anchas en tabla de rangos 
varhuecos="                                                                                     "
varguiones="------------------------------------------------------------------------------------"
varasteriscos="*********************************************************************************"
varfondos="█████████████████████████████████████████████████████████████████████████████████████"
esc=$(echo -en "\033")
RESET=$esc"[0m"

#
#ES_330 VARIABLES PARA DESTACAR TEXTO CON COLOR
#
#ES_340NORMAL=$esc"[1;m"
#ES_350ROJO=$esc"[1;31m"
#ES_360VERDE=$esc"[1;32m"
#ES_370AMARILLO=$esc"[1;33m"
#ES_380AZUL=$esc"[1;34m"
#ES_390MORADO=$esc"[1;35m"
#ES_400CYAN=$esc"[1;36m"
#ES_410Variables de colores 
amarillo="\033[1;33m";
verde='\e[1;32m';
morado='\e[1;35m';
rojo='\e[1;31m';
cian='\e[1;36m';
gris='\e[1;30m';
azul='\e[1;34m';
blanco='\e[1bold;37m';
#ES_420reset
#ES_430Vector de colores
coloress=();
#
#
#
#ES_440 foreground magenta
#
#
#ES_450 foreground blue
#ES_460 foreground blue
#ES_470 foreground yellow
#
#ES_480 foreground red
#
#
#
#
#ES_490 foreground cyan
#
#ES_500 foreground green
#
#
#
#ES_510INVISIBLE
#ES_520Vector de colores con el fondo pintado. 
colorfondo=(); 
#ES_530 background cyan
#
#
#
#
#ES_540 background blue
#ES_550 background yellow
#
#ES_560 background red
#
#ES_570 background magenta
#ES_580 background green
#ES_590 background white
#ES_600 ANSI color codes
#ES_610 hicolor
#ES_620 underline
#ES_630 inverse background and foreground
#ES_640 foreground black
#ES_650 foreground white
#ES_660 background black

#
#ES_670     Tablas de trabajo (CAMBIAR ARRAYS Y VARIABLES)
#
#ES_680     nprocesos - Número total de procesos.
#ES_690     proceso() - Nombre del proceso (P01,...).
#ES_700     llegada() - Tiempo de llegada de los procesos.
#ES_710     ejecucion() - Tiempo de ejecución de los procesos
#ES_720     paginasDefinidasTotal(,) - El primer índice recorre los Procesos y el segundo las Páginas de cada Proceso 
#ES_730     memoria() - Cuánta memoria necesita cada proceso.
#ES_740     temp_wait() - Se acumulan el tiempo de espera.
#ES_750     temp_exec() - Se acumulan el tiempo de ejecución. 
#ES_760     bloqueados() - Procesos "En espera"
#
#ES_770     pos_inicio() - Posición de inicio en memoria.
#ES_780     pos_final() - Posición final en memoria. 
#ES_790     (Para estos dos arrays (que deberán ser dinámicos) tendrémos los valores de la memoria que están ocupados por un proceso, el valor de inicio en memoria y el valor al final)
#
#ES_800     mem_total - Tamaño total de la memoria que se va a usar.
#ES_810     mem_libre - Tamaño aún libre de la memoria.
#
#ES_820     encola() tendremos qué procesos pueden entrar en memoria. Los valores son:
#ES_830       0 : El proceso no ha entrado en la cola (no ha "llegado" - Estado "Fuera del sistema") 
#ES_840       1 : El proceso está en la cola (Estado "En espera")
#ES_850     enmemoria()  - Procesos que se encuentran en memoria. Los valores son:
#ES_860       0 : El proceso no está en memoria
#ES_870       1 : El proceso está en memoria esperando a ejecutarse (Estado "En memoria")
#ES_880     escrito()  - Procesos que se encuentran en memoria y a los que se les ha encontrado espacio sufiente en la banda de memoria. 
#ES_890     ejecucion  - Número de proceso que está ejecutándose (Estado "En ejecución")
#ES_900     reloj  - Instante de tiempo que se está tratando en el programa (reloj).
#
#ES_910     Estados de los procesos:
#ES_920          ${estad[$i]} = 0 - No llegado
#ES_930          ${estad[$i]} = 1 - En espera 
#ES_940          ${estad[$i]} = 2 - En memoria 
#ES_950          ${estad[$i]} = 3 - En ejecución 
#ES_960          ${estad[$i]} = 4 - En pausa 
#ES_970          ${estad[$i]} = 5 - Terminado

#ES_980 Declaración de los arrays:
#ES_990Contiene el número de unidades de ejecución y será usado para controlar que serán representadas en las bandas.
#ES_1000Variacble intermedia usada para la creación automática de los nombres de los procesos.
#ES_1010Nombre de los procesos
#ES_1020Tiempo de llegada de los procesos
#ES_1030Tiempo de ejecución de los procesos
#ES_1040Unidades de memoria asociados a los procesos
#ES_1050Variable recogida de datos para ordenar el temporal por tiempo de llegada
#ES_1060Tiempo ya esperado por los procesos
#ES_1070Tiempo ya ejecutado de los procesos
#ES_1080Tiempo de retorno de los procesos
#ES_1090Tiempo restante de ejecución de los procesos
#ES_1100Posición de inicio de cada hueco de memoria asociado a cada proceso.
#ES_1110Posición final de cada hueco de memoria asociado a cada proceso.
#ES_1120Se añade al comentario principal ?????????????????????
#ES_1130Se añade al comentario principal ?????????????????????
#ES_1140Estado inicial de los procesos cuando aún no han llegado al sistema.
#ES_1150Estado de los procesos cuando han llegado al sistema, pero aún no han entrado a la memoria.    
#ES_1160Estado de los procesos cuando han entrado en memoria, pero aún no han empezado a ejecutarse.
#ES_1170Estado de los procesos cuando un proceso ya ha empezado a ejecutarse, pero aunque no han terminado de ejecutarse, otro proceso ha comenzado a ejecutarse.
#ES_1180Estado de los procesos cuando un proceso ya ha empezado a ejecutarse
#ES_1190Se añade al comentario principal ?????????????????????
#ES_1200Estado de los procesos cuando ya han terminado de ejecutarse
#ES_1210Se añade al comentario principal ?????????????????????
#ES_1220Número asociado a cada estado de los procesos
#ES_1230Se añade al comentario principal
#ES_1240Secuencia de los procesos que ocupan cada marco de la memoria completa
#ES_1250Matriz auxiliar de la memoria no continua (para reubicar)
#ES_1260bandera para no escibir dos veces un proceso en memoria
#ES_1270para guardar en cuantos bloques se fragmenta un proceso
#ES_1280posición inicial de cada bloque en la memoria NO CONTINUA
#ES_1290posición final de cada bloque en la memoria NO CONTINUA
#ES_1300posición inicial en la memoria NO CONTINUA para impresiones (cuadrado en tabla)
#ES_1310posición final en la memoria NO CONTINUA para impresiones (cuadrado en tabla)
#ES_1320borrar posiciones innecesarias tras la impresión
#ES_1330borrar posiciones innecesarias tras la impresión
#ES_1340Para saber si un proceso en la barra de tiempo está nombrado, si se ha introducido en las variables de las diferentes líneas.
#ES_1350bandera para saber si hay un proceso anterior que finalizar de dibujar
#ES_1360Contiene el proceso que se esté tratando en la asignación de dígitos en la representación de la banda de tiempo
#ES_1370Guarda de uno en uno los colores para cada caracter de la barra de memoria (necesario impresión ventana)
#ES_1380Guarda de uno en uno los colores para cada caracter de la línea del tiempo (necesario impresión ventana)
#ES_1390Array que va a guardar el orden de la reubicacion
#ES_1400Array que guarda en orden de reubicación la memoria que ocupan
#ES_1410Si vale 0 no es reubicable. Si vale 1 es reubicable.
#ES_1420Si vale 0 es no continua. Si vale 1 es continua.
#ES_1430En cada casilla (instante actual - reloj) se guarda el número de orden del proceso que se ejecuta en cada instante.
#ES_1440Usada en gestionProcesosSRPT para determinar la anteriorproceso en ejecución que se compara con el actual tiempo restante de ejecución más corto y que va a ser definida como el actual proceso en ejecución.
#ES_1450Direcciones definidas de todos los Proceso (Índices:Proceso, Direcciones).
#ES_1460Páginas definidas de todos los Proceso (Índices:Proceso, Páginas).
#ES_1470Número de Páginas ya usadas de cada Proceso.
#ES_1480Secuencia de Páginas ya usadas de cada Proceso.
#ES_1490Páginas ya usadas del Proceso en ejecución. Sale de forma secuencial de paginasDefinidasTotal.
#ES_1500Páginas pendientes de ejecutar del Proceso en ejecución. Sale de forma secuencial de paginasDefinidasTotal. 
#ES_1510Siguiente Página a ejecutar del Proceso en ejecución. Sale de forma secuencial de paginasDefinidasTotal con el delimitador de numeroPaginasUsadasProceso.
#ES_1520Páginas residentes en memoria del Proceso en ejecución. Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#ES_1530Páginas residentes en memoria de cada Proceso (Índices:Proceso,número ordinal de marco asociado). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#ES_1540Contiene el número de Marcos de Memoria con Páginas ya dibujadas de cada Proceso.
#ES_1550Fallos de página totales de cada proceso.
#ES_1560Desde 0, es el ordinal del número de marcos en memoria asociados a cada proceso (Índices:Proceso)

#ES_1570Resumen - Índices: (proceso). Dato: Número de Marcos usados en cada Proceso.
#ES_1580Resumen - Índices: (tiempo). Dato: Proceso que se ejecuta en cada instante de tiempo real (reloj).
#ES_1590Resumen - Índices: (proceso, tiempo de ejecución). Dato: Tiempo de reloj en el que se ejecuta un Proceso.
#ES_1600Resumen - Índices: (proceso, marco, reloj). Dato: Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_1610Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_1620Resumen - Índices: (proceso, marco, reloj). Dato: Frecuencia de la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_1630Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_1640Resumen - Índices: (proceso, reloj). Dato: Marco (Puntero) sobre el que se produce el siguiente fallo para todos los Procesos en cada unidad de Tiempo.
#ES_1650Resumen - Índices: (proceso, tiempo). Dato: Marco usado (Puntero) para cada Proceso en cada unidad de Tiempo.
#ES_1660Resumen - Índices: (marco, tiempo). Dato: Texto a iprimir en Color con el seguimiento del uso de los Marcos a lo largo del Tiempo (página-frecuencia).
#ES_1670Resumen - Índices: (marco, tiempo). Dato: Texto a iprimir en Blanco-Negro con el seguimiento del uso de los Marcos a lo largo del Tiempo (página-frecuencia).
#ES_1680Resumen - Índices: (proceso, tiempo, número ordinal de marco). Dato: Relación de Marcos asignados al Proceso en ejecución en cada unidad de tiempo. El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
#ES_1690Resumen - Índices: (proceso). Dato: Último instante (reloj) en que cada proceso usó una página para realizar los acumulados de páginas y frecuencias de todos los procesos/marcos.
#ES_1700Resumen - Índices: (proceso, tiempo). Dato: Páginas que produjeron Fallos de Página del Proceso en ejecución.
#ES_1710Resumen - Índices: (proceso, tiempo). Dato: Marcos donde se produjeron Fallos de Página del Proceso en ejecución.
#ES_1720Resumen - Índices: (proceso). Dato: Número de Fallos de Página de cada Proceso.
#ES_1730Resumen - Índices: (proceso). Dato: Número de Expulsiones Forzadas de cada Proceso.
#ES_1740Resumen - Índices: (proceso). Dato: Número memor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#ES_1750Resumen - Índices: (proceso). Dato: Número mayor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#ES_1760Resumen - Índices: (proceso). Dato: Número de las posiciones con la memor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#ES_1770Resumen - Índices: (proceso). Dato: Número de las posiciones con la mayor de las Frecuencias de Uso de las Páginas en Memoria de cada Proceso.
#ES_1780Resumen - Índices: (proceso). Dato: Número memor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#ES_1790Resumen - Índices: (proceso). Dato: Número mayor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#ES_1800Resumen - Índices: (proceso). Dato: Número de las posiciones con la memor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#ES_1810Resumen - Índices: (proceso). Dato: Número de las posiciones con la mayor de las Antigüedades de Uso de las Páginas en Memoria de cada Proceso.
#ES_1820Resumen - Índices: (proceso, ordinal de página, reloj (0)). Dato: Se usará para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
#ES_1830Resumen - Índices: (proceso, marco). Dato: Se usará para determinar si una página ha sido o no referenciada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
#ES_1840Resumen - Índices: (proceso, tiempo de ejecución). Dato: Página referenciada (1) o no referenciada (0).
#ES_1850Resumen - Índices: (proceso, ordinal del tiempo de ejecución). Dato: Página modificada (1) o no modificada (0).
#ES_1860Resumen - Índices: (proceso). Dato: Ordinal del tiempo de ejecución en el que se hizo el último cambio de clase máxima.
#ES_1870Resumen - Índices: (proceso, marco). Dato: Histórico con el valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_1880Resumen - Índices: (proceso, marco). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_1890Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
#ES_1900Resumen - Índices: (proceso, marco). Dato: Histórico con el tiempo con inicialización a 0 cuando se inicializa $ResuTiempoProcesoUnidadEjecucion_MarcoPaginaClase_valor por cambio de la clase, o por inicialización de la frecuencia por llegar a su máximo, para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación	
#ES_1910Resumen - Índices: (proceso, marco, reloj). Dato: Histórico con la resta de las frecuencias de ambos momentos para ver si supera el valor límite máximo.
#ES_1920Resumen - Índices: (proceso, marco, tiempo). Dato: Clase de la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_1930Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el coeficiente M de los algoritmos de Segunda Oportunidad con valor 0 cuando se inicializa o cuando se permite su mantenimiento, aunque le toque para el fallo de paginación, y 1 como premio cuando se reutiliza.	
#ES_1940Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo que hay hasta la reutilización de la página contenida en el marco.	
#ES_1950Índice: (proceso). Dato: Contiene el orden de ejecución de Round-Robin (RR). Será "-" mientras no esté en cola, o cuando haya terminado, y si aún no ha terminado contendrá el número ordinal del siguiente quantum. El proceso a ejecutar será, por tanto, el que tenga el número ordinal más bajo. Y el número de quantums realizados (cambios de contexto, será el número ordinal más alto.

#ES_1960Variables para la impresión de volcados
#ES_1970Variables para la impresión de volcados
#ES_1980Variables para la impresión de volcados
#ES_1990Variables para la impresión de volcados
#ES_2000Variables para la impresión de volcados
#ES_2010Variables para la impresión de volcados
#ES_2020Variables para la impresión de volcados
#ES_2030Variables para la impresión de volcados
#ES_2040Variables para la impresión de volcados
#ES_2050Variables para la impresión de volcados
#ES_2060Variables para la impresión de volcados
#ES_2070Variables para la impresión de volcados

#
#ES_2080 Ficheros de salida. 
#
dirFLast="./FLast"
dirFDatos="./FDatos"
dirFRangos="./FRangos"
dirFRangosAleT="./FRangosAleT"
dirInformes="./Informes"
#ES_2090Informe en blanco/negro de todo lo visto en pantalla.
#ES_2100Informe a color de todo lo visto en pantalla.

#ES_2110Datos de particiones y procesos de la ejecución anterior.
#ES_2120Datos de particiones y procesos de la copia estándar (por defecto).

#ES_2130Rangos de particiones y procesos de la ejecución anterior.
#ES_2140Rangos de particiones y procesos de la copia estándar (por defecto).

#ES_2150Rangos amplios de particiones y procesos de la ejecución anterior para la extracción de subrangos.
#ES_2160Rangos amplios de particiones y procesos de la copia estándar (por defecto) para la extracción de subrangos.

#ES_2170Se inicializa la variable de fichero de datos
#ES_2180Se inicializa la variable de fichero de rangos
#ES_2190Se inicializa la variable de fichero de rangos amplios  

#
#
#ES_2200             FUNCIONES
#
#ES_2210 Sinopsis: Al inicio del programa muestra la cabecera por pantalla y la envía a los informes de B/N y COLOR. 
#
function presentacionPantallaInforme {
    clear
#ES_2220$NC\n"\
#ES_2230$NC\n"\
#ES_2240$NC\n"\
#ES_2250$NC\n"\
#ES_2260$NC\n"\
#ES_2270$NC\n"\
#ES_2280$NC\n"\
#ES_2290$NC\n"\
#ES_2300$NC\n"\
#ES_2310$NC\n"\
#ES_2320$NC\n"\
#ES_2330$NC\n"\
#ES_2340$NC\n"\
#ES_2350$NC\n"\
#ES_2360$NC\n"\
#ES_2370$NC\n"\
#ES_2380$NC\n"\
#ES_2390$NC\n"\
#ES_2400$NC\n"\
#ES_2410$NC\n"\
#ES_2420$NC\n"\
#ES_2430$NC\n"\
#ES_2440$NC\n"\
#ES_2450$NC\n"\
#ES_2460$NC\n"\
#ES_2470$NC\n"\
#ES_2480$NC\n"\
#ES_2490La opción -a lo crea inicialmente
    DIA=$(date +"%d/%m/%Y")
    HORA=$(date +"%H:%M")
    echo -e $NORMAL" ÚLTIMA EJECUCIÓN: $DIA - $HORA\n" | tee -a $informeConColorTotal

#ES_2500\n"\
#ES_2510\n"\
#ES_2520\n"\
#ES_2530\n"\
#ES_2540\n"\
#ES_2550\n"\
#ES_2560\n"\
#ES_2570\n"\
#ES_2580\n"\
#ES_2590\n"\
#ES_2600\n"\
#ES_2610\n"\
#ES_2620\n"\
#ES_2630\n"\
#ES_2640\n"\
#ES_2650\n"\
#ES_2660\n"\
#ES_2670\n"\
#ES_2680\n"\
#ES_2690\n"\
#ES_2700\n"\
#ES_2710\n"\
#ES_2720\n"\
#ES_2730\n"\
#ES_2740\n"\
#ES_2750\n"\
#ES_2760\n"\
#ES_2770La opción > lo crea inicialmente
    DIA=$(date +"%d/%m/%Y")
    HORA=$(date +"%H:%M")
    echo -e " ÚLTIMA EJECUCIÓN: $DIA - $HORA\n" >> $informeSinColorTotal

	echo -ne $ROJO"\n\n Pulsa ENTER para continuar "$NORMAL
	read enter
}

#
#ES_2780 Sinopsis: Cabecera de inicio 
#
function cabecerainicio {
#ES_2790$NC\n"\
#ES_2800$NC\n"\
#ES_2810$NC\n"\
#ES_2820$NC\n"\
#ES_2830$NC\n"\
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_2850\n"\
#ES_2860\n"\
#ES_2870\n"\
#ES_2880\n"\
#ES_2890\n"\
#ES_2900\n" >> $informeSinColorTotal
#ES_2910Fin de cabecerainicio()

#
#ES_2920 Sinopsis: Menú inicial con ayuda y ejecución
#
function menuInicio {
#ES_2930	clear
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
#ES_2940Menú de elección de algoritmo de gestión de procesos. 
#ES_2950Menú de elección de continuidad.
#ES_2960Menú de elección de reubicabilidad.
			seleccionAlgoritmoPaginacion=0
#ES_2970Menú de elección de entrada de datos.
			;;
		'2')
#ES_2980Menú de elección de algoritmo de gestión de procesos. 
#ES_2990Menú de elección de continuidad.
#ES_3000Menú de elección de reubicabilidad.
#ES_3010Menú de elección del algoritmo de paginación.
#ES_3020Menú de elección de entrada de datos.
			;;
        '3')
#ES_3030Permite ver los ficheros de ayuda en formato PDF y de vídeo
            ;;
        '4')
            echo $0
            echo " El informe resultante es ./zsdoc/$0.adc junto con el subdirectorio ./zsdoc/data." | tee -a $informeConColorTotal
            echo " El informe resultante es ./zsdoc/$0.adc junto con el subdirectorio ./zsdoc/data." >> $informeSinColorTotal
            echo " Si el formato no es el adecuado o para estandarizar ese formato, se puede imprimir o transformar el documento a fichero pdf." | tee -a $informeConColorTotal
            echo " Si el formato no es el adecuado o para estandarizar ese formato, se puede imprimir o transformar el documento a fichero pdf." >> $informeSinColorTotal
#ES_3040...O el directorio que se corresponda con la localización de zshelldoc, dependiendo de dónde se haya instalado
            exit 0
            ;;
		'5')
			echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
			exit 0 ;;
		'33')
#ES_3050Menú de elección de opciones de ensayos de los algoritmos de gestión de procesos y paginación y tomas de datos. 
			;;
#ES_3060No es necesario. Existe por si se modifica y no se revisa el until anterior.
			echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
			echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal ;;
	esac
#ES_3070Fin de menuInicio()

#
#ES_3080 Sinopsis: Menú de ayuda con ficheros PDF y de vídeo
#
function menuAyuda {
#ES_3090	clear
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
#ES_3100Un fichero a elegir
			echo -e "\n\nFicheros de ayuda existentes en formato PDF:\n$NORMAL" | tee -a $informeConColorTotal
			echo -e "\n\nFicheros de ayuda existentes en formato PDF:\n" >> $informeSinColorTotal 
			files=("./DOCPDF"/*)
#ES_3110Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
				echo -e "$i) ${files[$i]}" | tee -a $informeConColorTotal
				echo -e "$i) ${files[$i]}" >> $informeSinColorTotal 
			done
			echo -ne "\n$AMARILLO\n\nIntroduce el número correspondiente al fichero elegido: $NORMAL" | tee -a $informeConColorTotal
			echo -ne "\n\n\nIntroduce el número correspondiente al fichero elegido: " >> $informeSinColorTotal 
			read -r numeroFicheroPDF
#ES_3120files[@]} ]]; do
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
#ES_3130Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
				echo -e "$i) ${files[$i]}" | tee -a $informeConColorTotal
				echo -e "$i) ${files[$i]}" >> $informeSinColorTotal 
			done
			echo -ne "\n$AMARILLO\n\nIntroduce el número correspondiente al fichero elegido: $NORMAL" | tee -a $informeConColorTotal
			echo -ne "\n\n\nIntroduce el número correspondiente al fichero elegido: " >> $informeSinColorTotal 
			read -r numeroFicheroVideo
#ES_3140files[@]} ]]; do
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
#ES_3150No es necesario. Existe por si se modifica y no se revisa el until anterior.
			echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
			echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal ;;
	esac
#ES_3160Fin de menuAyuda()

#
#ES_3170 Sinopsis: Menú inicial con ayuda y ejecución
#
function menuEnsayos {
#ES_3180	clear
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
#ES_3190Menú de elección de algoritmo de gestión de procesos. 
#ES_3200Menú de elección de continuidad.
#ES_3210Menú de elección de reubicabilidad.
#ES_3220Menú de elección del número de ensayos automáticos a realizar de forma continua.
#ES_3230Se definen y ejecutan los ensayos automáticos y se recogen los datos en ficheros secuenciales.
			;;
		'2')
#ES_3240Menú de elección de algoritmo de gestión de procesos. 
#ES_3250Menú de elección de continuidad.
#ES_3260Menú de elección de reubicabilidad.
#ES_3270Menú de elección del número de ensayos automáticos a realizar de forma continua.
#ES_3280Se definen y ejecutan los ensayos automáticos y se recogen los datos en ficheros secuenciales.
			;;
		'3')
#ES_3290Menú de elección de algoritmo de gestión de procesos. 
#ES_3300Menú de elección de continuidad.
#ES_3310Menú de elección de reubicabilidad.
#ES_3320Menú de elección del número de ensayos automáticos a realizar de forma continua.
#ES_3330Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos sobre los diferentes algoritmos de paginación y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
			;;
		'4') 
#ES_3340Menú de elección del número de ensayos automáticos a realizar de forma continua.
#ES_3350Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos sobre los diferentes algoritmos de gestión de procesos y de paginación y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
#ES_3360Se vuelve a inicial la aplicación
			;;
		'5')
			echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
			exit 0 ;;
#ES_3370No es necesario. Existe por si se modifica y no se revisa el until anterior.
			echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
			echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal ;;
	esac
#ES_3380Fin de menuEnsayos()

#
#ES_3390 Sinopsis: Menú de elección del Algoritmo de Gestión de Procesos; FCFS, SJF, SRPT.
#
function menuDOCPDF { 
#ES_3400    clear
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

#ES_3410Comprobación de que el número introducido por el usuario es de 1 a 4
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
#ES_3420Fin de menuDOCPDF()

#
#ES_3430 Sinopsis: Menú de elección del Algoritmo de Gestión de Procesos; FCFS, SJF, SRPT.
#
function menuDOCVideo { 
#ES_3440    clear
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

#ES_3450Comprobación de que el número introducido por el usuario es de 1 a 4
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
#ES_3460Fin de menuDOCVideo()

#
#ES_3470 Sinopsis: Menú de elección del Algoritmo de Gestión de Procesos; FCFS, SJF, SRPT, Prioridades.
#
function menuAlgoritmoGestionProcesos {
#ES_3480	clear
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
#ES_3490Se comprueba que el número introducido por el usuario es de 1 a 6
    until [[ 0 -lt $seleccionMenuAlgoritmoGestionProcesos && $seleccionMenuAlgoritmoGestionProcesos -lt 7 ]];   do
        echo -ne "\nError en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
        echo -ne "\nError en la elección de una opción válida\n--> " >> $informeSinColorTotal
        read seleccionMenuAlgoritmoGestionProcesos
        echo -e "$seleccionMenuAlgoritmoGestionProcesos\n\n" >> $informeConColorTotal
        echo -e "$seleccionMenuAlgoritmoGestionProcesos\n\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuAlgoritmoGestionProcesos" in
        '4')
#ES_3500Menú de elección del tipo de prioridad (Mayor/Menor).
#ES_3510Menú de elección de apropiatividad. Cuando se ejecuta con Prioridades. Se hace en menuAlgoritmoGestionProcesos()
			;;
    esac
#ES_3520Para que se equipare al programa nuevo.
#ES_3530Fin de menuAlgoritmoGestionProcesos()

#
#ES_3540 Sinopsis: Menú de elección de Tipo de Prioridad (Mayor/Menor). Cuando se ejecuta con Prioridades.
#
function menuTipoPrioridad { 
#ES_3550	clear
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
#ES_3560Fin de menuApropiatividad()

#
#ES_3570 Sinopsis: Menú de elección de Apropiatividad. Cuando se ejecuta con Prioridades.
#ES_3580 
function menuApropiatividad { 
#ES_3590	clear
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
#ES_3600No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal ;;
    esac
#ES_3610Fin de menuApropiatividad()

#
#ES_3620 Sinopsis: Menú de elección de reubicabilidad. 
#
#ES_3630Si reubicabilidadNo0Si1 vale 0 no es reubicable. Si vale 1 es reubicable.
#ES_3640	clear
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
#ES_3650Se comprueba que el número introducido por el usuario es de 1 a 3
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
#ES_3660No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#ES_3670Fin de menuReubicabilidad()

#
#ES_3680 Sinopsis: Menú de elección de continuidad. 
#
#ES_3690Si vale 0 es no continua. Si vale 1 es continua.
#ES_3700	clear
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
#ES_3710Se comprueba que el número introducido por el usuario es de 1 a 3
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
#ES_3720No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#ES_3730Fin de menuContinuidad()

#
#ES_3740 Sinopsis: Menú de elección de Continuidad. 
#
function menuAlgoritmoPaginacion { 
#ES_3750	clear
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
#ES_3760FIFO
        '2')
#ES_3770FIFO - Segunda Oportunidad
        '3')
#ES_3780Reloj
        '4')
#ES_3790Reloj - Segunda Oportunidad
        '5')
#ES_3800Óptimo
        '6')
#ES_3810More Frequently Used (MFU)
        '7')
#ES_3820Lest Frequently Used (LFU)
        '8')
#ES_3830No Frequently Used (NFU) sobre MFU con límite de frecuencia
#ES_3840Se pide el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
			;;
        '9')
#ES_3850No Frequently Used (NFU) sobre LFU con límite de frecuencia
#ES_3860Se pide el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
			;;
        '10')
#ES_3870No Frequently Used (NFU) con clases sobre MFU con límite de frecuencia en un intervalo de tiempo. Se inician los datos en ordenarDatosEntradaFicheros() y ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve().
#ES_3880Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#ES_3890Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#ES_3900Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
			;;
        '11')
#ES_3910No Frequently Used (NFU) con clases sobre LFU con límite de frecuencia en un intervalo de tiempo. Se inician los datos en ordenarDatosEntradaFicheros() y ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve().
#ES_3920Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#ES_3930Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#ES_3940Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
			;;
        '12')
#ES_3950More Recently Used (MRU)
        '13')
#ES_3960Lest Recently Used (LRU)
        '14')
#ES_3970No Recently Used (NRU) sobre MRU con límite de tiempo de uso
#ES_3980Se pide el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
			;;
        '15')
#ES_3990No Recently Used (NRU) sobre LRU con límite de tiempo de uso
#ES_4000Se pide el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
			;;
        '16')
#ES_4010No Recently Used (NRU) con clases sobre MRU con límite de tiempo de uso en un intervalo de tiempo. Se inician los datos en ordenarDatosEntradaFicheros() y ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve().
#ES_4020Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#ES_4030Se pide el valor máximo del contador de antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.
#ES_4040Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
			;;
        '17')
#ES_4050No Recently Used (NRU) con clases sobre LRU con límite de tiempo de uso en un intervalo de tiempo. Se inician los datos en ordenarDatosEntradaFicheros() y ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve().
#ES_4060Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#ES_4070Se pide el valor máximo del contador de antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.
#ES_4080Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
			;;
        '18')
            echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
            exit 0 ;;
#ES_4090No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal $informeSinColorTotal ;;
    esac
#ES_4100Fin de menuAlgoritmoPaginacion()

#
#ES_4110 Sinopsis: Se pide el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
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
#ES_4120Fin de menuAlgoritmoPaginacion_frecuencia()

#
#ES_4130 Sinopsis: Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
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
#ES_4140Fin de menuAlgoritmoPaginacion_clases_frecuencia()

#
#ES_4150 Sinopsis: Se pide el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
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
#ES_4160Fin de menuAlgoritmoPaginacion_uso_rec()

#
#ES_4170 Sinopsis: Se pide el valor máximo del contador de antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.
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
#ES_4180Fin de menuAlgoritmoPaginacion_clases_uso_rec()

#
#ES_4190 Sinopsis: Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
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
#ES_4200Fin de menuAlgoritmoPaginacion_clases_valor()

#
#ES_4210 Sinopsis: Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
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
#ES_4220Fin de menuAlgoritmoPaginacion_TiempoConsiderado_valor()

#
#ES_4230 Sinopsis: Menú de elección de opciones de entrada de datos/rangos/rangos amplios del programa:
#ES_4240 Manul, Última ejecución, Otros ficheros.
#
function menuEleccionEntradaDatos {
#ES_4250	clear
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

#ES_4260Se comprueba que el número introducido por el usuario es de 1 a 10
    until [[ 0 -lt $seleccionMenuEleccionEntradaDatos && $seleccionMenuEleccionEntradaDatos -lt 11 ]];  do
        echo -ne "\n Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read seleccionMenuEleccionEntradaDatos
        echo -ne "$seleccionMenuEleccionEntradaDatos\n\n" >> $informeConColorTotal
        echo -ne "$seleccionMenuEleccionEntradaDatos\n\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuEleccionEntradaDatos" in
#ES_42701. Introducción de datos manual 
            nuevaEjecucion
            preguntaDondeGuardarDatosManuales
            entradaMemoriaTeclado
            entradaProcesosTeclado
            menuModoTiempoEjecucionAlgormitmo
            ;;
#ES_42802. Fichero de datos de última ejecución (./FLast/DatosLast.txt).
#ES_4290Elección del algoritmo de gestión de procesos y la fuente de datos.
            leer_datos_desde_fichero $ficheroDatosAnteriorEjecucion
#ES_4300Ordenar los datos sacados desde $ficheroDatosAnteriorEjecucion por el tiempo de llegada.
            ;;
#ES_43103. Otros ficheros de datos $ficheroDatosAnteriorEjecucion
#ES_4320Elegir el fichero para la entrada de datos $ficheroParaLectura.
#ES_4330Elección del algoritmo de gestión de procesos y la fuente de datos.
#ES_4340Leer los datos desde el fichero elegido $ficheroParaLectura
#ES_4350Ordenar los datos sacados desde $ficheroParaLectura por el tiempo de llegada.
            ;;
#ES_43604. Introducción de rangos manual (modo aleatorio)
#ES_4370Resuelve los nombres de los ficheros de rangos
#ES_4380Resuelve los nombres de los ficheros de datos
            nuevaEjecucion 
            entradaMemoriaRangosFichero_op_cuatro
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#ES_43905. Fichero de rangos de última ejecución (./FLast/RangosLast.txt)
            entradaMemoriaRangosFichero_op_cinco_Previo
#ES_4400Leer los datos desde el fichero elegido $ficheroParaLectura
            entradaMemoriaRangosFichero_op_cinco_seis
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#ES_44106. Otros ficheros de rangos
            nuevaEjecucion 
            entradaMemoriaRangosFichero_op_seis_Previo 
#ES_4420Leer los datos desde el fichero elegido $ficheroParaLectura
            entradaMemoriaRangosFichero_op_cinco_seis
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#ES_44307. Introducción de rangos amplios manual (modo aleatorio total)
            nuevaEjecucion 
            entradaMemoriaRangosFichero_op_siete_Previo
            entradaMemoriaRangosFichero_op_siete_ocho_nueve
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#ES_44408. Fichero de rangos amplios de última ejecución
#ES_4450Pregunta en qué fichero guardar los rangos para la opción 8.
#ES_4460Leer los datos desde el fichero elegido $ficheroRangosAleTotalAnteriorEjecucion
            entradaMemoriaRangosFichero_op_siete_ocho_nueve
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#ES_44709. Otros ficheros de rangos amplios
            nuevaEjecucion 
            entradaMemoriaRangosFichero_op_nueve_Previo
#ES_4480Leer los datos desde el fichero elegido $ficheroParaLectura
            entradaMemoriaRangosFichero_op_siete_ocho_nueve
            menuModoTiempoEjecucionAlgormitmo
            ordenarDatosEntradaFicheros
            ;;
#ES_449010. Salir  
            echo -e $ROJO"\n SE HA SALIDO DEL PROGRAMA"$NORMAL
            exit 0 ;;
#ES_4500No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#ES_4510Fin de menuEleccionEntradaDatos()

#
#ES_4520 Sinopsis: Se decide el modo de ejecución: Por eventos, Automática, Completa, Unidad de tiempo a unidad de tiempo  
#
function menuModoTiempoEjecucionAlgormitmo {
#ES_4530	clear
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
#ES_4540 Se comprueba que el número introducido por el usuario esta entre 1 y 5
    until [[ "0" -lt $seleccionMenuModoTiempoEjecucionAlgormitmo && $seleccionMenuModoTiempoEjecucionAlgormitmo -lt "6" ]]; do
        echo -ne "\n Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne " Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read seleccionMenuModoTiempoEjecucionAlgormitmo
        echo -e "$seleccionMenuModoTiempoEjecucionAlgormitmo\n" >> $informeConColorTotal
        echo -e "$seleccionMenuModoTiempoEjecucionAlgormitmo\n" >> $informeSinColorTotal
    done
    case "$seleccionMenuModoTiempoEjecucionAlgormitmo" in
#ES_4550 Por eventos
            optejecucion=1
            ;;
#ES_4560 Automática
            tiempoejecucion=0
            optejecucion=2
            ;;
#ES_4570 Completa
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
#ES_4580 De unidad de tiempo en unidad de tiempo
            optejecucion=4
            ;;
#ES_4590 Sólo muestra el resumen final
            optejecucion=5
            ;;
#ES_4600No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#ES_4610    clear
#ES_4620Fin de menuModoTiempoEjecucionAlgormitmo()

#
#ES_4630 Sinopsis: Comprobar si existe el árbol de directorios utilizados en el programa
#
#ES_4640Regenera el árbol de directorios si no se encuentra. 
#ES_4650    clear
#ES_4660Se regenera la estructura de directorios en caso de no existir
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
#ES_4670Informes y temporales 
    if [[ -f $informeConColorTotal ]]; then
#ES_4680Se borran los ficheros de informes COLOR
    fi
    if [[ -f $informeSinColorTotal ]]; then
#ES_4690Se borran los ficheros de informes BN
    fi
#ES_4700Fin de revisarArbolDirectorios()

#
#ES_4710 Sinopsis: Se pregunta por las opciones de guardar lo datos de particiones y procesos.
#ES_4720 Se pregunta si se quiere guardar los datos en el fichero estándar (Default) o en otro.
#ES_4730 Si es en otro, pide el nombre del archivo.
#
function preguntaDondeGuardarDatosManuales {
#ES_4740Pregunta para los datos por teclado  
    echo -e $AMARILLO"\n¿Dónde quiere guardar los datos resultantes?\n"$NORMAL | tee -a $informeConColorTotal
    echo -e " 1- En el fichero estándar ($ficheroDatosDefault)" | tee -a $informeConColorTotal
    echo -ne " 2- En otro fichero\n\n\n--> " | tee -a $informeConColorTotal
    echo -e "¿Dónde quiere guardar los datos resultantes?\n\n" >> $informeSinColorTotal
    echo -e " 1- En el fichero estándar ($ficheroDatosDefault)" >> $informeSinColorTotal
    echo -ne " 2- En otro fichero\n\n\n--> " >> $informeSinColorTotal
    read seleccionMenuPreguntaDondeGuardarDatosManuales
    echo -e " $seleccionMenuPreguntaDondeGuardarDatosManuales\n\n" >> $informeConColorTotal
    echo -e " $seleccionMenuPreguntaDondeGuardarDatosManuales\n\n" >> $informeSinColorTotal
#ES_4750 Se comprueba que el número introducido por el usuario esta entre 1 y 2
    until [[ "0" -lt $seleccionMenuPreguntaDondeGuardarDatosManuales && $seleccionMenuPreguntaDondeGuardarDatosManuales -lt "3" ]]; do
        echo -ne "\n Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "\n Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read seleccionMenuPreguntaDondeGuardarDatosManuales
        echo -e " $seleccionMenuPreguntaDondeGuardarDatosManuales\n\n" >> $informeConColorTotal
        echo -e " $seleccionMenuPreguntaDondeGuardarDatosManuales\n\n" >> $informeSinColorTotal
    done
    case "${seleccionMenuPreguntaDondeGuardarDatosManuales}" in
#ES_4760En el fichero estándar
#ES_4770Se borran los datos del fichero por defecto de la anterior ejecución
            nomFicheroDatos="$ficheroDatosDefault"
            ;;
#ES_4780En otro fichero
            echo -e $ROJO"\n Ficheros de datos ya existentes en './FDatos/': "$NORMAL | tee -a $informeConColorTotal
            echo -e "\n Ficheros de datos ya existentes en './FDatos/': " >> $informeSinColorTotal
            files=($(ls -l ./FDatos/ | awk '{print $9}'))
#ES_4790Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
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
#ES_4800cierre el sobreescribir NO
            done
            ;;
#ES_4810No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e " Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e " Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#ES_4820    clear
#ES_4830Fin de preguntaDondeGuardarDatosManuales()
        
#
#ES_4840 Sinopsis: Se pregunta por las opciones de guardar lo rangos de particiones y procesos.
#ES_4850 Se pregunta si se quiere guardar los rangos en el fichero estándar (Default) o en otro.
#ES_4860 Si es en otro, pide el nombre del archivo.
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

#ES_4870 Se comprueba que el número introducido por el usuario esta entre 1 y 2
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
#ES_4880En el fichero estándar
#ES_4890Se borran los rangos del fichero por defecto de la anterior ejecución
            nomFicheroRangos="$ficheroRangosDefault"
            ;;
#ES_4900En otro fichero
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
#ES_4910cierre el sobreescribir NO
            done
            ;;
#ES_4920No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e "Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e "Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#ES_4930Fin de preguntaDondeGuardarRangosManuales()

#
#ES_4940 Sinopsis: Se pregunta por las opciones de guardar los mínimos y máximos de los rangos amplios.
#ES_4950 Se pregunta si se quiere guardar los rangos en el fichero estándar (Default) o en otro.
#ES_4960 Si es en otro, pide el nombre del archivo.
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
#ES_4970 Se comprueba que el número introducido por el usuario esta entre 1 y 2
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
#ES_4980En el fichero estándar
#ES_4990Se borran los rangos del fichero por defecto de la anterior ejecución
            nomFicheroRangosAleT="$ficheroRangosAleTotalDefault"
            ;;
#ES_5000En otro fichero
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
#ES_5010cierre el sobreescribir NO
            done
            ;;
#ES_5020No es necesario. Existe por si se modifica y no se revisa el until anterior.
            echo -e "Error en la elección de una opción válida" | tee -a $informeConColorTotal
            echo -e "Error en la elección de una opción válida" >> $informeSinColorTotal
            ;;
    esac
#ES_5030Fin de preguntaDondeGuardarRangosAleTManuales()

#
#ES_5040 Sinopsis: Menú de elección del número de ensayos automáticos a ejecutar de forma continua.
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
#ES_5050Fin de menuAlgoritmoPaginacion_TiempoConsiderado_valor()

#
#
#ES_5060    Funciones de recogida de datos con ejecución cíclica automatizada
#
#
#
#ES_5070Se definen y ejecutan los ensayos automáticos y se recogen los datos en ficheros secuenciales. Se usan datos diferentes en cada aloritmo de paginación y ensayo para buscar errores.
#
function ejecutarEnsayosDatosDiferentes { 
#ES_5080Número de algoritmos de paginación que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#ES_5090Número de algoritmos de paginación que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#ES_5100Rango desde el que se extraen subrangos, desde los que se extraen datos, que se ejecutan con las diferentes opciones.
#ES_5110Se pueden definir los diferentes modos de ejecución (1-Ejecución por eventos // 2-Ejecución automática (Por eventos y sin pausas) // 3-Ejecución completa (Por eventos con pausas de cierto número de segundos) // 4-Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo) // 5-Ejecución completa (Sin representación de resultados intermedios)) 
#ES_5120Sólo se guardan los datos de las medias de los tiempos de espera y retorno, el número de fallos de página totales y el número de expulsiones de procesos forzadas en RR totales. Viene de la variable $seleccionMenuModoTiempoEjecucionAlgormitmo en el menú de selección de modo de ejecución MenuModoTiempoEjecucionAlgormitmo()			
	dirInformes="./Informes/RecogerDatosAutomDiferentes"
	if [[ ! -d $dirInformes ]]; then
		mkdir $dirInformes   
	fi
#ES_5130Se inicializa la variable de fichero de datos dond se recogen todos los datos finales.
	if [[ -f $nomFicheroDatosEjecucionAutomatica ]]; then
#ES_5140Se borran los ficheros anteriores
	fi
#ES_5150Origen de los datos sobre los que se desarrollan los subrangos, sobre lso que se extraen los datos, sobre los que se ejecuta el programa.
	for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
		for (( indEnsayos = 1; indEnsayos <= $seleccionNumEnsayos; indEnsayos++ )); do 
#ES_5160Se define el fichero sobre el que se guarda el rango amplio.
			if [[ -f $ficheroRangosAleTotalDefault ]]; then
#ES_5170Se borran los ficheros anteriores
			fi
#ES_5180Se define el fichero sobre el que se guardan los subrangos.
			if [[ -f $nomFicheroRangos ]]; then
#ES_5190Se borran los ficheros anteriores
			fi
#ES_5200Se define el fichero sobre el que se guardan los datos que se extraen de los subrangos.
			if [[ -f $nomFicheroDatos ]]; then
#ES_5210Se borran los ficheros anteriores
			fi
#ES_5220Se define el fichero sobre el que se guardan los volcados en COLOR.
			if [[ -f $informeSinColorTotal ]]; then
#ES_5230Se borran los ficheros anteriores
			fi
#ES_5240Se define el fichero sobre el que se guardan los volcados en BN.
			if [[ -f $informeConColorTotal ]]; then
#ES_5250Se borran los ficheros anteriores
			fi
#ES_5260Leer los datos desde el fichero elegido $ficheroRangosAleTotalAnteriorEjecucion
#ES_5270Se piden y tratan los mínimos y máximos de los rangos. El cálculo de los datos aleatorios con los que se trabajará se hace en entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun. 
#ES_5280Ordena los datos para ser mostrados y considerados por orden de llegada.
			echo -e "Algoritmo de paginación: $seleccionAlgoritmoPaginacion\n" >> $informeConColorTotal
			echo -e "Número de Ensayo: $indEnsayos\n" >> $informeConColorTotal
#ES_5290Cuando se han definido todas las opciones se inicia la ejecución del programa
#ES_5300Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
			echo -e "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado AlgPag $seleccionAlgoritmoPaginacion NumEnsayo $indEnsayos Tesperamedio $promedio_espera T.retornomedio $promedio_retorno TotalFallosPagina $suma_contadorAlgPagFallosProcesoAcumulado TotalExpulsionesForzadasRR $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
		done
	done
#ES_5310Fin de ejecutarEnsayosDatosDiferentes()

#
#ES_5320Se definen y ejecutan los ensayos automáticos y se recogen los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
#
function ejecutarEnsayosDatosIguales { 
#ES_5330Número de algoritmos de paginación que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#ES_5340Rango desde el que se extraen subrangos, desde los que se extraen datos, que se ejecutan con las diferentes opciones.
#ES_5350Se pueden definir los diferentes modos de ejecución (1-Ejecución por eventos // 2-Ejecución automática (Por eventos y sin pausas) // 3-Ejecución completa (Por eventos con pausas de cierto número de segundos) // 4-Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo) // 5-Ejecución completa (Sin representación de resultados intermedios)) 
#ES_5360Sólo se guardan los datos de las medias de los tiempos de espera y retorno, el número de fallos de página totales y el número de expulsiones de procesos forzadas en RR totales. Viene de la variable $seleccionMenuModoTiempoEjecucionAlgormitmo en el menú de selección de modo de ejecución MenuModoTiempoEjecucionAlgormitmo()			
	dirInformes="./Informes/RecogerDatosAutomIguales"
#ES_5370Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#ES_5380Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
	if [[ ! -d $dirInformes ]]; then
		mkdir $dirInformes   
	fi
#ES_5390Se inicializa la variable de fichero de datos dond se recogen todos los datos finales.
	if [[ -f $nomFicheroDatosEjecucionAutomatica ]]; then
#ES_5400Se borran los ficheros anteriores
	fi
			echo -ne "Título AlgPag NumEnsayo T.esperamedio T.retornomedio TotalFallosPagina TotalExpulsionesForzadasRR" >> $nomFicheroDatosEjecucionAutomatica
			echo -ne " MáxFrec TiempoConsiderado FrecValor Clase" >> $nomFicheroDatosEjecucionAutomatica
			echo -e " MáxUsoRec TiempoConsiderado UsoRecValor Clase" >> $nomFicheroDatosEjecucionAutomatica
#ES_5410Origen de los datos sobre los que se desarrollan los subrangos, sobre lso que se extraen los datos, sobre los que se ejecuta el programa.
#ES_5420Primero se inicializan los ficheros con los datos a tratar.
#ES_5430Se define el fichero sobre el que se guarda el rango amplio.
		if [[ -f $ficheroRangosAleTotalDefault ]]; then
#ES_5440Se borran los ficheros anteriores
		fi
#ES_5450Se define el fichero sobre el que se guardan los subrangos.
		if [[ -f $nomFicheroRangos ]]; then
#ES_5460Se borran los ficheros anteriores
		fi
#ES_5470Se define el fichero sobre el que se guardan los datos que se extraen de los subrangos.
		if [[ -f $nomFicheroDatos ]]; then
#ES_5480Se borran los ficheros anteriores
		fi
#ES_5490Leer los datos desde el fichero elegido $ficheroRangosAleTotalAnteriorEjecucion
#ES_5500Se piden y tratan los mínimos y máximos de los rangos. El cálculo de los datos aleatorios con los que se trabajará se hace en entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun. 
	done
#ES_5510Ahora se leen los datos ya guardados en los ficheros de datos y se tratan.
#ES_5520Se define el fichero desde el que se leen los datos que se extraen de los subrangos.
		maxDatoCierre=0
		leer_datos_desde_fichero $nomFicheroDatos
#ES_5530Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
			maxDato=0
			maxDatoCierre=1
#ES_5540Se calcula el mayor de lso tiempos de ejecución para calcular un valor aleatorio entre 1 y ese máximo. Podría usarse cualquier rango, pero este dato puede estar relacionado con lso datos del problema.
				if [[ ${ejecucion[$i]} -gt $maxDato ]]; then 
					maxDato=${ejecucion[$i]} 
				fi
			done
		fi
		for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
#ES_5550Se define el fichero sobre el que se guardan los volcados en COLOR.
			if [[ -f $informeSinColorTotal ]]; then
#ES_5560Se borran los ficheros anteriores
			fi
#ES_5570Se define el fichero sobre el que se guardan los volcados en BN.
			if [[ -f $informeConColorTotal ]]; then
#ES_5580Se borran los ficheros anteriores
			fi
#ES_5590Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_5610 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_frecuencia_valor=$datoAleatorioGeneral
			fi
#ES_5620Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#ES_563010-11-Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#ES_5640 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#ES_565010-11-Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#ES_5660 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_frecuencia_valor=$datoAleatorioGeneral
#ES_567010-11-Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
#ES_5680 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
			fi
#ES_5690Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_5710 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_uso_rec_valor=$datoAleatorioGeneral
			fi
#ES_5720Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_5740 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_5760 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_uso_rec_valor=$datoAleatorioGeneral
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_5780 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
			fi
#ES_5790Ordena los datos para ser mostrados y considerados por orden de llegada.
			echo -ne "$NORMAL\nAlgoritmo de paginación:$seleccionAlgoritmoPaginacion" | tee -a $informeConColorTotal
			echo -ne "$NORMAL\nNúmero de Ensayo:$indEnsayos\n" | tee -a $informeConColorTotal
			echo -e "Algoritmo de paginación: $seleccionAlgoritmoPaginacion" >> $informeSinColorTotal
			echo -e "Número de Ensayo: $indEnsayos" >> $informeSinColorTotal
#ES_5800Cuando se han definido todas las opciones se inicia la ejecución del programa
#ES_5810Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
			echo -ne "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado $seleccionAlgoritmoPaginacion $indEnsayos $promedio_espera $promedio_retorno $suma_contadorAlgPagFallosProcesoAcumulado $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
			echo -ne " $seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
			echo -e " $seleccionAlgoritmoPaginacion_uso_rec_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
		done
	done	
#ES_5820Fin de ejecutarEnsayosDatosIguales()

#
#ES_5830Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
#
function ejecutarEnsayosDatosIgualesAnteriores { 
#ES_5840Número de algoritmos de paginación que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#ES_5850Datos, que se ejecutan con las diferentes opciones.
#ES_5860Se pueden definir los diferentes modos de ejecución (1-Ejecución por eventos // 2-Ejecución automática (Por eventos y sin pausas) // 3-Ejecución completa (Por eventos con pausas de cierto número de segundos) // 4-Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo) // 5-Ejecución completa (Sin representación de resultados intermedios)) 
#ES_5870Sólo se guardan los datos de las medias de los tiempos de espera y retorno, el número de fallos de página totales y el número de expulsiones de procesos forzadas en RR totales. Viene de la variable $seleccionMenuModoTiempoEjecucionAlgormitmo en el menú de selección de modo de ejecución MenuModoTiempoEjecucionAlgormitmo()			
	dirInformes="./Informes/RecogerDatosAutomIguales"
	dirInformesAnteriores="./Informes/RecogerDatosAutomIgualesAnteriores"
#ES_5880Se define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#ES_5890Se define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
	if [[ ! -d $dirInformesAnteriores ]]; then
		mkdir $dirInformesAnteriores   
	fi
#ES_5900Primero se inicializan los ficheros con los datos a tratar.
#ES_5910Se define el fichero sobre el que se guardan los datos que se extraen de los subrangos.
		if [[ -f $nomFicheroDatos ]]; then
#ES_5920Se borran los ficheros anteriores
		fi
	done
    files=($dirInformes"/DatosDefault"*".txt")
    echo -e "\n\nFicheros existentes:\n$NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\nFicheros existentes:\n" >> $informeSinColorTotal 
#ES_5930Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
        echo -e ${files[$i]} 
        cp ${files[$i]} "$dirInformesAnteriores/"
    done
#ES_5940Se inicializa la variable de fichero de datos dond se recogen todos los datos finales.
	if [[ -f $nomFicheroDatosEjecucionAutomatica ]]; then
#ES_5950Se borran los ficheros anteriores
	fi
	echo -ne "Título AlgPag NumEnsayo T.esperamedio T.retornomedio TotalFallosPagina TotalExpulsionesForzadasRR" >> $nomFicheroDatosEjecucionAutomatica
	echo -ne " MáxFrec TiempoConsiderado FrecValor Clase" >> $nomFicheroDatosEjecucionAutomatica
	echo -e " MáxUsoRec TiempoConsiderado UsoRecValor Clase" >> $nomFicheroDatosEjecucionAutomatica
#ES_5960Ahora se leen los datos ya guardados en los ficheros de datos y se tratan.
#ES_5970Se define el fichero desde el que se leen los datos que se extraen de los subrangos.
		maxDatoCierre=0
		leer_datos_desde_fichero $nomFicheroDatos
#ES_5980Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
			maxDato=0
			maxDatoCierre=1
#ES_5990Se calcula el mayor de lso tiempos de ejecución para calcular un valor aleatorio entre 1 y ese máximo. Podría usarse cualquier rango, pero este dato puede estar relacionado con lso datos del problema.
				if [[ ${ejecucion[$i]} -gt $maxDato ]]; then 
					maxDato=${ejecucion[$i]} 
				fi
			done
		fi
		for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
#ES_6000Se define el fichero sobre el que se guardan los volcados en COLOR.
			if [[ -f $informeSinColorTotal ]]; then
#ES_6010Se borran los ficheros anteriores
			fi
#ES_6020Se define el fichero sobre el que se guardan los volcados en BN.
			if [[ -f $informeConColorTotal ]]; then
#ES_6030Se borran los ficheros anteriores
			fi
#ES_6040Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_6060 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_frecuencia_valor=$datoAleatorioGeneral
			fi
#ES_6070Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#ES_608010-11-Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#ES_6090 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#ES_610010-11-Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#ES_6110 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_frecuencia_valor=$datoAleatorioGeneral
#ES_612010-11-Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
#ES_6130 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
			fi
#ES_6140Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_6160 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_uso_rec_valor=$datoAleatorioGeneral
			fi
#ES_6170Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_6190 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_6210 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_uso_rec_valor=$datoAleatorioGeneral
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_6230 Generar un número aleatorio dentro del rango
				seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
			fi
#ES_6240Ordena los datos para ser mostrados y considerados por orden de llegada.
			echo -ne "$NORMAL\nAlgoritmo de paginación:$seleccionAlgoritmoPaginacion" | tee -a $informeConColorTotal
			echo -ne "$NORMAL\nNúmero de Ensayo:$indEnsayos\n" | tee -a $informeConColorTotal
			echo -e "Algoritmo de paginación: $seleccionAlgoritmoPaginacion" >> $informeSinColorTotal
			echo -e "Número de Ensayo: $indEnsayos" >> $informeSinColorTotal
#ES_6250Cuando se han definido todas las opciones se inicia la ejecución del programa
#ES_6260Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
			echo -ne "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado $seleccionAlgoritmoPaginacion $indEnsayos $promedio_espera $promedio_retorno $suma_contadorAlgPagFallosProcesoAcumulado $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
			echo -ne " $seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
			echo -e " $seleccionAlgoritmoPaginacion_uso_rec_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
		done
	done	
#ES_6270Fin de ejecutarEnsayosDatosIgualesAnteriores()

#
#ES_6280Se usan los conjuntos de datos ya definidos anteriormente para ejecutar los ensayos automáticos y se recoger los datos en ficheros secuenciales. Se usa el mismo conjunto de datos para el ensayo de todos y cada uno de los algoritmos.
#
function ejecutarEnsayosDatosIgualesAnterioresCompleto { 	
#ES_6290Se define la fuente de datos utilizada para la obtención de los datos a utilizar en el posterior tratamiento. 
#ES_6300Datos, que se ejecutan con las diferentes opciones.
#ES_6310Se definen los diferentes modos de ejecución (1-Ejecución por eventos // 2-Ejecución automática (Por eventos y sin pausas) // 3-Ejecución completa (Por eventos con pausas de cierto número de segundos) // 4-Ejecución por unidad de tiempo (Con un volcado en cada unidad de tiempo) // 5-Ejecución completa (Sin representación de resultados intermedios)) 
#ES_6320Sólo se guardan los datos de las medias de los tiempos de espera y retorno, el número de fallos de página totales y el número de expulsiones de procesos forzadas en RR totales. Viene de la variable $seleccionMenuModoTiempoEjecucionAlgormitmo en el menú de selección de modo de ejecución MenuModoTiempoEjecucionAlgormitmo()			
#ES_6330Se definen los diferentes directorios utilizados para guardar los datos obtenidos
	dirInformes="./Informes/RecogerDatosAutomIguales"
	dirInformesAnterioresCompleto="./Informes/RecogerDatosAutomIgualesAnterioresCompleto"
#ES_6340Se definen las variables necesarias para ejecutar los diferentes algoritmos y opciones.
#ES_6350Define el título de la cabecera de los volcados
#ES_6360Define el número de ensayo tratado 
#ES_6370Define el algoritmo usado para resolver la gestión de Procesos (FCFS/SJF/SRPT/Prioridades/Round-Robin)
#ES_6380Máximo número de algoritmos de gestión de procesos (FCFS (1), SJF (2), SRPT (3), Prioridades (4), Round-Robin (5)) que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#ES_6390Máximo número de opciones del tipo de memoria (No Continua (1)/Continua (2)) 
#ES_6400Máximo número de opciones del tipo de memoria (No Continua (0)/Continua (1)) 
#ES_6410Máximo número de opciones del tipo de memoria (No Reubicable (1)/Reubicable (2)) 
#ES_6420Máximo número de opciones del tipo de reubicabilidad (No Reubicable (0)/Reubicable (1)) 
#ES_6430Define el algoritmo usado para resolver los fallos de página.
#ES_6440Máximo número de algoritmos de paginación (FIFO, Reloj, SegOp, Óptimo, MFU, LFU, NFU, MRU, LRU, NRU,...) que se probarán con cada conjunto de datos sacados de los subrangos, previamente calculados desde el fichero de rangos amplios.
#ES_6450Máximo número de opciones del tipo de prioridad (Mayor (1)/Menor (2)) 
#ES_6460Máximo número de opciones del tipo de apropiatividad (No Apropiativo (1)/Apropiativo (2)) 
#ES_6470Máximo número de opciones del tipo de apropiatividad (No Apropiativo (0)/Apropiativo (1)) 
#ES_6480Define el tiempo de espera medio de los procesos 
#ES_6490Define el tiempo de retorno medio de los procesos
#ES_6500Define el número de fallos de página producidos
#ES_6510Define el número de expulsiones forzadas por Round-Robin (RR)
#ES_6520Define el valor máximo del contador de frecuencia, a partir de la cual, no será considerada.
#ES_6530Define el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#ES_6540Define el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#ES_6550Define el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada en algoritmos basados en la "frecuencia/tiempo de antigüedad" de uso
#ES_6560Define el valor máximo del contador de la antigüedad a partir de la cual no será considerada.
#ES_6570Define el valor máximo del contador de antigüedad en un intervalo de tiempo, a partir de la cual, no será considerada.
	
	if [[ ! -d $dirInformesAnterioresCompleto ]]; then
		mkdir $dirInformesAnterioresCompleto   
	fi
#ES_6580Primero se inicializan los ficheros con los datos a tratar.
#ES_6590Se define el fichero sobre el que se guardan los datos que se extraen de los subrangos.
		if [[ -f $nomFicheroDatos ]]; then
#ES_6600Se borran los ficheros anteriores
		fi
	done
    files=($dirInformes"/DatosDefault"*".txt")
    echo -e "\n\nFicheros existentes:\n$NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\nFicheros existentes:\n" >> $informeSinColorTotal 
#ES_6610Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
        echo -e ${files[$i]} 
        cp ${files[$i]} "$dirInformesAnterioresCompleto/"
    done
#ES_6620Se inicializa la variable de fichero de datos dond se recogen todos los datos finales.
	if [[ -f $nomFicheroDatosEjecucionAutomatica ]]; then
#ES_6630Se borran los ficheros anteriores
	fi
	echo -ne "Título NumEnsayo AlgGestProc Contin Reubic AlgPag TipoPrio Apropia Quantum" >> $nomFicheroDatosEjecucionAutomatica
	echo -ne " T.esperamedio T.retornomedio TotalFallosPagina TotalExpulsionesForzadasRR" >> $nomFicheroDatosEjecucionAutomatica
	echo -ne " MáxFrec TiempoConsiderado FrecValor FrecClase" >> $nomFicheroDatosEjecucionAutomatica
	echo -e " MáxUsoRec TiempoConsiderado UsoRecValor UsoRecClase" >> $nomFicheroDatosEjecucionAutomatica
#ES_6640Ahora se leen los datos ya guardados en los ficheros de datos y se tratan.
#ES_6650Se define el fichero desde el que se leen los datos que se extraen de los subrangos.
#ES_6660Si no se encuentra un archivo de datos por no haber creado previamente el conjunto de datos necesario, se muestra un mensaje de error y se para el bucle.
		echo -ne "Error: No se encuentra el fichero de datos "$nomFicheroDatos | tee -a $informeConColorTotal
		echo -ne "Error: No se encuentra el fichero de datos "$nomFicheroDatos >> $informeSinColorTotal 
		break
	fi		
		maxDatoCierre=0
		leer_datos_desde_fichero $nomFicheroDatos
#ES_6670Define el quantum utilizado en Round-Robin (RR). Se usa para salvar el dato hasta que se necesite y que no se repita en los listados.
#ES_6680Define el quantum utilizado en Round-Robin (RR)
#ES_6690Define el tipo de apropiatividad utilizado en Prioridad. Se usa para salvar el dato hasta que se necesite y que no se repita en los listados.
#ES_6700Define el Tipo de Prioridad (Mayor (1)/Menor (2)).
#ES_6710Define el modo de apropiatividad utilizado en Prioridad. Se usa para salvar el dato hasta que se necesite y que no se repita en los listados.
#ES_6720Define el Tipo de Apropiatividad (No Apropiativo (1)/Apropiativo (2)).
#ES_6730Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
			maxDato=0
			maxDatoCierre=1
#ES_6740Se calcula el mayor de lso tiempos de ejecución para calcular un valor aleatorio entre 1 y ese máximo. Podría usarse cualquier rango, pero este dato puede estar relacionado con lso datos del problema.
				if [[ ${ejecucion[$i]} -gt $maxDato ]]; then 
					maxDato=${ejecucion[$i]} 
				fi
			done
		fi
		for (( seleccionMenuAlgoritmoGestionProcesos=1 ; seleccionMenuAlgoritmoGestionProcesos<=$numAlgoritmosGestionProcesos ; seleccionMenuAlgoritmoGestionProcesos++ )); do
			if ([[ $seleccionMenuAlgoritmoGestionProcesos -ge 1 && $seleccionMenuAlgoritmoGestionProcesos -le 3 ]]) || [[ $seleccionMenuAlgoritmoGestionProcesos -eq 5 ]]; then
#ES_6750Para que se equipare al programa nuevo. Se aconseja quitar la variable $alg y estandarizar las variables a usar ??????????. También se define en menuAlgoritmoGestionProcesos, pero resulta necesario cuando no se pregunta por el algoritmo de gestión de procesos porque se ejecutan todos. 
#ES_6760Define el quantum utilizado en Round-Robin (RR). Se usa para recuperar el dato cuando se necesite y que no se repita en los listados.
#ES_6770Se hace para eliminar el espacio que contiene la variable, y por el que la exportación a fichero da problemas porque el resto de datos se desplazan hacia la derecha.
				fi
#ES_6780Define el número de opciones del tipo de memoria (Continua/No Continua)
				for (( seleccionMenuContinuidad=1 ; seleccionMenuContinuidad<=$numAlgoritmosContinuidad ; seleccionMenuContinuidad++ )); do
#ES_6790Define el número de opciones del tipo de memoria (Reubicable/No Reubicable)
					for (( seleccionMenuReubicabilidad=1 ; seleccionMenuReubicabilidad<=$numAlgoritmosReubicabilidad ; seleccionMenuReubicabilidad++ )); do		
						for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
#ES_6800Se define el fichero sobre el que se guardan los volcados en COLOR.
							if [[ -f $informeSinColorTotal ]]; then
#ES_6810Se borran los ficheros anteriores
							fi
#ES_6820Se define el fichero sobre el que se guardan los volcados en BN.
							if [[ -f $informeConColorTotal ]]; then
#ES_6830Se borran los ficheros anteriores
							fi
#ES_6840Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_6860 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_frecuencia_valor=$datoAleatorioGeneral
							fi
#ES_6870Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#ES_688010-11-Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#ES_6890 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#ES_690010-11-Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#ES_6910 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_clases_frecuencia_valor=$datoAleatorioGeneral
#ES_692010-11-Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
#ES_6930 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
							fi
#ES_6940Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_6960 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_uso_rec_valor=$datoAleatorioGeneral
							fi
#ES_6970Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_6990 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_7010 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_clases_uso_rec_valor=$datoAleatorioGeneral
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_7030 Generar un número aleatorio dentro del rango
								seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
							fi
#ES_7040Ordena los datos para ser mostrados y considerados por orden de llegada.
#ES_7050Cuando se han definido todas las opciones se inicia la ejecución del programa
#ES_7060Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
							echo -e "$NORMAL\n Número de Ensayo:$indEnsayos" | tee -a $informeConColorTotal
							echo -e "$NORMAL Algoritmo:$algoritmoPaginacionContinuidadReubicabilidadSeleccionado" | tee -a $informeConColorTotal
							echo -e " Número de Ensayo: $indEnsayos" >> $informeSinColorTotal
							echo -e " Algoritmo: $algoritmoPaginacionContinuidadReubicabilidadSeleccionado" >> $informeSinColorTotal
							echo -ne "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado $indEnsayos $seleccionMenuAlgoritmoGestionProcesos $seleccionMenuContinuidad $seleccionMenuReubicabilidad $seleccionAlgoritmoPaginacion" >> $nomFicheroDatosEjecucionAutomatica
							echo -ne " $seleccionTipoPrioridad $seleccionMenuApropiatividad $quantum $promedio_espera $promedio_retorno $suma_contadorAlgPagFallosProcesoAcumulado $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
							echo -ne " $seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
							echo -e " $seleccionAlgoritmoPaginacion_uso_rec_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
							
#ES_7070Se inicializan a "" para empezar el siguiente ciclo.
							seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=""
							seleccionAlgoritmoPaginacion_clases_frecuencia_valor=""
							seleccionAlgoritmoPaginacion_clases_valor=""
							seleccionAlgoritmoPaginacion_uso_rec_valor=""
							seleccionAlgoritmoPaginacion_clases_uso_rec_valor=""

#ES_7080$seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_uso_rec_valor
					done
				done
#ES_7090Define el quantum utilizado en Round-Robin (RR). Se vuelve a anular hasta que se necesite.
			fi
			if [[ $seleccionMenuAlgoritmoGestionProcesos -eq 4 ]]; then
#ES_7100Para que se equipare al programa nuevo. Se aconseja quitar la variable $alg y estandarizar las variables a usar ??????????.
#ES_7110Define el Tipo de Prioridad (Mayor (1)/Menor (2)).
				for (( seleccionTipoPrioridad=1 ; seleccionTipoPrioridad<=$numAlgoritmosTipoPrioridad ; seleccionTipoPrioridad++ )); do
#ES_7120Define el Tipo de Apropiatividad (No Apropiativo (1)/Apropiativo (2)).
					for (( seleccionMenuApropiatividad=1 ; seleccionMenuApropiatividad<=numAlgoritmosApropiatividad ; seleccionMenuApropiatividad++ )); do
#ES_7130Define el número de opciones del tipo de memoria (Continua/No Continua)
						for (( seleccionMenuContinuidad=1 ; seleccionMenuContinuidad<=$numAlgoritmosContinuidad ; seleccionMenuContinuidad++ )); do
#ES_7140Define el número de opciones del tipo de memoria (Reubicable/No Reubicable)
							for (( seleccionMenuReubicabilidad=1 ; seleccionMenuReubicabilidad<=$numAlgoritmosReubicabilidad ; seleccionMenuReubicabilidad++ )); do		
								for (( seleccionAlgoritmoPaginacion = 1; seleccionAlgoritmoPaginacion <= $numAlgoritmosPaginacion; seleccionAlgoritmoPaginacion++ )); do 
#ES_7150Se define el fichero sobre el que se guardan los volcados en COLOR.
									if [[ -f $informeSinColorTotal ]]; then
#ES_7160Se borran los ficheros anteriores
									fi
#ES_7170Se define el fichero sobre el que se guardan los volcados en BN.
									if [[ -f $informeConColorTotal ]]; then
#ES_7180Se borran los ficheros anteriores
									fi
#ES_7190Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_7210 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_frecuencia_valor=$datoAleatorioGeneral
									fi
#ES_7220Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
#ES_723010-11-Se pide el valor del tiempo de ejecución de un proceso a partir del cual serán consideradas la "frecuencia de uso/tiempo de uso" de una página y su clase.
#ES_7240 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
#ES_725010-11-Se pide el valor máximo del contador de frecuencia en un intervalo de tiempo, a partir de la cual, no será considerada.
#ES_7260 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_clases_frecuencia_valor=$datoAleatorioGeneral
#ES_727010-11-Se pide el valor máximo de unidades de tiempo de antigüedad a partir de la cual una página será considerada como NO referenciada
#ES_7280 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
									fi
#ES_7290Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_7310 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_uso_rec_valor=$datoAleatorioGeneral
									fi
#ES_7320Permite calcular el máximo del valor una única vez para cada conjunto de datos en cada ensayo, pero que sirve para todos los algoritmos de paginación.
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_7340 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=$datoAleatorioGeneral
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_7360 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_clases_uso_rec_valor=$datoAleatorioGeneral
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_7380 Generar un número aleatorio dentro del rango
										seleccionAlgoritmoPaginacion_clases_valor=$datoAleatorioGeneral
									fi
#ES_7390Ordena los datos para ser mostrados y considerados por orden de llegada.
#ES_7400Cuando se han definido todas las opciones se inicia la ejecución del programa
#ES_7410Se define la variable con el título completo del algoritmo ejecutado ($algoritmoPaginacionContinuidadReubicabilidadSeleccionado).
									echo -e "$NORMAL\n Número de Ensayo: $indEnsayos" | tee -a $informeConColorTotal
									echo -e "$NORMAL Algoritmo: $algoritmoPaginacionContinuidadReubicabilidadSeleccionado" | tee -a $informeConColorTotal
									echo -e " Número de Ensayo: $indEnsayos" >> $informeSinColorTotal
									echo -e " Algoritmo: $algoritmoPaginacionContinuidadReubicabilidadSeleccionado" >> $informeSinColorTotal
									echo -ne "$algoritmoPaginacionContinuidadReubicabilidadSeleccionado $indEnsayos $seleccionMenuAlgoritmoGestionProcesos $seleccionMenuContinuidad $seleccionMenuReubicabilidad $seleccionAlgoritmoPaginacion" >> $nomFicheroDatosEjecucionAutomatica
									echo -ne " $seleccionTipoPrioridad $seleccionMenuApropiatividad $quantum $promedio_espera $promedio_retorno $suma_contadorAlgPagFallosProcesoAcumulado $suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado" >> $nomFicheroDatosEjecucionAutomatica
									echo -ne " $seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
									echo -e " $seleccionAlgoritmoPaginacion_uso_rec_valor $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_clases_valor" >> $nomFicheroDatosEjecucionAutomatica
								
#ES_7420Se inicializan a "" para empezar el siguiente ciclo.
									seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado=""
									seleccionAlgoritmoPaginacion_clases_frecuencia_valor=""
									seleccionAlgoritmoPaginacion_clases_valor=""
									seleccionAlgoritmoPaginacion_uso_rec_valor=""
									seleccionAlgoritmoPaginacion_clases_uso_rec_valor=""
#ES_7430$seleccionAlgoritmoPaginacion_frecuencia_valor $seleccionAlgoritmoPaginacion_clases_uso_rec_valor $seleccionAlgoritmoPaginacion_uso_rec_valor 
							done
						done
					done
#ES_7440Define el Tipo de Apropiatividad (No Apropiativo (1)/Apropiativo (2)). Se vuelve a anular hasta que se vuelva a necesitar.
				done
#ES_7450Define el Tipo de Prioridad (Mayor (1)/Menor (2)). Se vuelve a anular hasta que se vuelva a necesitar.
			fi
		done
	done	
	
#ES_7460Fin de ejecutarEnsayosDatosIgualesAnterioresCompleto()

#
#
#ES_7470    Funciones
#
#
#
#ES_7480 Sinopsis: Para colorear lo impreso en pantalla.
#
function cecho {
	local default_msg="No message passed."                     
    message=${1:-$default_msg}   
    color=${2:-$FWHT}           
    echo -en "$color"
    echo "$message"
    tput sgr0                    
    return
#ES_7490Fin de cecho()

#
#ES_7500 Sinopsis: Genera los números de página a partir de las direcciones del proceso. 
#
function transformapag {
    let pagTransformadas[$2]=`expr $1/$mem_direcciones`
#ES_7510Fin de transformapag()

#
#ES_7520 Sinopsis: Calcula el número de direcciones por cada proceso y lo guarda en npagprocesos y el mayor número de páginas entre todos los procesos.
#
function vermaxpagsfichero {
#ES_7530Empieza en 14 por ser la primera línea del fichero con procesos.
	for (( npagp = 0; npagp <= $p; npagp++ )); do
		npagprocesos[$p]=`awk "NR==$i" $1 | wc -w `
		(( i++ ))	
	done
#ES_7540No se usa para nada
#ES_7550Calcula el mayor número de páginas de entre todos los procesos.
		if (( $verlas > $maxpags )); then
			maxpags=$verlas
		fi
	done
#ES_7560Fin de vermaxpagsfichero()

#
#ES_7570 Sinopsis: Se leen datos desde fichero 
#
function leer_datos_desde_fichero {
#ES_7580Lee los datos del fichero 
#ES_7590Primer dato -> Tamaño en memoria
#ES_7600Quinto dato -> Tamaño de pagina
	numDireccionesTotales=$(($mem_total * $mem_direcciones))
#ES_7610Segundo dato -> Prioridad menor
#ES_7620Tercero dato -> Prioridad mayor
#ES_7630Cuarto dato -> Tipo de prioridad - Realmente no se usa porque se introduce por teclado al seleccionar el algoritmo de gestión de procesos mediante la variable de selección $seleccionTipoPrioridad. 
#ES_7640Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#ES_7650Sexto dato -> Variable para la reubicabilidad - Realmente no se usa porque se introduce por teclado tras seleccionar la posibilidad de reubicar procesos. 
#ES_7660Séptimo dato -> Quantum de Round Robin (RR)
	maxfilas=`wc -l < $1`
#ES_7670Número de marcos totales de la memoria
#ES_7680Número de marcos vacíos
#ES_7690Tamaño de memoria total en direcciones
#ES_7700Número de procesos definidos en el problema
#ES_7710Índice local que recorre cada proceso definido en el problema
#ES_7720Índice que recorre cada dirección de cada proceso definido en el problema
#ES_7730Define el número de dígitos de pantalla usados para controlar los saltos de línea. Deja 1 de margen izquierdo y varios más para controlar el comienzo del espacio usado para los datos en la tabla resumen.
#ES_7740Se inicia con 16 por ser la primera línea del fichero que contiene procesos. 
		llegada[$p]=`awk "NR==$fila" $1 |  cut -d ' ' -f 1`
		memoria[$p]=`awk "NR==$fila" $1 |  cut -d ' ' -f 2`
		prioProc[$p]=`awk "NR==$fila" $1 |  cut -d ' ' -f 3`
#ES_7750(Usa el número de línea donde empiezan a definirse los procesos.) Calcula el número de direcciones por cada proceso y lo guarda en npagprocesos[] y el mayor número de páginas entre todos los procesos (maxpags).
		ejecucion[$p]=$(expr $[npagprocesos[$p]] - 3)
#ES_7760Para ser equivalente al nuevo programa
#ES_7770Contendrá el número de páginas ya usadas en la ejecución de cada proceso
#ES_7780El nombre de los procesos está predefinido: P01, P02, ...
		numOrdinalPagTeclado=0
#ES_7790maxpags es el mayor número de páginas entre todos los procesos. Se inicia con 4 por ser el primer campo que contiene direcciones en cada fila.
			directionsYModificado=`awk "NR==$fila" $1 | cut -d ' ' -f $i` 
			directions[$p,$numOrdinalPagTeclado]=`echo $directionsYModificado | cut -d '-' -f 1`
			directions_AlgPagFrecUsoRec_pagina_modificada[$p,$numOrdinalPagTeclado,0]=`echo $directionsYModificado | cut -d '-' -f 2`
			if [[ $seleccionAlgoritmoPaginacion -eq 0 && ${directions[$p,$numOrdinalPagTeclado]} -gt $(($numDireccionesTotales - 1)) ]]; then
				echo -e "\n***Error en la lectura de datos. La dirección de memoria utilizada está fuera del rango definido por el número de marcos de página.\n"
				exit 1
			fi
#ES_7800let pagTransformadas[$2]=`expr $1/$mem_direcciones`
			paginasDefinidasTotal[$p,$numOrdinalPagTeclado]=${pagTransformadas[$numOrdinalPagTeclado]} 
#ES_7810Posición en la que se define cada dirección dentro de un proceso.
			((one++))
		done
#ES_7820Se elimina para poder hacer una segunda lectura sin datos anteriores.
		p=$((p+1))
	done 
#ES_7830	clear
#ES_7840Se almacena el cálculo aleatorio de si una página es o no modificada al ser ejecutada.


#
#ES_7850 Sinopsis: Extrae los límites de los rangos del fichero de rangos de última ejecución. 
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
#*#ES_7870*Inicial - Datos a representar
#ES_7880Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	prio_menor_min=$PriomFinal
	prio_menor_max=$PrioMFinal
#Se invierten los rangos para calcular el mínimo, pero no para su representación, en la que se verán los datos originales *Inicial.
#*#ES_7900*Inicial - Datos a representar
#ES_7910Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
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
#ES_7920Si el mayor es menor que el menor, se invierten los rangos 
        invertirRangos $memoria_min $memoria_max
        memoria_min=$min
        memoria_max=$max
    fi 
#ES_7930Si ambos son negativos se desplazan a positivos
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
#ES_7940Este valor podría ser 0 
        llegada_max=$(($max - 1))
    fi 
    if [[ $tiempo_ejec_min -gt $tiempo_ejec_max ]]; then
        invertirRangos $tiempo_ejec_min $tiempo_ejec_max
        tiempo_ejec_min=$min
        tiempo_ejec_max=$max
    fi
    if [[ $tiempo_ejec_min -lt 0 ]]; then 
        desplazarRangos $tiempo_ejec_min $tiempo_ejec_max
#ES_7950Este valor podría ser 0 
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
#ES_7960?????????????????
        invertirRangos $prio_proc_min $prio_proc_max
#ES_7970Los valroes de las prioridades podrían ser 0 o negativos. 
        prio_proc_max=$max
    fi
#ES_7980?????????????????
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
#ES_7990Se comparará este valor con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.
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
#ES_8000Fin de leer_rangos_desde_fichero()

#
#ES_8010 Sinopsis: Compara variables con enteros
#
function es_entero {
#ES_8020 En caso de error, sentencia falsa
#ES_8030 Retorna si la sentencia anterior fue verdadera
#ES_8040Fin de es_entero()

#
#ES_8050 Sinopsis: Permite ordenar los datos sacados desde fichero y de entrada por teclado. 
#
function ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve {
#ES_8060llegada[@]} - 1)); j >= 0; j--)); do
        for ((i = 0; i <= $j; i++)); do
            if [[ ${llegada[$i]} -gt ${llegada[$(($i + 1))]} ]]; then
                aux=${proceso[$(($i + 1))]}
                proceso[$(($i + 1))]=${proceso[$i]} 
                proceso[$i]=$aux
                aux=${llegada[$(($i + 1))]}
                llegada[$(($i + 1))]=${llegada[$i]}
                llegada[$i]=$aux
#ES_8070Se permutan las páginas
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${paginasDefinidasTotal[$(($i + 1)),$counter2]}
				done
#ES_8080Se borran para que no pueda haber valores anteriores residuales.
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
#ES_8090Se permutan las direcciones
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${directions[$(($i + 1)),$counter2]}
				done
#ES_8100Se borran para que no pueda haber valores anteriores residuales.
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
#ES_8110Se permutan los valores de esta variable auxiliar porque se definió en leer_datos_desde_fichero().
                tiempoEjecucion[$i]=$aux
                aux=${memoria[$(($i + 1))]}
                memoria[$(($i + 1))]=${memoria[$i]} 
                memoria[$i]=$aux
                aux=${prioProc[$(($i + 1))]}
#ES_8120En caso de usar el algoritmo basado en Prioridades...
                prioProc[$i]=$aux
#ES_8130No se permutan los nombres de los procesos, como en ordenarDatosEntradaFicheros(), porque se definirán más tarde.
            fi
        done
    done
#ES_8140Fin de ordenarDatosEntradaFicheros_cuatro_cinco_seis_siete_ocho_nueve()

#
#ES_8150 Sinopsis: Se ordenan por t.llegada únicamente los datos que se meten en la introducción de procesos
#ES_8160 (posteriormente se ordenará todo ya que se añaden el resto de arrays con todos los datos de cada proceso).
#
#ES_8170En este caso se intercambian todos los datos al ordenar por tiempo de llegada.
#ES_8180llegada[@]}; i++ )); do
#ES_8190llegada[@]}; j++ )); do
            a=${llegada[$i]};
#ES_8200Asignamos variables (tiempos de llegada)
            if [[ $a -gt $b ]];      then
                aux=${proceso[$i]};
#ES_8210Ordenar los nombres
                proceso[$j]=$aux;
                aux=${llegada[$i]};        
#ES_8220Ordenar por menor tiempo de llegada
                llegada[$j]=$aux
                aux=${ejecucion[$i]};
#ES_8230Ordenar tiempos de ejecución 
                ejecucion[$j]=$aux;
                aux=${memoria[$i]};
#ES_8240Ordenar los tamaños
                memoria[$j]=$aux;
                aux=${numeroproceso[$i]};
#ES_8250Ordenar los números de proceso
                numeroproceso[$j]=$aux;
            fi
#ES_8260Si el orden de entrada coincide se arreglan dependiendo de cuál se ha metido primero
                c=${numeroproceso[$i]};
                d=${numeroproceso[$j]};
                if [[ $c -gt $d ]]; then
                    aux=${proceso[$i]};
#ES_8270Ordenar los nombres 
                    proceso[$j]=$aux
                    aux=${llegada[$i]};       
#ES_8280Ordenar los tiempo de llegada
                    llegada[$j]=$aux
                    aux=${ejecucion[$i]};
#ES_8290Ordenar tiempos de ejecución 
                    ejecucion[$j]=$aux;
                    aux=${memoria[$i]};
#ES_8300Ordenar los tamaños
                    memoria[$j]=$aux;
                    aux=${numeroproceso[$i]};
#ES_8310Ordenar los números de proceso
                    numeroproceso[$j]=$aux;
                fi
            fi
        done
    done
#ES_8320Fin de ordenSJF()

#
#
#ES_8330 Establecimiento de funciones para rangos                
#
#
#ES_8340 Sinopsis: Presenta una tabla con los rangos y valores calculados 
#
function datos_memoria_tabla {
#ES_8350    clear
    if [[ $seleccionMenuEleccionEntradaDatos -eq 4 ]]; then 
        echo -e "$amarillo Por favor establezca los rangos para datos"                  
    elif [[ $seleccionMenuEleccionEntradaDatos -eq 5 || $seleccionMenuEleccionEntradaDatos -eq 6 ]]; then 
        echo -e "$amarillo Resultados actuales:"                  
    fi
    echo -e "$azul┌────────────────────────────────────────────────────────────┐" | tee -a $informeConColorTotal
    printf  "$azul│$NC""${varhuecos:1:$((36))}""Min-Max rango     Valor""$azul │\n" | tee -a $informeConColorTotal
 tee -a $informeConColorTotal | tee -a $informeConColorTotal 
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
    echo -e "$azul└────────────────────────────────────────────────────────────┘"  | tee -a $informeConColorTotal
    echo -e "┌────────────────────────────────────────────────────────────┐" >> $informeSinColorTotal
    printf  "│$NC""${varhuecos:1:$((36))}""Min-Max rango     Valor"" │\n" >> $informeSinColorTotal
#ES_8640MARCOS}))}""$MIN_RANGE_MARCOS"" - " >> $informeSinColorTotal
#ES_8650mem_total}))}""$mem_total"" │\n" >> $informeSinColorTotal
#ES_8660DIRECCIONES}))}""$MIN_RANGE_DIRECCIONES"" - " >> $informeSinColorTotal
#ES_8670mem_direcciones}))}""$mem_direcciones"" │\n" >> $informeSinColorTotal
#ES_8680prio_menor_minInicial}))}""$prio_menor_minInicial"" - " >> $informeSinColorTotal
#ES_8690prio_menorInicial}))}""$prio_menorInicial"" │\n" >> $informeSinColorTotal
#ES_8700prio_menorInicial}))}""$prio_menorInicial"" │\n" >> $informeSinColorTotal
#ES_8710prio_mayor_minInicial}))}""$prio_mayor_minInicial"" - " >> $informeSinColorTotal
#ES_8720prio_mayorInicial}))}""$prio_mayorInicial"" │\n" >> $informeSinColorTotal
#ES_8730prio_mayorInicial}))}""$prio_mayorInicial"" │\n" >> $informeSinColorTotal
#ES_8740REUB}))}""$MIN_RANGE_REUB"" - " >> $informeSinColorTotal
#ES_8750reub}))}""$reub"" │\n" >> $informeSinColorTotal
#ES_8760NPROC}))}""$MIN_RANGE_NPROC"" - " >> $informeSinColorTotal
#ES_8770n_prog}))}""$n_prog"" │\n" >> $informeSinColorTotal
#ES_8780llegada}))}""$MIN_RANGE_llegada"" - " >> $informeSinColorTotal
#ES_8790llegada}))}""   │\n" >> $informeSinColorTotal
#ES_8800tiempo_ejec}))}""$MIN_RANGE_tiempo_ejec"" - " >> $informeSinColorTotal
#ES_8810tiempo_ejec}))}""   │\n" >> $informeSinColorTotal
#ES_8820tamano_marcos_proc}))}""$MIN_RANGE_tamano_marcos_proc"" - " >> $informeSinColorTotal
#ES_8830tamano_marcos_proc}))}""   │\n" >> $informeSinColorTotal
#ES_8840prio_proc}))}""$MIN_RANGE_prio_proc"" - " >> $informeSinColorTotal
#ES_8850prio_proc}))}""   │\n" >> $informeSinColorTotal
#ES_8860prio_menorInicial}))}""$prio_menorInicial"" - " >> $informeSinColorTotal
#ES_8870prio_mayorInicial}))}""   │\n" >> $informeSinColorTotal
#ES_8880quantum}))}""$MIN_RANGE_quantum"" - " >> $informeSinColorTotal
#ES_8890quantum}))}""│\n" >> $informeSinColorTotal
#ES_8900tamano_direcciones_proc}))}""$MIN_RANGE_tamano_direcciones_proc"" - " >> $informeSinColorTotal
#ES_8910tamano_direcciones_proc}))}""│\n" >> $informeSinColorTotal
    echo -e "└────────────────────────────────────────────────────────────┘" >> $informeSinColorTotal
#ES_8920Fin de datos_memoria_tabla()

#
#ES_8930 Sinopsis: Presenta una tabla con los datos de los rangos introducidos, y los subrangos y los valores calculables.
#
function datos_amplio_memoria_tabla {
#ES_8940    clear
    if [[ $seleccionMenuEleccionEntradaDatos -eq 4 ]]; then 
        echo -e "$amarillo Por favor establezca los rangos para datos"                  
    elif [[ $seleccionMenuEleccionEntradaDatos -eq 5 || $seleccionMenuEleccionEntradaDatos -eq 6 ]]; then 
        echo -e "$amarillo Resultados actuales:"                  
    fi
    echo -e "$azul┌────────────────────────────────────────────────────────────────────────┐" | tee -a $informeConColorTotal
    printf  "$azul│$NC""${varhuecos:1:$((33))}""Min-Max_amplio   Min-Max_rango   Valor""$azul │\n" | tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
    echo -e "$azul└────────────────────────────────────────────────────────────────────────┘" | tee -a $informeConColorTotal  
    
    echo -e "┌────────────────────────────────────────────────────────────────────────┐" >> $informeSinColorTotal
    printf "│$NC""${varhuecos:1:$((33))}""Min-Max_amplio Min-Max_rango Valor"" │\n" >> $informeSinColorTotal
#ES_9210memoria_maxInicial}))}""  " >> $informeSinColorTotal
#ES_9220mem_total}))}""$mem_total"" │\n" >> $informeSinColorTotal
#ES_9230direcciones_maxInicial}))}""  " >> $informeSinColorTotal
#ES_9240mem_direcciones}))}""$mem_direcciones"" │\n" >> $informeSinColorTotal
#ES_9250prio_menor_maxInicial}))}""  " >> $informeSinColorTotal
#ES_9260prio_menorInicial}))}""$prio_menorInicial"" │\n" >> $informeSinColorTotal
#ES_9270prio_mayor_maxInicial}))}""  " >> $informeSinColorTotal
#ES_9280prio_mayorInicial}))}""$prio_mayorInicial"" │\n" >> $informeSinColorTotal
#ES_9290reubicacion_maxInicial}))}""  " >> $informeSinColorTotal
#ES_9300reub}))}""$reub"" │\n" >> $informeSinColorTotal
#ES_9310programas_maxInicial}))}""  " >> $informeSinColorTotal
#ES_9320n_prog}))}""$n_prog"" │\n" >> $informeSinColorTotal
#ES_9330llegada_maxInicial}))}""  " >> $informeSinColorTotal
#ES_9340llegada}))}"" │\n" >> $informeSinColorTotal
#ES_9350tiempo_ejec_maxInicial}))}""  " >> $informeSinColorTotal
#ES_9360tiempo_ejec}))}"" │\n" >> $informeSinColorTotal
#ES_9370tamano_marcos_proc_maxInicial}))}""  " >> $informeSinColorTotal
#ES_9380tamano_marcos_proc}))}"" │\n" >> $informeSinColorTotal
#ES_9390prio_mayor}))}""  " >> $informeSinColorTotal
#ES_9400prio_mayor}))}"" │\n" >> $informeSinColorTotal
#ES_9410quantum_maxInicial}))}""  " >> $informeSinColorTotal
#ES_9420quantum}))}"" │\n" >> $informeSinColorTotal
#ES_9430tamano_direcciones_proc_maxInicial}))}""  " >> $informeSinColorTotal
#ES_9440tamano_direcciones_proc}))}"" │\n" >> $informeSinColorTotal
    echo -e "└────────────────────────────────────────────────────────────────────────┘" >> $informeSinColorTotal 
#ES_9450Fin de datos_amplio_memoria_tabla()

#ES_9460---------Funciones para el pedir por pantalla los mínimos y máximos de los rangos - Opción 4--------------                
#
#ES_9470 Sinopsis: Se piden por pantalla el mínimo y máximo del rango de la memoria total 
#
function datos_numero_marcos_memoria {
	datos_memoria_tabla 
    until [[ $MAX_RANGE_MARCOS -ge $MIN_RANGE_MARCOS && $MIN_RANGE_MARCOS -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de marcos de memoria$cian:$NC" 
#ES_9480Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de marcos de memoria$cian:$NC"
#ES_9490Rango maximo para la memoria
#ES_9500Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS
            MIN_RANGE_MARCOS=$min
            MAX_RANGE_MARCOS=$max
        fi
#ES_9510Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS
            MIN_RANGE_MARCOS=$min
            MAX_RANGE_MARCOS=$max
        fi  
    done
#ES_9520Fin de datos_numero_marcos_memoria()               

#
#ES_9530 Sinopsis: Se piden por pantalla el mínimo y máximo del rango de la memoria total 
#
function datos_numero_marcos_memoria_amplio {
	datos_amplio_memoria_tabla
    until [[ $memoria_maxInicial -ge $memoria_minInicial && $memoria_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de marcos de memoria$cian:$NC" 
#ES_9540Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de marcos de memoria$cian:$NC"
#ES_9550Rango maximo para la memoria
#ES_9560Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $memoria_minInicial $memoria_maxInicial
            memoria_minInicial=$min
            memoria_maxInicial=$max
        fi
#ES_9570Si ambos son negativos se desplazan a positivos 
            desplazarRangos $memoria_minInicial $memoria_maxInicial
            memoria_minInicial=$min
            memoria_maxInicial=$max
        fi  
    done
#ES_9580Se definen nuevas variables para redefinir los límites de los subrangos sacados de los rangos amplios. 
	memoria_max=$memoria_maxInicial
#ES_9590Fin de datos_numero_marcos_memoria_amplio()               

#
#ES_9600 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del número de procesos 
#
function datos_numero_direcciones_marco {
	datos_memoria_tabla 
    until [[ $MAX_RANGE_DIRECCIONES -ge $MIN_RANGE_DIRECCIONES && $MIN_RANGE_DIRECCIONES -gt 0 ]]; do                 
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de direcciones por marco$cian:$NC" 
#ES_9610Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de direcciones por marco$cian:$NC"
#ES_9620Rango maximo para la memoria
#ES_9630Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
            MIN_RANGE_DIRECCIONES=$min
            MAX_RANGE_DIRECCIONES=$max
        fi
#ES_9640Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
            MIN_RANGE_DIRECCIONES=$min
            MAX_RANGE_DIRECCIONES=$max
        fi  
    done                    
#ES_9650Fin de datos_numero_direcciones_marco() 

#
#ES_9660 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del número de procesos 
#
function datos_numero_direcciones_marco_amplio {
	datos_amplio_memoria_tabla
    until [[ $direcciones_maxInicial -ge $direcciones_minInicial && $direcciones_minInicial -gt 0 ]]; do                 
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de direcciones por marco$cian:$NC" 
#ES_9670Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de direcciones por marco$cian:$NC"
#ES_9680Rango maximo para la memoria
#ES_9690Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $direcciones_minInicial $direcciones_maxInicial
            direcciones_minInicial=$min
            direcciones_maxInicial=$max
        fi
#ES_9700Si ambos son negativos se desplazan a positivos 
            desplazarRangos $direcciones_minInicial $direcciones_maxInicial
            direcciones_minInicial=$min
            direcciones_maxInicial=$max
        fi  
    done                    
	direcciones_min=$direcciones_minInicial
	direcciones_max=$direcciones_maxInicial
#ES_9710Fin de datos_numero_direcciones_marco_amplio() 
                        
#
#ES_9720 Sinopsis: Se piden por pantalla el mínimo y máximo para el mínimo del rango de la prioridad
#
function datos_prio_menor {
	datos_memoria_tabla 
	echo -e "$cian Por favor, establezca el mínimo del rango para la prioridad menor$cian:$NC" 
#ES_9730Rango minimo para la variable prioridad
	echo -e "$cian Por favor, establezca el máximo del rango para la prioridad menor$cian:$NC"
#ES_9740Rango maximo para la variable prioridad
	prio_menor_min=$prio_menor_minInicial
	prio_menor_max=$prio_menor_maxInicial
#ES_9750Fin de datos_prio_menor()                               
                        
#
#ES_9760 Sinopsis: Se piden por pantalla el mínimo y máximo para el mínimo del rango de la prioridad
#
function datos_prio_menor_amplio {
	datos_amplio_memoria_tabla
	echo -e "$cian Por favor, establezca el mínimo del rango para la prioridad menor$cian:$NC" 
#ES_9770Rango minimo para la variable prioridad
	echo -e "$cian Por favor, establezca el máximo del rango para la prioridad menor$cian:$NC"
#ES_9780Rango maximo para la variable prioridad
	prio_menor_min=$prio_menor_minInicial
	prio_menor_max=$prio_menor_maxInicial
#ES_9790Fin de datos_prio_menor_amplio()                               
                        
#
#ES_9800 Sinopsis: Se piden por pantalla el mínimo y máximo para el máximo del rango de la prioridad
#
function datos_prio_mayor {
	datos_memoria_tabla 
	echo -e "$cian Por favor, establezca el mínimo del rango para la prioridad mayor$cian:$NC" 
#ES_9810Rango minimo para la variable prioridad
	echo -e "$cian Por favor, establezca el máximo del rango para la prioridad mayor$cian:$NC"
#ES_9820Rango maximo para la variable prioridad
	prio_mayor_min=$prio_mayor_minInicial
	prio_mayor_max=$prio_mayor_maxInicial
#ES_9830Fin de datos_prio_mayor()                               
                        
#
#ES_9840 Sinopsis: Se piden por pantalla el mínimo y máximo para el máximo del rango de la prioridad
#
function datos_prio_mayor_amplio {
	datos_amplio_memoria_tabla
	echo -e "$cian Por favor, establezca el mínimo del rango para la prioridad mayor$cian:$NC" 
#ES_9850Rango minimo para la variable prioridad
	echo -e "$cian Por favor, establezca el máximo del rango para la prioridad mayor$cian:$NC"
#ES_9860Rango maximo para la variable prioridad
	prio_mayor_min=$prio_mayor_minInicial
	prio_mayor_max=$prio_mayor_maxInicial
#ES_9870Fin de datos_prio_mayor_amplio()                               

#
#ES_9880 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del número de procesos 
#
function datos_numero_programas {
	datos_memoria_tabla 
    until [[ $MAX_RANGE_NPROC -ge $MIN_RANGE_NPROC && $MIN_RANGE_NPROC -gt 0 ]]; do                 
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de procesos$cian:$NC" 
#ES_9890Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de procesos$cian:$NC"
#ES_9900Rango maximo para la memoria
#ES_9910Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_NPROC $MAX_RANGE_NPROC
            MIN_RANGE_NPROC=$min
            MAX_RANGE_NPROC=$max
        fi
#ES_9920Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_NPROC $MAX_RANGE_NPROC
            MIN_RANGE_NPROC=$min
            MAX_RANGE_NPROC=$max
        fi  
    done                    
#ES_9930Fin de datos_numero_programas() 

#
#ES_9940 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del número de procesos 
#
function datos_numero_programas_amplio {
	datos_amplio_memoria_tabla
    until [[ $programas_maxInicial -ge $programas_minInicial && $programas_minInicial -gt 0 ]]; do                 
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de procesos$cian:$NC" 
#ES_9950Rango minimo para la memoria
        echo -e "$cian Por favor, establezca el máximo del rango para el número de procesos$cian:$NC"
#ES_9960Rango maximo para la memoria
#ES_9970Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $programas_minInicial $programas_maxInicial
            programas_minInicial=$min
            programas_maxInicial=$max
        fi
#ES_9980Si ambos son negativos se desplazan a positivos 
            desplazarRangos $programas_minInicial $programas_maxInicial
            programas_minInicial=$min
            programas_maxInicial=$max
        fi  
    done                    
		programas_min=$programas_minInicial
		programas_max=$programas_maxInicial
#ES_9990Fin de datos_numero_programas_amplio() 

#
#ES_10000 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del máximo de unidades de memoria admisible para la reubicabilidad
#
function datos_tamano_reubicacion { 
	datos_memoria_tabla 
#ES_10010Si el mayor es menor que el menor, se invierten los rangos
        echo -e "$cian Por favor, establezca el mínimo del rango para la variable de reubicacion$cian:$NC" 
#ES_10020Rango minimo para la variable reubicacion
        echo -e "$cian Por favor, establezca el máximo del rango para la variable de reubicacion$cian:$NC" 
#ES_10030Rango maximo para la variable reubicacion
#ES_10040Si límite mínimo mayor que límite máximo
            invertirRangos $MIN_RANGE_REUB $MAX_RANGE_REUB
            MIN_RANGE_REUB=$min
            MAX_RANGE_REUB=$max
        fi
#ES_10050Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_REUB $MAX_RANGE_REUB
            MIN_RANGE_REUB=$min
            MAX_RANGE_REUB=$max
        fi  
    done                        
#ES_10060Fin de datos_tamano_reubicacion()

#
#ES_10070 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del máximo de unidades de memoria admisible para la reubicabilidad
#
function datos_tamano_reubicacion_amplio { 
	datos_amplio_memoria_tabla
#ES_10080Si el mayor es menor que el menor, se invierten los rangos
        echo -e "$cian Por favor, establezca el mínimo del rango para la variable de reubicacion$cian:$NC" 
#ES_10090Rango minimo para la variable reubicacion
        echo -e "$cian Por favor, establezca el máximo del rango para la variable de reubicacion$cian:$NC" 
#ES_10100Rango maximo para la variable reubicacion
#ES_10110Si límite mínimo mayor que límite máximo
            invertirRangos $reubicacion_minInicial $reubicacion_maxInicial
            reubicacion_minInicial=$min
            reubicacion_maxInicial=$max
        fi
#ES_10120Si ambos son negativos se desplazan a positivos 
            desplazarRangos $reubicacion_minInicial $reubicacion_maxInicial
            reubicacion_minInicial=$min
            reubicacion_maxInicial=$max
        fi  
		reubicacion_min=$reubicacion_minInicial
		reubicacion_max=$reubicacion_maxInicial
    done                        
#ES_10130Fin de datos_tamano_reubicacion_amplio()
                
#
#ES_10140 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tiempo de llegada de los procesos
#
function datos_tiempo_llegada {
	datos_memoria_tabla 
    MIN_RANGE_llegada=-1 
    until [[ $MAX_RANGE_llegada -ge $MIN_RANGE_llegada && $(($MIN_RANGE_llegada + 1)) -gt 0 ]]; do  
        echo -e "$cian Por favor, establezca el mínimo del rango para el tiempo de llegada$cian:$NC" 
#ES_10150Rango minimo para la variable tiempo de llegada
        echo -e "$cian Por favor, establezca el máximo del rango para el tiempo de llegada$cian:$NC" 
#ES_10160Rango maximo para la variable tiempo de llegada
        if [[ $MIN_RANGE_llegada -gt $MAX_RANGE_llegada ]]; then
            invertirRangos $MIN_RANGE_llegada $MAX_RANGE_llegada
            MIN_RANGE_llegada=$min
            MAX_RANGE_llegada=$max
        fi
#ES_10170Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_llegada $MAX_RANGE_llegada
#ES_10180Este valor es el único que puede ser 0
            MAX_RANGE_llegada=$(($max - 1))
        fi  
    done
#ES_10190Fin de datos_tiempo_llegada()                       
                
#
#ES_10200 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tiempo de llegada de los procesos
#
function datos_tiempo_llegada_amplio {
	datos_amplio_memoria_tabla
    llegada_minInicial=-1 
    until [[ $llegada_maxInicial -ge $llegada_minInicial && $(($llegada_minInicial + 1)) -gt 0 ]]; do  
        echo -e "$cian Por favor, establezca el mínimo del rango para el tiempo de llegada$cian:$NC" 
#ES_10210Rango minimo para la variable tiempo de llegada
        echo -e "$cian Por favor, establezca el máximo del rango para el tiempo de llegada$cian:$NC" 
#ES_10220Rango maximo para la variable tiempo de llegada
        if [[ $llegada_minInicial -gt $llegada_maxInicial ]]; then
            invertirRangos $llegada_minInicial $llegada_maxInicial
            llegada_minInicial=$min
            llegada_maxInicial=$max
        fi
#ES_10230Si ambos son negativos se desplazan a positivos 
            desplazarRangos $llegada_minInicial $llegada_maxInicial
#ES_10240Este valor es el único que puede ser 0
            llegada_maxInicial=$(($max - 1))
        fi  
		llegada_min=$llegada_minInicial
		llegada_max=$llegada_maxInicial
    done
#ES_10250Fin de datos_tiempo_llegada_amplio()                       
                        
#
#ES_10260 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tiempo de ejecución de los procesos
#
function datos_tiempo_ejecucion {
	datos_memoria_tabla 
    until [[ $MAX_RANGE_tiempo_ejec -ge $MIN_RANGE_tiempo_ejec && $MIN_RANGE_tiempo_ejec -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el tiempo de ejecución$cian:$NC" 
#ES_10270Rango minimo para la variable tiempo de ejecución
        echo -e "$cian Por favor, establezca el máximo del rango para el tiempo de ejecución$cian:$NC"
#ES_10280Rango maximo para la variable tiempo de ejecución
#ES_10290Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_tiempo_ejec $MAX_RANGE_tiempo_ejec
            MIN_RANGE_tiempo_ejec=$min
            MAX_RANGE_tiempo_ejec=$max
        fi
#ES_10300Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_tiempo_ejec $MAX_RANGE_tiempo_ejec
            MIN_RANGE_tiempo_ejec=$min
            MAX_RANGE_tiempo_ejec=$max
        fi  
    done
#ES_10310Fin de datos_tiempo_ejecucion()                               
                        
#
#ES_10320 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tiempo de ejecución de los procesos
#
function datos_tiempo_ejecucion_amplio {
	datos_amplio_memoria_tabla
    until [[ $tiempo_ejec_maxInicial -ge $tiempo_ejec_minInicial && $tiempo_ejec_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el tiempo de ejecución$cian:$NC" 
#ES_10330Rango minimo para la variable tiempo de ejecución
        echo -e "$cian Por favor, establezca el máximo del rango para el tiempo de ejecución$cian:$NC"
#ES_10340Rango maximo para la variable tiempo de ejecución
#ES_10350Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $tiempo_ejec_minInicial $tiempo_ejec_maxInicial
            tiempo_ejec_minInicial=$min
            tiempo_ejec_maxInicial=$max
        fi
#ES_10360Si ambos son negativos se desplazan a positivos 
            desplazarRangos $tiempo_ejec_minInicial $tiempo_ejec_maxInicial
            tiempo_ejec_minInicial=$min
            tiempo_ejec_maxInicial=$max
        fi  
		tiempo_ejec_min=$tiempo_ejec_minInicial
		tiempo_ejec_max=$tiempo_ejec_maxInicial
    done
#ES_10370Fin de datos_tiempo_ejecucion_amplio()                               
                        
#
#ES_10380 Sinopsis: Se piden por pantalla el mínimo y máximo del rango de la prioridad de los procesos
#
function datos_prio_proc {
	datos_memoria_tabla 
#ES_10390Fin de datos_prio_proc()                               
                        
#
#ES_10400 Sinopsis: Se piden por pantalla el mínimo y máximo del rango de la prioridad de los procesos
#
function datos_prio_proc_amplio {
	datos_amplio_memoria_tabla
#ES_10410Fin de datos_prio_proc_amplio()                               

#
#ES_10420 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tamaño en memoria de los procesos
#
function datos_tamano_marcos_procesos {                
	datos_memoria_tabla 
    until [[ $MAX_RANGE_tamano_marcos_proc -ge $MIN_RANGE_tamano_marcos_proc && $MIN_RANGE_tamano_marcos_proc -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de marcos asociados a cada proceso$cian:$NC" 
#ES_10430Rango minimo para la variable tamaño del proceso en marcos
        echo -e "$cian Por favor, establezca el máximo del rango para el número de marcos asociados a cada proceso:$NC" 
#ES_10440Rango maximo para la variable tamaño del proceso en marcos
#ES_10450Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_tamano_marcos_proc $MAX_RANGE_tamano_marcos_proc
            MIN_RANGE_tamano_marcos_proc=$min
            MAX_RANGE_tamano_marcos_proc=$max
        fi
#ES_10460Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_tamano_marcos_proc $MAX_RANGE_tamano_marcos_proc
            MIN_RANGE_tamano_marcos_proc=$min
            MAX_RANGE_tamano_marcos_proc=$max
        fi  
    done
#ES_10470Fin de datos_tamano_marcos_procesos()

#
#ES_10480 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tamaño en memoria de los procesos
#
function datos_tamano_marcos_procesos_amplio {                
	datos_amplio_memoria_tabla
    until [[ $tamano_marcos_proc_maxInicial -ge $tamano_marcos_proc_minInicial && $tamano_marcos_proc_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el número de marcos asociados a cada proceso$cian:$NC" 
#ES_10490Rango minimo para la variable tamaño del proceso en marcos
        echo -e "$cian Por favor, establezca el máximo del rango para el número de marcos asociados a cada proceso:$NC" 
#ES_10500Rango maximo para la variable tamaño del proceso en marcos
#ES_10510Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $tamano_marcos_proc_minInicial $tamano_marcos_proc_maxInicial
            tamano_marcos_proc_minInicial=$min
            tamano_marcos_proc_maxInicial=$max
        fi
#ES_10520Si ambos son negativos se desplazan a positivos 
            desplazarRangos $tamano_marcos_proc_minInicial $tamano_marcos_proc_maxInicial
            tamano_marcos_proc_minInicial=$min
            tamano_marcos_proc_maxInicial=$max
        fi  
		tamano_marcos_proc_min=$tamano_marcos_proc_minInicial
		tamano_marcos_proc_max=$tamano_marcos_proc_maxInicial
    done
#ES_10530Fin de datos_tamano_marcos_procesos_amplio()

#
#ES_10540 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tamaño en memoria de los procesos
#
function datos_tamano_direcciones_procesos {                
	datos_memoria_tabla 
    until [[ $MAX_RANGE_tamano_direcciones_proc -ge $MIN_RANGE_tamano_direcciones_proc && $MIN_RANGE_tamano_direcciones_proc -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el tamaño del proceso en direcciones$cian:$NC" 
#ES_10550Rango minimo para la variable tamaño del proceso en direcciones
        echo -e "$cian Por favor, establezca el máximo del rango para el tamaño del proceso en direcciones$cian:$NC" 
#ES_10560Rango maximo para la variable tamaño del proceso en direcciones
#ES_10570Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_tamano_direcciones_proc $MAX_RANGE_tamano_direcciones_proc
            MIN_RANGE_tamano_direcciones_proc=$min
            MAX_RANGE_tamano_direcciones_proc=$max
        fi
#ES_10580Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_tamano_direcciones_proc $MAX_RANGE_tamano_direcciones_proc
            MIN_RANGE_tamano_direcciones_proc=$min
            MAX_RANGE_tamano_direcciones_proc=$max
        fi  
    done
#ES_10590Fin de datos_tamano_direcciones_procesos()

#
#ES_10600 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tamaño en memoria de los procesos
#
function datos_tamano_direcciones_procesos_amplio {                
	datos_amplio_memoria_tabla
    until [[ $tamano_direcciones_proc_maxInicial -ge $tamano_direcciones_proc_minInicial && $tamano_direcciones_proc_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el tamaño del proceso en direcciones$cian:$NC" 
#ES_10610Rango minimo para la variable tamaño del proceso en direcciones
        echo -e "$cian Por favor, establezca el máximo del rango para el tamaño del proceso en direcciones$cian:$NC" 
#ES_10620Rango maximo para la variable tamaño del proceso en direcciones
#ES_10630Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $tamano_direcciones_proc_minInicial $tamano_direcciones_proc_maxInicial
            tamano_direcciones_proc_minInicial=$min
            tamano_direcciones_proc_maxInicial=$max
        fi
#ES_10640Si ambos son negativos se desplazan a positivos 
            desplazarRangos $tamano_direcciones_proc_minInicial $tamano_direcciones_proc_maxInicial
            tamano_direcciones_proc_minInicial=$min
            tamano_direcciones_proc_maxInicial=$max
        fi  
		tamano_direcciones_proc_min=$tamano_direcciones_proc_minInicial
		tamano_direcciones_proc_max=$tamano_direcciones_proc_maxInicial
    done
#ES_10650Fin de datos_tamano_direcciones_procesos_amplio()

#
#ES_10660 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tamaño en memoria de los procesos
#
function datos_quantum {                
	datos_memoria_tabla 
    until [[ $MAX_RANGE_quantum -ge $MIN_RANGE_quantum && $MIN_RANGE_quantum -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el quantum$cian:$NC" 
#ES_10670Rango minimo para la variable tamaño del proceso en direcciones
        echo -e "$cian Por favor, establezca el máximo del rango para el quantum$cian:$NC" 
#ES_10680Rango maximo para la variable tamaño del proceso en direcciones
#ES_10690Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $MIN_RANGE_quantum $MAX_RANGE_quantum
            MIN_RANGE_quantum=$min
            MAX_RANGE_quantum=$max
        fi
#ES_10700Si ambos son negativos se desplazan a positivos 
            desplazarRangos $MIN_RANGE_quantum $MAX_RANGE_quantum
            MIN_RANGE_quantum=$min
            MAX_RANGE_quantum=$max 
        fi  
    done
#ES_10710Fin de datos_quantum()

#
#ES_10720 Sinopsis: Se piden por pantalla el mínimo y máximo del rango del tamaño en memoria de los procesos
#
function datos_quantum_amplio {                
	datos_amplio_memoria_tabla
    until [[ $quantum_maxInicial -ge $quantum_minInicial && $quantum_minInicial -gt 0 ]]; do
        echo -e "$cian Por favor, establezca el mínimo del rango para el quantum:$NC" 
#ES_10730Rango minimo para la variable tamaño del proceso en direcciones
        echo -e "$cian Por favor, establezca el máximo del rango para el quantum$cian:$NC" 
#ES_10740Rango maximo para la variable tamaño del proceso en direcciones
#ES_10750Si el mayor es menor que el menor, se invierten los rangos
            invertirRangos $quantum_minInicial $quantum_maxInicial
            quantum_minInicial=$min
            quantum_maxInicial=$max
        fi
#ES_10760Si ambos son negativos se desplazan a positivos 
            desplazarRangos $quantum_minInicial $quantum_maxInicial
            quantum_minInicial=$min
            quantum_maxInicial=$max
        fi  
		quantum_min=$quantum_minInicial
		quantum_max=$quantum_maxInicial
    done
#ES_10770Fin de datos_quantum_amplio()

#ES_10780---------Funciones para el cálculo de los datos desde los rangos--------------                
#
#ES_10790 Sinopsis: Dato calculado de forma aleatoria desde su subrango. Puede usarse para calcular el Mínimo y Máximo del subrango, calculado desde el rango amplio.
#
function calcDatoAleatorioGeneral {
#ES_10800Variable devuelta: mem=$((RANDOM % ($max - $min + 1) + $min))
#ES_10810min=$MIN_RANGE_MARCOS
#ES_10820max=$MAX_RANGE_MARCOS
#ES_10830 Generar un número aleatorio dentro del rango
#ES_10840Fin de calcDatoAleatorioGeneral()

#
#ES_10850Si los mínimos son mayores que los invierten los rangos. 
#
function invertirRangos {
    aux=$1
    min=$2
    max=$aux
#ES_10860Fin de invertirRangos()

#
#ES_10870Si mínimo y máximo son negativos se desplaza el mínimo hasta ser 0. 
#
function desplazarRangos {
#ES_10880La condición es estrictamente mayor para que si sólo hay una unidad de diferencia se quedan iguales.
#ES_10890Todos los valores mínimos tienen que ser 1 como mínimo, salvo el tiempo de llegada que podría ser 0
#ES_10900Fin de desplazarRangos()

#
#ES_10910 Sinopsis: Define el color de cada dígito de cada unidad a representar - Color por defecto
#
function colorDefaultInicio {
    for (( j=0; j<5; j++)); do
        coloresPartesTiempo=("${coloresPartesTiempo[@]}" "${coloress[97]}")
    done
#ES_10920Fin de colorDefaultInicio()

#
#ES_10930 Sinopsis: Define el color de cada dígito de cada unidad a representar - Color del proceso anterior
#
function colorAnterior {
    for (( j=0; j<$digitosUnidad; j++)); do
        coloresPartesTiempo=("${coloresPartesTiempo[@]}" "${coloress[$proanterior]}")
    done
#ES_10940Fin de datos_numero_marcos_memoria_amplio()

#
#ES_10950 Sinopsis: Establece los colores de cada proceso
#
function  Establecimiento_colores_proces {
    col=1
    aux=0
    for (( i=0,j=0; i<$nprocesos; i++,j++)); do
#ES_10960coloress[@]} - 2 ]
        indice[$i]=$j
        while [[ ${indice[$i]} -ge $auxiliar ]]; do
            indice[$i]=$[ ${indice[$i]} - $auxiliar ]
        done
        colores[$i]=${coloress[${indice[$i]}]}
        colorfondo[$i]=${colorfondos[${indice[$i]}]}
#ES_10970Para que se reinicien los colores
            j=$((j-16))
#ES_10980Cierre para que se reinicien los colores
    done
#ES_10990Fin de Establecimiento_colores_proces()

#
#ES_11000 Sinopsis: Define el color de cada dígito de cada unidad a representar - Color de otras unidades del proceso actual
#
function colorunidMemOcupadas { 
    for (( j=0; j<$digitosUnidad; j++)); do
        coloresPartesMemoria=("${coloresPartesMemoria[@]}" "${coloress[${unidMemOcupadas[$ra]}]}")
    done
#ES_11010Fin de colorunidMemOcupadas()

#
#ES_11020 Sinopsis: Define el color de cada dígito de cada unidad de la memoria y tiempo a representar - Color por defecto
#
function colorDefaultBMBT { 
    for (( j=0; j<$digitosUnidad; j++)); do
        coloresPartesMemoria=("${coloresPartesMemoria[@]}" "${coloress[97]}")
    done
#ES_11030Fin de colorDefaultBMBT()

#
#ES_11040 Sinopsis: Dada una unidad de 3 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#ES_110503 - ancho de columnas estrechas en tabla resumen de procesos en los volcados 
#ES_11060No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC"
#ES_11070Fin de imprimirEspaciosEstrechos()

#ES_110803 - ancho de columnas estrechas en tabla resumen de procesos en los volcados 
#ES_11090No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal"
#ES_11100Fin de imprimirEspaciosEstrechosBN()

#
#ES_11110 Sinopsis: Dada una unidad de 4 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#ES_111204 - ancho de columnas anchas en tabla resumen de procesos en los volcados
#ES_11130No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC" 
#ES_11140Fin de imprimirEspaciosAnchos()

#ES_111504 - ancho de columnas anchas en tabla resumen de procesos en los volcados
#ES_11160No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal" 
#ES_11170Fin de imprimirEspaciosAnchosBN()

#
#ES_11180 Sinopsis: Dada una unidad de 5 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#ES_111905 - ancho de columnas más anchas en tabla resumen de procesos en los volcados
#ES_11200No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC"
#ES_11210Fin de imprimirEspaciosMasAnchos()

#ES_112205 - ancho de columnas más anchas en tabla resumen de procesos en los volcados
#ES_11230No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal"
#ES_11240Fin de imprimirEspaciosMasAnchosBN()

#
#ES_11250 Sinopsis: Dada una unidad de 17 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#ES_1126017 - ancho de columnas muy anchas en tabla resumen de procesos en los volcados 
#ES_11270No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC"
#ES_11280Fin de imprimirEspaciosMuyAnchos()

#ES_1129017 - ancho de columnas muy anchas en tabla resumen de procesos en los volcados 
#ES_11300No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal"
#ES_11310Fin de imprimirEspaciosMuyAnchosBN()

#
#ES_11320 Sinopsis: Dada una unidad de 9 dígitos, se calcula el número de espacios a poner por delante para rellenar.
#
#ES_113309 - ancho de columnas anchas en tabla de rangos 
#ES_11340No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "${varC[$i]}$espaciosfinal$NC"
#ES_11350Fin de imprimirEspaciosRangosLargos()

#ES_113609 - ancho de columnas anchas en tabla de rangos 
#ES_11370No se restan los espacios laterales izquierdo y derecho porque se pintarán por separado. 
    espaciosfinal=${varhuecos:1:$TamNum}
    echo -ne "$espaciosfinal"
#ES_11380Fin de imprimirEspaciosRangosLargos()

#
#ES_11390 Sinopsis: Se eliminan los archivos de última ejecución que había anteriormente creados y 
#ES_11400 nos direcciona a la entrada de particiones y procesos
#
function nuevaEjecucion {
#ES_11410    clear
    if [[ -f $ficheroDatosAnteriorEjecucion ]]; then
        rm $ficheroDatosAnteriorEjecucion   
    fi
    if [[ -f $ficherosRangosAnteriorEjecucion && ($seleccionMenuEleccionEntradaDatos -eq 4 || $seleccionMenuEleccionEntradaDatos -eq 6 || $seleccionMenuEleccionEntradaDatos -eq 7 || $seleccionMenuEleccionEntradaDatos -eq 8 || $seleccionMenuEleccionEntradaDatos -eq 9) ]]; then
        rm $ficherosRangosAnteriorEjecucion     
    fi
    if [[ -f $ficheroRangosAleTotalAnteriorEjecucion && ($seleccionMenuEleccionEntradaDatos -eq 7 || $seleccionMenuEleccionEntradaDatos -eq 9) ]]; then
        rm $ficheroRangosAleTotalAnteriorEjecucion     
    fi
#ES_11420Fin de nuevaEjecucion()

#
#ES_11430 Sinopsis: Se calcula el tamaño máximo de la unidad para contener todos los datos que se generen sin modificar el ancho de la columna necesaria
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
#ES_11440Fin de calcularUnidad()

#
#ES_11450 Sinopsis: Permite introducir las particiones y datos desde otro fichero (predefinido).
#
function entradaMemoriaDatosFichero {
#ES_11460    clear
    echo -e $ROJO"\nFicheros de datos a elegir en './FDatos/': "$NORMAL | tee -a $informeConColorTotal
    echo -e "\nFicheros de datos a elegir en './FDatos/': " >> $informeSinColorTotal
    files=($(ls -l ./FDatos/ | awk '{print $9}'))
#ES_11470Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
        echo -e "$i) ${files[$i]}"
    done
    echo -ne "$AMARILLO\n\n\nIntroduce el número correspondiente al fichero a analizar: $NORMAL" | tee -a $informeConColorTotal
    echo -ne "\n\n\nIntroduce el número correspondiente al fichero a analizar: " >> $informeSinColorTotal
    read -r numeroFichero
#ES_11480files[@]} ]]; do
        echo -ne "Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read -r numeroFichero
        echo -e "$numeroFichero\n\n" >> $informeConColorTotal
        echo -e "$numeroFichero\n\n" >> $informeSinColorTotal
    done
    ficheroParaLectura="./FDatos/${files[$numeroFichero]}"
#ES_11490Fin de entradaMemoriaDatosFichero()

#
#ES_11500 Sinopsis: Permite introducir las particiones y datos desde otro fichero (predefinido).
#
function entradaMemoriaRangosFichero {
#ES_11510    clear
    echo -e $ROJO"\nFicheros de datos a elegir en './FDatos/': "$NORMAL | tee -a $informeConColorTotal
    echo -e "\nFicheros de datos a elegir en './FDatos/': " >> $informeSinColorTotal
    files=($(ls -l ./FDatos/ | awk '{print $9}'))
#ES_11520Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
        echo -e "$i) ${files[$i]}"
    done
    echo -ne "$AMARILLO\n\n\nIntroduce el número correspondiente al fichero a analizar: $NORMAL" | tee -a $informeConColorTotal
    echo -ne "\n\n\nIntroduce el número correspondiente al fichero a analizar: " >> $informeSinColorTotal
    read -r numeroFichero
#ES_11530files[@]} ]]; do
        echo -ne "Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read -r numeroFichero
        echo -e "$numeroFichero\n\n" >> $informeConColorTotal
        echo -e "$numeroFichero\n\n" >> $informeSinColorTotal
    done
    ficheroParaLectura="./FDatos/${files[$numeroFichero]}"
#ES_11540Fin de datos_numero_marcos_memoria_amplio()

#
#ES_11550 Sinopsis: Se inicilizan diferentes tablas y variables
#
function inicializaVectoresVariables { 
#ES_11560 -----------------------------------------------------------------------------
#ES_11570 Se inicilizan las tablas indicadoras de la MEMORIA NO CONTINUA
#ES_11580Se crea el array para determinar qué unidades de memoria están ocupadas y se inicializan con _
    for (( ca=0; ca<(mem_total); ca++)); do
        unidMemOcupadas[$ca]="_"
#ES_11590Se crea un array auxiliar para realizar la reubicación
    done
#ES_11600Se crea variables para determinar si hay que reubicar (en un primer momento no)
#ES_11610En caso de ser memoria no continua, si hay un hueco demasiado pequeño, y se va a usar como parte de la memoria a usar.
    reubicarReubicabilidad=0 
#ES_11620En caso de ser memoria continua, si no hay un hueco suficientemente grande en el que quepa pero sí en la suma de todos ellos.
    reubicarContinuidad=0 
#ES_11630 -----------------------------------------------------------------------------
#ES_11640 Se inicilizan las tablas indicadoras de la situación del proceso
#ES_11650Copia algunas listas para luego ponerlas en orden
        entradaAuxiliar[$i]=${llegada[$i]} 
        temp_rej[$i]="-"
#ES_11660Para ser equivalente al nuevo programa
        memoriaAuxiliar[$i]=${memoria[$i]}
        encola[$i]=0
        enmemoria[$i]=0
        enejecucion[$i]=0
        bloqueados[$i]=0
        enpausa[$i]=0 
#ES_11670Determina qué procesos han terminado (1).
#ES_11680Determina qué procesos han terminado cuyo resumen de fallos de página ha sido imprimido (1).
        nollegado[$i]=0
        estad[$i]=0 
        estado[$i]=0
        temp_wait[$i]="-"
        temp_resp[$i]="-"
        temp_ret[$i]="-"
        pos_inicio[$i]="-"
        pos_final[$i]="-"
#ES_11690Guarda si un proceso está escrito o no EN EL ARRAY.
#ES_11700Almacena el valor de en cuantos bloques se fragmenta un proceso
#ES_11710Controla qué procesos están presentes en la banda de tiempo. Se van poniendo a 1 a medida que se van metiendo en las variables de las líneas de la banda de tiempos.
#ES_11720Número de Marcos ya usadas de cada Proceso.
#ES_11730Número de Páginas ya usadas de cada Proceso.
#ES_11740Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
#ES_11750Número de Páginas ya dibujadas de cada Proceso para el resumen de Banda.		
#ES_11760Fallos de página totales de cada proceso.
#ES_11770Mayor "frecuencia/uso de página".
		max_AlgPagFrecRec_Position[$i]=0
#ES_11780Menor "frecuencia/uso de página".
		min_AlgPagFrecRec_Position[$i]=0
		indiceResuPaginaProceso[$i]="_"
		indiceResuPaginaAcumulado[$i]="_"
#ES_11790Número de Fallos de Página de cada Proceso.
#ES_11800Número de expulsiones forzadas en Round-Robin (RR) 
#ES_11810Controlan el ordinal del tiempo de ejecución que hace que se cambió un valor de las clases y la frecuencia de uso de cada página en cada ordinal de tiempo de ejecución.
			primerTiempoEntradaPagina[$i,$indMarco]=0 
			restaFrecUsoRec[$i,$indMarco,0]=0
			directions_AlgPagFrecUsoRec_marco_pagina_clase[$i,$indMarco,0]=0
			directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$i,$indMarco]=0
		done
#ES_11820Contiene el orden de ejecución de Round-Robin (RR). Será "-" mientras no esté en cola, o cuando haya terminado, y si aún no ha terminado contendrá el número ordinal del siguiente quantum. El proceso a ejecutar será, por tanto, el que tenga el número ordinal más bajo. Y el número de quantums realizados (cambios de contexto, será el número ordinal más alto.
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
#ES_11830Establece el color de cada proceso
    blanco="\e[37m"
#ES_11840Para ser equivalente al nuevo programa
#ES_11850Para ser equivalente al nuevo programa
#ES_11860 Se calcula el valor máximo del número de unidades de tiempo. Como mucho, los tiempos de llegada más los tiempos de ejecución. Ese será el número de elementos máximo del array procPorUnidadTiempoBT 
#ES_11870proceso[@]}; j++)); do
        maxProcPorUnidadTiempoBT=$(expr $maxProcPorUnidadTiempoBT + ${llegada[$j]} + ${ejecucion[$j]})  
    done  
#ES_11880 Se pone un valor que nunca se probará (tope dinámico). Osea, el mismo que maxProcPorUnidadTiempoBT.
#ES_11890Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
	ejecutandoinst=-1
#ES_11900Determina el mayor número que podría ser representado por Tllegada y Tejecucion
#ES_11910Timpo ejecutado de un proceso que se comparará con el quantum para ser sacado de CPU.
#ES_11920Índice con el primer ordinal libre a repartir en Round-Robin (RR). Irá creciendo con cada puesto de quantum repartido y marca el futuro orden de ejecución. 
#ES_11930Índice con el actual ordinal en ejecución para Round-Robin (RR). Irá creciendo con cada quantum ejecutado y marca el actual número ordinal de uantum en ejecución. 
#ES_11940    clear
#ES_11950Fin de inicializaVectoresVariables()

#
#ES_11960 Sinopsis: Se inicializan las variables con diferentes acumulados en cada instante de reloj. Algunos acumulados sólo serían necesarios cuando se produzcan eventos, pero se podrían generalizar haciendo acumulados en cada instante. 
#
#ES_11970Se ejecuta en cada instante mientra que otras funciones sólo si se producen ciertas condiciones. Sería mejor inicializar aquí los acumulados.
#ES_11980Se arrastran los datos del siguiente fallo de página para cada proceso en cada unidad de tiempo.
		if [[ $reloj -ne 0 ]]; then
#ES_11990Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
		fi
	done
#ES_12000Fin de inicializarAcumulados()

#
#ES_12010 Sinopsis: Gestión de procesos - FCFS
#
function gestionProcesosFCFS {
    if [[ $cpu_ocupada == "NO" ]]; then
        if [[ $realizadoAntes -eq 0 ]]; then  
            indice_aux=-1
#ES_12020Establecemos qué proceso es el siguiente que llega a memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
#ES_12030El siguiente proceso que llega a memoria
                    temp_aux=${temp_rej[$i]}
                    break
                fi
            done
#ES_12040Hemos encontrado el siguiente proceso en memoria
#ES_12050Marco el proceso para ejecutarse
#ES_12060Quitamos el estado pausado si el proceso lo estaba anteriormente
#ES_12070Marcamos el proceso como en memoria
#ES_12080La CPU está ocupada por un proceso
#ES_12090Se activa el aviso de entrada en CPU del volcado
            fi
        fi
    fi
#ES_12100Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
        done
#ES_12110Si no hay proceso en ejecución se pone -1, para que pueda ser comparado.  
#ES_12120Resumen - Proceso en ejecución en cada instante de tiempo. 
		else
			ResuTiempoProceso[$reloj]=-1
		fi 
	fi
#ES_12130Si se trabaja NFU/NRU con clases.
#ES_12140Se traspasan todos los datos al siguiente instante para ser modificados, si se produce nmodificaciones al analizar los fallos y usos de las páginas. 
#ES_12150 
#ES_12160 
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#ES_12170Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.
#ES_12180Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#ES_12190Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#ES_12200Se lanza la gestión sin algoritmo de paginación, dado que en memoria no virtual los procesos entran en memoria de forma completa y no por páginas como en memoria virtual.
#ES_12210Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#ES_12220Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#ES_12230Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#ES_12240Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#ES_12250Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi 

#ES_12260ESTADO DE CADA PROCESO
#ES_12270Se modifican los valores de los arrays, restando de lo que quede
#ES_12280ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizaran tras imprimir.)
    for (( i=0; i<$nprocesos; i++ )); do
        if [[ ${nollegado[$i]} -eq 1 ]] ; then
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
        if [[ ${encola[$i]} -eq 1 && ${bloqueados[$i]} -eq 1 && ${temp_wait[$i]} == "-" && ${temp_ret[$i]} == "-" ]] ; then
#ES_12290Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#ES_12300Aunque no entre en memoria ya tiene datos a considerar.
        fi
        if [[ ${encola[$i]} -eq 1 && ${bloqueados[$i]} -eq 1 ]] ; then
            estado[$i]="En espera"
            estad[$i]=1
        fi
        if [[ ${enmemoria[$i]} -eq 1 && ${temp_wait[$i]} == "-" && ${temp_ret[$i]} == "-" ]] ; then
#ES_12310Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#ES_12320Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
        if [[ ${enmemoria[$i]} -eq 1 && ${enejecucion[$i]} -eq 1 ]] ; then
            estado[$i]="En ejecucion"
            estad[$i]=3
#ES_12330Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
        elif [[ ${enmemoria[$i]} -eq 1 && ${enpausa[$i]} -eq 1 ]] ; then
            estado[$i]="En pausa"
        elif [[ ${enmemoria[$i]} -eq 1 ]] ; then
            estado[$i]="En memoria"
            estad[$i]=2
        fi
#ES_12340Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
            estado[$i]="Finalizado"
            estad[$i]=5
#ES_12350Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
        elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
            estado[$i]="Finalizado"
            estad[$i]=5
        fi
    done

#ES_12360Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#ES_12370SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#ES_12380En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
#ES_12390Siempre se imprimie el volcado en T=0. y también cuando se escoja la impresión unidad de tiempo a unidad de tiempo (seleccionMenuModoTiempoEjecucionAlgormitmo = optejecucion = 4).
        evento=1
    fi
#ES_12400Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#ES_12410Fin de gestionProcesosFCFS()

#
#ES_12420 Sinopsis: Gestión de procesos - SJF
#
function gestionProcesosSJF {
#ES_12430ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizarán tras lanzar el volcado.)
#ES_12440Se modifican los valores de los arrays.
#ES_12450No ha llegado por tiempo de llegada.
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
#ES_12460Se encola pero no ha llegado por tiempo de llegada.
#ES_12470Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#ES_12480Aunque no entre en memoria ya tiene datos a considerar.
            estado[$i]="En espera"
            estad[$i]=1
        fi
#ES_12490Se mete en memoria.
#ES_12500Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#ES_12510Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
    done
 
#ES_12520Se establece el proceso con menor tiempo de ejecución de los que están en memoria.
        if [[ $realizadoAntes -eq 0 ]]; then  
#ES_12530Contendrá un tiempo de ejecución de referencia (el primero encontrado) para su comparación con el de otros procesos.
            temp_aux=0
#ES_12540Se busca el primer tiempo de ejecución de todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
                    if [[ ${temp_rej[$i]} -gt $temp_aux ]]; then
#ES_12550Proceso de referencia
#ES_12560Tiempo de ejecución de referencia
                    fi
                fi
#ES_12570Una vez encontrado el primero, se van a comparar todos los procesos hasta encontrar el de tiempo restante de ejecución más pequeño.
            min_indice_aux=-1  
#ES_12580Contendrá el menor tiempo de ejecución para su comparación con el de otros procesos.
#ES_12590Se establece qué proceso tiene menor tiempo de ejecución de todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${terminados[$i]} -ne 1 ]]; then
                    if [[ ${temp_rej[$i]} -lt $min_temp_aux ]]; then
#ES_12600Proceso de ejecución más corta hasta ahora
#ES_12610Tiempo de ejecución menor hasta ahora
                    fi
                fi
            done
#ES_12620Una vez encontrado el proceso más corto, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#ES_12630Marco el proceso para ejecutarse.
#ES_12640Quitamos el estado pausado si el proceso lo estaba anteriormente.
#ES_12650La CPU está ocupada por un proceso.
#ES_12660Se activa el aviso de entrada en CPU del volcado
            fi
        fi
    fi
#ES_12670Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
            if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enejecucion[$i]} -eq 1 ]] ; then 
                estado[$i]="En ejecucion"
                estad[$i]=3
#ES_12680Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enpausa[$i]} -eq 1 ]] ; then
                estado[$i]="En pausa"
                estad[$i]=4
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  ]] ; then
                estado[$i]="En memoria"
                estad[$i]=2
            fi
#ES_12690Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
                estado[$i]="Finalizado"
                estad[$i]=5
#ES_12700Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
            elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
                estado[$i]="Finalizado"
                estad[$i]=5
            fi
        done
    fi
#ES_12710Si no hay proceso en ejecución se pone -1, para que pueda ser comparado.  
#ES_12720Resumen - Proceso en ejecución en cada instante de tiempo. 
	else
		ResuTiempoProceso[$reloj]=-1
	fi 

#ES_12730Si se trabaja NFU/NRU con clases.
#ES_12740Se traspasan todos los datos al siguiente instante para ser modificados, si se produce nmodificaciones al analizar los fallos y usos de las páginas. 
#ES_12750 
#ES_12760 
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#ES_12770Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.

#ES_12780Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#ES_12790Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#ES_12800Se lanza la gestión sin algoritmo de paginación, dado que en memoria no virtual los procesos entran en memoria de forma completa y no por páginas como en memoria virtual.
#ES_12810Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#ES_12820Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#ES_12830Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#ES_12840Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#ES_12850Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi

#ES_12860Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#ES_12870SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#ES_12880En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
    if [[ $reloj -eq 0 || $optejecucion = "4" ]]; then 
        evento=1
    fi
#ES_12890Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#ES_12900Fin de gestionProcesosSJF()

#
#ES_12910 Sinopsis: Gestión de procesos - SRPT
#
function gestionProcesosSRPT {
#ES_12920ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizarán tras lanzar el volcado.)
#ES_12930Se modifican los valores de los arrays.
#ES_12940No ha llegado por tiempo de llegada.
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
#ES_12950Se encola pero no ha llegado por tiempo de llegada.
#ES_12960Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#ES_12970Aunque no entre en memoria ya tiene datos a considerar.
            estado[$i]="En espera"
            estad[$i]=1
        fi
#ES_12980Se mete en memoria.
#ES_12990Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#ES_13000Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
    done
 
#ES_13010Se establece el proceso con mayor y menor tiempo de ejecución de los que están en memoria.
        if [[ $realizadoAntes -eq 0 ]]; then  
#ES_13020Contendrá un tiempo de ejecución de referencia (el mayor tiempo de ejecución encontrado) para su comparación con el de otros procesos. Se busca el mayor para poder encontrar el primero de los de tiempo de ejecución más bajo.
            temp_aux=0
#ES_13030Se busca el mayor tiempo de ejecución de todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
                    if [[ ${temp_rej[$i]} -gt $temp_aux ]]; then
#ES_13040Proceso con el mayor tiempo de ejecución.
#ES_13050Tiempo de ejecución de referencia.
                    fi
                fi
#ES_13060Una vez encontrado el mayor, se van a comparar todos los procesos hasta encontrar el de menor tiempo restante de ejecución.
            min_indice_aux=-1  
#ES_13070Contendrá el menor tiempo de ejecución para su comparación con el de otros procesos.
#ES_13080Se establece qué proceso tiene menor tiempo de ejecución de todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${terminados[$i]} -ne 1 ]]; then
                    if [[ ${temp_rej[$i]} -lt $min_temp_aux ]]; then
#ES_13090Proceso de tiempo de ejecución más bajo hasta ahora.
#ES_13100Tiempo de ejecución menor hasta ahora.
                    fi
                fi
            done
#ES_13110Una vez encontrado el proceso más corto, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#ES_13120Marcamos el proceso como no ejecutándose si lo estaba anteriormente.
#ES_13130Ponemos el estado pausado si el proceso anteriormente en ejecución.
#ES_13140Marco el proceso para ejecutarse.
#ES_13150Quitamos el estado pausado si el proceso lo estaba anteriormente.
#ES_13160La CPU está ocupada por un proceso.
#ES_13170Si había otro proceso en ejecución con anterioridad se avisa que se pone en pausa.
					avisoPausa[$anteriorProcesoEjecucion]=1 
                fi
#ES_13180Se activa el aviso de entrada en CPU del volcado
                anteriorProcesoEjecucion=$min_indice_aux
            fi
        fi
    fi
#ES_13190Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
            if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enejecucion[$i]} -eq 1 ]] ; then 
                estado[$i]="En ejecucion"
                estad[$i]=3
#ES_13200Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enpausa[$i]} -eq 1 ]] ; then
                estado[$i]="En pausa"
                estad[$i]=4
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  ]] ; then
                estado[$i]="En memoria"
                estad[$i]=2
            fi
#ES_13210Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
                estado[$i]="Finalizado"
                estad[$i]=5
#ES_13220Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
            elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
                estado[$i]="Finalizado"
                estad[$i]=5
            fi
        done
    fi
#ES_13230Si no hay proceso en ejecución se pone -1, para que pueda ser comparado. 
#ES_13240Resumen - Proceso en ejecución en cada instante de tiempo. 
	else
		ResuTiempoProceso[$reloj]=-1
	fi 

#ES_13250Si se trabaja NFU/NRU con clases.
#ES_13260Se traspasan todos los datos al siguiente instante para ser modificados, si se producen modificaciones al analizar los fallos y usos de las páginas.   
#ES_13270 
#ES_13280 
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#ES_13290Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.

#ES_13300Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#ES_13310Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#ES_13320Se lanza la gestión sin algoritmo de paginación, dado que en memoria no virtual los procesos entran en memoria de forma completa y no por páginas como en memoria virtual.
#ES_13330Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#ES_13340Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#ES_13350Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#ES_13360Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#ES_13370Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi
    
#ES_13380Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#ES_13390SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#ES_13400En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
    if [[ $reloj -eq 0 || $optejecucion = "4" ]]; then 
        evento=1
    fi
#ES_13410Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#ES_13420Fin de gestionProcesosSRPT()

#
#ES_13430 Sinopsis: Gestión de procesos - Prioridades (Mayor/Menor)
#
function gestionProcesosPrioridades {
#ES_13440ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizarán tras lanzar el volcado.)
#ES_13450Se modifican los valores de los arrays.
#ES_13460No ha llegado por tiempo de llegada.
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
#ES_13470Se encola pero no ha llegado por tiempo de llegada.
#ES_13480Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#ES_13490Aunque no entre en memoria ya tiene datos a considerar.
#ES_13500Aunque no entre en memoria ya tiene datos a considerar.
            estado[$i]="En espera"
            estad[$i]=1
        fi
#ES_13510Se mete en memoria.
#ES_13520Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#ES_13530Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
#ES_13540Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
    done
	if [[ $realizadoAntes -eq 0 ]]; then  
        cerrojo_aux=0
#ES_13550Variable de cierre
#ES_13560Se busca la mayor prioridad de todas las que se encuentran en memoria.
			if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
#ES_13570Se inicializan las variables para determinar el mayor valor de la priridad de los procesos en memoria.
#ES_13580Se inicializa la variable con el primer proceso para la menor prioridad.
#ES_13590Prioridad de referencia.
					cerrojo_aux=1
				fi
				if [[ ${temp_prio[$i]} -gt $prio_aux && $cerrojo_aux -eq 1 ]]; then
#ES_13600Proceso con la menor prioridad.
#ES_13610Prioridad de referencia.
				fi
			fi
#ES_13620Una vez encontrada la mayor prioridad, se van a comparar todos los procesos hasta encontrar el de prioridad más baja.
#ES_13630Prioridad mayor de los procesos en memoria.
#ES_13640Proceso con la mayor prioridad.
#ES_13650Variable de cierre  
#ES_13660Contendrá la menor prioridad para su comparación con la de otros procesos. Se le pone un valor superior al máximo porque se busca el primero de los que tengan el menor valor.
#ES_13670Se establece qué proceso tiene menor prioridad de todos los que se encuentran en memoria.
			if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${terminados[$i]} -ne 1 ]]; then
				if [[ ${temp_prio[$i]} -lt $min_prio_aux ]]; then
#ES_13680Proceso de prioridad más baja hasta ahora
#ES_13690Prioridad menor hasta ahora
				fi
			fi
		done
	fi
#ES_13700Si es Prioridad Mayor y se invierte el rango, se calcula la Prioridad Menor, y viveversa. 
		if [[ $seleccionTipoPrioridad -eq 1 ]]; then 
			seleccionTipoPrioridad_2=2
		elif [[ $seleccionTipoPrioridad -eq 2 ]]; then 
			seleccionTipoPrioridad_2=1
		fi
#ES_13710Si el rango de Prioridades no se invierte, se deja sin modificar la elección Mayor/Menor.
		seleccionTipoPrioridad_2=$seleccionTipoPrioridad
	fi
#ES_13720Se establece el proceso con menor prioridad de los que están en memoria.
#ES_13730seleccionMenuApropiatividad - 1-No apropiativo - 2-Apropiativo
#ES_13740Prioridad Mayor/Apropiativo - Se roba la CPU por ser Apropiativo.
#ES_13750Una vez encontrado el proceso de menor prioridad, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#ES_13760Marcamos el proceso como no ejecutándose si lo estaba anteriormente.
#ES_13770Ponemos el estado pausado si el proceso anteriormente en ejecución.
#ES_13780Marco el proceso para ejecutarse.
#ES_13790Quitamos el estado pausado si el proceso lo estaba anteriormente.
#ES_13800La CPU está ocupada por un proceso.
#ES_13810Una vez encontrado el proceso con más baja prioridad, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#ES_13820Se activa el aviso de entrada en CPU del volcado
				fi
#ES_13830Se activa el aviso de entrada en CPU del volcado
				anteriorProcesoEjecucion=$max_indice_aux
			fi
#ES_13840Prioridad Menor/Apropiativo - Se roba la CPU por ser Apropiativo.
#ES_13850Una vez encontrado el proceso de menor prioridad, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#ES_13860Marcamos el proceso como no ejecutándose si lo estaba anteriormente.
#ES_13870Ponemos el estado pausado si el proceso anteriormente en ejecución.
#ES_13880Marco el proceso para ejecutarse.
#ES_13890Quitamos el estado pausado si el proceso lo estaba anteriormente.
#ES_13900La CPU está ocupada por un proceso.
#ES_13910Si había otro proceso en ejecución con anterioridad se avisa que se pone en pausa.
					avisoPausa[$anteriorProcesoEjecucion]=1 
				fi
#ES_13920Se activa el aviso de entrada en CPU del volcado
				anteriorProcesoEjecucion=$min_indice_aux
			fi
		fi
	fi

#ES_13930Se establece el proceso con menor prioridad de los que están en memoria.
#ES_13940seleccionMenuApropiatividad - 1-No apropiativo - 2-Apropiativo
#ES_139501 Prioridad Mayor/No Apropiativo - No se roba la CPU por ser NO Apropiativo.
#ES_13960Una vez encontrado el proceso más corto, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#ES_13970Marco el proceso para ejecutarse.
#ES_13980Quitamos el estado pausado si el proceso lo estaba anteriormente.
#ES_13990La CPU está ocupada por un proceso.
#ES_14000Se activa el aviso de entrada en CPU del volcado
			fi
#ES_140102 Prioridad Menor/No Apropiativo - No se roba la CPU por ser NO Apropiativo.
#ES_14020Una vez encontrado el proceso más corto, se pone en ejecución. Y si había otro en ejecución y no ha terminado, se marca como "En pausa".
#ES_14030Marco el proceso para ejecutarse.
#ES_14040Quitamos el estado pausado si el proceso lo estaba anteriormente.
#ES_14050La CPU está ocupada por un proceso.
#ES_14060Se activa el aviso de entrada en CPU del volcado
			fi
		fi
    fi

#ES_14070Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
            if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enejecucion[$i]} -eq 1 ]] ; then 
                estado[$i]="En ejecucion"
                estad[$i]=3
#ES_14080Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enpausa[$i]} -eq 1 ]] ; then
                estado[$i]="En pausa"
                estad[$i]=4
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  ]] ; then
                estado[$i]="En memoria"
                estad[$i]=2
            fi
#ES_14090Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
                estado[$i]="Finalizado"
                estad[$i]=5
#ES_14100Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
            elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
                estado[$i]="Finalizado"
                estad[$i]=5
            fi
        done
    fi
#ES_14110Si no hay proceso en ejecución se pone -1, para que pueda ser comparado. 
#ES_14120Resumen - Proceso en ejecución en cada instante de tiempo. 
	else
		ResuTiempoProceso[$reloj]=-1
	fi 

#ES_14130Si se trabaja NFU/NRU con clases.
#ES_14140Se traspasan todos los datos al siguiente instante para ser modificados, si se producen modificaciones al analizar los fallos y usos de las páginas.   
#ES_14150 
#ES_14160 
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#ES_14170Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.

#ES_14180Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#ES_14190Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#ES_14200Se lanza la gestión sin algoritmo de paginación, dado que en memoria no virtual los procesos entran en memoria de forma completa y no por páginas como en memoria virtual.
#ES_14210Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#ES_14220Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#ES_14230Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#ES_14240Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#ES_14250Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi
    
#ES_14260Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#ES_14270SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#ES_14280En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
    if [[ $reloj -eq 0 || $optejecucion = "4" ]]; then 
        evento=1
    fi
#ES_14290Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#ES_14300Fin de gestionProcesosPrioridades()

#
#ES_14310 Sinopsis: Gestión de procesos - Round Robin
#
function gestionProcesosRoundRobin {
#ES_14320ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizarán tras lanzar el volcado.)
#ES_14330Se modifican los valores de los arrays. Primero se trabaja con los estados y tiempos de las estadísticas.
#ES_14340No ha llegado por tiempo de llegada.
            estado[$i]="Fuera del Sistema"
            estad[$i]=0
        fi 
#ES_14350Se encola pero no ha llegado por tiempo de llegada.
#ES_14360Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#ES_14370Aunque no entre en memoria ya tiene datos a considerar.
            estado[$i]="En espera"
            estad[$i]=1
        fi
#ES_14380Se mete en memoria.
#ES_14390Se inicializan a 0 para poder operar con el número
            temp_ret[$i]=0
#ES_14400Cuando entre en memoria, si no se había considerado antes en cola, ya tiene datos a considerar.
        fi
    done
#ES_14410Se modifican los valores de los arrays, pero ahora se trabaja con el proceso que pueda haber terminado.
#ES_14420Si termina el proceso, su referencias en la cola RR se actualiza a "_", y el contador $contadorTiempoRR a 0.
			colaTiempoRR[$i]=-1 
#ES_14430Marcamos el proceso como no ejecutándose si lo estaba anteriormente.
#ES_14440Índice con el actual ordinal en ejecución para Round-Robin (RR).
			anteriorProcesoEjecucion=$i
#ES_14450Para que el proceso que se vaya a ejecutar empiece a usar su quantum desde 0.
		fi 
    done
#ES_14460Se modifican los valores de los arrays. Y ahora se trabaja con el resto de variables para trabajar sobre los tiempos ya establecidos ya que dependen de ellos en algunos casos.
#ES_14470Si termina el quantum de un proceso, su referencias en la cola RR se actualiza al último valor del $contadorTiempoRR.
#ES_14480Se marca el proceso par no ser ejecutado ya que comenzará a ejecutarse otro proceso.
#ES_14490Se marca el proceso como "en pausa".
#ES_14500Número de expulsiones forzadas en Round-Robin (RR) 
			anteriorProcesoEjecucion=$i
			contadorTiempoRR=0
			colaTiempoRR[$i]=$indiceColaTiempoRRLibre  
#ES_14510Índice con el primer ordinal libre a repartir en Round-Robin (RR).
#ES_14520Índice con el actual ordinal en ejecución para Round-Robin (RR).
#ES_14530Provoca un volcado en cada final de quantum
#ES_14540Se marca que la CPU no está ocupada por un proceso.
		fi 
    done
#ES_14550En primer lugar se establece el primer proceso que haya entrado en memoria por tiempo de llegada, o por estricto orden de llegada en memoria.
        if [[ $realizadoAntes -eq 0 ]]; then  
#ES_14560Se busca el primer proceso de entre todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
#ES_14570Si hay nuevos procesos en memoria se les encola.
						colaTiempoRR[$i]=$indiceColaTiempoRRLibre  
						indiceColaTiempoRRLibre=$(($indiceColaTiempoRRLibre + 1))
					fi 
                fi
#ES_14580Una vez encolados, se determina si se sigue ejecutando el mismo que ya lo estaba en el instante anterior, o se determina cuál se ejecutará en el instante actual, si el proceso anterior o su quantum han terminado.
#ES_14590Se busca el primer proceso de entre todos los que se encuentran en memoria.
                if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1 && ${terminados[$i]} -ne 1 ]]; then
#ES_14600Si es nuevo, empieza a ejecutarse. Si el proceso está marcado como en ejecución, el contador $contadorTiempoRR aumenta en una unidad.
						contadorTiempoRR=$(($contadorTiempoRR + 1))
#ES_14610Se marca el proceso para ejecutarse o se refuerza si ya lo estaba.
#ES_14620Se quita el estado pausado si el proceso lo estaba anteriormente.
#ES_14630Se marca que la CPU está ocupada por un proceso o se refuerza si ya lo estaba.
#ES_14640Si había otro proceso en ejecución con anterioridad se avisa que se pone en pausa.
							avisoPausa[$anteriorProcesoEjecucion]=1 
						fi
#ES_14650Se activa el aviso de entrada en CPU del volcado
					fi 
				fi
            done 
        fi
    fi
#ES_14660Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
        for (( i=0; i<$nprocesos; i++ )); do
            if [[ ${enejecucion[$i]} -eq 1 ]]; then
                ejecutandoinst=$i
            fi
            if [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enejecucion[$i]} -eq 1 ]] ; then 
                estado[$i]="En ejecucion"
                estad[$i]=3
#ES_14670Mete el número de orden del proceso que se mantiene en ejecución en la posición reloj de procPorUnidadTiempoBT.
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  && ${enpausa[$i]} -eq 1 ]] ; then
                estado[$i]="En pausa"
                estad[$i]=4
            elif [[ ${enmemoria[$i]} -eq 1 && ${escrito[$i]} -eq 1  ]] ; then
                estado[$i]="En memoria"
                estad[$i]=2
            fi
#ES_14680Tiene esta doble condición porque una vez que pase a terminado no puede estar en otro estado.
                estado[$i]="Finalizado"
                estad[$i]=5
#ES_14690Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
            elif [[ ${terminados[$i]} -eq 1 && ${terminadosAux[$i]} -eq 1 ]] ; then 
                estado[$i]="Finalizado"
                estad[$i]=5
            fi
        done
    fi
#ES_14700Si no hay proceso en ejecución se pone -1, para que pueda ser comparado. 
#ES_14710Resumen - Proceso en ejecución en cada instante de tiempo. 
	else
		ResuTiempoProceso[$reloj]=-1
	fi 

#ES_14720Si se trabaja NFU/NRU con clases.
#ES_14730Se traspasan todos los datos al siguiente instante para ser modificados, si se producen modificaciones al analizar los fallos y usos de las páginas.   
#ES_14740 
#ES_14750 
					restaFrecUsoRec[$numProc,$numMarco,$reloj]=${restaFrecUsoRec[$numProc,$numMarco,$(($reloj - 1))]} 
				done
			done
		fi
#ES_14760Después de inicializar estos valores, se ejecutan las funciones que actualizarán los valores.

#ES_14770Está separado del anterior if porque la CPU podría estar ocupada por un proceso.
#ES_14780Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#ES_14790Se lanza la gestión sin algoritmo de paginación, dado que en memoria no virtual los procesos entran en memoria de forma completa y no por páginas como en memoria virtual.
#ES_14800Se lanza la gestión del algoritmo de paginación para ver qué página del proceso $ejecutandoinst entra en qué marco en cada instante.
#ES_14810Se lanza la gestión del algoritmo de paginación FIFO - FIFO con Segunda Oportunidad - Reloj - Reloj con Segunda Oportunidad.
        elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#ES_14820Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
#ES_14830Se lanza la gestión del algoritmo de paginación More Frequently Used (MFU) - Lest Frequently Used (LFU) - No Frequently Used (NFU) sobre MFU, sobre LFU y con clases (sobre MFU y sobre LFU).
        elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#ES_14840Se lanza la gestión del algoritmo de paginación More Recently Used (MRU) - Lest Recently Used (LRU) - No Recently Used (NRU) sobre LRU y con clases (sobre MRU y sobre LRU).
        fi
    fi
    
#ES_14850Se pone el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"
#ES_14860SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
#ES_14870En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
        evento=1
    fi
    if [[ $reloj -eq 0 || $optejecucion = "4" ]]; then 
        evento=1
    fi
#ES_14880Si no se quiere hacer ninguna representación intermedia en pantalla pero sí se quiere ver el resultado final y recogerlo en los ficheros de informes.
        evento=0
    fi
#ES_14890Fin de gestionProcesosRoundRobin()

#
#ES_14900 Sinopsis: Algoritmo PagNoVirtual
#
function gestionAlgoritmoPagNoVirtual { 
#ES_14910Si no hay proceso en ejecución se pone -1, para que pueda ser comparado. 
#ES_14920Resumen - Proceso en ejecución en cada instante de tiempo. 
	else
		ResuTiempoProceso[$reloj]=-1
	fi
#ES_14930Se inicializan los arrays que se van a usar temporalmente para cada proceso en ejecución.
#ES_14940Contiene el ordinal del número de marco de cada proceso.
#ES_14950Se van a determinar los marcos reales que usa cada proceso.
		ordinal[$counter]=0
	done
#ES_14960El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
#ES_14970 Se buscan los marcos ocupados por cada proceso
			relacionMarcosUsados[${unidMemOcupadas[$ii]},$reloj,${ordinal[${unidMemOcupadas[$ii]}]}]=$ii
			ordinal[${unidMemOcupadas[$ii]}]=$((${ordinal[${unidMemOcupadas[$ii]}]} + 1))
        fi
	done
#ES_14980Se crea la secuencia de páginas en memoria de cada proceso.
		paginasEnMemoriaProceso[$v]=${paginasEnMemoriaTotal[$ejecutandoinst,$v]}
	done 
#ES_14990Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#ES_15000Se crea la secuencia de páginas de cada proceso pendientes de ejecutar.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasPendientesUsarTotal[$ejecutandoinst,$v]=$pagina
	done
#ES_15010Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#ES_15020Se crea la secuencia de páginas de cada proceso ya ejecutadas.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasUsadasTotal[$ejecutandoinst,$v]=$pagina
#ES_15030No es necesario ya que paginasUsadasTotal[] se genera en cada ejecución de la función.
	done 
#ES_15040Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#ES_15050Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#ES_15060Como no cambian las páginas de memoria en el modelo paginado y no virtual, se inicializan a 0 para que se imprima este valor desde el principio-
			done
		fi
	done
#ES_15070En No Virtual se usan todos los marcos asociados al proceso desde el primer momento porque se cargan en memoria todas las páginas del proceso.
#ES_15080Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#ES_15090Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#ES_15100Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#ES_15110Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#ES_15120Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
			done
		fi
	done
		
#ES_15130Se inicializan las variables si no ha sido considerado el proceso con anterioridad.
#ES_15140Se meten las páginas del proceso en ejecución en los marcos de memoria.
			paginasEnMemoriaProceso[$counterMarco]=${counterMarco}
			paginasEnMemoriaTotal[$ejecutandoinst,$counterMarco]=$counterMarco
#ES_15150Índices: (proceso, marco, tiempo reloj). Dato de la página contenida en el marco
		done
#ES_15160El número de fallos de página del proceso es el número de marcos asociados a cada proceso.
#ES_15170El número de fallos de página totales es la suma de los números de marcos asociados a cada proceso.
	fi 

#ES_15180Si aún quedan páginas por ejecutar de ese proceso
#ES_15190Se determina la primera página de la secuencia de páginas pendientes
#ES_15200Número de páginas usadas en el proceso en ejecución. Aumenta en todas las unidades de ejecución del proceso. 
#ES_15210Siguiente página, pendiente de ejecutar.
#ES_15220Localiza en qué posición encuentra la página (da la posición pero no la variable en el array)
#ES_15230Localiza la página, no la posición de la página
#ES_15240Si la página está en memoria define x=1
#ES_15250Si la página está en memoria define x=1
#ES_15260Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#ES_15270Localiza en qué posición encuentra la página (da la posición pero no la variable en el array)
#ES_15280Localiza la página, no la posición de la página
					if [[ ${paginasEnMemoriaProceso[$indMarcoMem]} -eq $primera_pagina ]]; then
#ES_15290Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
#ES_15300Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#ES_15310Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_15320Se mantiene el mismo mientras no se produzca un fallo de página. 
#ES_15330Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
					fi
				done
			fi 
		done
#ES_15340Y si no quedan más páginas pendientes de ejecutar. No es tiempoEjecucion sino temp_rej.
		for (( counter=0; counter<$nprocesos; counter++ )); do
#ES_15350Para ser equivalente al nuevo programa. Se aconseja quitar la variable $ord y estandarizar las variables a usar ??????????.
			if [[ " ${llegados[*]} " == *" $ejecutandoinst "* ]]; then 
#ES_15360Como temp_ret()
#ES_15370Como temp_ret()
				if [[ ! " ${ejecutando[*]} " == *" $ejecutandoinst "* ]]; then
#ES_15380Como temp_wait()
					if [[ " ${haestadopausado[*]} " == *" $ejecutandoinst "* ]]; then
#ES_15390Esa resta debería ser alrevés, el de ejecución menos lo ya ejecutado...
#ES_15400Tampoco es (reloj - llegada[$ejecutandoinst])
					fi
#ES_15410Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
				fi
			fi
		done
#ES_15420Actualización de variables y cambios de estado. Algunos ya se hacen en ajusteFinalTiemposEsperaEjecucionRestante().
		ejecutando="" 
		finalizados+=("$finalizado")
		finalizadonuevo+=("$finalizado")
		hanestadomem=$paginasEnMemoriaProceso
#ES_15430De momento se cambia ordenados por llegada.
#ES_15440Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#ES_15450Define el dato, pero no en qué posición se encuentra.
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
#ES_15460Fin de gestionAlgoritmoPagNoVirtual()

#
#ES_15470 Sinopsis: Algoritmo AlgPagFrecFIFORelojSegOp
#
function gestionAlgoritmoPagAlgPagFrecFIFORelojSegOp { 
#ES_15480Si no hay proceso en ejecución se pone -1, para que pueda ser comparado. 
#ES_15490Resumen - Proceso en ejecución en cada instante de tiempo. 
	else
		ResuTiempoProceso[$reloj]=-1
	fi
#ES_15500Se inicializan los arrays que se van a usar temporalmente para cada proceso en ejecución.
#ES_15510Contiene el ordinal del número de marco de cada proceso.
#ES_15520Se van a determinar los marcos reales que usa cada proceso.
		ordinal[$counter]=0
	done
#ES_15530El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
#ES_15540 Se buscan los marcos ocupados por cada proceso
			relacionMarcosUsados[${unidMemOcupadas[$ii]},$reloj,${ordinal[${unidMemOcupadas[$ii]}]}]=$ii
			ordinal[${unidMemOcupadas[$ii]}]=$((${ordinal[${unidMemOcupadas[$ii]}]} + 1))
        fi
	done
#ES_15550Se crea la secuencia de páginas en memoria de cada proceso.
		paginasEnMemoriaProceso[$v]=${paginasEnMemoriaTotal[$ejecutandoinst,$v]}
	done 
#ES_15560Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#ES_15570Se crea la secuencia de páginas de cada proceso pendientes de ejecutar.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasPendientesUsarTotal[$ejecutandoinst,$v]=$pagina
	done
#ES_15580Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#ES_15590Se crea la secuencia de páginas de cada proceso ya ejecutadas.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasUsadasTotal[$ejecutandoinst,$v]=$pagina
#ES_15600No es necesario ya que paginasUsadasTotal[] se genera en cada ejecución de la función.
	done 
#ES_15610Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#ES_15620Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#ES_15630Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#ES_15640Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#ES_15650Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
			done
		fi
	done

#ES_15660Con Segunda Oportunidad. Se determina el primer marco con coeficiente M=0. Y si encuentra marcos con M=1, les define M=0 y busca el siguiente. El coeficiente de la página intercambiada también se define a 0 por lo que se deja tal y como estaba, a 0.
#ES_15670Se arrastran los datos de los coeficientes en anteriores tiempos ordinales de ejecución para cada proceso en cada unidad de tiempo.
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
		
#ES_15680Si aún quedan páginas por ejecutar de ese proceso
#ES_15690Se determina la primera página de la secuencia de páginas pendientes
#ES_15700Número de páginas usadas en el proceso en ejecución. Aumenta en todas las unidades de ejecución del proceso. 
#ES_15710Siguiente página, pendiente de ejecutar.

#ES_15720Si el número de marcos usados es menor que el tamaño de la memoria asociada al proceso.

#ES_15730Define si encuentra o no la página en paginasEnMemoriaProceso
#ES_15740Localiza en qué posición encuentra la página en paginasEnMemoriaProceso (da la posición, pero no la variable en el array)
#ES_15750Busca la página en paginasEnMemoriaProceso, pero no la posición.
#ES_15760Esta línea es para cuando usamos el valor del dato y no su posición. Si la página está en memoria define x=1
#ES_15770Esta línea es para cuando usamos la posición del dato y no su valor. Si la página está en memoria define x=1
					x=1
#ES_15780 Se guarda el marco en el que se encuentra la página.
				fi 
			done
#ES_15790USO DE PÁGINA - Si la página está en memoria, y si no es la primera página a usar para evitar la inicialización de la variable paginasEnMemoriaTotal[$ejecutandoinst,ordinal}] a 0.
#ES_15800Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#ES_15810Define el dato, pero no en qué posición se encuentra.
#ES_15820Localiza en qué posición encuentra la página (j). 
#ES_15830Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#ES_15840Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
						for (( jj=0; jj<${memoria[$ejecutandoinst]}; jj++ )); do
#ES_15850Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#ES_15860Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
						done 
#ES_15870Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.  
#ES_15880Con Segunda Oportunidad
#ES_15890En caso de reusar una página se pone a 1 aunque pueda ser redundante si ya era 1.
						fi
					fi
				done
#ES_15900Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se ejecuta este proceso. También se usa para las frecuencias.
#ES_15910Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#ES_15920Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0. 
				else
#ES_15930Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0. 
				fi
#ES_15940Si NO está en memoria... FALLO DE PÁGINA
#ES_15950... la página se añade a la secuencia de páginas del proceso en ejecución en memoria.
#ES_15960... y la página se añade a la secuencia de páginas de ese proceso junto con el resto de páginas del resto de procesos residentes en memoria (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#ES_15970Contador de fallos de página totales de cada proceso
#ES_15980Contador de fallos totales de cada proceso
#ES_15990Si no es el primer instante de ejecución de este proceso.  Primero se copian y luego se modifican si es necesario.
#ES_16000Se recuperan los datos de las páginas que ocupan todos los marcos en el instante anterior en el que se ejecutó este proceso.
#ES_16010Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#ES_16020Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
					done
				fi 
#ES_16030Se añade el dato de la página que acaba de ser incluida en un marco.
#ES_16040 Se añade el dato de la frecuencia de la página que acaba de ser incluida en un marco.
#ES_16050Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
#ES_16060Y se añade la página a la secuencia de fallos. 
#ES_16070Y se añade el marco a la secuencia de fallos. 
#ES_16080Aumenta en 1 el número de marcos usados. Sólo aumenta cuando se usa un nuevo marco y no en todas las unidades de ejecución del proceso. Debe ser la última línea dentro del if paradejarlo preparado para su siguiente uso como variable.
#ES_16090Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_16100Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). Sería -1 porque numeroMarcosUsados empieza a contar en 1.
#ES_16110Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#ES_16120Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados ya ha aumentado 1. 
				else
					ResuPunteroMarcoSiguienteFalloPagAcumulado[$ejecutandoinst,$reloj]=0
				fi
#ES_16130Con Segunda Oportunidad. Redundante porque ya se inicializa a 0...
					coeficienteSegOp[$ejecutandoinst,${ResuPunteroMarcoUsado[$ejecutandoinst,$reloj]},$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))]=0
				fi
			fi
#ES_16140Si el número de marcos usados es mayor o igual que el tamaño de la memoria asociada al proceso.
#ES_16150Define si encuentra o no la página en paginasEnMemoriaProceso
#ES_16160Localiza en qué posición encuentra la página (da la posición pero no la variable en el array)
#ES_16170Localiza la página, no la posición de la página
#ES_16180Si la página está en memoria define x=1
#ES_16190Si la página está en memoria define x=1
					x=1
				fi 
			done
#ES_16200Si la página está en memoria...USO DE PÁGINA
#ES_16210Localiza en qué posición encuentra la página (da la posición pero no la variable en el array)
#ES_16220Localiza la página, no la posición de la página
					if [[ ${paginasEnMemoriaProceso[$indMarcoMem]} -eq $primera_pagina ]]; then
						for (( jj=0; jj<${memoria[$ejecutandoinst]}; jj++ )); do
#ES_16230Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.							
#ES_16240Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
						done
#ES_16250Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
#ES_16260Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#ES_16270Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_16280Con Segunda Oportunidad
#ES_16290En caso de reusar una página se pone a 1 aunque pueda ser redundante si ya era 1.
						fi
#ES_16300Se mantiene el mismo mientras no se produzca un fallo de página. 
#ES_16310Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
					fi
				done
#ES_16320Y si NO está en la memoria...FALLO DE PÁGINA. se localiza el que tenga el primer valor del mayor contador de frecuencia por ser AlgPagFrecMFU.
#ES_16330Con Segunda Oportunidad. Se determina el primer marco con coeficiente M=0. Y si encuentra marcos con M=1, les define M=0 y busca el siguiente. El coeficiente de la página intercambiada también se define a 0 por lo que se deja tal y como estaba, a 0.
					varCoeficienteSegOp=0
					varCoefMarco=""
#ES_16340Se usa el mismo tiempo ordinal de ejecución del proceso para todos los marcos porque es el siguiente tiempo ordinal el que interesa. La variable ResuPaginaOrdinalAcumulado[] se cambiará después, pero ya se tiene en cuenta ahora.
					until [[ $varCoeficienteSegOp -eq 1 ]]; do 
						varCoefMarco=${ResuPunteroMarcoSiguienteFalloPagAcumulado[$ejecutandoinst,$reloj]}
#ES_16350Si M de Segunda Oportunidad vale 0, se pone a 1. Y si ya vale 1, se deja como está. 
#ES_16360Se define a 0 para que en la segunda vuelta se pueda producir el fallo sobre el primer M=0 que encuentre.
#ES_16370Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#ES_16380Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0. 
							else
								ResuPunteroMarcoSiguienteFalloPagAcumulado[$ejecutandoinst,$reloj]=0
							fi
						else 
#ES_16390Se define a 0 para que en la segunda vuelta se pueda producir el fallo sobre el primer M=0 que encuentre.
							varCoeficienteSegOp=1
						fi
					done
				fi
#ES_16400Se hace el fallo de página sobre el primer marco con la mayor frecuencia, sustituyendo la página.
#ES_16410Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#ES_16420Aumenta en una unidad el número de fallos de página del proceso.
#ES_16430Contador de fallos totales de cada proceso
				for (( jj=0; jj<${memoria[$ejecutandoinst]}; jj++ )); do
#ES_16440Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.								
#ES_16450Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
				done
#ES_16460 Se añade el dato de la página que acaba de ser incluida en un marco.
#ES_16470Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_16480Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página. 
#ES_16490Y se añade la página a la secuencia de fallos. 
#ES_16500Y se añade el marco a la secuencia de fallos. 
#ES_16510Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#ES_16520Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#ES_16530Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0. 
				else
					ResuPunteroMarcoSiguienteFalloPagAcumulado[$ejecutandoinst,$reloj]=0
				fi
#ES_16540Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
			fi
		fi          
#ES_16550Y si no quedan más páginas pendientes de ejecutar. No es tiempoEjecucion sino temp_rej.
		for (( counter=0; counter<$nprocesos; counter++ )); do
#ES_16560Para ser equivalente al nuevo programa. Se aconseja quitar la variable $ord y estandarizar las variables a usar ??????????.
			if [[ " ${llegados[*]} " == *" $ejecutandoinst "* ]]; then 
#ES_16570Como temp_ret()
#ES_16580Como temp_ret()
				if [[ ! " ${ejecutando[*]} " == *" $ejecutandoinst "* ]]; then
#ES_16590Como temp_wait()
					if [[ " ${haestadopausado[*]} " == *" $ejecutandoinst "* ]]; then
#ES_16600Esa resta debería ser alrevés, el de ejecución menos lo ya ejecutado...
#ES_16610Tampoco es (reloj - llegada[$ejecutandoinst])
					fi
#ES_16620Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
				fi
			fi
		done
#ES_16630Actualización de variables y cambios de estado. Algunos ya se hacen en ajusteFinalTiemposEsperaEjecucionRestante().
		ejecutando="" 
		finalizados+=("$finalizado")
		finalizadonuevo+=("$finalizado")
		hanestadomem=$paginasEnMemoriaProceso
#ES_16640De momento se cambia ordenados por llegada.
#ES_16650Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#ES_16660Define el dato, pero no en qué posición se encuentra.
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
#ES_16670Fin de gestionAlgoritmoPagAlgPagFrecFIFORelojSegOp()

#
#ES_16680 Sinopsis: Algoritmo AlgPagFrecMFULFUNFU - NFU usará un límite máximo de la frecuencia de uso de las páginas (seleccionAlgoritmoPaginacion_clases_frecuencia_valor) y el límite de tiempo de permanencia en las clases 2 y 3 (seleccionAlgoritmoPaginacion_clases_valor) en un intervalo de tiempo (seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado)
#
#ES_16690ResuFrecuenciaAcumulado
#ES_16700Se inicializan los arrays que se van a usar temporalmente para cada proceso en ejecución.
#ES_16710Contiene el ordinal del número de marco de cada proceso.
#ES_16720Se van a determinar los marcos reales que usa cada proceso.
		ordinal[$counter]=0
	done
#ES_16730El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
#ES_16740 Se buscan los marcos ocupados por cada proceso
			relacionMarcosUsados[${unidMemOcupadas[$ii]},$reloj,${ordinal[${unidMemOcupadas[$ii]}]}]=$ii
			ordinal[${unidMemOcupadas[$ii]}]=$((${ordinal[${unidMemOcupadas[$ii]}]} + 1))
        fi
	done
#ES_16750Se crea la secuencia de páginas en memoria de cada proceso.
		paginasEnMemoriaProceso[$v]=${paginasEnMemoriaTotal[$ejecutandoinst,$v]}
	done 
#ES_16760Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#ES_16770Se crea la secuencia de páginas de cada proceso pendientes de ejecutar.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasPendientesUsarTotal[$ejecutandoinst,$v]=$pagina
	done
#ES_16780Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
#ES_16790Se crea la secuencia de páginas de cada proceso ya ejecutadas.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasUsadasTotal[$ejecutandoinst,$v]=$pagina
#ES_16800No es necesario ya que paginasUsadasTotal[] se genera en cada ejecución de la función.
	done 
#ES_16810Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#ES_16820Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#ES_16830Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#ES_16840Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#ES_16850Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_16860NFU con clases sobre MFU/LFU
#ES_16870Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				fi
			done
		fi
	done
	
#ES_16880Se crea la secuencia de páginas en memoria de cada proceso.
		indPagIni=$((${numeroPaginasUsadasProceso[$ejecutandoinst]}))
		if [[ $indPagIni -eq 0 ]]; then
#ES_16890Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_16900Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_16910Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		else
#ES_16920Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_frecuencia_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		fi
	done 
#ES_16930Se crea la secuencia de páginas en memoria de cada proceso.
#ES_16940Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3, o al máximo de frecuencia de uso.
	done 

#ES_16950Si aún quedan páginas por ejecutar de ese proceso.
#ES_16960Se determina la primera página de la secuencia de páginas pendientes.
#ES_16970Número de páginas usadas en el proceso en ejecución. Aumenta en todas las unidades de ejecución del proceso. 
#ES_16980Siguiente página, pendiente de ejecutar.
#ES_16990Si el número de marcos usados es menor que el tamaño de la memoria asociada al proceso.
#ES_17000Define si encuentra o no la página en paginasEnMemoriaProceso
#ES_17010Localiza en qué posición encuentra la página en paginasEnMemoriaProceso (da la posición, pero no la variable en el array).
#ES_17020Esta línea es para cuando usamos la posición del dato y no su valor. Si la página está en memoria define x=1.
					x=1
				fi 
			done
#ES_17030USO DE PÁGINA - Si la página está en memoria, y si no es la primera página a usar para evitar la inicialización de la variable paginasEnMemoriaTotal[$ejecutandoinst,ordinal}] a 0.
#ES_17040Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array).
#ES_17050Localiza en qué posición encuentra la página (j). 
#ES_17060Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#ES_17070Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_17080NFU-MFU/NFU-LFU
							if [[ ${ResuFrecuenciaAcumulado[$ejecutandoinst,$indMarcoMem,${indiceResuPaginaAcumulado[$ejecutandoinst]}]} -lt $seleccionAlgoritmoPaginacion_frecuencia_valor ]]; then 
#ES_17090Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.  
							else
#ES_17100Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
							fi
#ES_17110MFU/LFU
#ES_17120Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.  
#ES_17130NFU-MFU/NFU-LFU con clases
#ES_17140Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.  
							directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarcoMem]=1
#ES_17150Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_17160Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#ES_17170Si las páginas tienen una frecuencia de uso mayor que la frecuencia máxima $seleccionAlgoritmoPaginacion_clases_frecuencia_valor
#ES_17180 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor. Si lo supera se comprueba que no sea en la misma clase 2 o 3.
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoMem]=$seleccionAlgoritmoPaginacion_clases_frecuencia_valor
							fi
						fi
#ES_17190Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se ejecuta este proceso. También se usa para las frecuencias.
#ES_17200Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#ES_17210Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0. 
						fi
#ES_17220NFU con clases sobre MFU/LFU
#ES_17230Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
						fi
					fi
				done
#ES_17240Si NO está en memoria... FALLO DE PÁGINA
#ES_17250Aumenta en 1 el número de marcos usados. Sólo aumenta cuando se usa un nuevo marco y no en todas las unidades de ejecución del proceso. Debe ser la última línea dentro del if paradejarlo preparado para su siguiente uso como variable.
#ES_17260Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). Sería -1 porque numeroMarcosUsados empieza a contar en 1.
#ES_17270... la página se añade a la secuencia de páginas del proceso en ejecución en memoria.
#ES_17280... y la página se añade a la secuencia de páginas de ese proceso junto con el resto de páginas del resto de procesos residentes en memoria (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#ES_17290Contador de fallos de página totales de cada proceso.
#ES_17300Contador de fallos totales de cada proceso
#ES_17310Se añade el dato de la página que acaba de ser incluida en un marco.
#ES_17320Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_17330 Se añade el dato de la frecuencia de la página que acaba de ser incluida en un marco.
#ES_17340Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_17350Y se añade la página a la secuencia de fallos. 
#ES_17360Y se añade el marco a la secuencia de fallos. 
#ES_17370Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
				directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))]=0
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 ]]; then
#ES_17380Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#ES_17390Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#ES_17400Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
				fi
#ES_17410Sólo es necesario si se llenan todos los marcos asociados al proceso. 
#ES_17420MFU
#ES_17430Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#ES_17440Localiza en qué posición encuentra la página. 
#ES_17450Mayor frecuencia encontrada.
#ES_17460Posición del marco con la mayor frecuencia.
							fi
#ES_17470Y sobre esa localización se hace el fallo de página
#ES_17480NFU con clases sobre MFU
#ES_17490Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#ES_17500Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
#ES_17510QUEDA PENDIENTE USARLO PARA RESTAR LA FRECUENCIA ACTUAL DE LA QUE TENÍA EN AQUEL MOMENTO.
						else
							limite_j=0
						fi
#ES_17520Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#ES_17530LFU
#ES_17540Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#ES_17550Localiza en qué posición encuentra la página. 
#ES_17560Menor frecuencia encontrada.
#ES_17570Posición del marco con la menor frecuencia.
							fi
#ES_17580Y sobre esa localización se hace el fallo de página
					
#ES_17590NFU con clases sobre MFU
#ES_17600Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#ES_17610Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#ES_17620Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					fi
				fi
#ES_17630Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#ES_17640Suma 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres. 
				else
#ES_17650MFU
#ES_17660El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#ES_17670LFU
#ES_17680El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
					fi
				fi
			fi
#ES_17690Si el número de marcos usados es mayor o igual que el tamaño de la memoria asociada al proceso.
#ES_17700Define si encuentra o no la página en paginasEnMemoriaProceso.
#ES_17710Localiza en qué posición encuentra la página (da la posición pero no la variable en el array).
#ES_17720Si la página está en memoria define x=1.
					x=1
				fi 
			done
#ES_17730Si la página está en memoria...USO DE PÁGINA
#ES_17740Localiza en qué posición encuentra la página (da la posición pero no la variable en el array).
					if [[ ${paginasEnMemoriaProceso[$indMarcoMem]} -eq $primera_pagina ]]; then
#ES_17750Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#ES_17760Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_17770NFU-MFU/NFU-LFU
							if [[ ${ResuFrecuenciaAcumulado[$ejecutandoinst,$indMarcoMem,${indiceResuPaginaAcumulado[$ejecutandoinst]}]} -lt $seleccionAlgoritmoPaginacion_frecuencia_valor ]]; then 
#ES_17780Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
							else
#ES_17790Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
							fi
#ES_17800MFU/LFU
#ES_17810Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.
#ES_17820NFU-MFU/NFU-LFU con clases
#ES_17830Se lee el dato la frecuencia de la página que estaba en un marco en el instante anterior en el que se ha ejecutado este proceso y se suma 1.  
							directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarcoMem]=1
#ES_17840Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_17850Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#ES_17860Si las páginas tienen una frecuencia de uso mayor que la frecuencia máxima $seleccionAlgoritmoPaginacion_clases_frecuencia_valor
#ES_17870 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor. Si lo supera se comprueba que no sea en la misma clase 2 o 3.
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoMem]=$seleccionAlgoritmoPaginacion_clases_frecuencia_valor
							fi
#ES_17880Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
						fi
#ES_17890MFU
#ES_17900Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#ES_17910Localiza en qué posición encuentra la página.
#ES_17920Mayor frecuencia encontrada.
#ES_17930Posición del marco con la mayor frecuencia.
								fi
#ES_17940Y sobre esa localización se hace el fallo de página
#ES_17950El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
				
#ES_17960NFU con clases sobre MFU
#ES_17970Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
							paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#ES_17980Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
								limite_j=$ultimasPaginasAConsiderar
							else
								limite_j=0
							fi
#ES_17990Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#ES_18000El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#ES_18010LFU
#ES_18020Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
							min_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#ES_18030Localiza en qué posición encuentra la página.
#ES_18040Menor frecuencia encontrada.
#ES_18050Posición del marco con la menor frecuencia.
								fi
#ES_18060Y sobre esa localización se hace el fallo de página
#ES_18070El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
				
#ES_18080NFU con clases sobre MFU
#ES_18090Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
							min_AlgPagFrecRec_Position[$ejecutandoinst]=0
							ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
							paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#ES_18100Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
								limite_j=$ultimasPaginasAConsiderar
							else
								limite_j=0
							fi
#ES_18110Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#ES_18120El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
						fi
#ES_18130Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
					fi
				done
#ES_18140Y si NO está en la memoria...FALLO DE PÁGINA. Se localiza el que tenga el primer valor del mayor contador de frecuencia por ser AlgPagFrecMFU.
#ES_18150MFU
#ES_18160Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#ES_18170Se hace el fallo de página sobre el primer marco con la mayor frecuencia, sustituyendo la página.
#ES_18180Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.

#ES_18190NFU con clases sobre MFU
#ES_18200Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#ES_18210Se hace el fallo de página sobre el primer marco con la mayor frecuencia, sustituyendo la página.
#ES_18220Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,${max_AlgPagFrecRec_Position[$ejecutandoinst]}]=0
#ES_18230LFU
#ES_18240Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#ES_18250Se hace el fallo de página sobre el primer marco con la menor frecuencia, sustituyendo la página.
#ES_18260Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
				
#ES_18270NFU con clases sobre MFU
#ES_18280Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#ES_18290Se hace el fallo de página sobre el primer marco con la menor frecuencia, sustituyendo la página.
#ES_18300Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,${min_AlgPagFrecRec_Position[$ejecutandoinst]}]=0
				fi
#ES_18310Aumenta en una unidad el número de fallos de página del proceso.
#ES_18320Contador de fallos totales de cada proceso
#ES_18330MFU
#ES_18340 Se añade el dato de la página que acaba de ser incluida en un marco.
#ES_18350Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_18360Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página. 
#ES_18370Y se añade la página a la secuencia de fallos. 
#ES_18380Y se añade el marco a la secuencia de fallos. 
#ES_18390NFU-MFU con clases					
#ES_18400Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_18410Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#ES_18420Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#ES_18430Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
#ES_18440Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#ES_18450Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#ES_18460Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					else
#ES_18470Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#ES_18480Localiza en qué posición encuentra la página.
#ES_18490Mayor frecuencia encontrada.
#ES_18500Posición del marco con la mayor frecuencia.
							fi
#ES_18510Y sobre esa localización se hace el fallo de página.
					fi
#ES_18520El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#ES_18530LFU
#ES_18540 Se añade el dato de la página que acaba de ser incluida en un marco.
#ES_18550Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_18560Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página. 
#ES_18570Y se añade la página a la secuencia de fallos. 
#ES_18580Y se añade el marco a la secuencia de fallos. 
#ES_18590NFU-LFU con clases
#ES_18600Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_18610Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#ES_18620Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#ES_18630Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
#ES_18640Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#ES_18650Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#ES_18660Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					else
#ES_18670Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#ES_18680Localiza en qué posición encuentra la página.
#ES_18690Mayor frecuencia encontrada.
#ES_18700Posición del marco con la menor frecuencia.
							fi
#ES_18710Y sobre esa localización se hace el fallo de página.
					fi
#ES_18720El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
				fi
#ES_18730Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
			fi
		fi          
	
#ES_18740Y si no quedan más páginas pendientes de ejecutar. No es tiempoEjecucion sino temp_rej.
		for (( counter=0; counter<$nprocesos; counter++ )); do
#ES_18750Para ser equivalente al nuevo programa. ?????? QUITAR ord ??????????
			if [[ " ${llegados[*]} " == *" $ejecutandoinst "* ]]; then 
#ES_18760Como temp_ret(). Se aconseja quitar la variable $retorno y estandarizar las variables a usar ??????????.
#ES_18770Como temp_ret(). Se aconseja quitar la variable $retorno y estandarizar las variables a usar ??????????.
				if [[ ! " ${ejecutando[*]} " == *" $ejecutandoinst "* ]]; then
#ES_18780Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
					if [[ " ${haestadopausado[*]} " == *" $ejecutandoinst "* ]]; then
#ES_18790Esa resta debería ser alrevés, el de ejecución menos lo ya ejecutado...
#ES_18800Tampoco es (reloj - llegada[$ejecutandoinst]).
					fi
#ES_18810Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
				fi
			fi
		done
#ES_18820Actualización de variables y cambios de estado. Algunos ya se hacen en ajusteFinalTiemposEsperaEjecucionRestante().
		ejecutando="" 
		finalizados+=("$finalizado")
		finalizadonuevo+=("$finalizado")
		hanestadomem=$paginasEnMemoriaProceso
#ES_18830De momento se cambia ordenados por llegada.
#ES_18840Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array).
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
#ES_18850Fin de gestionAlgoritmoPagAlgPagFrecMFULFUNFU()

#
#ES_18860 Sinopsis: Algoritmo AlgPagFrecMRULRUNRU - NRU usará un límite máximo del tiempo que hace que se usaron las páginas por última vez (seleccionAlgoritmoPaginacion_uso_rec_valor)
#
#ES_18870ResuUsoRecienteAcumulado 
#ES_18880Se inicializan los arrays que se van a usar temporalmente para cada proceso en ejecución.
#ES_18890Contiene el ordinal del número de marco de cada proceso.
#ES_18900Se van a determinar los marcos reales que usa cada proceso.
		ordinal[$counter]=0
	done
echo "444444444444 - 1"
#ES_18910El array relacionMarcosUsados[] no necesita acumulado porque ya contiene todos los datos necesarios y se mantienen hasta que se modifican en las reubicaciones, caso en el que también recoge el cambio.
#ES_18920 Se buscan los marcos ocupados por cada proceso
			relacionMarcosUsados[${unidMemOcupadas[$ii]},$reloj,${ordinal[${unidMemOcupadas[$ii]}]}]=$ii
			ordinal[${unidMemOcupadas[$ii]}]=$((${ordinal[${unidMemOcupadas[$ii]}]} + 1))
        fi
	done
echo "444444444444 - 2"
#ES_18930Se crea la secuencia de páginas en memoria de cada proceso.
		paginasEnMemoriaProceso[$v]=${paginasEnMemoriaTotal[$ejecutandoinst,$v]}
	done 
#ES_18940Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
echo "444444444444 - 3"
#ES_18950Se crea la secuencia de páginas de cada proceso pendientes de ejecutar.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasPendientesUsarTotal[$ejecutandoinst,$v]=$pagina
	done
#ES_18960Se borra la variable para volver a crearla con las páginas aún pendientes de ejecutar.
echo "444444444444 - 4"
#ES_18970Se crea la secuencia de páginas de cada proceso ya ejecutadas.
		pagina=${paginasDefinidasTotal[$ejecutandoinst,$v]}
		paginasUsadasTotal[$ejecutandoinst,$v]=$pagina
#ES_18980No es necesario ya que paginasUsadasTotal[] se genera en cada ejecución de la función.
	done 
echo "444444444444 - 5"
#ES_18990Se actualizan los datos de frecuencia o antigüedad de uso de cada marco de memoria ocupado por una página de un proceso.
#ES_19000Si no es el primer instante de ejecución de este proceso. Primero se copian y luego se modifican si es necesario.
			for (( jj=0; jj<${memoria[$counter]}; jj++ )); do
#ES_19010Recoge los datos del array con las páginbas en ls diferentes marcos en el instante anterior.
#ES_19020Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#ES_19030Recoge los datos del array de frecuencias de uso de las páginas contenidas en los marcos en el instante anterior.
#ES_19040Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_19050Óptimo
#ES_19060Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#ES_19070Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				fi
#ES_19080NFU con clases sobre MFU/LFU
#ES_19090Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				fi
			done
		fi
	done
	
echo "444444444444 - 6"
#ES_19100Se crea la secuencia de páginas en memoria de cada proceso.
		indPagIni=$((${numeroPaginasUsadasProceso[$ejecutandoinst]}))
		if [[ $indPagIni -eq 0 ]]; then
#ES_19110Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_19120Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_19130Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_uso_rec_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		else
#ES_19140Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_uso_rec_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		fi
	done 
echo "444444444444 - 7"
#ES_19150Se actualizan los valores del tiempo que falta para ejecutarse una página de cada proceso, salvo si es 0, ya que en ese caso, no se volverá a encontrar en la sucesión de páginas pendientes del proceso.
		if [[ ${primerTiempoEntradaPagina[$ejecutandoinst,$indMarco]} -gt 0 ]]; then
#ES_19160Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3, o al máximo de frecuencia de uso.
		fi
	done 

echo "3333333333333 - 8"
#ES_19170Si aún quedan páginas por ejecutar de ese proceso.
#ES_19180Se determina la primera página de la secuencia de páginas pendientes.
#ES_19190Número de páginas usadas en el proceso en ejecución. Aumenta en todas las unidades de ejecución del proceso. 
#ES_19200Siguiente página, pendiente de ejecutar.
#ES_19210Si el número de marcos usados es menor que el tamaño de la memoria asociada al proceso.
#ES_19220Define si encuentra o no la página en paginasEnMemoriaProceso
#ES_19230Localiza en qué posición encuentra la página en paginasEnMemoriaProceso (da la posición, pero no la variable en el array).
#ES_19240Esta línea es para cuando usamos la posición del dato y no su valor. Si la página está en memoria define x=1.
					x=1
#ES_19250 Se guarda el marco en el que se encuentra la página.
				fi 
			done
#ES_19260USO DE PÁGINA - Si la página está en memoria, y si no es la primera página a usar para evitar la inicialización de la variable paginasEnMemoriaTotal[$ejecutandoinst,ordinal}] a 0.
echo "3333333333333 - 2"
#ES_19270Se van a tratar las variables que no se corresponden con el marco usado.
#ES_19280El tiempo desde que se usó una página en memoria aumenta en cada unidad de tiempo de ejecución del proceso, siempre que no sea la que se usa, o sobre la que se produce el fallo de paginación. 
					if [[ $indMarcoRec -ne $indMarcoMem ]]; then
#ES_19290Óptimo 
#ES_19300Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#ES_19310MFU/LFU. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#ES_19320NFU-MFU/NFU-LFU
#ES_19330Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							else
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$seleccionAlgoritmoPaginacion_uso_rec_valor
							fi
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#ES_19340NFU-MFU/NFU-LFU con clases. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
#ES_19350Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
							else
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$seleccionAlgoritmoPaginacion_clases_uso_rec_valor
							fi 
						fi
					fi
					if [[ $indMarcoRec -eq $indMarcoMem ]]; then
#ES_19360Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#ES_19370Óptimo
#ES_19380Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
#ES_19390Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_19400Resumen - Índices: (proceso, marco). Dato: Histórico con el valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
						fi
					fi
				done
#ES_19410Ahora se definirán las variables que se corresponden con el marco usado. 
#ES_19420Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_194300 por haber sido usado.
#ES_19440NFU-MFU/NFU-LFU con clases
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarcoMem]=1
					ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoMem]=0
#ES_19450Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#ES_19460Si las páginas tienen una frecuencia de uso mayor que la frecuencia máxima $seleccionAlgoritmoPaginacion_clases_uso_rec_valor
				fi
									
#ES_19470Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se ejecuta este proceso. También se usa para las frecuencias.
#ES_19480Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#ES_19490Sumaría 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres, pero no lo suma porque el número de marcos usados no empezará en 0 sino en 1, mientras que las variables suelene empezar en 0. 
				fi
#ES_19500NFU con clases sobre MFU/LFU
#ES_19510Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
				fi
			
#ES_19520Si NO está en memoria... FALLO DE PÁGINA
echo "3333333333333 - 3"
#ES_19530Aumenta en 1 el número de marcos usados. Sólo aumenta cuando se usa un nuevo marco y no en todas las unidades de ejecución del proceso. Debe ser la última línea dentro del if paradejarlo preparado para su siguiente uso como variable.
#ES_19540Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). Sería -1 porque numeroMarcosUsados empieza a contar en 1.
#ES_19550Se van a tratar las variables que no se corresponden con el marco usado.
#ES_19560El tiempo desde que se usó una página en memoria aumenta en cada unidad de tiempo de ejecución del proceso, siempre que no sea la que se usa, o sobre la que se produce el fallo de paginación. 
					if [[ $indMarcoRec -ne ResuPunteroMarcoUsado[$ejecutandoinst,$reloj] ]]; then
#ES_19570Óptimo
#ES_19580Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#ES_19590MFU/LFU. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#ES_19600NFU-MFU/NFU-LFU
#ES_19610Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							else
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$seleccionAlgoritmoPaginacion_uso_rec_valor
							fi
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#ES_19620NFU-MFU/NFU-LFU con clases. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
#ES_19630Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
							else
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$seleccionAlgoritmoPaginacion_clases_uso_rec_valor
							fi
						fi
					fi
					if [[ $indMarcoRec -eq ${ResuPunteroMarcoUsado[$ejecutandoinst,$reloj]} ]]; then
#ES_19640Óptimo
#ES_19650Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
							
#ES_19660Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_19670Resumen - Índices: (proceso, marco). Dato: Histórico con el valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
						fi
					fi
				done
#ES_19680Ahora se definirán el resto de variables que se corresponden con el marco usado. 
#ES_19690... la página se añade a la secuencia de páginas del proceso en ejecución en memoria.
#ES_19700... y la página se añade a la secuencia de páginas de ese proceso junto con el resto de páginas del resto de procesos residentes en memoria (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#ES_19710Contador de fallos de página totales de cada proceso.
#ES_19720Contador de fallos totales de cada proceso
#ES_19730Se añade el dato de la página que acaba de ser incluida en un marco.
#ES_19740Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_19750 Se añade el dato de la frecuencia de la página que acaba de ser incluida en un marco.
#ES_19760Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_19770Y se añade la página a la secuencia de fallos. 
#ES_19780Y se añade el marco a la secuencia de fallos. 
#ES_19790Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
				directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))]=0
#ES_19800Sólo es necesario si se llenan todos los marcos asociados al proceso. 
#ES_19810MFU
#ES_19820Se recalcula el siguiente uso de la página utilizada más alejado en el tiempo.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#ES_19830Localiza en qué posición encuentra la página.
#ES_19840Mayor frecuencia encontrada.
#ES_19850Posición del marco con la mayor frecuencia.
							fi
#ES_19860Y sobre esa localización se hace el fallo de página
#ES_19870MFU
#ES_19880Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#ES_19890Localiza en qué posición encuentra la página.
#ES_19900Mayor frecuencia encontrada.
#ES_19910Posición del marco con la mayor frecuencia.
							fi
#ES_19920Y sobre esa localización se hace el fallo de página
#ES_19930NFU con clases sobre MFU
#ES_19940Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#ES_19950Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
#ES_19960QUEDA PENDIENTE USARLO PARA RESTAR LA FRECUENCIA ACTUAL DE LA QUE TENÍA EN AQUEL MOMENTO.
						else
							limite_j=0
						fi
#ES_19970Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#ES_19980LFU
#ES_19990Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#ES_20000Localiza en qué posición encuentra la página.
#ES_20010Menor frecuencia encontrada.
#ES_20020Posición del marco con la menor frecuencia.
							fi
#ES_20030Y sobre esa localización se hace el fallo de página					
#ES_20040NFU con clases sobre MFU
#ES_20050Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#ES_20060Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#ES_20070Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					fi
				fi
#ES_20080Si el número de páginas en memoria del proceso es menor que el tamaño de la memoria del proceso. 
#ES_20090Suma 1 al número de marco sobre el que se hará el fallo de página porque aún hay marcos libres. 
				else
#ES_20100MFU
#ES_20110El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#ES_20120LFU
#ES_20130El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
					fi
				fi
			fi

#ES_20140Si el número de marcos usados es mayor o igual que el tamaño de la memoria asociada al proceso.
#ES_20150Define si encuentra o no la página en paginasEnMemoriaProceso.
#ES_20160Localiza en qué posición encuentra la página (da la posición pero no la variable en el array).
#ES_20170Si la página está en memoria define x=1.
					x=1
				fi 
			done
#ES_20180Si la página está en memoria...USO DE PÁGINA
echo "3333333333333 - 4"
#ES_20190Localiza en qué posición encuentra la página (da la posición pero no la variable en el array).
					if [[ ${paginasEnMemoriaProceso[$indMarcoMem]} -eq $primera_pagina ]]; then
#ES_20200Índice que apunta al marco con la página que acaba de ser usada (ya exitente anteriormente). 
#ES_20210Se van a tratar las variables que no se corresponden con el marco usado.
#ES_20220El tiempo desde que se usó una página en memoria aumenta en cada unidad de tiempo de ejecución del proceso, siempre que no sea la que se usa, o sobre la que se produce el fallo de paginación. 
							if [[ $indMarcoRec -ne ResuPunteroMarcoUsado[$ejecutandoinst,$reloj] ]]; then
#ES_20230Óptimo
#ES_20240Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.

#ES_20250Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_20260Resumen - Índices: (proceso, marco). Dato: Histórico con el valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación

#ES_20270MFU/LFU. Sin máximo de tiempo desde que se usó por última vez.
									ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
									ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#ES_20280NFU-MFU/NFU-LFU
#ES_20290Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
										ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
									else
										ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$seleccionAlgoritmoPaginacion_uso_rec_valor
									fi
									ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#ES_20300NFU-MFU/NFU-LFU con clases. Sin máximo de tiempo desde que se usó por última vez.
									ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
#ES_20310Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
										ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
									else
										ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$seleccionAlgoritmoPaginacion_clases_uso_rec_valor
									fi
								fi
							fi
							if [[ $indMarcoRec -eq ResuPunteroMarcoUsado[$ejecutandoinst,$reloj] ]]; then
#ES_20320Óptimo
#ES_20330Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.

									ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
								fi
							fi							
						done
#ES_20340Ahora se definirán las variables que se corresponden con el marco usado. 
#ES_20350Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_20360MFU/LFU
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
#ES_20370NFU-MFU/NFU-LFU
							if [[ ${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,${indiceResuPaginaAcumulado[$ejecutandoinst]}]} -lt $seleccionAlgoritmoPaginacion_uso_rec_valor ]]; then 
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
							else
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
							fi
#ES_20380NFU-MFU/NFU-LFU con clases
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoMem,$reloj]=0
							directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarcoMem]=1
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoMem]=0
#ES_20390Se usa una página que ya estaba en memoria (0) y, por tanto, no es el resultado de un fallo de página (1).
#ES_20400Si las páginas tienen una frecuencia de uso mayor que la frecuencia máxima $seleccionAlgoritmoPaginacion_clases_uso_rec_valor
#ES_20410Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
						fi
#ES_20420MFU
#ES_20430Se recalcula el siguiente uso de la página utilizada más alejado en el tiempo.
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#ES_20440Localiza en qué posición encuentra la página.
#ES_20450Mayor frecuencia encontrada.
#ES_20460Posición del marco con la mayor frecuencia.
								fi
#ES_20470Y sobre esa localización se hace el fallo de página
#ES_20480El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#ES_20490MFU
#ES_20500Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#ES_20510Localiza en qué posición encuentra la página.
#ES_20520Mayor frecuencia encontrada.
#ES_20530Posición del marco con la mayor frecuencia.
								fi
#ES_20540Y sobre esa localización se hace el fallo de página
#ES_20550El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
				
#ES_20560NFU con clases sobre MFU
#ES_20570Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
							max_AlgPagFrecRec_Position[$ejecutandoinst]=0
							ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
							paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#ES_20580Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
								limite_j=$ultimasPaginasAConsiderar
							else
								limite_j=0
							fi
#ES_20590Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#ES_20600El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#ES_20610LFU
#ES_20620Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
							min_AlgPagFrecRec_Position[$ejecutandoinst]=0
							for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#ES_20630Localiza en qué posición encuentra la página.
#ES_20640Menor frecuencia encontrada.
#ES_20650Posición del marco con la menor frecuencia.
								fi
#ES_20660Y sobre esa localización se hace el fallo de página
#ES_20670El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
#ES_20680NFU con clases sobre MFU
#ES_20690Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
							min_AlgPagFrecRec_Position[$ejecutandoinst]=0
							ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
							paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#ES_20700Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
								limite_j=$ultimasPaginasAConsiderar
							else
								limite_j=0
							fi
#ES_20710Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#ES_20720El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
						fi
#ES_20730Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
					fi
				done

#ES_20740Y si NO está en la memoria...FALLO DE PÁGINA. Se localiza el que tenga el primer valor del mayor contador de frecuencia por ser AlgPagFrecMFU.
echo "3333333333333 - 5"
#ES_20750MFU
#ES_20760Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#ES_20770Se hace el fallo de página sobre el primer marco con la mayor frecuencia, sustituyendo la página.
#ES_20780Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#ES_20790LFU
#ES_20800Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#ES_20810Se hace el fallo de página sobre el primer marco con la menor frecuencia, sustituyendo la página.
#ES_20820Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#ES_20830NFU con clases sobre MFU
#ES_20840Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#ES_20850Se hace el fallo de página sobre el primer marco con la mayor frecuencia, sustituyendo la página.
#ES_20860Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,${max_AlgPagFrecRec_Position[$ejecutandoinst]}]=0
				
#ES_20870NFU con clases sobre MFU
#ES_20880Índice que apunta al marco con la página que acaba de ser incluida (ocupa un espacio ya utilizado anteriormente por otra página). 
#ES_20890Se hace el fallo de página sobre el primer marco con la menor frecuencia, sustituyendo la página.
#ES_20900Páginas residentes en memoria de todos los Procesos (Índices:Proceso, Páginas). Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
					directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,${min_AlgPagFrecRec_Position[$ejecutandoinst]}]=0
				fi
#ES_20910Se van a tratar las variables que no se corresponden con el marco usado.
#ES_20920El tiempo desde que se usó una página en memoria aumenta en cada unidad de tiempo de ejecución del proceso, siempre que no sea la que se usa, o sobre la que se produce el fallo de paginación. 
					if [[ $indMarcoRec -ne ${ResuPunteroMarcoUsado[$ejecutandoinst,$reloj]} ]]; then
#ES_20930Óptimo
#ES_20940Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))

#ES_20950MFU/LFU. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#ES_20960NFU-MFU/NFU-LFU
#ES_20970Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
							else
								ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$seleccionAlgoritmoPaginacion_uso_rec_valor
							fi
							ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
#ES_20980NFU-MFU/NFU-LFU con clases. Sin máximo de tiempo desde que se usó por última vez.
							ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]=$((${ResuUsoRecienteAcumulado[$ejecutandoinst,$indMarcoRec,$reloj]} + 1))
#ES_20990Hay un máximo par el tiempo desde que se usó (seleccionAlgoritmoPaginacion_uso_rec_valor).
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$((${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]} + 1))
							else
								ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMarcoRec]=$seleccionAlgoritmoPaginacion_clases_uso_rec_valor
							fi
						fi
					fi
					if [[ $indMarcoRec -eq ${ResuPunteroMarcoUsado[$ejecutandoinst,$reloj]}  ]]; then
#ES_21000Óptimo
#ES_21010Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.

#ES_21020Resumen - Índices: (proceso, marco, reloj). Dato: Tiempo que hace que se usó la Página de un proceso que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_21030Resumen - Índices: (proceso, marco). Dato: Histórico con el valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_21040 Se añade el dato de la página que acaba de ser incluida en un marco.
						fi
					fi					
				done
#ES_21050Ahora se definirán las variables que se corresponden con el marco usado. 
#ES_21060Aumenta en una unidad el número de fallos de página del proceso.
#ES_21070Contador de fallos totales de cada proceso
#ES_21080MFU
#ES_21090 Se añade el dato de la página que acaba de ser incluida en un marco.
#ES_21100Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_21110Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página. 
#ES_21120Y se añade la página a la secuencia de fallos. 
#ES_21130Y se añade el marco a la secuencia de fallos. 
#ES_21140NFU-MFU con clases					
#ES_21150Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_21160Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#ES_21170Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#ES_21180Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
#ES_21190Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#ES_21200Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#ES_21210Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					else
#ES_21220Se recalcula la mayor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión.
						max_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMaxAlgPag=0; indMaxAlgPag<${memoria[$ejecutandoinst]}; indMaxAlgPag++ )); do
#ES_21230Localiza en qué posición encuentra la página.
#ES_21240Mayor frecuencia encontrada.
#ES_21250Posición del marco con la mayor frecuencia.
							fi
#ES_21260Y sobre esa localización se hace el fallo de página.
					fi
#ES_21270El marco siguiente para el fallo de página será el que tiene la máxima frecuencia.  
#ES_21280LFU
#ES_21290 Se añade el dato de la página que acaba de ser incluida en un marco.
#ES_21300Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_21310Como la página acaba de ser metida en el marco, se suma 1 a la frecuencia de la página. 
#ES_21320Y se añade la página a la secuencia de fallos. 
#ES_21330Y se añade el marco a la secuencia de fallos. 
#ES_21340NFU-LFU con clases
#ES_21350Resumen - Índices: (proceso, marco). Dato: Valor de la "frecuencia/tiempo desde su último uso" para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación
#ES_21360Se inicializa a 0 el número de unidades de tiempo que hace que se cambió la clase por llegar al máximo de tiempo en una clase 2 o 3 o al máximo de frecuencia de uso.
#ES_21370Resultado de un fallo de página (1) y no por usar una página ya existente en memoria (0).
#ES_21380Se recalculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas. Se envía: marco + ordinal_página
#ES_21390Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						ultimasPaginasAConsiderar=$(($((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1)) - $seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado))
						paginasPendientesEjecutar=$((${ejecucion[$ejecutandoinst]}-$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))))
#ES_21400Sin se han usado muchas páginas. sólo se consideran las últimas definidas mediante seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado.
							limite_j=$ultimasPaginasAConsiderar
						else
							limite_j=0
						fi
#ES_21410Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
					else
#ES_21420Se recalcula la menor frecuencia, aunque parezca no necesario hacerlo, por si es necesario para su impresión. Y se comienza con la frecuencia de la primera página en el primer marco asociado al proceso.
						min_AlgPagFrecRec_Position[$ejecutandoinst]=0
						for (( indMinAlgPag=0; indMinAlgPag<${memoria[$ejecutandoinst]}; indMinAlgPag++ )); do
#ES_21430Localiza en qué posición encuentra la página.
#ES_21440Mayor frecuencia encontrada.
#ES_21450Posición del marco con la menor frecuencia.
							fi
#ES_21460Y sobre esa localización se hace el fallo de página.
					fi
#ES_21470El marco siguiente para el fallo de página será el que tiene la mínima frecuencia.  
				fi
#ES_21480Guarda el índice de la última modificación de datos por no usar el reloj en todos sus instantes sino sólo en los que se usa este proceso. También se usa para las frecuencias.
			fi
		fi          
	
#ES_21490Y si no quedan más páginas pendientes de ejecutar. No es tiempoEjecucion sino temp_rej.
echo "3333333333333 - 6"
		for (( counter=0; counter<$nprocesos; counter++ )); do
#ES_21500Para ser equivalente al nuevo programa. Se aconseja quitar la variable $ord y estandarizar las variables a usar ??????????.
#ES_21510??????????? NO PUEDE ESTAR BIEN...Ni el timpo de retorno, porque puede llegar pero no entrar en memoria,  ni el tiempo de espera por la misma razón, ni resta[$ejecutandoinst]=$((tiempo[$ejecutandoinst].... porque tiempo[] no existe
#ES_21520Como temp_ret(). Se aconseja quitar la variable $retorno y estandarizar las variables a usar ??????????.
#ES_21530Como temp_ret(). Se aconseja quitar la variable $retorno y estandarizar las variables a usar ??????????.
				if [[ ! " ${ejecutando[*]} " == *" $ejecutandoinst "* ]]; then
#ES_21540Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
					if [[ " ${haestadopausado[*]} " == *" $ejecutandoinst "* ]]; then
#ES_21550Esa resta debería ser alrevés, el de ejecución menos lo ya ejecutado...
#ES_21560Tampoco es (reloj - llegada[$ejecutandoinst]).
					fi
#ES_21570Como temp_wait(). Se aconseja quitar la variable $espera y estandarizar las variables a usar ??????????.
				fi
			fi
		done
#ES_21580Actualización de variables y cambios de estado. Algunos ya se hacen en ajusteFinalTiemposEsperaEjecucionRestante().
#ES_21590Variable que se usa para controlar la impresión de entrada a dibujaResumenAlgPagFrecUsoRec(). Se modifica en inicializaVectoresVariables(), gestionAlgoritmoPagAlgPagFrecMFU(), gestionProcesosFCFS(), gestionProcesosSJF(), gestionProcesosSRPT() y en inicioNuevo().
		ejecutando="" 
		finalizados+=("$finalizado")
		finalizadonuevo+=("$finalizado")
		hanestadomem=$paginasEnMemoriaProceso
#ES_21600De momento se cambia ordenados por llegada.
#ES_21610Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array).
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
#ES_21620Fin de gestionAlgoritmoPagAlgPagRecMRULRUNRU()

#
#ES_21630 Sinopsis: Se calculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas.
#
function calcularResuTiempoOptimoAcumulado_PaginaEjecutada { 
	varCierreOptimo=0
	indOptimo=$((${numeroPaginasUsadasProceso[$ejecutandoinst]}))
	until [[ $varCierreOptimo -eq 1 ]]; do 
#ES_21640Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
			if [[ ${paginasDefinidasTotal[$ejecutandoinst,$indOptimo]} -eq $primera_pagina ]]; then
#ES_21650Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				varCierreOptimo=1
			fi
		else
#ES_21660Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
			varCierreOptimo=1
		fi
		indOptimo=$(($indOptimo + 1)) 
	done
}

#
#ES_21670 Sinopsis: Se calculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas.
#
function calcularResuTiempoOptimoAcumulado_PaginaNoEjecutada { 
	varCierreOptimo=0
#ES_21680	indOptimo=$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))
	indOptimo=$((${numeroPaginasUsadasProceso[$ejecutandoinst]}))
	until [[ $varCierreOptimo -eq 1 ]]; do 
#ES_21690Con $indOptimo se busca el tiempo que falta hasta una nueva ejecución de la misma página. 0 si no hay más repeticiones de esa página.
			if [[ ${paginasDefinidasTotal[$ejecutandoinst,$indOptimo]} -eq ${paginasEnMemoriaProceso[$indMarcoRec]} ]]; then
#ES_21700Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
				varCierreOptimo=1
			fi
		else
#ES_21710Recoge los datos del array de clases de uso de las páginas contenidas en los marcos en el instante anterior.
			varCierreOptimo=1
		fi
		indOptimo=$(($indOptimo + 1)) 
	done
}

#
#ES_21720 Sinopsis: Se calculan las clases NRU de las páginas de cada proceso, dependiendo de si han sido referenciadas y/o modificadas.
#
function gestionAlgoritmoPagAlgPagRecNRU_Referenciado_Modificado { 
#ES_21730Se usará para determinar si una página ha sido o no referenciada y modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_clases_valor unidades de tiempo en los algoritmos NFU y NRU. Se inicia a 0 por no haber sido aún referenciada (vista o modificada) y se cambia sólo cuando ya estuviera en memoria.
		tiempoPag=$((${numeroPaginasUsadasProceso[$ejecutandoinst]} - 1))
#ES_21740Con cambio de página por fallo de página ($usoMismaPagina=1) y, por tanto, sólo para esa página. El fallo sobre un marco sólo puede producir clases 0 o 1.
#ES_21750Se define como página usada o modificada	
#ES_21760Se reinicia la clase a NO referenciada-NO modificada para recalcular después la clase correcta.
#ES_21770Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#ES_21780NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#ES_21790NO referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
			fi
		fi

#ES_21800Con cambio de página por fallo de página ($usoMismaPagina=1), pero sin actuar sobre la página tratada, ya que se deben actualizar las clases de todas las páginas. El fallo sobre otro marco sólo puede producir un aumento en el tiempo ordinal que hace que se cambió la clase, por lo que podría pasar de clase 2 a 0, o de 3 a 1.
#ES_21810Se define como página no usada ni modificada	
			if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#ES_21820NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_21830Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#ES_21840SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_21850Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#ES_21860SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_21870Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#ES_21880Si lleva mucho tiempo como clase 3, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#ES_21890SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_21900Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			fi
		fi

#ES_21910Con uso de página, pero sin cambio por fallo de página ($usoMismaPagina=0), ya que se deben actualizar las clases de todas las páginas.
#ES_21920Se define como página usada o modificada	
			if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#ES_21930Referencia a una página ya ejecutada en una unidad de reloj anterior, dato copiado en todas las páginas de una unidad de tiempo a la siguiente, antes de analizar lo que ocurrirá en el tiempo actual. 
#ES_21940NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_21950Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#ES_21960Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#ES_21970SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_21980Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				fi
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
				if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$1,$(($tiempoPag - 1))]} -eq 0 ]]; then 
#ES_21990NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22000Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#ES_22010Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#ES_22020NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22030Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				fi
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#ES_22040Referencia a una página ya ejecutada en una unidad de reloj anterior, dato copiado en todas las páginas de una unidad de tiempo a la siguiente, antes de analizar lo que ocurrirá en el tiempo actual. 
#ES_22050NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22060Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$1,$(($tiempoPag - 1))]} -eq 1 ]]; then 
#ES_22070NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22080Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#ES_22090Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#ES_22100SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22110Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#ES_22120Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#ES_22130NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22140Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				fi
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$1]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
				if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$1,$(($tiempoPag - 1))]} -eq 0 ]]; then 
#ES_22150SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22160Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$1,$(($tiempoPag - 1))]} -eq 1 ]]; then 
#ES_22170SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22180Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#ES_22190Si ya era de clase 2 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#ES_22200SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22210Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
#ES_22220Si ya era de clase 3 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor
#ES_22230Si lleva mucho tiempo como clase 3, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#ES_22240SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22250Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
				fi
			fi 
		fi
		
#ES_22260Con uso, pero sin cambio de página ($usoMismaPagina=1), ya que se deben actualizar las clases de todas las páginas.
#ES_22270Se define como página no usada ni modificada	
			if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#ES_22280NO referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22290Resumen - Índices: (proceso, marco, ordinal del tiempo de ejecución (página)). Dato: Histórico con el tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 0 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#ES_22300SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22310Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 0 ]]; then
#ES_22320SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22330Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_referenciada[$ejecutandoinst,$indMarco]} -eq 1 && ${directions_AlgPagFrecUsoRec_pagina_modificada[$ejecutandoinst,$pagUsadaMarco,0]} -eq 1 ]]; then
#ES_22340Si lleva mucho tiempo como clase 3, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#ES_22350SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22360Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			fi
		fi
#ES_22370Si el tiempo ordinal de una página en una clase 2 o 3 en los últimos instantes (intervalo de tiempo) es superior al límite ($seleccionAlgoritmoPaginacion_clases_valor) se modifica a "no referenciado" y luego se calcula la nueva clase.
#ES_22380 se comprueba que no lleve más de un tiempo $seleccionAlgoritmoPaginacion_clases_valor. Si lo supera se comprueba que no sea en la misma clase 2 o 3.
#ES_22390Si ya era de clase 2 se pasa a clase 0.
#ES_22400Si lleva mucho tiempo como clase 2, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#ES_22410SI referenciada-NO modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22420Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			fi
#ES_22430Si ya era de clase 3 se pasa a clase 1.
#ES_22440Si lleva mucho tiempo como clase 2, pasa a no referenciado (0) y no modificada y, por tanto, a clase 0.
#ES_22450SI referenciada-SI modificada en un tiempo anterior inferior a seleccionAlgoritmoPaginacion_FrecRec_TiempoConsiderado unidades de tiempo.
#ES_22460Resumen - Índices: (proceso, marco). Dato: Tiempo desde la asigación de las clases 2 o 3 para NFU/NRU en las opciones para la selección del algoritmo de gestión fallos de paginación.
			fi
		fi
#ES_22470		echo ""
    done
#ES_22480Fin de gestionAlgoritmoPagAlgPagRecNRU_Referenciado_Modificado()

#
#ES_22490 Sinopsis: Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#
function gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Max_Prueba { 
	for (( indMaxPrueba=0; indMaxPrueba<${memoria[$ejecutandoinst]}; indMaxPrueba++ )); do
#ES_22500Localiza en qué posición encuentra la página.
#ES_22510Mayor antigüedad de uso encontrada.
#ES_22520Posición del marco con la mayor antigüedad de uso.
		fi
#ES_22530Y sobre esa localización se hace el fallo de página.
}

#
#ES_22540 Sinopsis: Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#
function gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Max {  
#ES_22550Para determinar si hay alguna página de clase 0, y de no ser así, de clase 1,...
	xxx_1=0
	xxx_2=0
	xxx_3=0
#ES_22560Mayor frecuencia encontrada en las páginas de clase 0.
#ES_22570Mayor frecuencia encontrada en las páginas de clase 1.
#ES_22580Mayor frecuencia encontrada en las páginas de clase 2.
#ES_22590Mayor frecuencia encontrada en las páginas de clase 3.
#ES_22600Posición del marco con la mayor frecuencia en las páginas de clase 0.
#ES_22610Posición del marco con la mayor frecuencia en las páginas de clase 1.
#ES_22620Posición del marco con la mayor frecuencia en las páginas de clase 2.
#ES_22630Posición del marco con la mayor frecuencia en las páginas de clase 3.

#ES_22640Se calculan los max para las 4 clases
#ES_22650Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
		if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMax,$punteroPagMarco]} -eq 0 ]]; then
#ES_22660Localiza en qué posición encuentra la página.
#ES_22670Mayor frecuencia encontrada.
#ES_22680Posición del marco con la mayor frecuencia.
#ES_22690Sólo se marca en caso de que haya cambio de max. De no ser así, no se marca y tampoco se cambia la variable max_AlgPagFrecRec_FrecRec ni max_AlgPagFrecRec_Position
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMax,$punteroPagMarco]} -eq 1 ]]; then
#ES_22700Localiza en qué posición encuentra la página.
#ES_22710Mayor frecuencia encontrada.
#ES_22720Posición del marco con la mayor frecuencia.
				xxx_1=1
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMax,$punteroPagMarco]} -eq 2 ]]; then
#ES_22730Localiza en qué posición encuentra la página.
#ES_22740Mayor frecuencia encontrada.
#ES_22750Posición del marco con la mayor frecuencia.
				xxx_2=1
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMax,$punteroPagMarco]} -eq 3 ]]; then
#ES_22760Localiza en qué posición encuentra la página.
#ES_22770Mayor frecuencia encontrada.
#ES_22780Posición del marco con la mayor frecuencia.
				xxx_3=1
			fi
		fi
#ES_22790Y sobre esa localización se hace el fallo de página
	if [[ $xxx_0 -eq 1 && $xxx_1 -eq 0 && $xxx_2 -eq 0 && $xxx_3 -eq 0 ]]; then
#ES_22800Mayor frecuencia encontrada.
#ES_22810Posición del marco con la mayor frecuencia.
	elif [[ $xxx_1 -eq 1 && $xxx_2 -eq 0 && $xxx_3 -eq 0 ]]; then
#ES_22820Mayor frecuencia encontrada.
#ES_22830Posición del marco con la mayor frecuencia.
	elif [[ $xxx_2 -eq 1 && $xxx_3 -eq 0 ]]; then
#ES_22840Mayor frecuencia encontrada.
#ES_22850Posición del marco con la mayor frecuencia.
	elif [[ $xxx_3 -eq 1 ]]; then
#ES_22860Mayor frecuencia encontrada.
#ES_22870Posición del marco con la mayor frecuencia.
	fi
#ES_22880Fin de gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Max() 

#
#ES_22890 Sinopsis: Se calcula el mínimo de las frecuencias de las páginas de cada proceso en NFU (min_AlgPagFrecRec_FrecRec y min_AlgPagFrecRec_Position), por clases empezando por 0.
#
function gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Min_Prueba { 
	for (( indMinPrueba=0; indMinPrueba<${memoria[$ejecutandoinst]}; indMinPrueba++ )); do
#ES_22900Localiza en qué posición encuentra la página.
#ES_22910Mayor antigüedad de uso encontrada.
#ES_22920Posición del marco con la menor antigüedad de uso.
		fi
	done
}

#
#ES_22930 Sinopsis: Se calcula el máximo de las frecuencias de las páginas de cada proceso en NFU (max_AlgPagFrecRec_FrecRec y max_AlgPagFrecRec_Position), por clases empezando por 0.
#
function gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Min {  
#ES_22940Para determinar si hay alguna página de clase 0, y de no ser así, de clase 1,...
	xxx_1=0
	xxx_2=0
	xxx_3=0
#ES_22950Menor frecuencia encontrada en las páginas de clase 0.
#ES_22960Menor frecuencia encontrada en las páginas de clase 1.
#ES_22970Menor frecuencia encontrada en las páginas de clase 2.
#ES_22980Menor frecuencia encontrada en las páginas de clase 3.
#ES_22990Posición del marco con la menor frecuencia en las páginas de clase 0.
#ES_23000Posición del marco con la menor frecuencia en las páginas de clase 1.
#ES_23010Posición del marco con la menor frecuencia en las páginas de clase 2.
#ES_23020Posición del marco con la menor frecuencia en las páginas de clase 3.

#ES_23030Se calculan los min para las 4 clases
#ES_23040Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
		if [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMin,$punteroPagMarco]} -eq 0 ]]; then
			if [[ $min_AlgPagFrecRec_FrecRec_0 -eq -1 ]]; then
				min_AlgPagFrecRec_FrecRec_0=${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMin]}
				min_AlgPagFrecRec_Position_0=$indMin
#ES_23050Sólo se marca en caso de que haya cambio de min. De no ser así, no se marca y tampoco se cambia la variable min_AlgPagFrecRec_FrecRec ni min_AlgPagFrecRec_Position
			fi
#ES_23060Localiza en qué posición encuentra la página.
#ES_23070Menor frecuencia encontrada.
#ES_23080Posición del marco con la menor frecuencia.
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMin,$punteroPagMarco]} -eq 1 ]]; then
			if [[ $min_AlgPagFrecRec_FrecRec_1 -eq -1 ]]; then
				min_AlgPagFrecRec_FrecRec_1=${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMin]}
				min_AlgPagFrecRec_Position_1=$indMin
				xxx_1=1
			fi
#ES_23090Localiza en qué posición encuentra la página.
#ES_23100Menor frecuencia encontrada.
#ES_23110Posición del menor con la mayor frecuencia.
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMin,$punteroPagMarco]} -eq 2 ]]; then
			if [[ $min_AlgPagFrecRec_FrecRec_2 -eq -1 ]]; then
				min_AlgPagFrecRec_FrecRec_2=${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMin]}
				min_AlgPagFrecRec_Position_2=$indMin
				xxx_2=1
			fi
#ES_23120Localiza en qué posición encuentra la página.
#ES_23130Menor frecuencia encontrada.
#ES_23140Posición del marco con la menor frecuencia.
			fi
		elif [[ ${directions_AlgPagFrecUsoRec_marco_pagina_clase[$ejecutandoinst,$indMin,$punteroPagMarco]} -eq 3 ]]; then
			if [[ $min_AlgPagFrecRec_FrecRec_3 -eq -1 ]]; then
				min_AlgPagFrecRec_FrecRec_3=${ResuTiempoProcesoUnidadEjecucion_MarcoPaginaFrecRec_valor[$ejecutandoinst,$indMin]}
				min_AlgPagFrecRec_Position_3=$indMin
				xxx_3=1
			fi
#ES_23150Localiza en qué posición encuentra la página.
#ES_23160Menor frecuencia encontrada.
#ES_23170Posición del marco con la menor frecuencia.
			fi
		fi
#ES_23180Y sobre esa localización se hace el fallo de página
	if [[ $xxx_0 -eq 1 && $xxx_1 -eq 0 && $xxx_2 -eq 0 && $xxx_3 -eq 0 ]]; then
#ES_23190Menor frecuencia encontrada.
#ES_23200Posición del marco con la menor frecuencia.
	elif [[ $xxx_1 -eq 1 && $xxx_2 -eq 0 && $xxx_3 -eq 0 ]]; then
#ES_23210Menor frecuencia encontrada.
#ES_23220Posición del marco con la menor frecuencia.
	elif [[ $xxx_2 -eq 1 && $xxx_3 -eq 0 ]]; then
#ES_23230Menor frecuencia encontrada.
#ES_23240Posición del marco con la menor frecuencia.
	elif [[ $xxx_3 -eq 1 ]]; then
#ES_23250Menor frecuencia encontrada.
#ES_23260Posición del marco con la menor frecuencia.
	fi

#ES_23270Fin de gestionAlgoritmoPagAlgPagRecNRU_Paginas_Clases_Min() 

#
#ES_23280 Sinopsis: Impresión pantalla tras la solicitud de datos/introducción desde fichero
#
function dibujaDatosPantallaFCFS_SJF_SRPT_RR {
#ES_23290...color
    echo -e " ┌───────────────┬───────────────┬───────────────┬───────────────┐" | tee -a $informeConColorTotal 
    echo -e " │    Proceso$NC    │  T.Llegada$NC    │  T.Ejecución$NC  │    Tamaño$NC     │" | tee -a $informeConColorTotal 
    echo -e " └───────────────┴───────────────┴───────────────┴───────────────┘" | tee -a $informeConColorTotal 
    for (( i=0; i<$nprocesos; i++)); do
        echo -e "${coloress[$i % 6]} \t${proceso[$i]}\t \t${entradaAuxiliar[$i]}\t \t${ejecucion[$i]}\t \t${memoriaAuxiliar[$i]}\t  $NC" | tee -a $informeConColorTotal
    done 
    echo -e "\n\n Memoria total: $mem_libre uds." | tee -a $informeConColorTotal
#ES_23300Se ejecuta cuando la selección inicial es por ejecución automática repetitiva. Se guardan todos los datos, aún cuando no es por Round-Robin.
		echo " Tamaño a partir del cual se reubica: $variableReubicar uds." | tee -a $informeConColorTotal 
	fi
#ES_23310Se ejecuta cuando la selección inicial es por ejecución automática repetitiva. Se guardan todos los datos, aún cuando no es por Round-Robin.
		echo " Quantum de tiempo para Round-Robin (RR): $quantum" | tee -a $informeConColorTotal 
	fi
    echo " ---------------------------------------------" | tee -a $informeConColorTotal 
   
#ES_23320...b/n
    echo -e " ┌───────────────┬───────────────┬───────────────┬───────────────┐" >> $informeSinColorTotal
    echo -e " │    Proceso    │  T.Llegada    │  T.Ejecución  │    Tamaño     │" >> $informeSinColorTotal
    echo -e " └───────────────┴───────────────┴───────────────┴───────────────┘" >> $informeSinColorTotal
    for (( i=0; i<$nprocesos; i++)); do
        echo -e " \t${proceso[$i]}\t \t${entradaAuxiliar[$i]}\t \t${ejecucion[$i]}\t \t${memoriaAuxiliar[$i]}\t  " >> $informeSinColorTotal
    done
    echo -e "\n\n Memoria total: $mem_libre uds." >> $informeSinColorTotal
#ES_23330Se ejecuta cuando la selección inicial es por ejecución automática repetitiva. Se guardan todos los datos, aún cuando no es por Round-Robin.
		echo -e " Tamaño a partir del cual se reubica: $variableReubicar uds." >> $informeSinColorTotal
	fi
#ES_23340Se ejecuta cuando la selección inicial es por ejecución automática repetitiva. Se guardan todos los datos, aún cuando no es por Round-Robin.
		echo -e " Quantum de tiempo para Round-Robin (RR): $quantum uds." >> $informeSinColorTotal
	fi
    echo -e  " ---------------------------------------------" >> $informeSinColorTotal
#ES_23350No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -e "\n$NC Pulse enter para continuar..." | tee -a $informeConColorTotal
		echo -e "\n Pulse enter para continuar..." >> $informeSinColorTotal
		read enter
		echo -e $enter "\n" >> $informeConColorTotal
		echo -e $enter "\n" >> $informeSinColorTotal
	fi
#ES_23360    clear
}

#
#ES_23370 Sinopsis: Muestra un resumen inicial ordenado por tiempo de llegada de todos los procesos introducidos.
#
function dibujaDatosPantallaPrioridad {
#ES_23380	ordenacion
#ES_23390Se ordenan los datos sacados desde $ficheroParaLectura o a medida que se van itroduciendo, por tiempo de llegada. 
#ES_23400...color
    echo -e " ┌───────────────┬───────────────┬───────────────┬───────────────┬───────────────┐" | tee -a $informeConColorTotal 
    echo -e " │    Proceso$NC    │  T.Llegada$NC    │  T.Ejecución$NC  │    Tamaño$NC     │   Prioridad$NC   │" | tee -a $informeConColorTotal 
    echo -e " └───────────────┴───────────────┴───────────────┴───────────────┴───────────────┘" | tee -a $informeConColorTotal 
    for (( i=0; i<$nprocesos; i++)); do
        echo -e "${coloress[$i % 6]} \t${proceso[$i]}\t \t${entradaAuxiliar[$i]}\t \t${ejecucion[$i]}\t \t${memoriaAuxiliar[$i]}\t \t${prioProc[$i]}\t  $NC" | tee -a $informeConColorTotal
    done
    echo -e "\n\n Memoria total: $mem_libre uds." | tee -a $informeConColorTotal
    echo " Tamaño a partir del cual se reubica: $variableReubicar uds." | tee -a $informeConColorTotal 
    echo " ---------------------------------------------" | tee -a $informeConColorTotal 
   
#ES_23410...b/n
    echo -e " ┌───────────────┬───────────────┬───────────────┬───────────────┬───────────────┐" >> $informeSinColorTotal
    echo -e " │    Proceso    │  T.Llegada    │  T.Ejecución  │    Tamaño     │   Prioridad   │" >> $informeSinColorTotal
    echo -e " └───────────────┴───────────────┴───────────────┴───────────────┴───────────────┘" >> $informeSinColorTotal
    for (( i=0; i<$nprocesos; i++)); do
        echo -e " \t${proceso[$i]}\t \t${entradaAuxiliar[$i]}\t \t${ejecucion[$i]}\t \t${memoriaAuxiliar[$i]}\t \t${prioProc[$i]}\t  " >> $informeSinColorTotal
    done
    echo -e "\n\n Memoria total: $mem_libre uds." >> $informeSinColorTotal
    echo -e " Tamaño a partir del cual se reubica: $variableReubicar uds." >> $informeSinColorTotal
    echo -e  " ---------------------------------------------" >> $informeSinColorTotal
#ES_23420No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -e "\n$NC Pulse enter para continuar..." | tee -a $informeConColorTotal
		echo -e "\n Pulse enter para continuar..." >> $informeSinColorTotal
		read enter
		echo -e $enter "\n" >> $informeConColorTotal
		echo -e $enter "\n" >> $informeSinColorTotal
	fi
#ES_23430    clear
#ES_23440Fin de imprimeprocesosresumen

#
#ES_23450 Sinopsis: Genera la Banda de Memoria y la muestra en pantalla/informe 
#
function dibujaResumenBandaMemoriaMarcosPagina { 
#ES_23460Ancho del terminal para adecuar el ancho de líneas a cada volcado
#ES_23470Para poder incluir -clase en la página. Se restan 3 porque previamente se ha añadido la logitud $digitosUnidad, y ya venía incluido.
#ES_23480Desde 0, es el ordinal del número de marcos en memoria asociados a cada proceso (Índices:Proceso)
		ordinalMarcosProcesoDibujados[$indProc]=-1	
	done
    echo ""
#ES_23490Se inicializan las variables.
	AlgPagFrecUsoRecNotas1=();
	AlgPagFrecUsoRecNotas2=();
	filaAlgPagFrecUsoRecTituloColor=""
	filaAlgPagFrecUsoRecTituloBN=""
	filaAlgPagFrecUsoRecNotas1Color=""
	filaAlgPagFrecUsoRecNotas1BN=""
	
#ES_23500Si hay algún proceso en memoria. ResuUsoRecienteAcumulado
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

#ES_23510 GENERACIÓN STRING DE PROCESOS (Línea 1 del Resumen de la Banda de Memoria) 
#ES_23520Define el número de saltos a realizar.
#ES_23530Contiene el texto a escribir de las diferentes filas antes de hacer cada salto.
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
#ES_23540Determina el número de procesos al contar el número de datos en la variable memoria.	
#ES_23550Índice que recorre los procesos del problema
#ES_23560Determina qué procesos están en memoria.
#ES_23570Páginas residentes en memoria del Proceso en ejecución. Sale de forma calculada de paginasDefinidasTotal y su orden es el establecido tras los fallos de paginación.
#ES_23580Deja 1 de margen izquierdo y 7 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.

#ES_23590 Variable que indica si se ha añadido un proceso al Resumen de la Banda de Memoria. ${memoria[$procFinalizado]}
    for ((indMem=0;indMem<$mem_total;indMem++)); do
#ES_23600 El proceso se puede imprimir en memoria
#ES_23610 El texto no cabe en la terminal
#ES_23620 Se pasa a la siguiente línea
				filaprocesosColor[$aux]="        "
				filaprocesosBN[$aux]="        "
#ES_23630Espacio por la izquierda para cuadrar líneas
            fi
#ES_23640 El texto no cabe en la terminal
                xx=0
            fi
#ES_23650 Se añade el proceso a la banda
#ES_23660proceso[$((${unidMemOcupadas[$indMem]}))]}))}
				filaprocesosBN[$aux]+=`echo -e "${proceso[$((${unidMemOcupadas[$indMem]}))]}""$espaciosfinal "`
				filaprocesosColor[$aux]+=`echo -e "${coloress[${unidMemOcupadas[$indMem]} % 6]}${proceso[$((${unidMemOcupadas[$indMem]}))]}""$NORMAL$espaciosfinal "`
                numCaracteres2=$(($numCaracteres2 + $anchoColumna))
                xx=1
            else
#ES_23670 El texto no cabe en la terminal
#ES_23680 Se pasa a la siguiente línea
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
#ES_23690 El texto no cabe en la terminal
#ES_23700 Se pasa a la siguiente línea
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

#ES_23710 GENERACIÓN STRING DE MARCOS (Línea 2 del Resumen de Memoria)  
#ES_23720Define el número de saltos a realizar.
#ES_23730Deja 1 de margen izquierdo y 7 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
	textoFallo1="M"
	textoFallo2="-F"
	for ((indMem=0;indMem<$mem_total;indMem++)); do
#ES_23740 El texto no cabe en la terminal
#ES_23750 Se pasa a la siguiente línea
			filamarcosColor[$aux]="        "
			filamarcosBN[$aux]="        "
#ES_23760Espacio por la izquierda para cuadrar líneas
		fi
		if [[ ${unidMemOcupadas[$indMem]} != "_" ]]; then	
#ES_23770Contendrá el código de subrayado con para subrayar la referencia del marco sobre el que se produciría el siguiente fallo de página.
#ES_23780Contendrá el código de negrita para la referencia del marco sobre el que se habría producido el fallo de página.
#ES_23790Ordinal del marco usado (Puntero - De 0 a n) para el Proceso en ejecución en una unidad de Tiempo.
#ES_23800Negrita - Marcos donde se produjeron Fallos de Página del Proceso en ejecución.
#ES_23810Marco real correspondiente al ordinal de un marco.
#ES_23820Marco real correspondiente al ordinal de un marco.
#ES_23830Si coincide el marco real al ordinal del marco usado, se define el color del fondo. 
				varImprimirSiguiente="\e[4m"
			fi
#ES_23840Si coincide el marco real al ordinal del marco con fallo, se define el código de negrita. 
				varImprimirFallo="\e[1m"
			fi
#ES_23850Si ese marco NO será sobre el que se produzca el siguiente fallo de página
#ES_23860Espacios por defecto. Se quita 1 por la M. 
				filamarcosColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}$varImprimirSiguiente$textoFallo1$indMem$NC$espaciosfinal "`
				filamarcosBN[$aux]+=`echo -e "M$indMem$espaciosfinal "`
#ES_23870Si el marco será sobre el que se produzca el siguiente fallo de página
#ES_23880Se quita 1 por la M, y 2 por "-F".
				filamarcosColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}$varImprimirSiguiente$varImprimirFallo$textoFallo1$indMem$textoFallo2$NC$espaciosfinal "`
				filamarcosBN[$aux]+=`echo -e "M$indMem$textoFallo$espaciosfinal "`
			fi 
		else
#ES_23890Espacios por defecto. Se quita 1 por la M. 
			filamarcosColor[$aux]+=`echo -e $NORMAL"$textoFallo1$indMem$espaciosfinal "`
			filamarcosBN[$aux]+=`echo -e "$textoFallo1$indMem$espaciosfinal "`
		fi 
		numCaracteres2=$(($numCaracteres2 + $anchoColumna))
	done

#ES_23900 GENERACIÓN STRING DE PÁGINAS (Línea 3 del Resumen de la Banda de Memoria)
#ES_23910 Línea de la banda
    numCaracteres2=10
    guionesAMeter=${varguiones:1:$(($anchoColumna - 2))}
    asteriscosAMeter=${varasteriscos:1:$(($anchoColumna - 2))}
    sumaTotalMemoria=0
#ES_23920Contador que recorrerá el número de marcos asociados a un proceso y determinar el ordinal que le corresponde.
#ES_23930 Variable que indica si se ha añadido un proceso a la banda
    for (( i=0; i<$nprocesos; i++)); do 
#ES_23940Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
	done
#ES_23950unidMemOcupadas[$indMem] da el Proceso que ocupa el marco indMem
#ES_23960Contendrá el ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo.
#ES_23970 El texto no cabe en la terminal
#ES_23980 Se pasa a la siguiente línea
			filapagBN[$aux]="        "
			filapagColor[$aux]="        "
			numCaracteres2=8
		fi
#ES_23990Contendrá la clase de la página en NFU/NRU con clases.
#ES_24000Contendrá el coeficiente M de los algoritmos de Segunda Oportunidad.
		espaciosadicionales=0
#ES_24010 El proceso se puede imprimir en memoria
#ES_24020paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}))}
#ES_24030Contendrá el color asociado al proceso en ejecución. Con él se establece el color del fondo de la página usada.
#ES_24040Sólo puede estar siendo usada una página en toda la memmoria y para el proceso en ejecución, y no las páginas de otros procesos en pausa. 
#ES_24050Ordinal del marco usado (Puntero - De 0 a n) para el Proceso en ejecución en una unidad de Tiempo.
#ES_24060Marco real correspondiente al ordinal de un marco ($varUsado).
			fi
#ES_24070Si coincide el marco real al puntero al ordinal del marco usado se define el color del fondo. 
				varImprimirUsado=${colorfondo[${unidMemOcupadas[$indMem]} % 6]}
			fi
#ES_24080Si no hay página se mete asterisco en BN.
#ES_24090paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}))}
				filapagBN[$aux]+=`echo -e "${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$espaciosasteriscofinal "`
				filapagColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$espaciosasteriscofinal$NC "`
#ES_24100Y si hay página se mete espacios y el número.
#ES_24110FIFO y Reloj con Segunda oportunidad
#ES_24120Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso. Se busca el ordinal usado en ese instante porque sería el utilizado para la búsqueda de los coeficientes M en todos los marcos al ser el mayor número.
					datoM="-"${coeficienteSegOp[$ejecutandoinst,${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$punteroPagMarco]}	
#ES_24130datoM}				

#ES_24140Óptimo
#ES_24150Índices: (proceso, marco, reloj).
#ES_24160dato4}
#ES_24170Contendrá la clase de la página en NFU/NRU con clases.
#ES_24180Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_24190Índices: (proceso, marco, número ordinal de la dirección a ejecutar(número de páginas usadas del proceso)).
#ES_24200dato4}
				fi
#ES_242102 por el tamaño de $datos4
#ES_24220Si el marco NO ha sido usado en el instante actual
					filapagBN[$aux]+=`echo -e "${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$dato4$datoM$espaciosfinal "`
					filapagColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$dato4$datoM$espaciosfinal$NC "`
#ES_24230Si el marco ha sido usado en el instante actual
					filapagBN[$aux]+=`echo -e "${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$dato4$datoM$espaciosfinal "`
					filapagColor[$aux]+=`echo -e "$NC$varImprimirUsado${paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}$dato4$datoM$espaciosfinal$NC "`
				fi
			fi
#ES_24240Número de Marcos con Páginas ya dibujadas de cada Proceso.
            numCaracteres2=$(($numCaracteres2 + $anchoColumna))
            if [[ $indMem -ne 0 ]]; then
                if [[ ${unidMemOcupadas[$((indMem - 1))]} !=  "_" ]]; then 
                    if [[ $xx -eq 1 && ${proceso[$((${unidMemOcupadas[$indMem]}))]} != ${proceso[$((${unidMemOcupadas[$((indMem - 1))]}))]} ]]; then
                        xx=0
                    fi
                fi
            fi
#ES_24250Sin proceso asignado al marco 
            xx=0
#ES_24260paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}))}
            filapagBN[$aux]+=`echo -e "$espaciosguionfinal "`
            filapagColor[$aux]+=`echo -e "$NC$espaciosguionfinal$NC "`
            numCaracteres2=$(($numCaracteres2 + $anchoColumna))
        fi
#ES_24270Aumenta el contador de marcos (ordinal de marcos distinto para cada proceso=
    done

#ES_24280 GENERACIÓN STRING DE FRECUENCIA/USO RECIENTE DE USO DE LAS PÁGINAS (Línea 4 del Resumen de la Banda de Memoria)  
#ES_24290 Línea de la frecuencia
    numCaracteres2=10
    guionesAMeter=${varguiones:1:$(($anchoColumna - 2))}
    asteriscosAMeter=${varasteriscos:1:$(($anchoColumna - 2))}
    sumaTotalMemoria=0
#ES_24300 Variable que indica si se ha añadido un proceso a la banda
    for (( i=0; i<$nprocesos; i++)); do 
#ES_24310Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
	done			
    for ((indMem=0;indMem<$mem_total;indMem++)); do
#ES_24320 El texto no cabe en la terminal
#ES_24330 Se pasa a la siguiente línea
			filaAlgPagFrecUsoRecBN[$aux]="        "
			filaAlgPagFrecUsoRecColor[$aux]="        "
			numCaracteres2=8
		fi
#ES_24340 El proceso se puede imprimir en memoria
#ES_24350Si no hay página se mete asterisco por ser frecuencia 0.
				espaciosasteriscofinal="*"${varhuecos:1:$(($anchoColumna - 2))}
				filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "$espaciosasteriscofinal "`
				filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}$espaciosasteriscofinal$NC "`
#ES_24360Y si hay página se mete espacios y el número.
				dato5=""
				dato6=""
				espaciosadicionales1=0
				espaciosadicionales2=0
#ES_24370Contendrá la clase de la página en NFU/NRU con clases.
#ES_24380Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_24390Índices: (proceso, marco)).
#ES_24400dato5}
#ES_24410Índices: (proceso, número ordinal del marco usado para ese proceso comenzando por 0).
#ES_24420dato6}
				fi 
#ES_24430Desde 0, es el ordinal del número de marcos en memoria asociados a cada proceso (Índices:Proceso)
#ES_24440ResuFrecuenciaAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]} - $espaciosadicionales1 - $espaciosadicionales2))}
				if [[ $seleccionAlgoritmoPaginacion -ge 0 && $seleccionAlgoritmoPaginacion -le 4 ]]; then
					filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "${ResuFrecuenciaAcumulado[${unidMemOcupadas[$indMem]},${ordinalMarcosProcesoDibujados[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal "`
					filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${ResuFrecuenciaAcumulado[${unidMemOcupadas[$indMem]},${ordinalMarcosProcesoDibujados[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal$NC "`
				elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#ES_24450ResuUsoRecienteAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]} - $espaciosadicionales1 - $espaciosadicionales2))}
					filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "${ResuUsoRecienteAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal "`
					filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${ResuUsoRecienteAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal$NC "`
				elif [[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
					filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "${ResuFrecuenciaAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal "`
					filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${ResuFrecuenciaAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal$NC "`
				elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
#ES_24460ResuUsoRecienteAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]} - $espaciosadicionales1 - $espaciosadicionales2))}
					filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "${ResuUsoRecienteAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal "`
					filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC${coloress[${unidMemOcupadas[$indMem]} % 6]}${ResuUsoRecienteAcumulado[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]},$reloj]}$dato5$dato6$espaciosfinal$NC "`
				fi
			fi 
#ES_24470Número de Marcos con Páginas ya dibujadas de cada Proceso.
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
#ES_24480paginasEnMemoriaTotal[${unidMemOcupadas[$indMem]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$indMem]}]}]}))}
            filaAlgPagFrecUsoRecBN[$aux]+=`echo -e "$espaciosguionfinal "`
            filaAlgPagFrecUsoRecColor[$aux]+=`echo -e "$NC$espaciosguionfinal$NC "`
            numCaracteres2=$(($numCaracteres2 + $anchoColumna))
        fi
    done

#ES_24490 GENERACIÓN STRING DE FALLOS TOTALES POR PROCESO   
#ES_24500Total de Fallos de Página del Proceso en el instante actual 

#ES_24510 IMPRIMIR LAS 4 LÍNEAS DE LA BANDA DE MEMORIA (COLOR y BN a pantalla y ficheros)
#ES_24520Si hay algún proceso en memoria.
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

#ES_24530Se vacía el auxiliar que reubica la memoria.
#ES_24540Borramos los datos de la auxiliar
        unidMemOcupadasAux[$ca]="_"
    done
#ES_24550Se vacían bloques
#ES_24560Borramos los datos de la auxiliar
         bloques[$ca]=0
    done
#ES_24570Se vacían las posiciones
    nposiciones=0
#ES_24580Se vacían posiciones iniciales y finales para borrar elementos innecesarios
    for (( i=0; i<$nposiciones; i++ )) ; do
         inicialNCmodelo[$i]=0
    done
    for (( i=0; i<$nposiciones; i++ )) ; do 
         finalNCmodelo[$i]=0
    done
#ES_24590Fin de la nueva versión de dibujaResumenBandaMemoriaMarcosPagina

#
#ES_24600 Sinopsis: Muestra los fallos de paginación por AlgPagFrecUsoRec al acabar un proceso.  ${coloress[${unidMemOcupadas[$ii]} % 6]}
#
#ES_24610  proceso[$po]  ${unidMemOcupadas[$ii]}  nproceso ejecutandoinst numeroproceso
    numCaracteres2Inicial=12
    Terminal=$((`tput cols`)) 
	if [[ $seleccionAlgoritmoPaginacion -eq 2 || $seleccionAlgoritmoPaginacion -eq 4 || $seleccionAlgoritmoPaginacion -eq 7 || $seleccionAlgoritmoPaginacion -eq 8 || $seleccionAlgoritmoPaginacion -eq 14 || $seleccionAlgoritmoPaginacion -eq 15 ]]; then 
#ES_24620Para poder incluir -clase en la página. Se restan 3 porque previamente se ha añadido la logitud $digitosUnidad, y ya venía incluido.
#ES_24630MFU/LFU con clases 
#ES_24640Para poder incluir -clase en la página. Se restan 3 porque previamente se ha añadido la logitud $digitosUnidad, y ya venía incluido.
    else
		anchoColumna=$((8 + $digitosUnidad - 3))
    fi
#ES_24650Se inicializan las variables.
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

#ES_24660 GENERACIÓN STRING DE RELOJ (Línea 1 del Resumen de Fallos de Paginación)  
#ES_24670Define el número de saltos a realizar.
	filatiempoColor[$aux]="\n$NC Tiempo     "
	filatiempoBN[$aux]="\n Tiempo     "
#ES_24680Deja 1 de margen izquierdo y 11 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
#ES_24690Índice 
	iiSiguiente=0
	for ((counter=0;counter<${ejecucion[$procFinalizado]};counter++)); do
		for ((ii=$iiSiguiente;ii<$reloj;ii++)); do
#ES_24700 El texto no cabe en la terminal
#ES_24710 Se pasa a la siguiente línea
				filatiempoColor[$aux]="\n            "
				filatiempoBN[$aux]="\n            "
#ES_24720Espacio por la izquierda para cuadrar líneas
			fi
			if [[ ${ResuTiempoProceso[$ii]} -eq $procFinalizado ]]; then
#ES_24730ii}))}
				filatiempoColor[$aux]+=`echo -e "$NORMAL""$ii$espaciosfinal$NORMAL "`
				filatiempoBN[$aux]+=`echo -e "$ii$espaciosfinal "`
#ES_24740Para que no se repitan los datos en cada ciclo al no empezar desde 0.
				numCaracteres2=$(($numCaracteres2 + $anchoColumna + 1))
			fi
		done
	done

#ES_24750 GENERACIÓN STRING DE PÁGINAS (Línea 2 del Resumen de Fallos de Paginación)  
#ES_24760Define el número de saltos a realizar. paginasDefinidasTotal  (Índices:Proceso, Páginas).
	filapagColor[$aux]="$NC Página     "
	filapagBN[$aux]=" Página     "
#ES_24770Deja 1 de margen izquierdo y 11 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
	iiSiguiente=0
	varCierre=0
	for ((counter=0;counter<${ejecucion[$procFinalizado]};counter++)); do
		for ((ii=$iiSiguiente;ii<$reloj;ii++)); do
#ES_24780 El texto no cabe en la terminal
#ES_24790 Se pasa a la siguiente línea
				filapagColor[$aux]="            "
				filapagBN[$aux]="            "
#ES_24800Espacio por la izquierda para cuadrar líneas
			fi
#ES_24810Evita qe queden elementos definidos de ejecuciones anteriores por las que sake un número al final de la línea en una nueva columna que, teóricamente no existe.
				varCierre=$(($varCierre + 1))
#ES_24820paginasDefinidasTotal[$procFinalizado,$ii]}))}
				filapagColor[$aux]+=`echo -e "$NORMAL""${paginasDefinidasTotal[$procFinalizado,$ii]}$espaciosfinal$NORMAL "`
				filapagBN[$aux]+=`echo -e "${paginasDefinidasTotal[$procFinalizado,$ii]}$espaciosfinal "`
				numCaracteres2=$(($numCaracteres2 + $anchoColumna + 1))
#ES_24830Para que no se repitan los datos en cada ciclo al no empezar desde 0.
			fi
		done
	done

#ES_24840 GENERACIÓN STRING DE Página-Frecuencia-Uso Reciente-Clase (Líneas de Marcos del Resumen de Fallos de Paginación)  
#ES_24850Bucle que recorre la ejecución del proceso finalizado a lo largo del tiempo para generar las variables con los datos a usar en la impresión del resumen. 	
#ES_24860Define el número de saltos a realizar.
#ES_24870Se considera que los números de marcos, páginas y frecuencias no superarán los tres dígitos.
#ES_24880"$NC Marco-Pág-Frec/UsoRec "
#ES_24890" Marco-Pág-Frec/UsoRec "
#ES_24900Deja 1 de margen izquierdo y 12 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
		iiSiguiente=0
		for ((counter=0;counter<${ejecucion[$procFinalizado]};counter++)); do
			for ((ii=$iiSiguiente;ii<$reloj;ii++)); do
#ES_24910Si el proceso que se ejecuta en un instante es el finalizado...
#ES_24920 El texto no cabe en la terminal
#ES_24930 Se pasa a la siguiente línea
						filaAlgPagFrecUsoRecColor[$k,$aux]="            "
						filaAlgPagFrecUsoRecBN[$k,$aux]="            "
#ES_24940Espacio por la izquierda para cuadrar líneas
					fi
#ES_24950Índices: (proceso, tiempo, número ordinal de marco). Dato del marco real que corresponde al ordinal
#ES_24960Índices: (proceso, marco, tiempo). Dato de la página contenida en el marco
					if ([[ $seleccionAlgoritmoPaginacion -ge 0 && $seleccionAlgoritmoPaginacion -le 4 ]]) || ([[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 9 ]]); then
#ES_24970Índices: (proceso, marco, tiempo). Dato de la frecuencia de uso de la página contenida en el marco
					elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#ES_24980Índices: (proceso, marco, tiempo). Dato del Tiempo que hace que se usó la página contenida en el marco
					elif [[ $seleccionAlgoritmoPaginacion -ge 10 && $seleccionAlgoritmoPaginacion -le 11 ]]; then
						dato3=${ResuFrecuenciaAcumulado[$procFinalizado,$k,$ii]}
						if [[ $dato3 -ge $seleccionAlgoritmoPaginacion_clases_frecuencia_valor ]]; then
#ES_24990Índices: (proceso, marco, tiempo). Dato del Tiempo que hace que se usó la página contenida en el marco
						fi
					elif [[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 15 ]]; then
#ES_25000Índices: (proceso, marco, tiempo). Dato del Tiempo que hace que se usó la página contenida en el marco
					elif [[ $seleccionAlgoritmoPaginacion -ge 16 && $seleccionAlgoritmoPaginacion -le 17 ]]; then
						dato3=${ResuUsoRecienteAcumulado[$procFinalizado,$k,$ii]}
						if [[ $dato3 -ge $seleccionAlgoritmoPaginacion_clases_uso_rec_valor ]]; then
#ES_25010Índices: (proceso, marco, tiempo). Dato del Tiempo que hace que se usó la página contenida en el marco
						fi
					fi
#ES_25020Contendrá la clase de la página en NFU/NRU con clases.
#ES_25030Contendrá el coeficiente M en algoritmos de Segunda Oportunidad.
					if [[ $seleccionAlgoritmoPaginacion -eq 2 || $seleccionAlgoritmoPaginacion -eq 4 ]]; then
#ES_25040Si no hay página, tampoco habrá coeficiente M
#ES_25050Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso. Se busca el ordinal usado en ese instante porque sería el utilizado para la búsqueda de los coeficientes M en todos los marcos al ser el mayor número.
#ES_25060Se usa el ordinal de la página desde ResuPaginaOrdinalAcumulado() que da el ordinal de la página en un marco en cada instante de reloj.				
							datostot="$dato1-$dato2-$dato3-$datoM"
#ES_25070Si no hay página asociada sólo se muestra el número de marco real.
							datostot="$dato1"						
						fi
					elif [[ $seleccionAlgoritmoPaginacion -eq 5 ]]; then
#ES_25080Si no hay página, tampoco habrá tiempo hasta una nueva ejecución. 
							datostot="$dato1-$dato2-$dato3"
						else
							datostot="$dato1"						
						fi
					elif [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then
#ES_25090Si no hay página, tampoco habrá clase
#ES_25100Resumen - Índices: (proceso, marco, reloj). Dato: Ordinal de la Página en la serie de páginas a ejecutar (ejecución) de un proceso, que ocupa cada Marco en cada unidad de Tiempo. Se acumulan los datos de todos los marcos del proceso.
#ES_25110Resumen - Índices: (proceso, ordinal del tiempo de ejecución). Dato: Página modificada (1) o no modificada (0).
#ES_25120Índices: (proceso, marco, número ordinal de la dirección a ejecutar).
						fi
						datostot="$dato1-$dato2-$dato3-$dato4"
					elif [[ $seleccionAlgoritmoPaginacion -eq 0 ]] || [[ $seleccionAlgoritmoPaginacion -eq 1 ]] || [[ $seleccionAlgoritmoPaginacion -eq 3 ]] || ([[ $seleccionAlgoritmoPaginacion -ge 6 && $seleccionAlgoritmoPaginacion -le 9 ]]) || ([[ $seleccionAlgoritmoPaginacion -ge 12 && $seleccionAlgoritmoPaginacion -le 15 ]]); then
						datostot="$dato1-$dato2-$dato3"
					fi
#ES_25130datostot}))}  
#ES_25140En lugar de generar diferentes opciones y comparativas, se generará una serie de variables con las modificaciones de formato. 
#ES_25150Fondo de color - Marco usado (Puntero) para cada Proceso en cada unidad de Tiempo.
					if [[ $seleccionAlgoritmoPaginacion -ne 0 ]]; then
#ES_25160Subrayado - Marco (Puntero) sobre el que se produce el siguiente fallo para cada Proceso en cada unidad de Tiempo.
					fi
#ES_25170Negrita - Marcos donde se produjeron Fallos de Página del Proceso en ejecución.
					varImprimirUsado=""
					varImprimirSiguiente=""
					varImprimirFallo=""
#ES_25180Contendría el marco sobre el que se produce un fallo.
					if [[ ${varUsado} -eq $k ]]; then
						varImprimirUsado=${colorfondo[$procFinalizado % 6]}
					elif [[ ${varSiguiente} -eq $k && $seleccionAlgoritmoPaginacion -ne 0 ]]; then
						varImprimirSiguiente="\e[4m"
#ES_25190Si contiene algún dato (marco) es porque hay un fallo.
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
#ES_25200Para que no se repitan los datos en cada ciclo al no empezar desde 0.
			done
		done
	done

#ES_25210 GENERACIÓN STRING DE FALLOS (Líneas de Fallos del Resumen de Fallos de Paginación)  
#ES_25220Define el número de saltos a realizar.
#ES_25230Es fijo porque sólo se va a escribir "F" o "-".
#ES_25240"$NC Marco-Pág-Frec/UsoRec "
#ES_25250" Marco-Pág-Frec/UsoRec "
#ES_25260Deja 1 de margen izquierdo y 12 para controlar el comienzo del espacio usado para los datos para controlar los saltos de línea.
	iiSiguiente=0
	for ((counter=0;counter<${ejecucion[$procFinalizado]};counter++)); do
		for ((ii=$iiSiguiente;ii<=$reloj;ii++)); do
#ES_25270Si el proceso que se ejecuta en un instante es el finalizado...
#ES_25280 El texto no cabe en la terminal
#ES_25290 Se pasa a la siguiente línea
					filaFallosColor[$aux]="            "
					filaFallosBN[$aux]="            "
#ES_25300Espacio por la izquierda para cuadrar líneas
				fi
#ES_25310Contendría el marco sobre el que se produce un fallo.
#ES_25320Si contiene algún dato (marco) es porque hay un fallo.
					filaFallosColor[$aux]+=`echo -e "${coloress[$procFinalizado % 6]}""F""$NC$espaciosfinal "`
					filaFallosBN[$aux]+=`echo -e "F""$espaciosfinal "`
				else
					filaFallosColor[$aux]+=`echo -e "-""$NC$espaciosfinal "`
					filaFallosBN[$aux]+=`echo -e "-""$espaciosfinal "`
				fi
				numCaracteres2=$(($numCaracteres2 + $anchoColumna + 1))
			fi
#ES_25330Para que no se repitan los datos en cada ciclo al no empezar desde 0.
		done
	done

#ES_25340 GENERACIÓN STRING DE FALLOS TOTALES POR PROCESO  
#ES_25350Total de Fallos de Página del Proceso 

#ES_25360 IMPRIMIR LAS LÍNEAS DE LOS MARCOS DE MEMORIA POR PROCESO (COLOR y BN a pantalla y ficheros)
	echo -e "$filaAlgPagFrecUsoRecTituloColor" | tee -a $informeConColorTotal
	echo -e "$filaAlgPagFrecUsoRecNotas1Color" | tee -a $informeConColorTotal
	echo -ne "$filaAlgPagFrecUsoRecNotas2Color" | tee -a $informeConColorTotal
	echo -e "$filaAlgPagFrecUsoRecTituloBN" >> $informeSinColorTotal
	echo -e "$filaMF$filaAlgPagFrecUsoRecNotas1BN" >> $informeSinColorTotal
	echo -ne "$filaAlgPagFrecUsoRecNotas2BN" >> $informeSinColorTotal
#ES_25370Para cada salto de línea por no caber en la pantalla
		echo -e "${filatiempoColor[$jj]}" | tee -a $informeConColorTotal
		echo -e "${filapagColor[$jj]}" | tee -a $informeConColorTotal
		echo -e "${filatiempoBN[$jj]}" >> $informeSinColorTotal
		echo -e "${filapagBN[$jj]}" >> $informeSinColorTotal
#ES_25380Para cada marco asociado al proceso
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
#ES_25390Se define a "-1" para que no vuelva a imprimirse en caso de producirse algún otro evento.
#ES_25400Fin de dibujaResumenAlgPagFrecUsoRec()

#
#ES_25410 Sinopsis: Permite introducir las opciones generales de la memoria por teclado
#
function entradaMemoriaTeclado {
#ES_25420Pedir el número de marcos de memoria del sistema
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
#ES_25430Pedir el número de direcciones de cada marco de memoria del sistema
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

#ES_25440Se inicializa para que no se considere la reubicabilidad si no está definida en la elección inicial.
#ES_25450R/NR
#ES_25460Pedir el tamaño de la variable de reubicación $reubicabilidadNo0Si1 -eq 0
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
    
#ES_25470Direcciones totales de memoria.
#ES_25480Número de marcos totales de memoria.
    variableReubicar=$reub

#ES_25490 salida de datos introducidos sobre la memoria para que el usuario pueda ver lo que esta introducciendo y volcado de los mismos en ficheros auxiliares
    echo ""
#ES_25500Se meten los datos de las particiones en otro fichero escogido
#ES_25510Se meten los datos de las particiones en otro fichero escogido
#ES_25520Se meten los datos de las particiones en otro fichero escogido
#ES_25530    clear
#ES_25540Fin de entradaMemoriaTeclado()                

#
#ES_25550 Sinopsis: Permite introducir los procesos por teclado.
#
function entradaProcesosTeclado {
#ES_25560Número ordinal de proceso
    masprocesos="s"
#ES_25570Se meten los textos correspondientes a los datos en el fichero escogido
    while [[ $masprocesos == "s" ]]; do 
#ES_25580        clear
#ES_25590Para ser equivalente al nuevo programa. Se aconseja quitar la variable $p y estandarizar las variables a usar ??????????.
#ES_25600Bloque para introducción del resto de datos del proceso
#ES_25610Se introduce el tiempo de llegada asociado a cada proceso.
        echo -ne $NORMAL"\n Tiempo de llegada del proceso $p: " >> $informeSinColorTotal
        read llegada[$p]
        until [[ ${llegada[$p]} -ge 0 ]]; do
            echo $NORMAL" No se pueden introducir tiempos de llegada negativos" | tee -a $informeConColorTotal
            echo $NORMAL" No se pueden introducir tiempos de llegada negativos" >>$informeSinColorTotal
            echo -ne $NORMAL" Introduce un nuevo tiempo de llegada\n" | tee -a $informeConColorTotal
            echo -ne $NORMAL" Introduce un nuevo tiempo de llegada\n" >> $informeSinColorTotal
            read llegada[$p]
        done
                
#ES_25620Se introduce la memoria asociada a cada proceso.
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
#ES_25630Se introduce la prioridad asociada a cada proceso.
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
#ES_25640Número ordinal de dirección/página definidas
		paginasTeclado=""
#ES_25650Se introducen las direcciones asociadas a cada proceso.
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
#ES_25660				directions[$p,$numOrdinalPagTeclado]=$paginasTeclado
#ES_25670let pagTransformadas[$2]=`expr $1/$mem_direcciones`
				varPaginasTeclado=$varPaginasTeclado"$paginasTeclado "
				paginasDefinidasTotal[$p,$numOrdinalPagTeclado]=${pagTransformadas[$numOrdinalPagTeclado]} 
				ejecucion[$p]=$(expr ${ejecucion[$p]} + 1)
#ES_25680Para ser equivalente al nuevo programa
				numOrdinalPagTeclado=$(expr $numOrdinalPagTeclado + 1)
			fi
		done

#ES_25690Salida de datos introducidos sobre procesos para que el usuario pueda ver lo que esta introducciendo y volcado de los mismos en ficheros auxiliares
        echo ""
#ES_25700Se meten los datos de las particiones en otro fichero escogido
#ES_25710        clear 
#ES_25720Se ordenan los datos por tiempo de llegada a medida que se van itroduciendo. También crea los bit de Modificados para cuando se utilicen los algoritmos basados en clases.

        echo -e $NORMAL"\n\n Ref Tll Tej nMar Dir-Pag" | tee -a $informeConColorTotal
        echo -e "\n\n Ref Tll Tej nMar Dir-Pag" >> $informeSinColorTotal
#ES_25730Función para mostrar los datos   
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
#ES_25740incremento el contador
    done
#ES_25750Se guardan los datos introducidos en el fichero de última ejecución
        cp $ficheroDatosDefault $ficheroDatosAnteriorEjecucion
    else
        cp $nomFicheroDatos $ficheroDatosAnteriorEjecucion
    fi
#ES_25760Fin de entradaProcesosTeclado()

#
#ES_25770 Sinopsis: Impresión de los procesos una vez introducidos por teclado o fichero 
#
function imprimeprocesos {
#ES_25780Se ordenan los procesos por tiempo de llegada a medida que se van introduciendo.
	for (( counter = 0; counter <= numprocesos; counter++ )); do
		if [[ $counter -gt 8 ]]; then
			let colorjastag[counter]=counter-8;
		else
			let colorjastag[counter]=counter+1;
		fi
	done
	echo -e "\n Ref Tll Tej nMar Dirección-Página ------ imprimeprocesos\n" | tee -a $informeConColorTotal $informeSinColorTotal
#ES_25790Resumen inicial de la taba de procesos.
	echo "" | tee -a $informeConColorTotal $informeSinColorTotal > /dev/null
	echo "|—————————————————————————————————————————————————————————————————————————|" | tee -a $informeConColorTotal $informeSinColorTotal > /dev/null
	echo "" | tee -a $informeConColorTotal $informeSinColorTotal > /dev/null
	echo "" | tee -a $informeConColorTotal $informeSinColorTotal > /dev/null
#ES_25800Fin de imprimeprocesos()

#
#ES_25810 Sinopsis: Permite visualizar los datos de la memoria/procesos introducidos por teclado.
#
function entradaProcesosTecladoDatosPantalla { 
	multiplicador=0
	counter2=0
	counter3=0	
#ES_25820Define los colores de los procesos de forma cíclica. 
#ES_25830Faltaría ajustar los valores de las variables a los colores posibles (6, 8, 9). Pero no es una buena idea porque los colores del texto y fondos no coinciden como se ve en las variables $coloress y $colorfondos...
			multiplicador=$multiplicador+1
#ES_25840Para calcular la diferencia ente contadores para determinar cuándo es superior al número de colores usados.
		fi
		counter2=$counter-$counter3;
		let colorjastag[counter]=$counter2+1;
	done
#ES_25850llegada[@]}; t++)); do
        echo -ne " ${coloress[$t % 6]}${proceso[$t]}" | tee -a $informeConColorTotal
        echo -n " ${proceso[$t]}" >>$informeSinColorTotal
#ES_25860llegada[$t]})) 
        echo -ne "${varhuecos:1:$longitudLlegada}""${coloress[$t % 6]}${llegada[$t]}" | tee -a $informeConColorTotal 
        echo -n "${varhuecos:1:$longitudLlegada}""${llegada[$t]}" >>$informeSinColorTotal
#ES_25870ejecucion[$t]})) 
        echo -ne "${varhuecos:1:$longitudTiempo}""${coloress[$t % 6]}${ejecucion[$t]}" | tee -a $informeConColorTotal 
        echo -n "${varhuecos:1:$longitudTiempo}""${ejecucion[$t]}" >>$informeSinColorTotal            
#ES_25880memoria[$t]})) 
        echo -ne "${varhuecos:1:$longitudMemoria}""${coloress[$t % 6]}${memoria[$t]}" | tee -a $informeConColorTotal 
        echo -ne "${varhuecos:1:$longitudMemoria}""${memoria[$t]}" >>$informeSinColorTotal
 		DireccionesPaginasPorProceso=""
 		for ((counter2=0;counter2<${ejecucion[$t]};counter2++)); do
			DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$t]}${directions[$t,$counter2]}-${paginasDefinidasTotal[$t,$counter2]}"
		done
		echo -e "$DireccionesPaginasPorProceso" | tee -a $informeConColorTotal
    done
#ES_25890Fin de entradaProcesosTecladoDatosPantalla()

#
#ES_25900 Sinopsis: Permite ordenar los datos sacados desde fichero y de entrada por teclado. 
#
function ordenarDatosEntradaFicheros {
#ES_25910llegada[@]}; j++)); do
#ES_25920Se guarda su número de orden de introducción o lectura en un vector para la función que lo ordena   
    done
#ES_25930llegada[@]}; j++)); do
        if [[ $j -ge 9 ]]; then
            proceso[$j]=$(echo P$(($j + 1)))
        else
            proceso[$j]=$(echo P0$(($j + 1)))
        fi
    done
#ES_25940llegada[@]} - 1)); j >= 0; j-- )); do 
        for (( i = 0; i < $j; i++ )); do
            if [[ $((llegada[$i])) -gt $((llegada[$(($i + 1))])) ]]; then
#ES_25950No hace falta borrar aux porque sólo hay un valor, y su valor se machaca en cada redefinición. 
                proceso[$(($i + 1))]=${proceso[$i]} 
                proceso[$i]=$aux
                aux=${llegada[$(($i + 1))]}
                llegada[$(($i + 1))]=${llegada[$i]}
                llegada[$i]=$aux
#ES_25960Se permutan las páginas
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${paginasDefinidasTotal[$(($i + 1)),$counter2]}
				done
#ES_25970Se borran para que no pueda haber valores anteriores residuales.
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

#ES_25980Se permutan las direcciones los valores de "Página Modificada", cuando se trabaja con algoritmos basados en Clases, porque se definió en leer_datos_desde_fichero().
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${directions[$(($i + 1)),$counter2]}
				done
#ES_25990Se borran para que no pueda haber valores anteriores residuales.
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

#ES_26000Se permutan las direcciones los valores de "Página Modificada", cuando se trabaja con algoritmos basados en Clases, porque se definió en leer_datos_desde_fichero().
				for ((counter2=0;counter2<${ejecucion[$(($i + 1))]};counter2++)); do
					aux2[$counter2]=${directions_AlgPagFrecUsoRec_pagina_modificada[$(($i + 1)),$counter2,0]}
				done
#ES_26010Se borran para que no pueda haber valores anteriores residuales.
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
#ES_26020Se permutan los valores de esta variable auxiliar porque se definió en leer_datos_desde_fichero().
                tiempoEjecucion[$i]=$aux
                aux=${memoria[$(($i + 1))]}
                memoria[$(($i + 1))]=${memoria[$i]} 
                memoria[$i]=$aux
                aux=${prioProc[$(($i + 1))]}
#ES_26030En caso de usar el algoritmo basado en Prioridades...
                prioProc[$i]=$aux
            fi
        done
    done
#ES_26040llegada[@]}; j++)); do
#ES_26050Se guarda su número de orden de introducción o lectura en un vector para la función que lo ordena   
    done
#ES_26060Fin de ordenarDatosEntradaFicheros()

#
#ES_26070 Sinopsis: Pregunta en qué fichero guardar los rangos para la opción 8.
#
function entradaMemoriaRangosFichero_op_cuatro_Previo {
#ES_26080    clear
#ES_26090Resuelve los nombres de los ficheros de rangos
#ES_26100Resuelve los nombres de los ficheros de datos
#ES_26110Fin de entradaMemoriaRangosFichero_op_cuatro_Previo()

#
#ES_26120 Sinopsis: Se piden y tratan los mínimos y máximos de los rangos, calculando los valores aleatorios y los datos 
#ES_26130 con los que se trabajará para la opción 4. 
#
function entradaMemoriaRangosFichero_op_cuatro { 
#ES_26140---Llamada a funciones para rangos-------------
#ES_26150Se asigna la memoria aleatoriamente       
    calcDatoAleatorioGeneral $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS
	mem_total=$datoAleatorioGeneral
#ES_26160Se asigna la memoria aleatoriamente       
    calcDatoAleatorioGeneral $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
	mem_direcciones=$datoAleatorioGeneral
#ES_26170Se comparará este valor con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.

#ES_26180Se asigna el mínimo del rango de prioridad aleatoriamente       
	MIN_RANGE_prio_menorInicial=${prio_menor_min}
	MAX_RANGE_prio_menorInicial=${prio_menor_max}
#ES_26190Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_prio_menor=$PriomFinal
	MAX_RANGE_prio_menor=$PrioMFinal
	calcDatoAleatorioGeneral $MIN_RANGE_prio_menor $MAX_RANGE_prio_menor
	prio_menorInicial=$datoAleatorioGeneral
#ES_26200Se asigna el máximo del rango de prioridad aleatoriamente       
	MIN_RANGE_prio_mayorInicial=${prio_mayor_min}
	MAX_RANGE_prio_mayorInicial=${prio_mayor_max}
#ES_26210Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_prio_mayor=$PriomFinal
	MAX_RANGE_prio_mayor=$PrioMFinal
	calcDatoAleatorioGeneral $MIN_RANGE_prio_mayor $MAX_RANGE_prio_mayor
	prio_mayorInicial=$datoAleatorioGeneral
	prio_menor_min=$prio_menor_minInicial
	prio_menor_max=$prio_menor_maxInicial
#ES_26220Se invierten los valores si el mayor es menor que el mayor.
	prio_menor=$PriomFinal
	prio_mayor=$PrioMFinal
#ES_26230Se asigna la reubicaciónaleatoriamente     
    calcDatoAleatorioGeneral $MIN_RANGE_REUB $MAX_RANGE_REUB
	reub=$datoAleatorioGeneral
#ES_26240Se asigna el número de procesos aleatoriamente 
    calcDatoAleatorioGeneral $MIN_RANGE_NPROC $MAX_RANGE_NPROC
	n_prog=$datoAleatorioGeneral
#ES_26250--------------------------------------------- En algunos casos no hace falta calcularlo porque se calculará por cada proceso. 
    datos_tiempo_llegada    
    datos_tiempo_ejecucion 
    datos_tamano_marcos_procesos 
    datos_prio_proc
#ES_26260---------------------------------------------
	datos_quantum         
	calcDatoAleatorioGeneral $MIN_RANGE_quantum $MAX_RANGE_quantum
	quantum=$datoAleatorioGeneral
#ES_26270--------------------------------------------- El resto no hace falta calcularlo porque se calculará por cada proceso. 
    datos_tamano_direcciones_procesos          
#ES_26280---------------------------------------------
#ES_26290    clear   
	for (( p=0; p<$n_prog; p++)); do     
#ES_26300Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 4, 5 y 6. 
#ES_26310Guarda los datos en los ficheros que correspondan
#ES_26320cierre del until
#ES_26330Copia los ficheros Default/Último
#ES_26340Fin de entradaMemoriaRangosFichero_op_cuatro()

#
#ES_26350 Sinopsis: Se guardarán los datos en los ficheros que corresponda para la opción 4
#ES_26360 
function entradaMemoriaRangosFichero_op_cuatro_Post_1 {
#ES_26370Para imprimir los rangos en el fichero dependiendo si es el fichero anterior o otro
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
#ES_26380Cierre if $p -eq 1
#ES_26390No se establece desde fichero sino que se decide en el momento de la ejecución mediante la variable de selección de tipo $seleccionTipoPrioridad.
#ES_26400M/m
		PrioR="Mayor"
	else    
		PrioR="Menor"                
	fi              
#ES_26410Escribe los datos en el fichero selecionado
		echo -ne "Marcos totales\n"$mem_total"\nTamano de pagina\n"$mem_direcciones"\nPrioridad menor\n"$prio_menorInicial\
		"\nPrioridad mayor\n"$prio_mayorInicial"\nTipo de prioridad\n"$PrioR"\nMinimo para reubicabilidad\n"$reub"\nQuantum\n"$quantum\
		"\nTll nMar Prio Direcciones/Modificado:\n" > $nomFicheroDatos
	fi                  

#ES_26420Se usarán para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
	MAX_RANGE_PAGINA_MODIFICADA=1
#ES_26430Hace que las direcciones sean diferentes en cada proceso.
#ES_26440Muestra las direcciones del proceso calculadas de forma aleatoria.
#ES_26450Se almacena el cálculo aleatorio de si una página es o no modificada al ser ejecutada.
#ES_26460Se calcula de forma aleatoria si una página es o no modificada al ser ejecutada.
		direccionesAcumuladas+=`echo -ne " ${directions[$p,$numdir]}-${directions_AlgPagFrecUsoRec_pagina_modificada[$p,$numdir,0]}"`
	done
	echo -e ${llegada[$p]} ${memoria[$p]} ${prioProc[$p]} $direccionesAcumuladas >> $nomFicheroDatos
#ES_26470    clear
#ES_26480Fin de entradaMemoriaRangosFichero_op_cuatro_Post_1()

#
#ES_26490 Sinopsis: Se copian los ficheros que correspondan para la opción 4
#
function entradaMemoriaRangosFichero_op_cuatro_Post_2 {
#ES_26500Borra el fichero de datos ultimo y escribe los datos en el fichero
        rm $ficheroDatosAnteriorEjecucion
    fi
#ES_26510Borra el fichero de datos ultimo y escribe los rangos en el fichero
        rm $ficheroRangosAnteriorEjecucion
    fi
#ES_26520Copia los ficheros Default/Último       
#ES_26530Copia los ficheros Default/Último       
#ES_26540Fin de entradaMemoriaRangosFichero_op_cuatro_Post_2()

#
#ES_26550 Sinopsis: Pregunta en qué fichero guardar los rangos amplios para la opción 5.
#
function entradaMemoriaRangosFichero_op_cinco_Previo {
#ES_26560    clear
#ES_26570Resuelve los nombres de los ficheros de datos
#ES_26580Fin de entradaMemoriaRangosFichero_op_cinco_Previo()

#
#ES_26590 Sinopsis: Pregunta en qué fichero guardar los rangos amplios para la opción 6.
#
function entradaMemoriaRangosFichero_op_seis_Previo {
#ES_26600    clear
#ES_26610Resuelve los nombres de los ficheros de datos
    echo -e "\n\nFicheros existentes:\n$NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\nFicheros existentes:\n" >> $informeSinColorTotal 
    files=("./FRangos"/*)
#ES_26620Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
        echo -e "$i) ${files[$i]}" | tee -a $informeConColorTotal
        echo -e "$i) ${files[$i]}" >> $informeSinColorTotal 
    done
    echo -ne "\n$AMARILLO\n\nIntroduce el número correspondiente al fichero elegido: $NORMAL" | tee -a $informeConColorTotal
    echo -ne "\n\n\nIntroduce el número correspondiente al fichero elegido: " >> $informeSinColorTotal 
    read -r numeroFichero
#ES_26630files[@]} ]]; do
        echo -ne "Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read -r numeroFichero
        echo -e "$numeroFichero\n\n" >> $informeConColorTotal
        echo -e "$numeroFichero\n\n" >> $informeSinColorTotal
    done
    echo "$numeroFichero" >> $informeConColorTotal
    echo "$numeroFichero" >> $informeSinColorTotal
    ficheroParaLectura="${files[$numeroFichero]}"
#ES_26640    clear
#ES_26650Fin de entradaMemoriaRangosFichero_op_seis_Previo()

#
#ES_26660 Sinopsis: Se tratan los mínimos y máximos de los rangos, calculando los valores aleatorios y los datos 
#ES_26670 con los que se trabajará para las opciones 5 y 6. 
#
function entradaMemoriaRangosFichero_op_cinco_seis {
#ES_26680    datos_memoria_tabla
#ES_26690-----------Llamada a funciones para calcular los datos aleatorios dentro de los rangos definidos-------------
    MIN_RANGE_MARCOS=${memoria_min}
    MAX_RANGE_MARCOS=${memoria_max}
    calcDatoAleatorioGeneral $MIN_RANGE_MARCOS $MAX_RANGE_MARCOS
	mem_total=$datoAleatorioGeneral
    MIN_RANGE_DIRECCIONES=${direcciones_min}
    MAX_RANGE_DIRECCIONES=${direcciones_max}
    calcDatoAleatorioGeneral $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
	mem_direcciones=$datoAleatorioGeneral
#ES_26700Se comparará este valor con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.

    MIN_RANGE_prio_menor=${prio_menor_min}
    MAX_RANGE_prio_menor=${prio_menor_max}
    calcDatoAleatorioGeneral $MIN_RANGE_prio_menor $MAX_RANGE_prio_menor
#*#ES_26710*Inicial - Datos a representar
    MIN_RANGE_prio_mayor=${prio_mayor_min}
    MAX_RANGE_prio_mayor=${prio_mayor_max}
    calcDatoAleatorioGeneral $MIN_RANGE_prio_mayor $MAX_RANGE_prio_mayor
#*#ES_26720*Inicial - Datos a representar
#ES_26730Variables con los datos originales usadas en la cabecera de la representación de la tabla
	PrioMInicial=$prio_mayorInicial
#ES_26740Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#ES_26750Sobre este rango se calculan los datos de las prioridades de los procesos, prioridades que no deberían pedirse al usuario.
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
#ES_26760El resto no se recalcula porque son datos de cada proceso, como tiempo_llegada, tamano_procesos,...
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
#ES_26770No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -e "\n$NC Pulse enter para continuar..." | tee -a $informeConColorTotal
		echo -e "\nPulse enter para continuar..." >> $informeSinColorTotal
		read enter
		echo -e $enter "\n" >> $informeConColorTotal
		echo -e $enter "\n" >> $informeSinColorTotal
	fi
#ES_26780    clear   
	for (( p=0; p<$n_prog; p++)); do     
#ES_26790Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 4, 5 y 6. 
#ES_26800Guarda los datos en los ficheros que correspondan        
#ES_26810cierre del for   
#ES_26820Copia los ficheros Default/Último    
#ES_26830Fin de entradaMemoriaRangosFichero_op_cinco_seis()

#
#ES_26840 Sinopsis: Se guardarán los datos en los ficheros que corresponda para las opciones 5 y 6 
#
function entradaMemoriaRangosFichero_op_cinco_seis_Post_1 {
#ES_26850No se establece desde fichero sino que se decide en el momento de la ejecución mediante la variable de selección de tipo $seleccionTipoPrioridad.
#ES_26860M/m
		PrioR="Mayor"
	else    
		PrioR="Menor"                
	fi              
	if [[ $p -eq 0 ]]; then
		echo -ne "Marcos totales\n"$mem_total"\nTamano de pagina\n"$mem_direcciones"\nPrioridad menor\n"$prio_menorInicial\
		"\nPrioridad mayor\n"$prio_mayorInicial"\nTipo de prioridad\n"$PrioR "\nMinimo para reubicabilidad\n"$reub"\nQuantum\n"$quantum\
		"\nTll nMar Prio Direcciones:\n" > $nomFicheroDatos
	fi                  

#ES_26870Hace que las direcciones sean diferentes en cada proceso.
#ES_26880Se usarán para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
	MAX_RANGE_PAGINA_MODIFICADA=1
#ES_26890Muestra las direcciones del proceso calculadas de forma aleatoria.
#ES_26900Se calcula de forma aleatoria si una página es o no modificada al ser ejecutada.
#ES_26910Se almacena el cálculo aleatorio de si una página es o no modificada al ser ejecutada.
		direccionesAcumuladas+=`echo -ne " ${directions[$p,$numdir]}-${directions_AlgPagFrecUsoRec_pagina_modificada[$p,$numdir,0]}"`
	done
	echo -e ${llegada[$p]} ${memoria[$p]} ${prioProc[$p]} $direccionesAcumuladas >> $nomFicheroDatos
#ES_26920Fin de entradaMemoriaRangosFichero_op_cinco_seis()

#
#ES_26930 Sinopsis: Se copian los ficheros que correspondan para las opciones 5 y 6
#
function entradaMemoriaRangosFichero_op_cinco_seis_Post_2 {
#ES_26940Borra el fichero de datos ultimo y escribe los datos en el fichero
    if [[ -f "$ficheroDatosAnteriorEjecucion" ]]; then
        rm $ficheroDatosAnteriorEjecucion
    fi
    if [[ -f "$ficheroRangosAnteriorEjecucion" && $seleccionMenuEleccionEntradaDatos -ne 5 ]]; then
        rm $ficheroRangosAnteriorEjecucion
    fi
#ES_26950Copia los ficheros Default/Último       
    if [[ $seleccionMenuEleccionEntradaDatos -ne 5 ]]; then
#ES_26960Copia los ficheros Default/Último       
    fi
#ES_26970Fin de entradaMemoriaRangosFichero_op_cinco_seis_Post_2()

#
#ES_26980 Sinopsis: Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 7, 8 y 9. 
#
function entradaMemoriaRangosFichero_op_cuatro_cinco_seis_Comun {                          
#ES_26990    clear   
    variableReubicar=$reub
#ES_27000----------------Empieza a introducir procesos------------         
    proc=$(($p-1))
    if [[ $((p + 1)) -ge 10 ]]; then
        nombre="P$((p + 1))"
    else
        nombre="P0$((p + 1))" 
    fi
#ES_27010Se añade el nombre del proceso al vector
#ES_27020Se guarda su número en un vector para la función que lo ordena
    calcDatoAleatorioGeneral $MIN_RANGE_llegada $MAX_RANGE_llegada
#ES_27030Se añade el tiempo de llegada al vector
    calcDatoAleatorioGeneral $MIN_RANGE_tiempo_ejec $MAX_RANGE_tiempo_ejec
#ES_27040Se añade el tiempo de ejecución al vector
    calcDatoAleatorioGeneral $MIN_RANGE_tamano_marcos_proc $MAX_RANGE_tamano_marcos_proc
#ES_27050Se añade el tamaño de ejecución al vector
    calcDatoAleatorioGeneral $prio_menor $prio_mayor
#ES_27060Se añade la prioridad del proceso al vector
#ES_27070Se crea otra variable para hacer compatible este código con otro código anterior.
    
#ES_27080Se definen las Direcciones de cada Proceso
#ES_27090Para ser equivalente al nuevo programa 
#ES_27100Primero se calcula el tamaño en direcciones del proceso.
	tamano_direcciones_proc=$datoAleatorioGeneral
	for (( numdir = 0; numdir <= ${ejecucion[$p]}; numdir++ )); do
#ES_27110Luego se calculan las direcciones aplicando la búsqueda aleatoria hasta el tamaño en direcciones dle proceso precalculado.
		directions[$p,$numdir]=$datoAleatorioGeneral
#ES_27120$numDireccionesTotales_max viene de leer_rangos_desde_fichero() y se comparará con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.
			echo -e "\n***Error en la lectura de rangos. La dirección de memoria utilizada ("${directions[$p,$numdir]}") está fuera del rango máximo definido por el número de marcos de página ("$(($numDireccionesTotales_max - 1))")."
			exit 1 
		fi
#ES_27130let pagTransformadas[$2]=`expr $1/$mem_direcciones`
		paginasDefinidasTotal[$p,$numdir]=${pagTransformadas[$numdir]} 
	done
#ES_27140Fin de entradaMemoriaRangosFichero_op_cuatro_cinco_seis_Comun()
            
#ES_27150 
#ES_27160 Sinopsis: Pregunta en qué fichero guardar los rangos para la opción 8.
#
function entradaMemoriaRangosFichero_op_siete_Previo {
#ES_27170    clear 
#ES_27180Resuelve los nombres de los ficheros de rangos amplios
#ES_27190Resuelve los nombres de los ficheros de rangos
#ES_27200Resuelve los nombres de los ficheros de datos
#ES_27210Fin de entradaMemoriaRangosFichero_op_siete_Previo()

#
#ES_27220 Sinopsis: Se piden y tratan los mínimos y máximos de los rangos para las opciones 7, 8 y 9. El cálculo de los datos 
#ES_27230 aleatorios con los que se trabajará se hace en entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun.  
#
function entradaMemoriaRangosFichero_op_siete_ocho_nueve { 
    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
#ES_27240Llamada a funciones para definir las variables con los límites de los rangos amplios.
    fi                     
#ES_27250Se definen nuevas variables para redefinir los límites de los subrangos sacados de los rangos amplios. 
	MIN_RANGE_MARCOSInicial=$datoAleatorioGeneral	
    calcDatoAleatorioGeneral $memoria_minInicial $memoria_maxInicial 
    MAX_RANGE_MARCOSInicial=$datoAleatorioGeneral
#ES_27260Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_MARCOS=$PriomFinal
	MAX_RANGE_MARCOS=$PrioMFinal
#ES_27270Se calculan los valores que no dependen de los procesos desde los subrangos ya calculados. 
	mem_total=$datoAleatorioGeneral

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_numero_direcciones_marco_amplio 
    fi                     
    calcDatoAleatorioGeneral $direcciones_minInicial $direcciones_maxInicial 
	MIN_RANGE_DIRECCIONESInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $direcciones_minInicial $direcciones_maxInicial 
    MAX_RANGE_DIRECCIONESInicial=$datoAleatorioGeneral
#ES_27280Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_DIRECCIONES=$PriomFinal
	MAX_RANGE_DIRECCIONES=$PrioMFinal
    calcDatoAleatorioGeneral $MIN_RANGE_DIRECCIONES $MAX_RANGE_DIRECCIONES
	mem_direcciones=$datoAleatorioGeneral
#ES_27290Dato usado para compararlo con la mayor dirección a ejecutar para saber si cabe en memoria No Virtual.

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_prio_menor_amplio 
    fi                     
#ES_27300Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#ES_27310Variables con los originales usadas para calcular subrangos y datos finales 
	prio_menor_max=$PrioMFinal
#ES_27320Prioridades asociadas a los procesos.
#ES_27330Desde este rango amplio se calculan los subrangos desde los que calcular el rango desde el que calcular los datos.
#ES_27340calcMaxPrioPro 
    MAX_RANGE_prio_menorInicial=$datoAleatorioGeneral          
#ES_27350Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_prio_menor=$PriomFinal
	MAX_RANGE_prio_menor=$PrioMFinal
#ES_27360Datos generales
#ES_27370Desde este subrango se calcula el rango desde el que calcular los datos.

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_prio_mayor_amplio 
    fi                     
#ES_27380Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	prio_mayor_min=$PriomFinal
	prio_mayor_max=$PrioMFinal
#ES_27390Prioridades asociadas a los procesos.
	MIN_RANGE_prio_mayorInicial=$datoAleatorioGeneral
#ES_27400calcMaxPrioPro 
    MAX_RANGE_prio_mayorInicial=$datoAleatorioGeneral          
#ES_27410Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_prio_mayor=$PriomFinal
	MAX_RANGE_prio_mayor=$PrioMFinal
#ES_27420Datos generales
	prio_mayorInicial=$datoAleatorioGeneral

#ES_27430Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#ES_27440Desde este rango se calculan los datos.
	prio_mayor=$PrioMFinal

#ES_27450Variables con los datos originales usadas en la cabecera de la representación de la tabla
	PrioMInicial=$prio_mayorInicial

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_tamano_reubicacion_amplio 
    fi                     
    calcDatoAleatorioGeneral $reubicacion_minInicial $reubicacion_maxInicial 
	MIN_RANGE_REUBInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $reubicacion_minInicial $reubicacion_maxInicial 
    MAX_RANGE_REUBInicial=$datoAleatorioGeneral
#ES_27460Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
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
#ES_27470Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
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
#ES_27480Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_llegada=$PriomFinal
	MAX_RANGE_llegada=$PrioMFinal

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_tiempo_ejecucion_amplio 
    fi                     
    calcDatoAleatorioGeneral $tiempo_ejec_minInicial $tiempo_ejec_maxInicial 
	MIN_RANGE_tiempo_ejecInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $tiempo_ejec_minInicial $tiempo_ejec_maxInicial 
    MAX_RANGE_tiempo_ejecInicial=$datoAleatorioGeneral
#ES_27490Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_tiempo_ejec=$PriomFinal
	MAX_RANGE_tiempo_ejec=$PrioMFinal
    
    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_tamano_marcos_procesos_amplio 
    fi                     
    calcDatoAleatorioGeneral $tamano_marcos_proc_minInicial $tamano_marcos_proc_maxInicial 
	MIN_RANGE_tamano_marcos_procInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $tamano_marcos_proc_minInicial $tamano_marcos_proc_maxInicial 
    MAX_RANGE_tamano_marcos_procInicial=$datoAleatorioGeneral
#ES_27500Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_tamano_marcos_proc=$PriomFinal
	MAX_RANGE_tamano_marcos_proc=$PrioMFinal

    if [[ $seleccionMenuEleccionEntradaDatos -eq 7 ]]; then   
		datos_quantum_amplio 
    fi                     
    calcDatoAleatorioGeneral $quantum_minInicial $quantum_maxInicial 
	MIN_RANGE_quantumInicial=$datoAleatorioGeneral
    calcDatoAleatorioGeneral $quantum_minInicial $quantum_maxInicial 
    MAX_RANGE_quantumInicial=$datoAleatorioGeneral
#ES_27510Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
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
#ES_27520Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
	MIN_RANGE_tamano_direcciones_proc=$PriomFinal
	MAX_RANGE_tamano_direcciones_proc=$PrioMFinal    
#ES_27530------------------------------------------------------ 
#ES_27540Se imprime una tabla con los datos de los rangos introducidos, los subrangos y los valores calculables.

#ES_27550    clear
    p=0
    until [[ $p -eq $n_prog ]]; do  
#ES_27560Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 7, 8 y 9. 
#ES_27570Guarda los datos en los ficheros que correspondan
#ES_27580        clear
#ES_27590Se incrementa el contador
#ES_27600cierre del do del while $pro=="S"
#ES_27610Copia los ficheros Default/Último
#ES_27620Fin de entradaMemoriaRangosFichero_op_siete_ocho_nueve()

#
#ES_27630 Sinopsis: Se guardarán los datos en los ficheros que corresponda para la opción 4
#
function entradaMemoriaRangosFichero_op_siete_ocho_nueve_Post_1 { 
#ES_27640No se establece desde fichero sino que se decide en el momento de la ejecución mediante la variable de selección de tipo $seleccionTipoPrioridad.
#ES_27650M/m
		PrioR="Mayor"
	else    
		PrioR="Menor"                
	fi              
	if [[ $p -eq 0 ]]; then
		echo -ne "Marcos totales\n"$mem_total"\nTamano de pagina\n"$mem_direcciones"\nPrioridad menor\n"$prio_menorInicial\
		"\nPrioridad mayor\n"$prio_mayorInicial"\nTipo de prioridad\n"$PrioR "\nMinimo para reubicabilidad\n"$reub"\nQuantum\n"$quantum\
		"\nTll nMar Prio Direcciones:\n" > $nomFicheroDatos
	fi                  

#ES_27660Hace que las direcciones sean diferentes en cada proceso.
#ES_27670Se usarán para determinar de forma aleatoria si una página es o no modificada al ser ejecutada en los algoritmos NFU y NRU.
	MAX_RANGE_PAGINA_MODIFICADA=1
#ES_27680Muestra las direcciones del proceso calculadas de forma aleatoria.
#ES_27690Se calcula de forma aleatoria si una página es o no modificada al ser ejecutada.
#ES_27700Se almacena el cálculo aleatorio de si una página es o no modificada al ser ejecutada.
		direccionesAcumuladas+=`echo -ne " ${directions[$p,$numdir]}-${directions_AlgPagFrecUsoRec_pagina_modificada[$p,$numdir,0]}"`
	done
	echo -e ${llegada[$p]} ${memoria[$p]} ${prioProc[$p]} $direccionesAcumuladas >> $nomFicheroDatos

#ES_27710Escribe los rangos en el fichero de rangos selecionado (RangosAleTotalDefault.txt, o el elegido por el usuario). 
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
#ES_27720Cierre if $p -eq 1 
#ES_27730Escribe los rangos en el fichero de rangos amplios selecionado 
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
#ES_27740Cierre if $p -eq 1
#ES_27750Fin de entradaMemoriaRangosFichero_op_siete_Post_1()

#
#ES_27760 Sinopsis: Se copian los ficheros que correspondan para la opción 4
#
function entradaMemoriaRangosFichero_op_siete_ocho_nueve_Post_2 { 
#ES_27770Borra el fichero de datos ultimo y escribe los datos en el fichero
        rm $ficheroDatosAnteriorEjecucion
    fi
#ES_27780Borra el fichero de datos ultimo y escribe los rangos en el fichero
        rm $ficheroRangosAnteriorEjecucion
    fi
    cp $nomFicheroDatos $ficheroDatosAnteriorEjecucion
    cp $nomFicheroRangos $ficheroRangosAnteriorEjecucion
#ES_27790Actualiza el fichero de rangos amplios de última ejecución (RangosAleTotalLast.txt) como copia del fichero utilizado para los rangos amplios (RangosAleTotalDefault.txt, o el elegido por el usuario).
#ES_27800Borra el fichero de datos ultimo y escribe los rangos amplios en el fichero
			rm $ficheroRangosAleTotalAnteriorEjecucion
		fi
		cp $nomFicheroRangosAleT $ficheroRangosAleTotalAnteriorEjecucion        
    fi
#ES_27810Fin de entradaMemoriaRangosFichero_op_siete_Post_2()
           
#
#ES_27820 Sinopsis: Pregunta en qué fichero guardar los rangos para la opción 8.
#
function entradaMemoriaRangosFichero_op_ocho_Previo {
#ES_27830    clear
#ES_27840Resuelve los nombres de los ficheros de rangos
#ES_27850Resuelve los nombres de los ficheros de datos
#ES_27860Fin de entradaMemoriaRangosFichero_op_ocho_Previo()

#
#ES_27870 Sinopsis: Pregunta en qué fichero guardar los rangos amplios para la opción 9.
#
function entradaMemoriaRangosFichero_op_nueve_Previo {
#ES_27880    clear
#ES_27890Resuelve los nombres de los ficheros de rangos
#ES_27900Resuelve los nombres de los ficheros de datos
    echo -e "\n\nFicheros existentes:\n$NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\nFicheros existentes:\n" >> $informeSinColorTotal  
    files=("./FRangosAleT"/*)
#ES_27910Localiza en qué posición encuentra el dato (da la posición, pero no la variable en el array)
#ES_27920Define el dato, pero no en qué posción se encuentra.
        echo -e "$i) ${files[$i]}" | tee -a $informeConColorTotal
        echo -e "$i) ${files[$i]}" >> $informeSinColorTotal  
    done
    echo -e "\n$AMARILLO\n\nIntroduce el número correspondiente al fichero elegido: $NORMAL" | tee -a $informeConColorTotal
    echo -e "\n\n\nIntroduce el número correspondiente al fichero elegido: " >> $informeSinColorTotal 
    read -r numeroFichero
#ES_27930files[@]} ]]; do
        echo -ne "Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
        echo -ne "Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
        read -r numeroFichero
        echo -e "$numeroFichero\n\n" >> $informeConColorTotal
        echo -e "$numeroFichero\n\n" >> $informeSinColorTotal
    done
    echo "$numeroFichero" >> $informeConColorTotal
    echo "$numeroFichero" >> $informeSinColorTotal
    ficheroParaLectura="${files[$numeroFichero]}"
#ES_27940    clear
#ES_27950Fin de entradaMemoriaRangosFichero_op_nueve_Previo()

#
#ES_27960 Sinopsis: Se calculan los valores aleatorios y los datos con los que se trabajará para las opciones 7, 8 y 9. 
#
function entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun {                          
#ES_27970    clear   
    variableReubicar=$reub
#ES_27980------------------------------Empieza a introducir procesos--------------------            
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
#ES_27990Se añade a el vector ese nombre
#ES_28000Se guarda su número en un vector para la función que lo ordena
#ES_28010 Generar un número aleatorio dentro del rango
#ES_28020 Generar un número aleatorio dentro del rango
#ES_28030 Generar un número aleatorio dentro del rango

    calcDatoAleatorioGeneral $prio_menor $prio_mayor
#ES_28040Sobra uno
#ES_28050Se añade el tamaño de ejecución al vector

#ES_28060Se definen las Direcciones de cada Proceso
#ES_28070Para ser equivalente al nuevo programa
#ES_28080Primero se calcula el tamaño en direcciones del proceso.
	tamano_direcciones_proc=$datoAleatorioGeneral
	for (( numdir = 0; numdir <= ${ejecucion[$p]}; numdir++ )); do
#ES_28090Luego se calculan las direcciones aplicando la búsqueda aleatoria hasta el tamaño en direcciones dle proceso precalculado.
		directions[$p,$numdir]=$datoAleatorioGeneral
#ES_28100$numDireccionesTotales_max viene de leer_rangos_desde_fichero() y se comparará con las direcciones definidas, ya que las direcciones deben ser menores en el caso de memoria No Virtual.
			echo -e "\n***Error en la lectura de rangos amplios. La dirección de memoria utilizada ("${directions[$p,$numdir]}") está fuera del rango máximo definido por el número de marcos de página ("$(($numDireccionesTotales_max - 1))")."
			exit 1
		fi
#ES_28110let pagTransformadas[$2]=`expr $1/$mem_direcciones`
		paginasDefinidasTotal[$p,$numdir]=${pagTransformadas[$numdir]} 
	done
#ES_28120Fin de entradaMemoriaRangosFichero_op_siete_ocho_nueve_Comun()

#
#ES_28130 Sinopsis: Calcula los datos de la tabla resumen de procesos en cada volcado
#
#ES_28140ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAR LAS VARIABLES.
#ES_28150Modificamos los valores de los arrays, restando de lo que quede
        if [[ ${enejecucion[$i]} -eq 1 ]]; then  
            temp_rej[$i]=`expr ${temp_rej[$i]} - 1`
#ES_28160Se suman para evitar que en el último segundo de ejecución no se sume el segundo de retorno
        fi
#ES_28170estado[$i]="Bloqueado" - En espera
            temp_wait[$i]=`expr ${temp_wait[$i]} + 1`
            temp_ret[$i]=`expr ${temp_ret[$i]} + 1`
        fi
#ES_28180estado[$i]="En ejecucion"
            temp_wait[$i]=`expr ${temp_wait[$i]} + 0`
#ES_28190estado[$i]="En pausa" - En pausa
            temp_wait[$i]=`expr ${temp_wait[$i]} + 1`
            temp_ret[$i]=`expr ${temp_ret[$i]} + 1`
#ES_28200estado[$i]="En memoria"
            temp_wait[$i]=`expr ${temp_wait[$i]} + 1`
            temp_ret[$i]=`expr ${temp_ret[$i]} + 1`
        fi
#ES_28210Si ha terminado, no se hace nada. Y si no ha llegado, su tiempo de espera es "-"
#ES_28220Se ponen todas las posiciones del vector enejecucion a 0, se establecerá qué proceso está a 1 en cada ciclo del programa.
#ES_28230Se desbloquean todos y se establecerán los procesos bloqueados en cada ciclo.
    done
#ES_28240 Se incrementa el reloj
#ES_28250Final de los cálculos para dibujar la banda de tiempos - ajusteFinalTiemposEsperaEjecucionRestante

#
#ES_28260 Sinopsis: Se muestran los eventos sucedidos, sobre la tabla resumen.
#
function mostrarEventos {
#ES_28270    clear
#ES_28280Inicializo evento
#ES_28290Se muestran los datos sobre las indicaciones del evento que ha sucedido
    Dato1=""
    Dato2=""
    Dato3=""
#ES_28300Paginado pero No Virtual
        algoritmoSeleccionado="FCFS-PaginaciónNoVirtual-"
#ES_28310FCFS/SJF/SRPT
        algoritmoSeleccionado="FCFS-Paginación-"
    elif [[ $seleccionMenuAlgoritmoGestionProcesos -eq 2 ]]; then    
        algoritmoSeleccionado="SJF-Paginación-"
    elif [[ $seleccionMenuAlgoritmoGestionProcesos -eq 3 ]]; then    
        algoritmoSeleccionado="SRPT-Paginación-" 
    elif [[ $seleccionMenuAlgoritmoGestionProcesos -eq 4 ]]; then    
        algoritmoSeleccionado="Prioridades-"    
#ES_28320M/m
			algoritmoSeleccionado+="Mayor-"
		else    
			algoritmoSeleccionado+="Menor-"                
		fi              
#ES_28330M/m
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
#ES_28340C/NC
        continuidadSeleccionado="NC-"
    else    
        continuidadSeleccionado="C-"                
    fi
#ES_28350R/NR
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
#ES_28360Se muestra el evento que ha sucedido       
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisosalida[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha salido de memoria." | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha salido de memoria." >> $informeSinColorTotal
#ES_28370Se borra el uno para que no se vuelva a imprimir 
        fi
    done
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisollegada[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha llegado al sistema." | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha llegado al sitema." >> $informeSinColorTotal
#ES_28380Se borra el uno para que no se vuelva a imprimir 
        fi
    done
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisoentrada[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha entrado de memoria. " | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha entrado en memoria." >> $informeSinColorTotal
#ES_28390Se borra el uno para que no se vuelva a imprimir 
        fi
    done
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisoEntradaCPU[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha entrado en CPU. " | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha entrado en CPU." >> $informeSinColorTotal
#ES_28400Se borra el uno para que no se vuelva a imprimir 
        fi
    done
    for ((l=0 ;l<nprocesos; l++)); do
        if [[ ${avisoPausa[$l]} -eq 1 ]]; then
            echo -e " El proceso$NC ${varC[$l]}${proceso[$l]}$NC ha quedado en pausa. " | tee -a $informeConColorTotal
            echo -e " El proceso ${proceso[$l]} ha quedado en pausa." >> $informeSinColorTotal
#ES_28410Se borra el uno para que no se vuelva a imprimir 
        fi
    done
#ES_28420Fin de mostrarEventos() - Final de mostrar los eventos sucedidos - mostrarEventos

#
#ES_28430 Sinopsis: Prepara e imprime la tabla resumen de procesos en cada volcado - SIN CUADRO
#
function dibujarTablaDatos {
    mem_aux=$[ $mem_total -1 ]
    j=0
    k=0
    for (( i=0; i<$nprocesos; i++ )); do
        if [[ ${enmemoria[$i]} -eq 1 ]]; then
#ES_28440Se guardan en cada posición el número del proceso correspondiente 
            coloresAux[$k]=${coloress[$i % 6]} 
            j=`expr $j + 1`
        fi
        k=`expr $k + 1`
    done
    j=0
    k=0
#ES_28450CALCULAR LOS DATOS A REPRESENTAR.
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
#ES_28460No llegado
            inicio2[$i]="-"
            final2[$i]="-" 
            temp_wait[$i]="-"
            temp_ret[$i]="-"
            temp_rej[$i]="-"
            estado[$i]="Fuera del Sistema"
#ES_28470En espera
            inicio2[$i]="-"
            final2[$i]="-"
            estado[$i]="En espera"
#ES_28480En memoria
            estado[$i]="En memoria"
#ES_28490En ejecucion
            estado[$i]="En ejecución"
#ES_28500En ejecucion
            estado[$i]="En pausa"
#ES_28510Finalizado
            inicio2[$i]="-"
            final2[$i]="-" 
            temp_rej[$i]="-"
            estado[$i]="Finalizado"
        fi
            varC[$i]=${coloress[$i % 6]}
    done

#ES_28520REPRESENTAR LOS DATOS
#ES_28530Se ajusta a parte el vector de memoria inicial y final NO CONTINUA para CUADRAR (he comentado lo que cuadraba lo de antes)(modificación 2020)
#ES_28540Ajuste para la memoria no continua en un auxiliar (se imprime el auxiliar)
#ES_28550Se copia los normales al auxiliar
    inicialNCaux=("${inicialNC[@]}")
    finalNCaux=("${finalNC[@]}")
 	datos4=""
#ES_28560Si han sido usadas, se subrayan
		datos4="-Modificación"
	fi

#ES_28570Para Prioridades
		echo -e " Ref Tll Tej Mem Pri TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " | tee -a $informeConColorTotal   
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────────" | tee -a $informeConColorTotal
		echo -e " Ref Tll Tej Mem Pri TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " >> $informeSinColorTotal
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────────" >> $informeSinColorTotal
#ES_28580Se aplica el $m a memoria inicial y memoria final (los auxiliares que son los que se imprimen en el volcado)
#ES_28590Se usa m porque i recorre los procesos y m controla las unidades usadas por cada proceso, normalmente 0 o 1, y también las unidades de los n trozos de memoria asociados a cada proceso. 
			echo -ne " ${varC[$i]}${proceso[$i]}$NC"\
#ES_28600ejecucion[$i]})${varC[$i]}${ejecucion[$i]}$NC"\
#ES_28610prioProc[$i]})${varC[$i]}${prioProc[$i]}$NC"\
#ES_28620temp_ret[$i]})${varC[$i]}${temp_ret[$i]}$NC"\
#ES_28630inicialNCaux[$m]})${varC[$i]}${inicialNCaux[$m]}$NC"\
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
			DireccionesPaginasPorProceso=""
#ES_28650Subrayado
			datos4=""
			for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then 
					datos4="-"${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				fi
#ES_28660Si han sido usadas, se subrayan
					kk=" $varImprimirPaginaUsada${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4$NC"
					DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$i]}$varImprimirPaginaUsada${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4$NC"
				else
					DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$i]}${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4"
				fi
			done
			echo -e $DireccionesPaginasPorProceso | tee -a $informeConColorTotal
			echo -ne " ${proceso[$i]}"\
#ES_28670ejecucion[$i]})${ejecucion[$i]}"\
#ES_28680prioProc[$i]})${prioProc[$i]}}"\
#ES_28690temp_ret[$i]})${temp_ret[$i]}"\
#ES_28700inicialNCaux[$m]})${inicialNCaux[$m]}"\
#ES_28710estado[$i]}) " >> $informeSinColorTotal
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
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_28740inicialNCaux[$m]})${inicialNCaux[$m]} " >> $informeSinColorTotal
#ES_28750finalNCaux[$m]})${finalNCaux[$m]}                   " >> $informeSinColorTotal
				m=$((m+1))
			done
		done
#ES_28760Para Round-Robin 
		echo -e " Ref Tll Tej Mem TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " | tee -a $informeConColorTotal   
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────" | tee -a $informeConColorTotal
		echo -e " Ref Tll Tej Mem TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " >> $informeSinColorTotal
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────" >> $informeSinColorTotal
#ES_28770Se aplica el $m a memoria inicial y memoria final (los auxiliares que son los que se imprimen en el volcado)
#ES_28780Se usa m porque i recorre los procesos y m controla las unidades usadas por cada proceso, normalmente 0 o 1, y también las unidades de los n trozos de memoria asociados a cada proceso. 
			echo -ne " ${varC[$i]}${proceso[$i]}$NC"\
#ES_28790ejecucion[$i]})${varC[$i]}${ejecucion[$i]}$NC"\
#ES_28800temp_wait[$i]})${varC[$i]}${temp_wait[$i]}$NC"\
#ES_28810temp_rej[$i]})${varC[$i]}${temp_rej[$i]}$NC"\
#ES_28820finalNCaux[$m]})${varC[$i]}${finalNCaux[$m]}$NC"\
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
			DireccionesPaginasPorProceso=""
#ES_28840Subrayado
			datos4=""
			for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then 
					datos4="-"${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				fi
#ES_28850Si han sido usadas, se subrayan
					kk=" $varImprimirPaginaUsada${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4$NC"
					DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$i]}$varImprimirPaginaUsada${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4$NC"
				else
					DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$i]}${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4"
				fi
			done
			echo -e $DireccionesPaginasPorProceso | tee -a $informeConColorTotal
		   
			echo -ne " ${proceso[$i]}"\
#ES_28860ejecucion[$i]})${ejecucion[$i]}"\
#ES_28870temp_wait[$i]})${temp_wait[$i]}"\
#ES_28880temp_rej[$i]})${temp_rej[$i]}"\
#ES_28890finalNCaux[$m]})${finalNCaux[$m]}"\
#ES_28900estado[$i]}) " >> $informeSinColorTotal
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
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_28930inicialNCaux[$m]})${inicialNCaux[$m]} " >> $informeSinColorTotal
#ES_28940finalNCaux[$m]})${finalNCaux[$m]}                   " >> $informeSinColorTotal
				m=$((m+1))
			done
		done
#ES_28950Para FCFS/SJF/SRPT 
		echo -e " Ref Tll Tej Mem TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " | tee -a $informeConColorTotal   
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────" | tee -a $informeConColorTotal
		echo -e " Ref Tll Tej Mem TEsp Tret Trej Mini Mfin Estado            Direcciones-Página$datos4   " >> $informeSinColorTotal
		echo -e " ────────────────────────────────────────────────────────────────────────────────────────" >> $informeSinColorTotal
#ES_28960Se aplica el $m a memoria inicial y memoria final (los auxiliares que son los que se imprimen en el volcado)
#ES_28970Se usa m porque i recorre los procesos y m controla las unidades usadas por cada proceso, normalmente 0 o 1, y también las unidades de los n trozos de memoria asociados a cada proceso. 
			echo -ne " ${varC[$i]}${proceso[$i]}$NC"\
#ES_28980ejecucion[$i]})${varC[$i]}${ejecucion[$i]}$NC"\
#ES_28990temp_wait[$i]})${varC[$i]}${temp_wait[$i]}$NC"\
#ES_29000temp_rej[$i]})${varC[$i]}${temp_rej[$i]}$NC"\
#ES_29010finalNCaux[$m]})${varC[$i]}${finalNCaux[$m]}$NC"\
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
			DireccionesPaginasPorProceso=""
#ES_29030Subrayado
			datos4=""
			for ((counter2=0;counter2<${ejecucion[$i]};counter2++)); do
				if [[ $seleccionAlgoritmoPaginacion -eq 10 || $seleccionAlgoritmoPaginacion -eq 11 || $seleccionAlgoritmoPaginacion -eq 16 || $seleccionAlgoritmoPaginacion -eq 17 ]]; then 
					datos4="-"${directions_AlgPagFrecUsoRec_pagina_modificada[$i,$counter2,0]}
				fi
#ES_29040Si han sido usadas, se subrayan
					kk=" $varImprimirPaginaUsada${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4$NC"
					DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$i]}$varImprimirPaginaUsada${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4$NC"
				else
					DireccionesPaginasPorProceso=$DireccionesPaginasPorProceso" ${varC[$i]}${directions[$i,$counter2]}-${paginasDefinidasTotal[$i,$counter2]}$datos4"
				fi
			done
			echo -e $DireccionesPaginasPorProceso | tee -a $informeConColorTotal
		   
			echo -ne " ${proceso[$i]}"\
#ES_29050ejecucion[$i]})${ejecucion[$i]}"\
#ES_29060temp_wait[$i]})${temp_wait[$i]}"\
#ES_29070temp_rej[$i]})${temp_rej[$i]}"\
#ES_29080finalNCaux[$m]})${finalNCaux[$m]}"\
#ES_29090estado[$i]}) " >> $informeSinColorTotal
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
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_29120inicialNCaux[$m]})${inicialNCaux[$m]} " >> $informeSinColorTotal
#ES_29130finalNCaux[$m]})${finalNCaux[$m]}                   " >> $informeSinColorTotal
				m=$((m+1))
			done
		done
	fi

#ES_29140CALCULAR Y REPRESENTAR LOS PROMEDIOS
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
#ES_29150Si el tamaño del proceso es menor o igual que el de memoria
#ES_29160suma para sacar su promedio
#ES_29170promedio
#ES_29180suma para sacar su promedio
#ES_29190promedio
        fi
    done
    var_uno=1
    echo -e "$NC T. espera medio: $promedio_espera\t      T. retorno medio: $promedio_retorno$NC" | tee -a $informeConColorTotal 
    echo -e " T. espera medio: $promedio_espera\t       T. retorno medio: $promedio_retorno" >> ./$informeSinColorTotal
#ES_29200Fin de dibujarTablaDatos() - Final de dibujar la banda de tiempos - dibujarTablaDatos

#
#ES_29210 Sinopsis: Sacar procesos terminados de memoria y actualizar variables de la Banda de Memoria.
#
function calculosActualizarVariablesBandaMemoria {
#ES_29220Sucesión: sacar procesos, actualizar variables de memoria guardadoMemoria y tamanoGuardadoMemoria
#ES_29230Se libera espacio en memoria de los procesos recien terminados. 
        if [[ ${enmemoria[$po]} == 0 && ${escrito[$po]} == 1 ]]; then 
            for (( ra=0; ra<$mem_total; ra++ )); do
                if [[ ${unidMemOcupadas[$ra]} == $po ]]; then
                    unidMemOcupadas[$ra]="_" 
                fi
            done
            escrito[$po]=0
        fi
    done
#ES_29240Si los procesos ya no están en memoria se eliminan de la variable guardadoMemoria.
        if [[ ${enmemoria[$po]} -ne 1 ]]; then 
#ES_29250guardadoMemoria[@]} ; i++ )); do 
                if [[ ${guardadoMemoria[$i]} -eq $po ]]; then
                    unset guardadoMemoria[$i]
                    unset tamanoGuardadoMemoria[$i]
                fi
            done
        fi
    done
#ES_29260Se eliminan los huecos vacíos que genera el unset
#ES_29270Se eliminan los huecos vacíos que genera el unset
#ES_29280Fin de calculosActualizarVariablesBandaMemoria()

#
#ES_29290 Sinopsis: Se realizan los cálculos necesarios para la impresión de la banda de memoria en los volcados.
#
function calculosReubicarYMeterProcesosBandaMemoria {
#ES_29300Sucesión: Se genera una lista secuencial de procesos en guardadoMemoria y tamanoGuardadoMemoria, se comprueba si hay espacio suficiente en la memoria dependiendo de la continuidad y reubicabilidad definidas, y si lo hay, se mete el proceso.
    if [[ $mem_libre -gt 0 ]]; then 
#ES_29310Si hay que reubicar, se hace.
#ES_29320Se reubican los procesos existentes en la memoria en el mismo orden.
#ES_29330ud contador que guarda las unidades que se van guardando (ud < total)
                ra=0
#ES_29340Se reescriben todos los números de proceso en unidMemOcupadasAux (menor y no menor o igual, ya que se empieza en 0) 
#ES_29350Se marca con el proceso que ocupa la posición de memoria.
                        unidMemOcupadasAux[$ra]=${guardadoMemoria[$gm]}  
                        ud=$((ud+1))
                    fi
#ES_29360Se marca que ya se ha escrito en memoria.
                    ra=$((ra+1))
	             done
            done
#ES_29370Se copia la memoria auxiliar a la original para que se después se escriba en memoria.
#ES_29380Notificamos que se ha reubicado.
            echo -e " La memoria ha sido reubicada." $NC | tee -a $informeConColorTotal
            echo -e " La memoria ha sido reubicada." >> $informeSinColorTotal
        fi
    fi
#ES_29390Fin de calculosReubicarYMeterProcesosBandaMemoria()

#
#ES_29400 Sinopsis: Determina si el rango es de menor a mayor y si no lo es, lo modifica para convertir el problema con las prioridades invertidas, porque el código sólo resuelve ese caso.
#
function tratarRangoPrioridadesDirecta {
#ES_29410Será 1 cuando se determine un rango de prioridades cuyo mínimo sea mayor que su máximo.
    if [[ $1 -gt $2 ]]; then 
		aux=$1
		PriomFinal=$2
		PrioMFinal=$aux
#ES_29420Será 1 cuando se determine un rango de prioridades cuyo mínimo sea mayor que su máximo.
    else
		PriomFinal=$1
		PrioMFinal=$2
    fi
#ES_29430Fin de calculosReubicarYMeterProcesosBandaMemoria()

#
#ES_29440 Sinopsis: Guardar los procesos que van entrando en memoria de forma secuencial en la variable guardadoMemoria 
#ES_29450 y sus tamaños en tamanoGuardadoMemoria   
#
function crearListaSecuencialProcesosAlEntrarMemoria {
#ES_29460Vaciamos el array anterior
#ES_29470Vaciamos el array anterior
#ES_29480Determinará qué procesos están en memoria.
        if [[ ${unidMemOcupadas[$ra]} != "_" ]]; then
            numeroProbar=${unidMemOcupadas[$ra]}
            permiso=1
#ES_29490Si el proceso ya está en memoria, no hace falta meterlo.
                if [[ ${guardadoMemoria[$i]} -eq $numeroProbar ]]; then
                    permiso=0
                fi
            done
#ES_29500Permiso es la variable que permite meter un proceso en memoria porque haya espacio suficiente.
#ES_29510Guarda el número de proceso que va a meter en memoria.
#ES_29520Guarda el tamaño del proceso que va a meter en memoria.
                permiso=0
            fi
        fi
    done
#ES_29530Fin de crearListaSecuencialProcesosAlEntrarMemoria()

#
#ES_29540 Sinopsis: Comprueba que cada hueco en memoria no es mayor que la variable definida, para decidir si se reubica. 
#
function comprobacionSiguienteProcesoParaReubicar {
#ES_29550Sucesión: Se determina qué proceso es el siguiente en entrar en memoria, y dependiendo de la continuidad y reubicabilidad definidas, se establece si hay espacio en memoria. 
#ES_29560Variable para no permitir meter procesos en memoria bajo ciertas condiciones relacionadas con la continuidad. 
    encontradoHuecoMuyReducido=0
    primeraUnidadFuturoProcesoSinreubicar=-1
    raInicioProceso=-1
#ES_29570En caso de ser memoria no continua, si hay un hueco demasiado pequeño, y se va a usar como parte de la memoria a usar.
#ES_29580En caso de ser memoria continua, si no hay un hueco suficientemente grande en el que quepa pero sí en la suma de todos ellos.
    contadorReubicar=-1
    contadorReubicarTotal=0
    siguienteProcesoAMeter=-1
#ES_29590Metemos un proceso y comprobamos si hay que reubicar 
#ES_29600Si está para entrar en memoria y no está dentro se mete, y si ya está dentro se ignora.
            siguienteProcesoAMeter=$po
            break
        fi 
    done
    if [[ $siguienteProcesoAMeter -eq -1 ]]; then
#ES_29610Metemos un proceso y comprobamos si hay que reubicar 
#ES_29620Si está para entrar en memoria y no está dentro se mete, y si ya está dentro se ignora.
                siguienteProcesoAMeter=$po
                break
            fi 
        done
    fi 
    if [[ $mem_libre -gt 0 ]]; then
        for (( ra=0; ra<$mem_total; ra++ )); do
            if [[ ${unidMemOcupadas[$ra]} == "_" && siguienteProcesoAMeter -gt -1 ]]; then
#ES_29630Se designa la primera unidad sobre la que meter el proceso si entrara en memoria continua.
                    contadorReubicar=0
                    raInicioProceso=$ra
                fi
                contadorReubicar=$((contadorReubicar + 1))
                contadorReubicarTotal=$((contadorReubicarTotal + 1))
                if [[ $contadorReubicar -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $primeraUnidadFuturoProcesoSinreubicar -eq -1 ]]; then 
#ES_296408 - Si cabe en un único hueco en memoria continua.
                    primeraUnidadFuturoProcesoSinreubicar=$raInicioProceso               
                    break
                fi
            elif [[ ${unidMemOcupadas[$ra]} != "_" && siguienteProcesoAMeter -ne -1 ]]; then
                if [[ $contadorReubicar -ne -1 && $contadorReubicar -le $variableReubicar && $reubicabilidadNo0Si1 -eq 1 ]]; then 
#ES_29650Si encuentra un hueco demasiado pequeño mientras busca hueco suficiente y puede caber en la totalidad de los huecos, en memoria no continua.
                    encontradoHuecoMuyReducido=1
                fi
                contadorReubicar=-1
            fi
        done
#ES_29660No necesario 
#ES_296701 - 3 - 6 - 9 - No cabe - Ya se considera cuando se resta el tamaño de memoria del proceso a introducir (memoriaAuxiliar[$siguienteProcesoAMeter]) de la memoria libre (mem_libre) y comprueba >=0 en comprobacionSiguienteProcesoParaMeterMemoria()
#ES_29680            noCabe0Cabe1=0 
#ES_29690            reubicarContinuidad=0
#ES_29700            reubicarReubicabilidad=0
#ES_29710        fi
#ES_29720No necesario
#ES_297302 - Lo meterá en memoria a trozos.
#ES_29740            noCabe0Cabe1=1
#ES_29750            reubicarContinuidad=0
#ES_29760            reubicarReubicabilidad=0
#ES_29770        fi
#ES_29780No necesario
#ES_297904 - 
#ES_29800            noCabe0Cabe1=1
#ES_29810            reubicarContinuidad=0
#ES_29820            reubicarReubicabilidad=0
#ES_29830        fi
#ES_29840No necesario
#ES_298507 - 
#ES_29860            noCabe0Cabe1=0 - No cabe - Ya se considera cuando se resta el tamaño de memoria del proceso a introducir (memoriaAuxiliar[$siguienteProcesoAMeter]) de la memoria libre (mem_libre) y comprueba >=0 en comprobacionSiguienteProcesoParaMeterMemoria()
#ES_29870            reubicarContinuidad=0
#ES_29880            reubicarReubicabilidad=0
#ES_29890        fi
#ES_29900No necesario
#ES_299108 - 
#ES_29920            noCabe0Cabe1=1
#ES_29930            reubicarContinuidad=0
#ES_29940            reubicarReubicabilidad=0
#ES_29950        fi
#ES_29960No necesario
#ES_2997010 - 
#ES_29980            noCabe0Cabe1=1
#ES_29990            reubicarContinuidad=0
#ES_30000            reubicarReubicabilidad=0
#ES_30010        fi
        if [[ $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorReubicarTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $encontradoHuecoMuyReducido -eq 1 && $continuidadNo0Si1 -eq 0 && $reubicabilidadNo0Si1 -eq 1 ]]; then 
#ES_300205 - Si encuentra un hueco demasiado pequeño mientras busca hueco suficiente y puede caber en un hueco, en memoria no continua.
        fi
        if [[ $primeraUnidadFuturoProcesoSinreubicar -gt -1 && $encontradoHuecoMuyReducido -eq 1 && $reubicabilidadNo0Si1 -eq 1 ]]; then 
#ES_3003011 - Si encuentra un hueco demasiado pequeño mientras busca hueco suficiente y puede caber en un hueco, en memoria no continua.
#ES_30040No haría falta, porque se metería, pero se considera. Y en caso de encontradoHuecoMuyReducido=0 ta,bién lo metería.
#
            if [[ $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorReubicarTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 1 ]] ; then
#ES_3005012 - Si no cabe en un único hueco, pero sí en la suma de ellos, en memoria continua.
            fi
        fi
#
            if [[ $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorReubicarTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 0 ]] ; then
#ES_300608 - Si no cabe en un único hueco, pero sí en la suma de ellos, en memoria continua.
            fi
        fi
    else
        noCabe0Cabe1=0
    fi
#ES_30070Memoria No Continua
#ES_30080Memoria No Reubicable
#ES_300901 - Si no cabe entre todos los huecos, no lo meterá en memoria.
#ES_301002 - OK - Si cabe entre todos los huecos, lo meterá en memoria a trozos.
#ES_30110Memoria Reubicable
#ES_301203 - Si no cabe entre todos los huecos, no reubica, ni lo meterá en memoria.
#ES_301304 - OK - Si cabe entre todos los huecos, y mientras busca no encuentra un hueco demasiado pequeño, no reubica y lo meterá en memoria a trozos.
#ES_301405 - Hecho - Si cabe entre todos los huecos, y mientras busca encuentra un hueco demasiado pequeño, reubica y lo meterá en memoria.
#ES_30150Memoria Continua
#ES_30160Memoria No Reubicable
#ES_301706 - Si no cabe entre todos los huecos, no lo meterá en memoria.
#ES_301807 - OK - Si cabe entre todos los huecos, pero no cabe en un único hueco, no lo meterá en memoria.
#ES_301908 - Hecho - Si cabe en un único hueco, lo meterá en memoria.
#ES_30200Memoria Reubicable
#ES_302109 - Si no cabe entre todos los huecos, no reubica, ni lo meterá en memoria.
#ES_3022010 - OK - Si cabe en un único hueco, y mientras busca no encuentra un hueco demasiado pequeño, no reubica y lo meterá en memoria.
#ES_3023011 - Hecho - Si cabe en un único hueco, y mientras busca encuentra un hueco demasiado pequeño, reubica y lo meterá en memoria.
#ES_3024012 - Hecho - Si cabe entre todos los huecos, pero no en un único hueco, reubica y lo meterá en memoria.
#ES_30250Fin de comprobacionSiguienteProcesoParaReubicar()

#
#ES_30260 Sinopsis: Comprueba que cada hueco en memoria es suficiente para meter un proceso en memoria. 
#
function comprobacionSiguienteProcesoParaMeterMemoria {
    if [[ $mem_libre -gt 0 && reubicarReubicabilidad -ne 1 && reubicarContinuidad -ne 1 ]]; then
        mem_libreTemp=$mem_libre
#ES_30270No se debería definir porque es un valor arrastrado desde la comprobación en comprobacionSiguienteProcesoParaReubicar()
#ES_30280El for se resuelve con i=$po de la línea anterior a la llamada de la función. 
#ES_30290Si están en cola pero no en memoria (en espera)
#ES_30300Variable para no permitir meter procesos en memoria bajo ciertas condiciones relacionadas con la continuidad. 
            encontradoHuecoMuyReducido=0
            raInicioProceso=-1
            contadorMeterMemoria=-1
            contadorMeterMemoriaTotal=0
            siguienteProcesoAMeter=$i
            if [[ $((mem_libreTemp - ${memoriaAuxiliar[$i]})) -ge 0 ]]; then
                noCabe0Cabe1=1
                for (( ra=0; ra<$mem_total; ra++ )); do
                    if [[ ${unidMemOcupadas[$ra]} == "_" && siguienteProcesoAMeter -gt -1 ]]; then
#ES_30310Se designa la primera unidad sobre la que meter el proceso si entrara en memoria continua.
                            contadorMeterMemoria=0
                            raInicioProceso=$ra
                        fi
                        contadorMeterMemoria=$((contadorMeterMemoria + 1))
                        contadorMeterMemoriaTotal=$((contadorMeterMemoriaTotal + 1))
                        if [[ $contadorMeterMemoria -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $primeraUnidadFuturoProcesoSinreubicar -eq -1 ]]; then 
#ES_303208 - Si cabe en un único hueco en memoria continua.
                            primeraUnidadFuturoProcesoSinreubicar=$raInicioProceso               
                        fi
                    elif [[ ${unidMemOcupadas[$ra]} != "_" && siguienteProcesoAMeter -ne -1 ]]; then
                        if [[ $contadorMeterMemoria -ne -1 && $contadorMeterMemoria -le $variableReubicar && $reubicabilidadNo0Si1 -eq 1 ]]; then 
#ES_30330Si encuentra un hueco demasiado pequeño mientras busca hueco suficiente y puede caber en la totalidad de los huecos, en memoria no continua.
                            encontradoHuecoMuyReducido=1
                        fi
                        contadorMeterMemoria=-1
                    fi
                done
#
                    if [[ $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorMeterMemoriaTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 0 ]] ; then
#ES_303408 - Si no cabe en un único hueco, pero sí en la suma de ellos, en memoria continua.
                    fi
                    if [[ $siguienteProcesoAMeter != -1 && $primeraUnidadFuturoProcesoSinreubicar -eq -1 && $contadorMeterMemoriaTotal -ge ${memoriaAuxiliar[$siguienteProcesoAMeter]} && $continuidadNo0Si1 -eq 1 && $reubicabilidadNo0Si1 -eq 0 ]] ; then
#ES_303508 - Si no cabe en un único hueco, pero sí en la suma de ellos, en memoria continua.
                    fi
                fi
#ES_30360Este if es fundamental para generar las excepciones sobres si se reubica o no, y sobre la unidad de memoria donde empezar a meter el proceso.
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
#ES_30370Bucle para bloquear los procesos
        bloqueados[$j]=1
    done
#ES_30380Memoria No Continua
#ES_30390Memoria No Reubicable
#ES_304001 - Si no cabe entre todos los huecos, no lo meterá en memoria.
#ES_304102 - OK - Si cabe entre todos los huecos, lo meterá en memoria a trozos.
#ES_30420Memoria Reubicable
#ES_304303 - Si no cabe entre todos los huecos, no reubica, ni lo meterá en memoria.
#ES_304404 - OK - Si cabe entre todos los huecos, y mientras busca no encuentra un hueco demasiado pequeño, no reubica y lo meterá en memoria a trozos.
#ES_304505 - Hecho - Si cabe entre todos los huecos, y mientras busca encuentra un hueco demasiado pequeño, reubica y lo meterá en memoria.
#ES_30460Memoria Continua
#ES_30470Memoria No Reubicable
#ES_304806 - Si no cabe entre todos los huecos, no lo meterá en memoria.
#ES_304907 - OK - Si cabe entre todos los huecos, pero no cabe en un único hueco, no lo meterá en memoria.
#ES_305008 - Hecho - Si cabe en un único hueco, lo meterá en memoria.
#ES_30510Memoria Reubicable
#ES_305209 - Si no cabe entre todos los huecos, no reubica, ni lo meterá en memoria.
#ES_3053010 - OK - Si cabe en un único hueco, y mientras busca no encuentra un hueco demasiado pequeño, no reubica y lo meterá en memoria.
#ES_3054011 - Hecho - Si cabe en un único hueco, y mientras busca encuentra un hueco demasiado pequeño, reubica y lo meterá en memoria.
#ES_3055012 - Hecho - Si cabe entre todos los huecos, pero no en un único hueco, reubica y lo meterá en memoria.
#ES_30560Fin de comprobacionSiguienteProcesoParaMeterMemoria()

#
#ES_30570 Sinopsis: Se realizan los cálculos necesarios para la impresión de la banda de memoria en los volcados.
#
function meterProcesosBandaMemoria {
#ES_30580Si está para entrar en memoria, y no está dentro se mete, y si ya está dentro se ignora.
        ud=0
        ra=0
#ES_30590Esto permite la continuidad en memoria al necesitar un tramo continuo de memoria y haberlo conseguido.
            ra=$primeraUnidadFuturoProcesoSinreubicar
        fi
#ES_30600Esto permite la no continuidad en memoria al no necesitar un tramo continuo de memoria.
            if [[ ${unidMemOcupadas[$ra]} == "_" ]]; then
                unidMemOcupadas[$ra]=$po
                ud=$((ud+1))
                mem_libre=$((mem_libre - 1))
            fi
#ES_30610Este proceso ya sólo estará en memoria, ejecutandose o habrá acabado
#ES_30620Se marca que ya está en memoria.
#ES_30630El ordinal del marco sobre el que se hará el primer fallo de página cuando se introduce un proceso en memoria, siempre será 0 por ser su primer marco libre.
#ES_30640Se define el primer instante a contemplar en cada proceso como el $reloj ya que será el instante en el que entra en memoria, y por tanto, el primer instante a referenciar para cada proceso.
            ra=$((ra+1))
        done
    fi
#ES_30650Fin de meterProcesosBandaMemoria()

#
#ES_30660 Sinopsis: Se preparan las líneas para la impresión de la banda de memoria en los volcados - NO Continua y Reubicabilidad.
#
function calculosPrepararLineasImpresionBandaMemoria {
#ES_30670Sucesión: Crear las tres líneas de la banda de memoria y se generan los bloques que componen la memoria usada por cada proceso en memoria.
#ES_30680Se calcula la línea de nombres - Línea 1
    arribaMemoriaNC="   |"
    arribaMemoriaNCb="   |"
#ES_30690Si el proceso está en la barra y no está nombrado se escribe. Si está nombrado se llena de _ para que el siguiente coincida con la línea de memoria.
    for (( ra=0; ra<$mem_total; ra++ )); do
#ES_30700Si la posición de memoria no está escrita, añades dígitos para completar los caracteres de la unidad, y la escribes.
        for (( po=0; po<$nprocesos; po++ )); do
            if [[ $ra -eq 0 && ${unidMemOcupadas[$ra]} == $po ]]; then 
#ES_30710proceso[$po]}))}"$NC
#ES_30720proceso[$po]}))}"
            fi
#ES_30730Si en una posición hay un proceso y antes algo distinto lo nombras
#ES_30740proceso[$po]}))}"$NC
#ES_30750proceso[$po]}))}"
#ES_30760Si es un proceso pero no es inicio pones barras bajas
                arribaMemoriaNC=$arribaMemoriaNC${coloress[$po % 6]}"${varhuecos:1:$digitosUnidad}"$NC
                arribaMemoriaNCb=$arribaMemoriaNCb"${varhuecos:1:$digitosUnidad}"
            fi
        done
#ES_30770Si es una barra baja (blanco) se llena de _ para seguir alineando.
        if [[ ${unidMemOcupadas[$ra]} == '_' ]]; then 
            arribaMemoriaNC=$arribaMemoriaNC"${varhuecos:1:$digitosUnidad}"$NC
            arribaMemoriaNCb=$arribaMemoriaNCb"${varhuecos:1:$digitosUnidad}"
        fi
    done

#ES_30780Se calcula la línea de banda - Línea 2
#ES_30790Lo vaciamos ya que cada volcado es diferente. Añadimos valores cada vez que se imprima un bloque
    barraMemoriaNC="BM |"
#ES_30800Para el color se usa esta variable ya que se cuentan los caracteres por línea y no se puede hacer con las secuencias de escape. Además se hace con "█" negros cuando no están siendo usados.
#ES_30810Para el fichero de blanco y negro se usa esta variable ya que se cuentan los caracteres por línea y no se puede hacer con las secuencias de escape. Además se hace con "-" cuando no están siendo usados. 
    coloresPartesMemoria=(" ${coloresPartesMemoria[@]}" "${coloress[97]}" "${coloress[97]}" "${coloress[97]}")
#ES_30820En $ra (recorre array) siempre va a haber o un proceso o una barra baja
#ES_30830Entonces hay guardado el número del 0-x de un proceso
            barraMemoriaNC=$barraMemoriaNC${coloress[${unidMemOcupadas[$ra]} % 6]}"${varfondos:1:$digitosUnidad}"$NC
            barraMemoriaNCbPantalla=$barraMemoriaNCbPantalla"${varfondos:1:$digitosUnidad}"
            colorunidMemOcupadas
        fi
#ES_30840Imprimir 3 blancos si hay una _
            barraMemoriaNC=$barraMemoriaNC" "${coloress[97]}"${varfondos:1:$digitosUnidad}"$NC
            barraMemoriaNCbPantalla=$barraMemoriaNCbPantalla"${varfondos:1:$digitosUnidad}"
            colorDefaultBMBT
        fi
    done

#ES_30850Se calcula la línea que escriba la posición de memoria - Línea 3
    abajoMemoriaNC="   |"
    abajoMemoriaNCb="   |"
    for (( ra=0; ra<$mem_total; ra++ )); do
#ES_30860Al final se escriben las unidades de comienzo de los procesos:
#ES_30870Si la posición de memoria está o no escrita, se escribe el 0 y se añaden dígitos para completar los caracteres de la unidad.
        if [[ $ra -eq 0 ]] ; then 
#ES_30880ra}))}"${coloress[$po % 6]}"$ra"$NC
#ES_30890ra}))}""$ra"
        fi
        for (( po=0; po<$nprocesos; po++ )); do
#ES_30900Si la posición de memoria no está escrita, añades dígitos para completar los caracteres de la unidad, y la escribes.
            if [[ $ra -ne 0 && ${unidMemOcupadas[$((ra-1))]} != $po  && ${unidMemOcupadas[$ra]} == $po ]] ; then 
#ES_30910ra}))}"${coloress[$po % 6]}"$ra"$NC
#ES_30920ra}))}""$ra"
#ES_30930Si la posición ya está escrita se añaden huecos para las siguientes unidades
            elif [[ $ra -ne 0 && ${unidMemOcupadas[$((ra-1))]} == $po  && ${unidMemOcupadas[$ra]} == $po ]] ; then 
                abajoMemoriaNC=$abajoMemoriaNC"${varhuecos:1:$digitosUnidad}"$NC
                abajoMemoriaNCb=$abajoMemoriaNCb"${varhuecos:1:$digitosUnidad}"
            fi
        done
#ES_30940Se escribe la posición de los primeros blancos de la misma manera salvo el 0 que ya está escrito.
#ES_30950Si la posición de memoria no está escrita se escribe y se añaden dos dígitos en blanco (completar 3 caract).
        if [[ $ra -ne 0 && ${unidMemOcupadas[$((ra-1))]} != "_" && ${unidMemOcupadas[$ra]} == "_" ]] ; then 
#ES_30960ra}))}"${coloress[97]}"$ra"$NC
#ES_30970ra}))}""$ra"
#ES_30980Posición ya escrita huecos SALVO en caso de que sea la posición 0 (que se escribe siempre si está vacía aunque el último hueco tenga algo).
#ES_30990Si es un proceso pero no es inicio pones barras bajas
            abajoMemoriaNC=$abajoMemoriaNC"${varhuecos:1:$digitosUnidad}"$NC
            abajoMemoriaNCb=$abajoMemoriaNCb"${varhuecos:1:$digitosUnidad}"
        fi
    done
    
#ES_31000Se calcula el número de bloques en los que se fragmentan los procesos.
#ES_31010Se determina is hay un proceso en la primera unidad de memoria y qué proceso es, y se define como primer bloque.
        bloques[$((unidMemOcupadas[0]))]=1
    fi
    for (( ra=1; ra<$mem_total; ra++ )); do
#ES_31020menor
            bloques[$((unidMemOcupadas[$ra]))]=$((bloques[$((unidMemOcupadas[$ra]))] + 1)) 
        fi
    done
#ES_31030Se cuenta el número de datos que tienen que tener los arrays posición inicial/final. Si bloques de algo equivale a 0 o 1, se suma 1. Si no, se suma el número de bloques.
#ES_31040El array de bloques tiene el mismo número de posiciones que el de procesos.
#ES_31050Una por proceso, est´´e o no en memoria, y una más por cada bloque añadido más allá del primero
#ES_31060Número de procesos
        else 
#ES_31070Número de bloques por proceso cuando tenga bloques
        fi
    done
#ES_31080Se inicializan a 0 (Sin bloques)
        inicialNC[$i]=0
        finalNC[$i]=0
    done
#ES_31090Se rellena
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
#ES_31100El primero es un caso especial
#ES_31110Si el proceso entra en memoria, guarda la unidad de inicio    
                        main=$((main+1))
                        contadori=$((contadori+1))
                    fi
                    if [[ $ra -ne 0  &&  ${unidMemOcupadas[$((ra - 1))]} != $po && ${unidMemOcupadas[$ra]} == $po ]] ; then
#ES_31120Si el proceso entra en memoria, guarda la unidad de inicio    
                        main=$((main+1))
                        contadori=$((contadori+1))
                    fi
                    if [[ $ra -ne 0  &&  $ra -ne $((mem_total-1)) && ${unidMemOcupadas[$ra]} == $po && ${unidMemOcupadas[$((ra + 1))]} != $po ]] ; then
#ES_31130Si el proceso entra en memoria, guarda la unidad de final
                        mafi=$((mafi+1))
                        contadorf=$((contadorf+1))
                    fi
#ES_31140El último es un caso especial
#ES_31150Si el proceso entra en memoria, guarda la unidad de final aunque no haya terminado el proceso. No debería ya que hubiera tenido que empezar en el primer hueco y le habría cabido.
                        mafi=$((mafi+1))
                        contadorf=$((contadorf+1))
                    fi
                done
            done
        fi
    done
#ES_31160Final de preparar líneas para Banda de Memoria - calculosPrepararLineasImpresionBandaMemoria()

#
#ES_31170 Sinopsis: Genera la Banda de Memoria y la muestra en pantalla/informe 
#
#ES_31180Nueva versión y más simplificada, pero tiene 100 líneas más que la versión original (dibujarBandaMemoriaORI)
#ES_31190Ancho del terminal para adecuar el ancho de líneas a cada volcado

#ES_31200 GENERACIÓN STRING DE PROCESOS (Línea 1 de la Banda de Memoria) 
#ES_31210Número de línea de la banda
    bandaProcesos=("    |")
    bandaProcesosColor=("$NORMAL    |")
    numCaracteres2=5
#ES_31220 Variable que indica si se ha añadido un proceso a la banda (1).
#ES_31230unidMemOcupadas[@]};ii++)); do
#ES_31240El proceso está en memoria y se imprimirá
#ES_31250El texto no cabe en la terminal
#ES_31260 Se pasa a la siguiente línea
                bandaProcesos[$nn]="     "
                bandaProcesosColor[$nn]="     "
                numCaracteres2=5
            fi
#ES_31270 El texto no cabe en la terminal
                xx=0
            fi
#ES_31280Se añade el proceso a la banda
#ES_31290proceso[$((${unidMemOcupadas[$ii]}))]}))}
                bandaProcesos[$nn]+=`echo -e "${proceso[$((${unidMemOcupadas[$ii]}))]}""$espaciosfinal"`
                bandaProcesosColor[$nn]+=`echo -e "${coloress[${unidMemOcupadas[$ii]} % 6]}${proceso[$((${unidMemOcupadas[$ii]}))]}""$NORMAL$espaciosfinal"`
                numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
                xx=1
            else
#ES_31300El texto no cabe en la terminal
#ES_31310Se pasa a la siguiente línea
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
#ES_31320El texto no cabe en la terminal
#ES_31330Se pasa a la siguiente línea
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
#ES_31340Añadir final de banda
#ES_31350El texto no cabe en la terminal
#ES_31360Se pasa a la siguiente línea
        bandaProcesos[$nn]="     "
        bandaProcesosColor[$nn]="     "
        numCaracteres2=5
    fi
    bandaProcesos[$nn]+=`echo -e "|"`
    bandaProcesosColor[$nn]+=`echo -e "$NORMAL|"`

#ES_31370 GENERACIÓN STRING DE MEMORIA (Línea 2 de la Banda de Memoria)
#ES_31380Línea de la banda
    bandaMemoria=(" BM |")
    bandaMemoriaColor=("$NORMAL BM |")
    numCaracteres2=5
    espaciosAMeter=${varfondos:1:$digitosUnidad}
    guionesAMeter=${varguiones:1:$digitosUnidad}
    asteriscosAMeter=${varasteriscos:1:$digitosUnidad}
    fondosAMeter=${varfondos:1:$digitosUnidad}
    sumaTotalMemoria=0
#ES_31390Variable que indica si se ha añadido un proceso a la banda
    for (( i=0; i<$nprocesos; i++)); do 
#ES_31400Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
	done
			
#ES_31410unidMemOcupadas[@]};ii++)); do
#ES_31420El proceso está en memoria y se imprimirá
#ES_31430El texto no cabe en la terminal
#ES_31440Se pasa a la siguiente línea
                bandaMemoria[$nn]="     "
                bandaMemoriaColor[$nn]="     "
                numCaracteres2=5
            fi
#ES_31450paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}))}
#ES_31460Si no hay página se mete asterisco en BN.
#ES_31470paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}))}"*"*"
#ES_31480Y si hay página se mete espacios y el número.
#ES_31490paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}))}
			fi
            bandaMemoria[$nn]+=`echo -e "$espaciosasteriscofinal${paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}"`
            bandaMemoriaColor[$nn]+=`echo -e "$NC${colorfondo[${unidMemOcupadas[$ii]} % 6]}$espaciosfinal${paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}$NC"`
#ES_31500Número de Marcos con Páginas ya dibujadas de cada Proceso.
            numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
            if [[ $ii -ne 0 ]]; then
                if [[ ${unidMemOcupadas[$((ii - 1))]} !=  "_" ]]; then 
                    if [[ $xx -eq 1 && ${proceso[$((${unidMemOcupadas[$ii]}))]} != ${proceso[$((${unidMemOcupadas[$((ii - 1))]}))]} ]]; then
                        xx=0
                    fi
                fi
            fi
#ES_31510El proceso no está en memoria y no puede representarse en la Banda de Memoria.
            xx=0
#ES_31520El texto no cabe en la terminal
#ES_31530Se pasa a la siguiente línea
                bandaMemoria[$nn]="     "
                bandaMemoriaColor[$nn]="     "
                numCaracteres2=5
            fi
#ES_31540paginasEnMemoriaTotal[${unidMemOcupadas[$ii]},${numMarcosDibujadosPorProceso[${unidMemOcupadas[$ii]}]}]}))}"-"
            bandaMemoria[$nn]+=`echo -e "$espaciosguionfinal"`
            bandaMemoriaColor[$nn]+=`echo -e "$NC$fondosAMeter$NC"`
            numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
        fi
    done

#ES_31550Añadir final de banda 
#ES_31560El texto no cabe en la terminal
#ES_31570Se pasa a la siguiente línea
        bandaMemoria[$nn]="     "
        bandaMemoriaColor[$nn]=$NORMAL"     "
        numCaracteres2=5
    fi
#ES_31580 TODO: CAMBIAR NÚMERO DE MEMORIA
#ES_31590 TODO: CAMBIAR NÚMERO DE MEMORIA

#ES_31600 GENERACIÓN STRING DE POSICIÓN DE MEMORIA (Línea 3 de la Banda de Memoria)  
#ES_31610 Línea de la banda
    bandaPosicion=("    |")
    bandaPosicionColor=("$NORMAL    |")
    numCaracteres2=5
#ES_31620Variable que indica si se ha añadido un proceso a la banda
#ES_31630unidMemOcupadas[@]};ii++)); do
#ES_31640El proceso está en memoria y se imprimirá
#ES_31650 El texto no cabe en la terminal
#ES_31660 Se pasa a la siguiente línea
                bandaPosicion[$nn]="     "
                bandaPosicionColor[$nn]="     "
                numCaracteres2=5
            fi
#ES_31670 El texto no cabe en la terminal
                xx=0
            fi
#ES_31680Se añade el proceso a la banda
#ES_31690ii}))}
                bandaPosicion[$nn]+=`echo -e "$espaciosfinal""$ii"`
                bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal""$ii"`
                numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
                xx=1
            else
#ES_31700El texto no cabe en la terminal
#ES_31710Se pasa a la siguiente línea
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
#ES_31720El texto no cabe en la terminal
#ES_31730Se pasa a la siguiente línea
                bandaPosicion[$nn]="     "
                bandaPosicionColor[$nn]="     "
                numCaracteres2=5
            fi
            if [[ $ii -ne 0 ]]; then
                if [[ ${unidMemOcupadas[$((ii - 1))]} != "_" ]]; then
#ES_31740ii}))}
                    bandaPosicion[$nn]+=`echo -e "$espaciosfinal""$ii"`
                    bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal""$ii"`
                else
                    espaciosfinal=${varhuecos:1:$(($digitosUnidad))}
                    bandaPosicion[$nn]+=`echo -e "$espaciosfinal"`
                    bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal"`
                fi
            else
#ES_31750ii}))}
                bandaPosicion[$nn]+=`echo -e "$espaciosfinal""$ii"`
                bandaPosicionColor[$nn]+=`echo -e "$NORMAL$espaciosfinal""$ii"`
            fi
            numCaracteres2=$(($numCaracteres2 + $digitosUnidad))
        fi
    done
#ES_31760Añadir final de banda
#ES_31770El texto no cabe en la terminal
#ES_31780 Se pasa a la siguiente línea
        bandaPosicion[$nn]="     "
        bandaPosicionColor[$nn]="$NORMAL     "
        numCaracteres2=5
    fi
    bandaPosicion[$nn]+=`echo -e "|"`
    bandaPosicionColor[$nn]+=`echo -e "$NORMAL|"`

#ES_31790 IMPRIMIR LAS 3 LÍNEAS DE LA BANDA DE MEMORIA (COLOR y BN a pantalla y ficheros)
#ES_31800bandaProcesos[@]}; jj++ )); do
        echo -e "${bandaProcesosColor[$jj]}" | tee -a $informeConColorTotal
        echo -e "${bandaMemoriaColor[$jj]}" | tee -a $informeConColorTotal
        echo -e "${bandaPosicionColor[$jj]}\n" | tee -a $informeConColorTotal
        echo -e "${bandaProcesos[$jj]}" >> $informeSinColorTotal
        echo -e "${bandaMemoria[$jj]}" >> $informeSinColorTotal
        echo -e "${bandaPosicion[$jj]}\n" >> $informeSinColorTotal
    done
#ES_31810Se vacía el auxiliar que reubica la memoria.
#ES_31820Se borran los datos del auxiliar.
        unidMemOcupadasAux[$ca]="_"
    done
#ES_31830Se vacían bloques
#ES_31840Se borran los datos del auxiliar.
         bloques[$ca]=0
    done
#ES_31850Se vacían las posiciones
    nposiciones=0
#ES_31860Se vacían posiciones iniciales y finales para borrar elementos innecesarios
    for (( i=0; i<$nposiciones; i++ )) ; do
         inicialNCmodelo[$i]=0
    done
    for (( i=0; i<$nposiciones; i++ )) ; do 
         finalNCmodelo[$i]=0
    done
#ES_31870Fin de la nueva versión de dibujarBandaMemoria()

#
#ES_31880 Sinopsis: Prepara la banda de tiempos de procesos en cada volcado - PRUEBA DE COPIAR LÍNEA A lÍNEA
#
function calculosImpresionBandaTiempos { 
#ES_31890Sucesión: Crear las tres líneas de la banda de tiempo y se generan los bloques que componen la memoria usada por cada proceso en memoria.
#ES_31900Nota: Todas las que acaben en "b" (o "baux) significa que es la versión en blanco y negro (también en la memoria).
#ES_31910Se trabaja simultaneamente con la línea en b/n, en color, y con el array coloresPartesTiempo (o memoria) que guarda el color de cada caracter del terminal.
#ES_31920dibujasNC es el array que guarda cúantas unidades quedan por dibujar de un proceso
        
#ES_31930A... Primero. Se trata la entrada por separado hasta que entre el primer proceso
#ES_31940En T=0 se pone el "rótulo".
#ES_31950Determina el número de caracteres a inmprimir en cada línea.
    arribatiempoNC_0="    |"
    arribatiempoNCb_0="    |"
    tiempoNC_0=" BT |"
    tiempoNCb_0=" BT |"
    abajotiempoNC_0="    |"
    abajotiempoNCb_0="    |"
#ES_31960Unidades ya incluidas en las variables tiempoNC_0,...
    colorDefaultInicio
#ES_31970Primero se meten blancos en tiempoNC_0,... hasta la legada del primer proceso, si lo hay.
#ES_31980En el caso en que el primer proceso entre más tarde que 0, se introducen blancos iniciales en tiempoNC_0,....
        arribatiempoNC=$arribatiempoNC_0"${varhuecos:1:$(($digitosUnidad))}"$NC 
        arribatiempoNCb=$arribatiempoNCb_0"${varhuecos:1:$(($digitosUnidad))}"
        tiempoNC=$tiempoNC_0"${varhuecos:1:$(($digitosUnidad))}"$NC 
        tiempoNCb=$tiempoNCb_0"${varhuecos:1:$(($digitosUnidad))}"
        abajotiempoNC=$abajotiempoNC_0"${varhuecos:1:$(($digitosUnidad - 1))}0"$NC
        abajotiempoNCb=$abajotiempoNCb_0"${varhuecos:1:$(($digitosUnidad - 1))}0"
        colorDefaultBMBT
    fi
#ES_31990Hasta que se alcance reloj dibujar blancos en tiempoNC_0,....
        for (( i=0 ; i<$(($reloj)) ; i++ )) ; do
            if [[ $tiempodibujado -eq 0 ]]; then
                arribatiempoNC=$arribatiempoNC_0"${varhuecos:1:$(($digitosUnidad))}""${coloress[$i % 6]}"
                arribatiempoNCb=$arribatiempoNCb_0"${varhuecos:1:$(($digitosUnidad))}"
#ES_32000Representa los fondos con su color correspondiente
                tiempoNCb=$tiempoNCb_0"${varguiones:1:$(($digitosUnidad))}"
                abajotiempoNC=$abajotiempoNC_0"${varhuecos:1:$(($digitosUnidad - 1))}0"
                abajotiempoNCb=$abajotiempoNCb_0"${varhuecos:1:$(($digitosUnidad - 1))}0"
                tiempodibujado=$(($tiempodibujado + 1))
#ES_32010En el caso en que el primer proceso entre más tarde que 0 (dibujar blancos iniciales de la barra todos de golpe).
                arribatiempoNC=$arribatiempoNC"${varhuecos:1:$(($digitosUnidad))}""${coloress[$i % 6]}"
                arribatiempoNCb=$arribatiempoNCb"${varhuecos:1:$(($digitosUnidad))}"
#ES_32020Representa los fondos con su color correspondiente
                tiempoNCb=$tiempoNCb"${varguiones:1:$(($digitosUnidad))}"
                abajotiempoNC=$abajotiempoNC"${varhuecos:1:$(($digitosUnidad))}"
                abajotiempoNCb=$abajotiempoNCb"${varhuecos:1:$(($digitosUnidad))}"
                tiempodibujado=$(($tiempodibujado + 1))
            fi
        done
    fi
    
#ES_32030B... Segundo: A partir de la representación del primer proceso, si lo hay, se dibuja el resto de procesos de forma normal, añadiendo sus nombres y unidades.
#ES_320401.Dibujar los procesos finalizados - Si está nombrado y no se ha empezado a dibujar
#ES_320502.Añadir el rótulo del último proceso si hace falta y se marca como nombrado (entra en ejecución pero no hay que dibujar nada).        
#ES_320601. Proceso finalizado que NO se ha acabado de dibujar. Hay que dibujar meter nombres (línea 1) y unidades (línea 3). 
#ES_32070Que haya, que esté acabado (no él mismo) y que quede por dibujar:
#ES_32080Si se ha nombrado (nomtiempo()=1) y no se ha empezado a dibujar (valor en dibujasNC() como en tejecucion()) 
        if [[ ${nomtiempo[$proanterior]} == 1 && ${dibujasNC[$proanterior]} -eq ${tejecucion[$proanterior]} ]]; then 
#ES_32090Si se ha marcado como terminado y no se ha empezado a dibujar 
#ES_32100Ponemos espacios para cuadrar, tantos como unidades de la barra se dibujen, menos 1 (ese 1 es poe empezar a contar desde 0)
            for (( i=0 ; i<$contad; i++ )); do
                arribatiempoNC=$arribatiempoNC"${varhuecos:1:$(($digitosUnidad))}"$NC
                arribatiempoNCb=$arribatiempoNCb"${varhuecos:1:$(($digitosUnidad))}""222"
#ES_32110Cambiados a varfondos
                tiempoNCb=$tiempoNCb"${varguiones:1:$(($digitosUnidad))}"
                abajotiempoNC=$abajotiempoNC"${varhuecos:1:$(($digitosUnidad))}"$NC
                abajotiempoNCb=$abajotiempoNCb"${varhuecos:1:$(($digitosUnidad))}"
                colorAnterior
                tiempodibujado=$(($tiempodibujado + 1))
            done
            dibujasNC[$proanterior]=0
        fi 
#ES_32120Fin de los procesos terminados pendientes de imprimir en la banda de tiempo
#ES_321302.Se añade el nombre del último proceso que entra en ejecución y se marca como nombrado (entra en ejecución pero no hay que dibujar nada).
    for (( po=0; po<$nprocesos; po++)) ; do
        if ( [[ $tiempodibujado -eq $reloj && ${dibujasNC[$po]} -eq ${tejecucion[$po]} && ${estad[$po]} -eq 3 ]] ) ; then 
            arribatiempoNC=$arribatiempoNC"${coloress[$po % 6]}${proceso[$po]}""${varhuecos:1:$(($digitosUnidad - ${proceso[$po]}))}"$NC
            arribatiempoNCb=$arribatiempoNCb"${proceso[$po]}""${varhuecos:1:$(($digitosUnidad - ${proceso[$po]}))}"
#ES_32140Propuesto meter varfondos
            tiempoNCb=$tiempoNCb"${varhuecos:1:$(($digitosUnidad))}"
#ES_32150reloj}))}""$reloj"$NC
#ES_32160reloj}))}""$reloj"
            tiempodibujado=$(($tiempodibujado + 1))
        fi
#ES_32170Se marca como nombrado
    done
#ES_32180Final de los cálculos para la impresión de la banda de memoria de los volcados - calculosImpresionBandaTiempos()

#
#ES_32190 Sinopsis: Imprime las tres líneas de la banda de tiempo. Permite mostrar el orden de ejecución de los 
#ES_32200 procesos y su evolución en el tiempo.
#
function dibujarBandaTiempos {     
#ES_32210 Variable para almacenar la suma total de tiempos de llegada y ejecución
#ES_32220 Número más alto entre la suma los tiempos de llegada y ejecución totales, y la página de mayor número
    local maxCaracteres=0
#ES_32230 Longitud en número de dígitos de cada unidad 
    if [[ $maxCaracteres -eq 2 ]]; then
#ES_32240 El mínimo de caracteres tiene que ser 3 para que entren los nombres de 
    fi
#ES_32250Ancho del terminal para adecuar el ancho de líneas a cada volcado
#ES_32260proceso[@]}; s++)); do
        if [[ ${estado[$s]} == "En ejecución" ]]; then
#ES_32270En cada casilla contiene el número de orden del proceso que se ejecuta en cada instante. Sólo puede haber un proceso en cada instante.
        fi
    done

#ES_32280 GENERACIÓN STRING DE LA BANDA DE TIEMPOS (Línea 1 de la Banda de Tiempos)
    local bandaProcesos=("    |")
    local bandaProcesosColor=($NORMAL"    |")
#ES_32290 Línea de la banda
    local numCaracteres=5
    espaciosAMeter=${varhuecos:1:$maxCaracteres}
    guionesAMeter=${varguiones:1:$maxCaracteres}
    fondosAMeter=${varfondos:1:$maxCaracteres}
    for ((k = 0; k <= $reloj; k++)); do
#ES_32300Si T=0
#ES_32310Si hay proceso en ejecución para T=0
#ES_32320Se imprime el nombre del proceso en ejecución en ese instante definido por la posición almacenada en procPorUnidadTiempoBT
				bandaProcesos[n]+=`printf "%-$(($maxCaracteres))s" $p`
				bandaProcesosColor[n]+=`printf "${coloress[${procPorUnidadTiempoBT[$k]} % 6]}%-$(($maxCaracteres))s$NORMAL" $p`
#ES_32330Si no hay proceso en ejecución para T=0
                bandaInstantes[n]+=`echo -e $espaciosAMeter`
                bandaInstantesColor[n]+=`echo -e $espaciosAMeter`
            fi
            numCaracteres=$(($numCaracteres + $maxCaracteres))
#ES_32340Si NO T=0
#ES_32350 El texto no cabe en la terminal
#ES_32360 Se pasa a la siguiente línea
				bandaProcesos[n]="     "
				bandaProcesosColor[n]="     "
				numCaracteres=5
			fi
#ES_32370Si se mantiene el mismo proceso en ejecución se imprimen espacios
				bandaProcesos[n]+=`printf "%$(($maxCaracteres))s" ""`
				bandaProcesosColor[n]+=`printf "%$(($maxCaracteres))s" ""`
#ES_32380Si no se mantiene el mismo proceso en ejecución se imprime el nombre del nuevo proceso
#ES_32390Se imprime el nombre del proceso en ejecución en ese instante definido por la posición almacenada en procPorUnidadTiempoBT
				bandaProcesos[n]+=`printf "%-$(($maxCaracteres))s" $p`
				bandaProcesosColor[n]+=`printf "${coloress[${procPorUnidadTiempoBT[$k]} % 6]}%-$(($maxCaracteres))s$NORMAL" $p`
			fi
			numCaracteres=$(($numCaracteres + $maxCaracteres))
        fi
    done
#ES_32400 Añadir final de banda
#ES_32410 El texto no cabe en la terminal
#ES_32420 Se pasa a la siguiente línea
        bandaProcesos[n]="     "
        bandaProcesosColor[n]="     "
        numCaracteres=5
    fi
    bandaProcesos[n]+=`printf "|    %$(($maxCaracteres))s" ""`
    bandaProcesosColor[n]+=`printf "|    %$(($maxCaracteres))s" ""`

#ES_32430 GENERACIÓN STRING DE LA BANDA DE TIEMPOS (Línea 2 de la Banda de Tiempos)
    local bandaTiempo=(" BT |")
    local bandaTiempoColor=(" BT |")
#ES_32440 Línea de la banda
    local numCaracteres=5
    for (( i=0; i<$nprocesos; i++)); do 
#ES_32450Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
	done
    for ((k = 0; k <= $reloj; k++)); do
#ES_32460 El texto no cabe en la terminal
#ES_32470 Se pasa a la siguiente línea
            bandaTiempo[n]="     "
            bandaTiempoColor[n]="     "
            numCaracteres=5
        fi
#ES_32480Si el instante considerado es igual al tiempo actual
#ES_32490Si no hay proceso en ejecución asociado a ese instante. Vale 0 si no está definido porque la inicialización empieza en posición=1.
				if [[ $k -eq 0 ]]; then
					espaciosguionfinal=${varhuecos:1:$(($digitosUnidad - 1))}"-"
					bandaTiempo[n]+=$espaciosguionfinal
					bandaTiempoColor[n]+=$espaciosguionfinal
            	else
					bandaTiempo[n]+=$espaciosAMeter
					bandaTiempoColor[n]+=$espaciosAMeter
            	fi
#ES_32500Si hay proceso en ejecución asociado a ese instante.
#ES_32510paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}))}
				bandaTiempo[n]+=$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}
				bandaTiempoColor[n]+=$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}
			fi
#ES_32520Si el instante considerado NO es igual al tiempo actual
#ES_32530 Si NO hay proceso en ejecución asociado a ese instante. Vale 0 si no está definido porque la inicialización empieza en posición=1.
                espaciosguionfinal=${varhuecos:1:$(($digitosUnidad - 1))}"-"
                bandaTiempo[n]+=$espaciosguionfinal
                bandaTiempoColor[n]+=$fondosAMeter
#ES_32540 Si hay proceso en ejecución asociado a ese instante  
#ES_32550paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}))}
                bandaTiempo[n]+=$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}$NC
#ES_32560Si NO es T=0
                    bandaTiempoColor[n]+=$NC${colorfondo[${procPorUnidadTiempoBT[$k]} % 6]}$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}$NC
#ES_32570Si es T=0
#ES_32580Si T=0 no se colorea el fondo 
						bandaTiempoColor[n]+=$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}$NC
#ES_32590Si T>0 se pintará el fondo del color del proceso en ejecución.
                        bandaTiempoColor[n]+=$NC${colorfondo[${procPorUnidadTiempoBT[$k]} % 6]}$espaciosfinal${paginasDefinidasTotal[${procPorUnidadTiempoBT[$k]},${numMarcosDibujadosPorProceso[${procPorUnidadTiempoBT[$k]}]}]}$NC                    
                    fi
                fi
#ES_32600Número de Marcos en Memoria con Páginas ya dibujadas de cada Proceso para el resumen de Banda.
            fi
        fi
        numCaracteres=$(($numCaracteres + $maxCaracteres))
    done

#ES_32610 Añadir final de banda
#ES_32620 El texto no cabe en la terminal
#ES_32630 Se pasa a la siguiente línea
        bandaTiempo[n]="     "
        bandaTiempoColor[n]="     "
        numCaracteres=5
    fi
    bandaTiempo[n]+=`printf "|T= %-${maxCaracteres}d" $reloj`
    bandaTiempoColor[n]+=$NC`printf "|T= %-${maxCaracteres}d" $reloj`

#ES_32640 GENERACIÓN STRING DE LAS UNIDADES DE LOS INSTANES DE TIEMPO (Línea 3 de la Banda de Tiempos)
    local bandaInstantes=("    |")
    local bandaInstantesColor=($NC"    |")
#ES_32650 Línea de la banda
    local numCaracteres=5
    for ((k = 0; k <= $reloj; k++)); do
#ES_32660Cuando se mantiene el mismo proceso en ejecución
#ES_32670En T=0 o T=momento actual, aumenta el contenido de las bandas
#ES_32680 El texto no cabe en la terminal
#ES_32690 Se pasa a la siguiente línea
                    bandaInstantes[n]="     "
                    bandaInstantesColor[n]=$NC"     "
                    numCaracteres=5
                fi
                bandaInstantes[n]+=`printf "%${maxCaracteres}d" $k`
                bandaInstantesColor[n]+=`printf "%${maxCaracteres}d" $k`
                numCaracteres=$(($numCaracteres + $maxCaracteres))
#ES_32700En T distinto de 0 o momento actual, también aumenta el contenido de las bandas
#ES_32710 El texto no cabe en la terminal
#ES_32720 Se pasa a la siguiente línea
                    bandaInstantes[n]="     "
                    bandaInstantesColor[n]=$NC"     "
                    numCaracteres=5
                fi
                bandaInstantes[n]+=`printf "%${maxCaracteres}s" ""`
                bandaInstantesColor[n]+=`printf "%${maxCaracteres}s" ""`
                numCaracteres=$(($numCaracteres + $maxCaracteres))
            fi
#ES_32730Cuando no se mantiene el mismo proceso en ejecución
#ES_32740 El texto no cabe en la terminal
#ES_32750 Se pasa a la siguiente línea
                bandaInstantes[n]="     "
                bandaInstantesColor[n]=$NC"     "
                numCaracteres=5
            fi
            bandaInstantes[n]+=`printf "%${maxCaracteres}d" $k`
            bandaInstantesColor[n]+=`printf "%${maxCaracteres}d" $k`
            numCaracteres=$(($numCaracteres + $maxCaracteres))
        fi
    done
#ES_32760 Añadir final de banda
#ES_32770 El texto no cabe en la terminal
#ES_32780 Se pasa a la siguiente línea
        bandaInstantes[n]="     "
        bandaInstantesColor[n]=$NC"     "
        numCaracteres=5
    fi
    bandaInstantes[n]+=`printf "|    %$(($maxCaracteres))s" ""`
    bandaInstantesColor[n]+=`printf "|    %$(($maxCaracteres))s" ""`

#ES_32790 IMPRIMIR LAS 3 LÍNEAS DE LA BANDA DE TIEMPOS (COLOR y BN a pantalla y ficheros temporales) - Se meten ahora en los temporales para que la banda de tiempo vaya tras la banda de memoria
#ES_32800bandaProcesos[@]}; i++ )); do
        echo -e "${bandaProcesos[$i]}" >> $informeSinColorTotal
        echo -e "${bandaTiempo[$i]}" >> $informeSinColorTotal
        echo -e "${bandaInstantes[$i]}\n" >> $informeSinColorTotal
        echo -e "${bandaProcesosColor[$i]}" | tee -a $informeConColorTotal
        echo -e "${bandaTiempoColor[$i]}" | tee -a $informeConColorTotal
        echo -e "${bandaInstantesColor[$i]}\n" | tee -a $informeConColorTotal
    done    

#
#ES_32810Se determina el modo de ejecución (Enter, sin paradas, con paradas con tiempo predefinido)
#ES_32820Impresión de forma manual (pulsando enter para pasar)
        echo -e " Pulse ENTER para continuar.$NC" | tee -a $informeConColorTotal
        echo -e " Pulse ENTER para continuar." >> $informeSinColorTotal
        read continuar
        echo -e $continuar "\n" >> $informeConColorTotal
        echo -e $continuar "\n" >> $informeSinColorTotal
#ES_32830Cierre de fi - optejecucion=1 (seleccionMenuModoTiempoEjecucionAlgormitmo=1)
#ES_32840Impresión de forma sin parar (pasa sin esperar, de golpe)
        echo -e "───────────────────────────────────────────────────────────────────────$NC" | tee -a $informeConColorTotal
        echo -e "───────────────────────────────────────────────────────────────────────" >> $informeSinColorTotal
#ES_32850Cierre de fi - optejecucion=2 (seleccionMenuModoTiempoEjecucionAlgormitmo=2)
#ES_32860Impresión de forma automatica (esperando x segundo para pasar)
        echo -e " Espere para continuar...$NC\n" | tee -a $informeConColorTotal
        echo -e " Espere para continuar...\n" >> $informeSinColorTotal
        sleep $tiempoejecucion 
#ES_32870Cierre de fi - optejecucion=3 (seleccionMenuModoTiempoEjecucionAlgormitmo=3)
#ES_32880Fin de dibujarBandaTiempos()

#
#ES_32890 Sinopsis: Muestra en pantalla/informe una tabla con el resultado final tras la ejecución
#ES_32900 de todos los procesos
#
function resultadoFinalDeLaEjecucion {
    echo "$NORMAL Procesos introducidos (ordenados por tiempo de llegada):" | tee -a $informeConColorTotal
    echo -e " ┌─────┬─────┬─────┬─────┬──────┬──────┐" | tee -a $informeConColorTotal
    echo -e " │ Ref │ Tll │ Tej │ Mem │ TEsp │ Tret │" | tee -a $informeConColorTotal   
    echo -e " ├─────┼─────┼─────┼─────┼──────┼──────┤" | tee -a $informeConColorTotal
    echo -e " ┌─────┬─────┬─────┬─────┬──────┬──────┐" >> $informeSinColorTotal
    echo -e " │ Ref │ Tll │ Tej │ Mem │ TEsp │ Tret │" >> $informeSinColorTotal
    echo -e " ├─────┼─────┼─────┼─────┼──────┼──────┤" >> $informeSinColorTotal
    
#ES_32910Se usa m porque i recorre los procesos y m controla las unidades usadas por cada proceso, normalmente 0 o 1, y también las unidades de los n trozos de memoria asociados a cada proceso. 
        echo -e " │ ${varC[$i]}${proceso[$i]}$NC │"\
#ES_32920llegada[$i]})${varC[$i]}${llegada[$i]}$NC │"\
#ES_32930ejecucion[$i]})${varC[$i]}${ejecucion[$i]}$NC │"\
#ES_32940memoria[$i]})${varC[$i]}${memoria[$i]}$NC │"\
#ES_32950temp_wait[$i]})${varC[$i]}${temp_wait[$i]}$NC │"\
 tee -a $informeConColorTotal| tee -a $informeConColorTotal
#ES_32970llegada[$i]})${llegada[$i]} │"\
#ES_32980ejecucion[$i]})${ejecucion[$i]} │"\
#ES_32990memoria[$i]})${memoria[$i]} │"\
#ES_33000temp_wait[$i]})${temp_wait[$i]} │"\
#ES_33010temp_ret[$i]})${temp_ret[$i]} │" >> $informeSinColorTotal
    done
    echo " └─────┴─────┴─────┴─────┴──────┴──────┘" | tee -a $informeConColorTotal
    echo " └─────┴─────┴─────┴─────┴──────┴──────┘">> $informeSinColorTotal

#ES_33020Promedios
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
#ES_33030Si el tamaño del proceso es menor o igual que el de memoria
#ES_33040suma para sacar su promedio
#ES_33050promedio

#ES_33060suma para sacar su promedio
#ES_33070promedio
        fi
        suma_contadorAlgPagFallosProcesoAcumulado=$(($suma_contadorAlgPagFallosProcesoAcumulado + ${contadorAlgPagFallosProcesoAcumulado[$i]}))
        suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado=$(($suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado + ${contadorAlgPagExpulsionesForzadasProcesoAcumulado[$i]}))
    done
    echo -e "\n ┌─────────────────────────────┬─────────────────────────────┐" | tee -a $informeConColorTotal 
#ES_33080promedio_espera})$NC " \
 tee -a $informeConColorTotal | tee -a $informeConColorTotal 
    echo -e " └─────────────────────────────┴─────────────────────────────┘" | tee -a $informeConColorTotal 
    echo -e "\n ┌─────────────────────────────┬─────────────────────────────┐" >> $informeSinColorTotal
#ES_33100promedio_espera}) " \
#ES_33110promedio_retorno}) │" >> $informeSinColorTotal
    echo -e " └─────────────────────────────┴─────────────────────────────┘" >> $informeSinColorTotal
	echo -e "\n ┌───────────────────────────────────────────────────────────┐" | tee -a $informeConColorTotal 
 tee -a $informeConColorTotal | tee -a $informeConColorTotal 
    if [[ $seleccionMenuAlgoritmoGestionProcesos -eq 5 ]]; then
 tee -a $informeConColorTotal | tee -a $informeConColorTotal 
    fi
	echo -e " └───────────────────────────────────────────────────────────┘" | tee -a $informeConColorTotal 
	echo -e "\n ┌───────────────────────────────────────────────────────────┐" >> $informeSinColorTotal
#ES_33140suma_contadorAlgPagFallosProcesoAcumulado})                          │" >> $informeSinColorTotal
    if [[ $seleccionMenuAlgoritmoGestionProcesos -eq 5 ]]; then
#ES_33150suma_contadorAlgPagExpulsionesForzadasProcesoAcumulado})  │" >> $informeSinColorTotal
    fi
	echo -e " └───────────────────────────────────────────────────────────┘" >> $informeSinColorTotal
#ES_33160No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -ne $ROJO"\n\n Pulsa ENTER para continuar "$NORMAL
		read enter
	fi
#ES_33170Fin de resultadoFinalDeLaEjecucion()

#
#ES_33180 Sinopsis: Permite introducir las particiones y datos desde otro fichero (predefinido).
#
function mostrarInforme {
#ES_33190No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
		echo -e "\n Final del proceso, puede consultar la salida en el fichero informeBN.txt" 
		echo -e "\n Pulse enter para las opciones de visualización del fichero informeBN.txt..."
		read enter
	fi
#ES_33200    clear
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
#ES_33210Se comprueba que el número introducido por el usuario es de 1 a 10
		until [[ 0 -lt $num && $num -lt 5 ]];  do
			echo -ne "\n Error en la elección de una opción válida\n\n--> " | tee -a $informeConColorTotal
			echo -ne "\n Error en la elección de una opción válida\n\n--> " >> $informeSinColorTotal
			read num
			echo -ne "$num\n\n" >> $informeConColorTotal
			echo -ne "$num\n\n" >> $informeSinColorTotal
		done
        case $num in
            '1' )  
#ES_33220                clear               
                cat $informeSinColorTotal
                exit 0
                ;;
            '2' ) 
#ES_33230                clear
                gedit $informeSinColorTotal
                exit 0
                ;;
            '3' )
#ES_33240                clear
                cat $informeConColorTotal
                exit 0
                ;;
            '4' )
#ES_33250                clear
                exit 0
                ;;
            *) 
                num=0
                cecho "Opción errónea, vuelva a introducir:" $FRED
        esac
    done
#ES_33260Fin de mostrarInforme()

#
#
#ES_33270 COMIENZO DEL PROGRAMA
#
#
function inicioNuevo {
#ES_33280Empieza el script
#ES_33290proceso[@]}
#ES_33300Inicilizamos diferentes tablas y variables  

#ES_33310 Se inicilizan las variables necesarias para la nueva línea del tiempo
#ES_33320Se dibuja tanto como tiempo de ejecución tengan
    if [[ seleccionMenuAlgoritmoGestionProcesos -ne 4 ]]; then 
#ES_33330Volcado de datos en pantalla tras pedir datos/introducción desde fichero.
    elif [[ seleccionMenuAlgoritmoGestionProcesos -eq 4 ]]; then 
#ES_33340Volcado de datos en pantalla tras pedir datos/introducción desde fichero.
    fi
    
#ES_33350B U C L E   P R I N C I P A L 
#ES_33360Tiempo transcurrido desde el inicio del programa.
    contador=1
#ES_33370Controla la salida del bucle cuando finalicen todos los procesos.
#ES_33380Controla si hay procesos en ejecución.
#ES_33390Número de procesos definidos en el problema
    realizadoAntes=0

    while [[ "$parar_proceso" == "NO" ]]; do
#ES_33400Se inicializa al máximo antes calculado para declarar que no hay proceso en ejecución en ese instante de reloj
        timepoAux=`expr $reloj + 1`

#ES_33410E N T R A R   E N   C O L A - Si el momento de entrada del proceso coincide con el reloj marcamos el proceso como en espera, en encola()
#ES_33420Bucle que pone en cola los procesos.
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

#ES_33430G U A R D A R   E N    M E M O R I A - Si un proceso está encola(), intento guardarlo en memoria, si cabe. Si lo consigo, lo marco como listo enmemoria().
#ES_33440Comprueba si el proceso en ejecución ha finalizado, y lo saca de memoria. 
            if [[ ${enejecucion[$i]} -eq 1 && ${temp_rej[$i]} -eq 0 ]]; then 
#ES_33450Para que deje de estar en ejecución.
#ES_33460Para que deje de estar en memoria y deje espacio libre.  
#ES_33470Se libera la memoria que ocupaba el proceso cuando termina.
                avisosalida[$i]=1
                evento=1
#ES_33480Pasa a estar no ocupada hasta que se vuelva a buscar si hay procesos en memoria que vayan a ser ejecutados.
#ES_33490Se guarda qué procesos han terminado (1) o no (0)
#ES_33500Finalizado
				estado[$i]="Finalizado"
#ES_33510Número de procesos que quedan por ejecutar.                    
                pos_inicio[$i]=""
                procFinalizado=$i
            fi
        done
        
#ES_33520Se actualiza la variable memoria al terminar los procesos.
        
#ES_33530Con esta parte se revisa la reubicabilidad, y si hay procesos se intentan cargar antes de usar los gestores de procesos, mientras que con la que hay en la reubicación, tras reubicar y producir un hueco al final de la memoria, se reintenta cargar procesos.
#ES_33540Se comprueba que haya espacio suficiente en memoria y se meten los procesos que se puedan de la cola para empezar a ejecutar los algoritmos de gestión de procesos.
        if [[ $mem_libre -gt 0 ]]; then  
#ES_33550Determinará si se debe o no hacer la reubicación de los procesos por condiciones de reubicabilidad. En caso de ser memoria no continua, si hay un hueco demasiado pequeño, y se va a usar como parte de la memoria a usar.
#ES_33560Determinará si se debe o no hacer la reubicación de los procesos por condiciones de continuidad. En caso de ser memoria continua, si no hay un hueco suficientemente grande en el que quepa pero sí en la suma de todos ellos.
#ES_33570Contiene los procesos que están en memoria de forma secuencial en la variable guardadoMemoria, y sus tamaños en tamanoGuardadoMemoria.
#ES_33580Se determina qué proceso es el siguiente en entrar en memoria, y dependiendo de la continuidad y reubicabilidad definidas, se establece si hay espacio en memoria. 
#ES_33590Si hay que reubicar antes de meter más procesos, se hace.
#ES_33600Se meten todos los nuevos proceso que quepan y se comprueba si hay que reubicar tras cada uno de ellos. 
#ES_33610Ajusta el bucle actual a la variable interna de la función.
                    comprobacionSiguienteProcesoParaMeterMemoria
                    meterProcesosBandaMemoria
#ES_33620Sin este if+break fallaba porque podía meter otro proceso en memoria si tenía el espacio suficiente, incluso colándose a otro proceso anterior.
						break
                    fi
                done
            else
#ES_33630Se reubica la memoria.
#ES_33640Se impide un nuevo volcado en pantalla en el que no se vea avance de la aplicación.
#ES_33650Se modifica restando una unidad para ajustar el reloj y variables temporales al anular un ciclo del bucle, ya que la variable timepoAux se modifica al principio del bucle principal mediante: timepoAux=`expr $reloj + 1` 
            fi
        fi

#ES_33660Se inicializan las variables con diferentes acumulados en cada instante de reloj. Algunos acumulados sólo serían necesarios cuando se produzcan eventos, pero se podrían generalizar haciendo acumulados en cada instante.
		inicializarAcumulados 
        
#ES_33670 P L A N I F I C A R   P R O C E S O S  
#ES_33680 Si hay procesos listos en memoria(), se ejecuta el que corresponde en función del criterio de planificación que, 
#ES_33690 en este caso, es el que tenga una ejecución más corta de todos los procesos. Se puede expulsar a un proceso de la CPU
#ES_33700 Si acaba un proceso, su tiempo de ejecución se ponemos a 0 en la lista de enejecución y se libera la memoria que estaba ocupando
#ES_33710Si hay que reubicar antes de meter más procesos, se hace.
#ES_33720Mientras no haya un proceso en ejecución, se pone a -1. El gestor del algoritmo lo cambiará si procede.
            if [[ $alg == 1 ]]; then
#ES_33730Algoritmo de gestión de procesos: FCFS
            elif [[ $alg == 2 ]]; then
#ES_33740Algoritmo de gestión de procesos: SJF
            elif [[ $alg == 3 ]]; then
#ES_33750Algoritmo de gestión de procesos: SRPT
            elif [[ $alg == 4 ]]; then
#ES_33760Algoritmo de gestión de procesos: Prioridades
            elif [[ $alg == 5 ]]; then
#ES_33770Algoritmo de gestión de procesos: Round Robin
            fi
        fi
#ES_33780I M P R I M I R   E V E N T O S 
#ES_33790Los eventos los determinan en las funciones gestionProcesosFCFS, gestionProcesosSJF y gestionProcesosSRPT
#ES_33800Prepara la banda de tiempos de procesos en cada volcado
#ES_33810Se muestran los eventos sucedidos, sobre la tabla resumen.
#ES_33820 C Á L C U L O   D E   L A   B A N D A   D E   M E M O R I A  
#ES_33830 Habrá un array inicialmente relleno de "_" que se va llenando de las referencias de los procesos (memoria()). Después será usado para formar la banda de memoria.
#ES_33840 $po es el índice usado para los procesos y $ra para las posiciones de la memoria al recorrer el array.
#ES_33850 Hay otros arrays como el que se usa para generar los diferentes bloques que conforman cada proceso, relacionados con la reubicación (bloques()).
            calculosPrepararLineasImpresionBandaMemoria
#ES_33860 D I B U J O   D E   L A   T A B L A   D E   D A T O S   Y   D E   L A S   B A N D A S (Normalmente, por eventos) 
#ES_33870 Los eventos suceden cuando se realiza un cambio en los estados de cualquiera de los procesos.
#ES_33880 Los tiempos T. ESPERA, T. RETORNO y T. RESTANTE sólo se mostrarán en la tabla cuando el estado del proceso sea distinto de "No ha llegado".
#ES_33890 Para ello hacemos un bucle que pase por todos los procesos que compruebe si el estado nollegado() es 0 y para cada uno de los tiempos, si se debe mostrar se guarda el tiempo, si no se mostrará un guión
#ES_33900 Hay una lista de los procesos en memoria en la variable $guardados() 
#ES_33910Prepara e imprime la tabla resumen de procesos en cada volcado
#ES_33920Imprime diferentes resúmenes de paginación.
#ES_33930Muestra el resumen de todos los fallos de paginación del proceso finnalizado
#ES_33940Para no volver a hacer la impresión del mismo proceso a lescoger procFinalizado en gestionProcesosFCFS, gestionProcesosSJF y gestionProcesosSRPT.
				procFinalizado=-1
			fi          
#ES_33950Verifica qué proceso está en cada marco y determina si se produce un nuevo fallo de página, y lo muestra.
#ES_33960Se imprime la banda de memoria. Nueva versión, más fácil de interpretar y adaptar, larga y con iguales resultados.
#ES_33970Se imprime la banda de tiempo
#ES_33980Cierre de Impresión Eventos
#ES_33990 Se incrementa el contador de tiempos de ejecución y de espera de los procesos y se decrementa 
#ES_34000 el tiempo de ejecución que tiene el proceso que se encuentra en ejecución.
#ES_34010Si hay que reubicar antes de meter más procesos, se hace.
#ES_34020Prepara e imprime la tabla resumen de procesos en cada volcado - AL FINAL AUMENTA $reloj.
        fi
#ES_34030Fin del while con "$parar_proceso" = "NO"
#ES_34040    clear
#ES_34050Para ajustar el tiempo final
    echo -e "$NORMAL\n Tiempo: $tiempofinal  " | tee -a $informeConColorTotal
    echo -e " Ejecución terminada." | tee -a $informeConColorTotal
    echo -e "$NORMAL -----------------------------------------------------------\n" | tee -a $informeConColorTotal
    echo -e "\n Tiempo: $tiempofinal  " >> $informeSinColorTotal
    echo -e " Ejecución terminada." >> $informeSinColorTotal
    echo -e " -----------------------------------------------------------\n" >> $informeSinColorTotal
#ES_34060Impresión de datos finales
#ES_34070No se ejecuta cuando la selección inicial es la ejecución automática repetitiva.
#ES_34080Elección de visualización de informes
	fi
#ES_34090Final del programa principal - inicioNuevo()

#
#
#
#
#ES_34100Llamada a todas las funciones de forma secuencial
#ES_34110Regenera el árbol de directorios si no se encuentra. 
#ES_34120Carátula inicial con autores, versiones y licencias
#ES_34130Elección de ejecución o ayuda
#ES_34140Inicio de la ejecución del programa

#ES_34150????????????????????
#ES_34160llegada[@]}"z  z"
#ES_34170echo "z procPorUnidadTiempoBT z"${procPorUnidadTiempoBT[@]}"z  z"
#ES_34180echo "z estado z"${estado[@]}"z  z"
#ES_34190for (( counter=0 ; counter<${memoria[$ejecutandoinst]} ; counter++ )); do
#ES_34200	echo -ne "z ResuFrecuenciaAcumulado ("$counter"):"
#ES_34210	for (( ii=0 ; ii<=$reloj ; ii++ )); do
#ES_34220		echo -ne "-"$counter" "$ii" "${ResuFrecuenciaAcumulado[$ejecutandoinst,$counter,$ii]}
#ES_34230	done
#ES_34240	echo ""
#ES_34250done
#ES_34260echo -ne $ROJO"\n\n Pulsa ENTER para continuar "$NORMAL
#ES_34270read enterContinuar
#
