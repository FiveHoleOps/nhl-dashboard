# FiveHoleOps NHL Dashboard 🏒

A dynamic, terminal-based NHL dashboard built for sysadmins. Features real-time score tracking, team-specific news feeds, and a fully automated playoff engine.

## 🚀 Features
- **Dynamic Playoffs:** Automated bracket tracking that updates as series progress.
- **Visual Cues:**
    - Color-coded Conference markers (**Red E** / **Blue W**).
    - **Gold** highlighting for Series Winners.
    - **Strike-through** and dimming for eliminated teams.
- **Smart Logic:** Automatically transitions from Round 1 to the Stanley Cup Finals without manual code changes.
- **SysAdmin Friendly:** Lightweight Bash script with ANSI color formatting for high readability.

## 🛠 Setup & Usage
1. **Source the script** in your \`~/.bashrc\` to make functions available globally:
   \`\`\`bash
   echo "source ~/scripts/nhl-dashboard/nhl_dashboard.sh" >> ~/.bashrc
   \`\`\`

2. **Commands:**
    * \`playoffs\`: View the current Stanley Cup Playoff bracket and series standings.
    * \`wings\`: Check the Detroit Red Wings schedule, season progress, and latest news.
    * \`scores\`: View yesterday's finals and today's live scoreboard.
    * \`nhlnews\`: Pull the latest headlines from across the league.

## 📋 Requirements
* \`curl\`: For API data fetching.
* \`jq\`: For JSON parsing.
* \`bash\`: Optimized for Fedora/Ubuntu environments.

---
*Maintained by Benjamin Scott Morrow | FiveHoleOps*
