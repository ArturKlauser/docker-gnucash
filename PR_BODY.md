💡 What: Replaced apk installation of curl with Alpine's built-in wget for downloading oauth2-proxy, and batched apt-get purge, remove, and autoremove commands into a single apt-get purge call.
🎯 Why: Reducing the number of times package managers are invoked significantly reduces the severe I/O overhead of parsing dependency trees and acquiring locks multiple times, especially slow in QEMU multi-arch emulation.
📊 Impact: Eliminates unnecessary package index updates and extra dependency graph parses, saving build time and I/O.
🔬 Measurement: Verify the GitHub Actions CI multi-architecture build completes faster without failing, particularly on the arm64 platform.
