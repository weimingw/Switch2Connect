# ARM64 WinUHid on this machine

Use the native ARM64 Visual Studio 2022 MSBuild, MSVC v143 ARM64 tools, and SDK/WDK 26100. Clone https://github.com/cgutman/WinUHid and check out commit `d6cebbef5c7909168d1f881185be8f607d6aefd4`. Run `powershell -File drivers\build_winuhid_arm64.ps1 -SourcePath <WinUHid-checkout>` from the repository root.

The output contains an ARM64 DLL, INF, and newly generated **unsigned** catalog. A valid signing path and matching certificate are required before installation. Place the signed package and `WinUHidDriver.cer` in `drivers\arm64`; do not reuse the x64 catalog. The installer checks the package architecture and catalog signature before cleaning up an existing driver. Driver signing and installation have not yet been validated.

Use x64 Python and the existing x64 WinUHid client libraries. The driver and the Python process do not need to have the same architecture. Compatibility with the built driver must be tested after installation.
