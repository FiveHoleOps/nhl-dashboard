#!/bin/bash
# FiveHoleOps NHL Dashboard

# --- GLOBAL SETUP ---
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
TOMORROW=$(date -d "tomorrow" +%Y-%m-%d)
WHITE="\e[97m"; BOLD="\e[1m"; RESET="\e[0m"; BLUE="\e[38;5;33m"; RED="\e[31m"
GOLD="\e[38;5;214m"; GREEN="\e[32m"; DIM="\e[2;38;5;33m"

scores() {
    local MODE=$1 # Can be "today_only" or empty
    local WHITE="\e[97m"; local BOLD="\e[1m"; local RESET="\e[0m";
    local GREEN="\e[32m"; local RED="\e[31m"; local GOLD="\e[38;5;214m"

    # --- YESTERDAY'S FINALS (Skip if watchscores) ---
    if [[ "$MODE" != "today_only" ]]; then
        local Y_DATA=$(curl -s -H "User-Agent: Mozilla" "https://api-web.nhle.com/v1/score/$YESTERDAY")
        echo -e "\e[38;5;214m${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
        echo -e "\e[38;5;214m${BOLD}┃             YESTERDAY'S FINALS ($YESTERDAY)             ┃${RESET}"
        echo -e "\e[38;5;214m${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"

        while read -r AWAY ASCORE HOME HSCORE PERIOD; do
            ACOLOR=$WHITE; HCOLOR=$WHITE
            if [ "$ASCORE" -gt "$HSCORE" ]; then ACOLOR=$GREEN; HCOLOR=$RED;
            elif [ "$HSCORE" -gt "$ASCORE" ]; then HCOLOR=$GREEN; ACOLOR=$RED; fi
            TAG="[FINAL]"; [[ "$PERIOD" -eq 4 ]] && TAG="[FINAL][OT]"; [[ "$PERIOD" -ge 5 ]] && TAG="[FINAL][SO]"
            printf " $(nhl_team_style "$AWAY") %-3s ${RESET} ${ACOLOR}%2d${RESET}  @  $(nhl_team_style "$HOME") %-3s ${RESET} ${HCOLOR}%2d${RESET}  | %s\e[K\n" \
                "$AWAY" "$ASCORE" "$HOME" "$HSCORE" "$TAG"
        done < <(echo "$Y_DATA" | jq -r '.games[] | "\(.awayTeam.abbrev) \(.awayTeam.score // 0) \(.homeTeam.abbrev) \(.homeTeam.score // 0) \(.periodDescriptor.number // 3)"')
        echo ""
    fi

    # --- DAILY SCOREBOARD SECTION ---
    local T_DATA=$(curl -s -H "User-Agent: Mozilla" "https://api-web.nhle.com/v1/score/$TODAY")
    echo -e "${WHITE}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    echo -e "${WHITE}${BOLD}┃           NHL DAILY SCOREBOARD ($TODAY)            ┃${RESET}"
    echo -e "${WHITE}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"

    while read -r AWAY ASCORE HOME HSCORE STATUS PERIOD CLOCK START IS_INT; do
        ACOLOR=$WHITE; HCOLOR=$WHITE
        case $PERIOD in 1) P="1st" ;; 2) P="2nd" ;; 3) P="3rd" ;; 4) P="OT" ;; 5) P="SO" ;; *) P="P$PERIOD" ;; esac

        if [[ "$STATUS" == "INT" || "$IS_INT" == "true" ]]; then
            if [ "$ASCORE" -gt "$HSCORE" ]; then ACOLOR=$GREEN; HCOLOR=$RED;
            elif [ "$HSCORE" -gt "$ASCORE" ]; then HCOLOR=$GREEN; ACOLOR=$RED;
            else ACOLOR=$GOLD; HCOLOR=$GOLD; fi
            TIME_OUT="${GOLD}[INT] End of $P ($CLOCK)${RESET}"
        elif [[ "$STATUS" == "FINAL" || "$STATUS" == "OFF" || ( "$CLOCK" == "00:00" && "$PERIOD" -ge 3 ) ]]; then
            if [ "$ASCORE" -gt "$HSCORE" ]; then ACOLOR=$GREEN; HCOLOR=$RED;
            else HCOLOR=$GREEN; ACOLOR=$RED; fi
            TAG="[FINAL]"; [[ "$PERIOD" -eq 4 ]] && TAG="[FINAL][OT]"; [[ "$PERIOD" -ge 5 ]] && TAG="[FINAL][SO]"
            TIME_OUT="$TAG"
        elif [[ "$STATUS" == "LIVE" || "$STATUS" == "CRIT" ]]; then
            if [ "$ASCORE" -gt "$HSCORE" ]; then ACOLOR=$GREEN; HCOLOR=$RED;
            elif [ "$HSCORE" -gt "$ASCORE" ]; then HCOLOR=$GREEN; ACOLOR=$RED;
            else ACOLOR=$GOLD; HCOLOR=$GOLD; fi
            TIME_OUT="[LIVE] $P $CLOCK"
        else
            LOCAL_TIME=$(date -d "$START" +"%I:%M %p")
            TIME_OUT="[$STATUS] $LOCAL_TIME"
        fi

        printf " $(nhl_team_style "$AWAY") %-3s ${RESET} ${ACOLOR}%2d${RESET}  @  $(nhl_team_style "$HOME") %-3s ${RESET} ${HCOLOR}%2d${RESET}  | %s\e[K\n" \
            "$AWAY" "$ASCORE" "$HOME" "$HSCORE" "$TIME_OUT"
    done < <(echo "$T_DATA" | jq -r '.games[] | "\(.awayTeam.abbrev) \(.awayTeam.score // 0) \(.homeTeam.abbrev) \(.homeTeam.score // 0) \(.gameState) \(.periodDescriptor.number // 0) \(.clock.timeRemaining // "00:00") \(.startTimeUTC) \(.clock.inIntermission // false)"')

    # --- TOMORROW'S SCHEDULE (Skip if watchscores) ---
    if [[ "$MODE" != "today_only" ]]; then
        local TOM_DATA=$(curl -s -H "User-Agent: Mozilla" "https://api-web.nhle.com/v1/score/$TOMORROW")
        echo -e "\n\e[38;5;33m${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
        echo -e "\e[38;5;33m${BOLD}┃            TOMORROW'S SCHEDULE ($TOMORROW)            ┃${RESET}"
        echo -e "\e[38;5;33m${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"

        while read -r AWAY HOME START; do
            LOCAL_TIME=$(date -d "$START" +"%I:%M %p")
            printf " $(nhl_team_style "$AWAY") %-3s ${RESET}     @  $(nhl_team_style "$HOME") %-3s ${RESET}     | %s\n" \
                "$AWAY" "$HOME" "$LOCAL_TIME"
        done < <(echo "$TOM_DATA" | jq -r '.games[] | "\(.awayTeam.abbrev) \(.homeTeam.abbrev) \(.startTimeUTC)"')
    fi
}

