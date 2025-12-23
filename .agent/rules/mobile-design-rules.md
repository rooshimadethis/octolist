# Mobile Design Rules (Flutter)

When designing for the OctoList Flutter app, adapt the `frontend-design` principles specifically for mobile user experience:

### 1. Spatial & Gesture-Driven Layouts
- **Bottom-Heavy Navigation**: Use `NavigationBar` or custom bottom docks for primary actions. Reachability is key.
- **Gesture Feedback**: Ensure every interaction has haptic feedback (`HapticFeedback`) and smooth `Hero` transitions between screens.
- **Cards & Depth**: Use `Material 3` elevation or soft `BoxShadows` to create a sense of tactile layers. Overlap elements to create depth.

### 2. Mobile Typography & Color
- **High Density, Clear Hierarchy**: Mobile screens are small; use font weights and subtle color shifts (rather than just size) to create hierarchy.
- **Dark Mode First**: Focus on deep charcoal/navy backgrounds with vibrant neon or pastel accents for a premium "OLED-ready" look.
- **Custom Fonts**: Use the fonts recommended in `SKILL.md` but ensure they are optimized for small mobile displays (hint: use slightly more letter-spacing for headlines).

### 3. Motion & Micro-interactions
- **Implicit Animations**: Use `AnimatedContainer`, `AnimatedOpacity`, and `AnimatedCrossFade` for state changes.
- **Skeuomorphic Micro-details**: Subtle glassmorphism (`BackdropFilter`) or noise textures in the background to avoid flat, boring surfaces.

### 4. Implementation Protocol
- **Always Generate Mockups First**: Use `generate_image` to "hallucinate" the ideal premium UI before writing Dart code.
- **Atomic Widgets**: Build small, reusable, themed widgets that follow these rules.
