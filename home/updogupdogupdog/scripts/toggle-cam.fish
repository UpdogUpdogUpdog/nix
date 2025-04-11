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
        echo "Attempting to unbind $device_id from uvcvideo..."

        set retries 5
        set success 0

        for i in (seq $retries)
            echo $device_id | sudo tee /sys/bus/usb/drivers/uvcvideo/unbind > /dev/null
            sleep 1

            if not test -e "$driver_path"
                echo "$device_id successfully unbound after $i attempt(s)."
                set success 1
                break
            else
                echo "Unbind attempt $i failed... retrying in 5s."
                sleep 5
            end
        end

        if test $success -eq 1
            set unbound 1
        else
            echo "Failed to unbind $device_id after $retries attempts. Skipping."
        end
    end
end

if test $unbound -eq 1
    echo "Unbinding done, trying to unload uvcvideo..."
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

        # set device_id (basename $device_path)
        # echo $device_id | sudo tee /sys/bus/usb/drivers/uvcvideo/bind > /dev/null
    end

    kdialog --title "Webcam Toggle" --passivepopup "Camera enabled." 3
end