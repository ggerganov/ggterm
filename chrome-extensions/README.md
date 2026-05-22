# Loading Local Browser Extensions (Unpacked)

This guide explains how to load a custom, unpacked browser extension from a local folder for development or personal use.

## Chrome / Edge / Brave

1.  Open a new tab and navigate to the extensions management page:
    *   **Chrome:** `chrome://extensions`
    *   **Edge:** `edge://extensions`
2.  Enable **Developer mode** (toggle switch in the top-right corner).
3.  Click the **Load unpacked** button.
4.  Select the folder containing your extension files (e.g., `manifest.json`).

## Firefox

1.  Open a new tab and navigate to: `about:debugging#/runtime/this-firefox`
2.  Click **This Firefox** (if not already selected).
3.  Click **Load Temporary Add-on**.
4.  Select the `manifest.json` file from your extension folder.

> **Note:** Firefox "Temporary Add-ons" will unload when you close the browser. You must reload them manually after a restart.

