import re

contenido="opcion = valor"

resultado = re.search('(^opcion)\s=\s(.*)', contenido)

print("\ngrupo 0 (todo el contenido):")
print(resultado.group(0))
print("\ngrupo 1:")
print(resultado.group(1))
print("\ngrupo 2:")
print(resultado.group(2))
