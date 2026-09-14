---
name: AI LifeOS
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#ccc3d8'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#958da1'
  outline-variant: '#4a4455'
  surface-tint: '#d2bbff'
  primary: '#d2bbff'
  on-primary: '#3f008e'
  primary-container: '#7c3aed'
  on-primary-container: '#ede0ff'
  inverse-primary: '#732ee4'
  secondary: '#89ceff'
  on-secondary: '#00344d'
  secondary-container: '#00a2e6'
  on-secondary-container: '#00344e'
  tertiary: '#ffb784'
  on-tertiary: '#4f2500'
  tertiary-container: '#a15100'
  on-tertiary-container: '#ffe0cd'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#eaddff'
  primary-fixed-dim: '#d2bbff'
  on-primary-fixed: '#25005a'
  on-primary-fixed-variant: '#5a00c6'
  secondary-fixed: '#c9e6ff'
  secondary-fixed-dim: '#89ceff'
  on-secondary-fixed: '#001e2f'
  on-secondary-fixed-variant: '#004c6e'
  tertiary-fixed: '#ffdcc6'
  tertiary-fixed-dim: '#ffb784'
  on-tertiary-fixed: '#301400'
  on-tertiary-fixed-variant: '#713700'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  title-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
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
  unit: 4px
  container-padding-desktop: 32px
  container-padding-mobile: 16px
  gutter: 24px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The design system is centered on the concept of an "Intelligent Canvas"—a professional, high-utility environment that feels both expansive and focused. It targets high-performance individuals who require a sophisticated interface that recedes into the background until AI intervention is necessary.

The aesthetic is **Modern Minimalist with a Polished Tech edge**. It combines the systematic utility of productivity tools like Notion with the sensory refinement of high-end hardware interfaces. The visual language relies on significant white space (or "dark space"), precise typography, and subtle optical effects like background blurs to signify depth and intelligence. The emotional goal is to evoke a sense of calm, control, and cutting-edge capability.

## Colors

The palette is anchored in a "Deep Slate" ecosystem. The primary color, **AI Violet (#7C3AED)**, is reserved for moments of intelligence, active AI states, and primary calls to action. **Electric Blue (#0EA5E9)** serves as a secondary accent for system-level feedback and connectivity.

- **Dark Mode (Default):** Utilizes a foundation of Slate-950 for backgrounds, with Slate-900 for containers to create a "layered ink" effect.
- **Light Mode:** Uses a "Crisp Paper" approach with Slate-50 backgrounds and pure white containers.
- **Functional Colors:** Success, Warning, and Error states follow standard semantic patterns but are slightly desaturated to maintain the professional tone.

## Typography

This design system uses **Inter** exclusively to achieve a systematic, neutral, and highly readable interface. The hierarchy is strictly enforced to manage information-dense layouts.

- **Headlines:** Use a tighter letter-spacing and heavier weights to create a sense of authority.
- **Body:** Standard weight (400) with generous line-height to ensure long-form AI insights remain legible.
- **Labels:** Uppercase is used sparingly for secondary metadata to differentiate from actionable text.

## Layout & Spacing

The system employs a **Fluid Grid** model with fixed safe-zones. 
- **Desktop:** A 12-column grid with 24px gutters. Content is often centered in a "Focus Column" of 1024px for maximum readability.
- **Mobile:** A 4-column grid with 16px margins. 
- **Rhythm:** All spacing is based on a 4px baseline unit. Vertical stacks follow a geometric progression (8, 16, 32, 64) to create clear content groupings.

Internal padding within components should be generous to maintain the "Apple-style" polish, ensuring no element feels cramped.

## Elevation & Depth

Hierarchy is established through **Tonal Layering** and **Glassmorphism**.

1.  **Level 0 (Surface):** The base background color (Slate-950).
2.  **Level 1 (Cards):** Slate-900 with a subtle 1px border (Slate-800) and no shadow.
3.  **Level 2 (Active/Hover):** Slate-800 with a soft, diffused shadow (0px 8px 24px rgba(0,0,0,0.4)).
4.  **Level 3 (Overlays/Modals):** Glassmorphic surfaces with a 20px backdrop blur and 60% opacity fill. These represent AI-driven "interrupts" or temporary contexts.

Shadows are never pure black; they are tinted with the Deep Slate base to ensure they feel like natural ambient occlusion rather than "dirty" glows.

## Shapes

The shape language is defined by **High-Radius Geometry**. While the base setting is `2 (Rounded)`, the design system specifically pushes container corners to **24px** (rounded-xl) for main UI cards and modals to create a friendly, organic feel.

Buttons and input fields use a consistent 12px (rounded-lg) radius to maintain a distinct "interactive" shape language compared to the structural containers.

## Components

- **Buttons:** Primary buttons use a solid AI Violet fill with white text. Secondary buttons are "Ghost" style with a 1px Slate-700 border. Transitions should be subtle (200ms ease).
- **Cards:** Use a 24px corner radius. In dark mode, use a subtle top-down linear gradient (Slate-900 to Slate-950) to give a slight 3D feel.
- **Inputs:** Minimalist bottom-border only in "rest" state, transitioning to a full 1px AI Violet border on focus. Include a soft outer glow on focus.
- **AI Glow:** A unique component—a soft, pulsing violet aura behind specific elements to indicate that the AI is currently processing or suggesting information within that module.
- **Glass Overlays:** Used for command bars (CMD+K style) and navigation sidebars, utilizing high-density backdrop blurs (24px+) to maintain legibility over complex backgrounds.