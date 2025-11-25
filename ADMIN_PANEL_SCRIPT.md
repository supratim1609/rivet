# 🎥 Admin Panel Demo Script

**Goal:** Create a 10-second high-energy GIF showing off the Admin Panel.
**Tool:** Use QuickTime (Mac) or OBS to record. Use a tool like GIF Brewery or EzGif to convert to GIF.

## 🎬 The Shot List

### Scene 1: The "Zero Config" Start (0:00 - 0:03)
*   **Action:** In your terminal, run `./benchmark/rivet_cluster`.
*   **Visual:** Text scrolls rapidly, then "RIVET 🚀 running on http://0.0.0.0:3000" appears in green.
*   **Overlay Text:** "Instant Startup ⚡"

### Scene 2: The Dashboard Reveal (0:03 - 0:06)
*   **Action:** Switch to Browser -> `http://localhost:3000/admin`.
*   **Visual:** The dashboard loads instantly. Show the "Requests/Sec" graph spiking (run `ab` in background to make it move!).
*   **Overlay Text:** "Real-Time Metrics 📊"

### Scene 3: Route Inspector (0:06 - 0:10)
*   **Action:** Click "Routes" tab. Scroll down the list of API endpoints.
*   **Visual:** Show the clean list of `GET /hello`, `POST /upload`, `GET /user/:id`.
*   **Overlay Text:** "Auto-Generated Docs 📝"

## 💡 Pro Tips
1.  **Zoom In:** Make your browser 125% or 150% zoom so text is readable on mobile.
2.  **Dark Mode:** Ensure your OS/Browser is in Dark Mode. It looks more premium.
3.  **Fake Traffic:** Run `./benchmark/demo.sh` in a separate window while recording to make the graphs dance!
