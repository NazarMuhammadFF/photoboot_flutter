# Implementation Plan - Photo Booth V2

## Development Workflow Setup ✅

- [x] Create development workflow documentation (`Doc/development_workflow.md`)
- [x] Set up Git branching strategy (master ← dev ← feature branches)
- [x] Create initial feature branch (`feature/network-websocket-setup`)
- [x] **Create dev branch and merge feature branch**
- [x] Upload project to GitHub repository
- [x] Configure remote tracking for all branches

## Phase 1: Project Setup & Architecture

- [x] Initialize Flutter Project (Windows, Android, iOS, Web)
- [x] Install Core Dependencies (camera, printing, googleapis, provider, etc.)
- [x] Create Folder Structure (features, services, core, etc.)
- [x] Basic Navigation Setup
- [x] **Multi-Platform Architecture (Android User + Windows Operator)**
  - [x] Create separate build configurations (Platform checks)
  - [x] Android: User interface build (Kiosk Mode settings)
  - [x] Windows: Operator interface build
  - [ ] Network communication setup (WebSocket/HTTP)
  - [ ] Device discovery service
  - [x] Remove `desktop_multi_window` (not needed for cross-platform setup)

## Phase 2: Core Services Implementation

- [x] **Camera Service**
  - [x] Initialize camera
  - [x] Handle preview stream
  - [x] Capture image
  - [x] Switch cameras
  - [ ] **Screen Flash**: Implement white screen flash logic on capture
- [x] **Printer Service (Advanced)**
  - [x] Configure printer (Basic listing)
  - [x] Generate PDF for printing (Basic layout)
  - [x] Send to printer
  - [ ] **Canvas Logic**: Implement 300 DPI scaling
  - [ ] **Paper Adaptation**:
    - [ ] "Double Up" logic for Strip (2x6) on 4R paper
    - [ ] "N-Up" Tiling logic for A4 paper (with crop marks)
- [x] **Storage Service**
  - [x] Local file storage
  - [ ] **Offline Queue**: Mechanism to queue uploads when offline
  - [ ] Google Drive integration (Authentication & Upload)
  - [ ] Generate QR Code for download
- [x] **Grid Configuration Service**
  - [x] Define JSON structure for Grids (x, y, w, h, rotation)
  - [x] Load Grid configurations from assets/local storage
  - [x] Parse Grid JSON to UI Layout
  - [x] Grid Provider for State Management

## Phase 3: Operator Interface (Windows) - **PRIORITY**

- [ ] **Authentication**
  - [ ] Simple Login Screen (PIN/Password)
- [x] **Dashboard**
  - [x] Sidebar Navigation
  - [x] Active session status monitoring (Placeholder)
  - [x] Device Status (Camera, Printer, Network) (Placeholder)
- [ ] **Configuration Panel**
  - [ ] **Grid Editor**: Visual tool to create/edit JSON grids
    - [ ] Add/Remove Slots
    - [ ] Drag & Resize Slots
    - [ ] Save to JSON
  - [ ] **Template Manager**: Upload PNG overlays
  - [ ] **Printer Settings**: Select Paper Size (4R/A4), Toggle Cut Mode
  - [ ] **Storage Settings**: Toggle Local/Cloud, Retry Failed Uploads
- [ ] **Session Management**
  - [ ] View live user progress (which slot they are on)
  - [ ] Force end session / Reset User App
- [ ] **Approval Queue**
  - [ ] Preview generated PDF before printing
  - [ ] Approve/Reject print buttons

## Phase 4: User Interface (Android)

- [x] **Home / Attract Screen**
  - [x] Start button
  - [ ] Video Loop / Slideshow background
  - [ ] Blinking "Touch to Start"
- [x] **Grid Selection Screen**
  - [x] Grid View layout (2x2)
  - [x] Render thumbnails based on available JSON grids
  - [x] Selection logic
- [ ] **Template Selection Screen**
  - [ ] Horizontal Carousel
  - [ ] Filter templates based on selected Grid
- [x] **Photo Capture Screen**
  - [x] Live camera preview (Mirroring ON)
  - [ ] **Overlay**: Show template frame over camera
  - [ ] **Countdown Timer**: Big animated 3..2..1
  - [x] Photo taking sequence (Loop for N slots)
  - [ ] Retake functionality
  - [ ] **Timeout**: Auto-reset if inactive for 60s
- [ ] **Preview & Edit Screen**
  - [ ] Split screen: Result Preview vs Sticker Panel
  - [ ] Drag & Drop Stickers
- [ ] **Result Screen**
  - [ ] Print option (Send request to Operator)
  - [ ] QR Code display (from Cloud/Local URL)

## Phase 5: Integration & State Management

- [ ] **State Management (Provider)**
  - [ ] Global App State
  - [ ] Session State (Current Grid, Photos taken, Template used)
  - [ ] Device State (Camera/Printer/Network)
- [ ] **Network Communication (Android ↔ Windows)**
  - [ ] WebSocket server on Windows (Operator)
  - [ ] WebSocket client on Android (User)
  - [ ] **Protocol**:
    - [ ] `SESSION_START`
    - [ ] `PHOTO_TAKEN` (send thumbnail)
    - [ ] `PRINT_REQUEST`
    - [ ] `PRINT_APPROVED` / `PRINT_REJECTED`
    - [ ] `FORCE_RESET`
  - [ ] Handle connection loss & reconnection

## Phase 6: Testing & Deployment

- [ ] Unit Testing (Services, JSON Parsing)
- [ ] Integration Testing (User Flow -> Operator Approval -> Print)
- [ ] **Performance Testing**:
  - [ ] High-res image processing (300 DPI)
  - [ ] Network latency handling
- [ ] Build for Windows (EXE)
- [ ] Build for Android (APK)
- [ ] Documentation (User Manual)
