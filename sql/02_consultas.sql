/*Consulta 1: */
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
/*Consulta 2*/
SELECT 
    e.nombre       AS empresa,
    COUNT(*)       AS num_estaciones
FROM estacion_servicio es
JOIN empresa e 
    ON e.empresa_id = es.empresa_id
WHERE es.tipo_estacion = 'MARITIMA'
GROUP BY e.nombre
ORDER BY num_estaciones DESC
LIMIT 1;

RESULTADO: REPSOL	2727


/*Consulta 2*/

SELECT 
    e.nombre       AS empresa,
    COUNT(*)       AS num_estaciones
FROM estacion_servicio es
JOIN empresa e 
    ON e.empresa_id = es.empresa_id
WHERE es.tipo_estacion = 'MARITIMA'
GROUP BY e.nombre
ORDER BY num_estaciones DESC
LIMIT 1;

RESULTADO: REPSOL	71

/*Consulta 3*/

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

RESULTADO: MADRID	COSLADA	COSLADA	28820	AVENIDA DEL JARAMA, 17	D	PLENERGY	1.289

/*Consulta 4*/


SELECT 
    es.estacion_id,
    emp.nombre        AS empresa,
    es.direccion,
    es.margen,
    pc.precio         AS precio_gasoleo_a,
    es.latitud,
    es.longitud,
    (6371 * ACOS(
        COS(RADIANS(38.994349)) * COS(RADIANS(es.latitud)) *
        COS(RADIANS(es.longitud) - RADIANS(-1.858542)) +
        SIN(RADIANS(38.994349)) * SIN(RADIANS(es.latitud))
    )) AS distancia_km
FROM precio_carburante pc
JOIN tipo_carburante tc
    ON pc.carburante_id = tc.carburante_id
JOIN estacion_servicio es
    ON pc.estacion_id = es.estacion_id
JOIN empresa emp
    ON es.empresa_id = emp.empresa_id
WHERE UPPER(tc.nombre) = 'GASOLEO A'
HAVING distancia_km <= 10
ORDER BY pc.precio ASC
LIMIT 1;

RESULTADO: 10	A&A	AVENIDA ESCRITOR RODRIGO RUBIO, 3	D	1.297	39.006889	-1.885361	2.7046769323542676

/*Consulta 5*/

SELECT
    emp.nombre     AS empresa,
    es.direccion,
    es.cod_postal,
    pc.precio      AS precio_gasoleo_a,
    (
      6371 * acos(
          cos(radians(38.994349))
        * cos(radians(es.latitud))
        * cos(radians(es.longitud) - radians(-1.858542))
        + sin(radians(38.994349)) * sin(radians(es.latitud))
      )
    ) AS distancia_km
FROM precio_carburante pc
JOIN tipo_carburante tc
    ON pc.carburante_id = tc.carburante_id
JOIN estacion_servicio es
    ON pc.estacion_id = es.estacion_id
JOIN empresa emp
    ON es.empresa_id = emp.empresa_id
WHERE UPPER(tc.nombre) LIKE '%GASOLEO A%'
HAVING distancia_km <= 10
ORDER BY pc.precio ASC
LIMIT 1;


resultado:
'A&A', 'AVENIDA ESCRITOR RODRIGO RUBIO, 3', '02005', '1.297', '2.7046769323542676'



