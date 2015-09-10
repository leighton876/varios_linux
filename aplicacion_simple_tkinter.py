from tkinter import *
from tkinter import ttk

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

def accion():
    txt = str(var2.get())
    status.set(txt)

def new_win():
    window = Tk()
    window.geometry("200x120" + "+" + str(round(x)) + "+" + str(round(y)))
    ttk.Label(window, text="ventana modal 1").place(x= 10, y= 10)
    ttk.Button(window, text="salir", command=window.destroy).place(x= 120, y=9)

entry_text = ttk.Entry(mainwindow, width=7, textvariable=var2)
entry_text.place(x=10, y=30)
entry_text.bind("<Button-1>",resetCliente)

# para alinear cada elemento hacia la arriba izq der abajo
ttk.Label(mainwindow, text="Aplicacion v00").place(x=10 , y=10)
be = ttk.Button(mainwindow, text="Ejecutar", command=accion).place(x= 100, y=30)
bnw = ttk.Button(mainwindow, text="New Window", command=new_win).place(x= 100, y=60)
sl = ttk.Label(mainwindow, textvariable=status)
sl.place(x=10 , y=100)
sl.bind("<Button-1>",resetStatus)

entry_text.focus()
mainwindow.mainloop()
