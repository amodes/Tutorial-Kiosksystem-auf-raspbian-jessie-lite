#!/bin/sh
xset -dpms
xset s off 
xset s noblank
matchbox-window-manager &
matchbox-keyboard --daemon &
while true; do
    kweb -KHJ http://www.google.com &
    wait $!
    sleep 10
done
exit