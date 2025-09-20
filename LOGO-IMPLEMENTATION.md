# TulioCP Logo Implementation Guide

## 🎨 Logo Files Created

This implementation includes three new TulioCP logo files designed to replace the original Hestia logos:

### 1. Main Logo (`/web/images/logo-tulio.svg`)
- **Usage**: Login pages, primary brand representation
- **Size**: 120x120px (scalable SVG)
- **Design**: Circular background with gradient, prominent "T" letterform in white
- **Colors**: 
  - Primary: #1E40AF (Deep Blue)
  - Secondary: #3B82F6 (Bright Blue)
  - Accent: #10B981 (Emerald Green)
  - Text: #ffffff (White)

### 2. Header Logo (`/web/images/logo-tulio-header.svg`)
- **Usage**: Top navigation bar, horizontal layouts
- **Size**: 200x40px (scalable SVG)  
- **Design**: Horizontal layout with "T" symbol + "TulioCP" text + "Control Panel" tagline
- **Optimized for**: Light backgrounds, compact spaces

### 3. Favicon (`/web/images/favicon-tulio.svg`)
- **Usage**: Browser tabs, bookmarks, mobile icons
- **Size**: 32x32px (scalable SVG)
- **Design**: Simplified "T" on gradient background, optimized for small sizes

## 📂 Files Updated

### Web Interface
- `/web/templates/includes/panel.php` - Updated header logo reference
- `/web/templates/includes/css.php` - Updated favicon reference
- `/web/templates/pages/login/*.php` - Updated all login page logo references

### Documentation
- `/docs/.vitepress/config.js` - Updated VitePress configuration
- `/docs/public/` - Added logo files for documentation site

### White Label System
- `/bin/v-update-white-label-logo` - Updated to handle new logo filenames and paths

## 🔧 Technical Implementation

### Logo References Updated:
```php
// Before (Hestia)
<img src="/images/logo-tulio.svg" alt="..." width="100" height="120">
<img src="/images/logo-tulio-header.svg" alt="..." width="54" height="29">

// After (TulioCP)  
<img src="/images/logo-tulio.svg" alt="..." width="100" height="100">
<img src="/images/logo-tulio-header.svg" alt="..." width="120" height="24">
```

### CSS/HTML Icon References:
```html
<!-- Before -->
<link rel="icon" href="/images/logo-tulio.svg" type="image/svg+xml">

<!-- After -->
<link rel="icon" href="/images/logo-tulio.svg" type="image/svg+xml">
```

## 🎯 Design Specifications

### Color Palette
```css
:root {
  --tulio-primary: #1E40AF;    /* Deep Blue */
  --tulio-secondary: #3B82F6;  /* Bright Blue */
  --tulio-accent: #10B981;     /* Emerald Green */
  --tulio-dark: #1F2937;       /* Dark Gray */
  --tulio-white: #ffffff;      /* White */
}
```

### Logo Variations
- **Main Logo**: Full circular design with gradient background
- **Header Logo**: Horizontal layout for navigation bars
- **Favicon**: Ultra-simplified for small sizes
- **Monochrome**: Can be adapted for single-color applications

## 📱 Responsive Considerations

### Size Guidelines:
- **Desktop Header**: 120x24px (logo-tulio-header.svg)
- **Mobile Header**: Auto-scale to fit container
- **Login Pages**: 100x100px (logo-tulio.svg)
- **Favicon**: 16x16, 32x32, 48x48px (favicon-tulio.svg)
- **Documentation**: Flexible sizing based on context

## 🔄 Migration Notes

### Old vs New File Mapping:
```
logo-tulio.svg           → logo-tulio.svg
logo-tulio-header.svg    → logo-tulio-header.svg
favicon.png        → favicon-tulio.svg (improved SVG format)
```

### Backward Compatibility:
The old logo files remain in place to ensure no broken references during transition. The new logos are implemented alongside existing ones.

## 🎨 Customization

### For Custom Branding:
1. Replace logo files in `/web/images/custom/` directory
2. Use same naming convention: `logo-tulio.svg`, `logo-tulio-header.svg`, etc.
3. Run `v-update-white-label-logo` to apply changes
4. Maintain aspect ratios for best results

### CSS Integration:
The new logos work seamlessly with existing TulioCP CSS themes and color schemes. The gradient colors complement the default interface design.

## ✅ Implementation Status

- [x] Main logo created (`logo-tulio.svg`)
- [x] Header logo created (`logo-tulio-header.svg`) 
- [x] Favicon created (`favicon-tulio.svg`)
- [x] Web interface references updated
- [x] Login pages updated  
- [x] Documentation configuration updated
- [x] White label system updated
- [x] Logo files copied to documentation
- [ ] Generate PNG/ICO versions for broader compatibility
- [ ] Test across different browsers and devices
- [ ] Update mobile app icons (if applicable)

## 🔨 Next Steps

1. **Generate Raster Versions**: Convert SVGs to PNG/ICO for legacy browser support
2. **Mobile Icons**: Create Apple Touch icons and Android app icons
3. **Brand Guidelines**: Document logo usage, spacing, and color guidelines
4. **Testing**: Verify logo appearance across all supported browsers
5. **Optimization**: Minimize SVG file sizes for faster loading

## 📄 License

The TulioCP logos are created specifically for the TulioCP project and follow the same GPLv3 license as the main software.