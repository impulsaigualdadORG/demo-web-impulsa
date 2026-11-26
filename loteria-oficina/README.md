# El número de la oficina

Un juego de cinco preguntas para elegir un número de lotería de cinco cifras. Se revela cuando hay seis papeletas completas (puedes cambiarlo a cinco).

## Para probarlo

Abre `index.html` en un navegador. Al no haber conexión configurada, guarda las papeletas de prueba solo en ese navegador. Pulsa «Simular otra persona» hasta completar las seis participaciones. El botón «Reiniciar la prueba» borra esos datos locales.

## Para que vote la oficina

1. Crea un proyecto en Supabase y ejecuta `supabase.sql` en su editor SQL. Esto crea las tablas y dos funciones para registrar papeletas y consultar el estado.
2. Copia la URL del proyecto y su **publishable key** en `CONFIG` al principio del JavaScript de `index.html`. Nunca incluyas una `secret key` o `service_role` en el HTML.
3. Sube `index.html` a un repositorio GitHub y habilita GitHub Pages para la rama/carpeta donde lo publiques. Comparte la URL como enlace o QR.
4. Si quieres revelar con cinco personas, cambia `min_participants` a `5` en la tabla `lottery_settings` y `minParticipants` a `5` en `CONFIG` (el texto de entrada lo utiliza).

Los votos reales se guardan en la tabla `public.lottery_ballots` de tu proyecto Supabase, no en GitHub. GitHub Pages sirve la página HTML. La tabla registra un identificador aleatorio del navegador, las cinco opciones y la fecha; no solicita nombres. Los visitantes no pueden leer papeletas individuales. La función `lottery_status` devuelve solamente el número de papeletas hasta alcanzar el mínimo y después devuelve el número y tres alternativas. La votación se cierra al llegar al mínimo, para que el número revelado no cambie.

El límite de una participación se aplica por navegador: borrar el almacenamiento del navegador, usar otro dispositivo o manipular peticiones permite más participaciones. Si necesitas garantizar una papeleta por empleado, hay que añadir una autenticación o invitaciones individuales. La disponibilidad de los números se consulta manualmente en la aplicación de lotería que utilicéis.
