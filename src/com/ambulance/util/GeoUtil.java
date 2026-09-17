package com.ambulance.util;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * Lightweight geocoding + distance helper for Module 5 (Nearest Ambulance
 * Allocation & Tracking).
 *
 * The system doesn't store real GPS coordinates anywhere (ambulances only
 * have a free-text "current_location", requests only have a free-text
 * "location") and there's no map API key wired up, so this class turns
 * that free text into a stable lat/lng:
 *  - Known place names (the ones already seeded by DBInitializer) map to
 *    their real approximate Chennai coordinates.
 *  - Anything else is geocoded deterministically: the same location text
 *    always resolves to the same point (seeded by the text's hash), placed
 *    a few km around Chennai city center. This keeps "nearest ambulance"
 *    and "distance/ETA" calculations consistent across requests without
 *    needing a real geocoding service.
 */
public class GeoUtil {

    // Chennai city center - used as the anchor for unknown locations.
    private static final double CENTER_LAT = 13.0827;
    private static final double CENTER_LNG = 80.2707;

    // Roughly ±0.05 degrees (~5-6 km) of spread around the city center.
    private static final double SPREAD = 0.05;

    private static final double AVG_SPEED_KMPH = 40.0; // urban emergency-run average
    private static final double DISPATCH_BUFFER_MIN = 2.0; // time to move off / start engine

    private static final Map<String, double[]> KNOWN_LOCATIONS = new HashMap<>();
    static {
        // Ambulance depots seeded in DBInitializer
        KNOWN_LOCATIONS.put("central station", new double[]{13.0827, 80.2707});
        KNOWN_LOCATIONS.put("downtown district", new double[]{13.0418, 80.2341});
        KNOWN_LOCATIONS.put("service depot", new double[]{13.0067, 80.2206});

        // Sample emergency request locations seeded in DBInitializer
        KNOWN_LOCATIONS.put("12 anna nagar, chennai", new double[]{13.0850, 80.2101});
        KNOWN_LOCATIONS.put("mg road bus stop, chennai", new double[]{13.0604, 80.2496});
        KNOWN_LOCATIONS.put("7 lake view colony, chennai", new double[]{13.0994, 80.1998});
    }

    private GeoUtil() {
    }

    /** Resolves a free-text location into {latitude, longitude}. */
    public static double[] geocode(String locationText) {
        if (locationText == null) {
            return new double[]{CENTER_LAT, CENTER_LNG};
        }
        String key = locationText.trim().toLowerCase();
        double[] known = KNOWN_LOCATIONS.get(key);
        if (known != null) {
            return known;
        }
        // Deterministic pseudo-random offset so the same text always geocodes
        // to the same point (stable across requests without a real geocoder).
        Random rnd = new Random(key.hashCode());
        double latOffset = (rnd.nextDouble() * 2 - 1) * SPREAD;
        double lngOffset = (rnd.nextDouble() * 2 - 1) * SPREAD;
        return new double[]{CENTER_LAT + latOffset, CENTER_LNG + lngOffset};
    }

    /** Great-circle distance between two points, in kilometers (Haversine formula). */
    public static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
        final double R = 6371.0; // Earth radius in km
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    /** Convenience overload: distance between two free-text locations. */
    public static double distanceKm(String locationA, String locationB) {
        double[] a = geocode(locationA);
        double[] b = geocode(locationB);
        return distanceKm(a[0], a[1], b[0], b[1]);
    }

    /** Estimated arrival time in whole minutes, given a distance in km. */
    public static int estimateEtaMinutes(double distanceKm) {
        double minutes = (distanceKm / AVG_SPEED_KMPH) * 60.0 + DISPATCH_BUFFER_MIN;
        return Math.max(3, (int) Math.ceil(minutes));
    }
}
