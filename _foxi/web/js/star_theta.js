
//
// Pollux (Hercules)
// β Gem - 78 Gem - HIP 37826 - SAO 79666 - HD 62509 - HR 2990 - WDS J07453+2802AB
// Type: double star
// Magnitude: 1.15
// Absolute Magnitude: 1.07
// Color Index (B-V): 0.98
// RA/Dec (J2000.0): 7h45m17.75s/+28°01'30.1"
// Gal. long./lat.: -167°46'16.1"/+23°24'06.2"
// Supergal. long./lat.: +42°06'14.6"/-44°36'10.6"
// Ecl. long./lat. (J2000.0): +113°12'41.3"/+6°40'56.2"
// IAU Constellation: Gem
// Distance: 33.78±0.09 ly
// Proper motion: 719.1 mas/yr towards 264.5°
// Proper motions by axes: -715.8 -68.7 (mas/yr)
// Parallax: 96.540±0.270 mas
// Spectral Type: K0IIIb
// Position angle (2009): 75.70°
// Separation (2009): 39.820"


function v(x,y,z) {
    return [x*8, y*8, z*8]
}

const PIONEER_OFFSET_RA = -90

let test_stars = [
    // {
    //     name: "pollux",
    //     j2000: `7h45m17.75s/+28°01'30.1"`,
    //     gal: `-167°46'16.1"/+23°24'06.2"`,
    //     "pos": [
    //         2.671999931335449,
    //         5.199999809265137,
    //         7.840000152587891
    //     ],
    //     "sector": [
    //         3,
    //         1,
    //         1
    //     ]
    // },
    {
        name: "gliese 251",
        sector: [1, 0, 1],
        pos : [7.256, 3.72, 2.312],
        j2000: "6h54m47.48s/+33°15'56.1\"",
        dist: 18.2
    },
    {
        name: "sirius",
        // 1,0,-1,v(0.0100,0.2010,0.6910)
        sector: [1,0,-1],
        pos: v(0.0100,0.2010,0.6910),
        j2000: `6h45m07.85s/-16°43'30.0"`,
        dist: 8.60 //+-0.04ly
    }
    /*Sirius (Canicula - Aschere)
α CMa - 9 CMa - AGC 1 - HIP 32349 - SAO 151881 - HD 48915 - HR 2491 - WDS J06451-1643AB
Type: double star
Magnitude: -1.45
Absolute Magnitude: 1.44
Color Index (B-V): 0.00
RA/Dec (J2000.0): 6h45m07.85s/-16°43'30.0"
Gal. long./lat.: -132°45'48.6"/-8°53'52.8"
Supergal. long./lat.: -87°04'12.9"/-87°25'07.0"
Ecl. long./lat. (J2000.0): +104°04'38.2"/-39°36'52.2"
IAU Constellation: CMa
Distance: 8.60±0.04 ly
Proper motion: 1589.6 mas/yr towards 204.6°
Proper motions by axes: -661.7 -1445.3 (mas/yr)
Parallax: 379.210±1.580 mas
Spectral Type: A1V+DA
Position angle (2015): 80.30°
Separation (2015): 10.670"*/

]


const a = require("./lib_astro_crs")
const {degreesToRadians} = require("./lib_astro_crs");

function test_pioneer_offest(star)  {


    let name = star.name;

    let pos = a.parse_sector_pos(star.sector, star.pos)

    let equ = a.parseStellariumEqu(star.j2000)

    if(star.gal) {
        let gal = a.parseStellariumGal(star.gal)
        let equ2 = a.ga2equ(gal)

        console.log("ga2equ", equ2)

    }

    let pos_equ = a.calculateAngles(pos.x, pos.y, pos.z);
    let ra =pos_equ.thetaXYDegrees
    let dec =pos_equ.thetaXZDegrees

    // let pos_equ = a.cartesianToEquatorial(pos.x, pos.y, pos.z);
    // let ra = a.radiansToDegrees(pos_equ.ra);
    // let dec = a.radiansToDegrees(pos_equ.dec)
    console.log(pos);

    let pioneer_pos_equ = {ra, dec}
    console.log("Pioneer Pos Equ: ", pioneer_pos_equ);
    console.log("Stellar Pos Equ: ", equ);

    let deltaRa =  ra - equ.ra;
    let deltaDec =  dec - equ.dec;

    console.debug(`[End test debug]`)


    return {deltaDec, deltaRa, ra:equ.ra+PIONEER_OFFSET_RA, dec: equ.dec, pos}  //TODO STANDARDISE THIS AND FIGURE OUT THE BEST WAY
}

//Here we track the error of our test stars to see what the common offset is for pioneer
// Looks to me like a -90 degree XY plane rotation.
let err = test_stars.map(star=>{
    let res = test_pioneer_offest(star)

    if(star.dist) {

        console.log("stellar_input_w_offset_ra (ra,dec,dist) :", res.ra, res.dec, star.dist)
        let p = a.calculateCartesian(res.ra, res.dec, star.dist)

        let pioner_pos = a.get_sector_pos(p.x,p.y,p.z); /// this is a rotation maybe but still somthing is broken idk
        console.log("stellar_pos_calculated: ", p);
        console.log("approx_pos_form_pioneer: ", res.pos);

        console.log("stellar_pioneer_output: ",pioner_pos);
        console.log("original_pioneer_input: ", {sector: star.sector, pos:star.pos});
    }

    return [star.name, res]
})

console.log(err)
