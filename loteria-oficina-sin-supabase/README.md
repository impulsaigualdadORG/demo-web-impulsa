# El número de la oficina

Juego de cinco preguntas para elegir un número de lotería de cinco cifras entre las primeras seis personas que completen una papeleta.

## Cómo usarlo

1. Abre `index.html` en un navegador normal, o publícalo desde esta carpeta en GitHub Pages.
2. Comparte la pantalla o pasa el mismo portátil o tableta de persona en persona.
3. Cada participante responde las cinco preguntas y pulsa «Enviar mi papeleta».
4. La pantalla muestra el número de papeletas completas, sin revelar cifras ni resultados parciales.
5. Al enviar la sexta papeleta, aparece el número elegido y tres alternativas. Copia los números y consulta su disponibilidad en la aplicación de lotería.

Las papeletas se guardan en el almacenamiento local del navegador de ese dispositivo. Tras recargar la página siguen ahí. Para conservarlas, utiliza siempre el mismo navegador, no uses navegación privada y no borres los datos del sitio. El botón «Reiniciar votación» pide confirmación y elimina las papeletas.

GitHub guarda el archivo del juego, pero no recibe las papeletas ni calcula el resultado. Si se abre desde otro ordenador, ese ordenador empezará con cero papeletas. El juego se cierra cuando llega a seis y, por tanto, las personas que participen después ya no podrán votar.

Si el número de participantes debe ser cinco, cambia `minParticipants:6` por `minParticipants:5` en el HTML antes de empezar. Un empate entre respuestas de una ronda se resuelve por el orden en que aparecen las opciones. La aplicación no comprueba disponibilidad de números.