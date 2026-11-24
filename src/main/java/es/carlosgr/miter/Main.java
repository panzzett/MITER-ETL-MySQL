package es.carlosgr.miter;

import es.carlosgr.miter.loader.DataLoader;

public class Main {
    public static void main(String[] args) {

        // Rutas simples hacia los ficheros Excel dentro del proyecto
        String ficheroTerrestres = "./src/main/resources/preciosEESS_es.xls";
        String ficheroMaritimas = "./src/main/resources/embarcacionesPrecios_es.xls";

        DataLoader loader = new DataLoader();

        try {
            System.out.println("==== CARGA DE ESTACIONES TERRESTRES ====");
            loader.loadFile(ficheroTerrestres, "TERRESTRE");

            System.out.println("==== CARGA DE ESTACIONES MARÍTIMAS ====");
            loader.loadFile(ficheroMaritimas, "MARITIMA");

            System.out.println("PROCESO COMPLETADO SIN ERRORES");

        } catch (Exception e) {
            System.err.println("ERROR DURANTE LA CARGA:");
            e.printStackTrace();
        }
    }
}
