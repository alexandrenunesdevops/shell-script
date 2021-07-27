# Introduction
The codes are not tutorial , are example only, just to show the possibilities. Some are purposely incomplete.

## 1. Shell Script

Example of using shell script to automate tasks, resolve temporary issues, troubleshoot and connect different platforms.

### 1.1 - Zabbix
To monitor backup software using remote SQL query.
For example for check if exist restore in last 30 days and all last 7 days backups in postgresql database bacula using parameter.
- - -
> UserParameter=check.restore[\*], **/opt/zabbix_script.sh  _last-restored_**  
> UserParameter=check.backup[\*], **/opt/zabbix_script.sh  last-backups_**
- - -
 ~~~bash  
 fnRestore(){
   QueryColumn="(CASE WHEN COUNT(\*) > 0 THEN 1 ELSE 0 END) AS LAST_MONTH_RESTORE"  
   QueryFilter="schedTime > (CURRENT_DATE - interval '1 month') AND type = 'R'"  
   QuerySelect="SELECT $QueryColumn FROM Job WHERE $QueryFilter"  
   QueryResult=$(psql -d $1 -U $2 -t -c "$QuerySelect;" | head -1 | sed "s/ //g")  
   return “$QueryResult”  
}  
 
fnLastBackups(){  
   QueryLast=$(psql -d $1 -U $2 -t -c "\  
           SELECT DISTINCT CONCAT(‘- ’,(j.name)), \  
                         ‘(ID:’,( SELECT MAX(j2.jobId) \  
                            FROM Job j2 \  
                            WHERE j2.name = j.name \  
                          ),‘ scheduled ’,( SELECT j2.schedTime \  
                           FROM Job j2 \  
                           WHERE jobId = ( SELECT MAX(j2.jobId) \  
                                                      FROM Job j2 \  
                                                      WHERE j2.name = j.name ) \  
                         ), ‘ – status:’,( SELECT j2.jobStatus \  
                            FROM Job j2 \  
                            WHERE jobId = ( SELECT MAX(j2.jobId) \  
                                                       FROM Job j2 \  
                                                       WHERE j2.name = j.name ) \  
                            AND j2.jobStatus NOT LIKE 'T' ),”)<br/>”) AS "LastJobs" \  
             FROM job j \  
             WHERE j.schedTime > (CURRENT_DATE - interval '$3 day') \  
             ORDER BY j.name ASC;" | sed "s/[\|]/ /g" )  
    if [[ "$QueryLast" != "" ]]; then  
        echo "Success jobs:<br/>"  
        echo -e "$QueryLast"  
    else  
        echo "No jobs"  
    fi  
}  

case $1 in
    last-restored) fnRestore “$dbAApp” “$userApp” ;;
    list-backups) fnLastBackups  “$dbAApp” “$userApp” “7”
    *);;
esac
~~~


### 1.2 - Cups
For Insert and get information for files jobs, through decision making accept or send for new remote cups.
- - -
~~~bash
fnGenerateInformation(){
    ls spool/cups| sed -rn “s/^d([^-]+)(-[0-9]+){,1}/\1/p”|bc|sort -u|while read j;
    do
        FJob=$(/spool/cups/d$(printf "%05.f" $j)-001)
        HeadJob=$(sed '35q' $FJob | sed -n '/^[@%]/p')
        JobNumCopies=$(echo -e "$HeadJob" | \
                                     sed -rn "s/%RBINumCopies: (.*)/\1/p" | \
                                     sed "s/\"//g" | sed "s/ //g")
        JobPages=$(tail -n 20 $FJob | sed -rn 's/%%Pages: ([0-9]+)/\1/p')
        #convert and convert back utf-8
        JobTitle=$(echo -e "$HeadJob" | sed -rn "s/%%Title:.(.*)/\1/p" | \
                          iconv -f iso-8859-1 -t utf-8| iconv -f utf-8 -t iso-8859-1)
        JobPrivate=$(echo -e "$HeadJob" | \
                              sed -rn "s/@PJL.*SET.*HOLDTYPE[ ]{0,}=[ ]{0,}(.*)/\1/p" | \
                              sed "s/\"//g")
        if [[ “$JobTitle” =~ remote$ ]]; then
            lpmove frontprinter-$j remote-server-print
        else
            /opt/internal-task.sh  “$FJob” \
                                   "${JobPages}" \
                                   "${JobNumCopies:-"1"}" \
                                   "${JobPrivate:-"NO"}" \
                                   "${JobTitle:-="NO"}"
        fi
    done
}

while true; do
    timeout $TIMEOUTEXEC inotifywait /spool/cups -e create --format "%e" 1>/dev/null 2>&1
    fnGenerateInformation
done

~~~

### 1.3 - Nextcloud
To analyzer scanned files and link those files to the corresponding nextcloud users and move the files to user storage in nextcloud. Using systemctl for automate.
- - - 
> [Unit]  
> Description=Scan for nextcloud  
> ConditionPathExists=/opt/script_nextcloud.sh  
>   
> [Service]  
> Type=simple  
> ExecStart=/opt/script_nextcloud.sh  
> ExecReload=/bin/kill -HUP $MAINPID  
>   
> [Install]  
> WantedBy=default.target  
- - -
~~~bash
fnMove(){
    if [[ ! -d /home/$1/files/Scan-Files ]]; then
        mkdir -p "/home/$1/files/Scan-Files"
        chmod 750 "/home/$1/files/Scan-Files"
    fi
    mv “$2” “/home/$1/files/Scan-Files/$3”
    chmod 640 "/home/$1/files/Scan-Files/$3"
    chown -R $userWebServer.$userWebServer "/home/$1/files/Scan-Files"
    sudo -u $userWebServer php occ files:scan --path="$1/files/Scan-Files"
}

inotifywait -q -r -m $EVENT /www/ftp --format "%w}[:sEpArAtE:]{%f"|while read l 
do
    f=$(echo "$l"| sed -rn "s/.*\}\[:sEpArAtE:\]\{(.*)/\1/p")
    w=$(echo "$l"| sed -rn "s/(.*)\}\[:sEpArAtE:\]\{.*/\1/p")
    if [[ "$f" =~ \.(${EXTENSIONS// /\|})$ ]]; then
        UserScan=$(fnGetUser "$w")
        fnMove "$UserScan" "$w" "$f"
    fi
done
~~~

### 1.4 - Asterisk
For get and modification configurations.
Management voip phone in dhcp configuration.
- - -
~~~bash
fnChangePassword(){
    rasterisk -rx "database put DEVICE ${1}/PASSWORD $2 1> /dev/null
}
fnRedirect(){
    rasterisk -rx "database put CF $1 $2" 1> /dev/null
}
fnExtensionsOff(){
    asterisk -rx "sip show peers" | \
    sed -rn "/OK/d;s/^([0-9]{3}[0-9]+)[^0-9].*/\1/p"
}
fnExtensionsCallForward(){
    asterisk -rx "database show CW" | sed -rn "s/.*CW.([0-9]{4}).*: (.*)/\1/p"
}
~~~
