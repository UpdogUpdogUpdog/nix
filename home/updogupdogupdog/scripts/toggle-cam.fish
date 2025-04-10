#!/usr/bin/env fish

function any_uvc_bound_devices
    set devices (ls /sys/bus/usb/drivers/uvcvideo 2>/dev/null | grep -vE 'bind|unbind')
    test (count $devices) -gt 0
end

function is_uvc_loaded
    lsmod | grep -q '^uvcvideo'
end

set driver_bound 0
set module_loaded 0

# Step 1: Initial state check
if any_uvc_bound_devices
    set driver_bound 1
end

if is_uvc_loaded
    set module_loaded 1
end

echo "Driver bound: $driver_bound, Module loaded: $module_loaded"

# Step 2: If either is active → disable cameras
if test $driver_bound -eq 1 -o $module_loaded -eq 1
    echo "Disabling cameras..."

    # Try unbinding all devices
    for vdev in /sys/class/video4linux/video*
        set device_path (readlink $vdev/device 2> /dev/null)
        if test -z "$device_path"
            continue
        end

        set device_id (basename $device_path)
        set driver_path "/sys/bus/usb/drivers/uvcvideo/$device_id"

        if test -e "$driver_path"
            echo "Attempting to unbind $device_id..."

            set retries 5
            for i in (seq $retries)
                echo $device_id | sudo tee /sys/bus/usb/drivers/uvcvideo/unbind > /dev/null
                sleep 2
                if not test -e "$driver_path"
                    echo "Unbound $device_id."
                    break
                else
                    echo "Unbind failed (attempt $i), retrying in 5s..."
                    sleep 5
                end
            end
        end
    end

    if any_uvc_bound_devices
        echo "Undbind Failed. Devices still bound. Unable to disable camera module."
        kdialog --title "Webcam Toggle" --passivepopup "Undbind Failed. Devices still bound. Unable to disable camera module."
    else
        echo "All devices unbound. Attempting to unload camera module..."
        sudo modprobe -r uvcvideo
        sleep 1
        if not is_uvc_loaded
            echo "Module successfully unloaded."
            kdialog --title "Webcam Toggle" --passivepopup "Camera disabled." 3
        else
            echo "Camera module still loaded. Unable to unload camera module. Something's wrong. Maybe try rebooting?"
        end
    end
else
    # Step 3: If nothing's active, enable the camera
    echo "Enabling cameras..."
    sudo modprobe uvcvideo
    sleep 2

    if is_uvc_loaded
        echo "Module loaded."
        kdialog --title "Webcam Toggle" --passivepopup "Camera enabled and ready." 3

