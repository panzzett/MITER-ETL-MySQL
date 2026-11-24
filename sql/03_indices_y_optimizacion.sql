/* ============================================================
   ACTIVIDAD 2 – ÍNDICES EN BASES DE DATOS
   Esquema: miter_bbdd
   Asignatura: Bases de Datos Avanzadas
   Alumno: Carlos Galvez Reguera

   NOTA:
   Este script asume que el esquema miter_bbdd y todas las tablas
   ya han sido creados y cargados en la Actividad 1.
   ============================================================ */

-- 1. Seleccionar el esquema de trabajo
USE miter_bbdd;

-- ============================================================
-- 2. ÍNDICES CREADOS ANTERIORMENTE (DOCUMENTACIÓN)
-- ============================================================
--
-- 2.1. Índices de clave primaria (PRIMARY KEY):
--   comunidad_autonoma : PRIMARY KEY (comunidad_id)
--   empresa            : PRIMARY KEY (empresa_id)
--   provincia          : PRIMARY KEY (provincia_id)
--   municipio          : PRIMARY KEY (municipio_id)
--   localidad          : PRIMARY KEY (localidad_id)
--   estacion_servicio  : PRIMARY KEY (estacion_id)
--   tipo_carburante    : PRIMARY KEY (carburante_id)
--   precio_carburante  : PRIMARY KEY (estacion_id, carburante_id, fecha_actualizacion)
--
-- 2.2. Índices por claves foráneas (FOREIGN KEY):
--   provincia        : INDEX(comunidad_id)
--   municipio        : INDEX(provincia_id)
--   localidad        : INDEX(municipio_id)
--   estacion_servicio: INDEX(empresa_id), INDEX(localidad_id)
--   precio_carburante: INDEX(estacion_id), INDEX(carburante_id)
--
-- Estos índices permiten unir eficazmente las tablas del modelo
-- geográfico y las relaciones entre estaciones, empresas y precios.
-- Aquí sólo se documentan; no se recrean.


-- ============================================================
-- 3. ÍNDICES ADICIONALES PARA MEJORAR LAS CONSULTAS DEL LABORATORIO
--    (Consultas definidas en querys.sql)
-- ============================================================

/* ------------------------------------------------------------
   3.1. Índice sobre estacion_servicio.tipo_estacion
        Consultas 1 y 2:
        - Empresa con más estaciones TERRESTRES
        - Empresa con más estaciones MARÍTIMAS

   Motivo:
   - La columna tipo_estacion se usa en la cláusula WHERE.
   - Sin índice, MySQL puede hacer un escaneo completo de la tabla.
   - Con este índice, se acelera el filtrado por 'TERRESTRE' / 'MARITIMA'.
   ------------------------------------------------------------ */
CREATE INDEX idx_estacion_tipo
    ON estacion_servicio (tipo_estacion);


/* ------------------------------------------------------------
   3.2. Índice sobre tipo_carburante.nombre
        Consultas 3, 4 y 5:
        - Búsqueda por nombre de carburante (“GASOLINA 95”, “GASOLEO A”…)

   Motivo:
   - tc.nombre se usa en WHERE (con UPPER y LIKE).
   - El índice permite localizar rápidamente los carburantes
     correspondientes al texto buscado.
   ------------------------------------------------------------ */
CREATE INDEX idx_tc_nombre
    ON tipo_carburante (nombre);


/* ------------------------------------------------------------
   3.3. Índice sobre provincia.nombre
        Consulta 3:
        - Gasolinera con gasolina 95 más barata en la provincia de MADRID.

   Motivo:
   - p.nombre se usa en el filtro de provincia.
   - La tabla provincia es pequeña, pero tener el índice
     mantiene la consistencia y acelera consultas repetidas.
   ------------------------------------------------------------ */
CREATE INDEX idx_provincia_nombre
    ON provincia (nombre);


/* ------------------------------------------------------------
   3.4. Índice sobre precio_carburante.precio
        Consultas 3, 4 y 5:
        - Ordenación por precio ASC para obtener la gasolinera más barata.

   Motivo:
   - pc.precio se usa en ORDER BY.
   - El índice ayuda a ordenar y a encontrar mínimos de forma eficiente.
   ------------------------------------------------------------ */
CREATE INDEX idx_precio_precio
    ON precio_carburante (precio);


