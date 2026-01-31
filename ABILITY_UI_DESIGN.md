# Ability UI Documentation

## Overview
The game now features a visual ability interface displayed at the bottom of the screen, showing all five abilities as colored circles.

## UI Layout

### Position
- The ability UI is located at the bottom of the screen (Y position: 1820px out of 1920px viewport height)
- Five circles are evenly spaced horizontally across the screen
- Each circle has a radius of 40 pixels with 120 pixels spacing between centers

### Visual Design

#### Circle Colors
Each ability is represented by its corresponding color:
1. **Ability 1** - Violet (RGB: 0.58, 0.0, 0.83)
2. **Ability 2** - Yellow (RGB: 1.0, 1.0, 0.0)
3. **Ability 3** - Red (RGB: 1.0, 0.0, 0.0)
4. **Ability 4** - Green (RGB: 0.0, 1.0, 0.0)
5. **Ability 5** - Blue (RGB: 0.0, 0.0, 1.0)

## Visual States

### Normal State (Unselected, Not Winning)
- Circles are displayed with darkened colors (40-60% darker)
- Smaller appearance to indicate they are not active
- Used for abilities that are neither selected nor effective against the current enemy

### Selected State (Current Ability)
- Circle is highlighted with a bright white outer ring
- Larger appearance (radius + 8 pixels)
- Shows a lightened version of the ability color
- Clearly indicates which ability is currently active
- Players can switch abilities by pressing keys 1-5

### Winning State (Effective Against Current Enemy)
- Circle displays a pulsing glow effect
- Pulsing is achieved using a sine wave animation
- White arc/outline (6 pixels beyond the circle) to draw attention
- Lightened color (50% brighter) for the glow effect
- Indicates to the player that this ability will defeat the current enemy

## Gameplay Integration

### Enemy Detection
- The UI checks if there's a current enemy on screen
- When an enemy is present, the UI highlights abilities that will win against it
- Based on the win conditions defined in the ability system:
  - Ability 1 (Violet) wins against Enemies 2 & 4 (Yellow & Green)
  - Ability 2 (Yellow) wins against Enemies 3 & 5 (Red & Blue)
  - Ability 3 (Red) wins against Enemies 4 & 1 (Green & Violet)
  - Ability 4 (Green) wins against Enemies 5 & 2 (Blue & Yellow)
  - Ability 5 (Blue) wins against Enemies 1 & 3 (Violet & Red)

### Real-time Updates
- The UI is redrawn every frame to ensure smooth animations
- Changes are immediately reflected when:
  - Player switches abilities (pressing keys 1-5)
  - A new enemy spawns on screen
  - The current enemy is destroyed

## Technical Implementation

### Files Modified
1. **scripts/ability_ui.gd** (NEW)
   - Custom Node2D script for drawing the ability circles
   - Handles all visual states and animations
   - Integrates with game controller for game state

2. **scenes/main.tscn**
   - Added AbilityUI node to the main game scene
   - Connected to the game controller for state access

### Key Features
- **Automatic parent detection**: Gets game controller reference via get_parent()
- **Dynamic state evaluation**: Checks current ability and enemy type each frame
- **Animated effects**: Uses Time.get_ticks_msec() for smooth pulsing animation
- **Color-coded feedback**: Visual cues help players make strategic decisions

## User Experience

### Visual Feedback Hierarchy
1. **Selected ability** - Most prominent (white ring, larger size, bright colors)
2. **Winning abilities** - Eye-catching (pulsing glow, white arc)
3. **Other abilities** - Dimmed (darker colors, smaller appearance)

### Strategic Gameplay
Players can:
- Quickly identify which ability is currently selected
- See at a glance which abilities will be effective against the current enemy
- Make informed decisions about when to switch abilities
- React to incoming enemies by switching to the appropriate counter-ability

## Visual Example

```
Bottom of screen (Y: 1820):
[O]    [O]    [O]    [O]    [O]
 1      2      3      4      5
Violet Yellow Red   Green  Blue

Legend:
[O] - Normal dimmed circle
(O) - Pulsing circle with glow (wins against current enemy)
{O} - Selected circle with white ring (current ability)
```

### Example Scenarios

**Scenario 1: Ability 1 selected, no enemy**
```
{O}    [O]    [O]    [O]    [O]
Violet Yellow Red   Green  Blue
```

**Scenario 2: Ability 1 selected, Yellow enemy (type 2) on screen**
```
{O}    [O]    [O]    (O)    [O]
Violet Yellow Red   Green  Blue
     (Current)            (Wins)
```
- Ability 1 is selected (white ring)
- Ability 4 (Green) pulses because it wins against enemy 2 (Yellow)

**Scenario 3: Ability 3 selected, Violet enemy (type 1) on screen**
```
[O]    [O]    {O}    [O]    (O)
Violet Yellow Red   Green  Blue
            (Current)        (Wins)
```
- Ability 3 is selected (white ring)
- Ability 5 (Blue) pulses because it wins against enemy 1 (Violet)

## Benefits

1. **Improved Gameplay**: Players can make strategic decisions quickly
2. **Visual Clarity**: Color-coding and animations make the UI intuitive
3. **No Text Required**: Icons and colors communicate effectively
4. **Responsive**: Updates in real-time with game state changes
5. **Accessibility**: High contrast between states ensures visibility
