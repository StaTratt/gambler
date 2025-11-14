# Gambler

Automated Corsair roll management addon for Ashita v3/v4.

## How It Works

1. Cast a Phantom Roll normally, or using roll command
2. Addon monitors the roll result via game packets
3. Automatically uses Double-Up based on your settings
4. Uses Snake Eye when configured conditions are met
5. Stops rolling when bust risk exceeds threshold or target reached
6. Addon provides information on final number reached and resulting buff

## Configuration

Open the configuration window with `/gambler` to access:

## Commands

```
/gambler                  - Toggle configuration window
/gambler roll <name>      - Manually cast a roll (supports partial names)
/gambler lookup <text>    - Search for rolls by name or effect
/gambler help             - Display help message
```

## Credits

Roll data taken from rollTracker

