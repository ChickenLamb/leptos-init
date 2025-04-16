#!/bin/bash

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "Error: $1 is not installed"
        exit 1
    fi
}

# Check for required commands
check_command cargo
check_command rustup

# Install required tools
echo "Installing required tools..."
cargo install trunk
cargo install leptosfmt
cargo install cargo-leptos

# Add WebAssembly target
echo "Adding WebAssembly target..."
rustup target add wasm32-unknown-unknown

# Create new project
echo "Creating new Leptos project..."
cargo new leptos-app
cd leptos-app

# Add dependencies
echo "Adding dependencies..."
cargo add leptos --features=csr
cargo add console_error_panic_hook
cargo add web-sys
cargo add wasm-bindgen

# Create index.html with better structure
cat > index.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leptos App</title>
    <link data-trunk rel="css" href="styles.css">
  </head>
  <body></body>
</html>
EOL

# Create styles.css
cat > styles.css << 'EOL'
:root {
    --primary-color: #0066cc;
    --background-color: #ffffff;
    --text-color: #333333;
}

body {
    margin: 0;
    padding: 20px;
    font-family: system-ui, -apple-system, sans-serif;
    background-color: var(--background-color);
    color: var(--text-color);
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

.button {
    background-color: var(--primary-color);
    color: white;
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s;
}

.button:hover {
    background-color: #0052a3;
}

.info {
    margin-top: 20px;
    padding: 10px;
    background-color: #f0f0f0;
    border-radius: 4px;
    font-style: italic;
}

h2 {
    color: var(--primary-color);
    font-size: 1.5em;
    margin: 20px 0 10px;
}

p {
    margin: 8px 0;
    line-height: 1.4;
}
EOL

# Create main.rs with a basic component
cat > src/main.rs << 'EOL'
use leptos::*;
use wasm_bindgen::prelude::*;
use web_sys::{window, Event};

#[component]
fn App() -> impl IntoView {
    let (width, set_width) = create_signal(0);
    let (height, set_height) = create_signal(0);
    let (mouse_x, set_mouse_x) = create_signal(0);
    let (mouse_y, set_mouse_y) = create_signal(0);

    // Get window dimensions
    let window = window().unwrap();
    let update_dimensions = move || {
        let w = window.inner_width().unwrap().as_f64().unwrap() as i32;
        let h = window.inner_height().unwrap().as_f64().unwrap() as i32;
        set_width(w);
        set_height(h);
    };

    // Initial dimensions
    update_dimensions();

    // Handle window resize
    let resize_callback = move |_: Event| update_dimensions();
    window.add_event_listener_with_callback(
        "resize",
        Closure::wrap(Box::new(resize_callback) as Box<dyn FnMut(_)>).into_js_value().as_ref().unchecked_ref(),
    ).unwrap();

    // Handle mouse move
    let mousemove_callback = move |e: web_sys::MouseEvent| {
        set_mouse_x(e.client_x());
        set_mouse_y(e.client_y());
    };
    window.add_event_listener_with_callback(
        "mousemove",
        Closure::wrap(Box::new(mousemove_callback) as Box<dyn FnMut(_)>).into_js_value().as_ref().unchecked_ref(),
    ).unwrap();

    view! {
        <div class="container">
            <h1>"Web-sys and wasm-bindgen Demo"</h1>
            <div>
                <h2>"Window Dimensions:"</h2>
                <p>"Width: " {width} "px"</p>
                <p>"Height: " {height} "px"</p>
            </div>
            <div>
                <h2>"Mouse Position:"</h2>
                <p>"X: " {mouse_x} "px"</p>
                <p>"Y: " {mouse_y} "px"</p>
            </div>
            <p class="info">"Try resizing the window or moving your mouse!"</p>
        </div>
    }
}

fn main() {
    console_error_panic_hook::set_once();
    mount_to_body(App);
}
EOL

# Create .cargo/config.toml for wasm flags
mkdir -p .cargo
cat > .cargo/config.toml << 'EOL'
[target.wasm32-unknown-unknown.dev]
rustflags = [
   "--cfg",
   "erase_components",
]
[target.wasm32-unknown-unknown]
rustflags = ["--cfg=web_sys_unstable_apis"]

[build]
target = "wasm32-unknown-unknown"
EOL

echo "Leptos project initialized successfully!"
echo "Run 'trunk serve' to start the development server."

# Create readme.md
cat > README.md << 'EOL'
# Leptos Application

A modern web application built with Leptos and WebAssembly.

## Prerequisites

Ensure you have the following installed:

- Rust and Cargo (latest stable version)
- WebAssembly target: `rustup target add wasm32-unknown-unknown`
- Trunk: `cargo install trunk`
- Leptosfmt: `cargo install leptosfmt`
- Cargo Leptos: `cargo install cargo-leptos`

## Development

1. Start the development server:
   ```bash
   trunk serve --open
   ```

2. For hot-reload functionality:
   ```bash
   cargo leptos watch
   ```

## Project Structure

- `src/main.rs` - Main application entry point and components
- `index.html` - HTML template
- `styles.css` - Global styles
- `.cargo/config.toml` - Cargo configuration for WASM

## Features

- Modern Rust web framework
- WebAssembly for high performance
- Component-based architecture
- Hot-reload development
- CSS styling system
- Type-safe reactive state management
EOL

echo "Leptos project initialized successfully!"
echo "Navigate to the project directory: cd leptos-app"
echo "Start the development server: trunk serve --open"