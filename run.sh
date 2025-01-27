# If not working, first do: sudo rm -rf /tmp/.docker.xauth
# If still not working, try running the script as root.

XAUTH=/tmp/.docker.xauth

echo "Preparing Xauthority data..."
xauth_list=$(xauth nlist :0 | tail -n 1 | sed -e 's/^..../ffff/')
if [ ! -f $XAUTH ]; then
    if [ ! -z "$xauth_list" ]; then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

echo "Done."
echo ""
echo "Verifying file contents:"
file $XAUTH
echo "--> It should say \"X11 Xauthority data\"."
echo ""
echo "Permissions:"
ls -FAlh $XAUTH
echo ""
echo "Running docker..."

docker run -it \
    --name blockbuster_humble_jetson \
    --rm \
    --runtime=nvidia \
    --gpus all \
    --privileged \
    --net=host \
    -e DISPLAY=unix$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -e XAUTHORITY=$XAUTH \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v $XAUTH:$XAUTH \
    -v /run/user/1000/at-spi:/run/user/1000/at-spi \
    -v /dev:/dev \
    jacquemont/blockbuster_os:latest
