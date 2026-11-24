package es.carlosgr.miter.parser;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.*;

import java.io.FileInputStream;
import java.io.IOException;
import java.text.Normalizer;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class ExcelParser {

    // Representa una fila de estación con sus datos principales
    public static class StationRow {
        public String comunidad; // en este Excel viene vacía: se quedará null o "" y luego el ETL pondra
                                 // DESCONOCIDA
        public String provincia;
        public String municipio;
        public String localidad;
        public String codPostal;
        public String direccion;
        public String margen;
        public Double latitud;
        public Double longitud;
        public String empresa;
        public String horario;
        public LocalDate fechaActualizacion;
        public Map<String, Double> preciosPorCarburante = new HashMap<>();
    }

    /**
     * Parsea un fichero XLS del MITER y devuelve una lista de estaciones.
     * 
     * @param filePath     ruta al XLS (por ejemplo,
     *                     "./src/main/resources/preciosEESS_es.xls")
     * @param tipoEstacion "TERRESTRE" o "MARITIMA" (solo se usa después en
     *                     DataLoader)
     */
    public List<StationRow> parseFile(String filePath, String tipoEstacion) throws IOException {
        List<StationRow> result = new ArrayList<>();

        try (FileInputStream fis = new FileInputStream(filePath);
                Workbook workbook = new HSSFWorkbook(fis)) {

            Sheet sheet = workbook.getSheetAt(0);
            DataFormatter formatter = new DataFormatter();

            if (sheet.getPhysicalNumberOfRows() == 0) {
                return result;
            }

            // BUSCAR la fila real de CABECERAS: la que empieza por "Provincia"
            Row headerRow = null;
            int headerRowIndex = -1;

            for (int i = 0; i <= sheet.getLastRowNum(); i++) {
                Row possibleHeader = sheet.getRow(i);
                if (possibleHeader == null)
                    continue;

                Cell firstCell = possibleHeader.getCell(0);
                if (firstCell == null)
                    continue;

                String firstValue = formatter.formatCellValue(firstCell).trim();
                firstValue = firstValue.toLowerCase().replaceAll("\\s+", " ");

                if ("provincia".equals(firstValue)) {
                    headerRow = possibleHeader;
                    headerRowIndex = i;
                    break;
                }
            }

            if (headerRow == null) {
                throw new RuntimeException("No se ha encontrado la fila de cabeceras (Provincia) en el XLS");
            }

            // Mapa cabecera normalizada -> índice de columna
            Map<String, Integer> colIndex = buildHeaderIndex(headerRow, formatter);

            // Índices de columnas
            int idxProvincia = findColumn(colIndex, "provincia");
            int idxMunicipio = findColumn(colIndex, "municipio");
            int idxLocalidad = findColumn(colIndex, "localidad");
            int idxCP = findLike(colIndex, "codigo postal", "código postal");
            int idxDireccion = findLike(colIndex, "direccion", "dirección");
            int idxMargen = findColumn(colIndex, "margen");
            int idxLongitud = findColumn(colIndex, "longitud");
            int idxLatitud = findColumn(colIndex, "latitud");
            int idxEmpresa = findLike(colIndex, "rótulo", "rotulo");
            int idxHorario = findColumn(colIndex, "horario");
            int idxFechaAct = findLike(colIndex, "toma de datos");

            // Carburantes (según cabeceras: "Precio gasolina 95 E5", "Precio gasóleo A",

            int idxG95E5 = findLike(colIndex, "precio gasolina 95 e5");
            int idxGasoleoA = findLike(colIndex, "precio gasoleo a", "precio gasóleo a");

            DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

            // Bucle de datos: empiezan justo DESPUÉS de la fila de cabecera
            for (int r = headerRowIndex + 1; r <= sheet.getLastRowNum(); r++) {
                Row row = sheet.getRow(r);
                if (row == null)
                    continue;

                StationRow station = new StationRow();

                // Este Excel no trae comunidad en cabecera el ETL la tratará como DESCONOCIDA

                station.comunidad = null;

                station.provincia = getCellString(row, idxProvincia, formatter);
                station.municipio = getCellString(row, idxMunicipio, formatter);
                station.localidad = getCellString(row, idxLocalidad, formatter);
                station.codPostal = getCellString(row, idxCP, formatter);
                station.direccion = getCellString(row, idxDireccion, formatter);
                station.margen = getCellString(row, idxMargen, formatter);
                station.latitud = getCellDouble(row, idxLatitud, formatter);
                station.longitud = getCellDouble(row, idxLongitud, formatter);
                station.empresa = getCellString(row, idxEmpresa, formatter);
                station.horario = getCellString(row, idxHorario, formatter);

                // Toma de datos: formato "13/11/2025"
                String fechaStr = getCellString(row, idxFechaAct, formatter);
                if (!fechaStr.isBlank()) {
                    try {
                        String soloFecha = fechaStr.split(" ")[0]; // "13/11/2025"
                        station.fechaActualizacion = LocalDate.parse(soloFecha, dateFormatter);
                    } catch (Exception e) {
                        station.fechaActualizacion = null;
                    }
                }

                // Precios carburantes
                Double precio95 = getCellDouble(row, idxG95E5, formatter);
                if (precio95 != null) {
                    station.preciosPorCarburante.put("Gasolina 95 E5", precio95);
                }

                Double precioGasoleoA = getCellDouble(row, idxGasoleoA, formatter);
                if (precioGasoleoA != null) {
                    station.preciosPorCarburante.put("Gasoleo A", precioGasoleoA);
                }

                result.add(station);
            }
        }

        return result;
    }

    // Construye mapa "cabecera normalizada" -> índice de columna
    private Map<String, Integer> buildHeaderIndex(Row headerRow, DataFormatter formatter) {
        Map<String, Integer> index = new HashMap<>();
        for (int c = 0; c < headerRow.getLastCellNum(); c++) {
            Cell cell = headerRow.getCell(c);
            if (cell == null)
                continue;
            String raw = formatter.formatCellValue(cell).trim();
            if (raw.isEmpty())
                continue;
            String norm = normalize(raw);
            index.put(norm, c);
        }
        return index;
    }

    // Normaliza: minúsculas, sin acentos, sin dobles espacios
    private String normalize(String s) {
        String n = Normalizer.normalize(s, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", ""); // quitar acentos
        n = n.toLowerCase(Locale.ROOT);
        n = n.replaceAll("\\s+", " ").trim();
        return n;
    }

    /*
     * Busca una columna por uno de varios posibles nombres normalizados (igualdad
     * exacta tras normalizar)
     */
    private int findColumn(Map<String, Integer> index, String... posibles) {
        for (String p : posibles) {
            String norm = normalize(p);
            if (index.containsKey(norm)) {
                return index.get(norm);
            }
        }
        // si no se encuentra, devolvemos -1
        return -1;
    }

    // Busca una cabecera que CONTENGA todas las palabras clave
    private int findLike(Map<String, Integer> index, String... keywords) {
        for (Map.Entry<String, Integer> entry : index.entrySet()) {
            String header = entry.getKey(); // ya normalizada
            boolean allMatch = true;
            for (String kw : keywords) {
                if (!header.contains(normalize(kw))) {
                    allMatch = false;
                    break;
                }
            }
            if (allMatch) {
                return entry.getValue();
            }
        }
        return -1;
    }

    private String getCellString(Row row, int index, DataFormatter formatter) {
        if (index < 0)
            return "";
        Cell cell = row.getCell(index);
        if (cell == null)
            return "";
        return formatter.formatCellValue(cell).trim();
    }

    private Double getCellDouble(Row row, int index, DataFormatter formatter) {
        if (index < 0)
            return null;
        Cell cell = row.getCell(index);
        if (cell == null)
            return null;
        String value = formatter.formatCellValue(cell).replace(",", ".").trim();
        if (value.isEmpty())
            return null;
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
