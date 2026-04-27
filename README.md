# FiveHoleOps NHL Dashboard

A terminal-based NHL scoreboard and news aggregator for Fedora.

## Features
- Live Scoreboard updates.
- Detroit Red Wings specialized tracker.
- Dynamic Playoff Bracket tracking.
- News aggregator from Pro Hockey News.

## Installation

### 1. Prerequisites
sudo dnf install curl jq

### 2. Setup
git clone [https://github.com/FiveHoleOps/nhl-dashboard.git](https://github.com/FiveHoleOps/nhl-dashboard.git)
cd nhl-dashboard
chmod +x nhl_dashboard.sh

## Usage

| Command | Description |
| :--- | :--- |
| ./nhl_dashboard.sh | Show finals, today's scores, and tomorrow's schedule. |
| ./nhl_dashboard.sh wings | Show Red Wings schedule and news. |
| ./nhl_dashboard.sh bracket | Show the "If the playoffs started today" bracket. |
| ./nhl_dashboard.sh news | Show the latest NHL headlines. |

## Integration

Add these to your ~/.bashrc:
alias wings='~/scripts/nhl-dashboard/nhl_dashboard.sh wings'
alias scores='~/scripts/nhl-dashboard/nhl_dashboard.sh'

---
*Maintained by FiveHoleOps*
