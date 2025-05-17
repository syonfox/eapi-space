

const PIONEER_OFFSET_RA = -90

function ga2equ(ga) {
    /**
     * Convert Galactic to Equatorial coordinates (J2000.0)
     *
     * Input: [l, b] in decimal degrees
     * Returns: [ra, dec] in decimal degrees
     */

    const toRadians = (degrees) => degrees * (Math.PI / 180);
    const toDegrees = (radians) => radians * (180 / Math.PI);

    const l = toRadians(ga[0]);
    const b = toRadians(ga[1]);

    // North galactic pole (J2000)
    const poleRA = toRadians(192.859508);
    const poleDec = toRadians(27.128336);
    const posAngle = toRadians(122.932 - 90.0);

    // Calculate RA and Dec
    const ra = Math.atan2(
        Math.cos(b) * Math.cos(l - posAngle),
        Math.sin(b) * Math.cos(poleDec) - Math.cos(b) * Math.sin(poleDec) * Math.sin(l - posAngle)
    ) + poleRA;

    const dec = Math.asin(
        Math.cos(b) * Math.cos(poleDec) * Math.sin(l - posAngle) + Math.sin(b) * Math.sin(poleDec)
    );

    // Return in decimal degrees
    return [toDegrees(ra), toDegrees(dec)];
}