/* ------------------------------------------------------------
   3.5. Índice geográfico sobre estacion_servicio(latitud, longitud)
        Consultas 4 y 5:
        - Gasolinera más barata dentro de un radio de 10 km.

   Motivo:
   - Las consultas calculan distancias con latitud/longitud.
   - Aunque la fórmula no se resuelve sólo con el índice,
     este índice compuesto permite restringir el conjunto de
     estaciones a una “caja” geográfica (bounding box), reduciendo
     el número de filas sobre las que se evalúa la distancia.
   ------------------------------------------------------------ */
CREATE INDEX idx_estacion_geo
    ON estacion_servicio (latitud, longitud);


-- ============================================================
-- 4. ÍNDICES ADICIONALES SEGÚN EL CASO DE USO DE LA APLICACIÓN
--    (Aplicación web que muestra precios de gasolina a usuarios)
-- ============================================================

/* ------------------------------------------------------------
   4.1. Índice sobre municipio.nombre

   Caso de uso:
   - El usuario filtra gasolineras por municipio (ej. “Madrid”,
     “Coslada”, etc.).

   Motivo:
   - municipio.nombre es una columna muy utilizada en búsquedas.
   - El índice mejora el rendimiento de consultas que, a partir
     del nombre del municipio, recuperan sus localidades y estaciones.
   ------------------------------------------------------------ */
CREATE INDEX idx_municipio_nombre
    ON municipio (nombre);


/* ------------------------------------------------------------
   4.2. Índice sobre estacion_servicio.cod_postal

   Caso de uso:
   - Búsqueda de estaciones por código postal introducido por el usuario.

   Motivo:
   - cod_postal se usa como criterio de filtrado.
   - El índice permite localizar rápidamente las estaciones de un CP
     concreto sin recorrer toda la tabla.
   ------------------------------------------------------------ */
CREATE INDEX idx_estacion_cp
    ON estacion_servicio (cod_postal);


/* ------------------------------------------------------------
   4.3. Índice compuesto sobre precio_carburante(carburante_id, precio)

   Caso de uso:
   - Mostrar las gasolineras más baratas para un tipo de carburante
     específico (ranking de precios por carburante).

   Motivo:
   - La combinación carburante_id + precio es muy habitual:
       WHERE carburante_id = X
       ORDER BY precio ASC
   - El índice compuesto permite filtrar por carburante y ordenar
     por precio usando el mismo índice, de forma óptima.
   ------------------------------------------------------------ */
CREATE INDEX idx_precio_combustible_precio
    ON precio_carburante (carburante_id, precio);


-- ============================================================
-- 5. EJEMPLOS DE ANÁLISIS DE RENDIMIENTO CON EXPLAIN
--    (comentados para no ejecutarlos automáticamente)
--    Puedes descomentarlos en Workbench para mostrarlos en la
--    videomemoria.
-- ============================================================

/*
-- 5.1. Consulta 1: empresa con más estaciones TERRESTRES
EXPLAIN
SELECT 
    e.nombre       AS empresa,
    COUNT(*)       AS num_estaciones
FROM estacion_servicio es
JOIN empresa e 
    ON e.empresa_id = es.empresa_id
WHERE es.tipo_estacion = 'TERRESTRE'
GROUP BY e.nombre
ORDER BY num_estaciones DESC
LIMIT 1;


-- 5.2. Consulta 3: gasolinera más barata de Gasolina 95 en MADRID
EXPLAIN
SELECT 
    p.nombre   AS provincia,
    m.nombre   AS municipio,
    l.nombre   AS localidad,
    es.cod_postal,
    es.direccion,
    es.margen,
    emp.nombre AS empresa,
    pc.precio  AS precio_gasolina_95_e5
FROM precio_carburante pc
JOIN tipo_carburante tc
    ON pc.carburante_id = tc.carburante_id
JOIN estacion_servicio es
    ON pc.estacion_id = es.estacion_id
JOIN empresa emp
    ON es.empresa_id = emp.empresa_id
JOIN localidad l
    ON es.localidad_id = l.localidad_id
JOIN municipio m
    ON l.municipio_id = m.municipio_id
JOIN provincia p
    ON m.provincia_id = p.provincia_id
WHERE UPPER(tc.nombre) LIKE '%GASOLINA 95%'
  AND UPPER(p.nombre) = 'MADRID'
ORDER BY pc.precio ASC
LIMIT 1;
*/



