# FSR 3 Frame Generation for NVIDIA Optimal Setup Guide

Installing the version FSR 3 Frame Generation version of UltraPlus is only
necessary for those with NVIDIA 4000 series GPUs 

1. In the NVIDIA App or the NVIDIA Control Panel set the following for
   Stalker 2:
   - Vertical Sync (VSync) - Use the 3D Application Setting
   - Low Latency - On
   - Max Frame Rate - Off
2. In the game settings: 
   - Display -> V-Sync - Off
   - Display -> NVIDIA Reflex Low Latency - Disabled
   - Graphics -> FSR3 Frame Generation - Enabled

VSync does not correctly work with this setup of FSR3 Frame Generation but
it should handle presentation sync (see _Optional Recommended Configuration_).

## Optional Recommended Configuration

We highly recommend using an external tool for frame pacing and to enable
NVIDIA Reflex. The simplest option is to use RTSS which can be found here:
https://www.guru3d.com/download/rtss-rivatuner-statistics-server-download/.
To configure RTSS:

1. Set your framerate limit to ~3 FPS below your refresh rate (ideally
   framerate limit = refresh rate - 0.5%)
2. Under setup configure the following
   - [x] Enable framerate limiter -> NVIDIA Reflex
   - [x] Inject NVIDIA Reflex latency markers -> after frame presentation


# Notes

The above settings should achieve the smoothest gameplay experience with
higher FPS and improved responsivity over using DLSS Frame Generation. This
is due to the way the engine interacts and integrates with the frame
generation libraries, not necessarily the frame generation quality/performance
itself. 

If you use the Frame Generation Cutscene enabler in UltraPlus, there will
be flicker on dialogue text during cutscenes but everything else should
work as expected.