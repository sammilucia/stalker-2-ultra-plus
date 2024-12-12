If you have a blue screen of death (BSOD) or crash with similar to:

	"error DXGI_ERROR_DEVICE_REMOVED with Reason: DXGI_ERROR_DEVICE_HUNG"

Or if you see in %LocalAppData%\Hogwarts Legacy\Saved\Crashes\<UUID>\CrashContext.runtime-xml has the string:

	"DXGI_ERROR_DEVICE_REMOVED"

The problem is likely the game is causing your PC to not respond to Windows in a timely fashion - especially with the Ultra+ Mod which forces a lot out of the game.

Applying the reg fix to "Disable TDR" should fix this. If you want to re-enable it again later simply use the "Re-enable TDR"


More info
=========

TDR stands for "timeout detection and recovery" and is used during testing and development. I wouldn't expect disabling it will cause any issues.
Technical details from Microsoft here: https://learn.microsoft.com/en-us/windows-hardware/drivers/display/tdr-registry-keys


- SammiLucia