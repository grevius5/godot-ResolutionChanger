# Resolution Changer

A fast and easy way to change the test resolution of your game with only 2 clicks.

**This addon is only tested with Godot 3.1 beta. Godot 3.0.6 is not supported!**

## Description

Resolution Changer is the fastest way to test your game with different resolutions.
Simply to click the menu button and pick one resolution.
There are almost all common resolutions available, but you can also add your own
resolutions with the **Add custom...** menu.
All resolutions are stored in categories and are reorganizable.

## Getting Started

### Installation

Copy the `addons/resolutionChanger` folder in your project's `addons` folder
(create it if it doesn't exist). Once you've done this, open your project in Godot,
go to the **Project Settings**, click the **Plugins** tab and enable **Resolution Changer**.

### How to use

Click on the **Resolutions** menu button and pick one of the available resolutions.

![UI_Menu](screenshot/UI_Menu.png?raw=true "UI Menu")

If you need a custom resolution, click on the **Resolutions** menu button
and pick the last item **Add custom...**. A popup will appear:

![UI_CustomPopup](screenshot/UI_CustomPopup.png?raw=true "UI Custom Popup")

Define the device's type, name, screen width and height then click **Save**.
The newly-added resolution will be listed with the other ones.

### Documentation

All resolutions are stored in the `Resolutions.txt` file which is located
in the addon folder. If you want to delete some resolutions, you have to do it
manually by removing the corresponding record from `Resolutions.txt`.
