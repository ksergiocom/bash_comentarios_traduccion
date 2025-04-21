# Bash Comment Translate Tool

This bash script is designed to work with comments in bash script files. Its main purpose is to reference and extract each comment from all **.sh** files in the directory where it is placed, and overwrite the original files with the translated comments.

![example](img/example.png)

The script generates translation files where all found comments are dumped with a numerical reference. Later, any of these can be dumped again.

Manual comment references can be added and appended to the translation files. It's also possible to renumber all references again.

![extracted_comments](img/comments.png)

## Pending

- Formatting the code
- Add headers and additional data
- Performance issue:
	- Two loops one for findComments other for loop over them.
	- Progress bar render every iteration
- New language generates a file even if there are no references
- Ditch sed -i to avoid creating tmp files for each iteration

---------- 
## ToDo
Echos para todas estas funciones:
1. Swap
2. addAdditionalReferences
3. renumerateReferences

Cambiar los comentarios de idiomas a inglés (cuando ya me aburra)

En verdad no se atrapan correctamente los echos (cambiar la funcion findEchoes por implementacion correcta!)

Se rompe el contaodr de progreso en los echos. ¿Por que?