# 🚗 Toll Booth Controller – ASIC Design (RTL to GDSII)
A complete ASIC implementation of a Mealy FSM-based **Digital Toll Booth Controller**, designed and synthesized using RTL Verilog, with full flow from RTL to GDSII. Developed as VLSI Design & Automation project.


## 🔧 Tools Used
- **nclaunch** – Project management and flow setup  
- **Genus** – Logic synthesis  
- **Innovus** – Physical design (PnR: Placement and Routing)  
- **Tempus** – Static Timing Analysis (STA) and RC Extraction  


## ⚙️ Key Functionalities & Features
- **Mealy FSM-based** Toll Booth Controller
  
1. **Vehicle Detection**  
    Detects vehicles via sensor input and classifies them as car/truck/bus (`vehicle_class` 2'd0–2'd2).
2. **RFID Payment Handling (Primary Flow)**  
    - Reads RFID presence, validates tag, and checks balance  
    - Automatically deducts toll fee based on vehicle class  
    - Opens gate and logs vehicle + revenue on success  
3. **Manual Payment Fallback**  
    - If RFID absent, invalid, or insufficient balance → prompts manual payment  
    - Accepts coin or card payments  
    - Opens gate and logs data on successful payment  
4. **Gate Automation & Evasion Logging**  
    - Controls gate opening/closing signals  
    - Detects and logs evasion when vehicle passes without successful payment  
5. **Counters & Revenue Tracking**  
    - Per-class counters: `vehiclecount0/1/2`  
    - Per-class revenue accumulation: `totalrevenue0/1/2`  
    - Daily evasion counter: `evasioncount`  
6. **Toll Rate Updates**  
    - Supports real-time rate changes via `updaterate` input per vehicle class  
7. **Maintenance Mode**  
    - Disables toll operations to allow safe maintenance  
    - Supports gate testing, toll rate configuration, and daily counter reset via `reset_counters`  

## 📐 ASIC Flow Highlights
- RTL coded in **Verilog** with **Mealy FSM architecture**
- Simulated using **nclaunch** testbenches and waveform outputs
- Synthesized via **Genus**, generating netlists and area reports
- Full PnR (Placement and Routing) with floorplanning, powerplanning, placement, clock tree synthesis, & routing using **Innovus**
- RC extraction and STA performed in **Tempus**
- Timing violation fixes applied to resolve negative slack and ensure timing closure

## 🗂 Folder
├── README.md
├── Verilog codes
