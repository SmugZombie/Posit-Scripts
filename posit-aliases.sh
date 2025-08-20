alias config='f(){ vi /etc/rstudio/"$1";  unset -f f; }; f'
alias restart="/usr/sbin/rstudio-server stop && /usr/bin/rstudio-launcher stop && /usr/bin/rstudio-launcher start && /usr/sbin/rstudio-server start && sleep 2 && systemctl --no-pager -l status rstudio-server && systemctl --no-pager -l status rstudio-launcher"
alias status="systemctl --no-pager -l status rstudio-server && systemctl --no-pager -l status rstudio-launcher"
alias stop="/usr/sbin/rstudio-server stop && /usr/bin/rstudio-launcher stop"
alias start="/usr/bin/rstudio-launcher start && /usr/sbin/rstudio-server start && sleep 2 && systemctl --no-pager -l status rstudio-server && systemctl --no-pager -l status rstudio-launcher"
alias diagnostic="/usr/sbin/rstudio-server run-diagnostics"
alias license-status="/usr/sbin/rstudio-server license-manager status"
alias logs='GREEN="\033[0;32m" && NC="\033[0m" && echo -e ${GREEN}"\n Posit Workbench Logs:\n"${NC} && tail -n 15 /var/log/rstudio/rstudio-server/rserver.log && echo -e ${GREEN}"\n Posit Launcher Logs:\n"${NC} && tail -n 15 /var/log/rstudio/launcher/rstudio-launcher.log'
