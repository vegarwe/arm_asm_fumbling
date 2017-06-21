#set -e

rm -f _build/unity_output.txt

/cygdrive/c/Keil_v5/UV4/UV4.exe -j0 -b unit_test.uvprojx -t Simulator
if [ "$?" -ne "0" ]; then
    echo "Build failed"
    cat _build/Simulator.build_log.htm
    exit 3
fi

/cygdrive/c/Keil_v5/UV4/UV4.exe -j0 -d unit_test.uvprojx -t Simulator
#if [ "$?" -ne "0" ]; then
#    echo "Simulation failed"
#    cat _build/Simulator.build_log.htm
#    exit 3
#fi

cat _build/unity_output.txt

