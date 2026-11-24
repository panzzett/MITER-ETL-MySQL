package es.carlosgr.miter.loader;

import es.carlosgr.miter.db.DatabaseManager;
import es.carlosgr.miter.parser.ExcelParser;
import es.carlosgr.miter.parser.ExcelParser.StationRow;

import java.sql.*;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public class DataLoader {

    public void loadFile(String filePath, String tipoEstacion) throws Exception {
        ExcelParser parser = new ExcelParser();
        List<StationRow> rows = parser.parseFile(filePath, tipoEstacion);

        System.out.println("Leídas " + rows.size() + " filas desde " + filePath);

        try (Connection conn = DatabaseManager.getConnection()) {
            conn.setAutoCommit(false);

            for (StationRow row : rows) {
                int comunidadId = ensureComunidad(conn, row.comunidad);
                int provinciaId = ensureProvincia(conn, row.provincia, comunidadId);
                int municipioId = ensureMunicipio(conn, row.municipio, provinciaId);
                int localidadId = ensureLocalidad(conn, row.localidad, municipioId);
                int empresaId = ensureEmpresa(conn, row.empresa);

                int estacionId = insertEstacion(conn, empresaId, localidadId, row, tipoEstacion);

                LocalDate fecha = (row.fechaActualizacion != null) ? row.fechaActualizacion : LocalDate.now();

                for (Map.Entry<String, Double> entry : row.preciosPorCarburante.entrySet()) {
                    String nombreCarburante = entry.getKey();
                    Double precio = entry.getValue();
                    if (precio == null)
                        continue;

                    int carburanteId = ensureCarburante(conn, nombreCarburante);
                    insertPrecio(conn, estacionId, carburanteId, fecha, precio);
                }
            }

            conn.commit();
            System.out.println("Inserción completada para " + filePath);
        }
    }

    private int ensureComunidad(Connection conn, String nombre) throws SQLException {
        if (nombre == null || nombre.isBlank())
            nombre = "DESCONOCIDA";
        String select = "SELECT comunidad_id FROM comunidad_autonoma WHERE nombre = ?";
        try (PreparedStatement ps = conn.prepareStatement(select)) {
            ps.setString(1, nombre);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getInt(1);
        }

        String insert = "INSERT INTO comunidad_autonoma(nombre) VALUES (?)";
        try (PreparedStatement ps = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, nombre);
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next())
                return rs.getInt(1);
        }
        throw new SQLException("No se pudo insertar comunidad_autonoma");
    }

    private int ensureProvincia(Connection conn, String nombre, int comunidadId) throws SQLException {
        if (nombre == null || nombre.isBlank())
            nombre = "DESCONOCIDA";
        String select = "SELECT provincia_id FROM provincia WHERE nombre = ? AND comunidad_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(select)) {
            ps.setString(1, nombre);
            ps.setInt(2, comunidadId);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getInt(1);
        }

        String insert = "INSERT INTO provincia(nombre, comunidad_id) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, nombre);
            ps.setInt(2, comunidadId);
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next())
                return rs.getInt(1);
        }
        throw new SQLException("No se pudo insertar provincia");
    }

    private int ensureMunicipio(Connection conn, String nombre, int provinciaId) throws SQLException {
        if (nombre == null || nombre.isBlank())
            nombre = "DESCONOCIDO";
        String select = "SELECT municipio_id FROM municipio WHERE nombre = ? AND provincia_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(select)) {
            ps.setString(1, nombre);
            ps.setInt(2, provinciaId);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getInt(1);
        }

        String insert = "INSERT INTO municipio(nombre, provincia_id) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, nombre);
            ps.setInt(2, provinciaId);
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next())
                return rs.getInt(1);
        }
        throw new SQLException("No se pudo insertar municipio");
    }

    private int ensureLocalidad(Connection conn, String nombre, int municipioId) throws SQLException {
        if (nombre == null || nombre.isBlank())
            nombre = "DESCONOCIDA";
        String select = "SELECT localidad_id FROM localidad WHERE nombre = ? AND municipio_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(select)) {
            ps.setString(1, nombre);
            ps.setInt(2, municipioId);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getInt(1);
        }

        String insert = "INSERT INTO localidad(nombre, municipio_id) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, nombre);
            ps.setInt(2, municipioId);
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next())
                return rs.getInt(1);
        }
        throw new SQLException("No se pudo insertar localidad");
    }

    private int ensureEmpresa(Connection conn, String nombre) throws SQLException {
        if (nombre == null || nombre.isBlank())
            nombre = "DESCONOCIDA";
        String select = "SELECT empresa_id FROM empresa WHERE nombre = ?";
        try (PreparedStatement ps = conn.prepareStatement(select)) {
            ps.setString(1, nombre);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getInt(1);
        }

        String insert = "INSERT INTO empresa(nombre) VALUES (?)";
        try (PreparedStatement ps = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, nombre);
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next())
                return rs.getInt(1);
        }
        throw new SQLException("No se pudo insertar empresa");
    }

    private int ensureCarburante(Connection conn, String nombre) throws SQLException {
        String select = "SELECT carburante_id FROM tipo_carburante WHERE nombre = ?";
        try (PreparedStatement ps = conn.prepareStatement(select)) {
            ps.setString(1, nombre);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getInt(1);
        }

        String insert = "INSERT INTO tipo_carburante(nombre) VALUES (?)";
        try (PreparedStatement ps = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, nombre);
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next())
                return rs.getInt(1);
        }
        throw new SQLException("No se pudo insertar tipo_carburante");
    }

    private int insertEstacion(Connection conn, int empresaId, int localidadId,
            StationRow row, String tipoEstacion) throws SQLException {

        String sql = "INSERT INTO estacion_servicio " +
                "(empresa_id, localidad_id, cod_postal, direccion, margen, latitud, longitud, " +
                "tipo_estacion, horario, fecha_ultima_actualizacion) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, empresaId);
            ps.setInt(2, localidadId);
            ps.setString(3, row.codPostal);
            ps.setString(4, row.direccion);
            ps.setString(5, row.margen);
            if (row.latitud != null)
                ps.setDouble(6, row.latitud);
            else
                ps.setNull(6, Types.DECIMAL);
            if (row.longitud != null)
                ps.setDouble(7, row.longitud);
            else
                ps.setNull(7, Types.DECIMAL);
            ps.setString(8, tipoEstacion);
            ps.setString(9, row.horario);
            if (row.fechaActualizacion != null) {
                ps.setDate(10, Date.valueOf(row.fechaActualizacion));
            } else {
                ps.setNull(10, Types.DATE);
            }

            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next())
                return rs.getInt(1);
        }
        throw new SQLException("No se pudo insertar estacion_servicio");
    }

    private void insertPrecio(Connection conn, int estacionId, int carburanteId,
            LocalDate fecha, double precio) throws SQLException {

        String sql = "INSERT INTO precio_carburante(estacion_id, carburante_id, fecha_actualizacion, precio) " +
                "VALUES (?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, estacionId);
            ps.setInt(2, carburanteId);
            ps.setDate(3, Date.valueOf(fecha));
            ps.setBigDecimal(4, new java.math.BigDecimal(String.format(java.util.Locale.US, "%.3f", precio)));
            ps.executeUpdate();
        }
    }
}
