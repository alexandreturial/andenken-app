---
name: Andenken
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1b1b1b'
  surface-container: '#1f1f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353535'
  on-surface: '#e2e2e2'
  on-surface-variant: '#ebbbb4'
  inverse-surface: '#e2e2e2'
  inverse-on-surface: '#303030'
  outline: '#b18780'
  outline-variant: '#603e39'
  surface-tint: '#ffb4a8'
  primary: '#ffb4a8'
  on-primary: '#690100'
  primary-container: '#ff5540'
  on-primary-container: '#5c0000'
  inverse-primary: '#c00100'
  secondary: '#ffecc0'
  on-secondary: '#3d2f00'
  secondary-container: '#fecb00'
  on-secondary-container: '#6e5700'
  tertiary: '#c8c6c5'
  on-tertiary: '#313030'
  tertiary-container: '#929090'
  on-tertiary-container: '#2a2a2a'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdad4'
  primary-fixed-dim: '#ffb4a8'
  on-primary-fixed: '#410000'
  on-primary-fixed-variant: '#930100'
  secondary-fixed: '#ffe08b'
  secondary-fixed-dim: '#f1c100'
  on-secondary-fixed: '#241a00'
  on-secondary-fixed-variant: '#584400'
  tertiary-fixed: '#e5e2e1'
  tertiary-fixed-dim: '#c8c6c5'
  on-tertiary-fixed: '#1c1b1b'
  on-tertiary-fixed-variant: '#474746'
  background: '#131313'
  on-background: '#e2e2e2'
  surface-variant: '#353535'
typography:
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-margin: 24px
  gutter: 16px
  card-padding: 32px
  stack-sm: 12px
  stack-md: 24px
  stack-lg: 48px
---

## Brand & Style

The brand personality for this design system is rooted in precision, discipline, and cognitive clarity. It is designed for learners who value efficiency and high-performance study environments. The aesthetic approach is **Corporate Modern** with a lean towards **High-Contrast Minimalism**, utilizing a deep black canvas to eliminate peripheral distractions.

The user experience should feel authoritative yet rewarding. By leveraging a dark-mode-first architecture, the interface reduces eye strain during long-form memorization sessions. The visual language avoids decorative flourishes in favor of structured information density and clear functional hierarchy.

## Colors

The palette is a high-contrast interpretation of the national colors, optimized for a premium digital interface. 

- **Base Background:** A pure Obsidian Black (#000000) serves as the foundation to maximize OLED efficiency and focus.
- **Primary Accent:** Vibrant Red (#FF0000) is reserved for high-priority actions, critical UI states, and "Hard" or "Forget" interaction triggers.
- **Secondary Accent:** Rich Gold (#FFCC00) signifies mastery, achievement, and "Easy" or "Known" interaction triggers.
- **Surface Layers:** Deep charcoal shades are used to create depth between the background and interactive elements, ensuring that the interface does not feel flat while maintaining its dark-themed integrity.

## Typography

Typography in this design system is engineered for maximum legibility. **Hanken Grotesk** provides a sharp, contemporary look for headlines, offering a sense of professional structure. **Inter** is utilized for body copy and flashcard content due to its exceptional readability at various scales and its neutral, systematic tone.

For study sessions, body text should maintain a generous line height to prevent visual crowding. Headlines use a slight negative letter spacing to feel more compact and impactful, while labels use expanded tracking and uppercase styling to denote metadata and secondary information.

## Layout & Spacing

This design system employs a **Fluid Grid** model with strict adherence to an 8px spacing rhythm. The layout adapts dynamically to different screen sizes while maintaining generous horizontal margins to keep content centered and scannable.

- **Mobile:** 4-column grid with 24px side margins. Content is primarily stacked vertically to facilitate one-handed navigation during study sessions.
- **Desktop/Tablet:** 12-column grid. The study interface (flashcards) is constrained to a maximum width of 720px to prevent excessive eye movement and maintain focus.
- **Rhythm:** Consistent vertical "stacks" ensure that related elements—like a question and its prompt—are grouped tightly, while distinct sections are separated by larger gaps to signal a change in context.

## Elevation & Depth

Elevation in this design system is achieved through **Tonal Layering** and **Low-Contrast Outlines** rather than heavy shadows. In a true black environment, shadows are often invisible or muddy; therefore, depth is communicated by shifting background colors from #000000 (Level 0) to #1A1A1A (Level 1) and #262626 (Level 2).

Key interactive surfaces, such as active flashcards, utilize a subtle 1px border in a dark gray or a muted version of the accent colors to define their boundaries. High-priority modals may use a soft ambient glow (tinted with the Gold or Red accents) to appear as if they are floating above the base layer.

## Shapes

The shape language for this design system is defined as **Rounded**, striking a balance between clinical precision and modern approachability. 

- **Primary Components:** Standard buttons and input fields utilize a 0.5rem (8px) corner radius.
- **Cards:** Flashcards and container surfaces use 1rem (16px) for a more pronounced, distinct appearance.
- **Interactive Elements:** Small elements like chips or badges may utilize a pill-shape (fully rounded) to contrast against the more structured rectangular forms of the primary UI.

## Components

### Buttons
Buttons are bold and high-contrast. The primary action button (e.g., "Show Answer") uses a solid Gold fill with Black text. Secondary actions use the Red accent for destructive or "hard" choices, and outlined styles for utility actions.

### Flashcards
The centerpiece of the app. Cards feature a #1A1A1A surface with 1px subtle borders. Typography within the card is scaled up (Body-LG) for effortless reading. Transitions between the front and back of the card should be instantaneous or use a minimal horizontal slide to maintain momentum.

### Progress Bars
Progress is tracked using the Gold accent for "Mastery" and a neutral gray for the "Remaining" track. When a user is in a "Review" state or has missed a streak, the bar may pulse with a muted Red.

### Chips & Tags
Used for deck categories and difficulty levels. These are small, low-profile elements with dark backgrounds and colored text (Gold/Red) to categorize information without cluttering the card face.

### Input Fields
Minimalist design with a 1px border. The border shifts to Gold on focus to provide a clear "Active" state. Error states are signaled by a 1px Red border and a small supporting label below the field.