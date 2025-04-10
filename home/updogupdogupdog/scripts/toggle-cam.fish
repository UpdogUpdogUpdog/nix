#!/usr/bin/env fish

set unbound 0
set found 0

for vdev in /sys/class/video4linux/video*
    set device_path (readlink $vdev/device 2> /dev/null)
    if test -z "$device_path"
        continue
    end

    set device_id (basename $device_path)
    set driver_path "/sys/bus/usb/drivers/uvcvideo/$device_id"
    set found 1

    if test -e "$driver_path"
        echo "Unbinding $device_id and unloading uvcvideo..."
        echo $device_id | sudo tee /sys/bus/usb/drivers/uvcvideo/unbind > /dev/null
        set unbound 1
    end
end

# if test $found -eq 0
#     kdialog --title "Webcam Toggle" --passivepopup "No /dev/video* devices found." 3
#     exit 1
# end

if test $unbound -eq 1
    sudo modprobe -r uvcvideo
    kdialog --title "Webcam Toggle" --passivepopup "Camera disabled." 3
else
    echo "Reloading uvcvideo and re-binding all cameras..."
    sudo modprobe uvcvideo
    sleep 3

    for vdev in /sys/class/video4linux/video*
        set device_path (readlink $vdev/device 2> /dev/null)
        if test -z "$device_path"
            continue
        end

        set device_id (basename $device_path)
        echo $device_id | sudo tee /sys/bus/usb/drivers/uvcvideo/bind > /dev/null
    end
    kdialog --title "Webcam Toggle" --passivepopup "Camera enabled." 3
end
