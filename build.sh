#!/bin/bash

echo "FOXI.EAPI.SPACE BUILD"

./zip_mod.sh mod n ;
echo "Warning not installing to game folder for dev environment use:"
echo "  ./zip_mod.sh mod y"

echo "Zipped mods release to _release directory."

cp _release/* _foxi/web/release/mirror
echo "Copied _release to _foxi web release mirror."

echo "You can now deploy '_foxi/web' to a server."
echo "Done."