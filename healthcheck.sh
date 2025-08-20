BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Save the list of systemd unit files to a variable to avoid running systemctl multiple times
UNIT_FILES=$(systemctl list-unit-files)

echo -e ${BLUE}"Hostname: "${NC}`hostname` && \
echo -e -n ${BLUE}"OS Version: "${NC} && \
echo -e "$(grep -E '^(PRETTY_NAME)=' /etc/os-release | cut -d= -f2 | tr -d '"')" && \
echo -e ${BLUE}"IP Addresses: "${NC} && ip -o -4 addr show | awk -v BLUE="$BLUE" -v NC="$NC" '!/127.0.0.1/ {print "   " BLUE $2 NC ": " $4}'  && \
echo -e ${BLUE}"Memory Utilization:${NC} $(free -h | awk '/^Mem:/ {print $3 "/" $2}')" && \
echo -e ${BLUE}"CPU:${NC} $(lscpu | grep 'Model name' | awk -F: '{print $2}' | sed 's/^ *//')" && \
echo -e ${BLUE}"   CPU Cores:"${NC} $(nproc) && \
echo -e ${BLUE}"Mounted Directories and Storage:"${NC} && \
df -h | head -n 1 | GREP_COLORS='mt=01;32' grep -E --color 'K|M|G|T|Avail|Size|Filesystem|Use%|Used|Mounted on' && \
df -h | tail -n +2 | sort -k6 | GREP_COLORS='mt=01;32' grep -E --color 'K|M|G|T|Avail|Size|Filesystem|Use%|Used|Mounted on' && \

# RStudio Services
echo -e ${BLUE}"Checking RStudio Services:${NC}" && \
for svc in rstudio-server rstudio-launcher rstudio-connect rstudio-pm; do
    if echo "$UNIT_FILES" | grep -q "^$svc.service"; then
        status=$(systemctl is-active $svc 2>/dev/null)
        if [[ "$status" == "active" ]]; then
            echo -e "   ${BLUE}$svc:${GREEN} Installed${NC}"
        else
            echo -e "   ${BLUE}$svc:${YELLOW} Installed but Inactive${NC}"
        fi
    else
        echo -e "   ${BLUE}$svc:${RED} Not Installed${NC}"
    fi
done && \

# List installed R versions in /opt/R (only versions starting with 3 or 4)
echo -e ${BLUE}"Checking Installed R Versions (/opt/R):"${NC} && \
if [[ -d "/opt/R" ]]; then
    R_VERSIONS=$(ls -r /opt/R | grep -E '^[34]' | tr '\n' ',' | sed 's/,$//')
    if [[ -z "$R_VERSIONS" ]]; then
        echo -e "   ${RED}No Posit R versions installed${NC}"
    else
        echo -e "   ${GREEN}$R_VERSIONS${NC}"
    fi
else
    echo -e "   ${RED}No Posit R versions installed${NC}"
fi && \

# List installed Python versions in /opt/python (only versions starting with 3 or 4)
echo -e ${BLUE}"Checking Installed Python Versions (/opt/python):"${NC} && \
if [[ -d "/opt/python" ]]; then
    PYTHON_VERSIONS=$(ls -r /opt/python | grep -E '^[34]' | tr '\n' ',' | sed 's/,$//')
    if [[ -z "$PYTHON_VERSIONS" ]]; then
        echo -e "   ${RED}No Posit Python versions installed${NC}"
    else
        echo -e "   ${GREEN}$PYTHON_VERSIONS${NC}"
    fi
else
    echo -e "   ${RED}No Posit Python versions installed${NC}"
fi && \

# Check Internet Access
echo -e ${BLUE}"Checking Internet Access (google.com):"${NC} && \
if ping -c 1 -W 2 google.com &> /dev/null; then
    echo -e "   ${BLUE}Internet:${GREEN} Available${NC}"
else
    echo -e "   ${BLUE}Internet:${RED} Not Available${NC}"
fi && \

# Check Proxy Settings
echo -e ${BLUE}"Checking Proxy Settings:"${NC} && \
echo -e "   HTTP Proxy: ${NC}$(echo ${HTTP_PROXY:-None})" && \
echo -e "   HTTPS Proxy: ${NC}$(echo ${HTTPS_PROXY:-None})" && \

# Security Services Check
echo -e ${BLUE}"Checking Security Services:${NC}" && \
for sec_svc in iptables nftables firewalld; do
    if echo "$UNIT_FILES" | grep -q "^$sec_svc.service"; then
        status=$(systemctl is-active $sec_svc 2>/dev/null)
        if [[ "$status" == "active" ]]; then
            echo -e "   ${BLUE}$sec_svc:${GREEN} Installed & Active${NC}"
        else
            echo -e "   ${BLUE}$sec_svc:${YELLOW} Installed but Inactive${NC}"
        fi
    else
        echo -e "   ${BLUE}$sec_svc:${RED} Not Installed${NC}"
    fi
done && \

# Check SELinux Status
if command -v sestatus &> /dev/null; then
    SELINUX_STATUS=$(sestatus | awk '/SELinux status:/ {print $3}')
    if [[ "$SELINUX_STATUS" == "enabled" ]]; then
        echo -e "   ${BLUE}SELinux:${GREEN} Enabled${NC}"
    else
        echo -e "   ${BLUE}SELinux:${RED} Disabled${NC}"
    fi
else
    echo -e "   ${BLUE}SELinux:${RED} Not Installed${NC}"
fi && \

# Check AppArmor Status
if command -v aa-status &> /dev/null; then
    APPARMOR_STATUS=$(aa-status --enforce | grep -c "enforce mode")
    if [[ "$APPARMOR_STATUS" -gt 0 ]]; then
        echo -e "   ${BLUE}AppArmor:${GREEN} Enabled${NC}"
    else
        echo -e "   ${BLUE}AppArmor:${RED} Disabled${NC}"
    fi
else
    echo -e "   ${BLUE}AppArmor:${RED} Not Installed${NC}"
fi
