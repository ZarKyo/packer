#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# -e : exit immediately on error
# -u : treat unset variables as errors
# -o pipefail : fail if any command in a pipeline fails
# IFS : safer word splitting
set -euo pipefail
IFS=$'\n\t'

# Set GNOME Shell dock favorite applications
gsettings set org.gnome.shell favorite-apps "[
    'firefox_firefox.desktop',
    'org.gnome.Nautilus.desktop',
    'org.gnome.Terminal.desktop'
]"

# Set clock to 24-hour format
gsettings set org.gnome.desktop.interface clock-format '24h'

# Prefer dark theme (apps that support it)
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Enable Ubuntu AppIndicators (system tray icons)
gnome-extensions enable ubuntu-appindicators@ubuntu.com
# Enable Ubuntu Dock extension
gnome-extensions enable ubuntu-dock@ubuntu.com

# Dash-to-Dock GNOME extension schema
SCHEMA="org.gnome.shell.extensions.dash-to-dock"

# Open existing window instead of launching a new one
gsettings set $SCHEMA activate-single-window true
# Center dock icons
gsettings set $SCHEMA always-center-icons true
# Animate the "Show Applications" overview
gsettings set $SCHEMA animate-show-apps true
# Set animation duration (in seconds)
gsettings set $SCHEMA animation-time 0.2
# Use a custom theme for the dock
gsettings set $SCHEMA apply-custom-theme true
# Enable glossy effect on dock icons
gsettings set $SCHEMA apply-glossy-effect true
# Shrink dock theme to better fit icons
gsettings set $SCHEMA custom-theme-shrink true
# Disable dock auto-hide
gsettings set $SCHEMA autohide false
# Keep dock visible even in fullscreen
gsettings set $SCHEMA autohide-in-fullscreen false
# Maximum icon size in the dock (pixels)
gsettings set $SCHEMA dash-max-icon-size 32
# Fix the dock position (not floating)
gsettings set $SCHEMA dock-fixed true
# Position the dock at the bottom of the screen
gsettings set $SCHEMA dock-position "'BOTTOM'"
# Extend dock to the full screen width
gsettings set $SCHEMA extend-height true
# Allow rounded dock corners
gsettings set $SCHEMA force-straight-corner false
# Show tooltips on hover
gsettings set $SCHEMA hide-tooltip false
# Allow dynamic icon size
gsettings set $SCHEMA icon-size-fixed false
# Enable intelligent auto-hide
gsettings set $SCHEMA intellihide true
# Hide dock only when application windows overlap
gsettings set $SCHEMA intellihide-mode "'FOCUS_APPLICATION_WINDOWS'"
# Separate dock items by filesystem location
gsettings set $SCHEMA isolate-locations true
# Do not isolate per monitor
gsettings set $SCHEMA isolate-monitors false
# Do not isolate per workspace
gsettings set $SCHEMA isolate-workspaces false
# Show dock on all monitors
gsettings set $SCHEMA multi-monitor true
# Keep "Show Applications" button at screen edge
gsettings set $SCHEMA show-apps-always-in-the-edge true
# Place "Show Applications" button at the top
gsettings set $SCHEMA show-apps-at-top true
# Show favorite applications
gsettings set $SCHEMA show-favorites true
# Show notification badges on icons
gsettings set $SCHEMA show-icons-emblems true
# Show mounted drives
gsettings set $SCHEMA show-mounts true
# Hide network mounts
gsettings set $SCHEMA show-mounts-network false
# Show only mounted devices
gsettings set $SCHEMA show-mounts-only-mounted true
# Show running applications
gsettings set $SCHEMA show-running true
# Show the "Show Applications" button
gsettings set $SCHEMA show-show-apps-button true
# Hide trash icon from the dock
gsettings set $SCHEMA show-trash false
