# GGGlide

GGGlide is an ergonomic and productivity feature for touchpad users.

The GGGlide function is reminiscent of the behavior of the Synaptics touchpad setting 'Momentum' (or the more familiar two-finger inertial scrolling but for pointing) and available to any touchpad/trackpad.

"One quick flick of the finger on the TouchPad surface can move the cursor across the entire computer screen. Momentum reduces the repetitive motion and fatigue associated with moving the cursor long distances."

Depending on the forcefulness and direction of the finger flick the cursor glides on the screen an equivalent distance.
After a flick of the finger, your movements inertia is "transferred" to the pointer which continues its trajectory with the same speed and direction of your finger, effectively gliding through your desktop. The gliding pointers' physics include friction and hence it will slow down over time eventually stopping. After some tries it is easy to estimate intuitively where the pointer will stop, vastly improving touchpad ergonomics by drastically reducing the total distance of finger/hand travel required. It also works very well with multiple monitor setups.

After a short 'flick' of the finger on the touchpad surface the pointer starts gliding. While gliding:

- If the user interacts with the position of the pointer (e.g. moves the pointer/mouse) the glide is interrupted.
- If the user presses down the left click the glide is interrupted (e.g. use tap-to-click to click/stop the gliding pointer at specific point).
- If the user releases the left click the glide is interrupted (e.g. hold down left click, initiate glide, release left click to stop).
- The user can perform another pointer glide (e.g. while gliding vertically, flick horizontally for horizontal glide).
- Any mouse input received will interrupt the current glide (scrolling, right click, etc).
- The pointer will decelerate until it stops if none of the above occurs.

I have a Logitech T650 touchpad and this has been a feature I had been sorely missing.

## Instructions

The script below will prompt you for the speed of the pointer above which a glide will be performed. Then, it will create and run GGGlide. You can run the GGGsetup as many times required or every time you want to change the glide parameters. You will need to experiment with different values due to hardware variability. The setup dialog will have as default speed your current GGGlide value for easier tweaking.
Optionally, GGGlide can change the OS pointer settings of Windows to the recommended defaults at every script launch.
Do not use the GGGlide script created on one PC on other machines. It will not work as expected. Note the glide parameters and then rerun the GGGSetup on the new machine (or copy the ggglide.ini file).

## GGGlide Notes:

Any mouse settings changes can be reverted painlessly by doing the following: 'Start>Mouse>Pointer Options' you will see a "Motion" box. There you can revert to any settings. If you untick "enhanced pointer precision" and move the speed slider exactly at the middle (6th line) you will replicate the GGGlide settings.
Use SSStumble if you are switching between mouse and touchpad to disable the gliding while mousing.

## FAQ

- How can I change GGGlide glide parameters?
Anytime you want to change GGGlide glide parameters you have to run GGGsetup and modify them via its GUI.

- Why is a new GGGlide file created every time I run GGGsetup?
Using numerical values instead of variables make GGGlide run faster. So GGGsetup has a template, fills in any numerical parameters required and outputs the newly created GGGlide file. This happens every time you make changes via GGGsetup.

- Why shouldn’t I copy a GGGlide script from one PC to another?
One of the baked-in GGGlide numerical parameters relates to the tick length of the time keeping counter and is CPU dependent. So a GGGlide script created in one machine is not portable to another.
If you want to replicate a GGGlide config you should copy the “.ini” file and GGGsetup to the new PC and run GGGsetup again. This will reproduce the same GGGlide experience (or you could note the GGGsetup parameters and enter them manually via the GUI).

- Why modify the OS pointer settings?
When you alter the Windows pointer settings, the OS takes the pointing device input and scales it accordingly. Say the device reports displacement X and given your pointers Windows “sensitivity”, for example, it scales that to 0.5*X or 1.5*X (other settings affect things like pointer acceleration). Using the default settings suggested by GGGlide the OS does not interfere with the pointing device output, it is 1 to 1.
This way you eliminate some variables from the physics equation.
Also, usually these settings are used to increase the reach of the pointer (by increasing pointer sensitivity) but at the cost of fiddly short distance navigation. With GGGlide you are covered for long/medium pointer displacements and you might as well enjoy an increased short distance resolution and range of hand motion.
All that being said GGGlide works fine with any OS settings.

# SSStumble

(GGGlide Companion)

For those who often switch between mouse and touchpad use and prefer disabling GGGlide while "mousing" there is SSStumble! SSStumble is an additional script. When using the mouse GGGlide will be disabled by SSStumble.

## Instructions

Download and run on the same directory with your trusty GGGlide. Upon launch you can select pointing devices where GGGlide gliding will be disabled by SSStumble. You can launch SSStumble and wait for the message box to expire and GGGlide will be launched soon after. All settings are preserved in the GGGlide ".ini" file.

## SSStumble Notes:
- SSStumble disables GGGlide only once the current glide has been completed/interrupted (assuming the pointer is currently gliding when switching to the disabled mouse/device). This is evident only when triggering a pause to GGGlide via a hotkey.
- SSStumble only works with the new version of GGGlide v1.97.1 and above. Any older version will not work.
- SSStumble must be running in the background in order to monitor the device which you are using.
- It can distinguish between identical pointing devices operating simultaneously (e.g. two mice or two trackpads which are of the same make).
- Saved devices need to be added again if they are plugged in a different USB port.
