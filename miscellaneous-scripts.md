# 2. Scripts in other languages
## 2.1 - Script in expect language
For automatically configuration corporate routers and generate custom reports.
- - -
~~~expect
proc status_connect { spwnid } {
  set timeout 0
  global IP
  global USER
  global  PASSWORD
  global spawn_id
  global conec
  set spawn_id $spwnid
  set cont 0
  set contg 0
  set conec 0
  while {$conec == 0} {
      if { $contg == 40000 } then { return "TIMEOUT" }
      if { $cont == 3 } then { return "NRETURN" }
      expect -i $spawn_id "No route" { return "NOROUTE" }
      expect -i $spawn_id "yes" { send "yes\r" }
      expect -i $spawn_id "sername" { send "$USER\r" }
      expect -i $spawn_id "IDENTIFICATION HAS CHANGED" { send -i $spawn_id "ssh-keygen -R $IP\r"; send -i $spawn_id "\r" }
      expect -i $spawn_id "assword" { send -i $spawn_id "$PASSWORD\r"; set cont [ expr $cont + 1 ] }
      expect -i $spawn_id "ast login" { set conec 1 }
      expect -i $spawn_id "elcome" { set conec 1 }
      expect -i $spawn_id "try again" { return "NRETURN" }
      expect -i $spawn_id "ad secrets" { return "NRETURN" }
      expect -i $spawn_id "publickey" { return "NPUBKEY" }
      expect -i $spawn_id "denied" { return "NDENIED" }
      expect -i $spawn_id "refused" { return "NREFUSE" }
      expect -i $spawn_id "Unable to connect" { return "NUNABLE" }
      expect -i $spawn_id "onnection closed" { return "NCLOSED" }
      set contg [ expr $contg + 1 ]
  }
  return "SUCCESS"
}

spawn ssh "$USER@$IP"
set return_connect [ status_connect $spawn_id ]
send "\n"
interact "+" expect -i $spawn_id "exit" { send_user [exec clear]
~~~

## 2.2 - Python in Xenserver
To make custom panel for managing VMs and templates, snapshot of VM.
- - -
~~~python
def getIDbyHost(sessionxenapi, HOSTNAME):
    ref_host = sessionxenapi.xenapi.host.get_by_name_label(HOSTNAME)[0]
    id = sessaoxenapi.xenapi.host.get_uuid(ref_host)
    return id

def getNameByHost(sessionxenapi, UUIDHOST):
    ref_host = sessionxenapi.xenapi.host.get_by_uuid(UUIDHOST)
    nome = sessionxenapi.xenapi.host.get_name_label(ref_host)
    return name

def saveVM(self, contad=1):
        if self.dictProtection["type"]=="":
            return
        else:
            xe1a='xe vm-param-set ha-restart-priority="best-effort"'
            xe1b=' ha-always-run=true uuid='
            xe2="xe vm-param-set ha-restart-priority="
            xe3=xe2+"3 ha-always-run=false uuid="
            if self.dictProtection["type"]=="M":
                os.system(xe1a+xe1b+str(self.newListVM[self.pos_tab][5]))
            elif self.dictProtection["type"]=="P":
                os.system(xe2+self.dictProtection["nivel"]+xe1b\
                          +str(self.newListVM[self.pos_tab][5]))
            else:
                os.system(xe3+str(self.newListVM[self.pos_tab][5]))
            vmsDB = self.connect_db(constants_ha.PATH_LOCAL_FILE_VMS)
            for a in vmsDB:
                if a.uuid==str(self.newListVM[self.pos_tab][5]):
                    a.typeProtection=self.dictProtection["type"]
                    a.nivelProtection=self.dictProtection["nivel"]
            self.save_db(constants_ha.PATH_LOCAL_FILE_VMS,vmsDB)
            self.save()
~~~

## 2.3 - JavaScript in GoogleForms
For custom forms like this javascript code.
- List names registered and available positions.
- Discontinue registration on Saturday.
- Delete records and open form for new records.
- - -
~~~javascript
function limitarRespostas() {
    // Limit records
    var limite = 40
    
    var msg = "People registered\n"
    var today = new Date()
    
    var form = FormApp.getActiveForm();
    var contagem = form.getResponses().length
    var a = '0'
    var msgLimite
    var msgRestam

    //  Make people registered
    for (var i = 0; i < contagem; i++) {
        if ( i+1 >= 10  ) { a = '' }
        msg = msg + a + (i+1) + ' - ' + form.getResponses()[i].getItemResponses()[0].getResponse() + '\n';
    }
  
    // Lock, If limit exceed
    if ( contagem > (limite-1) || (today.getDay() == 6 && today.getHours() >= 20)||today.getDay() == 0) {
        // Message for records lock
        form.setAcceptingResponses(false).setCustomClosedFormMessage("Registration not available\n" + msg);
        // If is Sunday, delete records at 10 PM
        if (today.getDay() == 0 && today.getHours() == 22 ) {
              form.deleteAllResponses();
        }
    } else {
        form.setAcceptingResponses(true);
        msgLimite = "Total records : " + limite;
        msgRestam = "Records available : " + (limite - contagem);
        form.setDescription( msgLimite + "\n" + msgRestam + "\n" + msg + "\n\"Refresh page\"\n");
    }
}

~~~
