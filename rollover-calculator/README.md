# Rollover Calculator

Bond Withdrawal Goal Calculator — Chrome Extension

## Description

Rollover Calculator is a Chrome extension that allows you to quickly and visually calculate a bonus's withdrawal goal using the formula:

```
WITHDRAWAL GOAL = (DEPOSIT + BONUS %) × ROLLOVER
```

The interface is modern, responsive, and user-friendly, inspired by shadcn UI.

## Features

- Intuitive and responsive interface
- Elegant dark mode
- Clear and validated inputs
- Real-time calculation
- Ideal for extension popups (320px wide)

## Installation and Use

### 1. Clone the repository

```bash
git clone https://github.com/CodingLeonardo/code-for-my-job.git
cd code-for-my-job/calculator-rollover
```

### 2. Install dependencies

```bash
pnpm install
```

### 3. Build the project

```bash
pnpm run build
```

### 4. Test as a Chrome extension

1. Open Chrome and have `chrome://extensions/`
2. Enable "Developer Mode"
3. Click "Upload Unzipped" and Select the `build/` folder.
4. Add the extension and click the icon to open the pop-up window.

```tap
pnpm run build
```

### 4. Test as a Chrome extension

1. Open Chrome and have `chrome://extensions/`
2. Enable "Developer Mode"
3. Click "Upload Unzipped" and Select the `build/` folder.
4. Add the extension and click the icon to open the pop-up window.

## Project Structure

- `src/` — React/TypeScript source code
- `public/` — Static resources
- `build/` — Generated files for the extension
- `manifest.json` — Chrome extension manifest

## Customization

You can modify the styles and logic in `src/App.tsx` and `src/App.css` to suit your needs.

## License

MIT

---

Developed by [CodingLeonardo](https://github.com/CodingLeonardo)
