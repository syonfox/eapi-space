function galactic_pos_to_pioneer(rightAscension, declination, distance, sectorSize = 8) {
    // Convert RA and Dec from degrees to radians
    const ra = (rightAscension / 24) * 2 * Math.PI; // RA in hours to radians
    const dec = (declination / 180) * Math.PI; // Dec in degrees to radians

    // Convert equatorial to Cartesian coordinates
    const x_eq = distance * Math.cos(dec) * Math.cos(ra);
    const y_eq = distance * Math.cos(dec) * Math.sin(ra);
    const z_eq = distance * Math.sin(dec);

    console.log("Equatorial Cartesian:", { x_eq, y_eq, z_eq });

    // Equatorial to Galactic transformation (matrix multiplication)
    const transformMatrix = [
        [-0.0548755604, -0.8734370902, -0.4838350155],
        [ 0.4941094279, -0.4448296300,  0.7469822445],
        [-0.8676661490, -0.1980763734,  0.4559837762]
    ];

    const x_gal = transformMatrix[0][0] * x_eq + transformMatrix[0][1] * y_eq + transformMatrix[0][2] * z_eq;
    const y_gal = transformMatrix[1][0] * x_eq + transformMatrix[1][1] * y_eq + transformMatrix[1][2] * z_eq;
    const z_gal = transformMatrix[2][0] * x_eq + transformMatrix[2][1] * y_eq + transformMatrix[2][2] * z_eq;

    console.log("Galactic Cartesian:", { x_gal, y_gal, z_gal });

    // Adjust coordinates relative to Sol
    const solGalactic = { x: 0, y: 0, z: 0 }; // Sol is (0, 0, 0) in Pioneer
    const x_rel = x_gal - solGalactic.x;
    const y_rel = y_gal - solGalactic.y;
    const z_rel = z_gal - solGalactic.z;

    console.log("Relative to Sol:", { x_rel, y_rel, z_rel });

    // Compute sector indices
    const sectorX = Math.floor(x_rel / sectorSize);
    const sectorY = Math.floor(y_rel / sectorSize);
    const sectorZ = Math.floor(z_rel / sectorSize);

    // Compute position within the sector
    const posX = x_rel - sectorX * sectorSize;
    const posY = y_rel - sectorY * sectorSize;
    const posZ = z_rel - sectorZ * sectorSize;

    return {
        sector: { x: sectorX, y: sectorY, z: sectorZ },
        pos: { x: posX, y: posY, z: posZ }
    };
}

// Example usage for Gliese 251
const rightAscension = 6 + 54 / 60 + 48.95806 / 3600; // 6h 54m 48.95806s
const declination = 33 + 16 / 60 + 5.4383 / 3600;     // +33° 16′ 05.4383″
const distance = 18.215;                             // 18.215 ly

const result = galactic_pos_to_pioneer(rightAscension, declination, distance);
console.log("Result:", result);
