set -e
cp include/config.h /tmp/pi-eval-cfg.bak; cp include/util.h /tmp/pi-eval-util.bak
trap 'cp /tmp/pi-eval-cfg.bak include/config.h; cp /tmp/pi-eval-util.bak include/util.h' EXIT
grep -q 'hello v1' include/config.h && grep -q 'SCALE 1' include/util.h
rm -rf build app; find . -name '*.o' -o -name '*.d' | xargs -r rm -f
make -j8 >/dev/null 2>&1
[ "$(./app)" = "hello v1 5" ]
[ -z "$(make -j8 -n 2>/dev/null | grep -E 'gcc|cc ')" ]
sleep 1; sed -i 's/hello v1/hello v2/' include/config.h
out=$(make -j8 2>&1); echo "$out" | grep -q 'main\.c'
if echo "$out" | grep -q 'util\.c'; then echo "util.c rebuilt needlessly"; exit 1; fi
[ "$(./app)" = "hello v2 5" ]
sleep 1; sed -i 's/SCALE 1/SCALE 2/' include/util.h
make -j8 >/dev/null 2>&1; [ "$(./app)" = "hello v2 10" ]
[ -z "$(make -n 2>/dev/null | grep -E 'gcc|cc ')" ]
touch clean; make clean >/dev/null 2>&1; rm -f clean
[ ! -e app ] && [ -z "$(find . -name '*.o')" ]
