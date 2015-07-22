#!/usr/bin/python

import sys, getopt

def etc_mesos_zk(hosts):
  cfg = "zk://" + ','.join([host + ':2181' for host in hosts]) + '/mesos\n'
  #print cfg
  with open('/etc/mesos/zk', 'w') as cfg_file:
    cfg_file.write(cfg)

def etc_zk_conf_id(idee):
  with  open('/etc/zookeeper/conf/myid', 'w') as cfg_file:
    cfg_file.write(idee + '\n')

def etc_zk_conf_zoo(hosts):
  cfg = ""
  i=1
  for h in hosts:
    idee = str(i)
    cfg += "server." + idee + "=" + h +  ":2888:3888\n"
    i = i + 1
  
  #print cfg
  with open('/etc/zookeeper/conf/zoo.cfg', 'a') as cfg_file:
    cfg_file.write(cfg)

def main(argv):
   zk_hosts = []
   zk_id = -1
   master = False
   try:
      opts, args = getopt.getopt(argv, "h:n:m")
   except getopt.GetoptError:
      print 'config_zk.py -h <comma separated zk host ips> -n <zk id of this host> -m <if master>'
      sys.exit(2)
   for opt, arg in opts:
     if opt == '-h':
        zk_hosts = arg.split(',')
     elif opt == '-n':
        zk_id = arg
     elif opt == '-m':
        master = True

   #print 'Zk hosts are ', zk_hosts
   #print 'Zk id is ', zk_id
   
   etc_mesos_zk(zk_hosts)
   if master:
     etc_zk_conf_id(zk_id)
     etc_zk_conf_zoo(zk_hosts)


if __name__ == "__main__":
   main(sys.argv[1:])