watchscores() {
    tput civis
    clear
    trap "tput cnorm; clear; return" INT
    while true; do
        # Call scores with the "today_only" argument
        buffer=$(scores "today_only")
        printf "\033[H"
        echo -e "$buffer"
        printf "\033[J"
        sleep 15
    done
}

wings() {
    local WHITE="\e[97m"; local BOLD="\e[1m"; local RESET="\e[0m"; local RED="\e[31m"
    local NOW=$(date +%Y-%m-%d)

    # 1. SCHEDULE
    echo -e "\e[38;2;200;16;46m${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    echo -e "\e[38;2;200;16;46m${BOLD}┃             RED WINGS UPCOMING SCHEDULE                ┃${RESET}"
    echo -e "\e[38;2;200;16;46m${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
    S_DATA=$(curl -s -H "User-Agent: Mozilla" "https://api-web.nhle.com/v1/club-schedule-season/DET/20252026")
    echo "$S_DATA" | jq -r ".games[] | select(.gameDate >= \"$NOW\") | \"\(.gameDate)|\(.awayTeam.abbrev)|\(.homeTeam.abbrev)|\(.startTimeUTC)\"" | head -n 5 | while IFS='|' read -r GDATE AWAY HOME GUTC; do
        echo -e " $(date -d "$GDATE" +"%a %Y-%m-%d") | $(nhl_team_style "$AWAY") $AWAY ${RESET} @ $(nhl_team_style "$HOME") $HOME ${RESET} | ${BOLD}$(date -d "$GUTC" +"%I:%M %p")${RESET}"
    done

    # Progress Check
    STANDINGS=$(curl -s -H "User-Agent: Mozilla/5.0" "https://api-web.nhle.com/v1/standings/$TODAY")
    DET_STATS=$(echo "$STANDINGS" | jq -r '.standings[] | select(.teamAbbrev.default=="DET") | "\(.gamesPlayed)|\(.points)"')

    if [[ -n "$DET_STATS" ]]; then
        PLAYED=$(echo "$DET_STATS" | cut -d'|' -f1)
        POINTS=$(echo "$DET_STATS" | cut -d'|' -f2)
        REMAINING=$((82 - PLAYED))
        MAX_PTS=$((POINTS + (REMAINING * 2)))
        PTS_TO_95=$((95 - POINTS))
        [[ $PTS_TO_95 -lt 0 ]] && PTS_TO_95=0

        echo -e "\n ${RED}${BOLD}DET Season Progress:${RESET} $PLAYED/82 Games Played ($REMAINING Remaining)"
        echo -e " ${WHITE}Points: ${BOLD}$POINTS${RESET} | Max Possible: ${BOLD}$MAX_PTS${RESET} | Needed for 95: ${BOLD}$PTS_TO_95${RESET}"
    fi

    # 3. WINGING IT IN MOTOWN NEWS
    echo -e "\n\e[38;2;200;16;46m${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    echo -e "\e[38;2;200;16;46m${BOLD}┃                WINGING IT IN MOTOWN NEWS               ┃${RESET}"
    echo -e "\e[38;2;200;16;46m${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
    FEED=$(curl -s -L -H "User-Agent: Mozilla" "https://www.wingingitinmotown.com/feed")
    TITLES=$(echo "$FEED" | grep -oP '(?<=<title>).*?(?=</title>)' | sed '1,2d' | head -n 5)
    LINKS=$(echo "$FEED" | grep -oP '(?<=<link>).*?(?=</link>)' | sed '1,2d' | head -n 5)
    while IFS= read -r title <&3 && IFS= read -r link <&4; do
        clean_title=$(echo "$title" | sed 's/<!\[CDATA\[//g; s/\]\]>//g; s/&amp;/\&/g; s/&#8211;/-/g')
        echo -e " ${BOLD}• $clean_title${RESET}\n   ${DIM}$link${RESET}"
    done 3<<<"$TITLES" 4<<<"$LINKS"
}

nhlnews(){
    # 4. LATEST NEWS
    echo -e "\n\e[38;5;45m${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    echo -e "${BOLD}\e[38;5;45m┃                LATEST PRO HOCKEY NEWS                  ┃${RESET}"
    echo -e "\e[38;5;45m┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
    FEED=$(curl -s -H "User-Agent: Mozilla/5.0" "https://prohockeynews.com/feed/")
    TITLES=$(echo "$FEED" | grep -oP '(?<=<title>).*?(?=</title>)' | sed '1,2d' | head -n 8)
    LINKS=$(echo "$FEED" | grep -oP '(?<=<link>).*?(?=</link>)' | sed '1,2d' | head -n 8)

    while IFS= read -r title <&3 && IFS= read -r link <&4; do
        clean_title=$(echo "$title" | sed 's/<!\[CDATA\[//g; s/\]\]>//g; s/&amp;/\&/g; s/&#8211;/-/g')

        display_title=$(echo "$clean_title" | sed "s/\(Red Wings\|Detroit\|DET\)/\x1b[31m\1\x1b[0m\x1b[1m/gI")

        echo -e " ${BOLD}• $display_title${RESET}"
        echo -e "   ${DIM}$link${RESET}"
    done 3<<<"$TITLES" 4<<<"$LINKS"
}

bracket() {
    # --- SETUP ---
    GOLD="\e[38;5;214m"; BLUE="\e[38;5;33m"; RED="\e[31m"; BOLD="\e[1m"; RESET="\e[0m"; WHITE="\e[97m"; DIM="\e[2m"
    DATA=$(curl -s -L -H "User-Agent: Mozilla" "https://api-web.nhle.com/v1/standings/now")

    # ALIGNMENT HELPER
    v_pad() {
        local str="$1"
        local target=$2
        local visible_len=$(echo -e "$str" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print length}')
        local padding=$(( target - visible_len ))
        echo -ne "$str"
        [[ $padding -gt 0 ]] && printf '%*s' "$padding" ""
    }

    # API EXTRACTION
    get_div_t() { echo "$DATA" | jq -r ".standings[] | select(.divisionAbbrev==\"$1\" and .divisionSequence==$2) | .teamAbbrev.default" | tr -d '"'; }
    get_div_p() { echo "$DATA" | jq -r ".standings[] | select(.divisionAbbrev==\"$1\" and .divisionSequence==$2) | .points"; }
    get_wc_t() { echo "$DATA" | jq -r ".standings[] | select(.conferenceAbbrev==\"$1\" and .wildcardSequence==$2) | .teamAbbrev.default" | tr -d '"'; }
    get_wc_p() { echo "$DATA" | jq -r ".standings[] | select(.conferenceAbbrev==\"$1\" and .wildcardSequence==$2) | .points"; }

    # --- WEST DATA (Central/Pacific) ---
    C1=$(get_div_t C 1); C1P=$(get_div_p C 1); C2=$(get_div_t C 2); C2P=$(get_div_p C 2); C3=$(get_div_t C 3); C3P=$(get_div_p C 3)
    P1=$(get_div_t P 1); P1P=$(get_div_p P 1); P2=$(get_div_t P 2); P2P=$(get_div_p P 2); P3=$(get_div_t P 3); P3P=$(get_div_p P 3)
    WWC1=$(get_wc_t W 1); WWC1P=$(get_wc_p W 1); WWC2=$(get_wc_t W 2); WWC2P=$(get_wc_p W 2)

    # --- EAST DATA (Atlantic/Metro) ---
    A1=$(get_div_t A 1); A1P=$(get_div_p A 1); A2=$(get_div_t A 2); A2P=$(get_div_p A 2); A3=$(get_div_t A 3); A3P=$(get_div_p A 3)
    M1=$(get_div_t M 1); M1P=$(get_div_p M 1); M2=$(get_div_t M 2); M2P=$(get_div_p M 2); M3=$(get_div_t M 3); M3P=$(get_div_p M 3)
    EWC1=$(get_wc_t E 1); EWC1P=$(get_wc_p E 1); EWC2=$(get_wc_t E 2); EWC2P=$(get_wc_p E 2)

    # --- CROSSOVER LOGIC ---
    [[ $C1P -ge $P1P ]] && { C_OPP=$WWC2; C_OPP_P=$WWC2P; P_OPP=$WWC1; P_OPP_P=$WWC1P; } || { C_OPP=$WWC1; C_OPP_P=$WWC1P; P_OPP=$WWC2; P_OPP_P=$WWC2P; }
    [[ $A1P -ge $M1P ]] && { A_OPP=$EWC2; A_OPP_P=$EWC2P; M_OPP=$EWC1; M_OPP_P=$EWC1P; } || { A_OPP=$EWC1; A_OPP_P=$EWC1P; M_OPP=$EWC2; M_OPP_P=$EWC2P; }

    # --- DISPLAY ---
    echo -e "${GOLD}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    echo -e "${GOLD}${BOLD}┃                 NHL PLAYOFF BRACKET (IF STARTED TODAY)              ┃${RESET}"
    echo -e "${GOLD}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
    echo -e "  ${RED}WESTERN CONFERENCE${RESET}             |        ${BLUE}EASTERN CONFERENCE${RESET}"
    echo -e "  ━━━━━━━━━━━━━━━━━━━            |        ━━━━━━━━━━━━━━━━━━"

    echo -e "  $(v_pad "$(nhl_team_style $C1) $C1 ${RESET}($C1P) vs $(nhl_team_style $C_OPP) $C_OPP ${RESET}($C_OPP_P)" 30) |        $(nhl_team_style $A1) $A1 ${RESET}($A1P) vs $(nhl_team_style $A_OPP) $A_OPP ${RESET}($A_OPP_P)"
    echo -e "  $(v_pad "$(nhl_team_style $C2) $C2 ${RESET}($C2P) vs $(nhl_team_style $C3) $C3 ${RESET}($C3P)" 30) |        $(nhl_team_style $A2) $A2 ${RESET}($A2P) vs $(nhl_team_style $A3) $A3 ${RESET}($A3P)"
    echo -e "                                 |"
    echo -e "  $(v_pad "$(nhl_team_style $P1) $P1 ${RESET}($P1P) vs $(nhl_team_style $P_OPP) $P_OPP ${RESET}($P_OPP_P)" 30) |        $(nhl_team_style $M1) $M1 ${RESET}($M1P) vs $(nhl_team_style $M_OPP) $M_OPP ${RESET}($M_OPP_P)"
    echo -e "  $(v_pad "$(nhl_team_style $P2) $P2 ${RESET}($P2P) vs $(nhl_team_style $P3) $P3 ${RESET}($P3P)" 30) |        $(nhl_team_style $M2) $M2 ${RESET}($M2P) vs $(nhl_team_style $M3) $M3 ${RESET}($M3P)"

    # Wild Card Bubble (Next two out)
    WOUT1=$(get_wc_t W 3); WOUT1P=$(get_wc_p W 3); WOUT2=$(get_wc_t W 4); WOUT2P=$(get_wc_p W 4)
    EOUT1=$(get_wc_t E 3); EOUT1P=$(get_wc_p E 3); EOUT2=$(get_wc_t E 4); EOUT2P=$(get_wc_p E 4)

    echo -e "\n ${WHITE}${BOLD}Current Wild Card Bubble (In/Out):${RESET}"
    echo -e " West: $(nhl_team_style $WWC1) $WWC1 ${RESET}($WWC1P), $(nhl_team_style $WWC2) $WWC2 ${RESET}($WWC2P)  |  Out: $(nhl_team_style $WOUT1) $WOUT1 ${RESET}($WOUT1P), $(nhl_team_style $WOUT2) $WOUT2 ${RESET}($WOUT2P)"
    echo -e " East: $(nhl_team_style $EWC1) $EWC1 ${RESET}($EWC1P), $(nhl_team_style $EWC2) $EWC2 ${RESET}($EWC2P)  |  Out: $(nhl_team_style $EOUT1) $EOUT1 ${RESET}($EOUT1P), $(nhl_team_style $EOUT2) $EOUT2 ${RESET}($EOUT2P)"
}

nhl_team_style() {
    case $1 in
        ANA) printf "\e[38;2;181;152;90;48;2;249;86;2m" ;;
        BOS) printf "\e[38;2;0;0;0;48;2;253;180;31m" ;;
        BUF) printf "\e[38;2;255;184;28;48;2;0;48;135m" ;;
        CAR) printf "\e[38;2;204;0;0;48;2;162;170;173m" ;;
        CBJ) printf "\e[38;2;200;16;46;48;2;4;30;66m" ;;
        CGY) printf "\e[38;2;243;189;72;48;2;200;36;46m" ;;
        CHI) printf "\e[38;2;0;0;0;48;2;207;10;44m" ;;
        COL) printf "\e[38;2;35;97;146;48;2;111;38;61m" ;;
        DAL) printf "\e[38;2;162;170;173;48;2;0;99;65m" ;;
        DET) printf "\e[38;2;255;255;255;48;2;200;16;46m" ;;
        EDM) printf "\e[38;2;209;69;32;48;2;0;32;91m" ;;
        FLA) printf "\e[38;2;206;14;45;48;2;188;149;92m" ;;
        LAK) printf "\e[38;2;163;171;174;48;2;0;0;0m" ;;
        MIN) printf "\e[38;2;170;24;44;48;2;18;71;52m" ;;
        MTL) printf "\e[38;2;25;33;104;48;2;175;30;45m" ;;
        NJD) printf "\e[38;2;0;0;0;48;2;200;16;46m" ;;
        NSH) printf "\e[38;2;4;30;66;48;2;255;184;28m" ;;
        NYI) printf "\e[38;2;244;125;48;48;2;0;83;155m" ;;
        NYR) printf "\e[38;2;206;17;38;48;2;0;56;168m" ;;
        OTT) printf "\e[38;2;218;26;50;48;2;0;0;0m" ;;
        PHI) printf "\e[38;2;0;0;0;48;2;250;70;22m" ;;
        PIT) printf "\e[38;2;0;0;0;48;2;255;184;28m" ;;
        SEA) printf "\e[38;2;0;22;40;48;2;153;217;217m" ;;
        SJS) printf "\e[38;2;0;0;0;48;2;0;109;117m" ;;
        STL) printf "\e[38;2;255;184;28;48;2;0;48;135m" ;;
        TBL) printf "\e[38;2;0;40;104;48;2;255;255;255m" ;;
        TOR) printf "\e[38;2;255;255;255;48;2;0;32;91m" ;;
        UTA) printf "\e[38;2;0;0;0;48;2;108;172;227m" ;;
        VAN) printf "\e[38;2;168;170;173;48;2;0;45;86m" ;;
        VGK) printf "\e[38;2;180;151;90;48;2;51;63;66m" ;;
        WPG) printf "\e[38;2;142;144;144;48;2;4;30;65m" ;;
        WSH) printf "\e[38;2;11;31;65;48;2;206;14;45m" ;;
        *) printf "\e[97;40m" ;;
    esac
}
