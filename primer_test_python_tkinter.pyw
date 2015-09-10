from tkinter import *
from tkinter import ttk

root = Tk()
root.title("Serrania beta v00")

# padding es el espacio alrededor de todo como los muelles de qt... sin reajustarse
# padding orden: izq up der down
mainframe = ttk.Frame(root, padding="3 3 3 3")
mainframe.grid(column=0, row=0, sticky=(N, W, E, S)) # arriba izq der abajo
mainframe.columnconfigure(0, weight=100)
mainframe.rowconfigure(0, weight=1)

variable1 = StringVar()
variable1.set("test2")
var2 = StringVar()
var2.set("Cliente")

def resetEntry(event):
    var2.set("")

entry_text = ttk.Entry(mainframe, width=7, textvariable=var2)
entry_text.grid(column=2, row=1, sticky=(W, E))
entry_text.bind("<Button-1>",resetEntry)

# para alinear cada elemento hacia la arriba izq der abajo
l1 = ttk.Label(mainframe, text="test1").grid(column=3, row=1, sticky=W)
l2 = ttk.Label(mainframe, textvariable=variable1).grid(column=1, row=2, sticky=E)
l3 = ttk.Label(mainframe, text="test3").grid(column=3, row=2, sticky=E)

def accion():
    txt = str(var2.get())
    variable1.set(txt)

def win():
    test = Tk()
    ttk.Label(test, text="modal1").grid(column=3, row=1, sticky=W)
    ttk.Button(test, text="salir", command=test.destroy).grid(column=3, row=3, sticky=W)

ttk.Button(mainframe, text="accion", command=accion).grid(column=3, row=3, sticky=W)
ttk.Button(mainframe, text="w", command=win).grid(column=3, row=4, sticky=W)


entry_text.focus()

root.mainloop()
