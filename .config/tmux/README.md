# Tmux Configuration Guide

To achieve a clean, maintainable, and modular structure for your Tmux configuration, it's important to organize your files in a logical way, separating concerns while allowing for easy updates and readability. Here are some best practices and guidelines you can follow when organizing configuration files (themes, plugins, keybindings, hooks) and custom scripts in the /tmux directory.

## 1. Directory Structure

A good directory structure helps maintain a separation of concerns and modularity.
Here's an ideal structure for organizing your Tmux configuration:

```plaintext
 / /tmux  🥷
 ~/.config/tmux/
├──  scripts
│  ├──  fzf.sh
│  ├──  mem.sh
│  ├──  cpu.sh
│  └──  uptime.sh
├──  config
│  ├──  hooks.conf
│  ├──  core.conf
│  ├──  binds.conf
│  ├──  theme.conf
│  └──  plugins.conf
├──  READMI.md
└──  tmux.conf
```

## 2. Configuration File Organization:

Each category (themes, plugins, keybindings, hooks) should be dedicated to its specific purpose. For instance:

themes/: Store different color schemes or styling configurations in this folder. You can switch between them easily by sourcing different theme files in your main Tmux configuration.

plugins/: Place configurations related to plugins here. If you're using plugin managers like tpm (Tmux Plugin Manager), this is where you'd place configurations for individual plugins.

keybindings/: Organize keybindings by function. You might have keybindings for pane navigation, copy mode, or specific Tmux utilities. This keeps things modular and easy to maintain.

hooks/: Store event-driven configuration (e.g., pane, window, or session lifecycle hooks) in this folder. It ensures your hooks are separate from the core logic, making them easier to edit and maintain.

scripts/: If you need custom scripts to interact with Tmux (e.g., backup sessions, kill sessions, or resurrect workflows), placing them in a dedicated folder keeps everything organized and maintains clarity.

## 3. Main Configuration File (tmux.conf):

Your main tmux.conf should act as the orchestrator, sourcing configuration files from different directories. Here's a sample tmux.conf file that sources these configuration files in an organized manner:

## 4. Best Practices for Maintainability:

Use Descriptive Filenames: Ensure all filenames are descriptive and convey what they do (e.g., pane_navigation.conf, copy_mode.conf, session_hooks.conf). This makes it easier to find and edit specific configurations later.

Modular Configurations: Keep each file small and focused on one task (e.g., a file for pane keybindings, another for hook configurations). This modular approach avoids the complexity of having a massive, hard-to-navigate configuration file.

Version Control: Use Git or another version control system to track changes to your Tmux configuration. This allows you to experiment with different setups, revert to working configurations, and share your setup with others.

Comments: Include comments in your configuration files to explain what certain settings or scripts do. This is especially useful when coming back to the configuration after a long time or for sharing with others.

## 5. Custom Scripts:

In the scripts/ directory, custom scripts that automate tasks or provide utility functions (e.g., managing sessions, backups, or custom layouts) should be stored. You can source them in your Tmux config or bind them to key combinations.

```plaintext
~/.config/tmux/scripts/example.sh

#!/bin/bash

# This script backs up the current Tmux session and layout
tmux save-buffer ~/.tmux_resurrect/session_backup
echo "Tmux session backed up!"
```

## 6. Future-Proofing:

Modularize for Plugin Growth: As you add more plugins or configuration logic, consider expanding the plugins/ or other directories. Keeping things modular will help scale the configuration without cluttering the main config file.

Customizable Themes: As themes can be switched out easily by sourcing different theme files, this layout allows for simple experimentation and adjustments to the look and feel.

## Conclusion:

This structure emphasizes modularity, ease of maintenance, and clarity. With the directory structure outlined above, each component of your Tmux configuration is organized logically, making it easier to update and manage your setup over time.
