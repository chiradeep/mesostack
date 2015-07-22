#!/usr/bin/python

import sys, getopt, os, errno

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else: raise

def etc_mesos_quorum(hosts):
  num_hosts = len(hosts)
  q = int(num_hosts/2) + (num_hosts % 2 > 0)
  
  print q
  with open('/etc/mesos-master/quorum', 'w') as cfg_file:
    cfg_file.write(str(q) + '\n')

def etc_marathon_conf(hosts):
  cfg = "zk://" + ','.join([host + ':2181' for host in hosts]) + '/mesos\n'
  print cfg
  with open('/etc/marathon/conf/master', 'w') as cfg_file:
    cfg_file.write(cfg)
  cfg = "zk://" + ','.join([host + ':2181' for host in hosts]) + '/marathon\n'
  print cfg
  with open('/etc/marathon/conf/zk', 'w') as cfg_file:
    cfg_file.write(cfg)

def etc_mesos_ip(directory, myip):
  with open('/etc/' + directory +'/ip', 'w') as cfg_file:
    cfg_file.write(myip + '\n')
  with open('/etc/' + directory +'/hostname', 'w') as cfg_file:
    cfg_file.write(myip + '\n')

def etc_mesos_override(f):
  with open('/etc/init/' + f , 'w') as cfg_file:
    cfg_file.write('manual\n')

def etc_marathon_hostname(myip):
  with open('/etc/marathon/conf/hostname', 'w') as cfg_file:
    cfg_file.write(myip + '\n')


def main(argv):
   mesos_hosts = []
   myip = ""
   master = False
   try:
      opts, args = getopt.getopt(argv, "h:i:m")
   except getopt.GetoptError:
      print 'config_mesos.py -h <comma separated mesos master host ips> -i <ip of this host> -m <if master>'
      sys.exit(2)
   for opt, arg in opts:
     if opt == '-h':
        mesos_hosts = arg.split(',')
     elif opt == '-i':
        myip = arg
     elif opt == '-m':
        master = True

   
   if master:
     etc_mesos_quorum(mesos_hosts)
     etc_mesos_ip('mesos-master', myip)
     etc_mesos_override('mesos-slave')
     mkdir_p('/etc/marathon/conf')
     etc_marathon_conf(mesos_hosts)
     etc_marathon_hostname(myip)
   else: 
     etc_mesos_ip('mesos-slave', myip)
     etc_mesos_override('mesos-master')


if __name__ == "__main__":
   main(sys.argv[1:])


