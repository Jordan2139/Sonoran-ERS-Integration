# SonoranCAD Knight Emergency Response Simulator Integration

This repository provides an integration between SonoranCAD and the Knight Emergency Response Simulator. With this integration, you can:

- **Automatically Create 911 Calls:** New offered callouts automatically trigger a 911 call.
- **Automatically Create Law Enforcement Calls:** Law enforcement calls are generated based on callout data.
- **Automatically Add Units to CAD Calls:** When units accept a callout, they are automatically added to the corresponding CAD call.

---

## Features

- **911 Call Automation:** Seamlessly generate 911 calls for new incidents.
- **Law Enforcement Integration:** Instantly create law enforcement calls without manual input.
- **Unit Dispatch Automation:** Automatically update CAD calls when units accept callouts.
- **Streamlined Workflow:** Integrates smoothly with your existing SonoranCAD and Knight Emergency Response Simulator setups.

---

## Installation

Follow these steps to install the integration components:

1. **Submodules:**
   - Locate the folder named **Drag Files To Submodules**.
   - Drag this folder into the `\sonorancad\submodules` directory.

2. **Configuration:**
   - Find the config file in the folder labeled **Drag to Configuration Folder**.
   - Move this file into the `\sonorancad\configuration` directory.

3. **Client Files:**
   - Access the folder titled **Drag Files To Client Folder**.
   - Drag these files into the `\knight_ers\client` directory.

---

## Setup & Configuration

1. **Update the Configuration File:**
   Open the configuration file located in `\sonorancad\configuration` and customize any settings necessary for your environment (such as API keys, endpoints, or other parameters).

2. **Verify Folder Placement:**
   Ensure that all files have been placed in the correct directories as outlined in the Installation section.

3. **Restart Resources:**
   After installation and configuration, restart both SonoranCAD and the Knight Emergency Response Simulator to ensure that the integration is correctly loaded.

---

## Usage

Once installed and configured, the integration will work in the background to:

- **Monitor New Callouts:** Automatically detect new offered callouts.
- **Generate 911 Calls:** Create a 911 call for each new callout instance.
- **Create Law Enforcement Calls:** Initiate law enforcement responses based on callout data.
- **Dispatch Units:** Automatically add units to the CAD call as they accept the callout.

Check your logs to confirm that dispatches and unit assignments are processed correctly.

---

## Troubleshooting

- **No 911 Call Generated:**
  - Verify that the configuration file is set up correctly.
  - Confirm that callout data is being received properly.

- **Units Not Being Added:**
  - Check the integration logs for errors.
  - Ensure that the client files in `\knight_ers\client` are correctly placed and not corrupted.