-- Migracion 181: Pre-registrar mensajes de respuesta del API como fuentes
-- traducibles (entity_type 'api_message', dominio '__GLOBAL__').
-- El middleware i18nResponseMiddleware los localiza por request segun el
-- idioma (?lang=/Accept-Language). Aqui se registran todos por adelantado
-- para que aparezcan en el modulo de traducciones sin esperar a que cada
-- mensaje se emita. Idempotente (ON CONFLICT dentro de la funcion).

DO $$
BEGIN
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e4d06ce32954780e', 'text', 'es', 'Actualizacion cancelada. El proceso en segundo plano se detendra.', '{"label": "Actualizacion cancelada. El proceso en segundo plano se d..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '01bfc51c5ea2ea6a', 'text', 'es', 'Actualizacion iniciada. El nodo se reiniciara automaticamente cuando termine.', '{"label": "Actualizacion iniciada. El nodo se reiniciara automaticam..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2b3e0fab93231e6e', 'text', 'es', 'Actualizacion iniciada. Monitorea el progreso en la consola.', '{"label": "Actualizacion iniciada. Monitorea el progreso en la consola."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e37ff6eba96d53de', 'text', 'es', 'Ambas asambleas aprobaron. La resolucion puede ejecutarse.', '{"label": "Ambas asambleas aprobaron. La resolucion puede ejecutarse."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '26dd8f4103ba7a38', 'text', 'es', 'Asamblea cerrada', '{"label": "Asamblea cerrada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f0b21b702273be5d', 'text', 'es', 'Asamblea cerrada. Error al auto-convocar siguiente.', '{"label": "Asamblea cerrada. Error al auto-convocar siguiente."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '78414a1702b7cdd8', 'text', 'es', 'Asamblea cerrada. Siguiente asamblea ordinaria convocada automaticamente.', '{"label": "Asamblea cerrada. Siguiente asamblea ordinaria convocada ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '103c2bf1d4fc4e2c', 'text', 'es', 'Asamblea creada. Los miembros han sido notificados.', '{"label": "Asamblea creada. Los miembros han sido notificados."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f2e07fbcd6ea0006', 'text', 'es', 'Asistencia confirmada via token.', '{"label": "Asistencia confirmada via token."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '07cdcfc836be26d7', 'text', 'es', 'Asistencia registrada', '{"label": "Asistencia registrada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3128c25b1bce6fd5', 'text', 'es', 'Asistente removido', '{"label": "Asistente removido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7489005875c8c046', 'text', 'es', 'Aun no puedes ascender.', '{"label": "Aun no puedes ascender."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3aea4402ab75e06c', 'text', 'es', 'Autenticacion requerida', '{"label": "Autenticacion requerida"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f7405ace560177a9', 'text', 'es', 'Backup restaurado', '{"label": "Backup restaurado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5007d44b1228a009', 'text', 'es', 'Backup solicitado. El servicio db-backup lo creara en los proximos 60 segundos.', '{"label": "Backup solicitado. El servicio db-backup lo creara en los..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9bc2b9155fb50c65', 'text', 'es', 'Campo obligatorio faltante', '{"label": "Campo obligatorio faltante"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '64b757675c2bace9', 'text', 'es', 'Cargo cancelado por el cliente', '{"label": "Cargo cancelado por el cliente"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a86bb3f0a609ffac', 'text', 'es', 'Check-in abierto. Los participantes pueden registrarse ahora.', '{"label": "Check-in abierto. Los participantes pueden registrarse ah..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '52a2fc46abbe3bc5', 'text', 'es', 'Check-in cerrado.', '{"label": "Check-in cerrado."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bba78cd5a1bddf59', 'text', 'es', 'Check-in registrado', '{"label": "Check-in registrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3d6d90ba77c16368', 'text', 'es', 'Check-out abierto.', '{"label": "Check-out abierto."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '02cce9660f10cbbb', 'text', 'es', 'Check-out cerrado.', '{"label": "Check-out cerrado."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cb5967f7b66f5596', 'text', 'es', 'Clave generada. Escribe esta clave en la tarjeta usando tu herramienta NFC (DESFire o NTAG424). La clave se guarda cifrada en el servidor.', '{"label": "Clave generada. Escribe esta clave en la tarjeta usando t..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8fb6a0bd467ca98f', 'text', 'es', 'Claves WireGuard generadas correctamente', '{"label": "Claves WireGuard generadas correctamente"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7328dc50933ebb5f', 'text', 'es', 'Compra aprobada. Saldo bancario actualizado.', '{"label": "Compra aprobada. Saldo bancario actualizado."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'dbf0aeaa35eedeea', 'text', 'es', 'Compra registrada. Pendiente de aprobacion.', '{"label": "Compra registrada. Pendiente de aprobacion."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a5ade86dbc366fe7', 'text', 'es', 'Configuracion actualizada', '{"label": "Configuracion actualizada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f9506d7507a19d69', 'text', 'es', 'Configuracion de descubrimiento actualizada', '{"label": "Configuracion de descubrimiento actualizada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '294df144f173f9dc', 'text', 'es', 'Configuracion de impuestos actualizada', '{"label": "Configuracion de impuestos actualizada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '999423015edd3740', 'text', 'es', 'Configuracion de quorum actualizada', '{"label": "Configuracion de quorum actualizada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '860de24132647610', 'text', 'es', 'Configuracion del sitio actualizada', '{"label": "Configuracion del sitio actualizada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '26f84654bfd7d56e', 'text', 'es', 'Configuracion generada. Descarga los datos y crea la imagen manualmente.', '{"label": "Configuracion generada. Descarga los datos y crea la imag..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a2d5cf72501250cf', 'text', 'es', 'Configuracion guardada', '{"label": "Configuracion guardada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5e696b2a25132545', 'text', 'es', 'Configuracion guardada. Reinicia YugabyteDB para aplicar los cambios.', '{"label": "Configuracion guardada. Reinicia YugabyteDB para aplicar ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '30324d8ee68edbb6', 'text', 'es', 'Conflicto', '{"label": "Conflicto"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a3098c6b4d3c8eec', 'text', 'es', 'Constantes federadas para heredar al unirse a la federacion', '{"label": "Constantes federadas para heredar al unirse a la federacion"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f3302d514ed65247', 'text', 'es', 'Cuenta bloqueada', '{"label": "Cuenta bloqueada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '192bfa1055f848ef', 'text', 'es', 'Cuenta deshabilitada', '{"label": "Cuenta deshabilitada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'dd681ba4a05499db', 'text', 'es', 'Defensa aceptada. Solicitud elevada a asamblea.', '{"label": "Defensa aceptada. Solicitud elevada a asamblea."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7e8d08b7f85b90ef', 'text', 'es', 'Defensa enviada. La comision revisara tu respuesta.', '{"label": "Defensa enviada. La comision revisara tu respuesta."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd39b97eecda39221', 'text', 'es', 'Defensa rechazada. El rechazo se mantiene.', '{"label": "Defensa rechazada. El rechazo se mantiene."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2806cf49e0fea55a', 'text', 'es', 'Demasiadas peticiones', '{"label": "Demasiadas peticiones"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e87bef928e3cdf8c', 'text', 'es', 'Documento agregado', '{"label": "Documento agregado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3b45f28177f5d1e5', 'text', 'es', 'El banco de semillas funciona con prestamo y devolucion. Devuelve mas de lo que tomaste para que el banco crezca.', '{"label": "El banco de semillas funciona con prestamo y devolucion. ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ab1fad14d6cfaff5', 'text', 'es', 'El check-in no esta abierto', '{"label": "El check-in no esta abierto"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '662725008db5aba4', 'text', 'es', 'El check-out no esta abierto', '{"label": "El check-out no esta abierto"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '600dd282a00a14fb', 'text', 'es', 'El dominio no puede ser ''localhost'' ni ''__LOCAL__''', '{"label": "El dominio no puede ser ''localhost'' ni ''__LOCAL__''"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '27b0d0b78ddaf4bc', 'text', 'es', 'El dominio no se puede cambiar en el nodo demo. Se hereda del nodo padre.', '{"label": "El dominio no se puede cambiar en el nodo demo. Se hereda..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cbd3200800af3b7d', 'text', 'es', 'El nivel destino no existe. Contacta al administrador.', '{"label": "El nivel destino no existe. Contacta al administrador."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0809b066896ec2ae', 'text', 'es', 'El nodo ya tiene claves WireGuard', '{"label": "El nodo ya tiene claves WireGuard"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '554d5126c9d45562', 'text', 'es', 'El nombre de usuario debe tener al menos 3 caracteres', '{"label": "El nombre de usuario debe tener al menos 3 caracteres"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9b8436ca9b74dd17', 'text', 'es', 'El nombre de usuario ya esta en uso', '{"label": "El nombre de usuario ya esta en uso"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd3c8d30d511a797d', 'text', 'es', 'El nombre de usuario ya existe. Elige otro.', '{"label": "El nombre de usuario ya existe. Elige otro."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9ebc0b0b7ed0bf93', 'text', 'es', 'Elija el codigo que le comunico el nodo nuevo por telefono. Solo uno es correcto.', '{"label": "Elija el codigo que le comunico el nodo nuevo por telefon..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '841c9379e126d74e', 'text', 'es', 'Elija el codigo que le comunico el nodo nuevo. Solo uno es correcto.', '{"label": "Elija el codigo que le comunico el nodo nuevo. Solo uno e..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '87103e11be53f8bf', 'text', 'es', 'Elija el codigo que le comunico la persona del POS web.', '{"label": "Elija el codigo que le comunico la persona del POS web."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd9cad7c157d73b1b', 'text', 'es', 'Elija el codigo que le comunico la persona del terminal por telefono. Solo uno es correcto.', '{"label": "Elija el codigo que le comunico la persona del terminal p..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8af2318a155de14b', 'text', 'es', 'Entrada invalida', '{"label": "Entrada invalida"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0cb7b320496887ac', 'text', 'es', 'Envia este challenge a la tarjeta (DESFire EV3). La tarjeta respondera con AES(challenge, key). Envía la respuesta a /verify-response.', '{"label": "Envia este challenge a la tarjeta (DESFire EV3). La tarje..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '09efd6c5d5d9579c', 'text', 'es', 'Error de base de datos', '{"label": "Error de base de datos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6f5b887603276a48', 'text', 'es', 'Error de red', '{"label": "Error de red"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ebf6090551ce5d69', 'text', 'es', 'Error del servidor', '{"label": "Error del servidor"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b0a8cf468a90acf1', 'text', 'es', 'Error en el pago', '{"label": "Error en el pago"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '69084d94b80c8464', 'text', 'es', 'Error en la transferencia', '{"label": "Error en la transferencia"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '434e81de0cdbb7ef', 'text', 'es', 'Error leyendo estado de actualizacion', '{"label": "Error leyendo estado de actualizacion"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd648afe3869782cd', 'text', 'es', 'Estado de actualizacion reseteado.', '{"label": "Estado de actualizacion reseteado."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '79962740932d83a7', 'text', 'es', 'Estas sobre el limite de credito', '{"label": "Estas sobre el limite de credito"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '63662a1c162e76de', 'text', 'es', 'Felicidades! Has ascendido de nivel.', '{"label": "Felicidades! Has ascendido de nivel."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f12c9c0f7902721d', 'text', 'es', 'Formato invalido', '{"label": "Formato invalido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '550009d562b52620', 'text', 'es', 'Formulario de admision actualizado con exito', '{"label": "Formulario de admision actualizado con exito"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c32d73538f403546', 'text', 'es', 'IPv6 ULA no generado. Genera el prefijo ULA primero.', '{"label": "IPv6 ULA no generado. Genera el prefijo ULA primero."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '60c7749b8ce6abd6', 'text', 'es', 'Idioma requerido', '{"label": "Idioma requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b32d237c55428576', 'text', 'es', 'Iniciando arranque del nodo demo. Consulta /api/demo/start/status para ver el progreso.', '{"label": "Iniciando arranque del nodo demo. Consulta /api/demo/star..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '17d525a392876cba', 'text', 'es', 'JSON invalido', '{"label": "JSON invalido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c3f85305f78f70fb', 'text', 'es', 'La contrasena debe tener al menos 8 caracteres', '{"label": "La contrasena debe tener al menos 8 caracteres"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6fda86c748f9eb14', 'text', 'es', 'La cuenta de impuestos es la Asamblea General. Se le puede transferir usando: asamblea, impuestos o fondo_comunitario.', '{"label": "La cuenta de impuestos es la Asamblea General. Se le pued..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '19fa72af43d1301d', 'text', 'es', 'Las contrasenas no coinciden', '{"label": "Las contrasenas no coinciden"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '68c9c00ef7ff3b64', 'text', 'es', 'MAC invalido. La tarjeta puede ser falsa o clonada.', '{"label": "MAC invalido. La tarjeta puede ser falsa o clonada."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9aa87dfd4fd8de68', 'text', 'es', 'Minuta guardada', '{"label": "Minuta guardada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '82732cec29325b78', 'text', 'es', 'Muestra este codigo QR al encargado de la cayapa para registrar tu asistencia.', '{"label": "Muestra este codigo QR al encargado de la cayapa para reg..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '05273f5e561dc747', 'text', 'es', 'NTAG424 SUN verificado. Tarjeta autenticada criptograficamente.', '{"label": "NTAG424 SUN verificado. Tarjeta autenticada criptografica..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6ddf1dd3aa976d22', 'text', 'es', 'Namespace requerido', '{"label": "Namespace requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '50764838e155dbb0', 'text', 'es', 'Nivel actualizado', '{"label": "Nivel actualizado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b979c00354210b7b', 'text', 'es', 'Nivel creado', '{"label": "Nivel creado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd440d801cbc90e56', 'text', 'es', 'Nivel de organizacion actualizado', '{"label": "Nivel de organizacion actualizado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'feba95d358e24c71', 'text', 'es', 'Nivel de organizacion creado', '{"label": "Nivel de organizacion creado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c1943897d2c713b1', 'text', 'es', 'No encontrado', '{"label": "No encontrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '29975687c471e45b', 'text', 'es', 'No hay actualizacion en curso.', '{"label": "No hay actualizacion en curso."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ce85e055dca707a0', 'text', 'es', 'No hay configuracion de Comercio Exterior. La Asamblea debe crear la organizacion DEX.', '{"label": "No hay configuracion de Comercio Exterior. La Asamblea de..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '84aa55b595e200b1', 'text', 'es', 'No hay configuracion de impuestos. La asamblea debe aprobar una propuesta de cambio de impuestos.', '{"label": "No hay configuracion de impuestos. La asamblea debe aprob..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '37bb75a95e5d3a42', 'text', 'es', 'No hay contenido por defecto para esta pagina', '{"label": "No hay contenido por defecto para esta pagina"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '181d7e53e5c9e68c', 'text', 'es', 'No hay cuenta de Asamblea General. El Fondo Comunitario es la cuenta de la Asamblea.', '{"label": "No hay cuenta de Asamblea General. El Fondo Comunitario e..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5ca4356bde7626be', 'text', 'es', 'No hay cuenta de Asamblea configurada. La cuenta de la Asamblea es la misma que recibe impuestos y el Fondo Comunitario.', '{"label": "No hay cuenta de Asamblea configurada. La cuenta de la As..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b5358848e1c64009', 'text', 'es', 'No se encontro tu nivel. Pide a la asamblea que te asigne un nivel.', '{"label": "No se encontro tu nivel. Pide a la asamblea que te asigne..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '613cd4cdb725f606', 'text', 'es', 'No se puede actualizar el nodo demo directamente.', '{"label": "No se puede actualizar el nodo demo directamente."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '38e4adb0244a3a4e', 'text', 'es', 'No se puede configurar VoIP en el nodo demo.', '{"label": "No se puede configurar VoIP en el nodo demo."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '92bb4ba2cb5810ff', 'text', 'es', 'No se puede eliminar el idioma por defecto', '{"label": "No se puede eliminar el idioma por defecto"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3bc78a5e597bf5b1', 'text', 'es', 'No se puede modificar la configuracion de red en el nodo demo.', '{"label": "No se puede modificar la configuracion de red en el nodo ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '828c292ce5392aa6', 'text', 'es', 'No se pueden desinstalar servicios en el nodo demo.', '{"label": "No se pueden desinstalar servicios en el nodo demo."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0a0198ce0b2e5042', 'text', 'es', 'No se pueden detener servicios en el nodo demo.', '{"label": "No se pueden detener servicios en el nodo demo."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '15e49e18bdd3fc3b', 'text', 'es', 'No se pueden iniciar servicios en el nodo demo.', '{"label": "No se pueden iniciar servicios en el nodo demo."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '332509cee2c3f4b2', 'text', 'es', 'No se pueden instalar servicios en el nodo demo. Los servicios se instalan desde el nodo padre.', '{"label": "No se pueden instalar servicios en el nodo demo. Los serv..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ed974629cd33a9ad', 'text', 'es', 'No se pueden reiniciar servicios en el nodo demo.', '{"label": "No se pueden reiniciar servicios en el nodo demo."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1af2a29cc94a138e', 'text', 'es', 'No tienes check-in registrado', '{"label": "No tienes check-in registrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c06d57da4643b0f2', 'text', 'es', 'No tienes permiso para realizar esta accion', '{"label": "No tienes permiso para realizar esta accion"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a70cf2c407b2a915', 'text', 'es', 'No tienes un nivel asignado. Pide a la asamblea que te asigne un nivel.', '{"label": "No tienes un nivel asignado. Pide a la asamblea que te as..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e950cbe6b4d0d8a3', 'text', 'es', 'Node initialized successfully', '{"label": "Node initialized successfully"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0dd578d1709191b6', 'text', 'es', 'Nodo arrancado', '{"label": "Nodo arrancado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd4bd14374a7ac9b5', 'text', 'es', 'Nodo creado. Descarga el script de instalacion y ejecutalo en el servidor remoto.', '{"label": "Nodo creado. Descarga el script de instalacion y ejecutal..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '143d620413f97b63', 'text', 'es', 'Nodo demo recreado con la ultima version. Los datos se estan regenerando.', '{"label": "Nodo demo recreado con la ultima version. Los datos se es..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cba0b2bdf4dc466e', 'text', 'es', 'Nodo detenido', '{"label": "Nodo detenido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e0a563c1b4381510', 'text', 'es', 'Nodo reiniciado', '{"label": "Nodo reiniciado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c967062e896ddd30', 'text', 'es', 'Nueva clave generada. Escribe esta clave en la tarjeta. El contador SUN se reinicio.', '{"label": "Nueva clave generada. Escribe esta clave en la tarjeta. E..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9fa6066d7134d470', 'text', 'es', 'Nueva clave generada. Escribela en la tarjeta y confirma con /confirm-rotation.', '{"label": "Nueva clave generada. Escribela en la tarjeta y confirma ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a0a4fb3934eb5a5d', 'text', 'es', 'OpenWrt no configurado. Configura la direccion y dominio de OpenWrt primero.', '{"label": "OpenWrt no configurado. Configura la direccion y dominio ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'acffe13476240cab', 'text', 'es', 'PIN del turno configurado correctamente', '{"label": "PIN del turno configurado correctamente"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '380559c812d62a96', 'text', 'es', 'PIN del turno incorrecto', '{"label": "PIN del turno incorrecto"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'da90c95d7beda55b', 'text', 'es', 'PIN incorrecto', '{"label": "PIN incorrecto"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cac342270ccb9443', 'text', 'es', 'PIN must be between 4 and 32 characters', '{"label": "PIN must be between 4 and 32 characters"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd8040a8039bec4c0', 'text', 'es', 'Pagina actualizada', '{"label": "Pagina actualizada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '256317fd65e8ab59', 'text', 'es', 'Pagina creada', '{"label": "Pagina creada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '996b9b506f94f669', 'text', 'es', 'Pagina eliminada', '{"label": "Pagina eliminada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b2d978d11a904bbc', 'text', 'es', 'Pagina guardada con exito', '{"label": "Pagina guardada con exito"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4958d7c3839165d6', 'text', 'es', 'Pagina restablecida al contenido por defecto', '{"label": "Pagina restablecida al contenido por defecto"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '72f30933e4615ec1', 'text', 'es', 'Pago ejecutado correctamente', '{"label": "Pago ejecutado correctamente"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '740cdd1bf768f01a', 'text', 'es', 'Pais agregado', '{"label": "Pais agregado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '10a33da51cccc0fb', 'text', 'es', 'Parametro actualizado. Pendiente de reaprobacion.', '{"label": "Parametro actualizado. Pendiente de reaprobacion."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5cbe983a49d5ee06', 'text', 'es', 'Parametro aprobado', '{"label": "Parametro aprobado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd0d2d4d73cfc1e00', 'text', 'es', 'Parametro creado. Pendiente de aprobacion de asamblea.', '{"label": "Parametro creado. Pendiente de aprobacion de asamblea."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3eca33e5ea80cbe9', 'text', 'es', 'Pasarela PSTN creada. Las llamadas externas usaran esta pasarela.', '{"label": "Pasarela PSTN creada. Las llamadas externas usaran esta p..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'deecebbc93ada227', 'text', 'es', 'Passkey invalido', '{"label": "Passkey invalido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '53c40d11a295b38a', 'text', 'es', 'Passkey no encontrado', '{"label": "Passkey no encontrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '30df47cf3a081de5', 'text', 'es', 'Passkey registered successfully. User account pending admission approval.', '{"label": "Passkey registered successfully. User account pending adm..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f76cd9db7c98c58b', 'text', 'es', 'Passkey registrado correctamente.', '{"label": "Passkey registrado correctamente."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b33acdc3f24daf80', 'text', 'es', 'Peer registrado. Para federacion activa, el otro nodo tambien debe registrar tu clave publica.', '{"label": "Peer registrado. Para federacion activa, el otro nodo tam..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a6af067de8601271', 'text', 'es', 'Peticion invalida', '{"label": "Peticion invalida"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a17d0d8efb8be0fa', 'text', 'es', 'Pida al administrador que apruebe este codigo en su panel.', '{"label": "Pida al administrador que apruebe este codigo en su panel."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fd8a3aca816c66b0', 'text', 'es', 'Pide al dueno del terminal que apruebe este codigo en su cuenta.', '{"label": "Pide al dueno del terminal que apruebe este codigo en su ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c62a0e2ebfeffd3c', 'text', 'es', 'Presencia confirmada. Gracias por validar tu asistencia.', '{"label": "Presencia confirmada. Gracias por validar tu asistencia."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '91f24029738899e4', 'text', 'es', 'Producto actualizado', '{"label": "Producto actualizado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '58b88b11789e9b71', 'text', 'es', 'Producto aprobado por la asamblea. Se ha notificado a los nodos federados para su aprobacion individual.', '{"label": "Producto aprobado por la asamblea. Se ha notificado a los..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3e09169049f85685', 'text', 'es', 'Producto creado. Pendiente de aprobacion de la asamblea.', '{"label": "Producto creado. Pendiente de aprobacion de la asamblea."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '244105075cf016f0', 'text', 'es', 'Producto desaprobado. Sigue visible en la Federacion pero no esta aprobado.', '{"label": "Producto desaprobado. Sigue visible en la Federacion pero..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '83e307e857cb8909', 'text', 'es', 'Producto federado aprobado y agregado al catalogo local', '{"label": "Producto federado aprobado y agregado al catalogo local"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '96da3a196a4162b6', 'text', 'es', 'Producto promovido a producto base. Ahora aparece en toda la federacion y puede usarse como ingrediente.', '{"label": "Producto promovido a producto base. Ahora aparece en toda..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '49a8ddfbb3cb5a4b', 'text', 'es', 'Producto rechazado y ocultado del catalogo.', '{"label": "Producto rechazado y ocultado del catalogo."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '30948754033d8253', 'text', 'es', 'Productor agregado', '{"label": "Productor agregado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '780bbc8b5fb40b61', 'text', 'es', 'Propuesta aprobada y ejecutada directamente', '{"label": "Propuesta aprobada y ejecutada directamente"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1206cff12c103bbe', 'text', 'es', 'Propuesta creada. Gracias por aportar!', '{"label": "Propuesta creada. Gracias por aportar!"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '89cb097172b5337c', 'text', 'es', 'Propuesta creada. La asamblea debe aprobarla para abrir la votacion.', '{"label": "Propuesta creada. La asamblea debe aprobarla para abrir l..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '71080ca065106e9f', 'text', 'es', 'Propuesta creada. La asamblea debe revisarla y abrir la votacion.', '{"label": "Propuesta creada. La asamblea debe revisarla y abrir la v..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '01f11283be15d3dd', 'text', 'es', 'Propuesta creada. La modificacion se aplicara cuando la asamblea la apruebe.', '{"label": "Propuesta creada. La modificacion se aplicara cuando la a..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '80733956ea0ca2e8', 'text', 'es', 'Propuesta creada. La regla se eliminara cuando la asamblea lo apruebe.', '{"label": "Propuesta creada. La regla se eliminara cuando la asamble..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '02e9b9312b8f505c', 'text', 'es', 'Propuesta creada. Se compartira con los nodos federados para votacion.', '{"label": "Propuesta creada. Se compartira con los nodos federados p..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a74f072d7aa74019', 'text', 'es', 'Propuesta eliminada', '{"label": "Propuesta eliminada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ee1368da85440323', 'text', 'es', 'Propuesta recibida', '{"label": "Propuesta recibida"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e6355049a65e34e3', 'text', 'es', 'Recalculo de canasta aprobado. FC actualizado.', '{"label": "Recalculo de canasta aprobado. FC actualizado."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7a0b024f2c6eb214', 'text', 'es', 'Recarga solicitada. Un administrador debe confirmarla.', '{"label": "Recarga solicitada. Un administrador debe confirmarla."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '632ef3e21c27c9af', 'text', 'es', 'Respuesta enviada. Recuerda: la federacion se hace personalmente compartiendo las claves publicas, no automaticamente por el sistema.', '{"label": "Respuesta enviada. Recuerda: la federacion se hace person..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '62aeed4e5b91c515', 'text', 'es', 'Rotacion confirmada. Nueva clave activa. Transaccion puede proceder.', '{"label": "Rotacion confirmada. Nueva clave activa. Transaccion pued..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b5ff2e24587db9d3', 'text', 'es', 'Rotacion descartada. Clave vieja K sigue activa.', '{"label": "Rotacion descartada. Clave vieja K sigue activa."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd4026afe1dd8f7a7', 'text', 'es', 'Rotacion recuperada. K'' es ahora la clave activa.', '{"label": "Rotacion recuperada. K'' es ahora la clave activa."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2f118d1b3d23f992', 'text', 'es', 'Rotacion ya pendiente. Usa esta clave para escribir en la tarjeta.', '{"label": "Rotacion ya pendiente. Usa esta clave para escribir en la..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a494461cca3ce85e', 'text', 'es', 'Saldo insuficiente', '{"label": "Saldo insuficiente"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9ff79a31c3a2453c', 'text', 'es', 'Se requiere permiso especial', '{"label": "Se requiere permiso especial"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '02dabe4376c236e2', 'text', 'es', 'Servicio con imagen externa. Usa ''Actualizar'' para forzar descarga de nueva imagen.', '{"label": "Servicio con imagen externa. Usa ''Actualizar'' para forzar..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9fdc4d7dace63398', 'text', 'es', 'Servicio desinstalado', '{"label": "Servicio desinstalado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '80a15ae22b4abdd5', 'text', 'es', 'Servicio detenido', '{"label": "Servicio detenido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '38539fc60b081d14', 'text', 'es', 'Servicio iniciado', '{"label": "Servicio iniciado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4005be4119b4383d', 'text', 'es', 'Servicio reiniciado', '{"label": "Servicio reiniciado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b76966a343b97b4f', 'text', 'es', 'Sesion actualizada', '{"label": "Sesion actualizada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '28444bf61e18c093', 'text', 'es', 'Sesion creada', '{"label": "Sesion creada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1ffbd0f2608f0f77', 'text', 'es', 'Sesion expirada', '{"label": "Sesion expirada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bed40562d6a172f8', 'text', 'es', 'Sesion iniciada', '{"label": "Sesion iniciada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3940d37a6f70d763', 'text', 'es', 'Sistema en mantenimiento', '{"label": "Sistema en mantenimiento"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1feb44cfbf56231e', 'text', 'es', 'Solicitud creada. Comunique este codigo al nodo padrino por un canal seguro (telefono, mensaje). El padrino vera 4 opciones y debe elegir la correcta.', '{"label": "Solicitud creada. Comunique este codigo al nodo padrino p..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '408a208870d3d10c', 'text', 'es', 'Solicitud de contacto recibida. La federacion se hace personalmente compartiendo las claves publicas, no automaticamente.', '{"label": "Solicitud de contacto recibida. La federacion se hace per..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'df97b96f1c20dec2', 'text', 'es', 'Solicitud elevada a asamblea para votacion', '{"label": "Solicitud elevada a asamblea para votacion"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7375fc0daae913d8', 'text', 'es', 'Solicitud enviada. Puedes iniciar sesion con tu usuario y contrasena para ver el estado de tu solicitud.', '{"label": "Solicitud enviada. Puedes iniciar sesion con tu usuario y..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '56145c5e34063988', 'text', 'es', 'Solicitud rechazada. El postulante tiene 30 dias para enviar una defensa.', '{"label": "Solicitud rechazada. El postulante tiene 30 dias para env..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4824a3930c137a43', 'text', 'es', 'Tarifa actualizada', '{"label": "Tarifa actualizada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '90a9bf9f1ca4916d', 'text', 'es', 'Tarjeta autenticada criptograficamente. Es legitima.', '{"label": "Tarjeta autenticada criptograficamente. Es legitima."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2e8fb02f445d3406', 'text', 'es', 'Tarjeta bloqueada criptograficamente. No podra usarse para pagos.', '{"label": "Tarjeta bloqueada criptograficamente. No podra usarse par..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f4897fe9ca50ad89', 'text', 'es', 'Tarjeta desactivada', '{"label": "Tarjeta desactivada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '50be5e5c04c437a0', 'text', 'es', 'Tarjeta marcada como inicializada correctamente.', '{"label": "Tarjeta marcada como inicializada correctamente."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '913c7e47c304e153', 'text', 'es', 'Tarjeta no encontrada', '{"label": "Tarjeta no encontrada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a56a124b9fc03209', 'text', 'es', 'Tarjeta sin clave criptografica (modo uid_only)', '{"label": "Tarjeta sin clave criptografica (modo uid_only)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'affa58aa262d1028', 'text', 'es', 'Terminal existe pero no esta registrado o inactivo.', '{"label": "Terminal existe pero no esta registrado o inactivo."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '082cae4ac72d88ea', 'text', 'es', 'Terminal no encontrado en el servidor.', '{"label": "Terminal no encontrado en el servidor."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0bf729ba735e322c', 'text', 'es', 'Terminal registrado y activo.', '{"label": "Terminal registrado y activo."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2ae13184993603bc', 'text', 'es', 'Tiempo agotado. El pago ha sido anulado.', '{"label": "Tiempo agotado. El pago ha sido anulado."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a6b58412839565b7', 'text', 'es', 'Traducción guardada con éxito', '{"label": "Traducción guardada con éxito"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b27c1845c1f6209a', 'text', 'es', 'Tu cuenta esta pendiente de aprobacion. Solo puedes ver el estado de tu solicitud.', '{"label": "Tu cuenta esta pendiente de aprobacion. Solo puedes ver e..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3999db8b461b1a0b', 'text', 'es', 'Tu nivel actual no tiene auto-ascenso configurado.', '{"label": "Tu nivel actual no tiene auto-ascenso configurado."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '464f451dfab953c5', 'text', 'es', 'Una asamblea rechazo la propuesta. La federacion queda bloqueada hasta resolver.', '{"label": "Una asamblea rechazo la propuesta. La federacion queda bl..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7ab96ba4a7afdcc0', 'text', 'es', 'Usuario demo: no tienes permiso para modificar datos. Puedes navegar pero no guardar cambios.', '{"label": "Usuario demo: no tienes permiso para modificar datos. Pue..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0de2ad3c64e701ed', 'text', 'es', 'Usuario o contrasena incorrectos', '{"label": "Usuario o contrasena incorrectos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '360ef59f8669db5f', 'text', 'es', 'Valor demasiado grande', '{"label": "Valor demasiado grande"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'dada824dd437a3b0', 'text', 'es', 'Valor demasiado pequeno', '{"label": "Valor demasiado pequeno"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7e59a3a725252778', 'text', 'es', 'Venta aprobada. Saldo bancario actualizado.', '{"label": "Venta aprobada. Saldo bancario actualizado."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a5c66e70cbf095b2', 'text', 'es', 'Venta registrada. Pendiente de aprobacion.', '{"label": "Venta registrada. Pendiente de aprobacion."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f4ecad0977a3fcff', 'text', 'es', 'Votacion abierta', '{"label": "Votacion abierta"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3f8e5139808881eb', 'text', 'es', 'Votacion abierta. Los miembros pueden votar ahora.', '{"label": "Votacion abierta. Los miembros pueden votar ahora."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3e0a2951416a6aa3', 'text', 'es', 'Voto registrado', '{"label": "Voto registrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '049e2be43e497881', 'text', 'es', 'Voto registrado. Pendiente voto de la otra asamblea.', '{"label": "Voto registrado. Pendiente voto de la otra asamblea."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ec61fbcd39110eed', 'text', 'es', 'Voto remoto registrado', '{"label": "Voto remoto registrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9ed1f083194985d4', 'text', 'es', 'Ya existe', '{"label": "Ya existe"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '97481db02565369d', 'text', 'es', 'Ya hay un arranque en curso', '{"label": "Ya hay un arranque en curso"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '478f0677cf140bcc', 'text', 'es', 'Ya hay una actualizacion en curso. Espera a que termine o cancelala.', '{"label": "Ya hay una actualizacion en curso. Espera a que termine o..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4091a038f28552c2', 'text', 'es', 'Ya tienes una solicitud de admisión pendiente. Espera la respuesta de la asamblea.', '{"label": "Ya tienes una solicitud de admisión pendiente. Espera la ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e4047a3e181ae7da', 'text', 'es', 'account not found', '{"label": "account not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0a376277bea5d6dd', 'text', 'es', 'account parameter required', '{"label": "account parameter required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2b97dc95663f914a', 'text', 'es', 'account_id is required', '{"label": "account_id is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd931d175af5c30ec', 'text', 'es', 'account_name is required', '{"label": "account_name is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7f0e5ec8dcefe24c', 'text', 'es', 'action debe ser ''accept'' o ''reject''', '{"label": "action debe ser ''accept'' o ''reject''"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '69e8dc85fb60a1e1', 'text', 'es', 'admin_password must be at least 8 characters', '{"label": "admin_password must be at least 8 characters"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fe6bbb869ec44daa', 'text', 'es', 'admin_username is required', '{"label": "admin_username is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '735b923c78799b71', 'text', 'es', 'admission form not found', '{"label": "admission form not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ecca8e48702c257d', 'text', 'es', 'amount debe ser positivo', '{"label": "amount debe ser positivo"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5cf4badd8cf22c70', 'text', 'es', 'amount must be positive', '{"label": "amount must be positive"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ea165608757d5330', 'text', 'es', 'amount must be positive for POS QR', '{"label": "amount must be positive for POS QR"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'db80f1e4e0c283f6', 'text', 'es', 'archivo ''package'' no encontrado en el upload', '{"label": "archivo ''package'' no encontrado en el upload"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '27334cda73e5c0fd', 'text', 'es', 'archivo vacio', '{"label": "archivo vacio"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd603e4994160ed81', 'text', 'es', 'authentication required', '{"label": "authentication required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5e25dc5cb07e73da', 'text', 'es', 'authorization header required', '{"label": "authorization header required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2a8478f7003b02bd', 'text', 'es', 'backup ''tables'' field is not an object', '{"label": "backup ''tables'' field is not an object"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cdcde7d8f6a2a359', 'text', 'es', 'backup bloqueado', '{"label": "backup bloqueado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '838dbfced3671841', 'text', 'es', 'backup borrado', '{"label": "backup borrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cd4b3f4179276b0d', 'text', 'es', 'backup desbloqueado', '{"label": "backup desbloqueado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '45aa1000f4dc0e6a', 'text', 'es', 'backup missing ''tables'' field', '{"label": "backup missing ''tables'' field"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3cf007a9281ebd1e', 'text', 'es', 'backup no encontrado', '{"label": "backup no encontrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8ce75fefceddbe12', 'text', 'es', 'balance_action must be combine, forgive_debt, or remove_balance', '{"label": "balance_action must be combine, forgive_debt, or remove_b..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '51f52f22ef6c00ef', 'text', 'es', 'bilateral limit not found', '{"label": "bilateral limit not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd6434fdc75544970', 'text', 'es', 'both assemblies must approve before executing', '{"label": "both assemblies must approve before executing"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5734cbc46e9f9f38', 'text', 'es', 'build_id parameter is required', '{"label": "build_id parameter is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8c4956222ea8ea3e', 'text', 'es', 'calendar_date y day_type son requeridos', '{"label": "calendar_date y day_type son requeridos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8bc3b69681ed3ff7', 'text', 'es', 'cannot delete a proposal that has already been approved or is in voting', '{"label": "cannot delete a proposal that has already been approved o..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1b736e859fe3ee7a', 'text', 'es', 'cannot delete default language', '{"label": "cannot delete default language"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd42358bb59fca294', 'text', 'es', 'cannot pay yourself', '{"label": "cannot pay yourself"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '51aa36649de2082e', 'text', 'es', 'cannot register self as peer', '{"label": "cannot register self as peer"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5bfad40214df36da', 'text', 'es', 'card uid is required', '{"label": "card uid is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b3ab9ddb02fb4b22', 'text', 'es', 'cardUID is required', '{"label": "cardUID is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6b0170e708c6cd15', 'text', 'es', 'card_uid and initial_pin are required', '{"label": "card_uid and initial_pin are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2c7ba9150b4e6105', 'text', 'es', 'card_uid is required', '{"label": "card_uid is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ef1de1c2e46079d6', 'text', 'es', 'card_uid y user_id son requeridos', '{"label": "card_uid y user_id son requeridos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a8ff733de1a1d00e', 'text', 'es', 'card_uid, old_pin and new_pin are required', '{"label": "card_uid, old_pin and new_pin are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '73b187657c203cd1', 'text', 'es', 'category id and language required', '{"label": "category id and language required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '69a2eb8d2db27bf4', 'text', 'es', 'category id required', '{"label": "category id required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '35eb0f2013926a32', 'text', 'es', 'category is required', '{"label": "category is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '21eee64bbe81d95c', 'text', 'es', 'category, title y description son obligatorios', '{"label": "category, title y description son obligatorios"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cf2feecc77377382', 'text', 'es', 'category_name es requerido', '{"label": "category_name es requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '550481caa8324a2e', 'text', 'es', 'category_name is required', '{"label": "category_name is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9527d0baa4757116', 'text', 'es', 'challenge expirado', '{"label": "challenge expirado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '865235bdb10e3652', 'text', 'es', 'challenge no encontrado', '{"label": "challenge no encontrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '683a042c4cd04d80', 'text', 'es', 'challenge ya usado (posible replay attack)', '{"label": "challenge ya usado (posible replay attack)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3bcf669364c997bf', 'text', 'es', 'charge has expired', '{"label": "charge has expired"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a10774a87c32001b', 'text', 'es', 'charge id is required', '{"label": "charge id is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '46075d76724720f7', 'text', 'es', 'charge not found', '{"label": "charge not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '833c941072c3bbcf', 'text', 'es', 'charge not found or expired', '{"label": "charge not found or expired"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e3558ed94c8f154c', 'text', 'es', 'chip-id-reader.ino not found on server', '{"label": "chip-id-reader.ino not found on server"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '88f7a06f90987ba4', 'text', 'es', 'chip_id is required (12 hex chars from ESP.getEfuseMac)', '{"label": "chip_id is required (12 hex chars from ESP.getEfuseMac)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '33bf87059ed63e1e', 'text', 'es', 'chip_id must be 12 hex characters (e.g. AABBCCDDEEFF)', '{"label": "chip_id must be 12 hex characters (e.g. AABBCCDDEEFF)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '93ff434ffd59fa30', 'text', 'es', 'code is required', '{"label": "code is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '16cdc2e664ff9396', 'text', 'es', 'code is required and max 10 chars', '{"label": "code is required and max 10 chars"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e617f4ef353c578c', 'text', 'es', 'code must be at least 4 characters', '{"label": "code must be at least 4 characters"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cc0bd1b50d61c976', 'text', 'es', 'code required', '{"label": "code required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8316daf8a387b1a9', 'text', 'es', 'config id and language required', '{"label": "config id and language required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f78984d6dfa53d3c', 'text', 'es', 'config id required', '{"label": "config id required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ab5c15cb834fd572', 'text', 'es', 'configuracion actualizada', '{"label": "configuracion actualizada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '885acb2857351beb', 'text', 'es', 'conflict is not resolved. Both assemblies must approve first.', '{"label": "conflict is not resolved. Both assemblies must approve fi..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '84b370222f20b625', 'text', 'es', 'conflict not found', '{"label": "conflict not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0f6910df7ab49054', 'text', 'es', 'constant key and language required', '{"label": "constant key and language required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '763fe8b2264e3d7d', 'text', 'es', 'constant key required', '{"label": "constant key required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e36cd76fc0dbe07b', 'text', 'es', 'constante no encontrada', '{"label": "constante no encontrada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e8d5a5561c658b70', 'text', 'es', 'country_iso2 es obligatorio (se necesita el pais para evitar duplicados)', '{"label": "country_iso2 es obligatorio (se necesita el pais para evi..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6b42ae9be727bfe9', 'text', 'es', 'credenciales invalidas', '{"label": "credenciales invalidas"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5b19b16da95d88fb', 'text', 'es', 'database not available', '{"label": "database not available"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ca6a7346085853f0', 'text', 'es', 'date and time are required. Cannot create an assembly for ''right now''.', '{"label": "date and time are required. Cannot create an assembly for..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9d962daf76ae78f7', 'text', 'es', 'date requerido', '{"label": "date requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0f79657819c1516a', 'text', 'es', 'date_format invalido: debe ser DD/MM/YYYY, MM/DD/YYYY o YYYY-MM-DD', '{"label": "date_format invalido: debe ser DD/MM/YYYY, MM/DD/YYYY o Y..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '70fccddc52237378', 'text', 'es', 'debe agregar al menos un componente', '{"label": "debe agregar al menos un componente"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '749b07e8c86c0cbb', 'text', 'es', 'debes especificar la fecha y hora de la asamblea', '{"label": "debes especificar la fecha y hora de la asamblea"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8249b9e23de534fe', 'text', 'es', 'decision is not pending or approved', '{"label": "decision is not pending or approved"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '29a7b51ab35dc113', 'text', 'es', 'decision not found', '{"label": "decision not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1e73cdc0291db460', 'text', 'es', 'defense_text is required and must be at least 10 characters', '{"label": "defense_text is required and must be at least 10 characters"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a1640d97aeb8a543', 'text', 'es', 'department id is required', '{"label": "department id is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '13d4600bf3af4f49', 'text', 'es', 'description is required', '{"label": "description is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '73c863617a109547', 'text', 'es', 'device_fingerprint is required', '{"label": "device_fingerprint is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c3ca2bc72b551d53', 'text', 'es', 'dia del mes debe estar entre 0 y 28 (0 = cualquier dia)', '{"label": "dia del mes debe estar entre 0 y 28 (0 = cualquier dia)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ed22c99a06e9ad90', 'text', 'es', 'dias de notificacion entre 0 y 60', '{"label": "dias de notificacion entre 0 y 60"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3ea65918d8c44de1', 'text', 'es', 'docker-compose.yml no encontrado para el servicio', '{"label": "docker-compose.yml no encontrado para el servicio"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ea4a698b74f92f6a', 'text', 'es', 'document_type y document_number son obligatorios', '{"label": "document_type y document_number son obligatorios"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1c99bb4ebebeefa1', 'text', 'es', 'documento de identidad no coincide', '{"label": "documento de identidad no coincide"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '348e43b1e5d8ab26', 'text', 'es', 'documento no encontrado', '{"label": "documento no encontrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f3ef320df243c3ed', 'text', 'es', 'documento ya existe o tipo/pais invalido', '{"label": "documento ya existe o tipo/pais invalido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '93769963bfd95bb2', 'text', 'es', 'domain is required', '{"label": "domain is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e28e2d24398d7422', 'text', 'es', 'driver no tiene reader.json', '{"label": "driver no tiene reader.json"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9d269cd2fcef6b9e', 'text', 'es', 'edit the source language through site settings', '{"label": "edit the source language through site settings"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd451179ab39eb1a7', 'text', 'es', 'edit the source language through the admission form editor', '{"label": "edit the source language through the admission form editor"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9e9b020adfd4477b', 'text', 'es', 'edit the source language through the page editor', '{"label": "edit the source language through the page editor"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4912cce759f34f2f', 'text', 'es', 'el archivo debe ser .nfcpkg o .zip', '{"label": "el archivo debe ser .nfcpkg o .zip"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b4efff57b10a5cd8', 'text', 'es', 'el departamento solo puede pertenecer a una organizacion o al nodo/asamblea. No puede pertenecer a una persona.', '{"label": "el departamento solo puede pertenecer a una organizacion ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '256333e7813dd69b', 'text', 'es', 'el dueño del terminal debe configurar el PIN del turno desde su panel web', '{"label": "el dueño del terminal debe configurar el PIN del turno de..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'adcc8a8ffb872c8d', 'text', 'es', 'el dueño del terminal no ha configurado el PIN del turno', '{"label": "el dueño del terminal no ha configurado el PIN del turno"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '541df3a76907fb35', 'text', 'es', 'el monto debe ser mayor que 0', '{"label": "el monto debe ser mayor que 0"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e2639c0d16578099', 'text', 'es', 'el nodo votante no tiene derecho a voto (requiere nivel 2+)', '{"label": "el nodo votante no tiene derecho a voto (requiere nivel 2+)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '12288c772bb3ad0e', 'text', 'es', 'el plazo para enviar defensa ha expirado', '{"label": "el plazo para enviar defensa ha expirado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e156db2dd240d432', 'text', 'es', 'el secretario no te ha marcado como presente', '{"label": "el secretario no te ha marcado como presente"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a7b19072d2d10f93', 'text', 'es', 'el secretario no te ha marcado como presente. Pidele que pase la lista primero.', '{"label": "el secretario no te ha marcado como presente. Pidele que ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8ab3bcfeb6ade40b', 'text', 'es', 'el tiempo de votacion ha expirado', '{"label": "el tiempo de votacion ha expirado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b4248fffafd017ae', 'text', 'es', 'el usuario no tiene registrado ese tipo de documento', '{"label": "el usuario no tiene registrado ese tipo de documento"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3040001b812794e0', 'text', 'es', 'endpoint is required', '{"label": "endpoint is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd45265740b495715', 'text', 'es', 'error adding key', '{"label": "error adding key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '044196aec11c5978', 'text', 'es', 'error adding skill', '{"label": "error adding skill"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6fd2f5baa567ad2c', 'text', 'es', 'error al actualizar', '{"label": "error al actualizar"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '43a66898b6e43639', 'text', 'es', 'error al actualizar configuracion VoIP', '{"label": "error al actualizar configuracion VoIP"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9a326c12f402e176', 'text', 'es', 'error al actualizar propuesta', '{"label": "error al actualizar propuesta"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'acd1e6f99c891890', 'text', 'es', 'error al actualizar saldo', '{"label": "error al actualizar saldo"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '969d339ff64a3f4a', 'text', 'es', 'error al confirmar recarga', '{"label": "error al confirmar recarga"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '28908b8f8fc132ff', 'text', 'es', 'error al crear extension', '{"label": "error al crear extension"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5461f21e63a9b4a4', 'text', 'es', 'error al crear nodo', '{"label": "error al crear nodo"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0e8785ae055494c0', 'text', 'es', 'error al crear pais', '{"label": "error al crear pais"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a96a784aa02bd1db', 'text', 'es', 'error al crear pasarela PSTN', '{"label": "error al crear pasarela PSTN"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'dde3dde6d3d08a57', 'text', 'es', 'error al crear propuesta', '{"label": "error al crear propuesta"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'be5d83fc6db4addc', 'text', 'es', 'error al crear recarga', '{"label": "error al crear recarga"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5fa747baf2a6fca9', 'text', 'es', 'error al crear ruta', '{"label": "error al crear ruta"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0e9085a43c8434e0', 'text', 'es', 'error al eliminar extension', '{"label": "error al eliminar extension"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3b015f6ddc96c3a6', 'text', 'es', 'error al eliminar nodo', '{"label": "error al eliminar nodo"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c46f8d05ee1120f8', 'text', 'es', 'error al eliminar pasarela', '{"label": "error al eliminar pasarela"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '50aa72b5c50f0b78', 'text', 'es', 'error al eliminar ruta', '{"label": "error al eliminar ruta"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2fb4f167666219a6', 'text', 'es', 'error al guardar claves WireGuard', '{"label": "error al guardar claves WireGuard"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'abe4a26af52fa05c', 'text', 'es', 'error al guardar codigo de aldea', '{"label": "error al guardar codigo de aldea"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '61a5a2f216830815', 'text', 'es', 'error al guardar numero de nodo', '{"label": "error al guardar numero de nodo"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '445e5d0bcb7cf084', 'text', 'es', 'error al insertar producto federado', '{"label": "error al insertar producto federado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c1d531d134466284', 'text', 'es', 'error al listar nodos', '{"label": "error al listar nodos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bd4e208b26930dd6', 'text', 'es', 'error al listar servicios instalados', '{"label": "error al listar servicios instalados"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e37dd5ac2b7d148d', 'text', 'es', 'error al no permitir producto', '{"label": "error al no permitir producto"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e9868b2bad4080d5', 'text', 'es', 'error al obtener peers federados', '{"label": "error al obtener peers federados"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'efe18aa6e4acc672', 'text', 'es', 'error al permitir producto', '{"label": "error al permitir producto"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1462afcdb1b48f61', 'text', 'es', 'error al promover producto', '{"label": "error al promover producto"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9e7481d5be413397', 'text', 'es', 'error al rechazar propuesta', '{"label": "error al rechazar propuesta"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2c0bf81c4bb6e304', 'text', 'es', 'error al recibir propuesta remota', '{"label": "error al recibir propuesta remota"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd7558b1bea42076b', 'text', 'es', 'error al registrar voto', '{"label": "error al registrar voto"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '27e845f5a28df403', 'text', 'es', 'error al registrar voto remoto', '{"label": "error al registrar voto remoto"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f7c78e69f444a3ce', 'text', 'es', 'error al sincronizar constantes', '{"label": "error al sincronizar constantes"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3dd7cd1d454ca0c3', 'text', 'es', 'error approving FRNE request', '{"label": "error approving FRNE request"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8684ca07ffc2a0fb', 'text', 'es', 'error approving prohibition', '{"label": "error approving prohibition"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e7027b093db02649', 'text', 'es', 'error approving session', '{"label": "error approving session"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd27c01ea753f9dc2', 'text', 'es', 'error approving transaction', '{"label": "error approving transaction"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '43995f983d684214', 'text', 'es', 'error assigning label', '{"label": "error assigning label"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7eff0366df8d4118', 'text', 'es', 'error blocking card', '{"label": "error blocking card"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a69cedb435875703', 'text', 'es', 'error building net info', '{"label": "error building net info"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd7ce9da6ae429690', 'text', 'es', 'error cancelling FRNE request', '{"label": "error cancelling FRNE request"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5f2b16241f57c3dd', 'text', 'es', 'error cancelling loan', '{"label": "error cancelling loan"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '107433f49a75df7b', 'text', 'es', 'error checking auto-upgrade', '{"label": "error checking auto-upgrade"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '55b44bef0fdb33d0', 'text', 'es', 'error checking out', '{"label": "error checking out"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b587df67d4bdb2c8', 'text', 'es', 'error checking permissions', '{"label": "error checking permissions"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '23b42484b8159b57', 'text', 'es', 'error checking setup status', '{"label": "error checking setup status"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd6efaacea189f4dd', 'text', 'es', 'error checking upgrade eligibility', '{"label": "error checking upgrade eligibility"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '19b63ca944e21192', 'text', 'es', 'error closing check-in', '{"label": "error closing check-in"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd39bcd87af433e8b', 'text', 'es', 'error closing check-out', '{"label": "error closing check-out"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9ec75c18c964bd89', 'text', 'es', 'error confirming rotation', '{"label": "error confirming rotation"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd10e65c9d3dc410c', 'text', 'es', 'error consultando nodos', '{"label": "error consultando nodos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2eceb667a615f6c1', 'text', 'es', 'error creating FRNE request', '{"label": "error creating FRNE request"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1323d2b99b1cf1d0', 'text', 'es', 'error creating cipher', '{"label": "error creating cipher"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a9406bb890865ea9', 'text', 'es', 'error creating language', '{"label": "error creating language"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7fca0f4e5d8e670a', 'text', 'es', 'error creating request to OpenWrt', '{"label": "error creating request to OpenWrt"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '89a35a9b242d6723', 'text', 'es', 'error creating seed loan', '{"label": "error creating seed loan"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '20cd6652a9952f5f', 'text', 'es', 'error creating temp dir', '{"label": "error creating temp dir"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '51dcf55ad45d72dc', 'text', 'es', 'error crediting participant', '{"label": "error crediting participant"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c21019c06790a41f', 'text', 'es', 'error decrypting card key', '{"label": "error decrypting card key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bd19b35f43ef2582', 'text', 'es', 'error decrypting key', '{"label": "error decrypting key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9089c748c4dbbbd8', 'text', 'es', 'error deleting account', '{"label": "error deleting account"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '678e699e59ffda8e', 'text', 'es', 'error deleting calendar entry', '{"label": "error deleting calendar entry"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8e2c05f6cbd764e1', 'text', 'es', 'error deleting label', '{"label": "error deleting label"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'eff34a0e10624854', 'text', 'es', 'error deleting organization catalog rule', '{"label": "error deleting organization catalog rule"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '33771e53536e992e', 'text', 'es', 'error deleting passkey', '{"label": "error deleting passkey"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '241885e2d87869e3', 'text', 'es', 'error deleting rule', '{"label": "error deleting rule"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '785597e1e309466d', 'text', 'es', 'error deleting schedule', '{"label": "error deleting schedule"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '72fe780cc045f264', 'text', 'es', 'error disabling language', '{"label": "error disabling language"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '133f86860c29b241', 'text', 'es', 'error encrypting card key', '{"label": "error encrypting card key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '374c24f89c7eb2d9', 'text', 'es', 'error encrypting key', '{"label": "error encrypting key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '71fbd669dab8e883', 'text', 'es', 'error encrypting new key', '{"label": "error encrypting new key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '238466efff81a8b4', 'text', 'es', 'error executing resolution', '{"label": "error executing resolution"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8134e78be7a00de6', 'text', 'es', 'error generating PDF', '{"label": "error generating PDF"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '01dfa555c87a8ece', 'text', 'es', 'error generating ULA', '{"label": "error generating ULA"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '10726ba0fe109b91', 'text', 'es', 'error generating VAPID keys', '{"label": "error generating VAPID keys"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cf7a4a48aa64ba63', 'text', 'es', 'error generating token', '{"label": "error generating token"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '247c3b7a77a81218', 'text', 'es', 'error getting all sponsorships', '{"label": "error getting all sponsorships"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '18e3b73e341d22b7', 'text', 'es', 'error getting attendance', '{"label": "error getting attendance"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fe2d56ae12fe259c', 'text', 'es', 'error getting balance', '{"label": "error getting balance"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '24712432f2705e07', 'text', 'es', 'error getting federation config', '{"label": "error getting federation config"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ca9d7113df0e4fa4', 'text', 'es', 'error getting history', '{"label": "error getting history"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '01c00ef1ea3cf2bc', 'text', 'es', 'error getting master key', '{"label": "error getting master key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5d07fd3597112b94', 'text', 'es', 'error getting proposals', '{"label": "error getting proposals"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd607924e1b13a793', 'text', 'es', 'error getting sponsorships', '{"label": "error getting sponsorships"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '054da20319e4f3ae', 'text', 'es', 'error getting tariff', '{"label": "error getting tariff"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8f794c990df9b62f', 'text', 'es', 'error getting volume report', '{"label": "error getting volume report"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '600b4d1da4b75d42', 'text', 'es', 'error hashing password', '{"label": "error hashing password"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c27d5cec46ccfd37', 'text', 'es', 'error installing translation', '{"label": "error installing translation"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'deb9abd1dbe4951c', 'text', 'es', 'error listing FRNE requests', '{"label": "error listing FRNE requests"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a5cc2c428d7376bc', 'text', 'es', 'error listing accounts', '{"label": "error listing accounts"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5cce10cb126139a9', 'text', 'es', 'error listing admission requests', '{"label": "error listing admission requests"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '179b5245f8abe725', 'text', 'es', 'error listing attendance', '{"label": "error listing attendance"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '573895e89fddd57c', 'text', 'es', 'error listing bilateral limits', '{"label": "error listing bilateral limits"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ffa8e23031f2989d', 'text', 'es', 'error listing budgets', '{"label": "error listing budgets"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'efa014bdbe988ba8', 'text', 'es', 'error listing catalog rules', '{"label": "error listing catalog rules"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fdabe69e8b6f1d4e', 'text', 'es', 'error listing conflicts', '{"label": "error listing conflicts"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a84f87642e11abc7', 'text', 'es', 'error listing departments', '{"label": "error listing departments"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c5f44efefae95ea4', 'text', 'es', 'error listing labels', '{"label": "error listing labels"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e3188bb3ba185ac4', 'text', 'es', 'error listing member levels', '{"label": "error listing member levels"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6760f8d486dd1453', 'text', 'es', 'error listing node levels', '{"label": "error listing node levels"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9dd077fe6795537a', 'text', 'es', 'error listing nodes', '{"label": "error listing nodes"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '628832051a944323', 'text', 'es', 'error listing organization catalog rules', '{"label": "error listing organization catalog rules"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c6037f2db5d4d40f', 'text', 'es', 'error listing organization levels', '{"label": "error listing organization levels"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '80936f19475b3433', 'text', 'es', 'error listing organization profiles', '{"label": "error listing organization profiles"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a60f116e0df125ca', 'text', 'es', 'error listing organizations', '{"label": "error listing organizations"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '951f7e6cf47c8f3a', 'text', 'es', 'error listing participants', '{"label": "error listing participants"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ee8a7cef95c095d9', 'text', 'es', 'error listing peers', '{"label": "error listing peers"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e5c6e1bb87ded3ea', 'text', 'es', 'error listing pending', '{"label": "error listing pending"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5a9a5e74df2570c5', 'text', 'es', 'error listing presets', '{"label": "error listing presets"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '23ecec952b578c75', 'text', 'es', 'error listing products', '{"label": "error listing products"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0cacfdd32fd9d0e5', 'text', 'es', 'error listing profiles', '{"label": "error listing profiles"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c5439cca74222fdc', 'text', 'es', 'error listing prohibitions', '{"label": "error listing prohibitions"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '700a8c5c2581f947', 'text', 'es', 'error listing seed loans', '{"label": "error listing seed loans"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '397f49c7f838d80b', 'text', 'es', 'error listing services', '{"label": "error listing services"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3540d2d31514bdcc', 'text', 'es', 'error listing sessions', '{"label": "error listing sessions"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4dfa38fbf51f1032', 'text', 'es', 'error listing skills', '{"label": "error listing skills"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2dc7b0618ba62b29', 'text', 'es', 'error listing sponsorships', '{"label": "error listing sponsorships"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e0ad4321f115d04b', 'text', 'es', 'error listing tasks', '{"label": "error listing tasks"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ba389d354a0b3660', 'text', 'es', 'error listing transactions', '{"label": "error listing transactions"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7bcdbea1faf42dd4', 'text', 'es', 'error listing users', '{"label": "error listing users"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e2e2dcf20c24701b', 'text', 'es', 'error obteniendo peers', '{"label": "error obteniendo peers"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8a05d34c88ab9145', 'text', 'es', 'error opening check-in', '{"label": "error opening check-in"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bd95a2a7b11ae6ef', 'text', 'es', 'error opening check-out', '{"label": "error opening check-out"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3ff1ebf8fea9ef5c', 'text', 'es', 'error parsing form', '{"label": "error parsing form"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4728fa14678b6730', 'text', 'es', 'error parsing form data', '{"label": "error parsing form data"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e850e1a7ccc910eb', 'text', 'es', 'error paying installment', '{"label": "error paying installment"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6a5adcb4af582e2d', 'text', 'es', 'error proposing resolution', '{"label": "error proposing resolution"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fc4deaf7332fd4d7', 'text', 'es', 'error querying federated translations', '{"label": "error querying federated translations"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8faa5ea8c8618556', 'text', 'es', 'error querying languages', '{"label": "error querying languages"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8a32dafb617890fd', 'text', 'es', 'error querying passkeys', '{"label": "error querying passkeys"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7eda7fc85af99701', 'text', 'es', 'error querying schedules', '{"label": "error querying schedules"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4245d4805900f3f0', 'text', 'es', 'error querying translations', '{"label": "error querying translations"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9c267eeb9993fde2', 'text', 'es', 'error reading file', '{"label": "error reading file"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f204ff648534d003', 'text', 'es', 'error reading network config', '{"label": "error reading network config"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '86749c0900db7803', 'text', 'es', 'error recording vote', '{"label": "error recording vote"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '31921e6a1b32e3b3', 'text', 'es', 'error recovering rotation', '{"label": "error recovering rotation"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4e3364e1e0659372', 'text', 'es', 'error registering QR attendance', '{"label": "error registering QR attendance"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7b410bc819add31f', 'text', 'es', 'error registering attendance', '{"label": "error registering attendance"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4c52ee6dfcae86a7', 'text', 'es', 'error registering peer', '{"label": "error registering peer"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cdc77ca1004730bb', 'text', 'es', 'error registering return', '{"label": "error registering return"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '897206e22976d9c6', 'text', 'es', 'error rejecting prohibition', '{"label": "error rejecting prohibition"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1f7b75b33a3256a9', 'text', 'es', 'error removing label', '{"label": "error removing label"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5796cef3776ff170', 'text', 'es', 'error removing participant', '{"label": "error removing participant"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '588d391b0bba1685', 'text', 'es', 'error removing peer', '{"label": "error removing peer"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '566f4bd4583e314d', 'text', 'es', 'error removing prohibition', '{"label": "error removing prohibition"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b14a0c408ce67ae2', 'text', 'es', 'error removing service', '{"label": "error removing service"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4c3e9b8be136c9dd', 'text', 'es', 'error revoking permission', '{"label": "error revoking permission"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '75f78971b8dbabbb', 'text', 'es', 'error rotating key', '{"label": "error rotating key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '937b64af375c2a99', 'text', 'es', 'error saving ULA', '{"label": "error saving ULA"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd45291ddb5e0dc73', 'text', 'es', 'error saving attendance config', '{"label": "error saving attendance config"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd30cb09a4ad03ccf', 'text', 'es', 'error saving biodynamic calendar entry', '{"label": "error saving biodynamic calendar entry"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '403e79931902d7ce', 'text', 'es', 'error saving biodynamic config', '{"label": "error saving biodynamic config"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0cfec60a237ec275', 'text', 'es', 'error saving card key', '{"label": "error saving card key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ff3515275cc57945', 'text', 'es', 'error saving card type config', '{"label": "error saving card type config"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '36f22976b8d4778b', 'text', 'es', 'error saving multisig config', '{"label": "error saving multisig config"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a50996629d3cd25a', 'text', 'es', 'error saving organization catalog rule', '{"label": "error saving organization catalog rule"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'dcd5fa7a3de7d536', 'text', 'es', 'error saving organization profile', '{"label": "error saving organization profile"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3d92eb1b84ff9d6e', 'text', 'es', 'error saving pending key', '{"label": "error saving pending key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f6756509efd3a93a', 'text', 'es', 'error saving public page settings', '{"label": "error saving public page settings"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9694c846dfd1632e', 'text', 'es', 'error saving service', '{"label": "error saving service"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '11bec0cdbc3ba862', 'text', 'es', 'error saving subscription', '{"label": "error saving subscription"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2841c86ce2a3ee3f', 'text', 'es', 'error saving translation', '{"label": "error saving translation"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '660974ff28c4846a', 'text', 'es', 'error scanning conflicts', '{"label": "error scanning conflicts"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f8cddda6a940c5be', 'text', 'es', 'error scanning language', '{"label": "error scanning language"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4ab33c5099c5b5e0', 'text', 'es', 'error setting default language', '{"label": "error setting default language"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e5d310fdffa5e621', 'text', 'es', 'error starting transaction', '{"label": "error starting transaction"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4009c18e67082e4e', 'text', 'es', 'error updating FRNE request', '{"label": "error updating FRNE request"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4ad265a227839f26', 'text', 'es', 'error updating commerce hours', '{"label": "error updating commerce hours"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '382a5a8c56dddfb2', 'text', 'es', 'error updating contacts', '{"label": "error updating contacts"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9e50e4a4163bd76a', 'text', 'es', 'error updating federation config', '{"label": "error updating federation config"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ac21e1eb78f373d6', 'text', 'es', 'error updating key', '{"label": "error updating key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3e11c4ced194e460', 'text', 'es', 'error updating language', '{"label": "error updating language"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'be83d05969936dc8', 'text', 'es', 'error updating loan', '{"label": "error updating loan"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f3d87072f717b8a8', 'text', 'es', 'error updating network config', '{"label": "error updating network config"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '89d467d3d2b497a3', 'text', 'es', 'error updating node faith profile', '{"label": "error updating node faith profile"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3208e1bf2f4f99b1', 'text', 'es', 'error updating preferences', '{"label": "error updating preferences"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3072123946523b86', 'text', 'es', 'error updating schedule', '{"label": "error updating schedule"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '57a2248556709f4f', 'text', 'es', 'error updating session', '{"label": "error updating session"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fa36cf582c5cb343', 'text', 'es', 'error updating settings', '{"label": "error updating settings"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '079c6f1bfe6648bf', 'text', 'es', 'error upgrading level', '{"label": "error upgrading level"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '058b3d9feec97e41', 'text', 'es', 'ese usuario no es super admin', '{"label": "ese usuario no es super admin"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1a31af1f7cbe20c6', 'text', 'es', 'esta propuesta no esta pendiente de revision', '{"label": "esta propuesta no esta pendiente de revision"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cfbb072568c78566', 'text', 'es', 'esta tarjeta fue bloqueada por un administrador. Contacta al admin para reactivarla', '{"label": "esta tarjeta fue bloqueada por un administrador. Contacta..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '65543d2984d696aa', 'text', 'es', 'esta tarjeta ya fue inicializada', '{"label": "esta tarjeta ya fue inicializada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '379e1ac623aa858c', 'text', 'es', 'esta tarjeta ya tiene una clave criptografica. Use rotate-key para rotarla.', '{"label": "esta tarjeta ya tiene una clave criptografica. Use rotate..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '023e655f47ac2dc3', 'text', 'es', 'esta votacion es presencial. Solo pueden votar los miembros presentes con doble confirmacion.', '{"label": "esta votacion es presencial. Solo pueden votar los miembr..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3102b2a83c0c88fe', 'text', 'es', 'este backup esta bloqueado y no se puede borrar', '{"label": "este backup esta bloqueado y no se puede borrar"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '40f77d8faef1d4ff', 'text', 'es', 'este nodo no es un satelite', '{"label": "este nodo no es un satelite"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '78d4912fd669c7a6', 'text', 'es', 'este nodo no tiene derecho a voto (requiere nivel 2+)', '{"label": "este nodo no tiene derecho a voto (requiere nivel 2+)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4b24abd14f774b06', 'text', 'es', 'este servicio es obligatorio, no requiere suscripcion manual', '{"label": "este servicio es obligatorio, no requiere suscripcion manual"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '47f2a0f1204cb61f', 'text', 'es', 'este token no corresponde a tu usuario', '{"label": "este token no corresponde a tu usuario"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c0cb56e8c88aa36a', 'text', 'es', 'extension es obligatoria', '{"label": "extension es obligatoria"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b7f8472399a6a6ea', 'text', 'es', 'failed to add authorized user', '{"label": "failed to add authorized user"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '595b5ed9d9a458bf', 'text', 'es', 'failed to assign terminal to department', '{"label": "failed to assign terminal to department"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9779a92423c638b9', 'text', 'es', 'failed to assign terminal to organization', '{"label": "failed to assign terminal to organization"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4633817bd57bb1b2', 'text', 'es', 'failed to assign terminal to user', '{"label": "failed to assign terminal to user"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'abb3d86864ac213b', 'text', 'es', 'failed to block terminal', '{"label": "failed to block terminal"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'af6fd78a38e1ff60', 'text', 'es', 'failed to cancel charge', '{"label": "failed to cancel charge"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c07a643135700f2e', 'text', 'es', 'failed to check existing users', '{"label": "failed to check existing users"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b5521e1ecca777c0', 'text', 'es', 'failed to close shift', '{"label": "failed to close shift"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e7f1c148deb3366a', 'text', 'es', 'failed to commit payment', '{"label": "failed to commit payment"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4bc4ef7ea3d06597', 'text', 'es', 'failed to create upload directory', '{"label": "failed to create upload directory"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ab9a1759c8ba9490', 'text', 'es', 'failed to credit merchant', '{"label": "failed to credit merchant"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6e2e9a35cd071043', 'text', 'es', 'failed to debit payer', '{"label": "failed to debit payer"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e30f9d5a5a9d6f1d', 'text', 'es', 'failed to encrypt node private key', '{"label": "failed to encrypt node private key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a666857016421ff2', 'text', 'es', 'failed to encrypt private key', '{"label": "failed to encrypt private key"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '66eeb05335bb3465', 'text', 'es', 'failed to generate keypair', '{"label": "failed to generate keypair"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '56e96edd1d24851b', 'text', 'es', 'failed to generate node keypair', '{"label": "failed to generate node keypair"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2b08f96db1430ecc', 'text', 'es', 'failed to generate salt', '{"label": "failed to generate salt"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bca9faf6f8673276', 'text', 'es', 'failed to generate token', '{"label": "failed to generate token"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7cbd51147c254189', 'text', 'es', 'failed to get payer balance', '{"label": "failed to get payer balance"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7dcaa71a7b8fc51a', 'text', 'es', 'failed to get user info', '{"label": "failed to get user info"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c162d1cb39a2c18e', 'text', 'es', 'failed to hash PIN', '{"label": "failed to hash PIN"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f23c3e2d664eec1c', 'text', 'es', 'failed to hash code', '{"label": "failed to hash code"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e2a07b5a926ba162', 'text', 'es', 'failed to hash password', '{"label": "failed to hash password"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2ac0c67cd941a889', 'text', 'es', 'failed to list authorized users', '{"label": "failed to list authorized users"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7d340d6fb61f602a', 'text', 'es', 'failed to list shifts', '{"label": "failed to list shifts"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bb485625a61c6abd', 'text', 'es', 'failed to list terminals', '{"label": "failed to list terminals"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '826d6ff894046e70', 'text', 'es', 'failed to list transactions', '{"label": "failed to list transactions"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '571e591f58658927', 'text', 'es', 'failed to mark charge as paid', '{"label": "failed to mark charge as paid"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f6a6125b494d76ca', 'text', 'es', 'failed to open shift', '{"label": "failed to open shift"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ad8119b55e72c9de', 'text', 'es', 'failed to query shifts', '{"label": "failed to query shifts"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b351f57e78004a83', 'text', 'es', 'failed to query transactions', '{"label": "failed to query transactions"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1e55be5b7be5062a', 'text', 'es', 'failed to remove authorized user', '{"label": "failed to remove authorized user"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5a40341411d4c875', 'text', 'es', 'failed to renew terminal keys', '{"label": "failed to renew terminal keys"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f090b2825fdc55de', 'text', 'es', 'failed to save PIN', '{"label": "failed to save PIN"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '11888b816008ee13', 'text', 'es', 'failed to save file', '{"label": "failed to save file"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5a49a796e54b3191', 'text', 'es', 'failed to save original', '{"label": "failed to save original"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'eb6aec2d8278fcb1', 'text', 'es', 'failed to start transaction', '{"label": "failed to start transaction"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f3c26f81e66ac943', 'text', 'es', 'failed to sync offline close', '{"label": "failed to sync offline close"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bb3848329ca58cbf', 'text', 'es', 'failed to toggle terminal', '{"label": "failed to toggle terminal"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a4362d6a8308995e', 'text', 'es', 'failed to unblock terminal', '{"label": "failed to unblock terminal"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '54ef5d0052d5830f', 'text', 'es', 'failed to update retention config', '{"label": "failed to update retention config"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b38a53fa34f3bf78', 'text', 'es', 'failed to update terminal label', '{"label": "failed to update terminal label"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b87a9a67ba05171e', 'text', 'es', 'file is required', '{"label": "file is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1fab3ba48f45538b', 'text', 'es', 'file too large or invalid form (max 10MB)', '{"label": "file too large or invalid form (max 10MB)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8505462f54f8574c', 'text', 'es', 'firmware binary not found. You may need to compile first.', '{"label": "firmware binary not found. You may need to compile first."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4b0a275842f8e75a', 'text', 'es', 'firmware compiler not configured on this server', '{"label": "firmware compiler not configured on this server"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1fc41497d584ea6a', 'text', 'es', 'first_day_of_week invalido: debe ser 0 o 1', '{"label": "first_day_of_week invalido: debe ser 0 o 1"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3ca9d9632d7dc004', 'text', 'es', 'format_settings invalido', '{"label": "format_settings invalido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6c85af319a15af21', 'text', 'es', 'formato de fecha invalido', '{"label": "formato de fecha invalido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e4f77c9676d852a1', 'text', 'es', 'formato de fecha invalido (usar YYYY-MM-DD)', '{"label": "formato de fecha invalido (usar YYYY-MM-DD)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c7ca620e7d78ef29', 'text', 'es', 'frecuencia debe estar entre 0 y 12 meses (0 = no auto-convocar)', '{"label": "frecuencia debe estar entre 0 y 12 meses (0 = no auto-con..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fa741e279c1d3c5f', 'text', 'es', 'from_node is required', '{"label": "from_node is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5b4ef9bbb1cc6d58', 'text', 'es', 'from_node_domain is required', '{"label": "from_node_domain is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '60ded1e8dcd4a65d', 'text', 'es', 'full_name is required', '{"label": "full_name is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '42e8efff790402d4', 'text', 'es', 'hora debe estar entre 0 y 23', '{"label": "hora debe estar entre 0 y 23"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5a1b83e1ca2855b0', 'text', 'es', 'id and name are required', '{"label": "id and name are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ca3f383c54e4b0c6', 'text', 'es', 'id de organizacion requerido', '{"label": "id de organizacion requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4b9f49d062530547', 'text', 'es', 'id is required', '{"label": "id is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3290e45883263a5a', 'text', 'es', 'id requerido', '{"label": "id requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '81484df38e5625b5', 'text', 'es', 'id y category son requeridos', '{"label": "id y category son requeridos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '64c2ae960b9b0151', 'text', 'es', 'installment_number requerido', '{"label": "installment_number requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '91a02d510770b42d', 'text', 'es', 'invalid JSON format', '{"label": "invalid JSON format"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8c8b7f09b2e4c2c6', 'text', 'es', 'invalid account id', '{"label": "invalid account id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '886bacf0f1e7b524', 'text', 'es', 'invalid admin user', '{"label": "invalid admin user"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ff19193e0a4e8a16', 'text', 'es', 'invalid approval_mode. Valid: assembly, council, multi_sig, department', '{"label": "invalid approval_mode. Valid: assembly, council, multi_si..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '33c2871d49f0fbd3', 'text', 'es', 'invalid authorization header format', '{"label": "invalid authorization header format"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0cb843bfd804b3e6', 'text', 'es', 'invalid block code', '{"label": "invalid block code"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '22c2bc9840e05829', 'text', 'es', 'invalid conflict id', '{"label": "invalid conflict id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3ab680f48073ee85', 'text', 'es', 'invalid credentials', '{"label": "invalid credentials"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4fd0b53e19db105c', 'text', 'es', 'invalid date format. Use ISO 8601 (e.g: 2024-03-15T15:00:00Z)', '{"label": "invalid date format. Use ISO 8601 (e.g: 2024-03-15T15:00:..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '98377e76cce747f3', 'text', 'es', 'invalid department id', '{"label": "invalid department id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b8a32202df4f6489', 'text', 'es', 'invalid department_id', '{"label": "invalid department_id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a781a68e4be484fe', 'text', 'es', 'invalid document id', '{"label": "invalid document id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c36a9cbc19d8c42c', 'text', 'es', 'invalid envelope', '{"label": "invalid envelope"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f636900a084d654f', 'text', 'es', 'invalid from date format', '{"label": "invalid from date format"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '594a0135678fcd96', 'text', 'es', 'invalid from date format (use YYYY-MM-DD)', '{"label": "invalid from date format (use YYYY-MM-DD)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e50278548e35665e', 'text', 'es', 'invalid id', '{"label": "invalid id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5dea336bd58bba7f', 'text', 'es', 'invalid institution id', '{"label": "invalid institution id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e119fb0be58582f9', 'text', 'es', 'invalid item id', '{"label": "invalid item id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '841abc82997153e2', 'text', 'es', 'invalid member id', '{"label": "invalid member id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3ff19d77c6744be7', 'text', 'es', 'invalid operation id', '{"label": "invalid operation id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b22b2bcd1ee0ce4d', 'text', 'es', 'invalid or expired token', '{"label": "invalid or expired token"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b3d099e285197940', 'text', 'es', 'invalid org id', '{"label": "invalid org id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1cfa93b0c761419a', 'text', 'es', 'invalid organization id', '{"label": "invalid organization id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd0bef810058a7e1b', 'text', 'es', 'invalid pairing code', '{"label": "invalid pairing code"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cebfafdedcd498f9', 'text', 'es', 'invalid payload format', '{"label": "invalid payload format"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '04b7b9ec21848363', 'text', 'es', 'invalid payment id', '{"label": "invalid payment id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7fdf8e1c89528c3f', 'text', 'es', 'invalid pending payment id', '{"label": "invalid pending payment id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8690630265bfa4c1', 'text', 'es', 'invalid producer id', '{"label": "invalid producer id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e23ab423625255f9', 'text', 'es', 'invalid product id', '{"label": "invalid product id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7712608c053b8961', 'text', 'es', 'invalid propagation message', '{"label": "invalid propagation message"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '951b981bef226958', 'text', 'es', 'invalid proposal id', '{"label": "invalid proposal id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b3c1fd78625ee19c', 'text', 'es', 'invalid proposal_id', '{"label": "invalid proposal_id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e95c46883db0c183', 'text', 'es', 'invalid proposed_value', '{"label": "invalid proposed_value"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8e48a0d99e4ae22c', 'text', 'es', 'invalid receiver_id', '{"label": "invalid receiver_id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'aafa1753cf7c9ec4', 'text', 'es', 'invalid request', '{"label": "invalid request"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '924cf61a009aad76', 'text', 'es', 'invalid request body', '{"label": "invalid request body"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'dc3bfddd700072e6', 'text', 'es', 'invalid request id', '{"label": "invalid request id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a929aa69a02b39ee', 'text', 'es', 'invalid role id', '{"label": "invalid role id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '248f880e413fb0f3', 'text', 'es', 'invalid service id', '{"label": "invalid service id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c3457d086fa2833b', 'text', 'es', 'invalid session_id', '{"label": "invalid session_id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8257632b6a5d9f45', 'text', 'es', 'invalid signature hex', '{"label": "invalid signature hex"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '476bbc3f6c8d3183', 'text', 'es', 'invalid start_time format, use RFC3339', '{"label": "invalid start_time format, use RFC3339"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd92070573ec32dc2', 'text', 'es', 'invalid target id', '{"label": "invalid target id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '83f13f55699da918', 'text', 'es', 'invalid to date format', '{"label": "invalid to date format"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5948ad2803035b8e', 'text', 'es', 'invalid to date format (use YYYY-MM-DD)', '{"label": "invalid to date format (use YYYY-MM-DD)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2aae2989348380bd', 'text', 'es', 'invalid translation item', '{"label": "invalid translation item"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '84a4ff67411d95b3', 'text', 'es', 'invalid user id', '{"label": "invalid user id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'eb6da2a75e3d084c', 'text', 'es', 'invalid user_id', '{"label": "invalid user_id"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '64e2cd1b9dc3dc2e', 'text', 'es', 'iso2, iso3 y spanish_name son obligatorios', '{"label": "iso2, iso3 y spanish_name son obligatorios"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '37ac4d6acf118710', 'text', 'es', 'key es requerido', '{"label": "key es requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '92b794c39aba3cc5', 'text', 'es', 'key required', '{"label": "key required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c5f6fe156a8a7c21', 'text', 'es', 'kwh_per_unit must be positive', '{"label": "kwh_per_unit must be positive"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f441596119848a27', 'text', 'es', 'la organizacion padre no existe', '{"label": "la organizacion padre no existe"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b9c717e9e85d8930', 'text', 'es', 'la propuesta no esta en votacion', '{"label": "la propuesta no esta en votacion"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '448db6859981e5ce', 'text', 'es', 'label is required', '{"label": "label is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4732d8d1d2614347', 'text', 'es', 'label y public_key son obligatorios', '{"label": "label y public_key son obligatorios"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2c79aabccea31240', 'text', 'es', 'lang and namespace required', '{"label": "lang and namespace required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '89dd062703ba6335', 'text', 'es', 'lang required', '{"label": "lang required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '577e57afe0fd7783', 'text', 'es', 'language is not enabled', '{"label": "language is not enabled"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '360dcbf7e717580d', 'text', 'es', 'language is required', '{"label": "language is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '24103e820bc197dc', 'text', 'es', 'language required', '{"label": "language required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd5b32cbfd5748728', 'text', 'es', 'level id and language required', '{"label": "level id and language required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0677c92ed77303b6', 'text', 'es', 'level id required', '{"label": "level id required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '26739da5e29c5ac7', 'text', 'es', 'level not found', '{"label": "level not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bb511aa53328c4ef', 'text', 'es', 'license file not found', '{"label": "license file not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5d9b19670f837110', 'text', 'es', 'limite minimo es 100 tabletas', '{"label": "limite minimo es 100 tabletas"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e5662d1d384f6b1d', 'text', 'es', 'locale no puede ser vacio', '{"label": "locale no puede ser vacio"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4a6104900744be4a', 'text', 'es', 'memstore_percentage debe estar entre 5 y 85', '{"label": "memstore_percentage debe estar entre 5 y 85"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '024042dbdaf5d3b1', 'text', 'es', 'missing user IDs for resolution', '{"label": "missing user IDs for resolution"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a010288a128fd28c', 'text', 'es', 'mode debe ser ''single'' o ''multi''', '{"label": "mode debe ser ''single'' o ''multi''"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bd845cce50e5bbd2', 'text', 'es', 'multi-sig not configured', '{"label": "multi-sig not configured"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4cd00f673074fda4', 'text', 'es', 'name and category are required', '{"label": "name and category are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'be27d10ad770e9f5', 'text', 'es', 'name e ipv6_address son obligatorios', '{"label": "name e ipv6_address son obligatorios"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f162d27e4dffb1a0', 'text', 'es', 'name es requerido', '{"label": "name es requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6d13c98497974564', 'text', 'es', 'name is required', '{"label": "name is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4bc31aa129eee674', 'text', 'es', 'name, sip_server, sip_username y sip_password son obligatorios', '{"label": "name, sip_server, sip_username y sip_password son obligat..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ef1daef4650b5635', 'text', 'es', 'new_pin is required', '{"label": "new_pin is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bb44951927be36de', 'text', 'es', 'new_public_key is required', '{"label": "new_public_key is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '113ba1ea96f67ebf', 'text', 'es', 'new_start_time is required', '{"label": "new_start_time is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4d980ca9aa52db42', 'text', 'es', 'no admission request found for this user', '{"label": "no admission request found for this user"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '050194e3b7538ed1', 'text', 'es', 'no autenticado', '{"label": "no autenticado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '794beca66a06f604', 'text', 'es', 'no eres miembro de esta organizacion/departamento con derecho a voto', '{"label": "no eres miembro de esta organizacion/departamento con der..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8998dfa85a1a7c2c', 'text', 'es', 'no fields to update', '{"label": "no fields to update"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f7ef70923392d26a', 'text', 'es', 'no file provided', '{"label": "no file provided"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e958b786a0cff7f5', 'text', 'es', 'no hay rotacion pendiente para esta tarjeta', '{"label": "no hay rotacion pendiente para esta tarjeta"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6cab8fdbe1489d96', 'text', 'es', 'no pending login challenge', '{"label": "no pending login challenge"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '81fdeac4b9b1edd0', 'text', 'es', 'no pending passkey registration challenge', '{"label": "no pending passkey registration challenge"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4ddf6c15d673ef6a', 'text', 'es', 'no pending registration challenge', '{"label": "no pending registration challenge"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '57b772d6a185f127', 'text', 'es', 'no puedes eliminar tu propio nodo', '{"label": "no puedes eliminar tu propio nodo"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '111c06091e5a18b1', 'text', 'es', 'no puedes eliminar un nodo federado. Los nodos federados no se eliminan aunque esten offline.', '{"label": "no puedes eliminar un nodo federado. Los nodos federados ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9478e00ab3d1df43', 'text', 'es', 'no puedes enviar una solicitud a tu propio nodo', '{"label": "no puedes enviar una solicitud a tu propio nodo"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3689f789250e39cf', 'text', 'es', 'no rejected admission request found', '{"label": "no rejected admission request found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '35593534c56045c0', 'text', 'es', 'no se encontro docker-compose.yml para este servicio', '{"label": "no se encontro docker-compose.yml para este servicio"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a9e851076b51098a', 'text', 'es', 'no se encontro repo git en /project', '{"label": "no se encontro repo git en /project"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f22cd93d65fd001f', 'text', 'es', 'no se permite reprogramar este tipo de asamblea', '{"label": "no se permite reprogramar este tipo de asamblea"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '831e734936dde6c9', 'text', 'es', 'no se pudo actualizar la configuracion', '{"label": "no se pudo actualizar la configuracion"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '79217f52512c85c4', 'text', 'es', 'no se pudo borrar el backup', '{"label": "no se pudo borrar el backup"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '87e1eb0dd61bc102', 'text', 'es', 'no se pudo leer el directorio de backups', '{"label": "no se pudo leer el directorio de backups"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5eb163b5ffe776b5', 'text', 'es', 'no shift found for this terminal', '{"label": "no shift found for this terminal"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '043fdf1e625384f8', 'text', 'es', 'no tienes Telegram Chat ID configurado', '{"label": "no tienes Telegram Chat ID configurado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2f32d4b14ce0bf79', 'text', 'es', 'no tienes XMPP JID configurado', '{"label": "no tienes XMPP JID configurado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '839cd0839ac559c5', 'text', 'es', 'no tienes email configurado en tus contactos', '{"label": "no tienes email configurado en tus contactos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5b12e4f989cd5a9f', 'text', 'es', 'no tienes notificaciones push activadas. Ve a ''Mis contactos'' y activa las notificaciones push del navegador primero', '{"label": "no tienes notificaciones push activadas. Ve a ''Mis contac..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fb225c6773d34244', 'text', 'es', 'no tienes passkeys registrados', '{"label": "no tienes passkeys registrados"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4ffffc39248fe782', 'text', 'es', 'no tienes passkeys registrados. Usa contrasena para iniciar sesion y registra un dispositivo en tu perfil.', '{"label": "no tienes passkeys registrados. Usa contrasena para inici..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '28eb9e6b6836ca59', 'text', 'es', 'no tienes permiso para modificar esta tarjeta', '{"label": "no tienes permiso para modificar esta tarjeta"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c454aacfe2810504', 'text', 'es', 'no tienes telefono configurado', '{"label": "no tienes telefono configurado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ecf35d2ddd35130f', 'text', 'es', 'no_git', '{"label": "no_git"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e607b56a5157a362', 'text', 'es', 'node already initialized - use admin endpoint', '{"label": "node already initialized - use admin endpoint"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2fba6c75174ff836', 'text', 'es', 'node is already initialized', '{"label": "node is already initialized"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f8985208ff56160a', 'text', 'es', 'node not found', '{"label": "node not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '829f82429683b68e', 'text', 'es', 'node not found in federation membership', '{"label": "node not found in federation membership"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3f784731e89a52f7', 'text', 'es', 'node not initialized yet', '{"label": "node not initialized yet"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9f0d14c1603ce6a8', 'text', 'es', 'node_domain is required', '{"label": "node_domain is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '806e241d97bda926', 'text', 'es', 'node_domain is required (ej: localhost para desarrollo, o tu dominio real)', '{"label": "node_domain is required (ej: localhost para desarrollo, o..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'dc0d68951983cf86', 'text', 'es', 'node_name is required (ej: Banco Comunitario A)', '{"label": "node_name is required (ej: Banco Comunitario A)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'da905ba32fcfaccf', 'text', 'es', 'node_url is required', '{"label": "node_url is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3582d21489f1035a', 'text', 'es', 'nodo eliminado', '{"label": "nodo eliminado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '628ef0d019db1f27', 'text', 'es', 'nodo no encontrado', '{"label": "nodo no encontrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8e01b0b198c2ea67', 'text', 'es', 'nombre de archivo invalido', '{"label": "nombre de archivo invalido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c3282efc58370957', 'text', 'es', 'nombre y IP son obligatorios', '{"label": "nombre y IP son obligatorios"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '803c8c7b0ed6c905', 'text', 'es', 'not a demo node', '{"label": "not a demo node"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b54c8b084d3e4435', 'text', 'es', 'not authenticated', '{"label": "not authenticated"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '23f800a40620082e', 'text', 'es', 'not authenticated: user must be logged in to renew keys', '{"label": "not authenticated: user must be logged in to renew keys"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0f54bfb90bbd0268', 'text', 'es', 'not authorized: you are not the assigned merchant for this terminal', '{"label": "not authorized: you are not the assigned merchant for thi..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b05ed5408a3f1e2a', 'text', 'es', 'not_authorized_for_terminal', '{"label": "not_authorized_for_terminal"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '26696fbbbd0fd0ab', 'text', 'es', 'notificacion marcada como leida', '{"label": "notificacion marcada como leida"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '140c3cb13db7b60a', 'text', 'es', 'only image files are allowed (jpg, png, gif, webp)', '{"label": "only image files are allowed (jpg, png, gif, webp)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2de580bdfc8fc3be', 'text', 'es', 'only the author or an admin can delete this proposal', '{"label": "only the author or an admin can delete this proposal"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7f9c7d2a3b362f2d', 'text', 'es', 'only the recovered user or an approver can complete the recovery', '{"label": "only the recovered user or an approver can complete the r..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'df1fbd53578bda91', 'text', 'es', 'organizacion no encontrada', '{"label": "organizacion no encontrada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9b76649d028898df', 'text', 'es', 'other_node_domain is required', '{"label": "other_node_domain is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '792f8674a974b9b3', 'text', 'es', 'page id and language required', '{"label": "page id and language required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4ccfd05e985d4b68', 'text', 'es', 'page id required', '{"label": "page id required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e65046f081f58598', 'text', 'es', 'page not found', '{"label": "page not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a571d0da5e540452', 'text', 'es', 'pagina no encontrada', '{"label": "pagina no encontrada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '44f6cae2963a9249', 'text', 'es', 'pairing code is required', '{"label": "pairing code is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9880c29ad47bf9eb', 'text', 'es', 'parameter id and language required', '{"label": "parameter id and language required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '40edbb04004d1c8e', 'text', 'es', 'parameter id required', '{"label": "parameter id required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd15de5d42f561ddb', 'text', 'es', 'parameter not found', '{"label": "parameter not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4c37c400219ac347', 'text', 'es', 'pasarela actualizada', '{"label": "pasarela actualizada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c10060d6cebedf3c', 'text', 'es', 'pasarela inactiva, activela primero', '{"label": "pasarela inactiva, activela primero"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f8523bcf59970a58', 'text', 'es', 'pasarela no configurada', '{"label": "pasarela no configurada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b820f5261ab2854f', 'text', 'es', 'passkey id is required', '{"label": "passkey id is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6584dac02f8cf2e3', 'text', 'es', 'passkey no encontrado', '{"label": "passkey no encontrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6b3e2552f02a911d', 'text', 'es', 'passkey not found or does not belong to you', '{"label": "passkey not found or does not belong to you"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1134b4b35c4f5b13', 'text', 'es', 'payment not found', '{"label": "payment not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7fa1c244a35658cc', 'text', 'es', 'peerDomain is required', '{"label": "peerDomain is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '877f4a45b44154e9', 'text', 'es', 'peer_domain is required', '{"label": "peer_domain is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b7d787a0db6e6140', 'text', 'es', 'peer_public_key is required', '{"label": "peer_public_key is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1781761107e2c78c', 'text', 'es', 'peer_public_key must be 32 bytes (64 hex chars)', '{"label": "peer_public_key must be 32 bytes (64 hex chars)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fa196fe0ceece0d0', 'text', 'es', 'pending payment not found', '{"label": "pending payment not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f8103c459274cbfb', 'text', 'es', 'pending prohibition not found', '{"label": "pending prohibition not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'db537cab0170033e', 'text', 'es', 'period_start and period_end are required', '{"label": "period_start and period_end are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '021a5f253ea4ab10', 'text', 'es', 'permission name is required', '{"label": "permission name is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bb9c32edaa2a2d90', 'text', 'es', 'permission_name is required', '{"label": "permission_name is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2e86dfa8d96ac701', 'text', 'es', 'pin is required', '{"label": "pin is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd5aa8b5ec23180d2', 'text', 'es', 'pin is required to close shift', '{"label": "pin is required to close shift"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '813176d69f2f0da4', 'text', 'es', 'pin is required to open shift', '{"label": "pin is required to open shift"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c70adcaad1f3e3cf', 'text', 'es', 'preferencias actualizadas', '{"label": "preferencias actualizadas"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1f18a1679ef47b2b', 'text', 'es', 'preset not found', '{"label": "preset not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3f9acfc7bf1e11db', 'text', 'es', 'preset_id is required', '{"label": "preset_id is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b2e77b0d4f579d03', 'text', 'es', 'prestamo no encontrado', '{"label": "prestamo no encontrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3c9096dc6896c9ce', 'text', 'es', 'producer not found', '{"label": "producer not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cb39a8223f4b0d69', 'text', 'es', 'product id and label id are required', '{"label": "product id and label id are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b09eb8a6b1d7880c', 'text', 'es', 'product id and language required', '{"label": "product id and language required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0a106d8330c66bc9', 'text', 'es', 'product id required', '{"label": "product id required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5216e46550c232af', 'text', 'es', 'product not found', '{"label": "product not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f086b52102582a7b', 'text', 'es', 'product_name and quantity are required', '{"label": "product_name and quantity are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e187c459ba9cfa21', 'text', 'es', 'product_name or product_id required', '{"label": "product_name or product_id required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e860483ddcba25e6', 'text', 'es', 'producto no encontrado', '{"label": "producto no encontrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '98c6f1797ab5e7a8', 'text', 'es', 'profile_id and product_name are required', '{"label": "profile_id and product_name are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '48ef1b2fcf37b00e', 'text', 'es', 'propagation not configured', '{"label": "propagation not configured"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3fade3fc7fc60ac5', 'text', 'es', 'proposal not found', '{"label": "proposal not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e6148edf9c9c167d', 'text', 'es', 'proposal_type is required', '{"label": "proposal_type is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fa55860184c72788', 'text', 'es', 'proposed_password is required and must be at least 6 characters', '{"label": "proposed_password is required and must be at least 6 char..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f1e6c5cf0239fe12', 'text', 'es', 'proposed_resolution must be ''a'' or ''b'' (no membresia dual)', '{"label": "proposed_resolution must be ''a'' or ''b'' (no membresia dual)"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9c1fc7f754c65f94', 'text', 'es', 'proposed_username is required', '{"label": "proposed_username is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7600a0bbd9949e28', 'text', 'es', 'propuesta no encontrada', '{"label": "propuesta no encontrada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0ce9295b3a181e7e', 'text', 'es', 'propuesta no encontrada o ya revisada', '{"label": "propuesta no encontrada o ya revisada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f5e9780d332dd5cb', 'text', 'es', 'quantity_returned debe ser mayor que 0', '{"label": "quantity_returned debe ser mayor que 0"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e3659bccb008c3ad', 'text', 'es', 'quorum_first_call debe estar entre 0 y 100', '{"label": "quorum_first_call debe estar entre 0 y 100"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '95cc3aa0febdfed1', 'text', 'es', 'quorum_second_call debe estar entre 0 y 100', '{"label": "quorum_second_call debe estar entre 0 y 100"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '91a9fde77197b26b', 'text', 'es', 'reason is required', '{"label": "reason is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a8990aff3d179d8c', 'text', 'es', 'recarga no encontrada o ya procesada', '{"label": "recarga no encontrada o ya procesada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f5f54204334ad863', 'text', 'es', 'recovery request not found', '{"label": "recovery request not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b956e30a9058b673', 'text', 'es', 'rejection_reason es obligatorio y debe tener al menos 10 caracteres', '{"label": "rejection_reason es obligatorio y debe tener al menos 10 ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2f47960b76278606', 'text', 'es', 'remoteNode is required', '{"label": "remoteNode is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0751655fc4df78db', 'text', 'es', 'remote_village_code es obligatorio', '{"label": "remote_village_code es obligatorio"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'be31e4ccc9f2ed40', 'text', 'es', 'reporter_node and target_node are required', '{"label": "reporter_node and target_node are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '01ff49fc20c121dc', 'text', 'es', 'reqId is required', '{"label": "reqId is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '84ec7e69e391f81f', 'text', 'es', 'request id is required', '{"label": "request id is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4ba365d948a4a33a', 'text', 'es', 'request must be approved before completion', '{"label": "request must be approved before completion"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1263e17d0f8f75d2', 'text', 'es', 'required_approvals must be at least 2 (no single person can restore access)', '{"label": "required_approvals must be at least 2 (no single person c..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3c4c32076faf700a', 'text', 'es', 'response requerido', '{"label": "response requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '13a4d5daa8260dee', 'text', 'es', 'respuesta incorrecta. La tarjeta puede ser falsa o clonada.', '{"label": "respuesta incorrecta. La tarjeta puede ser falsa o clonada."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a61b2e833b71c94a', 'text', 'es', 'retention_days must be at least 1', '{"label": "retention_days must be at least 1"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '07a602cfc0e1b026', 'text', 'es', 'rule id and language required', '{"label": "rule id and language required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5a56d3b31d6cb084', 'text', 'es', 'rule id required', '{"label": "rule id required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5c82199f216150a4', 'text', 'es', 'seed_name y quantity_borrowed son requeridos', '{"label": "seed_name y quantity_borrowed son requeridos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'af518b60d6150bd9', 'text', 'es', 'selected_code es requerido', '{"label": "selected_code es requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd8b979ca206567ca', 'text', 'es', 'selected_code is required', '{"label": "selected_code is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fd6f0caf284278e0', 'text', 'es', 'selected_code is required — debe elegir uno de los 4 codigos', '{"label": "selected_code is required — debe elegir uno de los 4 codigos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f0d6b368eafa4efb', 'text', 'es', 'server keys not configured', '{"label": "server keys not configured"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '681b7618706dfbc2', 'text', 'es', 'servicio no disponible', '{"label": "servicio no disponible"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fe6829facb6f7464', 'text', 'es', 'servicio no encontrado', '{"label": "servicio no encontrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cdd5bf6cf84ba7d7', 'text', 'es', 'sesion no encontrada', '{"label": "sesion no encontrada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd72733bf578840ea', 'text', 'es', 'session not found', '{"label": "session not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd360cdfde7cfefe3', 'text', 'es', 'session type is required', '{"label": "session type is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e974b015bae03719', 'text', 'es', 'skill_name is required', '{"label": "skill_name is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4682deb523cb1316', 'text', 'es', 'slug and title are required', '{"label": "slug and title are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ed95c7ba261db1ba', 'text', 'es', 'solicitud no encontrada', '{"label": "solicitud no encontrada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9dcb210fba9a5b52', 'text', 'es', 'solicitud no encontrada o no tiene defensa pendiente', '{"label": "solicitud no encontrada o no tiene defensa pendiente"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd376240dac282c15', 'text', 'es', 'source_node and language_code required', '{"label": "source_node and language_code required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b6333512d6c28954', 'text', 'es', 'status must be ''interested'' or ''not_interested''', '{"label": "status must be ''interested'' or ''not_interested''"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4ee3c3cc5d952d98', 'text', 'es', 'subscription removed', '{"label": "subscription removed"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd5e0481d94f00643', 'text', 'es', 'subscription saved', '{"label": "subscription saved"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b2b21ee03b07cf74', 'text', 'es', 'sun_mac requerido', '{"label": "sun_mac requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6d3b996484069275', 'text', 'es', 'target is required', '{"label": "target is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '079981a7ffd6e277', 'text', 'es', 'target_id o organization_id es requerido', '{"label": "target_id o organization_id es requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '85d9aa61f588306f', 'text', 'es', 'target_username is required', '{"label": "target_username is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f287c2d9629216f4', 'text', 'es', 'tarjeta bloqueada', '{"label": "tarjeta bloqueada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '14009e9f35d296e3', 'text', 'es', 'tarjeta bloqueada por intentos fallidos', '{"label": "tarjeta bloqueada por intentos fallidos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '86ca30c0441de223', 'text', 'es', 'tarjeta desactivada', '{"label": "tarjeta desactivada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '813fe87a4be75b25', 'text', 'es', 'tarjeta no encontrada', '{"label": "tarjeta no encontrada"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '86f41f9c44b90e60', 'text', 'es', 'tarjeta no encontrada o sin clave criptografica', '{"label": "tarjeta no encontrada o sin clave criptografica"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e36ecd1a8c7efb01', 'text', 'es', 'terminal id is required', '{"label": "terminal id is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '58cd9dccbb87b2ac', 'text', 'es', 'terminal is not blocked with a code', '{"label": "terminal is not blocked with a code"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6f9c4c0b2d5ecc9a', 'text', 'es', 'terminal not found', '{"label": "terminal not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4201eaa92dbfacc0', 'text', 'es', 'terminal not found or not assigned to this organization', '{"label": "terminal not found or not assigned to this organization"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'cd173dc52025ed0d', 'text', 'es', 'terminal not found or not assigned to you', '{"label": "terminal not found or not assigned to you"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '49bd72b5c2c34ba2', 'text', 'es', 'terminal not found or not authorized', '{"label": "terminal not found or not authorized"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2aa4e4efb7461ab6', 'text', 'es', 'terminal not found or not registered', '{"label": "terminal not found or not registered"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e0d45480b496234e', 'text', 'es', 'terminal not found or you are not the owner', '{"label": "terminal not found or you are not the owner"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '807a59bf0e2c0308', 'text', 'es', 'terminalId is required', '{"label": "terminalId is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a0af89cc54bc99c4', 'text', 'es', 'terminal_id is required', '{"label": "terminal_id is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f453f4dcef8cf052', 'text', 'es', 'terminal_id y terminal_public_key son requeridos', '{"label": "terminal_id y terminal_public_key son requeridos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3822e2bb78d3d999', 'text', 'es', 'terminal_id, registration_token and terminal_public_key are required', '{"label": "terminal_id, registration_token and terminal_public_key a..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '82e32b3c710534b0', 'text', 'es', 'terminal_not_registered', '{"label": "terminal_not_registered"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b05b0ea101125555', 'text', 'es', 'terminal_public_key is required', '{"label": "terminal_public_key is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '232d7e1cf5e7b3c7', 'text', 'es', 'test enviado con error', '{"label": "test enviado con error"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '337451a68c950f69', 'text', 'es', 'test enviado correctamente', '{"label": "test enviado correctamente"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bcfc2c98ee303aac', 'text', 'es', 'the source language must be edited in the original entity', '{"label": "the source language must be edited in the original entity"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '376e4e094cb1664d', 'text', 'es', 'there is already an open shift - close it first', '{"label": "there is already an open shift - close it first"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ff24e62bca00ba4b', 'text', 'es', 'this node is not part of this conflict', '{"label": "this node is not part of this conflict"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '40d0426013c53fae', 'text', 'es', 'this proposal has already been approved and executed', '{"label": "this proposal has already been approved and executed"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7262f05523642dca', 'text', 'es', 'this proposal has already been approved for voting and is in progress', '{"label": "this proposal has already been approved for voting and is..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '9cd92589ec61d16d', 'text', 'es', 'this proposal has already been executed', '{"label": "this proposal has already been executed"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '3194b70d9bc1201f', 'text', 'es', 'this proposal was rejected or expired', '{"label": "this proposal was rejected or expired"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '26d608d422b7d7e7', 'text', 'es', 'this voting is for the board of directors. Only board members can vote.', '{"label": "this voting is for the board of directors. Only board mem..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4a17a25e6a5979b0', 'text', 'es', 'this voting is in-person. Only members present can vote. You are not on the attendance list.', '{"label": "this voting is in-person. Only members present can vote. ..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'aae831c8e18fc230', 'text', 'es', 'time_format invalido: debe ser 24h o 12h', '{"label": "time_format invalido: debe ser 24h o 12h"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f1548c079334bab6', 'text', 'es', 'tipo de documento incorrecto para esta tarjeta', '{"label": "tipo de documento incorrecto para esta tarjeta"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'bca032fecffc0689', 'text', 'es', 'tipo de tarjeta no soportado. Use classic, ntag215, ultralight_c, ntag424 o desfire.', '{"label": "tipo de tarjeta no soportado. Use classic, ntag215, ultra..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2f5ada8f36c1412e', 'text', 'es', 'title is required', '{"label": "title is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4a658904a7c6a6d9', 'text', 'es', 'title y description son obligatorios', '{"label": "title y description son obligatorios"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4cc4e3fbe61fa82d', 'text', 'es', 'to_node_domain is required', '{"label": "to_node_domain is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '906899aadd2cad0b', 'text', 'es', 'todas marcadas como leidas', '{"label": "todas marcadas como leidas"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0935d6113e4b7c96', 'text', 'es', 'token expirado', '{"label": "token expirado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '2f4f625cf9a752c1', 'text', 'es', 'token invalido o expirado', '{"label": "token invalido o expirado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd0e90ec5b825d260', 'text', 'es', 'token is required', '{"label": "token is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '145506e28e64e306', 'text', 'es', 'translation is too large', '{"label": "translation is too large"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0fb63babeb18743f', 'text', 'es', 'translation source not found', '{"label": "translation source not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '47fe00a008c37f68', 'text', 'es', 'translations must contain between 1 and 250 items', '{"label": "translations must contain between 1 and 250 items"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '91c288a908709217', 'text', 'es', 'type es obligatorio', '{"label": "type es obligatorio"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '0af2656b7d798384', 'text', 'es', 'type must be ''work'' or ''material''', '{"label": "type must be ''work'' or ''material''"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5c1ec3a2a277d628', 'text', 'es', 'uid requerido', '{"label": "uid requerido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '493f03d44561e940', 'text', 'es', 'umbral debe estar entre 50 y 95', '{"label": "umbral debe estar entre 50 y 95"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '36fd540552b3b1b3', 'text', 'es', 'unauthorized', '{"label": "unauthorized"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'dd9eb1d9c34a8f6a', 'text', 'es', 'unexpected message type', '{"label": "unexpected message type"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e7936fc0153318b8', 'text', 'es', 'unexpected options type from passkey manager', '{"label": "unexpected options type from passkey manager"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '4f323c5b779c705e', 'text', 'es', 'unexpected passkey type from manager', '{"label": "unexpected passkey type from manager"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fa8ad601279d644f', 'text', 'es', 'user not found', '{"label": "user not found"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fe08d6141685cc43', 'text', 'es', 'user_id and position are required', '{"label": "user_id and position are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '5773a8467ec5c2fe', 'text', 'es', 'user_id invalido', '{"label": "user_id invalido"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '99a26527db613f73', 'text', 'es', 'user_id is required', '{"label": "user_id is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a43a763a39bea410', 'text', 'es', 'user_id parameter required', '{"label": "user_id parameter required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'e6d84434cfe3f014', 'text', 'es', 'user_id requerido en el QR', '{"label": "user_id requerido en el QR"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'c74ce53a492562f9', 'text', 'es', 'user_id, card_uid and initial_pin are required', '{"label": "user_id, card_uid and initial_pin are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7a0f37da86101ac7', 'text', 'es', 'username and password are required', '{"label": "username and password are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f4e6ee32c37ac0b9', 'text', 'es', 'username and pin are required', '{"label": "username and pin are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '1a5ccbe6fbbe7cd8', 'text', 'es', 'username is required', '{"label": "username is required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '309b4a2dc30ee00c', 'text', 'es', 'username solo puede contener letras, numeros, guiones y guiones bajos', '{"label": "username solo puede contener letras, numeros, guiones y g..."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a0a558653065391f', 'text', 'es', 'username, doc_number and pin are required', '{"label": "username, doc_number and pin are required"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '8d16a994b54605f8', 'text', 'es', 'usuario demo no disponible actualmente', '{"label": "usuario demo no disponible actualmente"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '57ddbf93889e22cb', 'text', 'es', 'usuario no encontrado', '{"label": "usuario no encontrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '67102f24ca781e80', 'text', 'es', 'usuario/organizacion no encontrado', '{"label": "usuario/organizacion no encontrado"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a2eba3f5ca2c9a40', 'text', 'es', 'vote debe ser ''approve'' o ''reject''', '{"label": "vote debe ser ''approve'' o ''reject''"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '7930bfc75fcd1c59', 'text', 'es', 'vote must be ''for'', ''against'' or ''abstain''', '{"label": "vote must be ''for'', ''against'' or ''abstain''"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'fa89d1253586dfa8', 'text', 'es', 'vote must be approved or rejected', '{"label": "vote must be approved or rejected"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'd7c6b0eec8c3a07b', 'text', 'es', 'voter_node y vote son requeridos', '{"label": "voter_node y vote son requeridos"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '34e2e2f2c6b7635e', 'text', 'es', 'voting time has expired', '{"label": "voting time has expired"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'ec9f4f903cefa97c', 'text', 'es', 'voting time has expired. To revote, create a new proposal.', '{"label": "voting time has expired. To revote, create a new proposal."}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', '6c44dee89d71b1f4', 'text', 'es', 'web_session_expired', '{"label": "web_session_expired"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'a87c6ff75c980c37', 'text', 'es', 'ya votaste por esta propuesta', '{"label": "ya votaste por esta propuesta"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'f8bce809f5cf1e45', 'text', 'es', 'you do not have permission to directly approve this proposal', '{"label": "you do not have permission to directly approve this proposal"}'::jsonb);
  PERFORM upsert_content_translation_source('__GLOBAL__', 'api_message', 'b914b77a4d578b3c', 'text', 'es', 'you do not have permission to directly approve this proposal. Voting is required.', '{"label": "you do not have permission to directly approve this propo..."}'::jsonb);
END $$;

-- Traducciones en ingles de los mensajes registrados arriba.
INSERT INTO content_translations (translation_key, language, value, source_hash, updated_at)
SELECT s.translation_key, 'en', v.value, s.source_hash, NOW()
FROM content_translation_sources s
JOIN (VALUES
  ('api_message:e4d06ce32954780e:text', 'Update cancelled. The background process will stop.'),
  ('api_message:01bfc51c5ea2ea6a:text', 'Update started. The node will restart automatically when finished.'),
  ('api_message:2b3e0fab93231e6e:text', 'Update started. Monitor progress in the console.'),
  ('api_message:e37ff6eba96d53de:text', 'Both assemblies approved. The resolution can be executed.'),
  ('api_message:26dd8f4103ba7a38:text', 'Assembly closed'),
  ('api_message:f0b21b702273be5d:text', 'Assembly closed. Failed to auto-convene the next one.'),
  ('api_message:78414a1702b7cdd8:text', 'Assembly closed. Next ordinary assembly convened automatically.'),
  ('api_message:103c2bf1d4fc4e2c:text', 'Assembly created. Members have been notified.'),
  ('api_message:f2e07fbcd6ea0006:text', 'Attendance confirmed via token.'),
  ('api_message:07cdcfc836be26d7:text', 'Attendance recorded'),
  ('api_message:3128c25b1bce6fd5:text', 'Attendee removed'),
  ('api_message:7489005875c8c046:text', 'You cannot level up yet.'),
  ('api_message:3aea4402ab75e06c:text', 'Authentication required'),
  ('api_message:f7405ace560177a9:text', 'Backup restored'),
  ('api_message:5007d44b1228a009:text', 'Backup requested. The db-backup service will create it within the next 60 seconds.'),
  ('api_message:9bc2b9155fb50c65:text', 'Missing required field'),
  ('api_message:64b757675c2bace9:text', 'Charge cancelled by the customer'),
  ('api_message:a86bb3f0a609ffac:text', 'Check-in opened. Participants can register now.'),
  ('api_message:52a2fc46abbe3bc5:text', 'Check-in closed.'),
  ('api_message:bba78cd5a1bddf59:text', 'Check-in recorded'),
  ('api_message:3d6d90ba77c16368:text', 'Check-out opened.'),
  ('api_message:02cce9660f10cbbb:text', 'Check-out closed.'),
  ('api_message:cb5967f7b66f5596:text', 'Key generated. Write this key to the card using your NFC tool (DESFire or NTAG424). The key is stored encrypted on the server.'),
  ('api_message:8fb6a0bd467ca98f:text', 'WireGuard keys generated successfully'),
  ('api_message:7328dc50933ebb5f:text', 'Purchase approved. Bank balance updated.'),
  ('api_message:dbf0aeaa35eedeea:text', 'Purchase recorded. Pending approval.'),
  ('api_message:a5ade86dbc366fe7:text', 'Settings updated'),
  ('api_message:f9506d7507a19d69:text', 'Discovery settings updated'),
  ('api_message:294df144f173f9dc:text', 'Tax settings updated'),
  ('api_message:999423015edd3740:text', 'Quorum settings updated'),
  ('api_message:860de24132647610:text', 'Site settings updated'),
  ('api_message:26f84654bfd7d56e:text', 'Configuration generated. Download the data and create the image manually.'),
  ('api_message:a2d5cf72501250cf:text', 'Settings saved'),
  ('api_message:5e696b2a25132545:text', 'Settings saved. Restart YugabyteDB to apply the changes.'),
  ('api_message:30324d8ee68edbb6:text', 'Conflict'),
  ('api_message:a3098c6b4d3c8eec:text', 'Federated constants to inherit when joining the federation'),
  ('api_message:f3302d514ed65247:text', 'Account locked'),
  ('api_message:192bfa1055f848ef:text', 'Account disabled'),
  ('api_message:dd681ba4a05499db:text', 'Defense accepted. Request escalated to the assembly.'),
  ('api_message:7e8d08b7f85b90ef:text', 'Defense sent. The committee will review your response.'),
  ('api_message:d39b97eecda39221:text', 'Defense rejected. The rejection stands.'),
  ('api_message:2806cf49e0fea55a:text', 'Too many requests'),
  ('api_message:e87bef928e3cdf8c:text', 'Document added'),
  ('api_message:3b45f28177f5d1e5:text', 'The seed bank works on borrow-and-return. Return more than you took so the bank grows.'),
  ('api_message:ab1fad14d6cfaff5:text', 'Check-in is not open'),
  ('api_message:662725008db5aba4:text', 'Check-out is not open'),
  ('api_message:600dd282a00a14fb:text', 'Domain cannot be ''localhost'' or ''__LOCAL__'''),
  ('api_message:27b0d0b78ddaf4bc:text', 'The domain cannot be changed on the demo node. It is inherited from the parent node.'),
  ('api_message:cbd3200800af3b7d:text', 'The target level does not exist. Contact the administrator.'),
  ('api_message:0809b066896ec2ae:text', 'The node already has WireGuard keys'),
  ('api_message:554d5126c9d45562:text', 'Username must be at least 3 characters'),
  ('api_message:9b8436ca9b74dd17:text', 'Username already in use'),
  ('api_message:d3c8d30d511a797d:text', 'Username already exists. Choose another one.'),
  ('api_message:9ebc0b0b7ed0bf93:text', 'Enter the code the new node gave you by phone. Only one is correct.'),
  ('api_message:841c9379e126d74e:text', 'Enter the code the new node gave you. Only one is correct.'),
  ('api_message:87103e11be53f8bf:text', 'Enter the code the web POS person gave you.'),
  ('api_message:d9cad7c157d73b1b:text', 'Enter the code the terminal person gave you by phone. Only one is correct.'),
  ('api_message:8af2318a155de14b:text', 'Invalid input'),
  ('api_message:0cb7b320496887ac:text', 'Send this challenge to the card (DESFire EV3). The card will respond with AES(challenge, key). Send the response to /verify-response.'),
  ('api_message:09efd6c5d5d9579c:text', 'Database error'),
  ('api_message:6f5b887603276a48:text', 'Network error'),
  ('api_message:ebf6090551ce5d69:text', 'Server error'),
  ('api_message:b0a8cf468a90acf1:text', 'Payment error'),
  ('api_message:69084d94b80c8464:text', 'Transfer error'),
  ('api_message:434e81de0cdbb7ef:text', 'Error reading update status'),
  ('api_message:d648afe3869782cd:text', 'Update status reset.'),
  ('api_message:79962740932d83a7:text', 'You are over the credit limit'),
  ('api_message:63662a1c162e76de:text', 'Congratulations! You have leveled up.'),
  ('api_message:f12c9c0f7902721d:text', 'Invalid format'),
  ('api_message:550009d562b52620:text', 'Admission form updated successfully'),
  ('api_message:c32d73538f403546:text', 'IPv6 ULA not generated. Generate the ULA prefix first.'),
  ('api_message:60c7749b8ce6abd6:text', 'Language required'),
  ('api_message:17d525a392876cba:text', 'Invalid JSON'),
  ('api_message:c3f85305f78f70fb:text', 'Password must be at least 8 characters'),
  ('api_message:19fa72af43d1301d:text', 'Passwords do not match'),
  ('api_message:68c9c00ef7ff3b64:text', 'Invalid MAC. The card may be fake or cloned.'),
  ('api_message:9aa87dfd4fd8de68:text', 'Minutes saved'),
  ('api_message:50764838e155dbb0:text', 'Level updated'),
  ('api_message:b979c00354210b7b:text', 'Level created'),
  ('api_message:d440d801cbc90e56:text', 'Organization level updated'),
  ('api_message:feba95d358e24c71:text', 'Organization level created'),
  ('api_message:c1943897d2c713b1:text', 'Not found'),
  ('api_message:29975687c471e45b:text', 'No update in progress.'),
  ('api_message:b5358848e1c64009:text', 'Your level was not found. Ask the assembly to assign you a level.'),
  ('api_message:613cd4cdb725f606:text', 'The demo node cannot be updated directly.'),
  ('api_message:38e4adb0244a3a4e:text', 'VoIP cannot be configured on the demo node.'),
  ('api_message:92bb4ba2cb5810ff:text', 'Cannot delete the default language'),
  ('api_message:3bc78a5e597bf5b1:text', 'Network configuration cannot be modified on the demo node.'),
  ('api_message:828c292ce5392aa6:text', 'Services cannot be uninstalled on the demo node.'),
  ('api_message:0a0198ce0b2e5042:text', 'Services cannot be stopped on the demo node.'),
  ('api_message:15e49e18bdd3fc3b:text', 'Services cannot be started on the demo node.'),
  ('api_message:332509cee2c3f4b2:text', 'Services cannot be installed on the demo node. Services are installed from the parent node.'),
  ('api_message:ed974629cd33a9ad:text', 'Services cannot be restarted on the demo node.'),
  ('api_message:1af2a29cc94a138e:text', 'You have no check-in recorded'),
  ('api_message:c06d57da4643b0f2:text', 'You do not have permission to perform this action'),
  ('api_message:a70cf2c407b2a915:text', 'You have no level assigned. Ask the assembly to assign you a level.'),
  ('api_message:0dd578d1709191b6:text', 'Node started'),
  ('api_message:d4bd14374a7ac9b5:text', 'Node created. Download the install script and run it on the remote server.'),
  ('api_message:143d620413f97b63:text', 'Demo node recreated with the latest version. Data is being regenerated.'),
  ('api_message:cba0b2bdf4dc466e:text', 'Node stopped'),
  ('api_message:e0a563c1b4381510:text', 'Node restarted'),
  ('api_message:c967062e896ddd30:text', 'New key generated. Write this key to the card. The SUN counter was reset.'),
  ('api_message:9fa6066d7134d470:text', 'New key generated. Write it to the card and confirm with /confirm-rotation.'),
  ('api_message:a0a4fb3934eb5a5d:text', 'OpenWrt not configured. Configure the OpenWrt address and domain first.'),
  ('api_message:acffe13476240cab:text', 'Shift PIN configured successfully'),
  ('api_message:380559c812d62a96:text', 'Incorrect shift PIN'),
  ('api_message:da90c95d7beda55b:text', 'Incorrect PIN'),
  ('api_message:d8040a8039bec4c0:text', 'Page updated'),
  ('api_message:256317fd65e8ab59:text', 'Page created'),
  ('api_message:996b9b506f94f669:text', 'Page deleted'),
  ('api_message:b2d978d11a904bbc:text', 'Page saved successfully'),
  ('api_message:4958d7c3839165d6:text', 'Page restored to default content'),
  ('api_message:72f30933e4615ec1:text', 'Payment executed successfully'),
  ('api_message:740cdd1bf768f01a:text', 'Country added'),
  ('api_message:10a33da51cccc0fb:text', 'Parameter updated. Pending re-approval.'),
  ('api_message:5cbe983a49d5ee06:text', 'Parameter approved'),
  ('api_message:d0d2d4d73cfc1e00:text', 'Parameter created. Pending assembly approval.'),
  ('api_message:3eca33e5ea80cbe9:text', 'PSTN gateway created. External calls will use this gateway.'),
  ('api_message:deecebbc93ada227:text', 'Invalid passkey'),
  ('api_message:53c40d11a295b38a:text', 'Passkey not found'),
  ('api_message:f76cd9db7c98c58b:text', 'Passkey registered successfully.'),
  ('api_message:b33acdc3f24daf80:text', 'Peer registered. For active federation, the other node must also register your public key.'),
  ('api_message:a6af067de8601271:text', 'Invalid request'),
  ('api_message:a17d0d8efb8be0fa:text', 'Ask the administrator to approve this code in their panel.'),
  ('api_message:fd8a3aca816c66b0:text', 'Ask the terminal owner to approve this code in their account.'),
  ('api_message:c62a0e2ebfeffd3c:text', 'Presence confirmed. Thank you for validating your attendance.'),
  ('api_message:91f24029738899e4:text', 'Product updated'),
  ('api_message:58b88b11789e9b71:text', 'Product approved by the assembly. Federated nodes have been notified for individual approval.'),
  ('api_message:3e09169049f85685:text', 'Product created. Pending assembly approval.'),
  ('api_message:244105075cf016f0:text', 'Product unapproved. Still visible in the Federation but not approved.'),
  ('api_message:83e307e857cb8909:text', 'Federated product approved and added to the local catalog'),
  ('api_message:96da3a196a4162b6:text', 'Product promoted to base product. It now appears across the federation and can be used as an ingredient.'),
  ('api_message:49a8ddfbb3cb5a4b:text', 'Product rejected and hidden from the catalog.'),
  ('api_message:30948754033d8253:text', 'Producer added'),
  ('api_message:780bbc8b5fb40b61:text', 'Proposal approved and executed directly'),
  ('api_message:1206cff12c103bbe:text', 'Proposal created. Thank you for contributing!'),
  ('api_message:89cb097172b5337c:text', 'Proposal created. The assembly must approve it to open voting.'),
  ('api_message:71080ca065106e9f:text', 'Proposal created. The assembly must review it and open voting.'),
  ('api_message:01f11283be15d3dd:text', 'Proposal created. The modification will be applied when the assembly approves it.'),
  ('api_message:80733956ea0ca2e8:text', 'Proposal created. The rule will be deleted when the assembly approves it.'),
  ('api_message:02e9b9312b8f505c:text', 'Proposal created. It will be shared with federated nodes for voting.'),
  ('api_message:a74f072d7aa74019:text', 'Proposal deleted'),
  ('api_message:ee1368da85440323:text', 'Proposal received'),
  ('api_message:e6355049a65e34e3:text', 'Basket recalculation approved. FC updated.'),
  ('api_message:7a0b024f2c6eb214:text', 'Top-up requested. An administrator must confirm it.'),
  ('api_message:62aeed4e5b91c515:text', 'Rotation confirmed. New key active. Transaction can proceed.'),
  ('api_message:b5ff2e24587db9d3:text', 'Rotation discarded. Old key K remains active.'),
  ('api_message:d4026afe1dd8f7a7:text', 'Rotation recovered. K'' is now the active key.'),
  ('api_message:2f118d1b3d23f992:text', 'Rotation already pending. Use this key to write to the card.'),
  ('api_message:a494461cca3ce85e:text', 'Insufficient balance'),
  ('api_message:9ff79a31c3a2453c:text', 'Special permission required'),
  ('api_message:02dabe4376c236e2:text', 'Service with external image. Use ''Update'' to force download of a new image.'),
  ('api_message:9fdc4d7dace63398:text', 'Service uninstalled'),
  ('api_message:80a15ae22b4abdd5:text', 'Service stopped'),
  ('api_message:38539fc60b081d14:text', 'Service started'),
  ('api_message:4005be4119b4383d:text', 'Service restarted'),
  ('api_message:b76966a343b97b4f:text', 'Session updated'),
  ('api_message:28444bf61e18c093:text', 'Session created'),
  ('api_message:1ffbd0f2608f0f77:text', 'Session expired'),
  ('api_message:bed40562d6a172f8:text', 'Logged in'),
  ('api_message:3940d37a6f70d763:text', 'System under maintenance'),
  ('api_message:df97b96f1c20dec2:text', 'Request escalated to the assembly for voting'),
  ('api_message:7375fc0daae913d8:text', 'Request sent. You can log in with your username and password to see your request status.'),
  ('api_message:56145c5e34063988:text', 'Request rejected. The applicant has 30 days to submit a defense.'),
  ('api_message:4824a3930c137a43:text', 'Rate updated'),
  ('api_message:90a9bf9f1ca4916d:text', 'Card cryptographically authenticated. It is legitimate.'),
  ('api_message:2e8fb02f445d3406:text', 'Card cryptographically blocked. It cannot be used for payments.'),
  ('api_message:f4897fe9ca50ad89:text', 'Card deactivated'),
  ('api_message:50be5e5c04c437a0:text', 'Card marked as initialized successfully.'),
  ('api_message:913c7e47c304e153:text', 'Card not found'),
  ('api_message:a56a124b9fc03209:text', 'Card without cryptographic key (uid_only mode)'),
  ('api_message:affa58aa262d1028:text', 'Terminal exists but is not registered or is inactive.'),
  ('api_message:082cae4ac72d88ea:text', 'Terminal not found on the server.'),
  ('api_message:0bf729ba735e322c:text', 'Terminal registered and active.'),
  ('api_message:2ae13184993603bc:text', 'Time expired. The payment has been voided.'),
  ('api_message:b27c1845c1f6209a:text', 'Your account is pending approval. You can only view your request status.'),
  ('api_message:3999db8b461b1a0b:text', 'Your current level has no auto-promotion configured.'),
  ('api_message:464f451dfab953c5:text', 'An assembly rejected the proposal. The federation remains blocked until resolved.'),
  ('api_message:7ab96ba4a7afdcc0:text', 'Demo user: you do not have permission to modify data. You can browse but cannot save changes.'),
  ('api_message:0de2ad3c64e701ed:text', 'Incorrect username or password'),
  ('api_message:360ef59f8669db5f:text', 'Value too large'),
  ('api_message:dada824dd437a3b0:text', 'Value too small'),
  ('api_message:7e59a3a725252778:text', 'Sale approved. Bank balance updated.'),
  ('api_message:a5c66e70cbf095b2:text', 'Sale recorded. Pending approval.'),
  ('api_message:f4ecad0977a3fcff:text', 'Voting open'),
  ('api_message:3f8e5139808881eb:text', 'Voting open. Members can vote now.'),
  ('api_message:3e0a2951416a6aa3:text', 'Vote recorded'),
  ('api_message:049e2be43e497881:text', 'Vote recorded. Pending the other assembly''s vote.'),
  ('api_message:ec61fbcd39110eed:text', 'Remote vote recorded'),
  ('api_message:9ed1f083194985d4:text', 'Already exists'),
  ('api_message:97481db02565369d:text', 'A startup is already in progress'),
  ('api_message:478f0677cf140bcc:text', 'An update is already in progress. Wait for it to finish or cancel it.'),
  ('api_message:e4047a3e181ae7da:text', 'account not found'),
  ('api_message:27334cda73e5c0fd:text', 'empty file'),
  ('api_message:cdcde7d8f6a2a359:text', 'backup locked'),
  ('api_message:838dbfced3671841:text', 'backup deleted'),
  ('api_message:cd4b3f4179276b0d:text', 'backup unlocked'),
  ('api_message:3cf007a9281ebd1e:text', 'backup not found'),
  ('api_message:9527d0baa4757116:text', 'challenge expired'),
  ('api_message:865235bdb10e3652:text', 'challenge not found'),
  ('api_message:ab5c15cb834fd572:text', 'settings updated')
) AS v(key, value) ON v.key = s.translation_key
ON CONFLICT (translation_key, language) DO UPDATE SET
  value = EXCLUDED.value,
  source_hash = EXCLUDED.source_hash,
  updated_at = NOW();
