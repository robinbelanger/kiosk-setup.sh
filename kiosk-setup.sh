#!/bin/bash

# Update system and install required packages
sudo apt update && sudo apt upgrade -y
sudo apt install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox chromium-browser unclutter -y

# Create kiosk script
cat <<EOL > /home/pi/kiosk.sh
#!/bin/bash
xset -dpms       # Disable Energy Star features
xset s off       # Disable screensaver
xset s noblank   # Disable screen blanking

# Hide the mouse cursor after 0.5 seconds of inactivity
unclutter -idle 0.5 &

# Launch Chromium in kiosk mode with the desired URL
chromium-browser --noerrdialogs --kiosk --disable-restore-session-state --disable-infobars --start-maximized "your-url-here"
EOL

# Make kiosk script executable
chmod +x /home/pi/kiosk.sh

# Configure Openbox to run kiosk script at startup
mkdir -p /home/pi/.config/openbox
echo "/home/pi/kiosk.sh &" >> /home/pi/.config/openbox/autostart

# Enable auto-login for the pi user
sudo raspi-config nonint do_boot_behaviour B4

# Set up .bash_profile to start the X server automatically on login
cat <<EOL >> /home/pi/.bash_profile
if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
  startx
fi
EOL

# Reboot the system to apply all changes
sudo reboot