function parseStellariumGal(galStr) {
    /**
     * Parse Stellarium Galactic coordinates.
     * Input: Gal. long./lat. string (e.g., "-177°03'47.7\"/+15°07'46.8\"")
     * Output: [l, b] in decimal degrees
     */
    const parseCoord = (coordStr) => {
        const match = coordStr.match(/([-+]?\d+)°(\d+)'([\d.]+)"/);
        if (!match) throw new Error("Invalid Galactic coordinate format");
        const degrees = parseFloat(match[1]);
        const minutes = parseFloat(match[2]);
        const seconds = parseFloat(match[3]);
        return degrees + (minutes / 60) + (seconds / 3600);
    };

    const [longStr, latStr] = galStr.split("/");
    const galLong = parseCoord(longStr.trim());
    const galLat = parseCoord(latStr.trim());

    return [galLong, galLat];
}



// used for convertin right assention in hours mins secs to decimal degrees
function hms2dd(str) {

        // Remove any whitespace
        str = str.trim();

        // Regular expression to match the RA format: 6h54m47.48s
        const match = str.match(/(\d+)h(\d+)m([\d.]+)s/);
        if (!match) {
            throw new Error("Invalid RA format. Expected format: '6h54m47.48s'");
        }

        // Extract hours, minutes, and seconds from the match
        const hours = parseInt(match[1], 10);
        const minutes = parseInt(match[2], 10);
        const seconds = parseFloat(match[3]);

        // Convert RA to decimal degrees
        // const raDegrees = (hours + minutes / 60 + seconds / 3600) * 15;
        const raDegrees = (hours * 15) + (minutes * 0.25) + (seconds * 0.004166666666666667);
        return raDegrees;
    }

function dms2dd(decStr) {

    const match = decStr.match(/([-+]?\d+)°(\d+)'([\d.]+)"/);
    if (!match) throw new Error("Invalid Dec format");
    const degrees = parseFloat(match[1]);
    const minutes = parseFloat(match[2]);
    const seconds = parseFloat(match[3]);
    return degrees + (minutes / 60) + (seconds / 3600);
}

const SECTOR_SIZE = 8
function parse_sector_pos(sec = [1, 0, 1], pos = [7.256, 3.72, 2.312]) {

    let ap = [
        sec[0] * SECTOR_SIZE + pos[0],
        sec[1] * SECTOR_SIZE + pos[1],
        sec[2] * SECTOR_SIZE + pos[2],
    ]

    console.log("Actual Pos (x,y,z): ", ap)
    return {x: ap[0], y: ap[1], z: ap[2]}

}

function get_sector_pos(x, y, z) {
    function adjustCoord(coord) {
        const pos = ((coord % SECTOR_SIZE) + SECTOR_SIZE) % SECTOR_SIZE; // Ensure positive remainder
        const sector = Math.floor(coord / SECTOR_SIZE); // Floor for consistent sector index
        return { pos, sector };
    }

    const adjustedX = adjustCoord(x);
    const adjustedY = adjustCoord(y);
    const adjustedZ = adjustCoord(z);

    return {
        sector: [adjustedX.sector, adjustedY.sector, adjustedZ.sector],
        pos: [adjustedX.pos, adjustedY.pos, adjustedZ.pos]
    };
}

function approx_j2000_to_pioneer_equatorial(ra, dec) {
    return {ra: ra+PIONEER_OFFSET_RA, dec: dec}
}

// Optional: Function to convert radians to degrees
function radiansToDegrees(rad) {
    return rad * (180 / Math.PI);
}
function degreesToRadians(deg) {

    return deg * (Math.PI / 180);
}


function parseStellariumEqu(equStr) {
    /**
     * Parse Stellarium Equatorial coordinates.
     * Input: RA/Dec string (e.g., "6h54m47.48s/+33°15'56.1\"")
     * Output: [ra, dec] in decimal degrees
     */
    const parseRA = hms2dd
    const parseDec = dms2dd;

    const [raStr, decStr] = equStr.split("/");
    const ra = parseRA(raStr.trim());
    const dec = parseDec(decStr.trim());

    return {ra, dec};
}

// //stelariums
// const equStr = "6h54m47.48s/+33°15'56.1\"";
// const equCoords = parseStellariumEqu(equStr);
// console.log("Equatorial Coordinates From Stellarium (RA, Dec):", equCoords);
//


function calculate_angles(x, y, z) {
    // Angle in the XY plane (radians)
    const thetaXY = Math.atan2(y, x);

    // Angle in the XZ plane (radians)
    const thetaXZ = Math.atan2(z, x);

    // Convert radians to degrees
    return {
        thetaXY: thetaXY,                       // XY angle in radians
        thetaXYDegrees: radiansToDegrees(thetaXY), // XY angle in degrees
        thetaXZ: thetaXZ,                       // XZ angle in radians
        thetaXZDegrees: radiansToDegrees(thetaXZ)  // XZ angle in degrees
    };
}
function calculate_cartesian(thetaXYDegrees, thetaXZDegrees, dist = 1) {
    // Convert angles from degrees to radians if needed
    const thetaXY = degreesToRadians(thetaXYDegrees);
    const thetaXZ = degreesToRadians(thetaXZDegrees);

    // Calculate Cartesian coordinates
    const x = dist * Math.cos(thetaXZ); // Component in the X direction
    const y = dist * Math.sin(thetaXY) * Math.cos(thetaXZ); // Y depends on XY angle and XZ scaling
    const z = dist * Math.sin(thetaXZ); // Z depends only on the XZ angle

    return { x, y, z };
}


// Example usage:
// const position = { x: 1.0, y: 1.0, z: 1.0 };
// const angles = calculateAngles(position.x, position.y, position.z);
//
// console.log("Angle in XY plane (radians):", angles.thetaXY);
// console.log("Angle in XY plane (degrees):", angles.thetaXYDegrees);
// console.log("Angle in XZ plane (radians):", angles.thetaXZ);
// console.log("Angle in XZ plane (degrees):", angles.thetaXZDegrees);






function testConversionSimple(galStr, equStr) {
    /**
     * Test the error from converting galactic to equatorial coordinates.
     *
     * @param {string} galStr - Galactic coordinates in Stellarium format.
     * @param {string} equStr - Equatorial coordinates in Stellarium format.
     * @returns {object} - Object containing errors and key intermediate results.
     */
    const parsedGal = parseStellariumGal(galStr);
    const expectedEqu = parseStellariumEqu(equStr);
    const convertedEqu = ga2equ(parsedGal);

    const raError = Math.abs(convertedEqu[0] - expectedEqu[0]);
    const decError = Math.abs(convertedEqu[1] - expectedEqu[1]);

    console.log("Test Conversion Results:");
    console.log("  Input Galactic:", galStr);
    console.log("  Parsed Galactic:", parsedGal);
    console.log("  Input Equatorial:", equStr);
    console.log("  Parsed Equatorial:", expectedEqu);
    console.log("  Converted Equatorial:", convertedEqu);
    console.log("  Errors: RA Error =", raError, "degrees, Dec Error =", decError, "degrees");

    return {
        parsedGalactic: parsedGal,
        expectedEquatorial: expectedEqu,
        convertedEquatorial: convertedEqu,
        errors: {raError, decError}

    };
}


function test() {


    // Example usage:
    const galacticCoords = [0.0, 0.0]; // Galactic center
    const equatorialCoords = ga2equ(galacticCoords);
    console.log("Equatorial Coordinates (galactic center) (RA, Dec):", equatorialCoords);
    // Example Usage


    const galStr = "-177°03'47.7\"/+15°07'46.8\"";
    const equStr = "6h54m47.48s/+33°15'56.1\"";

    const galCoords = parseStellariumGal(galStr);
    const equCoords = parseStellariumEqu(equStr);

    console.log("Galactic Coordinates (l, b):", galCoords);
    console.log("Equatorial Coordinates (RA, Dec):", equCoords);

    const result = testConversionSimple(galStr, equStr);
    console.log("Final Test Results:", result);

}
const a = {
    // parseDms,
    dms2dd,
    hms2dd,
    radiansToDegrees,
    degreesToRadians,
    ga2equ,
    parseStellariumEqu,
    parseStellariumGal,
    parse_sector_pos,
    calculate_angles, // this seems to corectly coraspond to pioneer???
    calculate_cartesian, // invert above i hope
    get_sector_pos,
    approx_j2000_to_pioneer_equatorial,
    equatorialToCartesian,
    cartesianToEquatorial
}
// Only export if `module` is defined (ES module environment)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = a;
}// Ensure the function is globally available if not using a module system
if (typeof window !== 'undefined') {
    window.a =  a;
}