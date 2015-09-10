#!/usr/bin/python

###################################################################################
# con este script troceamos un archivo de texto en lineas de x palabras indicadas.
###################################################################################

import os
import sys

# sys args:
#0        1    2   3   4                5     6
#comando  -p   6   -i  inarchivo.txt    -o    archivo.txt

ca = len(sys.argv)

def clear_screen():
    if os.name == "nt":
        os.system("cls")
    else:
        os.system("clear")

if ca == 7 and sys.argv[1] == "-p" and sys.argv[3] == "-i" and sys.argv[5] == "-o":
    uno = sys.argv[1]
    dos = sys.argv[2]
    tres = sys.argv[3]
    cuatro = sys.argv[4]
    cinco = sys.argv[5]
    seis = sys.argv[6]

    if cuatro:
        in_sub = cuatro

    if seis:
        out_sub = seis

    if dos:
        longitud = int(dos)

    def creartxt():
        archi=open(out_sub,'w')
        archi.close()

    def escribirtxt(archivo,texto):
        archi=open(archivo,'a')
        archi.write(texto)
        archi.close()

    # saber la longitud maxima de la palabra mas larga de todo el texto:
    def detector_leng(lista):
        maximo_len_palabras = max(len(w) for w in lista)
        return maximo_len_palabras

    def leertxt():

        archi=open(in_sub, 'r')

        palabras = []
        for line in file(in_sub):
            for word in line.split():
                palabras.append(word)

        grupo = []
        n = 0
        b = 0

        for i, w in enumerate(palabras):
            if n <= longitud:
                grupo.append(palabras[b:b+longitud])
                n = n+1
                b = b + longitud
            else:
                n = 0

        # limpiando el array de vacios:
        ordenado = []
        for g in grupo:
            if len(g) > 0:
                ordenado.append(g)

        result = []
        for g in ordenado:
            txt = ' '.join(g)
            result.append(txt)
            escribirtxt(out_sub, txt +"\n")

        archi.close()

    creartxt()
    leertxt()
    clear_screen()
    print "Fin del script. \nGracias por usar este script."

else:
    clear_screen()
    print "\n \
    Este programa necesita un archivo entrante sin formato, osea en utf-8 y en .txt\n \
    USO: \n \
    python comando -p 6 -i inarchivo.txt -o archivo.txt \n \
    -p indica el numero de palabras \n \
    -i indica el archivo input con el texto original en utf8\n \
    -o indica el output conel archivo resultante\n \
     "
