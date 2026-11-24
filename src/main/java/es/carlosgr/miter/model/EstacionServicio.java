package es.carlosgr.miter.model;

public class EstacionServicio {
    private String tipo;
    private String rotulo;
    private String direccion;
    private String localidad;
    private String provincia;
    private String cp;
    private double precioGasolina95;
    private double precioGasoleoA;

    public EstacionServicio(String tipo, String rotulo, String direccion, String localidad, String provincia, String cp,
            double precioGasolina95, double precioGasoleoA) {
        this.tipo = tipo;
        this.rotulo = rotulo;
        this.direccion = direccion;
        this.localidad = localidad;
        this.provincia = provincia;
        this.cp = cp;
        this.precioGasolina95 = precioGasolina95;
        this.precioGasoleoA = precioGasoleoA;
    }

    @Override
    public String toString() {
        return String.format("%s - %s (%s) - %s - Precio Gasolina 95: %.3f, Gasóleo A: %.3f",
                tipo, rotulo, localidad, provincia, precioGasolina95, precioGasoleoA);
    }

    public String getTipo() {
        return tipo;
    }

    public String getRotulo() {
        return rotulo;
    }

    public String getDireccion() {
        return direccion;
    }

    public String getLocalidad() {
        return localidad;
    }

    public String getProvincia() {
        return provincia;
    }

    public String getCp() {
        return cp;
    }

    public double getPrecioGasolina95() {
        return precioGasolina95;
    }

    public double getPrecioGasoleoA() {
        return precioGasoleoA;
    }
}
