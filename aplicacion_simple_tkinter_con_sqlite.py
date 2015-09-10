from tkinter import *
from tkinter import ttk
import sqlite3
import os.path

mainwindow = Tk()
mainwindow.title("aplicacion beta v00")

x = (mainwindow.winfo_screenwidth() - mainwindow.winfo_reqwidth()) / 2
y = (mainwindow.winfo_screenheight() - mainwindow.winfo_reqheight()) / 2
mainwindow.geometry("200x120" + "+" + str(round(x)) + "+" + str(round(y)))

status = StringVar()
status.set("Status")

var2 = StringVar()
var2.set("Cliente")

def resetCliente(event):
    var2.set("")

def resetStatus(event):
    status.set("Status")

def creardb():
    conexion = sqlite3.connect('data.db')
    cursor = conexion.cursor()
    cursor.execute('''CREATE TABLE clientes (cliente VARCHAR(10) NOT NULL, producto VARCHAR(10) NOT NULL)''')
    conexion.commit()
    conexion.close()

def accion():
    if not os.path.isfile('data.db'):
         creardb()

    txt = str(var2.get())


    conexion = sqlite3.connect('data.db')
    cursor = conexion.cursor()
    cursor.execute("INSERT INTO clientes (cliente, producto) VALUES ('"+txt+"','"+txt+"')")
    conexion.commit()
    cursor.execute("SELECT cliente, producto FROM clientes")
    db = []
    for i in cursor:
        a = [ "Cliente: " +i[0] , " Producto: " +i[1] ]
        db.append(a)
    print(db)
    status.set(db[-1][0])

    conexion.commit()
    conexion.close()


def new_win():
    window = Tk()
    window.geometry("200x120" + "+" + str(round(x)) + "+" + str(round(y)))
    ttk.Label(window, text="ventana modal 1").place(x= 10, y= 10)
    ttk.Button(window, text="salir", command=window.destroy).place(x= 120, y=9)


entry_text = ttk.Entry(mainwindow, width=7, textvariable=var2)
entry_text.place(x=10, y=30)
entry_text.bind("<Button-1>",resetCliente)
entry_text.focus()

# para alinear cada elemento hacia la arriba izq der abajo
ttk.Label(mainwindow, text="Aplicacion v00").place(x=10 , y=10)
be = ttk.Button(mainwindow, text="Ejecutar", command=accion).place(x= 100, y=30)
bnw = ttk.Button(mainwindow, text="New Window", command=new_win).place(x= 100, y=60)
sl = ttk.Label(mainwindow, textvariable=status)
sl.place(x=10 , y=100)
sl.bind("<Button-1>",resetStatus)

mainwindow.mainloop()
