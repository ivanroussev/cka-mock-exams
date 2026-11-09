ns main legacy
ip="$(docker inspect -f '{{(index .NetworkSettings.Networks "kind").IPAddress}}' "$REG_CACHE")"
[ -n "$ip" ] || { echo "registry cache has no IP on the kind network" >&2; exit 1; }
echo "$ip" > "$FILES/legacy-backend.txt"
